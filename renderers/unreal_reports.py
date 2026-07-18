#!/usr/bin/env python3
"""Render Unreal-specific text, HTML, and validated JSON reports."""
from __future__ import annotations
import argparse, json
from pathlib import Path
from typing import Any
from xml.sax.saxutils import escape

REPORTS = (("project_modules.txt", "Project, modules, and targets"), ("source_reflection.txt", "C++ and reflection"), ("plugins.txt", "Plugins"), ("content_maps.txt", "Content and maps"), ("configuration_input.txt", "Configuration and input"), ("tests.txt", "Tests"), ("gameplay_systems.txt", "Gameplay systems"), ("signals.txt", "Performance and risk signals"))

def report(title: str, rows: list[str], note: str = "") -> str:
    return "\n".join([title, "=" * len(title), *([note, ""] if note else []), *(rows or ["No evidence detected."])]) + "\n"

def render_text(data: dict[str, Any], out: Path) -> None:
    project = data.get("project", {})
    out.joinpath("project_modules.txt").write_text(report("Unreal project, modules, and targets", [f"Project | {project.get('path', 'unknown')} | engine: {project.get('engine_association') or 'not pinned'}", *[f"Module | {x['module']} | public: {', '.join(x['public_dependencies']) or 'none'} | private: {', '.join(x['private_dependencies']) or 'none'}" for x in data.get("modules", [])], *[f"Target | {x['name']} | {x['type']} | modules: {', '.join(x['modules']) or 'none'}" for x in data.get("targets", [])]], "Dependencies come from versioned Build.cs rules."), encoding="utf-8")
    out.joinpath("source_reflection.txt").write_text(report("Unreal C++ and reflection", [f"{x['path']} | lines: {x['lines']} | reflected: {len(x['reflected_types'])} | UFUNCTION: {x['ufunctions']} | UPROPERTY: {x['uproperties']} | RPC: {x['rpc_methods']} | replicated: {x['replicated_properties']} | Tick: {x['tick']} | Git touches: {x['git_commit_touches']}" for x in data.get("source", [])]), encoding="utf-8")
    out.joinpath("plugins.txt").write_text(report("Unreal plugins", [f"{x['name']} | {x['path']} | enabled by default: {x['enabled_by_default']} | modules: {len(x['modules'])}" for x in data.get("plugins", [])] + [f"Project plugin | {x['name']} | enabled: {x['enabled']}" for x in project.get("plugins", [])]), encoding="utf-8")
    assets = data.get("blueprints_assets", {})
    out.joinpath("content_maps.txt").write_text(report("Unreal Content assets and maps", [f"Asset count | {assets.get('count', 0)}", *[f"Naming prefix | {key} | {value}" for key, value in assets.get("naming_prefixes", {}).items()], *[f"Map | {path}" for path in data.get("maps", [])]], "Binary Content is inventoried by path and naming prefix; Blueprint graphs are not decoded."), encoding="utf-8")
    out.joinpath("configuration_input.txt").write_text(report("Unreal configuration and input", [*[f"Config | {x['path']} | sections: {len(x['sections'])} | keys: {len(x['keys'])}" for x in data.get("configuration", [])], f"Input declarations | {data.get('input', {}).get('count', 0)}", f"Platforms/targets | {', '.join(data.get('platforms', [])) or 'none'}"]), encoding="utf-8")
    out.joinpath("tests.txt").write_text(report("Unreal automation tests", [f"Automation macros | {data.get('tests', {}).get('automation_macros', 0)}", *[f"Test | {path}" for path in data.get("tests", {}).get("files", [])]]), encoding="utf-8")
    out.joinpath("gameplay_systems.txt").write_text(report("Unreal gameplay systems", [f"{x['name']} | {x['confidence']} | score: {x['evidence_score']} | files: {x['file_count']} | Git touches: {x['git_commit_touches']} | directories: {', '.join(x['primary_directories'])}" for x in data.get("gameplay_systems", [])], "Categories are evidence-backed candidates requiring human confirmation."), encoding="utf-8")
    out.joinpath("signals.txt").write_text(report("Unreal performance and risk signals", [f"{x['type']} | {x['confidence']} | {x['path']} | {x['rationale']}" for x in data.get("signals", [])], "These are heuristic review signals, not confirmed bugs."), encoding="utf-8")

def validate(doc: dict[str, Any], schema_path: Path) -> None:
    try: from jsonschema import Draft202012Validator
    except ImportError as error: raise SystemExit("Unreal report validation requires: pip install -r requirements-reporting.txt") from error
    schema = json.loads(schema_path.read_text(encoding="utf-8")); Draft202012Validator.check_schema(schema)
    errors = list(Draft202012Validator(schema).iter_errors(doc))
    if errors: raise SystemExit("Unreal analysis violates its JSON Schema:\n" + "\n".join(f"- {x.message}" for x in errors[:20]))

def main() -> int:
    parser = argparse.ArgumentParser(); parser.add_argument("report", type=Path); parser.add_argument("output", type=Path); parser.add_argument("--schema", type=Path, required=True); args = parser.parse_args()
    report = json.loads(args.report.read_text(encoding="utf-8")); data = report.get("specialized_analysis", {}).get("unreal", report.get("generic_analysis", {}).get("analysis", {}).get("unreal", {}))
    if data.get("status") not in {"assessed", "redacted_by_privacy_mode"}: raise SystemExit("Canonical report does not contain an Unreal analysis.")
    doc = {"$schema": "./unreal-analysis-1.0.0.schema.json", "schema_version": "1.0.0", "artifact_type": "repodna_unreal_analysis", **data}; validate(doc, args.schema)
    args.output.mkdir(parents=True, exist_ok=True); args.output.joinpath("analysis.json").write_text(json.dumps(doc, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"); render_text(data, args.output)
    cards = "".join(f"<div><span>{escape(k.replace('_',' ').title())}</span><strong>{v}</strong></div>" for k,v in data.get("summary", {}).items()); links = "".join(f'<li><a href="{p}">{escape(t)}</a></li>' for p,t in REPORTS)
    css = "body{font:16px system-ui;max-width:1100px;margin:auto;padding:2rem;color:#20242b}h1{color:#283b63}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:1rem}.cards div{border:1px solid #ccd3df;border-radius:12px;padding:1rem}.cards span{display:block}.cards strong{display:block;text-align:right;font-size:1.5rem}a{color:#315da8}.note{color:#596579}"
    args.output.joinpath("index.html").write_text(f"<!doctype html><html lang=en><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'><title>Unreal analysis</title><style>{css}</style></head><body><h1>Unreal analysis</h1><div class=cards>{cards}</div><h2>Reports</h2><ul>{links}</ul><p><a href=analysis.json>Open structured Unreal analysis</a></p><p class=note>Binary Blueprint and map internals require Unreal tooling. Systems and risk findings require review.</p></body></html>", encoding="utf-8")
    return 0
if __name__ == "__main__": raise SystemExit(main())
