"""Validate and normalize provider-neutral issue, pull-request, and release data."""

from __future__ import annotations

import json
import statistics
from collections import Counter
from datetime import datetime
from pathlib import Path
from typing import Any


SCHEMA_PATH = Path(__file__).resolve().parent.parent / "schemas" / "forge-data-1.0.0.schema.json"


def _parse_time(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None


def _duration_days(start: str | None, end: str | None) -> float | None:
    before, after = _parse_time(start), _parse_time(end)
    if before is None or after is None:
        return None
    return round(max((after - before).total_seconds(), 0) / 86400, 2)


def _identity_values(identity: dict[str, Any]) -> set[str]:
    return {
        str(value).strip().casefold()
        for value in (identity.get("id"), identity.get("username"), identity.get("display_name"), *identity.get("aliases", []))
        if value
    }


def _identity_matches(identity: dict[str, Any], author_filter: str) -> bool:
    requested = author_filter.strip().casefold()
    return not requested or requested in _identity_values(identity)


def _roles(item: dict[str, Any], author_filter: str, kind: str, selected_ids: set[str]) -> list[str]:
    if not author_filter:
        return []
    roles = []
    def matches(identity: dict[str, Any]) -> bool:
        return identity.get("id") in selected_ids or _identity_matches(identity, author_filter)

    if matches(item.get("author", {})):
        roles.append("author")
    collections = {"issue": ("assignees",), "pull_request": ("participants", "reviewers"), "release": ()}[kind]
    for collection in collections:
        if any(matches(identity) for identity in item.get(collection, [])):
            roles.append(collection.rstrip("s"))
    return roles


def _summary(items: list[dict[str, Any]], kind: str) -> dict[str, Any]:
    states = Counter(str(item.get("state", "unknown")).casefold() for item in items)
    result: dict[str, Any] = {"total": len(items), "states": dict(sorted(states.items()))}
    if kind == "issues":
        durations = [value for item in items if (value := _duration_days(item.get("created_at"), item.get("closed_at"))) is not None]
        result.update({
            "open": states.get("open", 0), "closed": states.get("closed", 0),
            "average_close_days": round(statistics.mean(durations), 2) if durations else None,
            "median_close_days": round(statistics.median(durations), 2) if durations else None,
            "comments": sum(item.get("comments_count", 0) for item in items),
        })
    elif kind == "pull_requests":
        merged = [item for item in items if item.get("merged_at") or str(item.get("state", "")).casefold() == "merged"]
        completed = [item for item in items if str(item.get("state", "")).casefold() in {"closed", "merged"}]
        durations = [value for item in merged if (value := _duration_days(item.get("created_at"), item.get("merged_at"))) is not None]
        result.update({
            "open": states.get("open", 0), "closed": states.get("closed", 0), "merged": len(merged),
            "drafts": sum(bool(item.get("draft")) for item in items),
            "merge_rate_percent": round(len(merged) / len(completed) * 100, 2) if completed else None,
            "average_time_to_merge_days": round(statistics.mean(durations), 2) if durations else None,
            "median_time_to_merge_days": round(statistics.median(durations), 2) if durations else None,
            "commits": sum(item.get("commits_count") or 0 for item in items),
            "changed_files": sum(item.get("changed_files") or 0 for item in items),
            "additions": sum(item.get("additions") or 0 for item in items),
            "deletions": sum(item.get("deletions") or 0 for item in items),
            "review_comments": sum(item.get("review_comments_count") or 0 for item in items),
        })
    else:
        result = {
            "total": len(items), "published": sum(bool(item.get("published_at")) and not item.get("draft") for item in items),
            "drafts": sum(bool(item.get("draft")) for item in items), "prereleases": sum(bool(item.get("prerelease")) for item in items),
            "assets": sum(item.get("assets_count", 0) for item in items),
        }
    return result


def _top_labels(issues: list[dict[str, Any]], pull_requests: list[dict[str, Any]]) -> list[dict[str, Any]]:
    labels = Counter(label for item in issues + pull_requests for label in item.get("labels", []))
    return [{"label": label, "items": count} for label, count in labels.most_common(30)]


def _participants(items: list[dict[str, Any]]) -> dict[str, int]:
    identities = {}
    for item in items:
        for key in ("author",):
            identity = item.get(key, {})
            if identity.get("id"):
                identities[identity["id"]] = identity
        for key in ("assignees", "participants", "reviewers"):
            for identity in item.get(key, []):
                if identity.get("id"):
                    identities[identity["id"]] = identity
    return {"unique_people": len(identities), "reviewers": len({identity["id"] for item in items for identity in item.get("reviewers", [])})}


def _validate(data: dict[str, Any]) -> None:
    try:
        from jsonschema import Draft202012Validator, FormatChecker
    except ImportError as error:
        raise SystemExit("Forge-data validation requires: pip install -r requirements-reporting.txt") from error
    schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    errors = sorted(Draft202012Validator(schema, format_checker=FormatChecker()).iter_errors(data), key=lambda item: list(item.absolute_path))
    if errors:
        details = "\n".join(f"- /{'/'.join(map(str, item.absolute_path))}: {item.message}" for item in errors[:30])
        raise ValueError(f"Forge data violates {SCHEMA_PATH.name}:\n{details}")
    for collection in ("issues", "pull_requests", "releases"):
        identifiers = [item["id"] for item in data[collection]]
        if len(identifiers) != len(set(identifiers)):
            raise ValueError(f"Forge data contains duplicate IDs in {collection}")
    release_tags = [item["tag"] for item in data["releases"]]
    if len(release_tags) != len(set(release_tags)):
        raise ValueError("Forge data contains duplicate release tags")


def import_forge_data(path: Path | None, author_filter: str = "", privacy_mode: str = "standard", local_tags: list[str] | None = None) -> dict[str, Any]:
    if path is None:
        return {"status": "not_imported", "provider": None, "scope": {"author_filter": author_filter}, "summary": {"issues": 0, "pull_requests": 0, "releases": 0}, "issues": [], "pull_requests": [], "releases": [], "limitations": ["No provider-neutral forge data file was supplied"]}
    data = json.loads(path.read_text(encoding="utf-8"))
    _validate(data)
    identities = [
        identity
        for item in data["issues"] + data["pull_requests"] + data["releases"]
        for identity in [item.get("author", {}), *item.get("assignees", []), *item.get("participants", []), *item.get("reviewers", [])]
        if identity.get("id")
    ]
    selected_ids = {identity["id"] for identity in identities if _identity_matches(identity, author_filter)} if author_filter else set()
    selected: dict[str, list[dict[str, Any]]] = {}
    for key, kind in (("issues", "issue"), ("pull_requests", "pull_request"), ("releases", "release")):
        rows = []
        for original in data[key]:
            item = dict(original)
            if kind == "issue" and item.get("confidential"):
                item["title"] = "[confidential issue omitted]"
                item["url"] = None
                item["labels"] = []
                item["milestone"] = None
            roles = _roles(item, author_filter, kind, selected_ids)
            if author_filter and not roles:
                continue
            item["selected_author_roles"] = roles
            rows.append(item)
        selected[key] = rows
    local_tag_set = set(local_tags or [])
    remote_tags = {item["tag"] for item in selected["releases"]}
    result = {
        "status": "imported", "schema_version": data["schema_version"], "provider": data["provider"],
        "repository": data["repository"], "exported_at": data["exported_at"],
        "scope": {**data["scope"], "author_filter": author_filter, "source_file": path.name},
        "summary": {
            "issues": len(selected["issues"]), "pull_requests": len(selected["pull_requests"]), "releases": len(selected["releases"]),
            "source_issues": len(data["issues"]), "source_pull_requests": len(data["pull_requests"]), "source_releases": len(data["releases"]),
        },
        "issue_metrics": _summary(selected["issues"], "issues"),
        "pull_request_metrics": _summary(selected["pull_requests"], "pull_requests"),
        "release_metrics": _summary(selected["releases"], "releases"),
        "collaboration": _participants(selected["issues"] + selected["pull_requests"]),
        "top_labels": _top_labels(selected["issues"], selected["pull_requests"]),
        "release_correlation": {
            "local_tags": len(local_tag_set), "imported_release_tags": len(remote_tags),
            "matched_tags": sorted(local_tag_set & remote_tags), "local_only_tags": sorted(local_tag_set - remote_tags),
            "imported_only_tags": sorted(remote_tags - local_tag_set),
        },
        **selected,
        "method": "Provider-neutral normalized import validated against forge-data-1.0.0.schema.json",
        "limitations": [
            "Import completeness depends on the exporter and declared scope.complete value",
            "Counts describe the supplied export and are not live provider state",
            "Participation does not prove ownership, approval quality, or business impact",
        ],
    }
    if privacy_mode == "strict":
        result["repository"] = {"name": "[redacted]", "owner": None, "host": None, "external_id": None}
        result["scope"]["source_file"] = "[redacted]"
        result["issues"] = []
        result["pull_requests"] = []
        result["releases"] = []
        result["top_labels"] = []
        result["release_correlation"] = {key: value if isinstance(value, int) else [] for key, value in result["release_correlation"].items()}
        result["status"] = "redacted_by_privacy_mode"
    return result
