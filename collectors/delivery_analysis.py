"""Analyze local release history and CI configuration without remote APIs."""

from __future__ import annotations

import re
import statistics
import subprocess
from collections import Counter
from datetime import datetime
from pathlib import Path
from typing import Any


SEMVER = re.compile(r"^v?(\d+)\.(\d+)\.(\d+)(?:[-+][0-9A-Za-z.-]+)?$")
RESERVED_GITLAB_KEYS = {"stages", "variables", "include", "workflow", "default", "image", "services", "cache", "before_script", "after_script"}


def _git(root: Path, *args: str) -> str:
    try:
        return subprocess.run(
            ["git", "-C", str(root), *args], check=False, capture_output=True,
            text=True, encoding="utf-8", errors="replace",
        ).stdout.strip()
    except OSError:
        return ""


def _release_churn(root: Path, revision_range: str) -> tuple[int, int, int]:
    added = removed = 0
    files = set()
    output = _git(root, "log", "--format=", "--numstat", "--find-renames", "--find-copies", revision_range)
    for line in output.splitlines():
        parts = line.split("\t", 2)
        if len(parts) == 3:
            files.add(parts[2])
            if parts[0].isdigit():
                added += int(parts[0])
            if parts[1].isdigit():
                removed += int(parts[1])
    return added, removed, len(files)


def analyze_releases(root: Path) -> dict[str, Any]:
    if not (root / ".git").exists() and not _git(root, "rev-parse", "--git-dir"):
        return {"status": "not_available", "summary": {"release_count": 0}, "releases": [], "unreleased": {"commits": 0}, "limitations": ["Git metadata is unavailable"]}
    rows = _git(
        root, "for-each-ref", "--sort=creatordate",
        "--format=%(refname:short)%09%(objecttype)%09%(creatordate:iso-strict)%09%(objectname)%09%(*objectname)%09%(subject)",
        "refs/tags",
    ).splitlines()
    releases, previous_ref, previous_date = [], None, None
    intervals = []
    for row in rows:
        fields = row.split("\t", 5)
        if len(fields) < 5:
            continue
        tag, object_type, date, object_hash, dereferenced = fields[:5]
        subject = fields[5] if len(fields) > 5 else ""
        target = dereferenced or object_hash
        revision_range = f"{previous_ref}..{target}" if previous_ref else target
        commits = int(_git(root, "rev-list", "--count", revision_range) or 0)
        added, removed, files = _release_churn(root, revision_range)
        author_data = _git(root, "show", "-s", "--format=%aN%x09%aI%x09%s", target).split("\t", 2)
        try:
            parsed_date = datetime.fromisoformat(date)
            if previous_date is not None:
                intervals.append(max((parsed_date - previous_date).days, 0))
            previous_date = parsed_date
        except ValueError:
            pass
        releases.append({
            "tag": tag, "semantic_version": bool(SEMVER.match(tag)),
            "prerelease": "-" in tag.lstrip("v"), "tag_type": "annotated" if object_type == "tag" else "lightweight",
            "date": date, "commit": target, "subject": subject or (author_data[2] if len(author_data) > 2 else ""),
            "author": author_data[0] if author_data and author_data[0] else "Unknown", "commits_since_previous": commits,
            "files_changed": files, "lines_added": added, "lines_removed": removed, "churn": added + removed,
        })
        previous_ref = target

    latest = releases[-1] if releases else None
    unreleased_range = f"{latest['commit']}..HEAD" if latest else "HEAD"
    unreleased_commits = int(_git(root, "rev-list", "--count", unreleased_range) or 0)
    added, removed, files = _release_churn(root, unreleased_range)
    changelog = next((path for path in ("CHANGELOG.md", "CHANGES.md", "HISTORY.md") if (root / path).is_file()), None)
    changelog_versions = []
    if changelog:
        text = (root / changelog).read_text(encoding="utf-8", errors="replace")
        changelog_versions = re.findall(r"^##\s+\[?v?(\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?)\]?", text, re.M)
    release_versions = {match.group(0).lstrip("v") for item in releases if (match := SEMVER.match(item["tag"]))}
    documented = sum(version in release_versions for version in changelog_versions)
    return {
        "status": "assessed", "summary": {
            "release_count": len(releases), "semantic_release_count": sum(item["semantic_version"] for item in releases),
            "annotated_tag_count": sum(item["tag_type"] == "annotated" for item in releases),
            "prerelease_count": sum(item["prerelease"] for item in releases),
            "latest_release": latest["tag"] if latest else None, "latest_release_date": latest["date"] if latest else None,
            "average_days_between_releases": round(statistics.mean(intervals), 1) if intervals else None,
            "median_days_between_releases": round(statistics.median(intervals), 1) if intervals else None,
            "changelog_present": bool(changelog), "documented_release_count": documented,
        },
        "releases": list(reversed(releases)),
        "unreleased": {"base_tag": latest["tag"] if latest else None, "commits": unreleased_commits, "files_changed": files, "lines_added": added, "lines_removed": removed, "churn": added + removed},
        "changelog": {"path": changelog, "versions": changelog_versions[:100]},
        "method": "Local Git tags, tag targets, commit ranges, rename-aware diffs, and versioned changelog headings",
        "limitations": ["Local tags may be incomplete when the clone is shallow", "Tags do not prove that a remote release artifact was published", "Issue, pull-request, review, and deployment outcomes require optional remote integration"],
    }


def _provider(path: str) -> str:
    lowered = path.casefold()
    if lowered.startswith(".github/workflows/"):
        return "GitHub Actions"
    if ".gitlab-ci" in lowered:
        return "GitLab CI"
    if lowered.endswith("jenkinsfile"):
        return "Jenkins"
    if "azure-pipelines" in lowered:
        return "Azure Pipelines"
    if "bitbucket-pipelines" in lowered:
        return "Bitbucket Pipelines"
    if ".circleci" in lowered or lowered.endswith("circle.yml"):
        return "CircleCI"
    return "Unknown"


def _yaml_section_items(lines: list[str], section: str) -> list[str]:
    values, active, base_indent = [], False, 0
    for line in lines:
        match = re.match(rf"^(\s*){re.escape(section)}:\s*(.*)$", line)
        if match:
            active, base_indent = True, len(match.group(1))
            inline = match.group(2).strip().strip("[]")
            if inline:
                values.extend(item.strip(" '\"") for item in inline.split(",") if item.strip())
            continue
        if active:
            indent = len(line) - len(line.lstrip())
            if line.strip() and indent <= base_indent:
                break
            item = re.match(r"^\s+(?:-\s*)?([\w.-]+):?", line)
            if item and indent == base_indent + 2:
                values.append(item.group(1))
    return sorted(set(values))


def _analyze_workflow(root: Path, relative: str) -> dict[str, Any]:
    path = root / relative
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    provider = _provider(relative)
    name_match = re.search(r"^name:\s*['\"]?(.+?)['\"]?\s*$", text, re.M)
    triggers = _yaml_section_items(lines, "on") if provider == "GitHub Actions" else _yaml_section_items(lines, "workflow")
    jobs = []
    if provider == "GitHub Actions":
        in_jobs = False
        for line in lines:
            if re.match(r"^jobs:\s*$", line):
                in_jobs = True
                continue
            if in_jobs and line and not line.startswith((" ", "\t", "#")):
                break
            match = re.match(r"^  ([\w.-]+):\s*$", line) if in_jobs else None
            if match:
                jobs.append(match.group(1))
    elif provider == "GitLab CI":
        jobs = [match.group(1) for line in lines if (match := re.match(r"^([\w.-]+):\s*$", line)) and match.group(1) not in RESERVED_GITLAB_KEYS and not match.group(1).startswith(".")]
        triggers = _yaml_section_items(lines, "stages")
    else:
        jobs = re.findall(r"^\s*-?\s*(?:job|stage)\s*[:(]\s*['\"]?([\w .-]+)", text, re.I | re.M)
        triggers = _yaml_section_items(lines, "pipelines") or _yaml_section_items(lines, "trigger")
    steps = len(re.findall(r"^\s*-\s+(?:name:|uses:|run:|script:)", text, re.M))
    lowered_jobs = [item.casefold() for item in jobs]
    floating_actions = re.findall(r"uses:\s*([^\s]+@(?![0-9a-f]{40}(?:\s|$))[^\s]+)", text, re.I)
    return {
        "path": relative, "provider": provider, "name": name_match.group(1) if name_match else path.name,
        "triggers": triggers, "jobs": jobs, "job_count": len(jobs), "step_count": steps,
        "test_job_count": sum(any(token in job for token in ("test", "check", "lint", "quality")) for job in lowered_jobs),
        "deployment_job_count": sum(any(token in job for token in ("deploy", "publish", "release")) for job in lowered_jobs),
        "signals": {
            "matrix": "matrix:" in text, "cache": "cache" in text.casefold(), "artifacts": "artifact" in text.casefold(),
            "manual_trigger": "workflow_dispatch" in text or "manual" in text, "scheduled": "schedule" in text,
            "pull_request_target": "pull_request_target" in text, "write_permissions": bool(re.search(r"(?:contents|packages|id-token|pull-requests):\s*write", text)),
            "floating_action_references": sorted(set(floating_actions)), "secret_reference_count": len(re.findall(r"(?:secrets\.|\$[A-Z_]*(?:TOKEN|SECRET|PASSWORD))", text)),
        },
    }


def analyze_ci(root: Path, ci_files: list[str]) -> dict[str, Any]:
    workflows, errors = [], []
    for relative in ci_files:
        try:
            workflows.append(_analyze_workflow(root, relative))
        except OSError as error:
            errors.append({"path": relative, "error": str(error)})
    providers = Counter(item["provider"] for item in workflows)
    return {
        "status": "assessed" if workflows else "not_found",
        "summary": {
            "workflow_count": len(workflows), "provider_count": len(providers), "providers": dict(sorted(providers.items())),
            "job_count": sum(item["job_count"] for item in workflows), "step_count": sum(item["step_count"] for item in workflows),
            "test_job_count": sum(item["test_job_count"] for item in workflows), "deployment_job_count": sum(item["deployment_job_count"] for item in workflows),
            "scheduled_workflow_count": sum(item["signals"]["scheduled"] for item in workflows),
            "manual_workflow_count": sum(item["signals"]["manual_trigger"] for item in workflows),
            "floating_action_reference_count": sum(len(item["signals"]["floating_action_references"]) for item in workflows),
        },
        "workflows": workflows, "parse_errors": errors,
        "method": "Static analysis of versioned CI configuration, triggers, jobs, steps, permissions, actions, cache, artifacts, and deployment naming",
        "limitations": ["Configuration presence does not prove successful execution", "Local analysis cannot observe run duration, failures, approvals, environments, protected branches, or remote secrets", "Job purposes are partly inferred from names and require confirmation"],
    }


def analyze_delivery(root: Path, ci_files: list[str]) -> dict[str, Any]:
    return {"releases": analyze_releases(root), "ci": analyze_ci(root, ci_files)}
