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
    specialized = data.get("specialized_analysis", {})
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
            system.get("confidence_level", "medium"), ["#/generic_analysis/analysis/systems"],
            {**{key: system.get(key) for key in ("file_count", "lines", "symbol_count", "import_references", "languages")}, "confidence_score": system.get("confidence")},
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
        evidence("coverage", "quality", "fact", coverage.get("message") or f"Coverage status is {coverage.get('status', 'not_observed')}.", "high", ["#/generic_analysis/analysis/quality/coverage"], {"line_coverage_percent": coverage.get("line_coverage_percent")}, [coverage.get("note", "Missing coverage is not a passing result.")]),
        evidence("tests", "quality", "fact", tests.get("message") or f"Test-result status is {tests.get('status', 'not_observed')}.", "high", ["#/generic_analysis/analysis/quality/tests"], {key: tests.get(key) for key in ("total", "passed", "failed", "errors", "skipped")}, [tests.get("note", "RepoDNA imports test reports and does not execute tests.")]),
        evidence("linters", "quality", "fact", linters.get("message") or f"Linter-result status is {linters.get('status', 'not_observed')}.", "high", ["#/generic_analysis/analysis/quality/linters"], {"issues": linters.get("issues"), "severities": linters.get("severities", {})}),
        evidence("vulnerabilities", "security", "fact", vulnerabilities.get("message") or f"Security scanner status is {vulnerabilities.get('status', 'not_observed')}.", "high", ["#/generic_analysis/analysis/quality/vulnerabilities"], {"findings": vulnerabilities.get("findings"), "severities": vulnerabilities.get("severities", {})}, ["not_observed and not_resolved do not mean vulnerability-free."]),
    ])
    dependency_resolution = quality.get("dependency_resolution", {})
    dependency_inventory = analysis.get("dependency_inventory", {})
    if dependency_inventory:
        items.append(evidence(
            "lockfile-sbom", "technology", "fact",
            "A CycloneDX 1.6 SBOM was generated from supported repository lockfiles.",
            "high", ["#/generic_analysis/analysis/dependency_inventory/summary"],
            dependency_inventory.get("summary", {}), dependency_inventory.get("limitations", []),
        ))
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

    delivery = analysis.get("delivery", {})
    releases = delivery.get("releases", {})
    ci_analysis = delivery.get("ci", {})
    if releases:
        items.append(evidence(
            "local-release-history", "project", "fact",
            f"Local Git history contains {releases.get('summary', {}).get('release_count', 0)} release tags and {releases.get('unreleased', {}).get('commits', 0)} commits after the latest tag.",
            "high", ["#/generic_analysis/analysis/delivery/releases"],
            {"summary": releases.get("summary", {}), "unreleased": releases.get("unreleased", {})}, releases.get("limitations", []),
        ))
    if ci_analysis:
        items.append(evidence(
            "local-ci-configuration", "quality", "fact",
            f"Static analysis found {ci_analysis.get('summary', {}).get('workflow_count', 0)} CI workflows with {ci_analysis.get('summary', {}).get('job_count', 0)} jobs.",
            "high", ["#/generic_analysis/analysis/delivery/ci"],
            ci_analysis.get("summary", {}), ci_analysis.get("limitations", []),
        ))

    forge_activity = analysis.get("forge_activity", {})
    if forge_activity.get("status") in {"imported", "redacted_by_privacy_mode"}:
        items.append(evidence(
            "imported-forge-activity", "collaboration", "fact",
            f"The normalized {forge_activity.get('provider') or 'forge'} export contains {forge_activity.get('summary', {}).get('issues', 0)} issues, {forge_activity.get('summary', {}).get('pull_requests', 0)} pull/merge requests, and {forge_activity.get('summary', {}).get('releases', 0)} releases in the selected scope.",
            "high", ["#/generic_analysis/analysis/forge_activity/summary"],
            {"summary": forge_activity.get("summary", {}), "issue_metrics": forge_activity.get("issue_metrics", {}), "pull_request_metrics": forge_activity.get("pull_request_metrics", {}), "release_metrics": forge_activity.get("release_metrics", {})},
            forge_activity.get("limitations", []),
        ))
        for index, pull_request in enumerate(forge_activity.get("pull_requests", [])[:50], 1):
            items.append(evidence(
                f"imported-pull-request-{index}", "contribution", "fact",
                f"Imported pull/merge request #{pull_request.get('number')}: {pull_request.get('title')}",
                "high", ["#/generic_analysis/analysis/forge_activity/pull_requests"],
                {key: pull_request.get(key) for key in ("state", "draft", "created_at", "merged_at", "commits_count", "changed_files", "additions", "deletions", "review_comments_count", "selected_author_roles")},
                ["Provider participation is activity evidence, not proof of ownership or impact."],
            ))

    health = analysis.get("health", {})
    if health:
        items.append(evidence(
            "repository-health", "health", "inference",
            f"Repository health score is {health.get('score')} with grade {health.get('grade')} and {health.get('assessment_coverage_percent', 0)}% assessment coverage.",
            "medium", ["#/generic_analysis/analysis/health"],
            {"score": health.get("score"), "grade": health.get("grade"), "assessment_coverage_percent": health.get("assessment_coverage_percent"), "confidence": health.get("confidence"), "dimensions": health.get("dimensions", []), "model_version": health.get("version")},
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
    for index, system in enumerate(analysis.get("bus_factor_by_system", {}).get("systems", []), 1):
        items.append(evidence(
            f"bus-factor-{index}", "collaboration", "inference",
            f"{system['system']} has an estimated activity bus factor of {system['bus_factor']} at the 75% cumulative activity threshold.",
            system.get("confidence", "low"), ["#/generic_analysis/analysis/bus_factor_by_system"],
            {key: system.get(key) for key in ("bus_factor", "risk", "authors_with_activity", "total_commit_touches", "covered_activity_percent", "system_confidence")},
            ["This is historical activity concentration, not proof of exclusive knowledge, replaceability, or formal ownership."], True,
        ))
    for index, command in enumerate(analysis.get("onboarding", {}).get("commands", [])[:50], 1):
        suggested = command.get("classification") == "suggested"
        items.append(evidence(
            f"onboarding-command-{index}", "technology", "candidate" if suggested else "fact",
            f"Onboarding command: {command['command']} ({command.get('purpose', 'purpose unknown')}).",
            "medium" if suggested else "high", ["#/generic_analysis/analysis/onboarding/commands"],
            command, ["Suggested commands were not executed and require team confirmation."] if suggested else ["Declared command existence does not prove that all local prerequisites are installed."], suggested,
        ))
    unity = specialized.get("unity", analysis.get("unity", {}))
    for index, system in enumerate(unity.get("gameplay_systems", [])[:50], 1):
        items.append(evidence(
            f"unity-gameplay-{index}", "system", "inference",
            f"Unity gameplay category {system['name']} matched {system['file_count']} files with {system['confidence']} confidence.",
            system.get("confidence", "low"), ["#/specialized_analysis/unity/gameplay_systems"],
            {key: system.get(key) for key in ("score", "file_count", "primary_directories", "git")},
            ["Gameplay categories are inferred from paths, symbols, imports, and Git evidence and require confirmation."], True,
        ))
    for index, signal in enumerate(unity.get("signals", [])[:100], 1):
        items.append(evidence(
            f"unity-signal-{index}", "quality", "candidate",
            f"Unity review signal {signal['type']} was detected with {signal['confidence']} confidence.",
            signal.get("confidence", "low"), ["#/specialized_analysis/unity/signals"], signal,
            ["This is a heuristic signal, not a confirmed bug; validate with code review and profiling."], True,
        ))
    android = specialized.get("android", analysis.get("android", {}))
    if android.get("status") in {"assessed", "redacted_by_privacy_mode"}:
        items.append(evidence(
            "android-analysis-summary", "technology", "fact",
            f"Android analysis recorded {android.get('summary', {}).get('components', 0)} component signals, {android.get('summary', {}).get('screens', 0)} screens, and {android.get('summary', {}).get('permissions', 0)} declared permissions.",
            "high", ["#/specialized_analysis/android"], android.get("summary", {}),
            ["Static declarations do not prove runtime use or behavior."],
        ))
    for index, component in enumerate(android.get("components", [])[:100], 1):
        items.append(evidence(
            f"android-component-{index}", "system", "fact" if component.get("manifest") else "inference",
            f"Android {component['type']} evidence: {component['name']}.",
            "high" if component.get("manifest") else "medium", ["#/specialized_analysis/android/components"], component,
            ["Naming-based source component classification requires inheritance confirmation."], not bool(component.get("manifest")),
        ))
    flutter = specialized.get("flutter", analysis.get("flutter", {}))
    if flutter.get("status") in {"assessed", "redacted_by_privacy_mode"}:
        items.append(evidence(
            "flutter-analysis-summary", "technology", "fact",
            f"Verified Flutter analysis recorded {flutter.get('summary', {}).get('widgets', 0)} widgets, {flutter.get('summary', {}).get('screens', 0)} screens, and {flutter.get('summary', {}).get('routes', 0)} route signals.",
            "high", ["#/specialized_analysis/flutter"], flutter.get("summary", {}),
            ["Routes and architecture can be created dynamically and require runtime confirmation."],
        ))
    for index, manager in enumerate(flutter.get("state_management", [])[:20], 1):
        items.append(evidence(
            f"flutter-state-{index}", "architecture", "inference",
            f"Flutter state-management evidence matched {manager['name']} with {manager['confidence']} confidence.",
            manager.get("confidence", "medium"), ["#/specialized_analysis/flutter/state_management"], manager,
            ["Package presence does not prove consistent application-wide architecture."], True,
        ))
    godot = specialized.get("godot", analysis.get("godot", {}))
    if godot.get("status") in {"assessed", "redacted_by_privacy_mode"}:
        summary = godot.get("summary", {})
        items.append(evidence(
            "godot-analysis-summary", "technology", "fact",
            f"Godot analysis recorded {summary.get('scenes', 0)} scenes, {summary.get('scripts', 0)} scripts, {summary.get('autoloads', 0)} autoloads, and {summary.get('export_presets', 0)} export presets.",
            "high", ["#/specialized_analysis/godot"], summary,
            ["Static project files do not prove runtime behavior or successful exports."],
        ))
    for index, system in enumerate(godot.get("gameplay_systems", [])[:50], 1):
        items.append(evidence(
            f"godot-gameplay-{index}", "system", "inference",
            f"Godot gameplay category {system['name']} matched {system['file_count']} files with {system['confidence']} confidence.",
            system.get("confidence", "medium"), ["#/specialized_analysis/godot/gameplay_systems"], system,
            ["Gameplay categories are static evidence-based candidates and require human confirmation."], True,
        ))
    for index, signal in enumerate(godot.get("signals", [])[:100], 1):
        items.append(evidence(
            f"godot-signal-{index}", "quality", "candidate",
            f"Godot review signal {signal['type']} was detected with {signal['confidence']} confidence.",
            signal.get("confidence", "medium"), ["#/specialized_analysis/godot/signals"], signal,
            ["This is a heuristic signal, not a confirmed bug; validate with code review and profiling."], True,
        ))
    unreal = specialized.get("unreal", analysis.get("unreal", {}))
    if unreal.get("status") in {"assessed", "redacted_by_privacy_mode"}:
        summary = unreal.get("summary", {})
        items.append(evidence(
            "unreal-analysis-summary", "technology", "fact",
            f"Unreal analysis recorded {summary.get('modules', 0)} modules, {summary.get('source_files', 0)} source files, {summary.get('reflected_types', 0)} reflected types, {summary.get('blueprint_assets', 0)} Content assets, and {summary.get('maps', 0)} maps.",
            "high", ["#/specialized_analysis/unreal"], summary,
            ["Binary Blueprint graphs and map internals were not decoded."],
        ))
    for index, system in enumerate(unreal.get("gameplay_systems", [])[:50], 1):
        items.append(evidence(
            f"unreal-gameplay-{index}", "system", "inference",
            f"Unreal gameplay category {system['name']} matched {system['file_count']} files with {system['confidence']} confidence.",
            system.get("confidence", "medium"), ["#/specialized_analysis/unreal/gameplay_systems"], system,
            ["Gameplay categories are evidence-backed candidates requiring human confirmation."], True,
        ))
    for index, signal in enumerate(unreal.get("signals", [])[:100], 1):
        items.append(evidence(
            f"unreal-signal-{index}", "quality", "candidate",
            f"Unreal review signal {signal['type']} was detected with {signal['confidence']} confidence.",
            signal.get("confidence", "medium"), ["#/specialized_analysis/unreal/signals"], signal,
            ["This is a heuristic signal, not a confirmed bug; validate with code review and Unreal profiling tools."], True,
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
        "canonical_metrics": data.get("canonical_metrics", {}),
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
