#!/usr/bin/env python3

"""Render the standardized Markdown report tree from canonical report JSON."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def load_data(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as source:
        return json.load(source)


def table(rows: list[tuple[str, Any]]) -> str:
    lines = ["| Metric | Value |", "|---|---:|"]
    lines.extend(f"| {label} | {value} |" for label, value in rows)
    return "\n".join(lines)


def labeled_rows(values: dict[str, Any], keys: list[str]) -> list[tuple[str, Any]]:
    return [(key.replace("_", " ").title(), values[key]) for key in keys]


def write(output_dir: Path, name: str, content: str) -> None:
    (output_dir / name).write_text(content.rstrip() + "\n", encoding="utf-8")


def render(data: dict[str, Any], output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    project = data["project"]
    metrics = data["current_metrics"]
    architecture = data["architecture"]
    technologies = data["technologies"]
    systems = data["systems"]
    history = data["history"]
    collaboration = data["collaboration"]
    risks = data["risks"]
    privacy = data["privacy"]
    profile = data.get("analysis_profile", {"unity": False, "csharp": True})
    generic = data.get("generic_analysis", {})

    executive_rows: list[tuple[str, Any]] = []
    if generic.get("available", True):
        executive_rows.extend([
            ("Files", generic.get("file_count", 0)),
            ("Languages", len(generic.get("languages", []))),
        ])
    if profile["csharp"]:
        executive_rows.extend([
            ("C# files", metrics["csharp_files"]),
            ("C# lines", metrics["csharp_lines"]),
        ])
    executive_rows.extend([
        ("Total commits", history["total_commits"]),
        ("Contributors", collaboration["contributors"]),
        ("Potential secret findings", risks["potential_secret_findings"]),
    ])

    overview_fields = [
        ("Repository", project["name"]),
        ("Project type", project["type"]),
        ("Code root", f"`{project['code_root']}`"),
    ]
    if profile["unity"]:
        overview_fields.extend([
            ("Product", project["product"]),
            ("Company", project["company"]),
            ("Unity version", project["unity_version"]),
        ])

    metric_keys: list[str] = []
    if profile["csharp"]:
        metric_keys.extend(["csharp_files", "csharp_lines"])
    if profile["unity"]:
        metric_keys.extend([
            "scenes", "prefabs", "animations", "animator_controllers", "shaders",
            "assembly_definitions", "uxml_files", "uss_files",
        ])

    if profile["unity"]:
        architecture_keys = list(architecture)
        technology_keys = list(technologies)
        system_keys = list(systems)
    elif profile["csharp"]:
        architecture_keys = [
            "interfaces", "architecture_signals", "networking_signals",
            "services_and_data_signals", "performance_signals", "technical_debt_markers",
        ]
        technology_keys = ["dependency_count"]
        system_keys = ["likely_system_files"]
    else:
        architecture_keys = []
        technology_keys = ["dependency_count"]
        system_keys = []

    generic_inventory = [
        ("Files", generic.get("file_count", 0)),
        ("Languages", len(generic.get("languages", []))),
        ("Configuration files", len(generic.get("configuration_files", []))),
        ("Documentation files", len(generic.get("documentation_files", []))),
        ("Test files", len(generic.get("test_files", []))),
        ("CI/CD files", len(generic.get("ci_cd_files", []))),
        ("Docker files", len(generic.get("docker_files", []))),
    ]
    language_rows = [
        (f"{item['name']} ({item['files']} files)", item["lines"])
        for item in generic.get("languages", [])
    ]
    module_rows = [
        (item["path"], item["file_count"]) for item in generic.get("possible_modules", [])[:20]
    ]
    hotspot_rows = [
        (item["path"], f"{item['commits']} commits / {item['churn']} churn")
        for item in generic.get("git", {}).get("hotspots", [])[:20]
    ]

    write(
        output_dir,
        "index.md",
        f"""# {project['name']} report

- [Executive summary](executive-summary.md)
- [Project overview](project-overview.md)
- [Architecture](architecture.md)
- [Technologies](technologies.md)
- [Systems](systems.md)
- [Contribution](contribution.md)
- [Collaboration](collaboration.md)
- [Risks](risks.md)
- [Notion evidence](notion-evidence.md)

Generated from `data/report.json` (schema {data['schema_version']}).
""",
    )

    write(
        output_dir,
        "executive-summary.md",
        f"""# Executive summary

**Project:** {project['name']}  
**Type:** {project['type']}  
**Privacy mode:** {privacy['mode']}  
**Source included:** {str(privacy['source_included']).lower()}

{table(executive_rows)}
""",
    )

    write(
        output_dir,
        "project-overview.md",
        f"""# Project overview

| Field | Value |
|---|---|
{chr(10).join(f'| {label} | {value} |' for label, value in overview_fields)}

## Current metrics

{table(labeled_rows(metrics, metric_keys)) if metric_keys else 'No specialized source metrics are available for this project type.'}

## Generic repository inventory

{table(generic_inventory)}
""",
    )

    write(output_dir, "architecture.md", "# Architecture\n\n" + (
        table(labeled_rows(architecture, architecture_keys)) if architecture_keys
        else ("## Possible modules\n\n" + table(module_rows) if module_rows else "No module candidates were detected.")
    ))
    write(output_dir, "technologies.md", "# Technologies\n\n" + table(
        labeled_rows(technologies, technology_keys)
    ) + ("\n\n## Languages\n\n" + table(language_rows) if language_rows else ""))
    write(output_dir, "systems.md", "# Systems\n\n" + (
        table(labeled_rows(systems, system_keys)) if system_keys
        else ("## Possible modules\n\n" + table(module_rows) if module_rows else "No system or module candidates were detected.")
    ))
    write(output_dir, "contribution.md", "# Contribution\n\n" + table([
        (key.replace("_", " ").title(), value) for key, value in history.items()
    ]) + ("\n\n## Hotspots\n\n" + table(hotspot_rows) if hotspot_rows else ""))
    write(output_dir, "collaboration.md", "# Collaboration\n\n" + table([
        (key.replace("_", " ").title(), value) for key, value in collaboration.items()
    ]))
    write(
        output_dir,
        "risks.md",
        "# Risks\n\n" + table([
            ("Potential secret findings", risks["potential_secret_findings"]),
            ("Ownership review required", risks["ownership_review_required"]),
        ]) + "\n\nSee `../security/potential_secrets.txt` and the ownership classification evidence.",
    )
    write(
        output_dir,
        "notion-evidence.md",
        """# Notion evidence

Structured evidence is available at `../notion/evidence.json`. It separates
facts, evidence, inferences, personal data, and claims requiring confirmation.

Detailed raw evidence remains available in the legacy `project/` and
`contribution/` directories during the reporting migration.
""",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("json_path", type=Path)
    parser.add_argument("output_dir", type=Path)
    args = parser.parse_args()
    render(load_data(args.json_path), args.output_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
