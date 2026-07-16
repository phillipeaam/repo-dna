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
    "largest_files": [],
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
      "churn": {"lines_added": 1000, "lines_removed": 400, "total": 1400}
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

if [[ -n "$PYTHON" ]]; then
    "$PYTHON" "$SOURCE_ROOT/renderers/markdown.py" "$TEST_ROOT/report.json" "$TEST_ROOT/report"
    "$PYTHON" "$SOURCE_ROOT/renderers/html.py" "$TEST_ROOT/report.json" "$TEST_ROOT/report/index.html"
    "$PYTHON" "$SOURCE_ROOT/renderers/notion.py" "$TEST_ROOT/report.json" "$TEST_ROOT/notion/evidence.json"
else
    bash "$SOURCE_ROOT/renderers/markdown.sh" "$TEST_ROOT/report.json" "$TEST_ROOT/report"
fi

for report_name in \
    index.md \
    executive-summary.md \
    project-overview.md \
    architecture.md \
    technologies.md \
    systems.md \
    contribution.md \
    collaboration.md \
    risks.md \
    notion-evidence.md; do
    [[ -s "$TEST_ROOT/report/$report_name" ]]
done

grep -q '# sample-project report' "$TEST_ROOT/report/index.md"
grep -q '| C# files | 12 |' "$TEST_ROOT/report/executive-summary.md"
grep -q '| Total commits | 42 |' "$TEST_ROOT/report/executive-summary.md"
grep -q '| Files | 25 |' "$TEST_ROOT/report/executive-summary.md"
grep -q '| Potential secret findings | 1 |' "$TEST_ROOT/report/risks.md" || {
    cat "$TEST_ROOT/report/risks.md" >&2
    exit 1
}
! grep -q 'Unity version' "$TEST_ROOT/report/project-overview.md"
! grep -q '| Scenes |' "$TEST_ROOT/report/project-overview.md"

if [[ -n "$PYTHON" ]]; then
    grep -q '<!doctype html>' "$TEST_ROOT/report/index.html"
    grep -q 'sample-project' "$TEST_ROOT/report/index.html"
    ! grep -q 'Unity version' "$TEST_ROOT/report/index.html"
    grep -q '"classification_model"' "$TEST_ROOT/notion/evidence.json"
    grep -q '"claims_requiring_confirmation"' "$TEST_ROOT/notion/evidence.json"
    grep -q '"kind": "fact"' "$TEST_ROOT/notion/evidence.json"
fi

printf '%s\n' 'structured reporting tests passed'
