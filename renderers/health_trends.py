#!/usr/bin/env python3

"""Build a versioned health-score time series from analysis snapshots."""

from __future__ import annotations

import argparse
import json
from datetime import datetime
from pathlib import Path
from typing import Any
from xml.sax.saxutils import escape


SCHEMA_VERSION = "1.0.0"
SCHEMA_FILE = "health-trends-1.0.0.schema.json"


def parse_time(value: Any) -> datetime:
    text = str(value or "").replace("Z", "+00:00")
    try:
        return datetime.fromisoformat(text)
    except ValueError:
        return datetime.min


def point(snapshot: dict[str, Any]) -> dict[str, Any]:
    health = snapshot.get("health", {})
    repository = snapshot.get("repository", {})
    return {
        "snapshot_id": snapshot.get("snapshot_id", ""),
        "generated_at": snapshot.get("generated_at", ""),
        "commit": repository.get("commit", ""),
        "score": health.get("score"),
        "grade": health.get("grade"),
        "assessment_coverage_percent": health.get("assessment_coverage_percent", 0),
        "dimensions": health.get("dimensions", []),
    }


def incompatibilities(reference: dict[str, Any], candidate: dict[str, Any]) -> list[str]:
    reasons = []
    if candidate.get("artifact_type") != "repodna_analysis_snapshot":
        return ["not an analysis snapshot"]
    if str(candidate.get("schema_version", "")).split(".")[0] != str(reference.get("schema_version", "")).split(".")[0]:
        reasons.append("snapshot schema major version differs")
    for key, label in (("name", "repository name"), ("type", "project type")):
        if candidate.get("repository", {}).get(key) != reference.get("repository", {}).get(key):
            reasons.append(f"{label} differs")
    for key, label in (("privacy_mode", "privacy mode"), ("author_filter", "author filter"), ("git_scope", "Git scope")):
        if candidate.get("scope", {}).get(key) != reference.get("scope", {}).get(key):
            reasons.append(f"{label} differs")
    if candidate.get("health", {}).get("model_version") != reference.get("health", {}).get("model_version"):
        reasons.append("health model version differs")
    if not isinstance(candidate.get("health", {}).get("score"), (int, float)):
        reasons.append("health score is unavailable")
    return reasons


def build(current: dict[str, Any], historical: list[tuple[str, dict[str, Any]]]) -> dict[str, Any]:
    # Process the current run last so it wins when a persisted snapshot has the
    # same stable identifier.
    candidates = [*historical, ("current", current)]
    accepted: dict[str, dict[str, Any]] = {}
    excluded = []
    for source, snapshot in candidates:
        reasons = incompatibilities(current, snapshot)
        identifier = str(snapshot.get("snapshot_id") or source)
        if reasons:
            excluded.append({"source": source, "snapshot_id": identifier, "reasons": reasons})
        else:
            accepted[identifier] = point(snapshot)
    points = sorted(accepted.values(), key=lambda item: (parse_time(item["generated_at"]), item["snapshot_id"]))
    status = "available" if len(points) >= 2 else "insufficient_history"
    summary: dict[str, Any] = {"point_count": len(points), "first_score": None, "latest_score": None, "delta": None, "direction": "unavailable"}
    if points:
        first, latest = points[0]["score"], points[-1]["score"]
        delta = round(latest - first, 2) if len(points) >= 2 else 0
        summary.update({"first_score": first, "latest_score": latest, "delta": delta, "direction": "increased" if delta > 0 else "decreased" if delta < 0 else "unchanged"})
    return {
        "$schema": f"./{SCHEMA_FILE}", "schema_version": SCHEMA_VERSION,
        "artifact_type": "repodna_health_trends", "status": status,
        "repository": {key: current.get("repository", {}).get(key) for key in ("name", "type")},
        "scope": current.get("scope", {}), "health_model_version": current.get("health", {}).get("model_version"),
        "summary": summary, "points": points, "excluded_snapshots": excluded,
        "limitations": [
            "Score direction is descriptive and does not by itself prove repository improvement or regression.",
            "The series includes only snapshots with compatible repository, scope, schema major version, and health model.",
            "Changes in assessment coverage can affect interpretation of score changes.",
        ],
    }


def validate(document: dict[str, Any], schema_path: Path) -> None:
    try:
        from jsonschema import Draft202012Validator
    except ImportError as error:
        raise SystemExit("Health-trend validation requires: pip install -r requirements-reporting.txt") from error
    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    errors = sorted(Draft202012Validator(schema).iter_errors(document), key=lambda item: list(item.absolute_path))
    if errors:
        raise SystemExit("Health trends violate their JSON Schema:\n" + "\n".join(f"- {item.message}" for item in errors[:20]))


def render_html(document: dict[str, Any], has_chart: bool) -> str:
    rows = "".join(
        f"<tr><td>{escape(str(item['generated_at']))}</td><td class=n>{escape(str(item['score']))}</td><td>{escape(str(item['grade']))}</td><td class=n>{escape(str(item['assessment_coverage_percent']))}%</td><td><code>{escape(str(item['commit'])[:12])}</code></td></tr>"
        for item in document["points"]
    ) or '<tr><td colspan="5">No compatible health points.</td></tr>'
    excluded = "".join(f"<li>{escape(item['snapshot_id'])}: {escape(', '.join(item['reasons']))}</li>" for item in document["excluded_snapshots"])
    chart = '<img src="health-score-trend.png" alt="Health score trend">' if has_chart else '<p class="note">PNG chart unavailable. Install matplotlib to generate it.</p>'
    summary = document["summary"]
    return f"""<!doctype html><html lang=en><head><meta charset=utf-8><meta name=viewport content='width=device-width,initial-scale=1'><title>Health score trends</title><style>body{{font:16px system-ui;max-width:1050px;margin:auto;padding:2rem;color:#172033}}h1,h2{{color:#152b55}}.cards{{display:flex;gap:1rem;flex-wrap:wrap}}.card{{background:#eef3fb;padding:1rem;min-width:150px}}table{{border-collapse:collapse;width:100%;margin:1rem 0 2rem}}th,td{{padding:.65rem;border-bottom:1px solid #d8deea;text-align:left}}.n{{text-align:right;font-variant-numeric:tabular-nums}}img{{max-width:100%;height:auto}}.note{{color:#536174}}</style></head><body><h1>Health score trends</h1><div class=cards><div class=card><strong>Points</strong><br>{summary['point_count']}</div><div class=card><strong>Latest score</strong><br>{summary['latest_score']}</div><div class=card><strong>Period delta</strong><br>{summary['delta']}</div><div class=card><strong>Direction</strong><br>{summary['direction']}</div></div><p>Status: <strong>{document['status']}</strong> · health model: <strong>{escape(str(document['health_model_version']))}</strong></p>{chart}<h2>Compatible snapshots</h2><table><thead><tr><th>Generated at</th><th class=n>Score</th><th>Grade</th><th class=n>Coverage</th><th>Commit</th></tr></thead><tbody>{rows}</tbody></table><h2>Excluded snapshots</h2><ul>{excluded or '<li>None.</li>'}</ul><p class=note>Direction is descriptive evidence, not an automatic quality judgment. Assessment coverage must be considered alongside score changes.</p></body></html>"""


def create_chart(document: dict[str, Any], output: Path) -> bool:
    if len(document["points"]) < 2:
        return False
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        return False
    labels = [item["generated_at"][:10] for item in document["points"]]
    scores = [item["score"] for item in document["points"]]
    figure, axis = plt.subplots(figsize=(10, 5))
    axis.plot(labels, scores, marker="o", linewidth=2, color="#3769b0")
    axis.set(title="Repository health score over time", xlabel="Snapshot date", ylabel="Health score", ylim=(0, 100))
    axis.grid(axis="y", alpha=.25); figure.autofmt_xdate(); figure.tight_layout()
    figure.savefig(output, dpi=150); plt.close(figure)
    return True


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("current", type=Path); parser.add_argument("output_json", type=Path); parser.add_argument("output_html", type=Path)
    parser.add_argument("--history-dir", type=Path); parser.add_argument("--schema", type=Path, required=True); parser.add_argument("--chart", type=Path)
    args = parser.parse_args()
    current = json.loads(args.current.read_text(encoding="utf-8"))
    historical, load_errors = [], []
    if args.history_dir and args.history_dir.is_dir():
        for path in sorted(args.history_dir.glob("*.json")):
            if ".schema." in path.name:
                continue
            try:
                historical.append((str(path), json.loads(path.read_text(encoding="utf-8"))))
            except (OSError, json.JSONDecodeError) as error:
                load_errors.append({"source": str(path), "snapshot_id": path.name, "reasons": [f"could not load snapshot: {error}"]})
    document = build(current, historical); document["excluded_snapshots"].extend(load_errors)
    validate(document, args.schema)
    args.output_json.parent.mkdir(parents=True, exist_ok=True)
    chart_created = create_chart(document, args.chart) if args.chart else False
    args.output_json.write_text(json.dumps(document, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    args.output_html.write_text(render_html(document, chart_created), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
