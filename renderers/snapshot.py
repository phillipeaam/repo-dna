#!/usr/bin/env python3

"""Create a compact, versioned analysis snapshot from the canonical report."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


SCHEMA_VERSION = "1.0.0"
SCHEMA_FILE = "analysis-snapshot-1.0.0.schema.json"


def _slug_time(value: str) -> str:
    return re.sub(r"[^0-9]+", "-", value).strip("-")


def build(data: dict[str, Any], commit: str, branch: str) -> dict[str, Any]:
    generic = data.get("generic_analysis", {})
    analysis = generic.get("analysis", {})
    architecture = analysis.get("architecture", {})
    quality = analysis.get("quality", {})
    git_data = generic.get("git", {})
    dependency_resolution = quality.get("dependency_resolution", {})
    generated_at = data.get("generated_at", "")
    return {
        "$schema": f"./{SCHEMA_FILE}",
        "schema_version": SCHEMA_VERSION,
        "artifact_type": "repodna_analysis_snapshot",
        "snapshot_id": f"{_slug_time(generated_at)}-{commit[:12] or 'uncommitted'}",
        "generated_at": generated_at,
        "repository": {
            "name": data.get("project", {}).get("name"),
            "type": data.get("project", {}).get("type"),
            "commit": commit,
            "branch": branch,
        },
        "scope": {
            "privacy_mode": data.get("privacy", {}).get("mode", "standard"),
            "author_filter": git_data.get("author_filter", ""),
            "git_scope": git_data.get("scope", "repository"),
            "source_included": data.get("privacy", {}).get("source_included", False),
        },
        "inventory": {
            "files": generic.get("file_count", 0),
            "languages": generic.get("languages", []),
            "configuration_files": generic.get("configuration_file_count", 0),
            "documentation_files": generic.get("documentation_file_count", 0),
            "test_files": generic.get("test_file_count", 0),
            "ci_cd_files": generic.get("ci_cd_file_count", 0),
            "docker_files": generic.get("docker_file_count", 0),
            "dependency_declarations": generic.get("dependencies", {}).get("total", 0),
        },
        "architecture": {
            "summary": architecture.get("summary", {}),
            "design_patterns": architecture.get("design_patterns", []),
            "parser_coverage": architecture.get("parser_coverage", []),
            "frameworks": analysis.get("frameworks", {}).get("detected", []),
            "graph_summary": analysis.get("graphs", {}).get("summary", {}),
        },
        "systems": [
            {key: system.get(key) for key in ("name", "confidence", "file_count", "lines", "symbol_count", "import_references", "languages")}
            for system in analysis.get("systems", [])
        ],
        "quality": {
            "coverage": {key: quality.get("coverage", {}).get(key) for key in ("status", "line_coverage_percent")},
            "tests": {key: quality.get("tests", {}).get(key) for key in ("status", "total", "passed", "failed", "errors", "skipped")},
            "linters": {key: quality.get("linters", {}).get(key) for key in ("status", "issues", "severities")},
            "vulnerabilities": {key: quality.get("vulnerabilities", {}).get(key) for key in ("status", "findings", "severities")},
            "dependencies": dependency_resolution.get("summary", {}),
        },
        "health": {
            "score": analysis.get("health", {}).get("score"),
            "grade": analysis.get("health", {}).get("grade"),
            "assessment_coverage_percent": analysis.get("health", {}).get("assessment_coverage_percent", 0),
            "model_version": analysis.get("health", {}).get("version"),
            "dimensions": analysis.get("health", {}).get("dimensions", []),
        },
        "git": {
            "contributors": git_data.get("contributors_count", 0),
            "churn": git_data.get("churn", {}),
            "hotspots": git_data.get("hotspots", [])[:50],
            "technical_impact_summary": git_data.get("technical_impact", {}).get("summary", {}),
            "author_system_ownership_summary": analysis.get("author_system_ownership", {}).get("summary", {}),
        },
        "risks": data.get("risks", {}),
        "provenance": {
            "canonical_source": "report/data/report.json",
            "collector_schema_version": generic.get("schema_version"),
            "canonical_schema_version": data.get("schema_version"),
        },
    }


def validate(document: dict[str, Any], schema_path: Path) -> None:
    try:
        from jsonschema import Draft202012Validator
    except ImportError as error:
        raise SystemExit("Snapshot validation requires: pip install -r requirements-reporting.txt") from error
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    errors = sorted(Draft202012Validator(schema).iter_errors(document), key=lambda item: list(item.absolute_path))
    if errors:
        details = "\n".join(f"- /{'/'.join(map(str, item.absolute_path))}: {item.message}" for item in errors[:20])
        raise SystemExit(f"Analysis snapshot violates schema {schema.get('$id', schema_path)}:\n{details}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("report_json", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--schema", type=Path, required=True)
    parser.add_argument("--commit", default="")
    parser.add_argument("--branch", default="")
    args = parser.parse_args()
    document = build(json.loads(args.report_json.read_text(encoding="utf-8")), args.commit, args.branch)
    validate(document, args.schema)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(document, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
