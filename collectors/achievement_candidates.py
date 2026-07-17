"""Generate confirmation-gated personal achievement candidates from author-scoped evidence."""

from __future__ import annotations

import re
from typing import Any


def _slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", value.casefold()).strip("-") or "candidate"


def _candidate(
    identifier: str,
    category: str,
    title: str,
    statement: str,
    facts: list[str],
    metrics: dict[str, Any],
    evidence: list[str],
    confidence: str,
    confirmations: list[str],
) -> dict[str, Any]:
    return {
        "id": identifier,
        "category": category,
        "title": title,
        "draft_statement": statement,
        "factual_basis": facts,
        "metrics": metrics,
        "evidence": evidence,
        "confidence": confidence,
        "confirmation_required": True,
        "required_confirmations": confirmations,
        "xyz_inputs": {
            "accomplished_x": "personal action and responsibility require confirmation",
            "measured_by_y": metrics,
            "by_doing_z": "technical approach requires personal confirmation",
        },
    }


def generate_achievement_candidates(
    author_filter: str,
    technical_impact: dict[str, Any],
    activity_ownership: dict[str, Any],
) -> dict[str, Any]:
    if not author_filter:
        return {
            "status": "requires_author_filter",
            "author": "",
            "summary": {"candidates": 0},
            "candidates": [],
            "instructions": ["Run RepoDNA with --author <canonical name> to generate personally scoped candidates."],
            "limitations": ["RepoDNA does not attribute repository-wide evidence to a person without an explicit author filter."],
        }

    contributions = technical_impact.get("contributions", [])
    summary = technical_impact.get("summary", {})
    selected_author = contributions[0].get("author", author_filter) if contributions else author_filter
    candidates: list[dict[str, Any]] = []
    if contributions:
        candidates.append(_candidate(
            "personal-scope-summary",
            "engineering_scope",
            "Author-scoped engineering contribution",
            f"Contributed {len(contributions)} first-parent commits with {summary.get('total_churn', 0)} lines of churn across the analyzed history scope.",
            [
                f"{len(contributions)} commits matched the configured author identity and aliases.",
                f"Changed-source line delta was {summary.get('net_changed_source_lines', 0)} within files touched by those commits.",
            ],
            {"commits": len(contributions), "churn": summary.get("total_churn", 0), "changed_source_line_delta": summary.get("net_changed_source_lines", 0)},
            ["#/git/technical_impact"],
            "high",
            ["Confirm that these Git identities belong to you.", "Describe your responsibility and the outcome of this work."],
        ))

    for relationship in activity_ownership.get("relationships", [])[:10]:
        system = relationship["system"]
        candidates.append(_candidate(
            f"system-{_slug(system)}",
            "system_contribution",
            f"Contribution to {system}",
            f"Contributed historical changes to {system} across {relationship['commits']} commit touches and {relationship['files_touched']} files.",
            [
                f"Author focus in this system was {relationship.get('author_focus_percent', 0):.2f}% within detected-system activity.",
                f"The relationship contains {relationship['churn']} lines of Git churn.",
            ],
            {"commit_touches": relationship["commits"], "files_touched": relationship["files_touched"], "churn": relationship["churn"], "author_focus_percent": relationship.get("author_focus_percent")},
            ["#/analysis/author_system_ownership"],
            relationship["confidence"],
            [f"Confirm your actual responsibility in {system}.", "Describe the technical problem, decisions, and resulting outcome."],
        ))

    signal_candidates = [
        ("test-evidence", "quality_engineering", "Test-related contributions", "contributions_changing_tests", "tests", "Explain whether tests were added, repaired, expanded, or only moved."),
        ("dependency-evidence", "dependency_engineering", "Dependency-related contributions", "contributions_changing_dependencies", "dependency manifests", "Explain why dependencies changed and what outcome followed."),
        ("complexity-reduction-evidence", "maintainability", "Estimated complexity reduction", "estimated_complexity_reductions", "estimated complexity reductions", "Confirm whether the change was an intentional simplification or refactor."),
    ]
    for identifier, category, title, key, label, question in signal_candidates:
        count = summary.get(key, 0)
        if not count:
            continue
        candidates.append(_candidate(
            identifier,
            category,
            title,
            f"Produced {count} author-scoped contributions with {label} detected in Git before/after evidence.",
            [f"The author-scoped technical-impact summary counted {count} contributions in this category."],
            {"matching_contributions": count},
            ["#/git/technical_impact/summary", "#/git/technical_impact/contributions"],
            "medium",
            [question, "Confirm the user or product outcome before presenting this as an achievement."],
        ))

    return {
        "status": "candidates_generated" if candidates else "insufficient_author_evidence",
        "author": selected_author,
        "summary": {
            "candidates": len(candidates),
            "high_confidence": sum(item["confidence"] == "high" for item in candidates),
            "medium_confidence": sum(item["confidence"] == "medium" for item in candidates),
            "low_confidence": sum(item["confidence"] == "low" for item in candidates),
        },
        "candidates": candidates,
        "method": "Author-filtered Git impact and author-to-system activity evidence",
        "instructions": ["Review factual evidence, supply personal context, and approve a claim before publishing it."],
        "limitations": [
            "Candidates are not confirmed achievements",
            "Repository evidence cannot establish personal responsibility, intent, product outcome, or business impact",
            "Churn and commit counts measure activity, not value or performance",
        ],
    }
