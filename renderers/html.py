#!/usr/bin/env python3

"""Render the standardized HTML report tree from canonical RepoDNA JSON."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from notion import build as build_notion_evidence


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


def numeric_value(value: Any) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def display_value(value: Any) -> str:
    if isinstance(value, int) and not isinstance(value, bool):
        return f"{value:,}"
    if isinstance(value, float):
        return f"{value:,.2f}"
    return str(value)


def table(rows: list[tuple[str, Any]]) -> str:
    body = "".join(
        f'<tr><th>{esc(label)}</th><td class="{"number" if numeric_value(value) else ""}">{esc(display_value(value))}</td></tr>'
        for label, value in rows
    )
    return f'<div class="table-wrap"><table>{body}</table></div>'


def data_table(headers: list[str], rows: list[list[Any]], numeric_columns: set[int] | None = None) -> str:
    numeric_columns = numeric_columns or set()
    head = "".join(f"<th>{esc(header)}</th>" for header in headers)
    body = "".join(
        "<tr>" + "".join(
            f'<td class="{"number" if index in numeric_columns else ""}">{esc(value)}</td>'
            for index, value in enumerate(row)
        ) + "</tr>"
        for row in rows
    )
    return f'<div class="table-wrap"><table class="data-table"><thead><tr>{head}</tr></thead><tbody>{body}</tbody></table></div>'


def item_list(items: list[str]) -> str:
    return "<ul>" + "".join(f"<li>{esc(item)}</li>" for item in items) + "</ul>"


def format_bytes(value: int) -> str:
    size = float(value)
    for unit in ("B", "KB", "MB", "GB"):
        if size < 1024 or unit == "GB":
            return f"{size:,.0f} {unit}" if unit == "B" else f"{size:,.1f} {unit}"
        size /= 1024
    return f"{value:,} B"


def labeled(values: dict[str, Any], keys: list[str]) -> list[tuple[str, Any]]:
    return [(key.replace("_", " ").title(), values[key]) for key in keys]


STYLES = """
:root{--ink:#182230;--muted:#617083;--paper:#f5f7fa;--panel:#fff;--line:#dce3ea;--brand:#155eef;--risk:#b42318}
*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;background:var(--paper);color:var(--ink);font:15px/1.55 system-ui,-apple-system,"Segoe UI",sans-serif}
header{background:linear-gradient(135deg,#101828,#233b63);color:#fff;padding:3rem max(5vw,1.5rem)}header p{color:#cbd5e1}.layout{display:grid;grid-template-columns:230px minmax(0,1fr);gap:2rem;max-width:1280px;margin:auto;padding:2rem}
nav{position:sticky;top:1rem;align-self:start;background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:.75rem}nav a{display:block;color:var(--ink);padding:.55rem .7rem;text-decoration:none;border-radius:8px}nav a:hover,nav a.active{background:#edf3ff;color:var(--brand)}main{min-width:0}.metrics,.report-links{display:grid;grid-template-columns:repeat(auto-fit,minmax(145px,1fr));gap:1rem;margin-bottom:2rem}.metric,section,.report-links a{background:var(--panel);border:1px solid var(--line);border-radius:14px;box-shadow:0 5px 18px rgba(16,24,40,.04)}.metric{padding:1rem}.metric span{display:block;color:var(--muted);font-size:.82rem}.metric strong{display:block;text-align:right;font-size:1.65rem;font-variant-numeric:tabular-nums}.report-links a{padding:1rem;text-decoration:none;font-weight:600}section{padding:1.4rem;margin-bottom:1rem;scroll-margin-top:1rem}h1,h2{margin-top:0}h2{font-size:1.2rem}.table-wrap{overflow:auto}table{width:100%;border-collapse:collapse}th,td{padding:.65rem;border-bottom:1px solid var(--line);text-align:left}th{color:var(--muted);font-weight:600;width:55%}.data-table th{width:auto}td.number{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}.chart{display:block;width:100%;height:auto;margin:1rem 0;border:1px solid var(--line);border-radius:10px}.note{background:#f8fafc;border-left:4px solid var(--brand);padding:.8rem 1rem;color:var(--muted)}a{color:var(--brand)}.empty{color:var(--muted)}
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
    analysis = generic.get("analysis", {})
    metrics = data["current_metrics"]
    architecture = data["architecture"]
    technologies = data["technologies"]
    systems = data["systems"]
    history = data["history"]
    collaboration = data["collaboration"]
    risks = data["risks"]
    privacy = data["privacy"]
    charts = data.get("visualizations", {}).get("charts", [])

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
        system_keys = list(systems)
    elif profile["csharp"]:
        architecture_keys = [
            "interfaces", "architecture_signals", "networking_signals",
            "services_and_data_signals", "performance_signals", "technical_debt_markers",
        ]
        system_keys = ["likely_system_files"]
    else:
        architecture_keys = []
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
    module_table = data_table(["Module candidate", "Files", "Languages"], [
        [item["path"], item["file_count"], ", ".join(item.get("languages", {})) or "Unknown"]
        for item in generic.get("possible_modules", [])[:20]
    ], {1}) if generic.get("possible_modules") else empty
    structured_systems = analysis.get("systems", [])
    system_rows = [
        [item["name"], item["confidence"], item["file_count"], item.get("symbol_count", 0), item.get("import_references", 0), ", ".join(item.get("languages", {}))]
        for item in structured_systems
    ]
    system_table = data_table(
        ["System candidate", "Confidence", "Files", "Symbols", "Import references", "Languages"], system_rows, {2, 3, 4}
    ) if system_rows else empty
    manifest_rows = [
        [item["path"], item["dependency_count"]]
        for item in generic.get("dependencies", {}).get("manifests", [])
    ]
    hotspot_table = data_table(
        ["File", "Score", "Commits", "Churn", "Lines", "Authors", "Days since change"], [
        [item["path"], item.get("score", "n/a"), item["commits"], item["churn"], item.get("current_lines", 0), item.get("authors", 0), item.get("days_since_last_change", 0)]
        for item in generic.get("git", {}).get("hotspots", [])[:20]
    ], {1, 2, 3, 4, 5, 6}) if generic.get("git", {}).get("hotspots") else empty
    git_data = generic.get("git", {})
    contributor_table = table([
        (item["name"], item["commits"]) for item in git_data.get("contributors", [])
    ]) if git_data.get("contributors") else empty
    contributor_page_size = 20
    contributors = git_data.get("contributors", [])
    contributor_chunks = [
        contributors[index:index + contributor_page_size]
        for index in range(0, len(contributors), contributor_page_size)
    ] if not git_data.get("author_filter") else []
    contributor_directory = ""
    if contributor_chunks:
        contributor_directory = '<p><a href="contributors-1.html">Open the paginated contributor directory</a> '
        contributor_directory += f'({len(contributors)} contributors across {len(contributor_chunks)} pages).</p>'
    elif git_data.get("author_filter"):
        contributor_directory = f'<p class="note">Contributor data is filtered to: {esc(git_data["author_filter"])}</p>'
    largest_table = data_table(["File", "Size", "Lines"], [
        [item["path"], format_bytes(item["bytes"]), f"{item.get('lines', 0):,}"]
        for item in generic.get("largest_files", [])[:20]
    ], {1, 2}) if generic.get("largest_files") else empty
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
    ownership = analysis.get("author_system_ownership", {})
    ownership_rows = [
        [
            item["system"], item["rank_in_system"], item["author"], item["commits"], item["churn"], item["files_touched"],
            f"{item['system_activity_share_percent']:.2f}%" if item.get("system_activity_share_percent") is not None else "Unavailable in filtered scope",
            f"{item.get('author_focus_percent', 0):.2f}%", item["confidence"], item["confidence_score"], item.get("system_confidence", "unknown"),
        ]
        for item in ownership.get("relationships", [])
    ]
    ownership_table = data_table(
        ["System", "Rank", "Author", "Commits", "Churn", "Files", "Share of system activity", "Author focus", "Confidence", "Confidence score", "System confidence"],
        ownership_rows,
        {1, 3, 4, 5, 6, 7, 9},
    ) if ownership_rows else '<p class="empty">Insufficient Git evidence to infer author-to-system activity.</p>'
    ownership_note = '<p class="note">This is approximate historical activity ownership, not proof of responsibility or authorship. Share of system activity compares author-file commit touches inside a system. Author focus shows how much of that author\'s system activity occurred there. Confidence reflects evidence volume; it is not confidence in personal or business ownership.</p>'
    technical_impact = git_data.get("technical_impact", {})
    impact_rows = [
        [item["date"][:10], item["commit"], item["author"], item["subject"], ", ".join(item.get("systems", [])),
         item["before"]["source_lines"], item["after"]["source_lines"], item["delta"]["source_lines"],
         item["before"]["estimated_complexity"], item["after"]["estimated_complexity"], item["delta"]["estimated_complexity"],
         item["touched"]["test_files"], item["touched"]["dependency_manifests"], item["touched"]["churn"],
         ", ".join(item.get("signals", [])), item["measurement_confidence"]]
        for item in technical_impact.get("contributions", [])[:100]
    ]
    impact_table = data_table(
        ["Date", "Commit", "Author", "Contribution", "Systems", "Lines before", "Lines after", "Lines delta", "Complexity before", "Complexity after", "Complexity delta", "Test files", "Dependency manifests", "Churn", "Technical signals", "Confidence"],
        impact_rows, {5, 6, 7, 8, 9, 10, 11, 12, 13},
    ) if impact_rows else '<p class="empty">Insufficient first-parent Git history to calculate contribution impact.</p>'
    impact_summary = technical_impact.get("summary", {})
    impact_summary_table = table([
        ("Contributions analyzed", technical_impact.get("contributions_analyzed", 0)),
        ("Total churn", impact_summary.get("total_churn", 0)),
        ("Net changed-source lines", impact_summary.get("net_changed_source_lines", 0)),
        ("Net estimated complexity", impact_summary.get("net_estimated_complexity", 0)),
        ("Contributions changing tests", impact_summary.get("contributions_changing_tests", 0)),
        ("Contributions changing dependencies", impact_summary.get("contributions_changing_dependencies", 0)),
        ("Estimated complexity reductions", impact_summary.get("estimated_complexity_reductions", 0)),
        ("Estimated complexity increases", impact_summary.get("estimated_complexity_increases", 0)),
    ])
    impact_note = '<p class="note">Before/after lines and estimated complexity cover only source files changed by that commit. Technical signals describe repository changes; they do not prove quality improvement, product impact, business impact, or individual performance.</p>'
    achievements = analysis.get("personal_achievement_candidates", {})
    achievement_rows = [
        [item["title"], item["category"], item["draft_statement"], item["confidence"], "; ".join(item.get("required_confirmations", []))]
        for item in achievements.get("candidates", [])
    ]
    achievement_table = data_table(
        ["Candidate", "Category", "Evidence-backed draft", "Confidence", "Required confirmation"], achievement_rows
    ) if achievement_rows else (
        '<p class="empty">Run RepoDNA with <code>--author &quot;Canonical Author&quot;</code> to generate personally scoped achievement candidates.</p>'
        if achievements.get("status") == "requires_author_filter"
        else '<p class="empty">The selected author scope did not provide enough evidence for achievement candidates.</p>'
    )
    achievement_note = '<p class="note">Candidates are not confirmed achievements. Git evidence can support scope and technical change, but personal responsibility, intent, outcome, and business impact require confirmation.</p>'
    reference_table = table([
        ("Branches", git_data.get("branches_count", 0)),
        ("Tags", git_data.get("tags_count", 0)),
        ("Author aliases configured", git_data.get("author_aliases_configured", 0)),
        ("Dependency declarations", generic.get("dependencies", {}).get("total", 0)),
    ])
    dependency_total = generic.get("dependencies", {}).get("total", technologies.get("dependency_count", 0))
    technology_body = table([("Declared dependency entries", dependency_total)])
    technology_body += '<p class="note">This is the number of dependency declarations found across detected manifest files. It does not necessarily represent unique or currently installed packages.</p>'
    if manifest_rows:
        technology_body += "<h3>Dependency manifests</h3>" + data_table(
            ["Manifest", "Declarations"], manifest_rows, {1}
        )
    technology_body += "<h3>Languages and lines</h3>" + language_table
    technology_body += "<h3>Repository references</h3>" + reference_table

    pattern_rows = [
        [item["name"], item["matches"], item["confidence"], item["basis"]]
        for item in analysis.get("architecture", {}).get("design_patterns", [])
    ]
    pattern_table = data_table(["Pattern signal", "Matches", "Confidence", "Basis"], pattern_rows, {1}) if pattern_rows else empty
    parser_rows = [
        [item["language"], item["mode"], item["parser"], item.get("ast_files", 0), item.get("heuristic_files", 0), item.get("parse_errors", 0)]
        for item in analysis.get("architecture", {}).get("parser_coverage", [])
    ]
    parser_table = data_table(["Language", "Mode", "Parser", "AST files", "Fallback files", "Parse errors"], parser_rows, {3, 4, 5}) if parser_rows else empty
    framework_analysis = analysis.get("frameworks", {})
    framework_rows = [
        [item["name"], item["family"], item["confidence"], item["score"], ", ".join(item.get("languages", [])), ", ".join(item.get("concepts", []))]
        for item in framework_analysis.get("detected", [])
    ]
    framework_table = data_table(
        ["Framework", "Family", "Confidence", "Evidence score", "Languages", "Detected concepts"], framework_rows, {3}
    ) if framework_rows else '<p class="empty">No supported framework reached the evidence threshold.</p>'
    graphs = analysis.get("graphs", {})
    graph_summary = graphs.get("summary", {})
    module_graph = graphs.get("module_graph", {})
    dependency_graph = graphs.get("dependency_graph", {})
    file_graph = graphs.get("file_graph", {})
    module_rows = [
        [item["id"], item.get("files", 0), item.get("fan_in", 0), item.get("fan_out", 0)]
        for item in sorted(module_graph.get("nodes", []), key=lambda row: (-(row.get("fan_in", 0) + row.get("fan_out", 0)), row["id"]))[:50]
    ]
    module_edge_rows = [[item["source"], item["target"], item["references"]] for item in module_graph.get("edges", [])[:100]]
    dependency_rows = [
        [item["id"], "yes" if item.get("declared") else "no", item.get("import_references", 0), item.get("source_modules", 0), ", ".join(item.get("manifests", []))]
        for item in sorted(dependency_graph.get("nodes", []), key=lambda row: (-row.get("import_references", 0), row["id"]))[:100]
    ]
    unresolved_rows = [[item["source"], item["import"]] for item in file_graph.get("unresolved", [])[:100]]
    cycle_rows = [[index, " → ".join(cycle)] for index, cycle in enumerate(module_graph.get("cycles", []), 1)]
    graphs_body = table([
        ("Source files", graph_summary.get("files", 0)), ("Imports", graph_summary.get("imports", 0)),
        ("Resolved internal edges", graph_summary.get("internal_edges", 0)),
        ("External references", graph_summary.get("external_references", 0)),
        ("Unresolved imports", graph_summary.get("unresolved_imports", 0)),
        ("Directory modules", graph_summary.get("modules", 0)), ("Module edges", graph_summary.get("module_edges", 0)),
        ("Dependency nodes", graph_summary.get("dependency_nodes", 0)), ("Module cycles", graph_summary.get("cycles", 0)),
    ])
    graphs_body += '<p class="note">Fan-in counts incoming module dependencies; fan-out counts outgoing dependencies. External packages and unresolved relative imports are kept separate from internal edges.</p>'
    graphs_body += "<h3>Module coupling</h3>" + (data_table(["Module", "Files", "Fan-in", "Fan-out"], module_rows, {1, 2, 3}) if module_rows else empty)
    graphs_body += "<h3>Resolved module edges</h3>" + (data_table(["Source module", "Target module", "References"], module_edge_rows, {2}) if module_edge_rows else empty)
    graphs_body += "<h3>External dependency graph</h3>" + (data_table(["Dependency", "Declared", "Import references", "Source modules", "Manifests"], dependency_rows, {2, 3}) if dependency_rows else empty)
    graphs_body += "<h3>Module cycles</h3>" + (data_table(["#", "Strongly connected modules"], cycle_rows, {0}) if cycle_rows else '<p class="empty">No module cycles were detected.</p>')
    graphs_body += "<h3>Unresolved relative imports</h3>" + (data_table(["Source", "Import"], unresolved_rows) if unresolved_rows else '<p class="empty">No unresolved relative imports were detected.</p>')
    architecture_body = table(labeled(architecture, architecture_keys)) if architecture_keys else (
        '<p class="note">Architecture candidates combine module structure, supported-language symbols, imports, and naming evidence. They remain heuristics until reviewed.</p>' + module_table
    )
    architecture_body += "<h3>Multi-language design-pattern signals</h3>" + pattern_table
    architecture_body += "<h3>Parser coverage</h3>" + parser_table
    architecture_body += "<h3>Specialized framework adapters</h3>" + framework_table
    architecture_body += '<p class="note">Framework confidence combines dependency manifests, imports, parsed symbols, calls, and conventional paths. It does not prove runtime configuration.</p>'
    entrypoint_rows = [[item["path"], item["language"], item["kind"], item["confidence"], item["evidence"]] for item in analysis.get("architecture", {}).get("entrypoints", [])]
    coupling_analysis = analysis.get("architecture", {}).get("coupling", {})
    coupling_rows = [[item["id"], item.get("role", "unknown"), item.get("fan_in", 0), item.get("fan_out", 0), item.get("total_coupling", 0), item.get("instability", 0)] for item in coupling_analysis.get("modules", [])[:50]]
    boundary_analysis = analysis.get("architecture", {}).get("boundaries", {})
    boundary_rows = [[item["module"], item["layer"], item["confidence"], item["evidence"]] for item in boundary_analysis.get("modules", [])[:100]]
    violation_rows = [[item["source"], item["source_layer"], item["target"], item["target_layer"], item["references"], item["severity"], item["rule"]] for item in boundary_analysis.get("violations", [])[:100]]
    architectural_cycle_rows = [[" → ".join(item["modules"]), ", ".join(item["layers"]), "yes" if item["cross_boundary"] else "no", item["severity"]] for item in boundary_analysis.get("cycles", [])]
    architecture_body += "<h3>Detected entrypoints</h3>" + (data_table(["Path", "Language", "Kind", "Confidence", "Evidence"], entrypoint_rows) if entrypoint_rows else '<p class="empty">No executable or framework entrypoints were detected.</p>')
    architecture_body += "<h3>Module coupling and instability</h3>" + (data_table(["Module", "Role", "Fan-in", "Fan-out", "Total coupling", "Instability"], coupling_rows, {2, 3, 4, 5}) if coupling_rows else empty)
    architecture_body += '<p class="note">Instability is fan-out divided by fan-in plus fan-out. Values near zero indicate depended-upon providers; values near one indicate dependency-heavy consumers.</p>'
    architecture_body += "<h3>Inferred architectural boundaries</h3>" + (data_table(["Module", "Layer", "Confidence", "Evidence"], boundary_rows) if boundary_rows else empty)
    architecture_body += "<h3>Boundary violations</h3>" + (data_table(["Source", "Layer", "Target", "Target layer", "References", "Severity", "Rule"], violation_rows, {4}) if violation_rows else '<p class="empty">No violations were found among classified module boundaries.</p>')
    architecture_body += "<h3>Architectural cycles</h3>" + (data_table(["Modules", "Layers", "Cross-boundary", "Severity"], architectural_cycle_rows) if architectural_cycle_rows else '<p class="empty">No module cycles were detected.</p>')
    architecture_body += '<p class="note">Layers are inferred from directory tokens and require review. A reported violation is an architectural signal, not proof that the repository intended to follow Clean Architecture.</p>'
    systems_body = table(labeled(systems, system_keys)) if system_keys else ""
    systems_body += '<p class="note">System names combine module boundaries, symbols, imports, dependency manifests, and historical path evidence. They are candidates for review, not confirmed product architecture.</p>'
    systems_body += "<h3>Symbol and dependency-based candidates</h3>" + system_table
    systems_body += "<h3>Framework concepts</h3>" + framework_table
    hotspot_explanation = '<p class="note">Composite hotspots rank files that may deserve attention by combining change frequency, code churn, current size, number of authors, and recency. A higher score suggests relevance or maintenance risk; it does not prove poor code quality.</p>'

    quality = analysis.get("quality", {})
    complexity = analysis.get("code", {}).get("complexity", {})
    coverage_result = quality.get("coverage", {})
    test_result = quality.get("tests", {})
    linter_result = quality.get("linters", {})
    scanner_result = quality.get("vulnerabilities", {})
    dependency_resolution = quality.get("dependency_resolution", {})
    dependency_summary = dependency_resolution.get("summary", {})
    high_complexity_rows = [
        [item["path"], item["language"], item["estimated_cyclomatic_complexity"], item["decision_points"], item["lines"]]
        for item in complexity.get("high_complexity_files", [])
    ]
    complexity_table = data_table(["File", "Language", "Estimated complexity", "Decision points", "Lines"], high_complexity_rows, {2, 3, 4}) if high_complexity_rows else '<p class="empty">No files crossed the current high-complexity threshold.</p>'
    function_complexity_rows = [
        [item["path"], item["name"], item["language"], item["estimated_cyclomatic_complexity"], item["decision_points"], item.get("parameters", 0)]
        for item in complexity.get("high_complexity_functions", [])
    ]
    function_complexity_table = data_table(["File", "Function", "Language", "Complexity", "Decision points", "Parameters"], function_complexity_rows, {3, 4, 5}) if function_complexity_rows else '<p class="empty">No AST-analyzed functions crossed the current threshold.</p>'
    quality_body = table([
        ("Complexity method", complexity.get("method", "Not assessed")),
        ("Files analyzed", complexity.get("files_analyzed", 0)),
        ("Average estimated complexity", complexity.get("average") if complexity.get("average") is not None else "Not assessed"),
        ("Maximum estimated complexity", complexity.get("maximum") if complexity.get("maximum") is not None else "Not assessed"),
        ("Coverage status", coverage_result.get("status", "Not assessed")),
        ("Line coverage", coverage_result.get("line_coverage_percent") if coverage_result.get("line_coverage_percent") is not None else "Not available"),
        ("Test results status", test_result.get("status", "Not assessed")),
        ("Tests passed", test_result.get("passed", 0)),
        ("Tests failed", test_result.get("failed", 0)),
        ("Linter status", linter_result.get("status", "Not assessed")),
        ("Linter issues", linter_result.get("issues", 0)),
        ("Vulnerability status", scanner_result.get("status", "Not assessed")),
        ("Imported security findings", scanner_result.get("findings") if scanner_result.get("findings") is not None else "Not available"),
        ("Dependencies correlated", dependency_summary.get("dependencies", 0)),
        ("Affected dependencies", dependency_summary.get("affected_dependencies", 0)),
        ("Dependency licenses resolved", dependency_summary.get("license_resolved", 0)),
        ("Dependency licenses requiring review", dependency_summary.get("license_review_required", 0)),
        ("Dependency licenses unresolved", dependency_summary.get("license_unresolved", 0)),
        ("Repository license", quality.get("licenses", {}).get("repository_license", "Unknown")),
        ("Dependency license status", quality.get("licenses", {}).get("dependency_license_status", "Not assessed")),
    ])
    quality_body += '<p class="note">A vulnerability status of not_scanned is not equivalent to zero vulnerabilities. RepoDNA only reports verified scanner evidence.</p>'
    coverage_rows = [[item["tool"], item["path"], item.get("metrics", {}).get("lines", {}).get("percent"), item.get("metrics", {}).get("branches", {}).get("percent"), item.get("metrics", {}).get("functions", {}).get("percent")] for item in coverage_result.get("reports", [])]
    test_rows = [[item["tool"], item["path"], item["total"], item["passed"], item["failed"], item["errors"], item["skipped"], item.get("duration_seconds")] for item in test_result.get("reports", [])]
    linter_rows = [[item["tool"], item["path"], item["issues"], item["affected_files"], ", ".join(f"{key}: {value}" for key, value in item.get("severities", {}).items())] for item in linter_result.get("reports", [])]
    scanner_rows = [[item["tool"], item["path"], item["findings"], ", ".join(f"{key}: {value}" for key, value in item.get("severities", {}).items())] for item in scanner_result.get("reports", [])]
    dependency_rows = []
    for item in dependency_resolution.get("dependencies", []):
        findings = item.get("vulnerabilities", [])
        dependency_rows.append([
            item["name"], "Yes" if item.get("direct") else "No", ", ".join(item.get("versions", [])) or "Unknown",
            item.get("vulnerability_status", "not_resolved"), item.get("vulnerability_count", 0),
            ", ".join(sorted({finding.get("severity", "unknown") for finding in findings})) or "None resolved",
            ", ".join(finding.get("id", "unknown") for finding in findings) or "None resolved",
            item.get("license_status", "unresolved"), item.get("license_category", "unresolved"),
            ", ".join(item.get("licenses", [])) or "Unknown", ", ".join(item.get("sources", [])) or "Manifest only",
        ])
    quality_body += "<h3>Imported coverage reports</h3>" + (data_table(["Tool", "Report", "Lines %", "Branches %", "Functions %"], coverage_rows, {2, 3, 4}) if coverage_rows else '<p class="empty">No parseable coverage report was imported.</p>')
    quality_body += "<h3>Imported test results</h3>" + (data_table(["Tool", "Report", "Total", "Passed", "Failed", "Errors", "Skipped", "Duration seconds"], test_rows, {2, 3, 4, 5, 6, 7}) if test_rows else '<p class="empty">No parseable test-result report was imported.</p>')
    quality_body += "<h3>Imported linter results</h3>" + (data_table(["Tool", "Report", "Issues", "Affected files", "Severities"], linter_rows, {2, 3}) if linter_rows else '<p class="empty">No parseable linter report was imported.</p>')
    quality_body += "<h3>Imported scanner results</h3>" + (data_table(["Tool", "Report", "Findings", "Severities"], scanner_rows, {2}) if scanner_rows else '<p class="empty">No parseable security scanner report was imported.</p>')
    quality_body += "<h3>Vulnerabilities and licenses by dependency</h3>" + (data_table(
        ["Dependency", "Direct", "Versions", "Vulnerability status", "Findings", "Severities", "Finding IDs", "License status", "License category", "Licenses", "Evidence sources"],
        dependency_rows,
        {4},
    ) if dependency_rows else '<p class="empty">No dependency identities were available for correlation.</p>')
    quality_body += '<p class="note"><strong>not_resolved</strong> means no per-dependency scanner result was correlated; it does not mean the dependency is vulnerability-free. License categories are conservative triage signals, not legal advice or a compatibility determination.</p>'
    quality_body += "<h3>High-complexity candidates</h3>" + complexity_table
    quality_body += "<h3>High-complexity functions (AST)</h3>" + function_complexity_table

    health = analysis.get("health", {})
    health_rows = [
        [item["name"], item["score"], item["maximum"], item["status"], item["evidence"]]
        for item in health.get("dimensions", [])
    ]
    health_body = table([
        ("Health score", health.get("score", "Not assessed")),
        ("Grade", health.get("grade", "Not assessed")),
        ("Assessment coverage", f"{health.get('assessment_coverage_percent', 0)}%"),
        ("Model version", health.get("version", "Unknown")),
    ]) + data_table(["Dimension", "Score", "Maximum", "Status", "Evidence"], health_rows, {1, 2})
    health_body += "<h3>Method limitations</h3>" + item_list(health.get("limitations", []))

    narrative_facts = analysis.get("narrative_facts", [])
    narrative_body = '<p class="note">Every sentence below is generated from a structured fact and retains an evidence pointer. No business impact or personal ownership is invented.</p>'
    narrative_body += "".join(
        f'<section><p>{esc(item["statement"])}</p><small>Confidence: {esc(item["confidence"])} · Evidence: {esc(item["evidence"])}</small></section>'
        for item in narrative_facts
    ) or empty
    charts_body = "".join(
        f'<section><h2>{esc(chart["title"])}</h2><a href="{esc(chart["path"])}"><img class="chart" src="{esc(chart["path"])}" alt="{esc(chart["title"])}"></a></section>'
        for chart in charts
    ) or '<p class="empty">No charts were generated. Charts require non-strict Git history data and matplotlib.</p>'

    notion = build_notion_evidence(data)
    notion_facts = [item["statement"] for item in notion["about_project"]["facts"]]
    notion_systems = [
        f"{item['name']} ({item['confidence']} confidence)" for item in notion["major_systems"]
    ]
    notion_body = "<h3>Repository facts</h3>" + item_list(notion_facts)
    notion_body += "<h3>Inferred systems requiring review</h3>" + (
        item_list(notion_systems) if notion_systems
        else '<p class="empty">No system candidates were inferred.</p>'
    )
    notion_body += "<h3>Personal confirmation required</h3>" + item_list(
        notion["personal_confirmation_required"]
    )
    notion_body += '<p><a href="../notion/evidence.json">Open the complete structured evidence JSON</a></p>'

    language_names = ", ".join(item["name"] for item in generic.get("languages", [])[:5]) or "None detected"
    architecture_evidence = (
        f"{architecture.get('architecture_signals', 0)} pattern signals and {architecture.get('interfaces', 0)} interfaces"
        if profile["csharp"] else f"{len(generic.get('possible_modules', []))} module candidates"
    )
    if framework_analysis.get("count", 0):
        architecture_evidence += f"; {framework_analysis['count']} specialized framework adapters matched"
    system_evidence = (
        f"{systems.get('likely_system_files', 0)} likely system files"
        if profile["csharp"] else f"{len(system_rows)} systems inferred from Git paths"
    )
    design_patterns = analysis.get("architecture", {}).get("design_patterns", [])
    design_status = "Available" if analysis.get("architecture", {}).get("languages_analyzed") else "Not available for this profile"
    design_evidence = f"{len(design_patterns)} pattern categories with {sum(item['matches'] for item in design_patterns)} heuristic matches"
    capability_rows = [
        ["Automatic project detection", "Completed", f"Detected profile: {project['type']}"],
        ["Architecture discovery", "Completed", architecture_evidence],
        ["Technology inventory", "Completed", f"Languages: {language_names}; {dependency_total} dependency declarations"],
        ["Gameplay and application systems", "Completed", f"{len(structured_systems)} symbol/dependency-based system candidates"],
        ["Project metrics", "Completed", f"{generic.get('file_count', 0)} files across {len(generic.get('languages', []))} languages"],
        ["Git contribution analysis", "Completed", f"{history.get('total_commits', 0)} commits; {generic.get('git', {}).get('churn', {}).get('total', 0)} lines of churn"],
        ["Collaboration insights", "Completed", f"{collaboration.get('contributors', 0)} contributors; {len(git_data.get('shared_files', []))} shared-file signals"],
        ["Design pattern detection", design_status, design_evidence],
        ["Module and dependency graphs", "Completed", f"{graph_summary.get('internal_edges', 0)} internal edges; {graph_summary.get('dependency_nodes', 0)} dependency nodes; {graph_summary.get('cycles', 0)} module cycles"],
        ["Architectural boundaries", "Completed", f"{len(entrypoint_rows)} entrypoints; {len(violation_rows)} inferred boundary violations; {len(architectural_cycle_rows)} assessed cycles"],
        ["Engineering signals", "Completed", f"{generic.get('test_file_count', 0)} tests; {generic.get('ci_cd_file_count', 0)} CI/CD; {generic.get('docker_file_count', 0)} Docker; {generic.get('documentation_file_count', 0)} documentation files"],
        ["Report generation", "Completed", "HTML report suite, canonical JSON, Git CSV data, and optional charts"],
        ["Portfolio and documentation support", "Completed", f"{len(notion_facts)} repository facts and {len(notion['personal_confirmation_required'])} personal confirmation prompts"],
    ]
    capability_table = data_table(["Analysis capability", "Status", "Evidence produced"], capability_rows)

    sections = [
        ("project-overview.html", "Project overview", table(overview) + "<h3>Repository inventory</h3>" + inventory + "<h3>Largest files</h3>" + largest_table + "<h3>Main directories</h3>" + directory_table),
        ("architecture.html", "Architecture", architecture_body),
        ("technologies.html", "Technologies", technology_body),
        ("systems.html", "Systems", systems_body),
        ("graphs.html", "Module and dependency graphs", graphs_body),
        ("contribution.html", "Contribution", table(labeled(history, list(history))) + "<h3>Personal achievement candidates</h3>" + achievement_table + achievement_note + "<h3>Technical impact before and after each contribution</h3>" + impact_summary_table + impact_table + impact_note + "<h3>Composite hotspots</h3>" + hotspot_explanation + hotspot_table + "<h3>System evolution</h3>" + evolution_table),
        ("collaboration.html", "Collaboration", table(labeled(collaboration, list(collaboration))) + "<h3>Contributors</h3>" + contributor_directory + contributor_table + "<h3>Author and system activity ownership</h3>" + ownership_table + ownership_note + "<h3>Co-authored commits</h3>" + coauthor_table + "<h3>Files shared by authors</h3>" + shared_table + '<p class="empty">Contributor and ownership signals approximate Git activity; they do not prove exclusive authorship or code review.</p>'),
        ("quality.html", "Quality and compliance", quality_body),
        ("health.html", "Repository health", health_body),
        ("narrative.html", "Evidence-based narrative", narrative_body),
        ("portfolio.html", "Portfolio and CV", '<p>The approval-gated portfolio draft is available at <a href="../portfolio/index.html">portfolio/index.html</a>. Repository facts remain unapproved until explicitly confirmed.</p>'),
        ("charts.html", "Charts", charts_body),
        ("risks.html", "Risks", table([
            ("Potential secret findings", risks["potential_secret_findings"]),
            ("Ownership review required", risks["ownership_review_required"]),
        ]) + '<p><a href="../security/potential_secrets.txt">Open redacted security evidence</a></p>'),
        ("notion-evidence.html", "Notion evidence", notion_body),
    ]
    top_language = generic.get("languages", [{}])[0].get("name", "Not detected") if generic.get("languages") else "Not detected"
    executive_body = '<section><h2>Repository at a glance</h2><p>This summary highlights the main measurable signals collected from the current repository and its Git history.</p><div class="metrics">' + metric_cards(headline) + "</div>"
    executive_body += table([
        ("Primary language", top_language),
        ("Detected tests", generic.get("test_file_count", 0)),
        ("Declared dependency entries", dependency_total),
        ("History period", f"{history.get('first_date') or 'Unknown'} to {history.get('last_date') or 'Unknown'}"),
        ("Total churn", generic.get("git", {}).get("churn", {}).get("total", 0)),
    ]) + '<p class="note">These are repository signals, not conclusions about business impact, code quality, or personal ownership.</p></section>'
    executive_body += '<section><h2>Analysis coverage and evidence</h2><p>Each row states what this run actually analyzed. Unsupported specialized analysis is shown explicitly instead of being reported as an empty result.</p>' + capability_table + '</section>'
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
    for page_index, chunk in enumerate(contributor_chunks, 1):
        rows = [[(page_index - 1) * contributor_page_size + index, item["name"], item["commits"]] for index, item in enumerate(chunk, 1)]
        pagination = '<p class="pagination">'
        if page_index > 1:
            pagination += f'<a href="contributors-{page_index - 1}.html">Previous</a> '
        pagination += f'Page {page_index} of {len(contributor_chunks)}'
        if page_index < len(contributor_chunks):
            pagination += f' <a href="contributors-{page_index + 1}.html">Next</a>'
        pagination += '</p>'
        body = '<section><h2>Contributors</h2>' + pagination
        body += data_table(["#", "Canonical contributor", "Commits"], rows, {0, 2})
        body += pagination + '</section>'
        (output_path.parent / f"contributors-{page_index}.html").write_text(
            page_document(data, f"Contributors · page {page_index}", body, all_pages, "collaboration.html"),
            encoding="utf-8",
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
