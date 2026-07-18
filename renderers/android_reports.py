#!/usr/bin/env python3

"""Render Android-specific text, HTML, and validated JSON reports."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any
from xml.sax.saxutils import escape


def lines(title: str, rows: list[str], note: str = "") -> str:
    body = [title, "=" * len(title)]
    if note: body.extend([note, ""])
    body.extend(rows or ["No evidence detected."])
    return "\n".join(body) + "\n"


def component_rows(data: dict[str, Any]) -> list[str]:
    return [f"{item['type']} | {item['name']} | {item.get('path') or item.get('manifest')} | Git commit touches: {item.get('git_commit_touches', 0)}" for item in data.get("components", [])]


def render_text(data: dict[str, Any], output: Path) -> None:
    gradle = data.get("gradle", {})
    output.joinpath("components.txt").write_text(lines("Android components", component_rows(data), "Manifest declarations and Java/Kotlin naming evidence; inferred source components require confirmation."), encoding="utf-8")
    output.joinpath("dependencies.txt").write_text(lines("Android dependencies", [f"{value}" for value in gradle.get("dependencies", [])] + [f"Plugin: {value}" for value in gradle.get("plugins", [])]), encoding="utf-8")
    output.joinpath("permissions.txt").write_text(lines("Android permissions", data.get("permissions", []), "Declared permissions do not prove runtime use or grant status."), encoding="utf-8")
    output.joinpath("screens.txt").write_text(lines("Android screens", [f"{item['type']} | {item['name']} | {item.get('path')} | Git commit touches: {item.get('git_commit_touches', 0)}" for item in data.get("screens", [])] + [f"Layout: {path}" for path in data.get("resources", {}).get("layouts", [])] + [f"Navigation: {path}" for path in data.get("resources", {}).get("navigation", [])]), encoding="utf-8")
    output.joinpath("data_layer.txt").write_text(lines("Android data layer", [f"{name}: {'detected' if detected else 'not detected'}" for name, detected in data.get("data_layer", {}).get("technologies", {}).items()] + [f"File: {path}" for path in data.get("data_layer", {}).get("files", [])]), encoding="utf-8")
    output.joinpath("networking.txt").write_text(lines("Android networking", [f"{name}: {'detected' if detected else 'not detected'}" for name, detected in data.get("networking", {}).get("technologies", {}).items()] + [f"File: {path}" for path in data.get("networking", {}).get("files", [])]), encoding="utf-8")
    output.joinpath("build_variants.txt").write_text(lines("Android build variants", [f"Build type: {value}" for value in gradle.get("build_types", [])] + [f"Product flavor: {value}" for value in gradle.get("product_flavors", [])] + [f"Variant: {value}" for value in gradle.get("build_variants", [])], "Variants are statically approximated; Gradle was not executed."), encoding="utf-8")


def render_html(data: dict[str, Any]) -> str:
    summary = data.get("summary", {})
    cards = "".join(f"<div><span>{escape(key.replace('_',' ').title())}</span><strong>{value}</strong></div>" for key, value in summary.items())
    reports = [("components.txt","Components"),("dependencies.txt","Dependencies"),("permissions.txt","Permissions"),("screens.txt","Screens"),("data_layer.txt","Data layer"),("networking.txt","Networking"),("build_variants.txt","Build variants")]
    links = "".join(f"<li><a href={path}>{label}</a></li>" for path,label in reports)
    style="body{font:16px system-ui;max-width:1000px;margin:auto;padding:2rem;color:#172033}h1{color:#152b55}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:1rem}.cards div{border:1px solid #d8deea;border-radius:12px;padding:1rem}.cards span{display:block}.cards strong{display:block;text-align:right;font-size:1.5rem}a{color:#155eef}.note{color:#536174}"
    return f"<!doctype html><html lang=en><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'><title>Android analysis</title><style>{style}</style></head><body><h1>Android analysis</h1><div class=cards>{cards}</div><h2>Reports</h2><ul>{links}</ul><p><a href=analysis.json>Open structured Android analysis</a></p><p class=note>Static evidence and inferred components require human review. Technology detection does not prove runtime use.</p></body></html>"


def validate(data: dict[str, Any], schema_path: Path) -> None:
    try: from jsonschema import Draft202012Validator
    except ImportError as error: raise SystemExit("Android report validation requires: pip install -r requirements-reporting.txt") from error
    schema=json.loads(schema_path.read_text(encoding="utf-8")); Draft202012Validator.check_schema(schema)
    errors=list(Draft202012Validator(schema).iter_errors(data))
    if errors: raise SystemExit("Android analysis violates its JSON Schema:\n"+"\n".join(f"- {item.message}" for item in errors[:20]))


def main() -> int:
    parser=argparse.ArgumentParser(); parser.add_argument("report",type=Path); parser.add_argument("output",type=Path); parser.add_argument("--schema",type=Path,required=True); args=parser.parse_args()
    report=json.loads(args.report.read_text(encoding="utf-8")); data=report.get("generic_analysis",{}).get("analysis",{}).get("android",{})
    if data.get("status") not in {"assessed","redacted_by_privacy_mode"}: raise SystemExit("Canonical report does not contain an Android analysis.")
    document={"$schema":"./android-analysis-1.0.0.schema.json","schema_version":"1.0.0","artifact_type":"repodna_android_analysis",**data}
    validate(document,args.schema); args.output.mkdir(parents=True,exist_ok=True)
    args.output.joinpath("analysis.json").write_text(json.dumps(document,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    render_text(data,args.output); args.output.joinpath("index.html").write_text(render_html(data),encoding="utf-8"); return 0


if __name__ == "__main__": raise SystemExit(main())
