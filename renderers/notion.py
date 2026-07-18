#!/usr/bin/env python3

"""Build Notion-ready evidence JSON from canonical RepoDNA report data."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def fact(statement: str, evidence: str, confidence: str = "high") -> dict[str, Any]:
    return {
        "kind": "fact",
        "statement": statement,
        "evidence": [evidence],
        "confidence": confidence,
    }


def build(data: dict[str, Any]) -> dict[str, Any]:
    project = data["project"]
    profile = data["analysis_profile"]
    metrics = data["current_metrics"]
    history = data["history"]
    technologies = data["technologies"]
    systems = data["systems"]
    collaboration = data["collaboration"]
    generic = data.get("generic_analysis", {})
    framework_findings = generic.get("analysis", {}).get("frameworks", {}).get("detected", [])
    quality_findings = generic.get("analysis", {}).get("quality", {})
    activity_ownership = generic.get("analysis", {}).get("author_system_ownership", {})
    technical_impact = generic.get("git", {}).get("technical_impact", {})
    achievement_candidates = generic.get("analysis", {}).get("personal_achievement_candidates", {})

    project_facts = [
        fact(f"Repository classified as {project['type']}.", "report/data/report.json#/project/type"),
        fact(f"Detected code root: {project['code_root']}.", "report/data/report.json#/project/code_root"),
    ]
    if profile["csharp"]:
        project_facts.append(fact(
            f"Current tree contains {metrics['csharp_files']} C# files and {metrics['csharp_lines']} lines.",
            "report/data/report.json#/current_metrics",
        ))
    imported_tests = quality_findings.get("tests", {})
    if imported_tests.get("status") == "imported":
        project_facts.append(fact(
            f"Imported test reports contain {imported_tests.get('total', 0)} tests: {imported_tests.get('passed', 0)} passed, {imported_tests.get('failed', 0)} failed, and {imported_tests.get('skipped', 0)} skipped.",
            "report/data/report.json#/generic_analysis/analysis/quality/tests",
        ))
    imported_coverage = quality_findings.get("coverage", {})
    if imported_coverage.get("status") == "imported" and imported_coverage.get("line_coverage_percent") is not None:
        project_facts.append(fact(
            f"Imported coverage reports indicate {imported_coverage['line_coverage_percent']}% line coverage.",
            "report/data/report.json#/generic_analysis/analysis/quality/coverage",
        ))
    dependency_resolution = quality_findings.get("dependency_resolution", {})
    dependency_inventory = generic.get("analysis", {}).get("dependency_inventory", {})
    if dependency_inventory.get("summary", {}).get("lockfiles", 0):
        inventory_summary = dependency_inventory["summary"]
        project_facts.append(fact(
            f"RepoDNA parsed {inventory_summary.get('parsed_lockfiles', 0)} lockfiles and generated a CycloneDX SBOM with {inventory_summary.get('components', 0)} resolved components.",
            "report/data/report.json#/generic_analysis/analysis/dependency_inventory/summary",
        ))
    dependency_summary = dependency_resolution.get("summary", {})
    if dependency_summary.get("dependencies", 0):
        project_facts.append(fact(
            f"RepoDNA correlated {dependency_summary['dependencies']} dependency identities; {dependency_summary.get('affected_dependencies', 0)} have imported vulnerability findings.",
            "report/data/report.json#/generic_analysis/analysis/quality/dependency_resolution",
        ))
        project_facts.append(fact(
            f"Imported metadata resolved licenses for {dependency_summary.get('license_resolved', 0)} dependencies; {dependency_summary.get('license_unresolved', 0)} remain unresolved and {dependency_summary.get('license_review_required', 0)} require license review.",
            "report/data/report.json#/generic_analysis/analysis/quality/dependency_resolution/summary",
            "medium",
        ))

    delivery = generic.get("analysis", {}).get("delivery", {})
    release_summary = delivery.get("releases", {}).get("summary", {})
    if release_summary:
        project_facts.append(fact(
            f"Local Git tags describe {release_summary.get('release_count', 0)} releases; latest tag: {release_summary.get('latest_release') or 'none'}.",
            "report/data/report.json#/generic_analysis/analysis/delivery/releases/summary",
        ))
    ci_summary = delivery.get("ci", {}).get("summary", {})
    if ci_summary.get("workflow_count", 0):
        project_facts.append(fact(
            f"The repository versions {ci_summary['workflow_count']} CI workflows containing {ci_summary.get('job_count', 0)} detected jobs.",
            "report/data/report.json#/generic_analysis/analysis/delivery/ci/summary",
        ))

    technology_facts = [
        fact(f"Project detector selected {project['type']}.", "report/data/report.json#/project/type")
    ]
    if profile["csharp"] and metrics["csharp_files"] > 0:
        technology_facts.append(fact("C# is present in the analyzed source tree.", "report/data/report.json#/current_metrics/csharp_files"))
    if profile["unity"]:
        technology_facts.append(fact("Unity project markers were detected.", "report/data/report.json#/analysis_profile/unity"))
    if profile.get("godot"):
        godot = generic.get("analysis", {}).get("godot", {})
        summary = godot.get("summary", {})
        technology_facts.append(fact(
            f"Godot project markers were detected with {summary.get('scenes', 0)} scenes and {summary.get('scripts', 0)} scripts analyzed.",
            "report/data/report.json#/generic_analysis/analysis/godot",
        ))
    if profile.get("unreal"):
        unreal = generic.get("analysis", {}).get("unreal", {})
        summary = unreal.get("summary", {})
        technology_facts.append(fact(
            f"Unreal project markers were detected with {summary.get('modules', 0)} modules, {summary.get('source_files', 0)} C++ source files, and {summary.get('blueprint_assets', 0)} binary Content assets inventoried.",
            "report/data/report.json#/generic_analysis/analysis/unreal",
        ))
    if technologies["dependency_count"] > 0:
        technology_facts.append(fact(
            f"Dependency manifest contains approximately {technologies['dependency_count']} entries.",
            "report/data/report.json#/technologies/dependency_count",
            "medium",
        ))
    for language in generic.get("languages", []):
        technology_facts.append(fact(
            f"{language['name']} appears in {language['files']} files with approximately {language['lines']} lines.",
            "report/data/report.json#/generic_analysis/languages",
        ))
    for framework in framework_findings:
        technology_facts.append(fact(
            f"{framework['name']} framework evidence was detected with {framework['confidence']} confidence.",
            "report/data/report.json#/generic_analysis/analysis/frameworks",
            framework["confidence"],
        ))

    major_systems: list[dict[str, Any]] = []
    if systems["likely_system_files"] > 0:
        major_systems.append({
            "name": "Unconfirmed system candidates",
            "kind": "inference",
            "confidence": "low",
            "evidence": ["report/data/report.json#/systems/likely_system_files"],
            "files": [],
            "commits": [],
            "author_involvement": "unknown",
            "confirmation_required": True,
        })
    for module in generic.get("possible_modules", [])[:20]:
        major_systems.append({
            "name": module["path"],
            "kind": "inference",
            "confidence": "medium",
            "evidence": ["report/data/report.json#/generic_analysis/possible_modules"],
            "files": [],
            "commits": [],
            "file_count": module["file_count"],
            "languages": module["languages"],
            "author_involvement": "unknown",
            "confirmation_required": True,
        })

    forge_activity = generic.get("analysis", {}).get("forge_activity", {})
    forge_contributions = [
        {
            "kind": "fact", "statement": f"Imported pull/merge request #{item.get('number')}: {item.get('title')}",
            "evidence": ["report/data/report.json#/generic_analysis/analysis/forge_activity/pull_requests"],
            "state": item.get("state"), "merged_at": item.get("merged_at"), "changed_files": item.get("changed_files"),
            "additions": item.get("additions"), "deletions": item.get("deletions"), "selected_author_roles": item.get("selected_author_roles", []),
            "personal_attribution": "provider activity only", "confidence": "high", "confirmation_required": True,
        }
        for item in forge_activity.get("pull_requests", [])[:100]
    ]

    return {
        "$schema": "./notion-evidence-1.0.0.schema.json",
        "schema_version": "1.0",
        "generated_at": data["generated_at"],
        "canonical_metrics": data.get("canonical_metrics", {}),
        "classification_model": {
            "fact": "Directly supported by collected repository data.",
            "evidence": "A path or JSON pointer supporting a statement.",
            "inference": "A plausible interpretation that is not established as fact.",
            "personal_data": "Information that must be supplied by the person.",
            "confirmation_required": "A candidate claim that must not be published without confirmation.",
        },
        "about_project": {
            "facts": project_facts,
            "inferences": [],
            "unknowns": [
                "Business purpose and target users.",
                "The candidate's formal mission and responsibilities.",
                "Product impact of the detected engineering work.",
            ],
            "confidence": "high" if project["type"] != "Generic Git repository" else "medium",
        },
        "major_systems": major_systems,
        "engineering_contributions": [{
            "kind": "evidence",
            "statement": f"Selected Git scope contains {history['total_commits']} commits across {history['active_days']} active days.",
            "evidence": ["report/data/report.json#/history"],
            "personal_attribution": "unconfirmed",
            "confidence": "high",
            "confirmation_required": True,
        }] + [
            {
                "kind": "fact",
                "statement": f"Commit {item['commit']} changed {item['touched']['files']} files with {item['touched']['churn']} lines of churn; changed-source lines moved from {item['before']['source_lines']} to {item['after']['source_lines']} and estimated complexity moved from {item['before']['estimated_complexity']} to {item['after']['estimated_complexity']}.",
                "evidence": ["report/data/report.json#/generic_analysis/git/technical_impact"],
                "author": item["author"], "date": item["date"], "systems": item.get("systems", []),
                "technical_signals": item.get("signals", []), "confidence": item["measurement_confidence"],
                "impact_interpretation": "unconfirmed", "confirmation_required": True,
            }
            for item in technical_impact.get("contributions", [])[:100]
        ] + forge_contributions,
        "technologies": technology_facts,
        "collaboration_signals": [
            fact(
                f"Git history lists {collaboration['contributors']} contributor entries.",
                "report/data/report.json#/collaboration/contributors",
            )
        ] + [
            {
                "kind": "inference",
                "statement": f"{item['author']} ranks #{item['rank_in_system']} by historical file-touch activity in {item['system']}, with {item['commits']} commit touches across {item['files_touched']} files.",
                "evidence": ["report/data/report.json#/generic_analysis/analysis/author_system_ownership"],
                "confidence": item["confidence"],
                "system_activity_share_percent": item.get("system_activity_share_percent"),
                "author_focus_percent": item.get("author_focus_percent"),
                "confirmation_required": True,
            }
            for item in activity_ownership.get("relationships", [])[:50]
        ] + ([fact(
            f"Imported provider activity includes {forge_activity.get('collaboration', {}).get('unique_people', 0)} unique participants and {forge_activity.get('collaboration', {}).get('reviewers', 0)} reviewers.",
            "report/data/report.json#/generic_analysis/analysis/forge_activity/collaboration",
        )] if forge_activity.get("status") in {"imported", "redacted_by_privacy_mode"} else []),
        "personal_data": [],
        "personal_achievement_candidates": achievement_candidates,
        "claims_requiring_confirmation": [
            "Personal ownership of any detected system.",
            "Causal product or business impact.",
            "Performance, revenue, quality, or delivery improvements not measured in the repository.",
        ],
        "personal_confirmation_required": [
            "What was your formal mission?",
            "Which systems did you own?",
            "What did you learn?",
            "Which achievement had the greatest product impact?",
            "Which measurable result can be attributed to your work?",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("json_path", type=Path)
    parser.add_argument("output_path", type=Path)
    args = parser.parse_args()
    with args.json_path.open(encoding="utf-8") as source:
        data = json.load(source)
    args.output_path.parent.mkdir(parents=True, exist_ok=True)
    args.output_path.write_text(json.dumps(build(data), indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
