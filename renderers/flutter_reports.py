#!/usr/bin/env python3

"""Render Flutter-specific text, HTML, and validated JSON reports."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any
from xml.sax.saxutils import escape


def text_report(title: str, rows: list[str], note: str = "") -> str:
    values=[title,"="*len(title)]; values.extend(([note,""] if note else [])); values.extend(rows or ["No evidence detected."]); return "\n".join(values)+"\n"


def render_text(data: dict[str, Any], output: Path) -> None:
    deps=data.get("dependencies",{}); output.joinpath("dependencies.txt").write_text(text_report("Flutter dependencies",[f"runtime | {name} | {version}" for name,version in deps.get("runtime",{}).items()]+[f"development | {name} | {version}" for name,version in deps.get("development",{}).items()]),encoding="utf-8")
    output.joinpath("widgets.txt").write_text(text_report("Flutter widgets",[f"{item['name']} | {item['base']} | {item['path']} | Git commit touches: {item['git_commit_touches']}" for item in data.get("widgets",[])]),encoding="utf-8")
    output.joinpath("screens_routes.txt").write_text(text_report("Flutter screens and routes",[f"Screen | {item['name']} | {item['path']}" for item in data.get("screens",[])]+[f"Route | {item['route']} | {item['path']}" for item in data.get("routes",[])],"Routes created dynamically can require runtime confirmation."),encoding="utf-8")
    output.joinpath("state_management.txt").write_text(text_report("Flutter state management",[f"{item['name']} | {item['confidence']} | packages: {', '.join(item['packages'])} | evidence files: {len(item['evidence_files'])}" for item in data.get("state_management",[])],"Package presence is not proof of consistent architectural use."),encoding="utf-8")
    loc=data.get("localization",{}); output.joinpath("localization_assets.txt").write_text(text_report("Flutter localization and assets",[f"ARB: {path}" for path in loc.get("arb_files",[])]+([f"l10n config: {loc['l10n_config']}"] if loc.get("l10n_config") else [])+[f"Localization package: {name} {version}" for name,version in loc.get("packages",{}).items()]+[f"Asset: {path}" for path in data.get("assets",[])]),encoding="utf-8")
    output.joinpath("platform_channels.txt").write_text(text_report("Flutter platform channels",[f"{item['type']} | {item['name']} | Dart: {item['dart_path']} | Native matches: {', '.join(item['native_matches']) or 'none'}" for item in data.get("platform_channels",[])]+[f"Native bridge file: {path}" for path in data.get("native_bridges",{}).get("files",[])],"Channel-name matching is static evidence and does not prove compatible message contracts."),encoding="utf-8")
    flavors=data.get("flavors",{}); tests=data.get("tests",{}); output.joinpath("tests_flavors.txt").write_text(text_report("Flutter tests and flavors",[f"Unit test: {path}" for path in tests.get("unit",[])]+[f"Integration test: {path}" for path in tests.get("integration",[])]+[f"Android flavor: {name}" for name in flavors.get("android",[])]+[f"iOS scheme: {path}" for path in flavors.get("ios_schemes",[])]+[f"Dart entrypoint: {path}" for path in flavors.get("dart_entrypoints",[])],"Flavor detection is static; Flutter, Gradle, and Xcode were not executed."),encoding="utf-8")


def html(data: dict[str, Any]) -> str:
    cards="".join(f"<div><span>{escape(key.replace('_',' ').title())}</span><strong>{value}</strong></div>" for key,value in data.get("summary",{}).items())
    reports=(("dependencies.txt","Dependencies"),("widgets.txt","Widgets"),("screens_routes.txt","Screens and routes"),("state_management.txt","State management"),("localization_assets.txt","Localization and assets"),("platform_channels.txt","Platform channels"),("tests_flavors.txt","Tests and flavors"))
    links="".join(f"<li><a href={path}>{label}</a></li>" for path,label in reports); style="body{font:16px system-ui;max-width:1000px;margin:auto;padding:2rem;color:#172033}h1{color:#152b55}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:1rem}.cards div{border:1px solid #d8deea;border-radius:12px;padding:1rem}.cards span{display:block}.cards strong{display:block;text-align:right;font-size:1.5rem}a{color:#155eef}.note{color:#536174}"
    return f"<!doctype html><html lang=en><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'><title>Flutter analysis</title><style>{style}</style></head><body><h1>Flutter analysis</h1><div class=cards>{cards}</div><h2>Reports</h2><ul>{links}</ul><p><a href=analysis.json>Open structured Flutter analysis</a></p><p class=note>The Flutter profile was enabled from repository structure, never from a project name. Static evidence requires human review.</p></body></html>"


def validate(document: dict[str, Any], schema_path: Path) -> None:
    try: from jsonschema import Draft202012Validator
    except ImportError as error: raise SystemExit("Flutter report validation requires: pip install -r requirements-reporting.txt") from error
    schema=json.loads(schema_path.read_text(encoding="utf-8")); Draft202012Validator.check_schema(schema); errors=list(Draft202012Validator(schema).iter_errors(document))
    if errors: raise SystemExit("Flutter analysis violates its JSON Schema:\n"+"\n".join(f"- {item.message}" for item in errors[:20]))


def main() -> int:
    parser=argparse.ArgumentParser(); parser.add_argument("report",type=Path); parser.add_argument("output",type=Path); parser.add_argument("--schema",type=Path,required=True); args=parser.parse_args()
    report=json.loads(args.report.read_text(encoding="utf-8")); data=report.get("specialized_analysis",{}).get("flutter",report.get("generic_analysis",{}).get("analysis",{}).get("flutter",{}))
    if data.get("status") not in {"assessed","redacted_by_privacy_mode"}: raise SystemExit("Canonical report does not contain a Flutter analysis.")
    document={"$schema":"./flutter-analysis-1.0.0.schema.json","schema_version":"1.0.0","artifact_type":"repodna_flutter_analysis",**data}; validate(document,args.schema)
    args.output.mkdir(parents=True,exist_ok=True); args.output.joinpath("analysis.json").write_text(json.dumps(document,indent=2,ensure_ascii=False)+"\n",encoding="utf-8"); render_text(data,args.output); args.output.joinpath("index.html").write_text(html(data),encoding="utf-8"); return 0


if __name__ == "__main__": raise SystemExit(main())
