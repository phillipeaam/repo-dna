#!/usr/bin/env python3
"""Export the lockfile-derived CycloneDX SBOM and a compact HTML inventory."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from xml.sax.saxutils import escape


def render(report_path: Path, output_dir: Path) -> None:
    report = json.loads(report_path.read_text(encoding="utf-8"))
    inventory = report.get("generic_analysis", {}).get("analysis", {}).get("dependency_inventory", {})
    sbom = inventory.get("sbom", {})
    if sbom.get("bomFormat") != "CycloneDX" or sbom.get("specVersion") != "1.6":
        raise ValueError("dependency inventory does not contain a CycloneDX 1.6 SBOM")
    components = sbom.get("components", [])
    refs = [item.get("bom-ref") for item in components]
    if any(not ref for ref in refs) or len(refs) != len(set(refs)):
        raise ValueError("CycloneDX components require unique non-empty bom-ref values")

    output_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / "bom.json").write_text(json.dumps(sbom, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    summary = inventory.get("summary", {})
    rows = "".join(
        "<tr>" + "".join(f"<td>{escape(str(value))}</td>" for value in (
            item.get("name", ""), item.get("version") or "Unknown", item.get("ecosystem", "Unknown"),
            "Yes" if item.get("direct") else "No", ", ".join(item.get("lockfiles", [])), item.get("purl", ""),
        )) + "</tr>"
        for item in inventory.get("components", [])
    ) or '<tr><td colspan="6">No lockfile-resolved components were available.</td></tr>'
    document = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Software bill of materials</title><style>
body{{font-family:system-ui,sans-serif;margin:2rem;color:#172033}}a{{color:#2457c5}}table{{width:100%;border-collapse:collapse}}
th,td{{padding:.65rem;border-bottom:1px solid #dfe5ef;text-align:left}}th{{background:#f5f7fb}}.number{{text-align:right}}
</style></head><body><p><a href="../report/index.html">Back to report</a></p><h1>Software bill of materials</h1>
<p>Lockfiles: <strong>{summary.get('lockfiles', 0)}</strong> · Components: <strong>{summary.get('components', 0)}</strong> · Direct: <strong>{summary.get('direct_components', 0)}</strong> · Transitive: <strong>{summary.get('transitive_components', 0)}</strong></p>
<p><a href="bom.json">Open CycloneDX 1.6 JSON</a></p><table><thead><tr><th>Package</th><th>Version</th><th>Ecosystem</th><th>Direct</th><th>Lockfile</th><th>PURL</th></tr></thead><tbody>{rows}</tbody></table>
<p>Versions and relationships are derived statically from lockfiles and may differ from deployed artifacts.</p></body></html>"""
    (output_dir / "index.html").write_text(document, encoding="utf-8")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("report", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    render(args.report, args.output)
