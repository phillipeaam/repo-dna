"""Heuristic architectural-system and structural-entity classification."""

from __future__ import annotations

import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


SYSTEM_RULES = {
    "Repository Analysis Pipeline": ("collector", "analyzer", "analysis", "pipeline", "inventory", "repository"),
    "Git Contribution Analysis": ("git", "history", "commit", "contribution", "author", "ownership", "churn", "hotspot", "bus factor"),
    "Architecture Analysis": ("architecture", "boundary", "coupling", "graph", "module", "import", "ast", "parser", "symbol"),
    "Technology Detection": ("technology", "framework", "runtime", "dependency", "package", "manifest", "detector", "project type"),
    "Privacy and Security": ("privacy", "security", "secret", "redact", "credential", "exclusion", "ignore", "sensitive"),
    "Structured Reporting": ("report", "renderer", "schema", "json", "csv", "markdown", "evidence", "structured"),
    "HTML Rendering": ("html", "template", "stylesheet", "css", "render html"),
    "Onboarding Generation": ("onboarding", "start here", "entrypoint", "developer setup", "command"),
    "Snapshot Comparison": ("snapshot", "comparison", "compare", "baseline", "period", "delta"),
    "Health Scoring": ("health", "score", "trend", "maintainability", "assessment", "risk"),
    "Data and Persistence": ("data", "persistence", "repository", "database", "storage", "save", "cache"),
    "API and Networking": ("api", "network", "http", "client", "server", "request", "response", "socket"),
    "Authentication and Authorization": ("auth", "authentication", "authorization", "identity", "permission", "role"),
    "User Interface": ("ui", "view", "screen", "page", "widget", "component", "presenter"),
    "Background Processing": ("worker", "queue", "job", "scheduler", "consumer", "producer", "background"),
}


def words(value: str) -> str:
    value = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", value)
    return " ".join(re.findall(r"[a-z0-9]+", value.casefold()))


def contains(text: str, term: str) -> bool:
    return f" {term} " in f" {text} "


def common_boundary(paths: list[str]) -> str:
    parents = [Path(path).parent.as_posix() for path in paths]
    if not parents:
        return "[multiple]"
    first = parents[0]
    return first if first != "." and all(path == first or path.startswith(f"{first}/") for path in parents) else "[multiple]"


def classify_systems(
    files: list[dict[str, Any]], code: dict[str, Any], architecture: dict[str, Any],
    git_data: dict[str, Any], dependencies: dict[str, Any],
) -> list[dict[str, Any]]:
    file_rows = {item["path"]: item for item in files}
    symbols: dict[str, list[str]] = defaultdict(list)
    imports: dict[str, list[str]] = defaultdict(list)
    for item in code.get("symbols", []): symbols[item["path"]].append(item.get("name", ""))
    for item in code.get("imports", []): imports[item["path"]].extend(item.get("imports", []))
    entrypoints = {item.get("path") for item in architecture.get("entrypoints", [])}
    hotspots = {item["path"]: item for item in git_data.get("hotspots", [])}
    results = []
    for name, terms in SYSTEM_RULES.items():
        scored: list[tuple[float, str, list[str], set[str]]] = []
        normalized_terms = [(term, words(term)) for term in terms]
        for path, row in file_rows.items():
            path_text = words(path)
            symbol_text = words(" ".join(symbols[path]))
            import_text = words(" ".join(imports[path]))
            score, reasons, row_categories = 0.0, [], set()
            path_hits = sorted({raw for raw, term in normalized_terms if contains(path_text, term)})
            symbol_hits = sorted({raw for raw, term in normalized_terms if contains(symbol_text, term)})
            import_hits = sorted({raw for raw, term in normalized_terms if contains(import_text, term)})
            if path_hits: score += min(4.0, 1.5 * len(path_hits)); reasons.append(f"path terms: {', '.join(path_hits)}"); row_categories.add("path")
            if symbol_hits: score += min(4.0, 1.5 * len(symbol_hits)); reasons.append(f"symbol terms: {', '.join(symbol_hits)}"); row_categories.add("symbol")
            if import_hits: score += min(2.0, len(import_hits)); reasons.append(f"import terms: {', '.join(import_hits)}"); row_categories.add("import")
            if path in entrypoints and score: score += 1.0; reasons.append("detected entrypoint"); row_categories.add("entrypoint")
            if path in hotspots and score:
                score += min(2.0, hotspots[path].get("commits", 0) / 5)
                reasons.append(f"{hotspots[path].get('commits', 0)} historical commits")
                row_categories.add("history")
            if score >= 1.5: scored.append((score, path, reasons, row_categories))
        scored.sort(reverse=True)
        evidence_rows = scored[:15]
        if not evidence_rows or (len(evidence_rows) < 2 and evidence_rows[0][0] < 4):
            continue
        evidence_files = [path for _, path, _, _ in evidence_rows]
        categories = set().union(*(row_categories for _, _, _, row_categories in evidence_rows))
        total_score = sum(score for score, _, _, _ in evidence_rows)
        confidence = min(0.94, 0.38 + min(len(evidence_files), 8) * 0.025 + min(len(categories), 5) * 0.04 + min(total_score, 40) * 0.004)
        confidence = round(confidence, 2)
        if confidence < 0.6:
            continue
        results.append({
            "name": name, "entity_type": "system", "path": common_boundary(evidence_files),
            "confidence": confidence, "confidence_level": "high" if confidence >= 0.8 else "medium" if confidence >= 0.6 else "low",
            "file_count": len(evidence_files), "lines": sum(file_rows[path].get("lines", 0) for path in evidence_files),
            "symbol_count": sum(len(symbols[path]) for path in evidence_files), "import_references": sum(len(imports[path]) for path in evidence_files),
            "languages": dict(Counter(file_rows[path].get("language") for path in evidence_files if file_rows[path].get("language")).most_common()),
            "dependency_manifests": [item["path"] for item in dependencies.get("manifests", []) if any(Path(path).parent == Path(item["path"]).parent for path in evidence_files)],
            "files": evidence_files,
            "evidence": [{"path": path, "score": round(score, 2), "signals": reasons} for score, path, reasons, _ in evidence_rows],
            "evidence_categories": sorted(categories), "confirmation_required": True,
        })
    return sorted(results, key=lambda item: (-item["confidence"], -item["file_count"], item["name"]))


def classify_structural_entities(generic: dict[str, Any], code: dict[str, Any], graphs: dict[str, Any]) -> list[dict[str, Any]]:
    entities = []
    for item in generic.get("top_directories", []):
        entities.append({"name": item["path"], "entity_type": "directory", "path": item["path"], "file_count": item["files"], "confidence": 1.0})
    for item in generic.get("possible_modules", []):
        entities.append({"name": item["path"], "entity_type": "module", "path": item["path"], "file_count": item["file_count"], "languages": item.get("languages", {}), "confidence": 0.85})
    for item in graphs.get("dependency_graph", {}).get("nodes", []):
        entities.append({"name": item["id"], "entity_type": "package", "path": None, "confidence": 0.9 if item.get("declared") else 0.65, "evidence": item.get("manifests", [])})
    namespaces = Counter(value.split(".", 1)[0].split("/", 1)[0] for item in code.get("imports", []) for value in item.get("imports", []) if value and not value.startswith("."))
    for name, count in namespaces.most_common(50):
        entities.append({"name": name, "entity_type": "namespace", "path": None, "reference_count": count, "confidence": 0.7})
    if generic.get("test_files"):
        entities.append({"name": "Test Suite", "entity_type": "test_suite", "files": generic["test_files"], "file_count": len(generic["test_files"]), "confidence": 0.95})
    if generic.get("documentation_files"):
        entities.append({"name": "Project Documentation", "entity_type": "documentation", "files": generic["documentation_files"], "file_count": len(generic["documentation_files"]), "confidence": 0.95})
    infrastructure = generic.get("ci_cd_files", []) + generic.get("docker_files", []) + generic.get("configuration_files", [])
    if infrastructure:
        entities.append({"name": "Development Infrastructure", "entity_type": "infrastructure_component", "files": infrastructure, "file_count": len(infrastructure), "confidence": 0.9})
    return entities
