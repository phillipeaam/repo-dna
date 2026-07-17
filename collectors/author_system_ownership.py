"""Infer author-to-system activity ownership from Git evidence."""

from __future__ import annotations

from collections import defaultdict
from typing import Any


def _belongs_to_system(path: str, system_path: str) -> bool:
    if system_path == "[root]":
        return "/" not in path
    return path == system_path or path.startswith(f"{system_path}/")


def _confidence(commits: int, files: int, churn: int) -> tuple[str, int]:
    score = min(100, commits * 5 + files * 10 + min(churn // 100, 20))
    if commits >= 10 and files >= 3 and score >= 70:
        return "high", score
    if (commits >= 3 or files >= 2) and score >= 30:
        return "medium", score
    return "low", score


def analyze_author_system_ownership(
    systems: list[dict[str, Any]], git_data: dict[str, Any]
) -> dict[str, Any]:
    activity = git_data.get("_file_author_activity", {})
    rows: list[dict[str, Any]] = []
    author_totals: dict[str, int] = defaultdict(int)
    system_records: dict[str, dict[str, dict[str, Any]]] = {}

    for system in systems:
        name = system["name"]
        system_path = system.get("path", name)
        authors: dict[str, dict[str, Any]] = defaultdict(lambda: {"commits": 0, "churn": 0, "files": set()})
        for path, contributions in activity.items():
            if not _belongs_to_system(path, system_path):
                continue
            for author, metrics in contributions.items():
                authors[author]["commits"] += metrics.get("commits", 0)
                authors[author]["churn"] += metrics.get("churn", 0)
                authors[author]["files"].add(path)
        system_records[name] = authors
        for author, metrics in authors.items():
            author_totals[author] += metrics["commits"]

    filtered = bool(git_data.get("author_filter"))
    for system in systems:
        name = system["name"]
        authors = system_records.get(name, {})
        system_total = sum(item["commits"] for item in authors.values())
        ordered = sorted(authors.items(), key=lambda item: (item[1]["commits"], item[1]["churn"]), reverse=True)
        for rank, (author, metrics) in enumerate(ordered, 1):
            commits = metrics["commits"]
            files = len(metrics["files"])
            confidence, confidence_score = _confidence(commits, files, metrics["churn"])
            rows.append({
                "author": author,
                "system": name,
                "rank_in_system": rank,
                "commits": commits,
                "churn": metrics["churn"],
                "files_touched": files,
                "system_activity_share_percent": None if filtered or not system_total else round(commits / system_total * 100, 2),
                "author_focus_percent": round(commits / author_totals[author] * 100, 2) if author_totals[author] else 0.0,
                "confidence": confidence,
                "confidence_score": confidence_score,
                "system_confidence": system.get("confidence", "low"),
            })

    rows.sort(key=lambda item: (item["system"].casefold(), item["rank_in_system"], item["author"].casefold()))
    return {
        "status": "assessed" if rows else "insufficient_history",
        "scope": git_data.get("scope", "repository"),
        "author_filter": git_data.get("author_filter", ""),
        "summary": {
            "authors": len({item["author"] for item in rows}),
            "systems": len({item["system"] for item in rows}),
            "relationships": len(rows),
            "high_confidence_relationships": sum(item["confidence"] == "high" for item in rows),
        },
        "relationships": rows,
        "method": "Git file-touch commits and churn aggregated into detected system boundaries",
        "limitations": [
            "Historical activity is an ownership proxy and does not prove responsibility, authorship, review, or business impact",
            "Commit percentages count author-file touches and are not percentages of current source authorship",
            "System activity share is unavailable for author-filtered runs because other contributors are outside the selected scope",
        ],
    }
