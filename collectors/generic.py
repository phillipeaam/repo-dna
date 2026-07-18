#!/usr/bin/env python3

"""Stack-neutral repository collector producing structured JSON only."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import tomllib
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from insights import analyze_repository
from technical_impact import collect_technical_impact


LANGUAGES = {
    ".cs": "C#", ".py": "Python", ".js": "JavaScript", ".jsx": "JavaScript",
    ".ts": "TypeScript", ".tsx": "TypeScript", ".java": "Java", ".kt": "Kotlin",
    ".kts": "Kotlin", ".go": "Go", ".rs": "Rust", ".rb": "Ruby", ".php": "PHP",
    ".c": "C", ".h": "C/C++ Header", ".cc": "C++", ".cpp": "C++", ".cxx": "C++",
    ".swift": "Swift", ".dart": "Dart", ".sh": "Shell", ".bash": "Shell",
    ".ps1": "PowerShell", ".sql": "SQL", ".html": "HTML", ".css": "CSS",
    ".scss": "SCSS", ".vue": "Vue", ".svelte": "Svelte", ".lua": "Lua",
    ".r": "R", ".scala": "Scala", ".fs": "F#", ".fsx": "F#",
}

HARD_EXCLUDES = {
    ".git", ".repodna", "node_modules", "vendor", "packages", "library", "logs", "temp",
    "obj", "bin", "build", "builds", "dist", ".venv", "venv", "__pycache__",
    ".next", ".nuxt", "coverage",
}
HARD_EXCLUDED_PATHS = {"tests/fixtures"}

CONFIG_NAMES = {
    "package.json", "pyproject.toml", "requirements.txt", "setup.py", "setup.cfg",
    "pipfile", "cargo.toml", "go.mod", "composer.json", "pubspec.yaml", "pom.xml",
    "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts",
    "dockerfile", "docker-compose.yml", "docker-compose.yaml", "makefile", "cmakelists.txt",
    ".editorconfig", ".npmrc", ".yarnrc", "nuget.config", "global.json",
}


def git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(root), *args], capture_output=True, text=True,
        encoding="utf-8", errors="replace"
    )
    return result.stdout if result.returncode == 0 else ""


def load_author_aliases(root: Path) -> tuple[dict[str, str], dict[str, str]]:
    """Parse the intentionally small YAML-like .repodna-authors format."""
    name_aliases: dict[str, str] = {}
    email_aliases: dict[str, str] = {}
    path = root / ".repodna-authors"
    if not path.is_file():
        return name_aliases, email_aliases
    canonical = ""
    section = ""
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if raw and not raw[0].isspace() and raw.rstrip().endswith(":"):
            canonical = raw.rstrip()[:-1].strip()
            name_aliases[canonical.casefold()] = canonical
            section = ""
        elif canonical and raw.strip() in {"names:", "emails:"}:
            section = raw.strip()[:-1]
        elif canonical and raw.strip().startswith("-"):
            value = raw.strip()[1:].strip().strip('"\'')
            if section == "names":
                name_aliases[value.casefold()] = canonical
            elif section == "emails":
                email_aliases[value.casefold()] = canonical
    return name_aliases, email_aliases


def canonical_author(name: str, email: str, names: dict[str, str], emails: dict[str, str]) -> str:
    return emails.get(email.casefold(), names.get(name.casefold(), name or email or "Unknown"))


def system_for_path(path: str) -> str:
    lowered = path.casefold()
    tokens = set(re.findall(r"[a-z0-9]+", lowered))
    groups = {
        "Combat": ("combat", "attack", "weapon", "damage", "ability", "buff", "debuff"),
        "UI": ("ui", "menu", "hud", "view", "screen", "widget"),
        "Networking": ("network", "multiplayer", "photon", "socket", "lobby", "api"),
        "Data/Persistence": ("data", "save", "persist", "database", "storage", "repository"),
        "Tests": ("test", "spec"),
    }
    return next((group for group, terms in groups.items() if any(term in tokens for term in terms)), "Other")


def is_text(path: Path) -> bool:
    try:
        return b"\0" not in path.read_bytes()[:8192]
    except OSError:
        return False


def line_count(path: Path) -> int:
    if not is_text(path):
        return 0
    try:
        with path.open("r", encoding="utf-8", errors="replace") as source:
            return sum(1 for _ in source)
    except OSError:
        return 0


def dependency_names(path: Path) -> list[str]:
    name = path.name.lower()
    try:
        if name in {"package.json", "composer.json", "manifest.json"}:
            data = json.loads(path.read_text(encoding="utf-8"))
            names: set[str] = set()
            for key in ("dependencies", "devDependencies", "peerDependencies", "require", "require-dev"):
                value = data.get(key, {})
                if isinstance(value, dict):
                    names.update(value)
            return sorted(names)[:200]
        if name == "requirements.txt":
            rows = []
            for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
                line = line.strip()
                if line and not line.startswith(("#", "-")):
                    rows.append(re.split(r"[<>=!~\[]", line, maxsplit=1)[0])
            return sorted(set(rows))[:200]
        if name in {"pyproject.toml", "cargo.toml"}:
            data = tomllib.loads(path.read_text(encoding="utf-8"))
            names: set[str] = set()
            if name == "pyproject.toml":
                for value in data.get("project", {}).get("dependencies", []):
                    names.add(re.split(r"[<>=!~\[ ;]", value, maxsplit=1)[0])
                names.update(data.get("tool", {}).get("poetry", {}).get("dependencies", {}))
            else:
                names.update(data.get("dependencies", {}))
                names.update(data.get("dev-dependencies", {}))
            names.discard("python")
            return sorted(names)[:200]
        if path.suffix.lower() == ".csproj":
            return sorted(set(re.findall(r'<PackageReference[^>]+Include="([^"]+)"', path.read_text(encoding="utf-8", errors="replace"))))[:200]
        if name == "go.mod":
            return sorted(set(re.findall(r"^\s*([\w./-]+)\s+v\d", path.read_text(encoding="utf-8", errors="replace"), re.M)))[:200]
        if name == "pom.xml":
            return sorted(set(re.findall(r"<artifactId>([^<]+)</artifactId>", path.read_text(encoding="utf-8", errors="replace"))))[:200]
        if name == "pubspec.yaml":
            return sorted(set(re.findall(r"^\s{2}([a-zA-Z0-9_-]+):", path.read_text(encoding="utf-8", errors="replace"), re.M)))[:200]
        if name in {"build.gradle", "build.gradle.kts"}:
            return sorted(set(re.findall(r"(?:implementation|api|compileOnly|runtimeOnly|testImplementation)\s*\(?[\"\047]([^:\"\047]+:[^:\"\047]+)", path.read_text(encoding="utf-8", errors="replace"))))[:200]
    except (OSError, ValueError, TypeError):
        return []
    return []


def author_scope_args(author_filter: str, name_aliases: dict[str, str], email_aliases: dict[str, str]) -> list[str]:
    if not author_filter:
        return []
    requested = author_filter.casefold()
    identities = {author_filter}
    for alias, canonical in {**name_aliases, **email_aliases}.items():
        if requested in {alias, canonical.casefold()}:
            identities.add(alias)
    pattern = "|".join(re.escape(identity) for identity in sorted(identities, key=str.casefold))
    return ["--extended-regexp", f"--author=({pattern})"]


def collect_git(root: Path, privacy_mode: str, author_filter: str = "") -> dict[str, Any]:
    name_aliases, email_aliases = load_author_aliases(root)
    scope = author_scope_args(author_filter, name_aliases, email_aliases)
    technical_impact = collect_technical_impact(
        root,
        scope,
        lambda name, email: canonical_author(name, email, name_aliases, email_aliases),
    )
    identity_rows = [row.split("\t", 1) for row in git(root, "log", "--all", *scope, "--format=%aN%x09%aE").splitlines() if "\t" in row]
    contributor_commits: Counter[str] = Counter(
        canonical_author(name, email, name_aliases, email_aliases) for name, email in identity_rows
    )
    branches = [line.strip() for line in git(root, "branch", "-a", "--format=%(refname:short)").splitlines() if line.strip()]
    tags = [line.strip() for line in git(root, "tag", "--sort=-creatordate").splitlines() if line.strip()]
    months = Counter(git(root, "log", "--all", *scope, "--date=format:%Y-%m", "--pretty=format:%ad").splitlines())
    years = Counter(value[:4] for value in months.elements() if value)

    change_commits: Counter[str] = Counter()
    churn: Counter[str] = Counter()
    added_total = 0
    removed_total = 0
    current_commit_files: set[str] = set()
    current_commit_systems: set[str] = set()
    file_authors: dict[str, set[str]] = defaultdict(set)
    file_author_commits: dict[str, Counter[str]] = defaultdict(Counter)
    file_author_churn: dict[str, Counter[str]] = defaultdict(Counter)
    last_changed: dict[str, str] = {}
    coauthors: Counter[tuple[str, str]] = Counter()
    system_months: dict[str, Counter[str]] = defaultdict(Counter)
    current_author = "Unknown"
    current_date = ""
    log_rows = git(root, "log", "--all", *scope, "--find-renames", "--find-copies", "--numstat", "--date=iso-strict", "--pretty=tformat:__REPODNA_COMMIT__%x09%aN%x09%aE%x09%ad%x09%B%x00")
    for line in log_rows.replace("\x00", "\n").splitlines():
        if line.startswith("__REPODNA_COMMIT__\t"):
            change_commits.update(current_commit_files)
            if current_date:
                for system in current_commit_systems:
                    system_months[system][current_date[:7]] += 1
            current_commit_files.clear()
            current_commit_systems.clear()
            fields = line.split("\t", 4)
            if len(fields) >= 4:
                current_author = canonical_author(fields[1], fields[2], name_aliases, email_aliases)
                current_date = fields[3]
            continue
        parts = line.split("\t", 2)
        if len(parts) == 3 and parts[0].isdigit() and parts[1].isdigit():
            added, removed, file_path = int(parts[0]), int(parts[1]), parts[2]
            current_commit_files.add(file_path)
            file_authors[file_path].add(current_author)
            file_author_commits[file_path][current_author] += 1
            file_author_churn[file_path][current_author] += added + removed
            last_changed.setdefault(file_path, current_date)
            current_commit_systems.add(system_for_path(file_path))
            churn[file_path] += added + removed
            added_total += added
            removed_total += removed
    change_commits.update(current_commit_files)
    if current_date:
        for system in current_commit_systems:
            system_months[system][current_date[:7]] += 1

    now = datetime.now(timezone.utc)
    hotspots = []
    for path, commits in change_commits.items():
        file_path = root / path
        size_lines = line_count(file_path) if file_path.is_file() else 0
        try:
            changed_at = datetime.fromisoformat(last_changed[path])
            days_since = max((now - changed_at).days, 0)
        except (KeyError, ValueError):
            days_since = 0
        author_count = len(file_authors[path])
        score = round(commits * 2 + churn[path] / 50 + size_lines / 100 + author_count * 3 + 30 / (days_since + 30), 2)
        hotspots.append({"path": path, "commits": commits, "churn": churn[path], "current_lines": size_lines, "authors": author_count, "days_since_last_change": days_since, "score": score})
    hotspots.sort(key=lambda item: (item["score"], item["churn"]), reverse=True)

    for record in git(root, "log", "--all", *scope, "--format=%aN%x09%aE%x1f%B%x1e").split("\x1e"):
        if "\x1f" not in record:
            continue
        identity, body = record.split("\x1f", 1)
        if "\t" not in identity:
            continue
        name, email = identity.strip().split("\t", 1)
        author = canonical_author(name, email, name_aliases, email_aliases)
        for match in re.finditer(r"Co-authored-by:\s*([^<\n]+)\s*<([^>]+)>", body, re.I):
            other = canonical_author(match.group(1).strip(), match.group(2).strip(), name_aliases, email_aliases)
            coauthors[tuple(sorted((author, other)))] += 1

    return {
        "author_filter": author_filter,
        "scope": "author" if author_filter else "repository",
        "contributors_count": len(contributor_commits),
        "contributors": [
            {"name": (f"Contributor-{index + 1}" if privacy_mode == "strict" else name), "commits": commits}
            for index, (name, commits) in enumerate(contributor_commits.most_common())
        ],
        "author_aliases_configured": len(name_aliases) + len(email_aliases),
        "coauthorship": [
            {"authors": ([f"Contributor" for _ in pair] if privacy_mode == "strict" else list(pair)), "commits": count}
            for pair, count in coauthors.most_common(50)
        ],
        "shared_files": [
            {"path": path, "authors": len(authors)} for path, authors in sorted(file_authors.items(), key=lambda item: len(item[1]), reverse=True) if len(authors) > 1
        ][:50],
        "system_evolution": {
            system: dict(sorted(periods.items())) for system, periods in sorted(system_months.items())
        },
        "branches_count": len(branches),
        "branches": branches[:100],
        "tags_count": len(tags),
        "tags": tags[:100],
        "releases": tags[:30],
        "history_by_month": dict(sorted(months.items())),
        "history_by_year": dict(sorted(years.items())),
        "churn": {"lines_added": added_total, "lines_removed": removed_total, "total": added_total + removed_total},
        "most_changed_files": [
            {"path": path, "commits": count} for path, count in change_commits.most_common(50)
        ],
        "hotspots": hotspots[:50],
        "technical_impact": technical_impact,
        "_file_author_activity": {
            path: {
                author: {"commits": commits, "churn": file_author_churn[path][author]}
                for author, commits in authors.items()
            }
            for path, authors in file_author_commits.items()
        },
    }


def sanitize_strict_result(result: dict[str, Any]) -> None:
    """Remove repository-specific names while preserving aggregate evidence."""

    def anonymize_paths(items: list[dict[str, Any]], prefix: str = "File") -> None:
        for index, item in enumerate(items, 1):
            if "path" in item:
                item["path"] = f"{prefix}-{index}"

    result["configuration_files"] = []
    result["documentation_files"] = []
    result["test_files"] = []
    result["ci_cd_files"] = []
    result["docker_files"] = []
    anonymize_paths(result["largest_files"])
    anonymize_paths(result["top_directories"], "Directory")
    anonymize_paths(result["possible_modules"], "Module")
    for index, manifest in enumerate(result["dependencies"]["manifests"], 1):
        manifest["path"] = f"Manifest-{index}"
        manifest["dependencies"] = []

    git_data = result["git"]
    git_data["branches"] = []
    git_data["tags"] = []
    git_data["releases"] = []
    for index, contribution in enumerate(git_data.get("technical_impact", {}).get("contributions", []), 1):
        contribution["commit"] = f"Contribution-{index}"
        contribution["author"] = "Selected contributor" if git_data.get("author_filter") else "Contributor"
        contribution["subject"] = "[REDACTED]"
        contribution["systems"] = [f"Module-{system_index}" for system_index, _ in enumerate(contribution.get("systems", []), 1)]
    anonymize_paths(git_data["shared_files"])
    anonymize_paths(git_data["most_changed_files"])
    anonymize_paths(git_data["hotspots"])

    analysis = result["analysis"]
    system_name_map = {system["name"]: f"Module-{index}" for index, system in enumerate(analysis["systems"], 1)}
    ownership = analysis.get("author_system_ownership", {})
    achievement_candidates = analysis.get("personal_achievement_candidates", {})
    if achievement_candidates.get("candidates"):
        achievement_candidates["candidates"] = []
        achievement_candidates["status"] = "redacted_by_privacy_mode"
        achievement_candidates["author"] = "Selected contributor"
    author_name_map = {
        name: f"Contributor-{index}"
        for index, name in enumerate(sorted({item["author"] for item in ownership.get("relationships", [])}), 1)
    }
    for item in ownership.get("relationships", []):
        item["author"] = author_name_map[item["author"]]
        item["system"] = system_name_map.get(item["system"], "Module")
    if ownership.get("author_filter"):
        ownership["author_filter"] = "Selected contributor"
    bus_factor = analysis.get("bus_factor_by_system", {})
    for item in bus_factor.get("systems", []):
        item["system"] = system_name_map.get(item["system"], "Module")
        for author in item.get("critical_authors", []):
            author["author"] = author_name_map.get(author["author"], "Contributor")
    onboarding = analysis.get("onboarding", {})
    onboarding["commands"] = []
    onboarding["status"] = "redacted_by_privacy_mode"
    unity = analysis.get("unity", {})
    unity_config = unity.get("configuration", {})
    unity_config.get("build", {})["enabled_scenes"] = []
    unity_config.get("player", {})["define_symbols"] = []
    unity_config.get("addressables", {})["groups"] = []
    unity_config.get("assemblies", {})["test_assemblies"] = []
    unity_config["native_plugins"] = []
    unity_config["platform_specific_code"] = []
    for system in unity.get("gameplay_systems", []):
        system["files"] = []
        system["primary_directories"] = []
        system.get("git", {})["frequently_changed_files"] = []
    for signal in unity.get("signals", []):
        signal["path"] = "[redacted]"
        signal["lines"] = []
    android = analysis.get("android", {})
    if android.get("status") == "assessed":
        android["status"] = "redacted_by_privacy_mode"
        for key in ("manifests", "components", "permissions", "screens"):
            android[key] = []
        android.get("gradle", {})["files"] = []
        android.get("gradle", {})["dependencies"] = []
        android.get("data_layer", {})["files"] = []
        android.get("networking", {})["files"] = []
        android.get("resources", {})["layouts"] = []
        android.get("resources", {})["navigation"] = []
        android.get("resources", {})["by_type"] = {}
        android.get("tests", {})["unit"] = []
        android.get("tests", {})["instrumented"] = []
    flutter = analysis.get("flutter", {})
    if flutter.get("status") == "assessed":
        flutter["status"] = "redacted_by_privacy_mode"
        for key in ("widgets", "screens", "routes", "assets", "platform_channels"):
            flutter[key] = []
        flutter["pubspec"] = "[redacted]"
        flutter["dependencies"] = {"runtime": {}, "development": {}}
        flutter.get("localization", {})["arb_files"] = []
        flutter.get("localization", {})["l10n_config"] = None
        for manager in flutter.get("state_management", []): manager["evidence_files"] = []
        flutter["native_bridges"] = {"files": [], "matched_channels": flutter.get("native_bridges", {}).get("matched_channels", 0)}
        flutter["tests"] = {"unit": [], "integration": []}
        flutter["flavors"] = {"android": [], "ios_schemes": [], "dart_entrypoints": []}
    for index, symbol in enumerate(analysis["code"]["symbols"], 1):
        sanitized_symbol = {
            "name": f"Symbol-{index}",
            "path": f"File-{index}",
            "language": symbol.get("language", "Unknown"),
            "kind": symbol.get("kind", "symbol"),
            "parser": symbol.get("parser", "unknown"),
        }
        symbol.clear()
        symbol.update(sanitized_symbol)
    for index, item in enumerate(analysis["code"]["imports"], 1):
        item["path"] = f"File-{index}"
        item["imports"] = []
    anonymize_paths(analysis["code"]["complexity"]["high_complexity_files"])
    for index, item in enumerate(analysis["code"]["complexity"].get("high_complexity_functions", []), 1):
        item["path"] = f"File-{index}"
        item["name"] = f"Function-{index}"
    for index, call in enumerate(analysis["code"].get("calls", []), 1):
        call["path"] = f"File-{index}"
        call["target"] = f"Call-{index}"
        call["scope"] = ""
    for index, system in enumerate(analysis["systems"], 1):
        system["name"] = f"Module-{index}"
        system["path"] = f"Module-{index}"
        system["dependency_manifests"] = []
    for framework in analysis.get("frameworks", {}).get("detected", []):
        framework["evidence"] = []
        framework["files"] = []
    graphs = analysis.get("graphs", {})
    graphs["file_graph"] = {"nodes": [], "edges": [], "unresolved": []}
    graphs["module_graph"] = {"nodes": [], "edges": [], "cycles": []}
    graphs["dependency_graph"] = {"nodes": [], "edges": []}
    architecture = analysis.get("architecture", {})
    architecture["entrypoints"] = []
    if "coupling" in architecture:
        architecture["coupling"]["modules"] = []
        architecture["coupling"]["high_coupling"] = []
    if "boundaries" in architecture:
        architecture["boundaries"]["modules"] = []
        architecture["boundaries"]["violations"] = []
        architecture["boundaries"]["cycles"] = []
    analysis["quality"]["coverage"]["evidence_files"] = []
    analysis["quality"]["coverage"]["reports"] = []
    analysis["quality"]["coverage"]["parse_errors"] = []
    analysis["quality"]["tests"]["reports"] = []
    analysis["quality"]["tests"]["parse_errors"] = []
    analysis["quality"]["linters"]["reports"] = []
    analysis["quality"]["linters"]["parse_errors"] = []
    analysis["quality"]["vulnerabilities"]["scanner_reports"] = []
    analysis["quality"]["vulnerabilities"]["reports"] = []
    analysis["quality"]["vulnerabilities"]["parse_errors"] = []
    analysis["quality"]["vulnerabilities"]["dependency_findings"] = []
    dependency_licenses = analysis["quality"].get("dependency_licenses", {})
    dependency_licenses["packages"] = []
    dependency_licenses["reports"] = []
    dependency_licenses["parse_errors"] = []
    dependency_resolution = analysis["quality"].get("dependency_resolution", {})
    dependency_resolution["dependencies"] = []
    dependency_inventory = analysis.get("dependency_inventory", {})
    dependency_inventory["components"] = []
    dependency_inventory["parse_errors"] = []
    dependency_inventory["lockfiles"] = [
        {"path": f"Lockfile-{index}", "ecosystem": item.get("ecosystem", "Unknown"), "component_count": item.get("component_count", 0), "status": item.get("status", "unknown")}
        for index, item in enumerate(dependency_inventory.get("lockfiles", []), 1)
    ]
    if "sbom" in dependency_inventory:
        dependency_inventory["sbom"]["components"] = []
        dependency_inventory["sbom"]["dependencies"] = []
    dependency_inventory["status"] = "redacted_by_privacy_mode"
    delivery = analysis.get("delivery", {})
    releases = delivery.get("releases", {})
    releases["releases"] = []
    releases["changelog"] = {"path": None, "versions": []}
    releases.get("summary", {})["latest_release"] = None
    releases.get("summary", {})["latest_release_date"] = None
    releases.get("unreleased", {})["base_tag"] = None
    releases["status"] = "redacted_by_privacy_mode"
    ci_analysis = delivery.get("ci", {})
    ci_analysis["workflows"] = []
    ci_analysis["parse_errors"] = []
    ci_analysis["status"] = "redacted_by_privacy_mode"
    analysis["quality"]["licenses"]["license_files"] = []


def collect(root: Path, report_name: str, privacy_mode: str, author_filter: str = "") -> dict[str, Any]:
    files: list[dict[str, Any]] = []
    language_files: Counter[str] = Counter()
    language_lines: Counter[str] = Counter()
    extensions: Counter[str] = Counter()
    directories: Counter[str] = Counter()
    configs: list[str] = []
    docs: list[str] = []
    tests: list[str] = []
    ci_cd: list[str] = []
    docker: list[str] = []
    manifests: list[dict[str, Any]] = []
    module_stats: dict[str, Counter[str]] = defaultdict(Counter)

    for current, dir_names, file_names in os.walk(root):
        current_path = Path(current)
        current_relative = current_path.relative_to(root).as_posix()
        dir_names[:] = [
            directory for directory in dir_names
            if directory.lower() not in HARD_EXCLUDES and directory != report_name
            and not re.match(r".*_project_analysis_\d{4}-\d{2}-\d{2}_", directory)
            and f"{current_relative}/{directory}".lstrip("./") not in HARD_EXCLUDED_PATHS
        ]
        for file_name in file_names:
            path = current_path / file_name
            relative = path.relative_to(root).as_posix()
            if relative.endswith((".zip", ".tar.gz")):
                continue
            try:
                size = path.stat().st_size
            except OSError:
                continue
            extension = path.suffix.lower()
            extensions[extension or "[no extension]"] += 1
            language = LANGUAGES.get(extension)
            lines = line_count(path) if language else 0
            files.append({"path": relative, "bytes": size, "lines": lines, "language": language})
            top_directory = relative.split("/", 1)[0] if "/" in relative else "[root]"
            directories[top_directory] += 1
            if language:
                language_files[language] += 1
                language_lines[language] += lines
                module_stats[top_directory][language] += 1

            lower_path = relative.lower()
            lower_name = file_name.lower()
            if lower_name in CONFIG_NAMES or extension in {".csproj", ".sln", ".props", ".targets"}:
                configs.append(relative)
            if lower_name.startswith(("readme", "changelog", "contributing", "architecture")) or extension in {".md", ".rst", ".adoc"}:
                docs.append(relative)
            if re.search(r"(^|/)(test|tests|spec|specs|__tests__)(/|$)", lower_path) or re.search(r"(test|tests|spec)\.[^.]+$", lower_name):
                tests.append(relative)
            if lower_path.startswith((".github/workflows/", ".gitlab-ci", ".gitlab/", ".circleci/")) or lower_name in {"jenkinsfile", "azure-pipelines.yml", "azure-pipelines.yaml", "bitbucket-pipelines.yml", "bitbucket-pipelines.yaml", "circle.yml"}:
                ci_cd.append(relative)
            if lower_name.startswith("dockerfile") or lower_name in {"docker-compose.yml", "docker-compose.yaml", "compose.yml", "compose.yaml"}:
                docker.append(relative)
            if lower_name in {"package.json", "pyproject.toml", "requirements.txt", "cargo.toml", "go.mod", "composer.json", "pubspec.yaml", "pom.xml", "manifest.json", "build.gradle", "build.gradle.kts"} or extension == ".csproj":
                names = dependency_names(path)
                manifests.append({"path": relative, "dependency_count": len(names), "dependencies": names})

    files.sort(key=lambda item: item["bytes"], reverse=True)
    modules = [
        {"path": directory, "file_count": directories[directory], "languages": dict(stats.most_common())}
        for directory, stats in module_stats.items() if directory != "[root]"
    ]
    modules.sort(key=lambda item: item["file_count"], reverse=True)

    result = {
        "schema_version": "1.1",
        "collector": "generic",
        "file_count": len(files),
        "language_count": len(language_files),
        "configuration_file_count": len(configs),
        "documentation_file_count": len(docs),
        "test_file_count": len(tests),
        "ci_cd_file_count": len(ci_cd),
        "docker_file_count": len(docker),
        "languages": [
            {"name": language, "files": count, "lines": language_lines[language]}
            for language, count in language_files.most_common()
        ],
        "extensions": [{"extension": extension, "files": count} for extension, count in extensions.most_common()],
        "largest_files": files[:50],
        "top_directories": [{"path": path, "files": count} for path, count in directories.most_common(30)],
        "configuration_files": sorted(configs)[:200],
        "documentation_files": sorted(docs)[:200],
        "test_files": sorted(tests)[:300],
        "ci_cd_files": sorted(ci_cd)[:100],
        "docker_files": sorted(docker)[:100],
        "dependencies": {"manifests": manifests, "total": sum(item["dependency_count"] for item in manifests)},
        "possible_modules": modules[:50],
        "git": collect_git(root, privacy_mode, author_filter),
        "_files": files,
    }
    result["analysis"] = analyze_repository(root, result)
    result.pop("_files")
    result["git"].pop("_file_author_activity", None)
    if privacy_mode == "strict":
        sanitize_strict_result(result)
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--report-name", default="")
    parser.add_argument("--privacy-mode", choices=("standard", "strict"), default="standard")
    parser.add_argument("--author", default="")
    args = parser.parse_args()
    data = collect(args.root.resolve(), args.report_name, args.privacy_mode, args.author)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
