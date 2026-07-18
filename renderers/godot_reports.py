#!/usr/bin/env python3
"""Render Godot-specific text, HTML, and validated JSON reports."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any
from xml.sax.saxutils import escape


REPORTS = (
    ("project_settings.txt", "Project settings"), ("scenes.txt", "Scenes and nodes"),
    ("scripts.txt", "Scripts"), ("resources.txt", "Resources and dependencies"),
    ("autoloads_input.txt", "Autoloads and input"), ("plugins_exports.txt", "Plugins and exports"),
    ("gameplay_systems.txt", "Gameplay systems"), ("signals.txt", "Performance and risk signals"),
    ("localization_assets_tests.txt", "Localization, assets, native extensions, and tests"),
)


def text_report(title: str, rows: list[str], note: str = "") -> str:
    values = [title, "=" * len(title)]
    if note:
        values.extend([note, ""])
    values.extend(rows or ["No evidence detected."])
    return "\n".join(values) + "\n"


def render_text(data: dict[str, Any], output: Path) -> None:
    project, rendering = data.get("project", {}), data.get("rendering", {})
    output.joinpath("project_settings.txt").write_text(text_report("Godot project settings", [
        f"Project: {project.get('name', 'Unknown')}", f"Godot version signal: {project.get('godot_version', 'Unknown')}",
        f"Main scene: {project.get('main_scene') or 'Not configured'}", f"Renderer: {rendering.get('method', 'Unknown')}",
        f"Physics ticks per second: {project.get('physics_ticks_per_second') or 'Default/unknown'}",
        f"Features: {', '.join(map(str, project.get('features', []))) or 'none'}",
    ]), encoding="utf-8")
    scene_rows = []
    for item in data.get("scenes", []):
        root = item.get("root_node") or {}
        scene_rows.append(f"{item['path']} | root: {root.get('name', 'none')} ({root.get('type', 'unknown')}) | nodes: {item['node_count']} | connections: {item['connection_count']} | scripts: {len(item['scripts'])} | dependencies: {len(item['dependencies'])}")
        scene_rows.extend(f"  node | {node['name']} | {node['type']} | parent: {node['parent'] or '[root]'}" for node in item.get("nodes", [])[:100])
    output.joinpath("scenes.txt").write_text(text_report("Godot scenes and nodes", scene_rows, "Scene graphs are static .tscn evidence; runtime nodes may differ."), encoding="utf-8")
    output.joinpath("scripts.txt").write_text(text_report("Godot scripts", [
        f"{item['path']} | {item['language']} | class: {item.get('class_name') or 'none'} | extends: {item.get('extends') or 'unknown'} | functions: {len(item.get('functions', []))} | signals: {len(item.get('signals', []))} | exports: {item.get('exports', 0)} | RPC: {item.get('rpc_methods', 0)} | lines: {item.get('lines', 0)} | Git touches: {item.get('git_commit_touches', 0)}"
        for item in data.get("scripts", [])
    ]), encoding="utf-8")
    output.joinpath("resources.txt").write_text(text_report("Godot resources and dependencies", [
        f"Resource | {item['path']} | type: {item.get('type', 'Unknown')} | dependencies: {', '.join(item.get('dependencies', [])) or 'none'}" for item in data.get("resources", [])
    ] + [f"Edge | {item['source']} -> {item['target']} | {item['kind']}" for item in data.get("scene_graph", {}).get("edges", [])]), encoding="utf-8")
    output.joinpath("autoloads_input.txt").write_text(text_report("Godot autoloads and input actions", [
        f"Autoload | {item['name']} | {item['path']} | singleton: {item['singleton']}" for item in data.get("autoloads", [])
    ] + [f"Input action | {name}" for name in data.get("input_actions", [])]), encoding="utf-8")
    output.joinpath("plugins_exports.txt").write_text(text_report("Godot plugins and export presets", [
        f"Plugin | {item['name']} | {item['path']} | version: {item.get('version') or 'unknown'} | enabled: {item['enabled']}" for item in data.get("plugins", [])
    ] + [f"Export | {item['name']} | {item['platform']} | runnable: {item['runnable']} | filter: {item['export_filter']}" for item in data.get("exports", [])], "Export configuration does not prove that a build succeeds."), encoding="utf-8")
    output.joinpath("gameplay_systems.txt").write_text(text_report("Godot gameplay systems", [
        f"{item['name']} | {item['confidence']} | score: {item['evidence_score']} | files: {item['file_count']} | scenes: {len(item['scenes'])} | scripts: {len(item['scripts'])} | Git touches: {item['git_commit_touches']} | directories: {', '.join(item['primary_directories']) or 'root'}"
        for item in data.get("gameplay_systems", [])
    ], "System categories combine paths, scene nodes, scripts, and Git activity and require confirmation."), encoding="utf-8")
    output.joinpath("signals.txt").write_text(text_report("Godot performance and risk signals", [
        f"{item['type']} | {item['confidence']} | {item['path']} | occurrences: {item['occurrences']} | {item['rationale']}" for item in data.get("signals", [])
    ], "These are heuristic review signals, not confirmed bugs."), encoding="utf-8")
    localization, tests, assets = data.get("localization", {}), data.get("tests", {}), data.get("assets", {})
    output.joinpath("localization_assets_tests.txt").write_text(text_report("Godot localization, assets, native extensions, and tests", [
        *[f"Translation | {path}" for path in localization.get("translations", [])],
        *[f"Asset type | {extension} | {count}" for extension, count in assets.get("by_extension", {}).items()],
        *[f"Native extension | {path}" for path in data.get("native_extensions", [])],
        *[f"Test | {path}" for path in tests.get("files", [])],
        *[f"Test framework | {name}" for name in tests.get("frameworks", [])],
    ]), encoding="utf-8")


def html_document(data: dict[str, Any]) -> str:
    cards = "".join(f"<div><span>{escape(key.replace('_', ' ').title())}</span><strong>{value}</strong></div>" for key, value in data.get("summary", {}).items())
    links = "".join(f'<li><a href="{path}">{escape(label)}</a></li>' for path, label in REPORTS)
    style = "body{font:16px system-ui;max-width:1100px;margin:auto;padding:2rem;color:#172033}h1{color:#284b36}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:1rem}.cards div{border:1px solid #d8deea;border-radius:12px;padding:1rem}.cards span{display:block}.cards strong{display:block;text-align:right;font-size:1.5rem}a{color:#176b3a}.note{color:#536174}"
    return f"<!doctype html><html lang=en><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'><title>Godot analysis</title><style>{style}</style></head><body><h1>Godot analysis</h1><div class=cards>{cards}</div><h2>Reports</h2><ul>{links}</ul><p><a href=analysis.json>Open structured Godot analysis</a></p><p class=note>Evidence is collected statically without opening the Godot editor. Systems and risk findings require human review.</p></body></html>"


def validate(document: dict[str, Any], schema_path: Path) -> None:
    try:
        from jsonschema import Draft202012Validator
    except ImportError as error:
        raise SystemExit("Godot report validation requires: pip install -r requirements-reporting.txt") from error
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    errors = list(Draft202012Validator(schema).iter_errors(document))
    if errors:
        raise SystemExit("Godot analysis violates its JSON Schema:\n" + "\n".join(f"- {item.message}" for item in errors[:20]))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("report", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--schema", type=Path, required=True)
    args = parser.parse_args()
    report = json.loads(args.report.read_text(encoding="utf-8"))
    data = report.get("specialized_analysis", {}).get("godot", report.get("generic_analysis", {}).get("analysis", {}).get("godot", {}))
    if data.get("status") not in {"assessed", "redacted_by_privacy_mode"}:
        raise SystemExit("Canonical report does not contain a Godot analysis.")
    document = {"$schema": "./godot-analysis-1.0.0.schema.json", "schema_version": "1.0.0", "artifact_type": "repodna_godot_analysis", **data}
    validate(document, args.schema)
    args.output.mkdir(parents=True, exist_ok=True)
    args.output.joinpath("analysis.json").write_text(json.dumps(document, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    render_text(data, args.output)
    args.output.joinpath("index.html").write_text(html_document(data), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
