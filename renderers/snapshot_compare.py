#!/usr/bin/env python3

"""Compare two versioned RepoDNA analysis snapshots."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any
from xml.sax.saxutils import escape


SCHEMA_VERSION = "1.0.0"
SCHEMA_FILE = "analysis-comparison-1.0.0.schema.json"


def number(value: Any) -> float:
    return value if isinstance(value, (int, float)) and not isinstance(value, bool) else 0


def metric(before: Any, after: Any) -> dict[str, Any]:
    before_value, after_value = number(before), number(after)
    delta = after_value - before_value
    return {
        "before": before_value,
        "after": after_value,
        "delta": delta,
        "direction": "increased" if delta > 0 else "decreased" if delta < 0 else "unchanged",
    }


def identity(snapshot: dict[str, Any]) -> dict[str, Any]:
    repository = snapshot.get("repository", {})
    return {
        "snapshot_id": snapshot.get("snapshot_id", ""),
        "generated_at": snapshot.get("generated_at", ""),
        "commit": repository.get("commit", ""),
        "branch": repository.get("branch", ""),
    }


def major(version: Any) -> str:
    return str(version or "").split(".", 1)[0]


def named_comparison(before: list[dict[str, Any]], after: list[dict[str, Any]], fields: list[str]) -> list[dict[str, Any]]:
    before_map = {str(item.get("name")): item for item in before if item.get("name")}
    after_map = {str(item.get("name")): item for item in after if item.get("name")}
    rows = []
    for name in sorted(before_map.keys() | after_map.keys(), key=str.casefold):
        previous, current = before_map.get(name, {}), after_map.get(name, {})
        values = {field: metric(previous.get(field), current.get(field)) for field in fields}
        status = "added" if name not in before_map else "removed" if name not in after_map else (
            "changed" if any(item["delta"] for item in values.values()) else "unchanged"
        )
        rows.append({"name": name, "status": status, "metrics": values})
    return rows


def numeric_object(before: dict[str, Any], after: dict[str, Any]) -> dict[str, Any]:
    keys = {key for key, value in before.items() if isinstance(value, (int, float)) and not isinstance(value, bool)}
    keys |= {key for key, value in after.items() if isinstance(value, (int, float)) and not isinstance(value, bool)}
    return {key: metric(before.get(key), after.get(key)) for key in sorted(keys)}


def compatibility(baseline: dict[str, Any], current: dict[str, Any]) -> dict[str, Any]:
    warnings: list[str] = []
    schema_compatible = (
        baseline.get("artifact_type") == current.get("artifact_type") == "repodna_analysis_snapshot"
        and major(baseline.get("schema_version")) == major(current.get("schema_version")) == "1"
    )
    if not schema_compatible:
        warnings.append("Snapshot schema major versions are incompatible.")
    for key, label in (("privacy_mode", "privacy mode"), ("author_filter", "author filter"), ("git_scope", "Git scope")):
        if baseline.get("scope", {}).get(key) != current.get("scope", {}).get(key):
            warnings.append(f"The {label} differs between snapshots.")
    if baseline.get("health", {}).get("model_version") != current.get("health", {}).get("model_version"):
        warnings.append("The health-score model version differs between snapshots.")
    for key, label in (("name", "repository name"), ("type", "project type")):
        if baseline.get("repository", {}).get(key) != current.get("repository", {}).get(key):
            warnings.append(f"The {label} differs between snapshots.")
    comparable = schema_compatible and not warnings
    return {"comparable": comparable, "schema_compatible": schema_compatible, "warnings": warnings}


def build(current: dict[str, Any], baseline: dict[str, Any] | None = None) -> dict[str, Any]:
    document: dict[str, Any] = {
        "$schema": f"./{SCHEMA_FILE}",
        "schema_version": SCHEMA_VERSION,
        "artifact_type": "repodna_analysis_comparison",
        "status": "no_baseline",
        "baseline": None,
        "current": identity(current),
        "compatibility": {"comparable": False, "schema_compatible": True, "warnings": ["No previous snapshot was available."]},
        "period": {"from": None, "to": current.get("generated_at", "")},
        "inventory": {}, "languages": [], "architecture": {}, "systems": [],
        "quality": {}, "health": {}, "git": {}, "risks": {}, "changes": [],
        "limitations": ["Deltas describe repository evidence; they do not prove improvement, regression, causality, or personal impact."],
    }
    if baseline is None:
        return document
    check = compatibility(baseline, current)
    document.update({
        "status": "compared" if check["comparable"] else "incompatible_schema" if not check["schema_compatible"] else "scope_mismatch",
        "baseline": identity(baseline), "compatibility": check,
        "period": {"from": baseline.get("generated_at", ""), "to": current.get("generated_at", "")},
    })
    if not check["schema_compatible"]:
        return document
    inventory_keys = ["files", "configuration_files", "documentation_files", "test_files", "ci_cd_files", "docker_files", "dependency_declarations"]
    document["inventory"] = {key: metric(baseline.get("inventory", {}).get(key), current.get("inventory", {}).get(key)) for key in inventory_keys}
    document["languages"] = named_comparison(baseline.get("inventory", {}).get("languages", []), current.get("inventory", {}).get("languages", []), ["files", "lines"])
    document["systems"] = named_comparison(baseline.get("systems", []), current.get("systems", []), ["file_count", "lines", "symbol_count", "import_references"])
    document["architecture"] = {
        "summary": numeric_object(baseline.get("architecture", {}).get("summary", {}), current.get("architecture", {}).get("summary", {})),
        "graph_summary": numeric_object(baseline.get("architecture", {}).get("graph_summary", {}), current.get("architecture", {}).get("graph_summary", {})),
        "design_patterns": named_comparison(baseline.get("architecture", {}).get("design_patterns", []), current.get("architecture", {}).get("design_patterns", []), ["matches"]),
    }
    before_quality, after_quality = baseline.get("quality", {}), current.get("quality", {})
    document["quality"] = {
        "coverage_percent": metric(before_quality.get("coverage", {}).get("line_coverage_percent"), after_quality.get("coverage", {}).get("line_coverage_percent")),
        "tests": numeric_object(before_quality.get("tests", {}), after_quality.get("tests", {})),
        "linter_issues": metric(before_quality.get("linters", {}).get("issues"), after_quality.get("linters", {}).get("issues")),
        "vulnerability_findings": metric(before_quality.get("vulnerabilities", {}).get("findings"), after_quality.get("vulnerabilities", {}).get("findings")),
        "dependencies": numeric_object(before_quality.get("dependencies", {}), after_quality.get("dependencies", {})),
    }
    document["health"] = {
        "score": metric(baseline.get("health", {}).get("score"), current.get("health", {}).get("score")),
        "assessment_coverage_percent": metric(baseline.get("health", {}).get("assessment_coverage_percent"), current.get("health", {}).get("assessment_coverage_percent")),
        "grade_before": baseline.get("health", {}).get("grade"), "grade_after": current.get("health", {}).get("grade"),
    }
    document["git"] = {
        "contributors": metric(baseline.get("git", {}).get("contributors"), current.get("git", {}).get("contributors")),
        "churn": numeric_object(baseline.get("git", {}).get("churn", {}), current.get("git", {}).get("churn", {})),
        "technical_impact_summary": numeric_object(baseline.get("git", {}).get("technical_impact_summary", {}), current.get("git", {}).get("technical_impact_summary", {})),
    }
    document["risks"] = numeric_object(baseline.get("risks", {}), current.get("risks", {}))
    changes = []
    for category, values in (("inventory", document["inventory"]), ("health", {k: v for k, v in document["health"].items() if isinstance(v, dict)}), ("git", {"contributors": document["git"]["contributors"]}), ("risks", document["risks"])):
        for name, value in values.items():
            if value["delta"]:
                changes.append({"category": category, "metric": name, **value})
    document["changes"] = changes
    return document


def validate(document: dict[str, Any], schema_path: Path) -> None:
    try:
        from jsonschema import Draft202012Validator
    except ImportError as error:
        raise SystemExit("Comparison validation requires: pip install -r requirements-reporting.txt") from error
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    errors = sorted(Draft202012Validator(schema).iter_errors(document), key=lambda item: list(item.absolute_path))
    if errors:
        raise SystemExit("Comparison violates its JSON Schema:\n" + "\n".join(f"- {item.message}" for item in errors[:20]))


def render(document: dict[str, Any]) -> str:
    esc = lambda value: escape(str(value))
    def rows(values: dict[str, Any]) -> str:
        return "".join(f"<tr><td>{esc(name.replace('_', ' ').title())}</td><td class=n>{esc(value['before'])}</td><td class=n>{esc(value['after'])}</td><td class=n>{esc(value['delta'])}</td><td>{esc(value['direction'])}</td></tr>" for name, value in values.items())
    warnings = "".join(f"<li>{esc(item)}</li>" for item in document["compatibility"]["warnings"])
    inventory = rows(document.get("inventory", {})) or '<tr><td colspan="5">No comparable baseline data.</td></tr>'
    changes = rows({f"{item['category']} / {item['metric']}": item for item in document.get("changes", [])}) or '<tr><td colspan="5">No numeric changes detected.</td></tr>'
    def named_rows(items: list[dict[str, Any]], primary: str) -> str:
        result = []
        for item in items:
            value = item.get("metrics", {}).get(primary, metric(0, 0))
            result.append(f"<tr><td>{esc(item['name'])}</td><td>{esc(item['status'])}</td><td class=n>{esc(value['before'])}</td><td class=n>{esc(value['after'])}</td><td class=n>{esc(value['delta'])}</td></tr>")
        return "".join(result) or '<tr><td colspan="5">No entries available.</td></tr>'
    languages = named_rows(document.get("languages", []), "lines")
    systems = named_rows(document.get("systems", []), "file_count")
    return f"""<!doctype html><html lang=en><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'><title>RepoDNA period comparison</title><style>body{{font:16px system-ui;max-width:1100px;margin:auto;padding:2rem;color:#172033}}h1,h2{{color:#152b55}}.status{{padding:1rem;background:#eef3fb;border-left:4px solid #3769b0}}table{{border-collapse:collapse;width:100%;margin:1rem 0 2rem}}th,td{{padding:.65rem;border-bottom:1px solid #d8deea;text-align:left}}.n{{text-align:right;font-variant-numeric:tabular-nums}}code{{background:#eef1f6;padding:.15rem .3rem}}</style></head><body><h1>Period comparison</h1><div class=status><strong>Status:</strong> {esc(document['status'])}<br><strong>Period:</strong> {esc(document['period']['from'] or 'No baseline')} → {esc(document['period']['to'])}</div><h2>Compatibility</h2><ul>{warnings or '<li>Scopes and schema versions are compatible.</li>'}</ul><h2>Repository inventory</h2><table><thead><tr><th>Metric</th><th class=n>Before</th><th class=n>After</th><th class=n>Delta</th><th>Direction</th></tr></thead><tbody>{inventory}</tbody></table><h2>Languages</h2><table><thead><tr><th>Language</th><th>Status</th><th class=n>Lines before</th><th class=n>Lines after</th><th class=n>Delta</th></tr></thead><tbody>{languages}</tbody></table><h2>Systems</h2><table><thead><tr><th>System</th><th>Status</th><th class=n>Files before</th><th class=n>Files after</th><th class=n>Delta</th></tr></thead><tbody>{systems}</tbody></table><h2>Numeric changes</h2><table><thead><tr><th>Metric</th><th class=n>Before</th><th class=n>After</th><th class=n>Delta</th><th>Direction</th></tr></thead><tbody>{changes}</tbody></table><p>Deltas are factual signals, not automatic quality judgments. See <code>comparison.json</code> for all structured evidence.</p></body></html>"""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("current", type=Path); parser.add_argument("output_json", type=Path); parser.add_argument("output_html", type=Path)
    parser.add_argument("--baseline", type=Path); parser.add_argument("--schema", type=Path, required=True)
    args = parser.parse_args()
    current = json.loads(args.current.read_text(encoding="utf-8"))
    baseline = json.loads(args.baseline.read_text(encoding="utf-8")) if args.baseline else None
    document = build(current, baseline); validate(document, args.schema)
    args.output_json.parent.mkdir(parents=True, exist_ok=True)
    args.output_json.write_text(json.dumps(document, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    args.output_html.write_text(render(document), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
