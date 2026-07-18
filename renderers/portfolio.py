#!/usr/bin/env python3

"""Create an approval-gated portfolio and CV evidence draft."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


def esc(value: Any) -> str:
    return (
        str(value)
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


def load_confirmations(path: Path | None) -> dict[str, Any]:
    if path is None:
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def build(data: dict[str, Any], confirmations: dict[str, Any]) -> dict[str, Any]:
    generic = data.get("generic_analysis", {})
    facts = generic.get("analysis", {}).get("narrative_facts", [])
    approved_ids = set(confirmations.get("approved_claims", []))
    claims = [
        {
            "id": f"repository-fact-{index + 1}",
            "statement": fact["statement"],
            "evidence": fact["evidence"],
            "confidence": fact["confidence"],
            "approved": f"repository-fact-{index + 1}" in approved_ids,
        }
        for index, fact in enumerate(facts)
    ]
    generated_candidates = [
        {
            "id": item["id"],
            "statement": item["draft_statement"],
            "title": item["title"],
            "category": item["category"],
            "evidence": item["evidence"],
            "metrics": item["metrics"],
            "confidence": item["confidence"],
            "required_confirmations": item["required_confirmations"],
            "xyz_inputs": item["xyz_inputs"],
            "approved": item["id"] in approved_ids,
        }
        for item in generic.get("analysis", {}).get("personal_achievement_candidates", {}).get("candidates", [])
    ]
    achievements = []
    for index, item in enumerate(confirmations.get("achievements", [])):
        claim_id = item.get("id", f"achievement-{index + 1}")
        action = item.get("action", "").strip()
        result = item.get("result", "").strip()
        metric = item.get("metric", "").strip()
        if not action or not result:
            continue
        statement = f"{action}, resulting in {result}"
        if metric:
            statement += f" ({metric})"
        achievements.append({
            "id": claim_id,
            "statement": statement + ".",
            "formula": "Accomplished X, measured by Y, by doing Z",
            "approved": claim_id in approved_ids,
            "evidence": item.get("evidence", []),
        })
    all_claims = claims + generated_candidates + achievements
    approved = [item for item in all_claims if item["approved"]]
    return {
        "$schema": "./portfolio-draft-1.0.0.schema.json",
        "schema_version": "1.0",
        "status": "approved" if all_claims and len(approved) == len(all_claims) else "confirmation_required",
        "candidate": {
            "name": confirmations.get("candidate_name", "Unconfirmed"),
            "target_role": confirmations.get("target_role", "Unconfirmed"),
        },
        "repository": data["project"]["name"],
        "canonical_metrics": data.get("canonical_metrics", {}),
        "claims": claims,
        "achievement_candidates": generated_candidates,
        "xyz_achievements": achievements,
        "approved_claim_count": len(approved),
        "confirmation_required_count": len(all_claims) - len(approved),
        "instructions": [
            "Review every claim against its evidence.",
            "Add a claim id to approved_claims only after personal confirmation.",
            "Do not publish impact, ownership, or metrics that the repository cannot prove.",
        ],
    }


def render_html(draft: dict[str, Any]) -> str:
    def items(values: list[dict[str, Any]]) -> str:
        return "".join(
            f'<li><strong>{esc(item["id"])}</strong>: {esc(item["statement"])} '
            f'<span class="{("approved" if item["approved"] else "review")}">'
            f'{("Approved" if item["approved"] else "Confirmation required")}</span></li>'
            for item in values
        ) or "<li>No evidence-based claims were generated.</li>"
    return f"""<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Portfolio evidence draft</title><style>body{{max-width:900px;margin:3rem auto;padding:0 1rem;font:16px/1.6 system-ui;color:#182230}}section{{border:1px solid #dce3ea;border-radius:12px;padding:1.2rem;margin:1rem 0}}.approved{{color:#067647}}.review{{color:#b54708}}code{{background:#f2f4f7;padding:.15rem .35rem}}</style></head>
<body><h1>Portfolio and CV evidence draft</h1><p>Status: <strong>{esc(draft["status"])}</strong>. This document never treats repository inference as personal ownership without approval.</p>
<section><h2>Repository facts</h2><ul>{items(draft["claims"])}</ul></section>
<section><h2>Author-filtered achievement candidates</h2><ul>{items(draft["achievement_candidates"])}</ul><p>These are evidence-backed prompts, not confirmed achievements. Complete the missing responsibility, action, and outcome before approval.</p></section>
<section><h2>X-Y-Z achievements</h2><ul>{items(draft["xyz_achievements"])}</ul></section>
<section><h2>How to approve</h2><p>Provide a confirmations JSON with personal context and an <code>approved_claims</code> list, then run RepoDNA with <code>--portfolio-profile path/to/confirmations.json</code>.</p></section></body></html>"""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("json_path", type=Path)
    parser.add_argument("output_json", type=Path)
    parser.add_argument("output_html", type=Path)
    parser.add_argument("--confirmations", type=Path)
    args = parser.parse_args()
    data = json.loads(args.json_path.read_text(encoding="utf-8"))
    draft = build(data, load_confirmations(args.confirmations))
    args.output_json.parent.mkdir(parents=True, exist_ok=True)
    args.output_html.parent.mkdir(parents=True, exist_ok=True)
    args.output_json.write_text(json.dumps(draft, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    args.output_html.write_text(render_html(draft), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
