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
from author_system_ownership import analyze_author_system_ownership
from bus_factor import analyze_bus_factor
from achievement_candidates import generate_achievement_candidates
from onboarding import collect_onboarding
from unity_analysis import analyze_unity
from android_analysis import analyze_android
from flutter_analysis import analyze_flutter
from dependency_inventory import collect_dependency_inventory
from delivery_analysis import analyze_delivery
from forge_import import import_forge_data
from godot_analysis import analyze_godot
from unreal_analysis import analyze_unreal
from system_classifier import classify_structural_entities, classify_systems


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
    function_complexities = sorted(row["estimated_cyclomatic_complexity"] for row in function_complexity)
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
            "function_count": len(function_complexities),
            "function_average": round(sum(function_complexities) / len(function_complexities), 2) if function_complexities else None,
            "function_median": function_complexities[len(function_complexities) // 2] if function_complexities else None,
            "functions_over_threshold": sum(value >= 10 for value in function_complexities),
            "high_complexity_files": [row for row in complexity_rows if row["estimated_cyclomatic_complexity"] >= 20][:50],
            "high_complexity_functions": [row for row in function_complexity if row["estimated_cyclomatic_complexity"] >= 10][:100],
        },
        "calls": calls[:2000],
        "call_count": len(calls),
    }


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


def health_score(generic: dict[str, Any], quality: dict[str, Any], git_data: dict[str, Any], architecture: dict[str, Any]) -> dict[str, Any]:
    dimensions: list[dict[str, Any]] = []

    def dimension(name: str, weight: int, checks: list[dict[str, Any]]) -> None:
        assessed = [item for item in checks if item["state"] in {"positive", "problem"}]
        assessed_weight = sum(item["weight"] for item in assessed)
        achieved = sum(item["points"] for item in assessed)
        score = round(achieved / assessed_weight * 100, 1) if assessed_weight else None
        dimensions.append({
            "name": name, "weight": weight, "score": score, "maximum": 100,
            "status": "assessed" if assessed_weight == weight else "partial" if assessed_weight else "not_assessed",
            "evidence_coverage_percent": round(assessed_weight / weight * 100, 1),
            "evidence": "; ".join(item["message"] for item in assessed) or "No supported evidence was available.",
            "checks": checks,
            "point_losses": [item["message"] for item in assessed if item["points"] < item["weight"]],
            "unavailable": [item["message"] for item in checks if item["state"] not in {"positive", "problem"}],
        })

    docs = generic.get("documentation_file_count", 0)
    dimension("Documentation", 15, [{"name":"repository_documentation","weight":15,"points":min(15, docs * 3),"state":"positive" if docs >= 5 else "problem","message":f"{docs} documentation files observed; full credit requires 5."}])

    tests = generic.get("test_file_count", 0); test_results = quality["tests"]; coverage_result = quality["coverage"]
    testing_checks = [{"name":"test_files","weight":8,"points":8 if tests >= 5 else min(8, tests * 1.6),"state":"positive" if tests >= 5 else "problem","message":f"{tests} test files observed; full credit requires 5."}]
    if test_results["status"] == "imported" and test_results.get("total", 0):
        ratio = test_results.get("passed", 0) / test_results["total"]
        testing_checks.append({"name":"test_results","weight":6,"points":6*ratio,"state":"positive" if ratio >= .9 else "problem","message":f"{test_results.get('passed',0)}/{test_results['total']} imported tests passed."})
    else: testing_checks.append({"name":"test_results","weight":6,"points":0,"state":"external_not_executed","message":test_results.get("message", "No test-result artifact was provided or discovered.")})
    if coverage_result["status"] == "imported" and coverage_result.get("line_coverage_percent") is not None:
        value = coverage_result["line_coverage_percent"]
        testing_checks.append({"name":"line_coverage","weight":6,"points":6*value/100,"state":"positive" if value >= 70 else "problem","message":f"Imported line coverage is {value}%."})
    else: testing_checks.append({"name":"line_coverage","weight":6,"points":0,"state":"external_not_executed","message":coverage_result.get("message", "No coverage artifact was provided or discovered.")})
    dimension("Testing", 20, testing_checks)

    code = quality["code"]; parser_rows = code.get("parser_coverage", []); parsed = sum(item.get("ast_files",0) for item in parser_rows); fallback = sum(item.get("heuristic_files",0) for item in parser_rows)
    if parsed + fallback:
        ratio = parsed / (parsed + fallback)
        architecture_checks = [{"name":"parser_support","weight":6,"points":3+3*ratio,"state":"positive" if ratio >= .5 else "problem","message":f"{parsed} AST-parsed and {fallback} heuristic-fallback source files."}]
    else: architecture_checks = [{"name":"parser_support","weight":6,"points":0,"state":"unsupported","message":"No supported source files were available for architecture analysis."}]
    assessed_modules=architecture.get("coupling",{}).get("summary",{}).get("assessed_modules",0)
    if assessed_modules:
        cycles=architecture.get("summary",{}).get("cycles",0); violations=architecture.get("summary",{}).get("boundary_violations",0)
        architecture_checks.extend([
            {"name":"dependency_cycles","weight":5,"points":max(0,5-cycles),"state":"positive" if cycles==0 else "problem","message":f"{cycles} approximate module dependency cycles across {assessed_modules} assessed modules."},
            {"name":"boundary_violations","weight":4,"points":max(0,4-violations),"state":"positive" if violations==0 else "problem","message":f"{violations} inferred architectural boundary violations."},
        ])
    else:
        architecture_checks.extend([
            {"name":"dependency_cycles","weight":5,"points":0,"state":"unsupported","message":"No module graph was available for cycle analysis."},
            {"name":"boundary_violations","weight":4,"points":0,"state":"unsupported","message":"No module boundaries were available for direction analysis."},
        ])
    dimension("Architecture", 15, architecture_checks)

    security = quality["vulnerabilities"]
    if security["status"] == "imported":
        severities=security.get("severities",{}); findings=security.get("findings",0) or 0
        penalty=min(15, severities.get("critical",0)*6+severities.get("high",0)*3+max(0,findings-severities.get("critical",0)-severities.get("high",0))*.5)
        security_checks=[{"name":"scanner_results","weight":15,"points":15-penalty,"state":"positive" if findings==0 else "problem","message":f"Imported scanner evidence contains {findings} findings: {severities}."}]
    else: security_checks=[{"name":"scanner_results","weight":15,"points":0,"state":"external_not_executed","message":security.get("message","No security scanner artifact was provided or discovered.")}]
    dimension("Security", 15, security_checks)

    complexity=code["complexity"]; maintainability=[]
    if complexity["average"] is None: maintainability.append({"name":"complexity","weight":15,"points":0,"state":"unsupported","message":"No supported source files were available for complexity analysis."})
    elif complexity.get("function_count"):
        function_count=complexity["function_count"]; high=complexity.get("functions_over_threshold",0); median=complexity.get("function_median",1); ratio=high/function_count
        points=max(0,15-min(10,ratio*30)-min(5,max(median-5,0)*.5))
        maintainability.append({"name":"complexity","weight":15,"points":points,"state":"positive" if high==0 and median<=5 else "problem","message":f"AST measured {function_count} functions: median complexity {median}; {high} functions at or above 10."})
    else:
        files=complexity.get("files_analyzed",0); high=len(complexity.get("high_complexity_files",[])); ratio=high/files if files else 1
        points=max(0,15*(1-ratio*.6))
        maintainability.append({"name":"complexity","weight":15,"points":points,"state":"positive" if high==0 else "problem","message":f"Fallback analysis flagged {high} of {files} files at or above complexity 20; file size can influence this heuristic."})
    lint=quality["linters"]
    if lint["status"]=="imported":
        issues=lint.get("issues",0) or 0; maintainability.append({"name":"linter_results","weight":5,"points":max(0,5-min(5,issues*.25)),"state":"positive" if issues==0 else "problem","message":f"Imported linter evidence contains {issues} issues."})
    else: maintainability.append({"name":"linter_results","weight":5,"points":0,"state":"external_not_executed","message":lint.get("message","No linter artifact was provided or discovered.")})
    dimension("Maintainability",20,maintainability)

    ci=generic.get("ci_cd_file_count",0); license_name=quality["licenses"]["repository_license"]; configs=generic.get("configuration_file_count",0)
    dimension("Repository Hygiene",15,[
        {"name":"automation","weight":6,"points":6 if ci else 0,"state":"positive" if ci else "problem","message":f"{ci} CI/CD files observed."},
        {"name":"license","weight":4,"points":4 if license_name not in {"Unknown","Unclassified"} else 0,"state":"positive" if license_name not in {"Unknown","Unclassified"} else "problem","message":f"Repository license: {license_name}."},
        {"name":"configuration","weight":5,"points":min(5,configs),"state":"positive" if configs>=5 else "problem","message":f"{configs} configuration files observed; full credit requires 5."},
    ])

    assessed_dimensions=[item for item in dimensions if item["score"] is not None]
    assessed_weight=sum(item["weight"]*item["evidence_coverage_percent"]/100 for item in dimensions)
    score=round(sum(item["score"]*item["weight"]*item["evidence_coverage_percent"]/100 for item in assessed_dimensions)/assessed_weight,1) if assessed_weight else None
    coverage=round(assessed_weight,1)
    grade = None if score is None else "A" if score >= 85 else "B" if score >= 70 else "C" if score >= 55 else "D" if score >= 40 else "E"
    return {
        "model": "RepoDNA repository health heuristic",
        "version": "2.0",
        "score": score,
        "grade": grade,
        "assessment_coverage_percent": coverage,
        "confidence": "High" if coverage >= 80 else "Medium" if coverage >= 50 else "Low",
        "dimensions": dimensions,
        "evidence_state_definitions": {
            "positive":"A good practice was supported by repository evidence.", "problem":"A point loss was supported by repository evidence.",
            "not_observed":"Information was unavailable.", "unsupported":"The current analyzer could not assess this signal.",
            "external_not_executed":"A compatible external-tool artifact was not provided or discovered."
        },
        "limitations": [
            "The score measures repository evidence, not product quality or team performance.",
            "Unavailable, unsupported, and externally unexecuted checks are excluded from the score and reduce evidence coverage.",
            "AST coverage varies by language; heuristic fallback complexity is not equivalent to language-native static analysis.",
        ],
    }


def build_conclusions(generic: dict[str, Any], systems: list[dict[str, Any]], quality: dict[str, Any]) -> dict[str, Any]:
    """Publish material conclusions using one fact/inference/absence contract."""
    manifests = generic.get("dependencies", {}).get("manifests", [])
    files = {item["path"] for item in generic.get("_files", [])}
    facts: list[dict[str, Any]] = []
    for technology in generic.get("technology_inventory", {}).get("technologies", []):
        evidence = [
            item["path"] for item in manifests
            if technology.casefold() in {str(value).casefold() for value in item.get("dependencies", [])}
        ]
        if not evidence:
            evidence = [path for path in files if technology.casefold().replace(".js", "") in path.casefold()][:5]
        facts.append({
            "value": technology, "classification": "fact", "confidence": 1.0,
            "evidence": sorted(evidence)[:10] or ["#/technology_inventory/technologies"],
        })

    inferences = [
        {
            "value": system["name"], "classification": "inference",
            "confidence": system.get("confidence", 0.5),
            "evidence": system.get("files", [])[:10],
        }
        for system in systems
    ]
    observations = []
    labels = {
        "coverage": "coverage artifact", "tests": "test-result artifact",
        "linters": "linter artifact", "vulnerabilities": "security scanner artifact",
        "dependency_licenses": "dependency-license artifact",
    }
    for key, label in labels.items():
        result = quality.get(key, {})
        observations.append({
            "subject": key,
            "status": result.get("status", "not_observed"),
            "message": result.get("message") or f"A {label} was discovered and imported.",
            "evidence": result.get("evidence_files", result.get("scanner_reports", [])),
        })
    return {"facts": facts, "inferences": inferences, "observations": observations}


def build_narrative_facts(generic: dict[str, Any], code: dict[str, Any], systems: list[dict[str, Any]]) -> list[dict[str, Any]]:
    facts = [
        {"statement": f"The repository contains {generic['file_count']} analyzed files across {generic['language_count']} detected languages.", "evidence": "#/file_count", "confidence": "high"},
        {"statement": f"The collector identified {code['symbol_count']} source symbols in supported languages.", "evidence": "#/analysis/code/symbol_count", "confidence": "medium"},
        {"statement": f"The analysis produced {len(systems)} evidence-based architectural system candidates requiring human confirmation.", "evidence": "#/analysis/systems", "confidence": "medium"},
    ]
    if generic.get("test_file_count", 0):
        facts.append({"statement": f"The repository contains {generic['test_file_count']} files classified as tests.", "evidence": "#/test_files", "confidence": "high"})
    return facts


def analyze_repository(root: Path, generic: dict[str, Any], forge_data: Path | None = None) -> dict[str, Any]:
    code = analyze_code(root, generic["_files"])
    frameworks = analyze_frameworks(generic["_files"], code, generic["dependencies"])
    graphs = build_graphs(root, generic["_files"], code["imports"], generic["dependencies"])
    architecture_model = analyze_architecture(root, generic["_files"], graphs)
    systems = classify_systems(generic["_files"], code, architecture_model, generic["git"], generic["dependencies"])
    structural_entities = classify_structural_entities(generic, code, graphs)
    author_system_ownership = analyze_author_system_ownership(systems, generic["git"])
    bus_factor_by_system = analyze_bus_factor(author_system_ownership)
    onboarding = collect_onboarding(root, generic["_files"], generic["dependencies"])
    unity = analyze_unity(root, generic["_files"], code, generic["git"], graphs)
    android = analyze_android(root, generic["_files"], code, generic["git"])
    flutter = analyze_flutter(root, generic["_files"], generic["git"])
    godot = analyze_godot(root, generic["_files"], generic["git"])
    unreal = analyze_unreal(root, generic["_files"], generic["git"])
    achievement_candidates = generate_achievement_candidates(
        generic["git"].get("author_filter", ""),
        generic["git"].get("technical_impact", {}),
        author_system_ownership,
    )
    dependency_inventory = collect_dependency_inventory(root, generic["dependencies"])
    delivery = analyze_delivery(root, generic.get("ci_cd_files", []))
    forge_activity = import_forge_data(
        forge_data, generic["git"].get("author_filter", ""),
        "standard", [item["tag"] for item in delivery.get("releases", {}).get("releases", [])],
    )
    imported_quality = import_quality_results(root, generic["dependencies"], dependency_inventory)
    quality = {
        "code": code,
        **imported_quality,
        "licenses": license_evidence(root, generic["_files"]),
    }
    health = health_score(generic, quality, generic["git"], architecture_model)
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
        "structural_entities": structural_entities,
        "author_system_ownership": author_system_ownership,
        "bus_factor_by_system": bus_factor_by_system,
        "onboarding": onboarding,
        "unity": unity,
        "android": android,
        "flutter": flutter,
        "godot": godot,
        "unreal": unreal,
        "dependency_inventory": dependency_inventory,
        "delivery": delivery,
        "forge_activity": forge_activity,
        "personal_achievement_candidates": achievement_candidates,
        "frameworks": frameworks,
        "graphs": graphs,
        "quality": quality | {"code": {"complexity": code["complexity"]}},
        "health": health,
        "conclusions": build_conclusions(generic, systems, quality),
        "narrative_facts": build_narrative_facts(generic, code, systems),
    }
