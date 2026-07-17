#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .reporting-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

cat > "$TEST_ROOT/report.json" <<'JSON'
{
  "schema_version": "1.1",
  "generated_at": "2026-07-16 12:00:00",
  "privacy": {"mode": "strict", "source_included": false},
  "project": {
    "name": "sample-project",
    "type": ".NET",
    "product": "[redacted]",
    "company": "[redacted]",
    "code_root": ".",
    "unity_version": "Unknown"
  },
  "analysis_profile": {
    "unity": false,
    "csharp": true,
    "dependency_manifest": "sample.csproj"
  },
  "generic_analysis": {
    "schema_version": "1.0",
    "collector": "generic",
    "file_count": 25,
    "language_count": 2,
    "configuration_file_count": 1,
    "documentation_file_count": 1,
    "test_file_count": 3,
    "ci_cd_file_count": 1,
    "docker_file_count": 1,
    "languages": [
      {"name": "C#", "files": 12, "lines": 340},
      {"name": "Shell", "files": 2, "lines": 80}
    ],
    "largest_files": [{"path": "src/Core.cs", "bytes": 2048, "lines": 1234}],
    "top_directories": [],
    "configuration_files": ["sample.csproj"],
    "documentation_files": ["README.md"],
    "test_files": ["tests/SampleTests.cs"],
    "ci_cd_files": [".github/workflows/ci.yml"],
    "docker_files": ["Dockerfile"],
    "dependencies": {"manifests": [], "total": 8},
    "possible_modules": [{"path": "src", "file_count": 12, "languages": {"C#": 12}}],
    "git": {
      "author_filter": "",
      "scope": "repository",
      "contributors_count": 2,
      "contributors": [{"name": "Developer One", "commits": 30}, {"name": "Developer Two", "commits": 12}],
      "hotspots": [{"path": "src/Core.cs", "commits": 5, "churn": 200}],
      "system_evolution": {"Data/Persistence": {"2026-01": 4}},
      "churn": {"lines_added": 1000, "lines_removed": 400, "total": 1400}
    },
    "analysis": {
      "architecture": {
        "languages_analyzed": ["C#"],
        "parser_coverage": [{"language": "C#", "mode": "heuristic-fallback", "parser": "planned-tree-sitter", "ast_files": 0, "heuristic_files": 12, "parse_errors": 0}],
        "signals": [],
        "design_patterns": [{"name": "Repository", "matches": 3, "confidence": "medium", "basis": "symbol and naming heuristic"}],
        "entrypoints": [{"path": "src/Program.cs", "language": "C#", "kind": "application bootstrap", "confidence": "high", "evidence": "ASP.NET host bootstrap"}],
        "coupling": {"modules": [{"id": "src/domain", "role": "hub", "fan_in": 2, "fan_out": 2, "total_coupling": 4, "instability": 0.5}], "high_coupling": [], "summary": {"assessed_modules": 1, "high_coupling_modules": 1, "maximum_total_coupling": 4}, "method": "fan-in/out"},
        "boundaries": {"modules": [{"module": "src/domain", "layer": "domain", "confidence": "medium", "evidence": "path token: domain"}], "violations": [{"source": "src/domain", "source_layer": "domain", "target": "src/infrastructure", "target_layer": "infrastructure", "references": 2, "severity": "high", "rule": "domain should not depend on infrastructure", "confidence": "medium"}], "cycles": [{"modules": ["src/domain", "src/infrastructure"], "layers": ["domain", "infrastructure"], "cross_boundary": true, "severity": "high"}], "summary": {"classified_modules": 2, "unclassified_modules": 0, "violations": 1, "cross_boundary_cycles": 1}, "method": "path inference", "limitations": []},
        "summary": {"entrypoints": 1, "cycles": 1, "high_coupling_modules": 1, "boundary_violations": 1}
      },
      "code": {
        "symbol_count": 10,
        "importing_file_count": 4,
        "complexity": {"method": "estimated", "files_analyzed": 12, "average": 4.5, "maximum": 21, "high_complexity_files": [], "high_complexity_functions": []}
      },
      "systems": [{"name": "Data/Persistence", "confidence": "high", "file_count": 6, "symbol_count": 8, "import_references": 12, "languages": {"C#": 6}}],
      "frameworks": {
        "count": 1,
        "method": "weighted evidence",
        "detected": [{"name": "ASP.NET Core", "family": "web framework", "confidence": "high", "score": 11, "languages": ["C#"], "concepts": ["HTTP controllers", "HTTP pipeline"], "evidence": [], "files": []}],
        "limitations": []
      },
      "graphs": {
        "summary": {"files": 12, "imports": 20, "internal_edges": 8, "external_references": 10, "unresolved_imports": 2, "modules": 3, "module_edges": 4, "dependency_nodes": 6, "cycles": 1},
        "file_graph": {"nodes": [], "edges": [], "unresolved": [{"source": "src/App.cs", "import": "./Missing"}]},
        "module_graph": {"nodes": [{"id": "src", "files": 10, "fan_in": 2, "fan_out": 3}], "edges": [{"source": "src", "target": "tests", "references": 2}], "cycles": [["src", "tests"]]},
        "dependency_graph": {"nodes": [{"id": "Microsoft.AspNetCore.Mvc", "declared": true, "import_references": 4, "source_modules": 1, "manifests": ["App.csproj"]}], "edges": []},
        "method": "language-aware",
        "limitations": []
      },
      "quality": {
        "coverage": {"status": "not_detected", "line_coverage_percent": null},
        "vulnerabilities": {"status": "not_scanned"},
        "licenses": {"repository_license": "MIT", "dependency_license_status": "not_scanned"}
      },
      "health": {
        "score": 72.5,
        "grade": "B",
        "assessment_coverage_percent": 95,
        "version": "1.0",
        "dimensions": [{"name": "Testing evidence", "score": 10, "maximum": 20, "status": "assessed", "evidence": "3 test files"}],
        "limitations": ["Repository evidence is not product quality."]
      },
      "narrative_facts": [{"statement": "The repository contains 25 analyzed files.", "evidence": "#/file_count", "confidence": "high"}]
    }
  },
  "current_metrics": {
    "csharp_files": 12,
    "csharp_lines": 340,
    "scenes": 0,
    "prefabs": 0,
    "animations": 0,
    "animator_controllers": 0,
    "shaders": 1,
    "assembly_definitions": 2,
    "uxml_files": 0,
    "uss_files": 0
  },
  "architecture": {
    "scriptable_objects": 0,
    "monobehaviours": 0,
    "interfaces": 4,
    "architecture_signals": 3,
    "networking_signals": 1,
    "services_and_data_signals": 2,
    "performance_signals": 1,
    "technical_debt_markers": 0
  },
  "technologies": {
    "dependency_count": 8,
    "shader_files": 1,
    "ui_toolkit_files": 0,
    "assembly_definitions": 2
  },
  "systems": {
    "likely_system_files": 5,
    "resources_assets": 0,
    "addressables_assets": 0
  },
  "history": {
    "scope": "Sanitized Git history",
    "total_commits": 42,
    "merge_commits": 2,
    "non_merge_commits": 40,
    "active_days": 20,
    "first_date": "2025-01-01",
    "last_date": "2026-01-01",
    "lines_added": 1000,
    "lines_removed": 400,
    "unique_paths_changed": 30
  },
  "collaboration": {"contributors": 3},
  "risks": {"potential_secret_findings": 1, "ownership_review_required": 2},
  "visualizations": {"charts": [{"title": "Commits by month", "path": "../graphs/commits_by_month.png"}]},
  "evidence": {
    "legacy_project_directory": "../project",
    "legacy_contribution_directory": "../contribution",
    "security_report": "../security/potential_secrets.txt",
    "privacy_scan": "../summary/03_privacy_scan.txt"
  }
}
JSON

if command -v python3 >/dev/null 2>&1 && python3 -c 'import sys' >/dev/null 2>&1; then
    PYTHON=python3
elif command -v python >/dev/null 2>&1 && python -c 'import sys' >/dev/null 2>&1; then
    PYTHON=python
else
    PYTHON=''
fi

[[ -n "$PYTHON" ]] || {
    echo "Python is required for structured reporting tests." >&2
    exit 1
}
"$PYTHON" "$SOURCE_ROOT/renderers/html.py" "$TEST_ROOT/report.json" "$TEST_ROOT/report/index.html"
"$PYTHON" "$SOURCE_ROOT/renderers/notion.py" "$TEST_ROOT/report.json" "$TEST_ROOT/notion/evidence.json"
"$PYTHON" "$SOURCE_ROOT/renderers/portfolio.py" "$TEST_ROOT/report.json" "$TEST_ROOT/portfolio/draft.json" "$TEST_ROOT/portfolio/index.html"
cat > "$TEST_ROOT/confirmations.json" <<'JSON'
{
  "candidate_name": "Confirmed Developer",
  "target_role": "Software Engineer",
  "approved_claims": ["repository-fact-1"]
}
JSON
"$PYTHON" "$SOURCE_ROOT/renderers/portfolio.py" "$TEST_ROOT/report.json" "$TEST_ROOT/portfolio/approved.json" "$TEST_ROOT/portfolio/approved.html" --confirmations "$TEST_ROOT/confirmations.json"

for report_name in \
    index.html \
    executive-summary.html \
    project-overview.html \
    architecture.html \
    technologies.html \
    systems.html \
    graphs.html \
    contribution.html \
    collaboration.html \
    quality.html \
    health.html \
    narrative.html \
    portfolio.html \
    charts.html \
    risks.html \
    notion-evidence.html; do
    [[ -s "$TEST_ROOT/report/$report_name" ]]
done
[[ -s "$TEST_ROOT/report/contributors-1.html" ]]

grep -q '<!doctype html>' "$TEST_ROOT/report/index.html"
grep -q 'C# files</span><strong>12' "$TEST_ROOT/report/executive-summary.html"
grep -q 'Commits</span><strong>42' "$TEST_ROOT/report/executive-summary.html"
grep -q 'Files</span><strong>25' "$TEST_ROOT/report/executive-summary.html"
grep -q 'Repository at a glance' "$TEST_ROOT/report/executive-summary.html"
grep -q 'Primary language</th><td class="">C#' "$TEST_ROOT/report/executive-summary.html"
grep -q 'Analysis coverage and evidence' "$TEST_ROOT/report/executive-summary.html"
grep -q 'Automatic project detection' "$TEST_ROOT/report/executive-summary.html"
grep -q 'Detected profile: .NET' "$TEST_ROOT/report/executive-summary.html"
grep -q 'Design pattern detection' "$TEST_ROOT/report/executive-summary.html"
grep -q '1 pattern categories with 3 heuristic matches' "$TEST_ROOT/report/executive-summary.html"
grep -q 'Portfolio and documentation support' "$TEST_ROOT/report/executive-summary.html"
grep -q 'File</th><th>Size</th><th>Lines' "$TEST_ROOT/report/project-overview.html"
grep -q 'class="number">1,234' "$TEST_ROOT/report/project-overview.html"
grep -q 'Files</th><td class="number">25' "$TEST_ROOT/report/project-overview.html"
grep -q 'Declared dependency entries' "$TEST_ROOT/report/technologies.html"
grep -q 'does not necessarily represent unique' "$TEST_ROOT/report/technologies.html"
grep -q 'Data/Persistence' "$TEST_ROOT/report/systems.html"
grep -q 'Parser coverage' "$TEST_ROOT/report/architecture.html"
grep -q 'heuristic-fallback' "$TEST_ROOT/report/architecture.html"
grep -q 'Specialized framework adapters' "$TEST_ROOT/report/architecture.html"
grep -q 'ASP.NET Core' "$TEST_ROOT/report/architecture.html"
grep -q 'Detected entrypoints' "$TEST_ROOT/report/architecture.html"
grep -q 'src/Program.cs' "$TEST_ROOT/report/architecture.html"
grep -q 'Module coupling and instability' "$TEST_ROOT/report/architecture.html"
grep -q 'domain should not depend on infrastructure' "$TEST_ROOT/report/architecture.html"
grep -q 'Cross-boundary' "$TEST_ROOT/report/architecture.html"
grep -q 'Framework concepts' "$TEST_ROOT/report/systems.html"
grep -q 'Module coupling' "$TEST_ROOT/report/graphs.html"
grep -q 'Microsoft.AspNetCore.Mvc' "$TEST_ROOT/report/graphs.html"
grep -q 'Strongly connected modules' "$TEST_ROOT/report/graphs.html"
grep -q './Missing' "$TEST_ROOT/report/graphs.html"
grep -q 'Module and dependency graphs' "$TEST_ROOT/report/executive-summary.html"
grep -q 'Architectural boundaries' "$TEST_ROOT/report/executive-summary.html"
grep -q 'specialized framework adapters matched' "$TEST_ROOT/report/executive-summary.html"
! grep -q 'Module candidate' "$TEST_ROOT/report/systems.html"
grep -q 'change frequency, code churn' "$TEST_ROOT/report/contribution.html"
grep -q 'Score</th><th>Commits</th><th>Churn</th><th>Lines</th><th>Authors</th><th>Days since change' "$TEST_ROOT/report/contribution.html"
grep -q 'Repository facts' "$TEST_ROOT/report/notion-evidence.html"
grep -q 'What was your formal mission?' "$TEST_ROOT/report/notion-evidence.html"
grep -q 'paginated contributor directory' "$TEST_ROOT/report/collaboration.html"
grep -q 'Developer One' "$TEST_ROOT/report/contributors-1.html"
grep -q 'Page 1 of 1' "$TEST_ROOT/report/contributors-1.html"
grep -q 'not_scanned is not equivalent to zero vulnerabilities' "$TEST_ROOT/report/quality.html"
grep -q 'High-complexity functions (AST)' "$TEST_ROOT/report/quality.html"
grep -q 'Repository health' "$TEST_ROOT/report/health.html"
grep -q 'No business impact or personal ownership is invented' "$TEST_ROOT/report/narrative.html"
grep -q 'portfolio/index.html' "$TEST_ROOT/report/portfolio.html"
grep -q 'commits_by_month.png' "$TEST_ROOT/report/charts.html"
grep -q 'class="chart"' "$TEST_ROOT/report/charts.html"
grep -q 'confirmation_required' "$TEST_ROOT/portfolio/draft.json"
grep -q 'Portfolio and CV evidence draft' "$TEST_ROOT/portfolio/index.html"
grep -q '"approved_claim_count": 1' "$TEST_ROOT/portfolio/approved.json"
grep -q 'Confirmed Developer' "$TEST_ROOT/portfolio/approved.json"
grep -q 'Potential secret findings</th><td class="number">1' "$TEST_ROOT/report/risks.html" || {
    cat "$TEST_ROOT/report/risks.html" >&2
    exit 1
}
! grep -q 'Unity version' "$TEST_ROOT/report/project-overview.html"
! grep -q '>Scenes<' "$TEST_ROOT/report/project-overview.html"

grep -q 'executive-summary.html' "$TEST_ROOT/report/index.html"
grep -q 'sample-project' "$TEST_ROOT/report/index.html"
! grep -q 'Unity version' "$TEST_ROOT/report/index.html"
grep -q 'href="index.html"' "$TEST_ROOT/report/architecture.html"
grep -q 'href="technologies.html"' "$TEST_ROOT/report/architecture.html"
grep -q '"classification_model"' "$TEST_ROOT/notion/evidence.json"
grep -q '"claims_requiring_confirmation"' "$TEST_ROOT/notion/evidence.json"
grep -q '"kind": "fact"' "$TEST_ROOT/notion/evidence.json"

printf '%s\n' 'structured reporting tests passed'
