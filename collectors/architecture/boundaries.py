"""Detect entrypoints, coupling risks, cycles, and inferred layer boundaries."""

from __future__ import annotations

import json
import re
from pathlib import Path, PurePosixPath
from typing import Any


LAYER_TOKENS = {
    "domain": {"domain", "core", "entities", "entity", "model", "models"},
    "application": {"application", "app", "usecases", "usecase", "services", "service"},
    "presentation": {"presentation", "ui", "views", "view", "controllers", "controller", "api", "web", "pages", "screens"},
    "infrastructure": {"infrastructure", "infra", "data", "persistence", "repositories", "repository", "adapters", "adapter", "database"},
}

ALLOWED_DEPENDENCIES = {
    "domain": {"domain"},
    "application": {"application", "domain"},
    "presentation": {"presentation", "application", "domain"},
    "infrastructure": {"infrastructure", "application", "domain"},
}

ENTRYPOINT_PATTERNS = {
    "Python": [(r"if\s+__name__\s*==\s*['\"]__main__['\"]", "Python main guard")],
    "C#": [(r"\bstatic\s+(?:async\s+)?(?:void|Task(?:<int>)?|int)\s+Main\s*\(", "C# Main method"), (r"\bWebApplication\.CreateBuilder\s*\(", "ASP.NET host bootstrap")],
    "Java": [(r"\bstatic\s+void\s+main\s*\(\s*String", "Java main method")],
    "Kotlin": [(r"\bfun\s+main\s*\(", "Kotlin main function")],
    "Dart": [(r"\b(?:void|Future<void>)\s+main\s*\(", "Dart main function")],
    "Go": [(r"(?m)^\s*package\s+main\b[\s\S]*?\bfunc\s+main\s*\(", "Go main package and function")],
    "Rust": [(r"\bfn\s+main\s*\(", "Rust main function")],
}


def _read(path: Path, limit: int = 1_000_000) -> str:
    try:
        if path.stat().st_size > limit:
            return ""
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def _entrypoints(root: Path, files: list[dict[str, Any]]) -> list[dict[str, Any]]:
    findings: list[dict[str, Any]] = []
    seen: set[tuple[str, str]] = set()

    def add(path: str, language: str, kind: str, evidence: str, confidence: str = "high") -> None:
        key = (path, kind)
        if key not in seen:
            seen.add(key)
            findings.append({"path": path, "language": language, "kind": kind, "confidence": confidence, "evidence": evidence})

    for item in files:
        language = item.get("language")
        path = item.get("path", "")
        if not language or not path:
            continue
        lowered = path.casefold()
        if language == "C#" and PurePosixPath(path).name.casefold() == "program.cs":
            add(path, language, "application bootstrap", "Conventional Program.cs entrypoint", "medium")
        if language == "Rust" and lowered.endswith(("src/main.rs", "/main.rs")):
            add(path, language, "executable entrypoint", "Conventional Rust main.rs", "high")
        if language in {"JavaScript", "TypeScript"} and re.search(r"(^|/)(?:app|pages)/(?:page|route|_app)\.[jt]sx?$", path, re.I):
            add(path, language, "framework route", "Next.js route convention", "medium")
        content = _read(root / path)
        for pattern, evidence in ENTRYPOINT_PATTERNS.get(language, []):
            if re.search(pattern, content):
                add(path, language, "executable entrypoint", evidence)

    package_json = root / "package.json"
    try:
        package = json.loads(package_json.read_text(encoding="utf-8"))
        for field in ("main", "module"):
            target = package.get(field)
            if isinstance(target, str):
                add(target.removeprefix("./"), "JavaScript", "package entrypoint", f"package.json {field} field")
        binary = package.get("bin")
        if isinstance(binary, str):
            add(binary.removeprefix("./"), "JavaScript", "CLI entrypoint", "package.json bin field")
        elif isinstance(binary, dict):
            for target in binary.values():
                if isinstance(target, str):
                    add(target.removeprefix("./"), "JavaScript", "CLI entrypoint", "package.json bin mapping")
    except (OSError, ValueError, TypeError):
        pass
    return sorted(findings, key=lambda item: (item["path"], item["kind"]))


def _layer(module: str) -> tuple[str, str]:
    tokens = {token for token in re.split(r"[/_.-]+", module.casefold()) if token}
    matches = [(layer, sorted(tokens & terms)) for layer, terms in LAYER_TOKENS.items() if tokens & terms]
    if len(matches) == 1:
        layer, evidence = matches[0]
        return layer, f"path token: {evidence[0]}"
    return "unclassified", "no unique architectural layer token"


def _coupling(module_graph: dict[str, Any]) -> dict[str, Any]:
    modules: list[dict[str, Any]] = []
    for node in module_graph.get("nodes", []):
        fan_in = node.get("fan_in", 0)
        fan_out = node.get("fan_out", 0)
        total = fan_in + fan_out
        instability = round(fan_out / total, 3) if total else 0.0
        role = "isolated"
        if fan_in and fan_out:
            role = "hub"
        elif fan_in:
            role = "provider"
        elif fan_out:
            role = "consumer"
        modules.append({**node, "total_coupling": total, "instability": instability, "role": role})
    modules.sort(key=lambda item: (-item["total_coupling"], -item["fan_in"], item["id"]))
    high = [item for item in modules if item["total_coupling"] >= 4 or item["fan_in"] >= 3 or item["fan_out"] >= 3]
    return {
        "modules": modules,
        "high_coupling": high[:50],
        "summary": {"assessed_modules": len(modules), "high_coupling_modules": len(high), "maximum_total_coupling": max((item["total_coupling"] for item in modules), default=0)},
        "method": "Afferent fan-in, efferent fan-out, total coupling, and instability I=fan-out/(fan-in+fan-out)",
    }


def _boundaries(module_graph: dict[str, Any]) -> dict[str, Any]:
    classifications: dict[str, tuple[str, str]] = {node["id"]: _layer(node["id"]) for node in module_graph.get("nodes", [])}
    modules = [{"module": module, "layer": layer, "confidence": "medium" if layer != "unclassified" else "low", "evidence": evidence} for module, (layer, evidence) in sorted(classifications.items())]
    violations: list[dict[str, Any]] = []
    for edge in module_graph.get("edges", []):
        source_layer = classifications.get(edge["source"], ("unclassified", ""))[0]
        target_layer = classifications.get(edge["target"], ("unclassified", ""))[0]
        if "unclassified" in {source_layer, target_layer} or target_layer in ALLOWED_DEPENDENCIES[source_layer]:
            continue
        severity = "high" if source_layer in {"domain", "application"} or target_layer == "presentation" else "medium"
        violations.append({
            "source": edge["source"], "source_layer": source_layer, "target": edge["target"], "target_layer": target_layer,
            "references": edge.get("references", 1), "severity": severity,
            "rule": f"{source_layer} should not depend on {target_layer}", "confidence": "medium",
        })
    cycles = []
    for cycle in module_graph.get("cycles", []):
        layers = sorted({classifications.get(module, ("unclassified", ""))[0] for module in cycle})
        cross_boundary = len({layer for layer in layers if layer != "unclassified"}) > 1
        cycles.append({"modules": cycle, "layers": layers, "cross_boundary": cross_boundary, "severity": "high" if cross_boundary else "medium"})
    return {
        "modules": modules, "violations": violations, "cycles": cycles,
        "summary": {
            "classified_modules": sum(item["layer"] != "unclassified" for item in modules),
            "unclassified_modules": sum(item["layer"] == "unclassified" for item in modules),
            "violations": len(violations), "cross_boundary_cycles": sum(item["cross_boundary"] for item in cycles),
        },
        "method": "Path-token layer inference evaluated against Clean Architecture dependency direction",
        "limitations": ["Inferred layers are naming-based unless a future explicit RepoDNA architecture configuration overrides them."],
    }


def analyze_architecture(root: Path, files: list[dict[str, Any]], graphs: dict[str, Any]) -> dict[str, Any]:
    module_graph = graphs.get("module_graph", {})
    entrypoints = _entrypoints(root, files)
    coupling = _coupling(module_graph)
    boundaries = _boundaries(module_graph)
    return {
        "entrypoints": entrypoints,
        "coupling": coupling,
        "boundaries": boundaries,
        "summary": {
            "entrypoints": len(entrypoints),
            "cycles": len(module_graph.get("cycles", [])),
            "high_coupling_modules": coupling["summary"]["high_coupling_modules"],
            "boundary_violations": boundaries["summary"]["violations"],
        },
    }
