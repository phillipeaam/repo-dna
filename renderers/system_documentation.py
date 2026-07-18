#!/usr/bin/env python3

"""Render evidence-based documentation for every detected system."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any
from xml.sax.saxutils import escape


VERSION = "1.0.0"
SCHEMA_FILE = "system-documentation-1.0.0.schema.json"


def slug(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", value.casefold()).strip("-") or "system"


def belongs(path: str, root: str) -> bool:
    return root == "[root]" and "/" not in path or path == root or path.startswith(f"{root}/")


def build(data: dict[str, Any]) -> dict[str, Any]:
    generic = data.get("generic_analysis", {})
    analysis = generic.get("analysis", {})
    git_data = generic.get("git", {})
    ownership = analysis.get("author_system_ownership", {}).get("relationships", [])
    bus_factors = {item["system"]: item for item in analysis.get("bus_factor_by_system", {}).get("systems", [])}
    symbols = analysis.get("code", {}).get("symbols", [])
    entrypoints = analysis.get("architecture", {}).get("entrypoints", [])
    coupling = analysis.get("architecture", {}).get("coupling", {}).get("modules", [])
    evolution = git_data.get("system_evolution", {})
    documents = []
    used_slugs: dict[str, int] = {}
    for system in analysis.get("systems", []):
        name, root = system["name"], system.get("path", system["name"])
        base = slug(name); used_slugs[base] = used_slugs.get(base, 0) + 1
        identifier = base if used_slugs[base] == 1 else f"{base}-{used_slugs[base]}"
        system_symbols = [item for item in symbols if belongs(str(item.get("path", "")), root)][:100]
        system_entrypoints = [item for item in entrypoints if belongs(str(item.get("path", "")), root)]
        system_coupling = [item for item in coupling if item.get("module") == root]
        system_ownership = [item for item in ownership if item.get("system") == name]
        facts = [
            {"statement": f"{name} contains {system.get('file_count', 0)} source files and approximately {system.get('lines', 0)} lines.", "evidence": "#/metrics", "confidence": "high"},
            {"statement": f"Static analysis associated {system.get('symbol_count', 0)} symbols and {system.get('import_references', 0)} import references with this system.", "evidence": "#/metrics", "confidence": system.get("confidence", "medium")},
        ]
        documents.append({
            "$schema": f"../{SCHEMA_FILE}", "schema_version": VERSION,
            "artifact_type": "repodna_system_documentation", "id": identifier,
            "name": name, "path": root, "confidence": system.get("confidence", "medium"),
            "confirmation_required": system.get("confirmation_required", True),
            "metrics": {key: system.get(key, 0) for key in ("file_count", "lines", "symbol_count", "import_references")},
            "languages": system.get("languages", {}), "dependency_manifests": system.get("dependency_manifests", []),
            "entrypoints": system_entrypoints, "symbols": system_symbols,
            "architecture": {"coupling": system_coupling, "evidence": system.get("evidence", [])},
            "git_evolution": evolution.get(name, {}), "activity_ownership": system_ownership,
            "bus_factor": bus_factors.get(name), "facts": facts,
            "inferences": [{"statement": f"{name} is a system candidate inferred from a source boundary and code evidence.", "confidence": system.get("confidence", "medium"), "confirmation_required": True}],
            "unknowns": [
                "What business or product responsibility does this system have?",
                "Which interfaces and behaviors are intentionally public?",
                "Who currently maintains and reviews changes to this system?",
                "What operational constraints, failure modes, and runbooks apply?",
            ],
            "limitations": ["System boundaries are inferred and require human confirmation.", "Git activity does not prove formal ownership or exclusive knowledge."],
        })
    return {
        "$schema": f"./{SCHEMA_FILE}", "schema_version": VERSION,
        "artifact_type": "repodna_system_documentation_catalog",
        "project": {"name": data.get("project", {}).get("name"), "type": data.get("project", {}).get("type")},
        "generated_at": data.get("generated_at", ""), "system_count": len(documents), "systems": documents,
        "limitations": ["Documents contain repository evidence and explicit inferences; product purpose and current ownership require confirmation."],
    }


def validate(document: dict[str, Any], schema_path: Path) -> None:
    try:
        from jsonschema import Draft202012Validator
    except ImportError as error:
        raise SystemExit("System-documentation validation requires: pip install -r requirements-reporting.txt") from error
    schema = json.loads(schema_path.read_text(encoding="utf-8")); Draft202012Validator.check_schema(schema)
    errors = sorted(Draft202012Validator(schema).iter_errors(document), key=lambda item: list(item.absolute_path))
    if errors:
        raise SystemExit("System documentation violates its JSON Schema:\n" + "\n".join(f"- {item.message}" for item in errors[:20]))


STYLE = "body{font:16px system-ui;max-width:1100px;margin:auto;padding:2rem;color:#172033}h1,h2{color:#152b55}a{color:#155eef}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:1rem}.card,section{border:1px solid #d8deea;border-radius:12px;padding:1rem;margin:1rem 0}.n{text-align:right;font-size:1.5rem}table{width:100%;border-collapse:collapse}th,td{padding:.6rem;border-bottom:1px solid #d8deea;text-align:left}.note{color:#536174}"


def list_html(items: list[Any]) -> str:
    return "<ul>" + "".join(f"<li>{escape(str(item))}</li>" for item in items) + "</ul>"


def system_html(item: dict[str, Any]) -> str:
    cards = "".join(f'<div class=card>{escape(key.replace("_", " ").title())}<div class=n>{escape(str(value))}</div></div>' for key, value in item["metrics"].items())
    facts = list_html([fact["statement"] for fact in item["facts"]])
    owners = "".join(f"<tr><td>{escape(row['author'])}</td><td>{row['rank_in_system']}</td><td>{row['commits']}</td><td>{escape(str(row.get('system_activity_share_percent')))}</td><td>{escape(row['confidence'])}</td></tr>" for row in item["activity_ownership"])
    bus = item.get("bus_factor")
    bus_html = '<p class=note>Unavailable for this scope.</p>' if not bus else f"<p>Estimated factor: <strong>{bus['bus_factor']}</strong> · {escape(bus['risk'])} · {bus['covered_activity_percent']}% covered activity.</p>"
    symbol_items = [f"{value.get('name', 'Unknown')} · {value.get('kind', 'symbol')} · {value.get('path', '')}" for value in item["symbols"]]
    coupling_items = [f"{value.get('module', item['path'])}: afferent {value.get('afferent', 0)}, efferent {value.get('efferent', 0)}, instability {value.get('instability', 'unknown')}" for value in item["architecture"]["coupling"]]
    evolution_items = [f"{period}: {count} commit touches" for period, count in item["git_evolution"].items()]
    inference_items = [f"{value['statement']} ({value['confidence']} confidence; confirmation required)" for value in item["inferences"]]
    return f"<!doctype html><html lang=en><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'><title>{escape(item['name'])} · RepoDNA</title><style>{STYLE}</style></head><body><p><a href=../index.html>← System documentation</a></p><h1>{escape(item['name'])}</h1><p>Path: <code>{escape(item['path'])}</code> · detection confidence: <strong>{escape(item['confidence'])}</strong></p><div class=cards>{cards}</div><section><h2>Confirmed repository facts</h2>{facts}</section><section><h2>Languages and symbols</h2>{list_html([f'{name}: {count} files' for name, count in item['languages'].items()])}<h3>Representative symbols</h3>{list_html(symbol_items)}</section><section><h2>Dependencies and entrypoints</h2><h3>Dependency manifests</h3>{list_html(item['dependency_manifests'])}<h3>Entrypoints</h3>{list_html([entry.get('path', entry) for entry in item['entrypoints']])}</section><section><h2>Architecture evidence</h2><h3>Coupling</h3>{list_html(coupling_items)}<h3>Detection evidence</h3>{list_html(item['architecture']['evidence'])}</section><section><h2>Historical evolution</h2>{list_html(evolution_items)}</section><section><h2>Historical activity ownership</h2><table><tr><th>Author</th><th>Rank</th><th>Commit touches</th><th>Activity share</th><th>Confidence</th></tr>{owners}</table><h3>Bus factor</h3>{bus_html}</section><section><h2>Inferences requiring review</h2>{list_html(inference_items)}</section><section><h2>Unknowns requiring confirmation</h2>{list_html(item['unknowns'])}</section><p class=note>System boundaries, purpose, ownership, and impact require human review. <a href=../data/{item['id']}.json>Open structured JSON</a>.</p></body></html>"


def render(document: dict[str, Any], output_dir: Path) -> None:
    (output_dir / "systems").mkdir(parents=True, exist_ok=True); (output_dir / "data").mkdir(parents=True, exist_ok=True)
    links = []
    for item in document["systems"]:
        (output_dir / "systems" / f"{item['id']}.html").write_text(system_html(item), encoding="utf-8")
        (output_dir / "data" / f"{item['id']}.json").write_text(json.dumps(item, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        links.append(f"<li><a href=systems/{item['id']}.html>{escape(item['name'])}</a> · {item['metrics']['file_count']} files · {escape(item['confidence'])} confidence</li>")
    body = "".join(links) or "<li>No systems were detected.</li>"
    (output_dir / "index.html").write_text(f"<!doctype html><html lang=en><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'><title>System documentation</title><style>{STYLE}</style></head><body><h1>Structured system documentation</h1><p>{document['system_count']} detected systems. Facts are separated from inferences and unknowns.</p><ul>{body}</ul><p><a href=systems.json>Open the complete structured catalog</a></p></body></html>", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(); parser.add_argument("report", type=Path); parser.add_argument("output_dir", type=Path); parser.add_argument("--schema", required=True, type=Path)
    args = parser.parse_args(); document = build(json.loads(args.report.read_text(encoding="utf-8"))); validate(document, args.schema)
    args.output_dir.mkdir(parents=True, exist_ok=True); (args.output_dir / "systems.json").write_text(json.dumps(document, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"); render(document, args.output_dir)
    return 0


if __name__ == "__main__": raise SystemExit(main())
