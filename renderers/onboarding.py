#!/usr/bin/env python3

"""Create a structured, LLM-ready and human-navigable onboarding dataset."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any
from xml.sax.saxutils import escape


VERSION = "1.0.0"
SCHEMA_FILE = "onboarding-dataset-1.0.0.schema.json"


def build(data: dict[str, Any]) -> dict[str, Any]:
    generic = data.get("generic_analysis", {})
    analysis = generic.get("analysis", {})
    architecture = analysis.get("architecture", {})
    graphs = analysis.get("graphs", {})
    onboarding = analysis.get("onboarding", {})
    systems = analysis.get("systems", [])
    return {
        "$schema": f"./{SCHEMA_FILE}", "schema_version": VERSION,
        "artifact_type": "repodna_onboarding_dataset", "generated_at": data.get("generated_at", ""),
        "project": {key: data.get("project", {}).get(key) for key in ("name", "type", "code_root")},
        "privacy_mode": data.get("privacy", {}).get("mode", "standard"),
        "canonical_metrics": data.get("canonical_metrics", {}),
        "start_here": {
            "entrypoints": architecture.get("entrypoints", []),
            "commands": onboarding.get("commands", []),
            "primary_documentation": generic.get("documentation_files", [])[:50],
        },
        "repository_map": {
            "modules": generic.get("possible_modules", [])[:50],
            "systems": [{key: item.get(key) for key in ("name", "path", "confidence", "file_count", "languages", "confirmation_required")} for item in systems],
            "module_graph_summary": graphs.get("summary", {}),
            "architectural_boundaries": architecture.get("boundaries", {}).get("summary", {}),
        },
        "engineering_workflow": {
            "configuration_files": generic.get("configuration_files", []),
            "test_files": generic.get("test_files", []),
            "ci_cd_files": generic.get("ci_cd_files", []),
            "docker_files": generic.get("docker_files", []),
            "dependency_manifests": generic.get("dependencies", {}).get("manifests", []),
            "quality_status": {name: analysis.get("quality", {}).get(name, {}).get("status") for name in ("coverage", "tests", "linters", "vulnerabilities")},
            "ci_summary": analysis.get("delivery", {}).get("ci", {}).get("summary", {}),
            "release_summary": analysis.get("delivery", {}).get("releases", {}).get("summary", {}),
            "unreleased_summary": analysis.get("delivery", {}).get("releases", {}).get("unreleased", {}),
        },
        "collaboration": {
            "contributors": generic.get("git", {}).get("contributors", []),
            "author_aliases_configured": generic.get("git", {}).get("author_aliases_configured", 0),
            "bus_factor_summary": analysis.get("bus_factor_by_system", {}).get("summary", {}),
        },
        "recommended_reading": [item["path"] for item in generic.get("largest_files", [])[:10]],
        "unknowns": [
            "Which local prerequisites and versions are mandatory?",
            "Which declared or suggested commands are the supported team workflow?",
            "Which external services, credentials, environment variables, and fixtures are required?",
            "Which system is the safest starting point for a first contribution?",
            "What review, release, rollback, and incident procedures does the team follow?",
        ],
        "limitations": onboarding.get("limitations", []) + ["Commands are documentation evidence and were not executed by RepoDNA.", "Repository structure cannot establish team conventions that are not versioned."],
    }


def validate(document: dict[str, Any], schema_path: Path) -> None:
    try:
        from jsonschema import Draft202012Validator
    except ImportError as error:
        raise SystemExit("Onboarding validation requires: pip install -r requirements-reporting.txt") from error
    schema = json.loads(schema_path.read_text(encoding="utf-8")); Draft202012Validator.check_schema(schema)
    errors = sorted(Draft202012Validator(schema).iter_errors(document), key=lambda item: list(item.absolute_path))
    if errors: raise SystemExit("Onboarding dataset violates its JSON Schema:\n" + "\n".join(f"- {item.message}" for item in errors[:20]))


def items(values: list[Any]) -> str:
    return "<ul>" + "".join(f"<li>{escape(str(value))}</li>" for value in values) + "</ul>"


def render(document: dict[str, Any]) -> str:
    commands = "".join(f"<tr><td><code>{escape(item['command'])}</code></td><td>{escape(item['purpose'])}</td><td>{escape(item['classification'])}</td><td>{escape(item['source'])}</td><td>{'Yes' if item['confirmation_required'] else 'No'}</td></tr>" for item in document["start_here"]["commands"])
    entrypoints = [f"{item.get('path', 'Unknown')} · {item.get('kind', item.get('evidence', 'entrypoint'))}" for item in document["start_here"]["entrypoints"]]
    systems = [f"{item['name']} · {item['file_count']} files · {item['confidence']} confidence" for item in document["repository_map"]["systems"]]
    workflow = document["engineering_workflow"]
    style = "body{font:16px system-ui;max-width:1100px;margin:auto;padding:2rem;color:#172033}h1,h2{color:#152b55}section{border:1px solid #d8deea;border-radius:12px;padding:1rem;margin:1rem 0}table{width:100%;border-collapse:collapse}th,td{padding:.6rem;border-bottom:1px solid #d8deea;text-align:left}.note{color:#536174}code{background:#eef3fb;padding:.15rem .3rem}"
    delivery = f"<p>CI workflows: <strong>{workflow.get('ci_summary', {}).get('workflow_count', 0)}</strong> · CI jobs: <strong>{workflow.get('ci_summary', {}).get('job_count', 0)}</strong> · Local releases: <strong>{workflow.get('release_summary', {}).get('release_count', 0)}</strong> · Unreleased commits: <strong>{workflow.get('unreleased_summary', {}).get('commits', 0)}</strong></p>"
    return f"<!doctype html><html lang=en><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'><title>Repository onboarding</title><style>{style}</style></head><body><h1>Repository onboarding dataset</h1><p>{escape(str(document['project']['name']))} · {escape(str(document['project']['type']))}</p><section><h2>Start here</h2><h3>Entrypoints</h3>{items(entrypoints)}<h3>Commands</h3><table><tr><th>Command</th><th>Purpose</th><th>Classification</th><th>Evidence</th><th>Confirm</th></tr>{commands}</table><p class=note>Suggested commands are stack conventions, were not executed, and require confirmation.</p></section><section><h2>Repository map</h2><h3>Systems</h3>{items(systems)}<h3>Modules</h3>{items([item['path'] for item in document['repository_map']['modules']])}</section><section><h2>Engineering workflow</h2>{delivery}<h3>Documentation</h3>{items(document['start_here']['primary_documentation'])}<h3>Configuration</h3>{items(workflow['configuration_files'])}<h3>Tests</h3>{items(workflow['test_files'])}<h3>CI/CD and containers</h3>{items(workflow['ci_cd_files'] + workflow['docker_files'])}</section><section><h2>Unknowns to ask the team</h2>{items(document['unknowns'])}</section><p><a href=dataset.json>Open structured onboarding JSON</a></p></body></html>"


def main() -> int:
    parser = argparse.ArgumentParser(); parser.add_argument("report", type=Path); parser.add_argument("output_dir", type=Path); parser.add_argument("--schema", required=True, type=Path)
    args = parser.parse_args(); document = build(json.loads(args.report.read_text(encoding="utf-8"))); validate(document, args.schema)
    args.output_dir.mkdir(parents=True, exist_ok=True); (args.output_dir / "dataset.json").write_text(json.dumps(document, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"); (args.output_dir / "index.html").write_text(render(document), encoding="utf-8"); return 0


if __name__ == "__main__": raise SystemExit(main())
