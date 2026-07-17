#!/usr/bin/env python3

"""Render the standardized HTML report tree from canonical RepoDNA JSON."""

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


def metric_cards(rows: list[tuple[str, Any]]) -> str:
    return "".join(
        f'<article class="metric"><span>{esc(label)}</span><strong>{esc(value)}</strong></article>'
        for label, value in rows
    )


def table(rows: list[tuple[str, Any]]) -> str:
    body = "".join(
        f"<tr><th>{esc(label)}</th><td>{esc(value)}</td></tr>" for label, value in rows
    )
    return f'<div class="table-wrap"><table>{body}</table></div>'


def labeled(values: dict[str, Any], keys: list[str]) -> list[tuple[str, Any]]:
    return [(key.replace("_", " ").title(), values[key]) for key in keys]


STYLES = """
:root{--ink:#182230;--muted:#617083;--paper:#f5f7fa;--panel:#fff;--line:#dce3ea;--brand:#155eef;--risk:#b42318}
*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;background:var(--paper);color:var(--ink);font:15px/1.55 system-ui,-apple-system,"Segoe UI",sans-serif}
header{background:linear-gradient(135deg,#101828,#233b63);color:#fff;padding:3rem max(5vw,1.5rem)}header p{color:#cbd5e1}.layout{display:grid;grid-template-columns:230px minmax(0,1fr);gap:2rem;max-width:1280px;margin:auto;padding:2rem}
nav{position:sticky;top:1rem;align-self:start;background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:.75rem}nav a{display:block;color:var(--ink);padding:.55rem .7rem;text-decoration:none;border-radius:8px}nav a:hover,nav a.active{background:#edf3ff;color:var(--brand)}main{min-width:0}.metrics,.report-links{display:grid;grid-template-columns:repeat(auto-fit,minmax(145px,1fr));gap:1rem;margin-bottom:2rem}.metric,section,.report-links a{background:var(--panel);border:1px solid var(--line);border-radius:14px;box-shadow:0 5px 18px rgba(16,24,40,.04)}.metric{padding:1rem}.metric span{display:block;color:var(--muted);font-size:.82rem}.metric strong{font-size:1.65rem}.report-links a{padding:1rem;text-decoration:none;font-weight:600}section{padding:1.4rem;margin-bottom:1rem;scroll-margin-top:1rem}h1,h2{margin-top:0}h2{font-size:1.2rem}.table-wrap{overflow:auto}table{width:100%;border-collapse:collapse}th,td{padding:.65rem;border-bottom:1px solid var(--line);text-align:left}th{color:var(--muted);font-weight:600;width:55%}a{color:var(--brand)}.empty{color:var(--muted)}
@media(max-width:760px){.layout{display:block;padding:1rem}nav{position:static;margin-bottom:1rem;display:flex;overflow:auto}nav a{white-space:nowrap}header{padding:2rem 1rem}}
@media print{nav{display:none}.layout{display:block;padding:0}section,.metric{box-shadow:none;break-inside:avoid}body{background:#fff}}
"""


def page_document(
    data: dict[str, Any], title: str, body: str, pages: list[tuple[str, str]], active: str
) -> str:
    project = data["project"]
    nav = "".join(
        f'<a class="{"active" if filename == active else ""}" href="{esc(filename)}">{esc(label)}</a>'
        for filename, label in pages
    )
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>{esc(title)} · {esc(project['name'])} · RepoDNA</title><style>{STYLES}</style></head>
<body><header><p>RepoDNA structured report · schema {esc(data['schema_version'])}</p><h1>{esc(title)}</h1><p>{esc(project['name'])} · {esc(project['type'])} · generated {esc(data['generated_at'])}</p></header>
<div class="layout"><nav>{nav}</nav><main>{body}</main></div>
</body></html>"""


def render(data: dict[str, Any], output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    project = data["project"]
    profile = data.get("analysis_profile", {"unity": False, "csharp": True})
    generic = data.get("generic_analysis", {})
    metrics = data["current_metrics"]
    architecture = data["architecture"]
    technologies = data["technologies"]
    systems = data["systems"]
    history = data["history"]
    collaboration = data["collaboration"]
    risks = data["risks"]
    privacy = data["privacy"]

    headline = [
        ("Commits", history["total_commits"]),
        ("Contributors", collaboration["contributors"]),
        ("Security findings", risks["potential_secret_findings"]),
        ("Ownership reviews", risks["ownership_review_required"]),
    ]
    if generic.get("available", True):
        headline[0:0] = [
            ("Files", generic.get("file_count", 0)),
            ("Languages", len(generic.get("languages", []))),
        ]
    if profile["csharp"]:
        headline[0:0] = [("C# files", metrics["csharp_files"]), ("C# lines", metrics["csharp_lines"])]

    overview = [
        ("Repository", project["name"]),
        ("Project type", project["type"]),
        ("Code root", project["code_root"]),
        ("Privacy mode", privacy["mode"]),
        ("Source included", str(privacy["source_included"]).lower()),
    ]
    if profile["unity"]:
        overview.extend([
            ("Product", project["product"]),
            ("Company", project["company"]),
            ("Unity version", project["unity_version"]),
        ])

    if profile["unity"]:
        architecture_keys = list(architecture)
        technology_keys = list(technologies)
        system_keys = list(systems)
    elif profile["csharp"]:
        architecture_keys = [
            "interfaces", "architecture_signals", "networking_signals",
            "services_and_data_signals", "performance_signals", "technical_debt_markers",
        ]
        technology_keys = ["dependency_count"]
        system_keys = ["likely_system_files"]
    else:
        architecture_keys = []
        technology_keys = ["dependency_count"]
        system_keys = []

    empty = '<p class="empty">No specialized collector is available for this project type yet.</p>'
    inventory = table([
        ("Files", generic.get("file_count", 0)),
        ("Languages", len(generic.get("languages", []))),
        ("Configuration files", len(generic.get("configuration_files", []))),
        ("Documentation files", len(generic.get("documentation_files", []))),
        ("Test files", len(generic.get("test_files", []))),
        ("CI/CD files", len(generic.get("ci_cd_files", []))),
        ("Docker files", len(generic.get("docker_files", []))),
    ])
    language_table = table([
        (f"{item['name']} ({item['files']} files)", item["lines"])
        for item in generic.get("languages", [])
    ]) if generic.get("languages") else empty
    module_table = table([
        (item["path"], item["file_count"]) for item in generic.get("possible_modules", [])[:20]
    ]) if generic.get("possible_modules") else empty
    hotspot_table = table([
        (item["path"], f"score {item.get('score', 'n/a')} · {item['commits']} commits · {item['churn']} churn · {item.get('current_lines', 0)} lines · {item.get('authors', 0)} authors · changed {item.get('days_since_last_change', 0)} days ago")
        for item in generic.get("git", {}).get("hotspots", [])[:20]
    ]) if generic.get("git", {}).get("hotspots") else empty
    git_data = generic.get("git", {})
    contributor_table = table([
        (item["name"], item["commits"]) for item in git_data.get("contributors", [])
    ]) if git_data.get("contributors") else empty
    largest_table = table([
        (item["path"], f"{item['bytes']} bytes · {item.get('lines', 0)} lines")
        for item in generic.get("largest_files", [])[:20]
    ]) if generic.get("largest_files") else empty
    directory_table = table([
        (item["path"], item["files"]) for item in generic.get("top_directories", [])[:20]
    ]) if generic.get("top_directories") else empty
    shared_table = table([
        (item["path"], item["authors"]) for item in git_data.get("shared_files", [])[:20]
    ]) if git_data.get("shared_files") else empty
    coauthor_table = table([
        (" + ".join(item["authors"]), item["commits"]) for item in git_data.get("coauthorship", [])[:20]
    ]) if git_data.get("coauthorship") else empty
    evolution_table = table([
        (f"{system} · {month}", count)
        for system, periods in git_data.get("system_evolution", {}).items()
        for month, count in periods.items()
    ]) if git_data.get("system_evolution") else empty
    reference_table = table([
        ("Branches", git_data.get("branches_count", 0)),
        ("Tags", git_data.get("tags_count", 0)),
        ("Author aliases configured", git_data.get("author_aliases_configured", 0)),
        ("Dependency declarations", generic.get("dependencies", {}).get("total", 0)),
    ])
    sections = [
        ("project-overview.html", "Project overview", table(overview) + "<h3>Repository inventory</h3>" + inventory + "<h3>Largest files</h3>" + largest_table + "<h3>Main directories</h3>" + directory_table),
        ("architecture.html", "Architecture", table(labeled(architecture, architecture_keys)) if architecture_keys else module_table),
        ("technologies.html", "Technologies", table(labeled(technologies, technology_keys)) + "<h3>Languages and lines</h3>" + language_table + "<h3>Repository references</h3>" + reference_table),
        ("systems.html", "Systems", table(labeled(systems, system_keys)) if system_keys else module_table),
        ("contribution.html", "Contribution", table(labeled(history, list(history))) + "<h3>Composite hotspots</h3>" + hotspot_table + "<h3>System evolution</h3>" + evolution_table),
        ("collaboration.html", "Collaboration", table(labeled(collaboration, list(collaboration))) + "<h3>Contributors</h3>" + contributor_table + "<h3>Co-authored commits</h3>" + coauthor_table + "<h3>Files shared by authors</h3>" + shared_table + '<p class="empty">Contributor and ownership signals approximate Git activity; they do not prove exclusive authorship or code review.</p>'),
        ("risks.html", "Risks", table([
            ("Potential secret findings", risks["potential_secret_findings"]),
            ("Ownership review required", risks["ownership_review_required"]),
        ]) + '<p><a href="../security/potential_secrets.txt">Open redacted security evidence</a></p>'),
        ("notion-evidence.html", "Notion evidence", '<p>Structured facts, evidence, inferences, and confirmation prompts are available in <a href="../notion/evidence.json">notion/evidence.json</a>.</p>'),
    ]
    executive_body = '<div class="metrics">' + metric_cards(headline) + "</div>"
    all_pages = [("index.html", "Home"), ("executive-summary.html", "Executive summary")] + [
        (filename, title) for filename, title, _ in sections
    ]
    links = '<div class="report-links">' + "".join(
        f'<a href="{esc(filename)}">{esc(title)}</a>' for filename, title in all_pages[1:]
    ) + "</div>"
    output_path.write_text(page_document(data, project["name"], executive_body + links, all_pages, "index.html"), encoding="utf-8")
    (output_path.parent / "executive-summary.html").write_text(
        page_document(data, "Executive summary", executive_body, all_pages, "executive-summary.html"), encoding="utf-8"
    )
    for filename, title, body in sections:
        section_body = f"<section><h2>{esc(title)}</h2>{body}</section>"
        (output_path.parent / filename).write_text(
            page_document(data, title, section_body, all_pages, filename), encoding="utf-8"
        )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("json_path", type=Path)
    parser.add_argument("output_path", type=Path)
    args = parser.parse_args()
    with args.json_path.open(encoding="utf-8") as source:
        data = json.load(source)
    render(data, args.output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
