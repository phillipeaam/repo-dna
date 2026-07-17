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
      "hotspots": [{"path": "src/Core.cs", "commits": 5, "churn": 200}],
      "system_evolution": {"Data/Persistence": {"2026-01": 4}},
      "churn": {"lines_added": 1000, "lines_removed": 400, "total": 1400}
    },
    "analysis": {
      "architecture": {
        "languages_analyzed": ["C#"],
        "signals": [],
        "design_patterns": [{"name": "Repository", "matches": 3, "confidence": "medium", "basis": "symbol and naming heuristic"}]
      },
      "code": {
        "symbol_count": 10,
        "importing_file_count": 4,
        "complexity": {"method": "estimated", "files_analyzed": 12, "average": 4.5, "maximum": 21, "high_complexity_files": []}
      },
      "systems": [{"name": "Data/Persistence", "confidence": "high", "file_count": 6, "symbol_count": 8, "import_references": 12, "languages": {"C#": 6}}],
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
    contribution.html \
    collaboration.html \
    quality.html \
    health.html \
    narrative.html \
    portfolio.html \
    risks.html \
    notion-evidence.html; do
    [[ -s "$TEST_ROOT/report/$report_name" ]]
done

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
! grep -q 'Module candidate' "$TEST_ROOT/report/systems.html"
grep -q 'change frequency, code churn' "$TEST_ROOT/report/contribution.html"
grep -q 'Score</th><th>Commits</th><th>Churn</th><th>Lines</th><th>Authors</th><th>Days since change' "$TEST_ROOT/report/contribution.html"
grep -q 'Repository facts' "$TEST_ROOT/report/notion-evidence.html"
grep -q 'What was your formal mission?' "$TEST_ROOT/report/notion-evidence.html"
grep -q 'not_scanned is not equivalent to zero vulnerabilities' "$TEST_ROOT/report/quality.html"
grep -q 'Repository health' "$TEST_ROOT/report/health.html"
grep -q 'No business impact or personal ownership is invented' "$TEST_ROOT/report/narrative.html"
grep -q 'portfolio/index.html' "$TEST_ROOT/report/portfolio.html"
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
