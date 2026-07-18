"""Estimate activity concentration and bus factor for detected systems."""

from __future__ import annotations

from collections import defaultdict
from typing import Any


ACTIVITY_THRESHOLD_PERCENT = 75.0


def _confidence(total_touches: int, author_count: int, relationship_confidences: list[str]) -> str:
    high_or_medium = sum(value in {"high", "medium"} for value in relationship_confidences)
    if total_touches >= 20 and author_count >= 2 and high_or_medium >= 2:
        return "high"
    if total_touches >= 8 and high_or_medium >= 1:
        return "medium"
    return "low"


def analyze_bus_factor(
    ownership: dict[str, Any], threshold_percent: float = ACTIVITY_THRESHOLD_PERCENT
) -> dict[str, Any]:
    if ownership.get("author_filter"):
        return {
            "status": "unavailable_in_author_scope", "threshold_percent": threshold_percent,
            "summary": {"systems_assessed": 0, "critical_systems": 0, "minimum_bus_factor": None},
            "systems": [], "method": "minimum authors reaching the cumulative activity threshold",
            "limitations": ["Bus factor requires repository-wide author activity; --author removes required comparison data."],
        }

    grouped: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for relationship in ownership.get("relationships", []):
        if relationship.get("system_activity_share_percent") is not None:
            grouped[relationship["system"]].append(relationship)

    systems = []
    for system, relationships in sorted(grouped.items(), key=lambda item: item[0].casefold()):
        ordered = sorted(relationships, key=lambda item: (-item.get("commits", 0), item["author"].casefold()))
        cumulative, critical_authors = 0.0, []
        for relationship in ordered:
            cumulative += relationship.get("system_activity_share_percent", 0)
            critical_authors.append({
                "author": relationship["author"],
                "activity_share_percent": relationship.get("system_activity_share_percent", 0),
                "commits": relationship.get("commits", 0),
                "files_touched": relationship.get("files_touched", 0),
            })
            if cumulative >= threshold_percent:
                break
        factor = len(critical_authors)
        total_touches = sum(item.get("commits", 0) for item in ordered)
        risk = "high_concentration" if factor == 1 else "moderate_concentration" if factor == 2 else "distributed"
        systems.append({
            "system": system, "bus_factor": factor, "risk": risk,
            "authors_with_activity": len(ordered), "total_commit_touches": total_touches,
            "covered_activity_percent": round(cumulative, 2), "critical_authors": critical_authors,
            "confidence": _confidence(total_touches, len(ordered), [item.get("confidence", "low") for item in ordered]),
            "system_confidence": ordered[0].get("system_confidence", "low") if ordered else "low",
        })

    factors = [item["bus_factor"] for item in systems]
    return {
        "status": "assessed" if systems else "insufficient_history",
        "threshold_percent": threshold_percent,
        "summary": {
            "systems_assessed": len(systems),
            "critical_systems": sum(item["bus_factor"] == 1 for item in systems),
            "minimum_bus_factor": min(factors) if factors else None,
        },
        "systems": systems,
        "method": "minimum authors whose cumulative author-file commit-touch share reaches 75% of detected-system activity",
        "limitations": [
            "This is an activity-concentration proxy, not a measurement of exclusive knowledge or replaceability.",
            "Git history can omit reviews, pair work, mentoring, uncommitted knowledge, squashed commits, and former repositories.",
            "Detected system boundaries and author aliases affect the estimate.",
        ],
    }
