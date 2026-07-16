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
from pathlib import Path
from typing import Any


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
    ".git", "node_modules", "vendor", "packages", "library", "logs", "temp",
    "obj", "bin", "build", "builds", "dist", ".venv", "venv", "__pycache__",
    ".next", ".nuxt", "coverage",
}

CONFIG_NAMES = {
    "package.json", "pyproject.toml", "requirements.txt", "setup.py", "setup.cfg",
    "pipfile", "cargo.toml", "go.mod", "composer.json", "pubspec.yaml", "pom.xml",
    "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts",
    "dockerfile", "docker-compose.yml", "docker-compose.yaml", "makefile", "cmakelists.txt",
    ".editorconfig", ".npmrc", ".yarnrc", "nuget.config", "global.json",
}


def git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(root), *args], capture_output=True, text=True, errors="replace"
    )
    return result.stdout if result.returncode == 0 else ""


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


def collect_git(root: Path) -> dict[str, Any]:
    contributors = [line.strip() for line in git(root, "shortlog", "-sn", "--all").splitlines() if line.strip()]
    branches = [line.strip() for line in git(root, "branch", "-a", "--format=%(refname:short)").splitlines() if line.strip()]
    tags = [line.strip() for line in git(root, "tag", "--sort=-creatordate").splitlines() if line.strip()]
    months = Counter(git(root, "log", "--date=format:%Y-%m", "--pretty=format:%ad").splitlines())
    years = Counter(value[:4] for value in months.elements() if value)

    change_commits: Counter[str] = Counter()
    churn: Counter[str] = Counter()
    added_total = 0
    removed_total = 0
    current_commit_files: set[str] = set()
    for line in git(root, "log", "--numstat", "--pretty=tformat:__REPODNA_COMMIT__").splitlines():
        if line == "__REPODNA_COMMIT__":
            change_commits.update(current_commit_files)
            current_commit_files.clear()
            continue
        parts = line.split("\t", 2)
        if len(parts) == 3 and parts[0].isdigit() and parts[1].isdigit():
            added, removed, file_path = int(parts[0]), int(parts[1]), parts[2]
            current_commit_files.add(file_path)
            churn[file_path] += added + removed
            added_total += added
            removed_total += removed
    change_commits.update(current_commit_files)

    hotspots = [
        {"path": path, "commits": commits, "churn": churn[path], "score": commits * max(churn[path], 1)}
        for path, commits in change_commits.items()
    ]
    hotspots.sort(key=lambda item: (item["score"], item["churn"]), reverse=True)

    return {
        "contributors_count": len(contributors),
        "contributors": [f"Contributor-{index + 1}" for index in range(len(contributors))],
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
    }


def collect(root: Path, report_name: str) -> dict[str, Any]:
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
        dir_names[:] = [
            directory for directory in dir_names
            if directory.lower() not in HARD_EXCLUDES and directory != report_name
            and not re.match(r".*_project_analysis_\d{4}-\d{2}-\d{2}_", directory)
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
            if lower_path.startswith((".github/workflows/", ".gitlab-ci")) or lower_name in {"jenkinsfile", "azure-pipelines.yml", "bitbucket-pipelines.yml", "circle.yml"}:
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

    return {
        "schema_version": "1.0",
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
        "git": collect_git(root),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--report-name", default="")
    args = parser.parse_args()
    data = collect(args.root.resolve(), args.report_name)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
