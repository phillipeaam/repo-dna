"""Language-aware, evidence-based repository insights for the generic collector."""

from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

from languages import analyze_source
from languages.registry import parser_status
from frameworks import analyze_frameworks
from graphs import build_graphs
from architecture import analyze_architecture
from quality import import_quality_results


SOURCE_LANGUAGES = {
    "Python", "JavaScript", "TypeScript", "Java", "Kotlin", "Go", "Rust",
    "Ruby", "PHP", "Dart", "C#", "C", "C++", "F#", "Swift", "Scala",
}

SYMBOL_PATTERNS = {
    "Python": re.compile(r"^\s*(?:async\s+)?(?:def|class)\s+([A-Za-z_]\w*)", re.M),
    "JavaScript": re.compile(r"(?:class|function)\s+([A-Za-z_$][\w$]*)|(?:const|let)\s+([A-Za-z_$][\w$]*)\s*=\s*(?:async\s*)?\("),
    "TypeScript": re.compile(r"(?:class|interface|type|function|enum)\s+([A-Za-z_$][\w$]*)"),
    "Java": re.compile(r"(?:class|interface|enum|record)\s+([A-Za-z_]\w*)"),
    "Kotlin": re.compile(r"(?:class|interface|object|fun)\s+([A-Za-z_]\w*)"),
    "Go": re.compile(r"^\s*(?:type|func)\s+(?:\([^)]*\)\s*)?([A-Za-z_]\w*)", re.M),
    "Rust": re.compile(r"(?:struct|enum|trait|fn|mod)\s+([A-Za-z_]\w*)"),
    "Ruby": re.compile(r"^\s*(?:class|module|def)\s+([A-Za-z_]\w*[!?=]?)", re.M),
    "PHP": re.compile(r"(?:class|interface|trait|function)\s+([A-Za-z_]\w*)", re.I),
    "Dart": re.compile(r"(?:class|mixin|enum|extension)\s+([A-Za-z_]\w*)"),
    "C#": re.compile(r"(?:class|interface|struct|record|enum)\s+([A-Za-z_]\w*)"),
}

IMPORT_PATTERNS = {
    "Python": re.compile(r"^\s*(?:from\s+([\w.]+)\s+import|import\s+([\w.]+))", re.M),
    "JavaScript": re.compile(r"(?:from\s+|require\s*\(\s*)[\"']([^\"']+)"),
    "TypeScript": re.compile(r"(?:from\s+|require\s*\(\s*)[\"']([^\"']+)"),
    "Java": re.compile(r"^\s*import\s+([\w.]+)", re.M),
    "Kotlin": re.compile(r"^\s*import\s+([\w.]+)", re.M),
    "Go": re.compile(r"^\s*[\"']([^\"']+)[\"']", re.M),
    "Rust": re.compile(r"^\s*(?:use|mod)\s+([\w:]+)", re.M),
    "Dart": re.compile(r"^\s*import\s+[\"']([^\"']+)", re.M),
    "C#": re.compile(r"^\s*using\s+([\w.]+)", re.M),
}

PATTERN_RULES = {
    "Repository": re.compile(r"\b\w*Repository\b"),
    "Factory": re.compile(r"\b\w*Factory\b"),
    "Builder": re.compile(r"\b\w*Builder\b"),
    "Strategy": re.compile(r"\b\w*Strategy\b"),
    "Observer/Event": re.compile(r"\b(?:Observer|EventBus|EventEmitter|EventHandler)\b"),
    "Command": re.compile(r"\b\w*Command\b"),
    "State machine": re.compile(r"\b(?:StateMachine|IState|StateHandler)\b"),
    "Dependency injection": re.compile(r"\b(?:Injectable|DependencyInjection|ServiceCollection|Container)\b"),
    "MVC/MVVM": re.compile(r"\b(?:Controller|ViewModel|Presenter)\b"),
    "Service layer": re.compile(r"\b\w*Service\b"),
}

BRANCH_PATTERNS = re.compile(
    r"\b(if|elif|else if|for|foreach|while|case|catch|except|when)\b|&&|\|\||\?"
)


def _read(path: Path, limit: int = 1_000_000) -> str:
    try:
        if path.stat().st_size > limit:
            return ""
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def _matches(pattern: re.Pattern[str], content: str) -> list[str]:
    values: list[str] = []
    for match in pattern.finditer(content):
        value = next((group for group in match.groups() if group), "") if match.groups() else match.group(0)
        if value:
            values.append(value)
    return values


def analyze_code(root: Path, files: list[dict[str, Any]]) -> dict[str, Any]:
    symbols: list[dict[str, Any]] = []
    imports_by_file: dict[str, list[str]] = {}
    pattern_counts: Counter[str] = Counter()
    pattern_basis: dict[str, str] = {}
    complexity_rows: list[dict[str, Any]] = []
    function_complexity: list[dict[str, Any]] = []
    calls: list[dict[str, Any]] = []
    language_architecture: dict[str, Counter[str]] = defaultdict(Counter)
    parser_files: dict[str, Counter[str]] = defaultdict(Counter)
    parser_errors: Counter[str] = Counter()

    for item in files:
        language = item.get("language")
        if language not in SOURCE_LANGUAGES:
            continue
        relative = item["path"]
        content = _read(root / relative)
        if not content:
            continue

        ast_result = analyze_source(language, content)
        ast_succeeded = bool(ast_result and not ast_result["parse_errors"])
        if ast_succeeded and ast_result:
            parser_files[language]["ast"] += 1
            for symbol in ast_result["symbols"][:100]:
                symbols.append({**symbol, "path": relative, "language": language, "parser": ast_result["parser"]})
            imports = ast_result["imports"]
            for call in ast_result["calls"]:
                calls.append({**call, "path": relative, "language": language})
            for function in ast_result["functions"]:
                function_complexity.append({**function, "path": relative, "language": language})
            for pattern in ast_result["design_patterns"]:
                pattern_counts[pattern["name"]] += pattern["matches"]
                pattern_basis[pattern["name"]] = pattern["basis"]
            for signal in ast_result["architecture_signals"]:
                language_architecture[language][signal] += 1
            decisions = ast_result["decision_points"]
        else:
            parser_files[language]["heuristic"] += 1
            if ast_result and ast_result["parse_errors"]:
                parser_errors[language] += len(ast_result["parse_errors"])
            symbol_pattern = SYMBOL_PATTERNS.get(language)
            file_symbols = _matches(symbol_pattern, content) if symbol_pattern else []
            symbols.extend({"name": name, "path": relative, "language": language, "parser": "regex"} for name in file_symbols[:100])
            import_pattern = IMPORT_PATTERNS.get(language)
            imports = sorted(set(_matches(import_pattern, content))) if import_pattern else []
            for pattern_name, pattern in PATTERN_RULES.items():
                count = len(pattern.findall(content))
                if count:
                    pattern_counts[pattern_name] += count
                    pattern_basis.setdefault(pattern_name, "symbol and naming heuristic")
            decisions = len(BRANCH_PATTERNS.findall(content))
        if imports:
            imports_by_file[relative] = imports[:100]

        estimated_complexity = 1 + decisions
        complexity_rows.append({
            "path": relative,
            "language": language,
            "estimated_cyclomatic_complexity": estimated_complexity,
            "decision_points": decisions,
            "lines": item.get("lines", 0),
        })

        lowered = relative.casefold()
        for signal, terms in {
            "layered": ("controller", "service", "repository"),
            "domain-oriented": ("domain", "entity", "aggregate", "usecase", "use_case"),
            "event-driven": ("event", "message", "queue", "consumer", "producer"),
            "component-oriented": ("component", "widget", "view"),
            "test-separated": ("test", "spec"),
        }.items():
            if any(term in lowered for term in terms):
                language_architecture[language][signal] += 1

    complexity_rows.sort(key=lambda row: row["estimated_cyclomatic_complexity"], reverse=True)
    function_complexity.sort(key=lambda row: row["estimated_cyclomatic_complexity"], reverse=True)
    complexities = [row["estimated_cyclomatic_complexity"] for row in complexity_rows]
    analyzed_languages = sorted({item.get("language") for item in files if item.get("language") in SOURCE_LANGUAGES})
    return {
        "languages_analyzed": analyzed_languages,
        "parser_coverage": [
            {
                **parser_status(language),
                "ast_files": parser_files[language]["ast"],
                "heuristic_files": parser_files[language]["heuristic"],
                "parse_errors": parser_errors[language],
            }
            for language in analyzed_languages
        ],
        "symbols": symbols[:1000],
        "symbol_count": len(symbols),
        "imports": [{"path": path, "imports": values} for path, values in sorted(imports_by_file.items())][:500],
        "importing_file_count": len(imports_by_file),
        "design_patterns": [
            {"name": name, "matches": count, "confidence": "medium", "basis": pattern_basis.get(name, "symbol and naming heuristic")}
            for name, count in pattern_counts.most_common()
        ],
        "architecture_signals": [
            {"language": language, "signals": dict(signals)}
            for language, signals in sorted(language_architecture.items())
        ],
        "complexity": {
            "method": "AST per-function complexity where available; heuristic decision points per file otherwise",
            "files_analyzed": len(complexity_rows),
            "average": round(sum(complexities) / len(complexities), 2) if complexities else None,
            "maximum": max(complexities) if complexities else None,
            "high_complexity_files": [row for row in complexity_rows if row["estimated_cyclomatic_complexity"] >= 20][:50],
            "high_complexity_functions": [row for row in function_complexity if row["estimated_cyclomatic_complexity"] >= 10][:100],
        },
        "calls": calls[:2000],
        "call_count": len(calls),
    }


def identify_systems(files: list[dict[str, Any]], code: dict[str, Any], dependencies: dict[str, Any]) -> list[dict[str, Any]]:
    groups: dict[str, dict[str, Any]] = {}
    symbols_by_path: Counter[str] = Counter(item["path"].split("/", 1)[0] for item in code["symbols"])
    imports_by_path: Counter[str] = Counter()
    for item in code["imports"]:
        imports_by_path[item["path"].split("/", 1)[0]] += len(item["imports"])
    for item in files:
        if not item.get("language"):
            continue
        path = item["path"]
        root_name = path.split("/", 1)[0] if "/" in path else "[root]"
        group = groups.setdefault(root_name, {"file_count": 0, "languages": Counter(), "lines": 0})
        group["file_count"] += 1
        group["languages"][item["language"]] += 1
        group["lines"] += item.get("lines", 0)
    manifest_paths = [item["path"] for item in dependencies.get("manifests", [])]
    systems = []
    for name, group in groups.items():
        evidence = [f"{group['file_count']} source files", f"{group['lines']} source lines"]
        if symbols_by_path[name]:
            evidence.append(f"{symbols_by_path[name]} symbols")
        if imports_by_path[name]:
            evidence.append(f"{imports_by_path[name]} import references")
        related_manifests = [path for path in manifest_paths if path == name or path.startswith(f"{name}/")]
        systems.append({
            "name": name,
            "path": name,
            "confidence": "high" if group["file_count"] >= 5 and (symbols_by_path[name] or imports_by_path[name]) else "medium",
            "file_count": group["file_count"],
            "lines": group["lines"],
            "symbol_count": symbols_by_path[name],
            "import_references": imports_by_path[name],
            "languages": dict(group["languages"].most_common()),
            "dependency_manifests": related_manifests,
            "evidence": evidence,
            "confirmation_required": True,
        })
    return sorted(systems, key=lambda item: (item["symbol_count"] + item["import_references"], item["file_count"]), reverse=True)[:50]


def license_evidence(root: Path, files: list[dict[str, Any]]) -> dict[str, Any]:
    license_paths = [item["path"] for item in files if Path(item["path"]).name.casefold().startswith(("license", "copying", "notice"))]
    detected = "Unknown"
    if license_paths:
        content = _read(root / license_paths[0], 200_000).casefold()
        signatures = {
            "MIT": "permission is hereby granted, free of charge",
            "Apache-2.0": "apache license, version 2.0",
            "GPL": "gnu general public license",
            "BSD": "redistribution and use in source and binary forms",
            "MPL-2.0": "mozilla public license version 2.0",
        }
        detected = next((name for name, signature in signatures.items() if signature in content), "Unclassified")
    return {
        "repository_license": detected,
        "license_files": license_paths[:20],
        "dependency_license_status": "not_scanned",
        "note": "Dependency licenses require ecosystem metadata or lockfile resolution and are not inferred from dependency names.",
    }


def health_score(generic: dict[str, Any], quality: dict[str, Any], git_data: dict[str, Any]) -> dict[str, Any]:
    dimensions: list[dict[str, Any]] = []

    def add(name: str, score: float, maximum: float, evidence: str, status: str = "assessed") -> None:
        dimensions.append({"name": name, "score": round(score, 1), "maximum": maximum, "status": status, "evidence": evidence})

    docs = generic.get("documentation_file_count", 0)
    tests = generic.get("test_file_count", 0)
    ci = generic.get("ci_cd_file_count", 0)
    complexity = quality["code"]["complexity"]
    add("Documentation", min(15, 5 + docs * 2) if docs else 0, 15, f"{docs} documentation files")
    test_results = quality["tests"]
    coverage_result = quality["coverage"]
    testing_score = min(5, tests) if tests else 0
    if test_results["status"] == "imported" and test_results.get("total", 0):
        testing_score += 8 * test_results.get("passed", 0) / test_results["total"]
    if coverage_result["status"] == "imported" and coverage_result.get("line_coverage_percent") is not None:
        testing_score += 7 * coverage_result["line_coverage_percent"] / 100
    add("Testing evidence", min(20, testing_score), 20, f"{tests} test files; test results {test_results['status']}; coverage {coverage_result.get('line_coverage_percent')}%")
    add("Automation", min(15, ci * 8 + generic.get("docker_file_count", 0) * 3), 15, f"{ci} CI/CD files")
    if complexity["average"] is None:
        add("Maintainability", 0, 20, "No supported source files", "not_assessed")
    else:
        avg = complexity["average"]
        base = max(0, 18 - max(avg - 5, 0))
        lint = quality["linters"]
        lint_bonus = 2 if lint["status"] == "imported" and lint.get("issues", 0) == 0 else 1 if lint["status"] == "imported" else 0
        add("Maintainability", min(20, base + lint_bonus), 20, f"Estimated average file complexity {avg}; linter results {lint['status']} with {lint.get('issues', 0)} issues")
    contributors = git_data.get("contributors_count", 0)
    add("Knowledge distribution", min(15, 5 + contributors * 2) if contributors else 0, 15, f"{contributors} contributors in Git history")
    license_name = quality["licenses"]["repository_license"]
    add("Governance", 10 if license_name not in {"Unknown", "Unclassified"} else 2 if license_name == "Unclassified" else 0, 10, f"Repository license: {license_name}")
    security = quality["vulnerabilities"]
    if security["status"] == "imported":
        severities = security.get("severities", {})
        penalty = severities.get("critical", 0) * 2 + severities.get("high", 0) + (security.get("findings", 0) - severities.get("critical", 0) - severities.get("high", 0)) * 0.25
        add("Dependency security", max(0, 5 - penalty), 5, f"Imported {security.get('findings', 0)} findings: {severities}")
    else:
        add("Dependency security", 0, 5, security["note"], "not_assessed")

    assessed = [item for item in dimensions if item["status"] == "assessed"]
    achieved = sum(item["score"] for item in assessed)
    maximum = sum(item["maximum"] for item in assessed)
    score = round(achieved / maximum * 100, 1) if maximum else None
    coverage = round(maximum / sum(item["maximum"] for item in dimensions) * 100, 1)
    grade = None if score is None else "A" if score >= 85 else "B" if score >= 70 else "C" if score >= 55 else "D" if score >= 40 else "E"
    return {
        "model": "RepoDNA repository health heuristic",
        "version": "1.1",
        "score": score,
        "grade": grade,
        "assessment_coverage_percent": coverage,
        "dimensions": dimensions,
        "limitations": [
            "The score measures repository evidence, not product quality or team performance.",
            "Unassessed dimensions are excluded from the score and reduce assessment coverage.",
            "AST coverage varies by language; heuristic fallback complexity is not equivalent to language-native static analysis.",
        ],
    }


def build_narrative_facts(generic: dict[str, Any], code: dict[str, Any], systems: list[dict[str, Any]]) -> list[dict[str, Any]]:
    facts = [
        {"statement": f"The repository contains {generic['file_count']} analyzed files across {generic['language_count']} detected languages.", "evidence": "#/file_count", "confidence": "high"},
        {"statement": f"The collector identified {code['symbol_count']} source symbols in supported languages.", "evidence": "#/analysis/code/symbol_count", "confidence": "medium"},
        {"statement": f"The analysis produced {len(systems)} module-based system candidates requiring human confirmation.", "evidence": "#/analysis/systems", "confidence": "medium"},
    ]
    if generic.get("test_file_count", 0):
        facts.append({"statement": f"The repository contains {generic['test_file_count']} files classified as tests.", "evidence": "#/test_files", "confidence": "high"})
    return facts


def analyze_repository(root: Path, generic: dict[str, Any]) -> dict[str, Any]:
    code = analyze_code(root, generic["_files"])
    frameworks = analyze_frameworks(generic["_files"], code, generic["dependencies"])
    graphs = build_graphs(root, generic["_files"], code["imports"], generic["dependencies"])
    architecture_model = analyze_architecture(root, generic["_files"], graphs)
    systems = identify_systems(generic["_files"], code, generic["dependencies"])
    imported_quality = import_quality_results(root, len(generic["dependencies"].get("manifests", [])))
    quality = {
        "code": code,
        **imported_quality,
        "licenses": license_evidence(root, generic["_files"]),
    }
    health = health_score(generic, quality, generic["git"])
    return {
        "architecture": {
            "languages_analyzed": code["languages_analyzed"],
            "parser_coverage": code["parser_coverage"],
            "signals": code["architecture_signals"],
            "design_patterns": code["design_patterns"],
            "entrypoints": architecture_model["entrypoints"],
            "coupling": architecture_model["coupling"],
            "boundaries": architecture_model["boundaries"],
            "summary": architecture_model["summary"],
        },
        "code": {
            "symbol_count": code["symbol_count"],
            "symbols": code["symbols"],
            "importing_file_count": code["importing_file_count"],
            "imports": code["imports"],
            "call_count": code["call_count"],
            "calls": code["calls"],
            "complexity": code["complexity"],
        },
        "systems": systems,
        "frameworks": frameworks,
        "graphs": graphs,
        "quality": quality | {"code": {"complexity": code["complexity"]}},
        "health": health,
        "narrative_facts": build_narrative_facts(generic, code, systems),
    }
