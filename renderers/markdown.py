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

{table([
    ('C# files', metrics['csharp_files']),
    ('C# lines', metrics['csharp_lines']),
    ('Total commits', history['total_commits']),
    ('Contributors', collaboration['contributors']),
    ('Potential secret findings', risks['potential_secret_findings']),
])}
""",
    )

    write(
        output_dir,
        "project-overview.md",
        f"""# Project overview

| Field | Value |
|---|---|
| Repository | {project['name']} |
| Project type | {project['type']} |
| Product | {project['product']} |
| Company | {project['company']} |
| Code root | `{project['code_root']}` |
| Unity version | {project['unity_version']} |

## Current metrics

{table([(key.replace('_', ' ').title(), value) for key, value in metrics.items()])}
""",
    )

    write(output_dir, "architecture.md", "# Architecture\n\n" + table([
        (key.replace("_", " ").title(), value) for key, value in architecture.items()
    ]))
    write(output_dir, "technologies.md", "# Technologies\n\n" + table([
        (key.replace("_", " ").title(), value) for key, value in technologies.items()
    ]))
    write(output_dir, "systems.md", "# Systems\n\n" + table([
        (key.replace("_", " ").title(), value) for key, value in systems.items()
    ]))
    write(output_dir, "contribution.md", "# Contribution\n\n" + table([
        (key.replace("_", " ").title(), value) for key, value in history.items()
    ]))
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

Use the pages in this directory as the standardized review entry points. Detailed
raw evidence remains available in the legacy `project/` and `contribution/`
directories during the reporting migration.
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
