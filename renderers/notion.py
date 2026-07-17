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

    project_facts = [
        fact(f"Repository classified as {project['type']}.", "report/data/report.json#/project/type"),
        fact(f"Detected code root: {project['code_root']}.", "report/data/report.json#/project/code_root"),
    ]
    if profile["csharp"]:
        project_facts.append(fact(
            f"Current tree contains {metrics['csharp_files']} C# files and {metrics['csharp_lines']} lines.",
            "report/data/report.json#/current_metrics",
        ))

    technology_facts = [
        fact(f"Project detector selected {project['type']}.", "report/data/report.json#/project/type")
    ]
    if profile["csharp"] and metrics["csharp_files"] > 0:
        technology_facts.append(fact("C# is present in the analyzed source tree.", "report/data/report.json#/current_metrics/csharp_files"))
    if profile["unity"]:
        technology_facts.append(fact("Unity project markers were detected.", "report/data/report.json#/analysis_profile/unity"))
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

    return {
        "schema_version": "1.0",
        "generated_at": data["generated_at"],
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
        }],
        "technologies": technology_facts,
        "collaboration_signals": [
            fact(
                f"Git history lists {collaboration['contributors']} contributor entries.",
                "report/data/report.json#/collaboration/contributors",
            )
        ],
        "personal_data": [],
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
