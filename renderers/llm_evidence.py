#!/usr/bin/env python3

"""Build a compact, provenance-rich evidence package for downstream LLMs."""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Any


MAX_SYSTEMS = 50
MAX_OWNERSHIP = 100
MAX_CONTRIBUTIONS = 100
MAX_DEPENDENCY_REVIEWS = 100
MAX_CONTRIBUTORS = 100
MAX_ENTRYPOINTS = 50


def evidence(
    identifier: str,
    category: str,
    kind: str,
    statement: str,
    confidence: str,
    pointers: list[str],
    metrics: dict[str, Any] | None = None,
    caveats: list[str] | None = None,
    confirmation_required: bool = False,
) -> dict[str, Any]:
    return {
        "id": identifier,
        "category": category,
        "kind": kind,
        "statement": statement,
        "confidence": confidence,
        "evidence": [{"source": "report/data/report.json", "pointer": pointer} for pointer in pointers],
        "metrics": metrics or {},
        "caveats": [str(item) for item in (caveats or []) if item],
        "confirmation_required": confirmation_required,
    }


def build(data: dict[str, Any]) -> dict[str, Any]:
    project = data.get("project", {})
    privacy = data.get("privacy", {})
    generic = data.get("generic_analysis", {})
    analysis = generic.get("analysis", {})
    git_data = generic.get("git", {})
    architecture = analysis.get("architecture", {})
    quality = analysis.get("quality", {})
    items: list[dict[str, Any]] = []

    items.append(evidence(
        "repository-profile", "project", "fact",
        f"Repository {project.get('name', 'Unknown')} was classified as {project.get('type', 'Unknown')}.",
        "high", ["#/project", "#/analysis_profile"],
        {"code_root": project.get("code_root", "."), "files": generic.get("file_count", 0), "languages": generic.get("language_count", 0)},
    ))
    for index, language in enumerate(generic.get("languages", []), 1):
        items.append(evidence(
            f"language-{index}", "technology", "fact",
            f"{language['name']} appears in {language['files']} files with approximately {language['lines']} lines.",
            "high", ["#/generic_analysis/languages"], language,
        ))
    items.append(evidence(
        "repository-inventory", "project", "fact",
        "Repository inventory counts configuration, documentation, tests, CI/CD, Docker, and dependency declarations.",
        "high", ["#/generic_analysis"],
        {"configuration_files": generic.get("configuration_file_count", 0), "documentation_files": generic.get("documentation_file_count", 0), "test_files": generic.get("test_file_count", 0), "ci_cd_files": generic.get("ci_cd_file_count", 0), "docker_files": generic.get("docker_file_count", 0), "dependency_declarations": generic.get("dependencies", {}).get("total", 0)},
    ))

    for index, pattern in enumerate(architecture.get("design_patterns", []), 1):
        items.append(evidence(
            f"design-pattern-{index}", "architecture", "inference",
            f"{pattern['name']} pattern evidence has {pattern.get('matches', 0)} matches.",
            pattern.get("confidence", "medium"), ["#/generic_analysis/analysis/architecture/design_patterns"],
            {"matches": pattern.get("matches", 0), "basis": pattern.get("basis", "unspecified")},
            ["Pattern detection is structural evidence and does not prove intentional design."], True,
        ))
    for index, framework in enumerate(analysis.get("frameworks", {}).get("detected", []), 1):
        items.append(evidence(
            f"framework-{index}", "technology", "inference",
            f"{framework['name']} framework evidence was detected.",
            framework.get("confidence", "medium"), ["#/generic_analysis/analysis/frameworks"],
            {"score": framework.get("score"), "family": framework.get("family"), "concepts": framework.get("concepts", [])},
            analysis.get("frameworks", {}).get("limitations", []),
        ))
    for index, entrypoint in enumerate(architecture.get("entrypoints", [])[:MAX_ENTRYPOINTS], 1):
        items.append(evidence(
            f"entrypoint-{index}", "architecture", "inference",
            f"{entrypoint.get('path', 'Unknown')} is a detected {entrypoint.get('kind', 'entrypoint')}.",
            entrypoint.get("confidence", "medium"), ["#/generic_analysis/analysis/architecture/entrypoints"],
            {"language": entrypoint.get("language"), "evidence": entrypoint.get("evidence")},
            ["Entrypoint detection is static and does not prove runtime reachability."],
        ))
    for index, system in enumerate(analysis.get("systems", [])[:MAX_SYSTEMS], 1):
        items.append(evidence(
            f"system-{index}", "system", "inference",
            f"{system['name']} is a detected system candidate supported by repository structure and code evidence.",
            system.get("confidence", "medium"), ["#/generic_analysis/analysis/systems"],
            {key: system.get(key) for key in ("file_count", "lines", "symbol_count", "import_references", "languages")},
            ["System boundaries require architectural review."], True,
        ))

    graph_summary = analysis.get("graphs", {}).get("summary", {})
    items.append(evidence(
        "module-graph-summary", "architecture", "fact",
        "Module and dependency graphs were built from imports and dependency declarations.",
        "high", ["#/generic_analysis/analysis/graphs/summary"], graph_summary,
        analysis.get("graphs", {}).get("limitations", []),
    ))
    boundary_summary = architecture.get("boundaries", {}).get("summary", {})
    if boundary_summary:
        items.append(evidence(
            "architectural-boundaries", "architecture", "inference",
            f"Boundary analysis found {boundary_summary.get('violations', 0)} inferred violations and {boundary_summary.get('cross_boundary_cycles', 0)} cross-boundary cycles.",
            "medium", ["#/generic_analysis/analysis/architecture/boundaries"], boundary_summary,
            ["Layers and intended boundaries are inferred from repository evidence."], True,
        ))

    coverage = quality.get("coverage", {})
    tests = quality.get("tests", {})
    linters = quality.get("linters", {})
    vulnerabilities = quality.get("vulnerabilities", {})
    items.extend([
        evidence("coverage", "quality", "fact", f"Coverage status is {coverage.get('status', 'not_found')}.", "high", ["#/generic_analysis/analysis/quality/coverage"], {"line_coverage_percent": coverage.get("line_coverage_percent")}, [coverage.get("note", "Missing coverage is not a passing result.")]),
        evidence("tests", "quality", "fact", f"Test-result status is {tests.get('status', 'not_found')}.", "high", ["#/generic_analysis/analysis/quality/tests"], {key: tests.get(key, 0) for key in ("total", "passed", "failed", "errors", "skipped")}, [tests.get("note", "RepoDNA imports test reports and does not execute tests.")]),
        evidence("linters", "quality", "fact", f"Linter-result status is {linters.get('status', 'not_found')}.", "high", ["#/generic_analysis/analysis/quality/linters"], {"issues": linters.get("issues"), "severities": linters.get("severities", {})}),
        evidence("vulnerabilities", "security", "fact", f"Security scanner status is {vulnerabilities.get('status', 'not_scanned')}.", "high", ["#/generic_analysis/analysis/quality/vulnerabilities"], {"findings": vulnerabilities.get("findings"), "severities": vulnerabilities.get("severities", {})}, ["not_scanned and not_resolved do not mean vulnerability-free."]),
    ])
    dependency_resolution = quality.get("dependency_resolution", {})
    if dependency_resolution:
        items.append(evidence(
            "dependency-resolution", "security", "fact",
            "Dependency vulnerability and license metadata was correlated conservatively.",
            "high", ["#/generic_analysis/analysis/quality/dependency_resolution/summary"],
            dependency_resolution.get("summary", {}), dependency_resolution.get("limitations", []),
        ))
        review_dependencies = [
            item for item in dependency_resolution.get("dependencies", [])
            if item.get("vulnerability_status") == "affected" or item.get("license_category") in {"review_required", "proprietary"}
        ][:MAX_DEPENDENCY_REVIEWS]
        for index, dependency in enumerate(review_dependencies, 1):
            items.append(evidence(
                f"dependency-review-{index}", "security", "fact",
                f"Dependency {dependency['name']} requires security or license review.",
                "high", ["#/generic_analysis/analysis/quality/dependency_resolution/dependencies"],
                {key: dependency.get(key) for key in ("vulnerability_status", "vulnerability_count", "vulnerabilities", "license_status", "license_category", "licenses")},
                ["License categories are triage signals, not legal advice."],
            ))

    health = analysis.get("health", {})
    if health:
        items.append(evidence(
            "repository-health", "health", "inference",
            f"Repository health score is {health.get('score')} with grade {health.get('grade')} and {health.get('assessment_coverage_percent', 0)}% assessment coverage.",
            "medium", ["#/generic_analysis/analysis/health"],
            {"score": health.get("score"), "grade": health.get("grade"), "assessment_coverage_percent": health.get("assessment_coverage_percent"), "model_version": health.get("version")},
            health.get("limitations", []),
        ))

    items.append(evidence(
        "git-scope", "contribution", "fact",
        f"Git evidence scope is {git_data.get('scope', 'repository')} with {git_data.get('contributors_count', 0)} contributors represented.",
        "high", ["#/generic_analysis/git"],
        {"author_filter": git_data.get("author_filter", ""), "contributors": git_data.get("contributors_count", 0), "churn": git_data.get("churn", {})},
        ["Git activity is not exclusive authorship or performance."],
    ))
    for index, contributor in enumerate(git_data.get("contributors", [])[:MAX_CONTRIBUTORS], 1):
        items.append(evidence(
            f"contributor-{index}", "collaboration", "fact",
            f"{contributor['name']} has {contributor['commits']} commits in the selected Git scope.",
            "high", ["#/generic_analysis/git/contributors"], contributor,
            ["Commit count is activity evidence, not ownership, quality, or performance."],
        ))
    for index, relationship in enumerate(analysis.get("author_system_ownership", {}).get("relationships", [])[:MAX_OWNERSHIP], 1):
        items.append(evidence(
            f"author-system-{index}", "contribution", "inference",
            f"{relationship['author']} ranks #{relationship['rank_in_system']} by historical activity in {relationship['system']}.",
            relationship.get("confidence", "low"), ["#/generic_analysis/analysis/author_system_ownership"],
            {key: relationship.get(key) for key in ("commits", "churn", "files_touched", "system_activity_share_percent", "author_focus_percent")},
            ["Activity ownership does not prove responsibility or authorship."], True,
        ))
    technical_impact = git_data.get("technical_impact", {})
    for index, contribution in enumerate(technical_impact.get("contributions", [])[:MAX_CONTRIBUTIONS], 1):
        items.append(evidence(
            f"technical-contribution-{index}", "contribution", "fact",
            f"Contribution {contribution['commit']} changed {contribution['touched']['files']} files with {contribution['touched']['churn']} lines of churn.",
            contribution.get("measurement_confidence", "medium"), ["#/generic_analysis/git/technical_impact/contributions"],
            {"date": contribution.get("date"), "author": contribution.get("author"), "systems": contribution.get("systems", []), "before": contribution.get("before", {}), "after": contribution.get("after", {}), "delta": contribution.get("delta", {}), "signals": contribution.get("signals", []), "touched": contribution.get("touched", {})},
            ["Before/after metrics cover changed source files, not complete repository snapshots."],
        ))

    achievement_data = analysis.get("personal_achievement_candidates", {})
    for candidate in achievement_data.get("candidates", []):
        items.append(evidence(
            f"achievement-{candidate['id']}", "career", "candidate",
            candidate["draft_statement"], candidate.get("confidence", "medium"),
            [f"#/generic_analysis{pointer[1:]}" if pointer.startswith("#/") else pointer for pointer in candidate.get("evidence", [])],
            candidate.get("metrics", {}),
            candidate.get("required_confirmations", []), True,
        ))

    risks = data.get("risks", {})
    items.append(evidence(
        "report-risks", "security", "fact",
        "RepoDNA recorded redacted security findings and ownership classifications requiring review.",
        "high", ["#/risks", "#/evidence/security_report"], risks,
        ["Potential-secret findings are pattern matches with values redacted and require human review."],
    ))

    kind_counts = Counter(item["kind"] for item in items)
    category_counts = Counter(item["category"] for item in items)
    return {
        "$schema": "./schema.json",
        "schema_version": "1.0.0",
        "artifact_type": "repodna_llm_evidence",
        "generated_at": data.get("generated_at"),
        "privacy": privacy,
        "repository": {"name": project.get("name"), "type": project.get("type"), "code_root": project.get("code_root")},
        "llm_contract": {
            "purpose": "Answer questions and draft documentation using traceable repository evidence.",
            "rules": [
                "Treat fact as observed repository data, inference as reviewable interpretation, and candidate as unpublished personal material.",
                "Never convert inference or candidate into fact without external confirmation.",
                "Never infer business impact, product outcome, formal responsibility, intent, or personal performance from Git activity.",
                "Preserve confidence, caveats, and evidence pointers when producing claims.",
                "State unknown when evidence is absent; missing scanner, coverage, or test reports are not passing results.",
            ],
            "citation_format": "Use evidence item id plus its report.json source and JSON pointer.",
        },
        "evidence_summary": {"items": len(items), "by_kind": dict(kind_counts), "by_category": dict(category_counts)},
        "evidence_items": items,
        "unknowns": [
            "Business purpose, users, and product outcomes unless externally supplied.",
            "Formal role, responsibility, intent, difficulty, and learning of each contributor.",
            "Code review decisions and pull-request discussion not present in local Git evidence.",
            "Runtime correctness and production behavior not established by static repository evidence.",
        ],
        "human_confirmation": {
            "achievement_status": achievement_data.get("status", "requires_author_filter"),
            "questions": [
                "What was the contributor's formal responsibility?",
                "Which detected systems were actually owned or led by the contributor?",
                "What technical decision or action did the contributor personally take?",
                "What user, product, delivery, quality, or business outcome was observed?",
                "Which evidence-backed candidate is accurate enough to approve?",
            ],
        },
        "source_manifest": {
            "canonical": "report/data/report.json",
            "generic": "report/data/generic-analysis.json",
            "notion": "notion/evidence.json",
            "portfolio": "portfolio/draft.json",
        },
        "truncation": {
            "systems": MAX_SYSTEMS,
            "author_system_relationships": MAX_OWNERSHIP,
            "technical_contributions": MAX_CONTRIBUTIONS,
            "dependency_review_items": MAX_DEPENDENCY_REVIEWS,
            "contributors": MAX_CONTRIBUTORS,
            "entrypoints": MAX_ENTRYPOINTS,
            "aggregate_counts_remain_available_in_summary_items": True,
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("json_path", type=Path)
    parser.add_argument("output_path", type=Path)
    parser.add_argument("--schema", type=Path, required=True)
    args = parser.parse_args()
    data = json.loads(args.json_path.read_text(encoding="utf-8"))
    output = build(data)
    try:
        from jsonschema import Draft202012Validator
    except ImportError as error:
        raise SystemExit("JSON Schema validation requires: pip install -r requirements-reporting.txt") from error
    schema = json.loads(args.schema.read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    errors = sorted(Draft202012Validator(schema).iter_errors(output), key=lambda item: list(item.absolute_path))
    if errors:
        details = "\n".join(f"- /{'/'.join(map(str, item.absolute_path))}: {item.message}" for item in errors[:20])
        raise SystemExit(f"LLM evidence violates schema {schema.get('$id', args.schema)}:\n{details}")
    args.output_path.parent.mkdir(parents=True, exist_ok=True)
    args.output_path.write_text(json.dumps(output, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
