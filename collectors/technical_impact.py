"""Measure before/after technical signals for individual Git contributions."""

from __future__ import annotations

import re
import subprocess
from pathlib import Path
from typing import Any, Callable


SOURCE_EXTENSIONS = {
    ".cs", ".py", ".js", ".jsx", ".ts", ".tsx", ".java", ".kt", ".kts",
    ".go", ".rs", ".rb", ".php", ".c", ".h", ".cc", ".cpp", ".cxx",
    ".swift", ".dart", ".scala", ".fs", ".fsx", ".vue", ".svelte",
}
MANIFEST_NAMES = {
    "package.json", "requirements.txt", "pyproject.toml", "cargo.toml", "go.mod",
    "pom.xml", "pubspec.yaml", "composer.json", "build.gradle", "build.gradle.kts",
}
CONFIG_NAMES = MANIFEST_NAMES | {
    "dockerfile", "docker-compose.yml", "docker-compose.yaml", ".editorconfig",
    "global.json", "nuget.config", "settings.gradle", "settings.gradle.kts",
}
DECISION_PATTERN = re.compile(r"\b(?:if|elif|else\s+if|for|while|case|catch|except|when)\b|&&|\|\||\?", re.I)


def _git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(root), *args], capture_output=True, text=True,
        encoding="utf-8", errors="replace"
    )
    return result.stdout if result.returncode == 0 else ""


class _BlobReader:
    """Reuse one Git process for all historical blob reads."""

    def __init__(self, root: Path) -> None:
        self.process = subprocess.Popen(
            ["git", "-C", str(root), "cat-file", "--batch"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
        )

    def read(self, revision: str, path: str) -> str | None:
        if not revision:
            return ""
        if self.process.stdin is None or self.process.stdout is None:
            return None
        self.process.stdin.write(f"{revision}:{path}\n".encode())
        self.process.stdin.flush()
        header = self.process.stdout.readline().decode("utf-8", errors="replace").rstrip("\n")
        if header.endswith(" missing"):
            return ""
        fields = header.rsplit(" ", 2)
        if len(fields) != 3 or not fields[2].isdigit():
            return None
        content = self.process.stdout.read(int(fields[2]))
        self.process.stdout.read(1)
        if b"\0" in content[:8192]:
            return None
        return content.decode("utf-8", errors="replace")

    def close(self) -> None:
        try:
            if self.process.stdin:
                self.process.stdin.close()
            self.process.wait(timeout=10)
        except (BrokenPipeError, subprocess.TimeoutExpired):
            self.process.kill()
            self.process.wait()


def _numstat(root: Path, commit: str, parent: str) -> list[dict[str, Any]]:
    if parent:
        raw = _git(root, "diff", "--numstat", "-z", "-M", "-C", parent, commit)
    else:
        raw = _git(root, "diff-tree", "--root", "--no-commit-id", "--numstat", "-z", "-r", "-M", "-C", commit)
    parts = raw.split("\0")
    rows: list[dict[str, Any]] = []
    index = 0
    while index < len(parts):
        header = parts[index]
        index += 1
        if not header:
            continue
        fields = header.split("\t", 2)
        if len(fields) != 3:
            continue
        added_text, removed_text, path = fields
        before_path = path
        after_path = path
        if not path and index + 1 < len(parts):
            before_path, after_path = parts[index], parts[index + 1]
            index += 2
        rows.append({
            "before_path": before_path,
            "after_path": after_path,
            "added": int(added_text) if added_text.isdigit() else None,
            "removed": int(removed_text) if removed_text.isdigit() else None,
        })
    return rows


def _is_test(path: str) -> bool:
    tokens = set(re.findall(r"[a-z0-9]+", path.casefold()))
    return bool(tokens & {"test", "tests", "spec", "specs"})


def _system(path: str) -> str:
    return path.split("/", 1)[0] if "/" in path else "[root]"


def _line_count(content: str | None) -> int | None:
    return None if content is None else len(content.splitlines())


def _complexity(content: str | None) -> int | None:
    return None if content is None else (1 + len(DECISION_PATTERN.findall(content)) if content else 0)


def _signals(delta: dict[str, int], touched: dict[str, int]) -> list[str]:
    signals = []
    if touched["test_files"]:
        signals.append("tests_changed")
    if touched["dependency_manifests"]:
        signals.append("dependencies_changed")
    if touched["configuration_files"]:
        signals.append("configuration_changed")
    if touched["documentation_files"]:
        signals.append("documentation_changed")
    if delta["estimated_complexity"] < 0:
        signals.append("estimated_complexity_reduced")
    elif delta["estimated_complexity"] > 0:
        signals.append("estimated_complexity_increased")
    if touched["source_files"] and abs(delta["source_lines"]) * 5 < touched["churn"]:
        signals.append("refactor_candidate")
    return signals or ["code_change"]


def collect_technical_impact(
    root: Path,
    scope_args: list[str],
    canonicalize: Callable[[str, str], str],
    limit: int = 200,
) -> dict[str, Any]:
    commit_rows = _git(
        root, "log", "--first-parent", f"--max-count={limit}", *scope_args,
        "--format=%H%x09%P%x09%aN%x09%aE%x09%aI%x09%s",
    ).splitlines()
    contributions = []
    blobs = _BlobReader(root)
    try:
        for row in reversed(commit_rows):
            fields = row.split("\t", 5)
            if len(fields) != 6:
                continue
            commit, parents, name, email, date, subject = fields
            parent = parents.split()[0] if parents else ""
            files = _numstat(root, commit, parent)
            touched = {
                "files": len(files), "source_files": 0, "test_files": 0,
                "documentation_files": 0, "configuration_files": 0,
                "dependency_manifests": 0, "binary_files": 0, "additions": 0,
                "deletions": 0, "churn": 0,
            }
            before = {"source_lines": 0, "estimated_complexity": 0}
            after = {"source_lines": 0, "estimated_complexity": 0}
            measurable_source_files = 0
            systems = set()
            for item in files:
                path = item["after_path"] or item["before_path"]
                systems.add(_system(path))
                file_name = Path(path).name.casefold()
                suffix = Path(path).suffix.casefold()
                if item["added"] is None or item["removed"] is None:
                    touched["binary_files"] += 1
                else:
                    touched["additions"] += item["added"]
                    touched["deletions"] += item["removed"]
                if _is_test(path):
                    touched["test_files"] += 1
                if suffix in {".md", ".rst", ".adoc"} or file_name.startswith("readme"):
                    touched["documentation_files"] += 1
                if file_name in CONFIG_NAMES or path.casefold().startswith(".github/workflows/"):
                    touched["configuration_files"] += 1
                if file_name in MANIFEST_NAMES or suffix == ".csproj":
                    touched["dependency_manifests"] += 1
                if suffix not in SOURCE_EXTENSIONS:
                    continue
                touched["source_files"] += 1
                before_content = blobs.read(parent, item["before_path"])
                after_content = blobs.read(commit, item["after_path"])
                before_lines, after_lines = _line_count(before_content), _line_count(after_content)
                before_complexity, after_complexity = _complexity(before_content), _complexity(after_content)
                if None in {before_lines, after_lines, before_complexity, after_complexity}:
                    continue
                measurable_source_files += 1
                before["source_lines"] += before_lines
                after["source_lines"] += after_lines
                before["estimated_complexity"] += before_complexity
                after["estimated_complexity"] += after_complexity
            touched["churn"] = touched["additions"] + touched["deletions"]
            delta = {key: after[key] - before[key] for key in before}
            measurement_confidence = "high" if touched["source_files"] and measurable_source_files == touched["source_files"] else "medium" if measurable_source_files else "low"
            contributions.append({
                "commit": commit[:12], "date": date, "author": canonicalize(name, email), "subject": subject,
                "parents": len(parents.split()), "systems": sorted(systems), "touched": touched,
                "before": before, "after": after, "delta": delta,
                "signals": _signals(delta, touched), "measurement_confidence": measurement_confidence,
            })
    finally:
        blobs.close()
    summary = {
        "total_churn": sum(item["touched"]["churn"] for item in contributions),
        "net_changed_source_lines": sum(item["delta"]["source_lines"] for item in contributions),
        "net_estimated_complexity": sum(item["delta"]["estimated_complexity"] for item in contributions),
        "contributions_changing_tests": sum("tests_changed" in item["signals"] for item in contributions),
        "contributions_changing_dependencies": sum("dependencies_changed" in item["signals"] for item in contributions),
        "estimated_complexity_reductions": sum("estimated_complexity_reduced" in item["signals"] for item in contributions),
        "estimated_complexity_increases": sum("estimated_complexity_increased" in item["signals"] for item in contributions),
    }
    return {
        "status": "assessed" if contributions else "insufficient_history",
        "scope": "first-parent",
        "limit": limit,
        "contributions_analyzed": len(contributions),
        "summary": summary,
        "contributions": list(reversed(contributions)),
        "method": "Per-commit Git diff metrics plus before/after measurements for changed source blobs",
        "limitations": [
            "Technical impact describes repository change, not product, business, quality, or personal performance impact",
            "Before and after source metrics cover changed source files, not complete repository snapshots",
            "Estimated complexity is a language-neutral decision-token heuristic",
            "Only the latest matching first-parent contributions up to the configured limit are analyzed",
        ],
    }
