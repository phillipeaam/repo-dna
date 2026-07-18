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
      "technical_impact": {
        "status": "assessed", "contributions_analyzed": 1,
        "contributions": [{"commit": "abc123def456", "date": "2026-01-20T10:00:00Z", "author": "Developer One", "subject": "Reduce persistence branching", "parents": 1, "systems": ["src"], "touched": {"files": 3, "source_files": 2, "test_files": 1, "documentation_files": 0, "configuration_files": 0, "dependency_manifests": 0, "binary_files": 0, "additions": 20, "deletions": 35, "churn": 55}, "before": {"source_lines": 180, "estimated_complexity": 24}, "after": {"source_lines": 165, "estimated_complexity": 20}, "delta": {"source_lines": -15, "estimated_complexity": -4}, "signals": ["tests_changed", "estimated_complexity_reduced"], "measurement_confidence": "high"}]
      },
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
      "author_system_ownership": {
        "status": "assessed",
        "summary": {"authors": 2, "systems": 1, "relationships": 2, "high_confidence_relationships": 1},
        "relationships": [
          {"author": "Developer One", "system": "Data/Persistence", "rank_in_system": 1, "commits": 24, "churn": 1800, "files_touched": 8, "system_activity_share_percent": 80.0, "author_focus_percent": 60.0, "confidence": "high", "confidence_score": 100, "system_confidence": "high"},
          {"author": "Developer Two", "system": "Data/Persistence", "rank_in_system": 2, "commits": 6, "churn": 300, "files_touched": 3, "system_activity_share_percent": 20.0, "author_focus_percent": 35.0, "confidence": "medium", "confidence_score": 63, "system_confidence": "high"}
        ]
      },
      "bus_factor_by_system": {
        "status": "assessed", "threshold_percent": 75.0,
        "summary": {"systems_assessed": 1, "critical_systems": 1, "minimum_bus_factor": 1},
        "systems": [{"system": "Data/Persistence", "bus_factor": 1, "risk": "high_concentration", "authors_with_activity": 2, "total_commit_touches": 30, "covered_activity_percent": 80.0, "critical_authors": [{"author": "Developer One", "activity_share_percent": 80.0, "commits": 24, "files_touched": 8}], "confidence": "high", "system_confidence": "high"}],
        "method": "75% activity threshold", "limitations": []
      },
      "personal_achievement_candidates": {
        "status": "candidates_generated", "author": "Developer One", "summary": {"candidates": 1, "high_confidence": 1, "medium_confidence": 0, "low_confidence": 0},
        "candidates": [{"id": "system-data-persistence", "category": "system_contribution", "title": "Contribution to Data/Persistence", "draft_statement": "Contributed historical changes to Data/Persistence across 24 commit touches and 8 files.", "factual_basis": ["60% author focus"], "metrics": {"commit_touches": 24, "files_touched": 8, "churn": 1800, "author_focus_percent": 60.0}, "evidence": ["#/analysis/author_system_ownership"], "confidence": "high", "confirmation_required": true, "required_confirmations": ["Confirm actual responsibility.", "Describe the outcome."], "xyz_inputs": {"accomplished_x": "requires confirmation", "measured_by_y": {"commit_touches": 24}, "by_doing_z": "requires confirmation"}}]
      },
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
        "coverage": {"status": "imported", "line_coverage_percent": 82, "reports": [{"path": "coverage-summary.json", "tool": "Istanbul", "metrics": {"lines": {"percent": 82}, "branches": {"percent": 60}, "functions": {"percent": 75}}}]},
        "tests": {"status": "imported", "total": 10, "passed": 8, "failed": 1, "errors": 0, "skipped": 1, "reports": [{"path": "junit.xml", "tool": "JUnit XML", "total": 10, "passed": 8, "failed": 1, "errors": 0, "skipped": 1, "duration_seconds": 2.5}]},
        "linters": {"status": "imported", "issues": 2, "reports": [{"path": "eslint-report.json", "tool": "ESLint", "issues": 2, "affected_files": 1, "severities": {"error": 1, "warning": 1}}]},
        "vulnerabilities": {"status": "imported", "findings": 1, "reports": [{"path": "npm-audit.json", "tool": "npm audit", "findings": 1, "severities": {"high": 1}}]},
        "dependency_licenses": {"status": "imported", "packages": [{"name": "lodash", "version": "4.17.20", "licenses": ["MIT"], "source": "license-checker"}]},
        "dependency_resolution": {
          "summary": {"dependencies": 2, "direct_dependencies": 2, "affected_dependencies": 1, "license_resolved": 1, "license_review_required": 0, "license_unresolved": 1},
          "dependencies": [
            {"name": "lodash", "direct": true, "versions": ["4.17.20"], "vulnerability_status": "affected", "vulnerability_count": 1, "vulnerabilities": [{"id": "CVE-TEST-1", "severity": "high", "source": "npm audit"}], "license_status": "resolved", "license_category": "permissive", "licenses": ["MIT"], "sources": ["npm audit", "license-checker"]},
            {"name": "requests", "direct": true, "versions": [], "vulnerability_status": "not_resolved", "vulnerability_count": 0, "vulnerabilities": [], "license_status": "unresolved", "license_category": "unresolved", "licenses": [], "sources": []}
          ]
        },
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
"$PYTHON" "$SOURCE_ROOT/renderers/canonical_model.py" "$TEST_ROOT/report.json"
"$PYTHON" "$SOURCE_ROOT/renderers/html.py" "$TEST_ROOT/report.json" "$TEST_ROOT/report/index.html"
"$PYTHON" - "$TEST_ROOT/report.json" "$TEST_ROOT/unity-report.json" "$TEST_ROOT/android-report.json" "$TEST_ROOT/flutter-report.json" <<'PY'
import json, sys
data=json.load(open(sys.argv[1],encoding="utf-8"))
data["analysis_profile"]["unity"]=True
data["project"]["type"]="Unity"
data["specialized_analysis"]["unity"]={
 "status":"assessed",
 "configuration":{"build":{"enabled_scene_count":1,"enabled_scenes":["Assets/Scenes/Main.unity"]},"rendering":{"pipeline":"URP"},"input":{"system":"New Input System"},"packages":{"com.unity.inputsystem":"1.11.2"},"quality_levels":["High"],"assemblies":{"asmdef_count":2,"test_assemblies":["Assets/Tests.asmdef"]},"native_plugins":[]},
 "gameplay_systems":[{"name":"Combat","confidence":"high","file_count":18,"score":40,"primary_directories":["Assets/_Project/Combat"],"git":{"matching_commit_touches":42,"frequently_changed_files":[{"path":"Assets/_Project/Combat/Damage.cs","commits":11}]}}],
 "signals":[{"type":"linq_in_frame_method","confidence":"medium","path":"Assets/_Project/Combat/Damage.cs","occurrences":1,"lines":[42],"rationale":"Review with profiling."}]
}
json.dump(data,open(sys.argv[2],"w",encoding="utf-8"))
android=json.load(open(sys.argv[1],encoding="utf-8"))
android["analysis_profile"]["android"]=True
android["project"]["type"]="Android"
json.dump(android,open(sys.argv[3],"w",encoding="utf-8"))
flutter=json.load(open(sys.argv[1],encoding="utf-8"))
flutter["analysis_profile"]["flutter"]=True
flutter["project"]["type"]="Flutter"
json.dump(flutter,open(sys.argv[4],"w",encoding="utf-8"))
PY
"$PYTHON" "$SOURCE_ROOT/renderers/html.py" "$TEST_ROOT/unity-report.json" "$TEST_ROOT/unity-report/index.html"
"$PYTHON" "$SOURCE_ROOT/renderers/html.py" "$TEST_ROOT/android-report.json" "$TEST_ROOT/android-report/index.html"
"$PYTHON" "$SOURCE_ROOT/renderers/html.py" "$TEST_ROOT/flutter-report.json" "$TEST_ROOT/flutter-report/index.html"
"$PYTHON" "$SOURCE_ROOT/renderers/notion.py" "$TEST_ROOT/report.json" "$TEST_ROOT/notion/evidence.json"
"$PYTHON" "$SOURCE_ROOT/renderers/llm_evidence.py" "$TEST_ROOT/report.json" "$TEST_ROOT/llm/evidence.json" --schema "$SOURCE_ROOT/schemas/llm-evidence-1.0.0.schema.json"
"$PYTHON" "$SOURCE_ROOT/renderers/snapshot.py" "$TEST_ROOT/report.json" "$TEST_ROOT/snapshots/fixture.json" --schema "$SOURCE_ROOT/schemas/analysis-snapshot-1.0.0.schema.json" --commit 0123456789abcdef0123456789abcdef01234567 --branch feature/test
"$PYTHON" "$SOURCE_ROOT/renderers/system_documentation.py" "$TEST_ROOT/report.json" "$TEST_ROOT/system-docs" --schema "$SOURCE_ROOT/schemas/system-documentation-1.0.0.schema.json"
"$PYTHON" "$SOURCE_ROOT/renderers/onboarding.py" "$TEST_ROOT/report.json" "$TEST_ROOT/onboarding" --schema "$SOURCE_ROOT/schemas/onboarding-dataset-1.0.0.schema.json"
"$PYTHON" - "$TEST_ROOT/snapshots/fixture.json" "$SOURCE_ROOT/schemas/analysis-snapshot-1.0.0.schema.json" <<'PY'
import json
import sys
from pathlib import Path
from jsonschema import Draft202012Validator

snapshot = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
schema = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
assert not list(Draft202012Validator(schema).iter_errors(snapshot))
assert snapshot["schema_version"] == "1.0.0"
assert snapshot["repository"]["commit"] == "0123456789abcdef0123456789abcdef01234567"
assert snapshot["repository"]["branch"] == "feature/test"
assert snapshot["inventory"]["files"] == 25
assert snapshot["health"]["score"] == 72.5
assert snapshot["git"]["technical_impact_summary"] == {}
assert "contributions" not in snapshot["git"]
PY
"$PYTHON" - "$TEST_ROOT/llm/evidence.json" <<'PY'
import json
import sys
from copy import deepcopy
from pathlib import Path
from jsonschema import Draft202012Validator

data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
schema = json.loads(Path("schemas/llm-evidence-1.0.0.schema.json").read_text(encoding="utf-8"))
Draft202012Validator.check_schema(schema)
validator = Draft202012Validator(schema)
assert not list(validator.iter_errors(data))
items = data["evidence_items"]
assert data["evidence_summary"]["items"] == len(items)
assert data["schema_version"] == "1.0.0" and data["$schema"] == "./schema.json"
assert sum(data["evidence_summary"]["by_kind"].values()) == len(items)
assert all(item["evidence"] for item in items)
assert all(row["source"] == "report/data/report.json" and row["pointer"].startswith("#/") for item in items for row in item["evidence"])
candidate = next(item for item in items if item["kind"] == "candidate")
assert candidate["confirmation_required"] is True
assert candidate["id"] == "achievement-system-data-persistence"
assert data["human_confirmation"]["achievement_status"] == "candidates_generated"
assert "Reduce persistence branching" not in Path(sys.argv[1]).read_text(encoding="utf-8")
invalid = deepcopy(data)
invalid["schema_version"] = "9.9.9"
assert any(list(error.absolute_path) == ["schema_version"] for error in validator.iter_errors(invalid))
PY
"$PYTHON" "$SOURCE_ROOT/renderers/portfolio.py" "$TEST_ROOT/report.json" "$TEST_ROOT/portfolio/draft.json" "$TEST_ROOT/portfolio/index.html"
"$PYTHON" - "$TEST_ROOT/report.json" "$TEST_ROOT/notion/evidence.json" "$TEST_ROOT/llm/evidence.json" "$TEST_ROOT/onboarding/dataset.json" "$TEST_ROOT/portfolio/draft.json" "$TEST_ROOT/system-docs/systems.json" "$TEST_ROOT/snapshots/fixture.json" <<'PY'
import json, sys
documents = [json.load(open(path, encoding="utf-8")) for path in sys.argv[1:]]
canonical = documents[0]["canonical_metrics"]
for document in documents[1:5]:
    assert document["canonical_metrics"] == canonical
assert documents[5]["canonical_metrics"] == canonical
assert documents[5]["system_count"] == canonical["system_count"]
assert documents[6]["canonical_metrics"] == canonical
PY
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
    system-documentation.html \
    onboarding.html \
    graphs.html \
    contribution.html \
    collaboration.html \
    quality.html \
    health.html \
    health-trends.html \
    narrative.html \
    portfolio.html \
    charts.html \
    risks.html \
    notion-evidence.html; do
    [[ -s "$TEST_ROOT/report/$report_name" ]]
done
[[ -s "$TEST_ROOT/report/contributors-1.html" ]]

grep -q '<!doctype html>' "$TEST_ROOT/report/index.html"
! grep -q 'C# files</span>' "$TEST_ROOT/report/executive-summary.html"
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
grep -q 'system-docs/index.html' "$TEST_ROOT/report/system-documentation.html"
grep -q 'onboarding/index.html' "$TEST_ROOT/report/onboarding.html"
[[ -s "$TEST_ROOT/onboarding/index.html" && -s "$TEST_ROOT/onboarding/dataset.json" ]]
grep -q 'Data/Persistence' "$TEST_ROOT/system-docs/index.html"
[[ -s "$TEST_ROOT/system-docs/systems/data-persistence.html" ]]
[[ -s "$TEST_ROOT/system-docs/data/data-persistence.json" ]]
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
grep -q 'Technical impact before and after each contribution' "$TEST_ROOT/report/contribution.html"
grep -q 'Personal achievement candidates' "$TEST_ROOT/report/contribution.html"
grep -q 'Contribution to Data/Persistence' "$TEST_ROOT/report/contribution.html"
grep -q 'Reduce persistence branching' "$TEST_ROOT/report/contribution.html"
grep -q 'estimated_complexity_reduced' "$TEST_ROOT/report/contribution.html"
grep -q 'Score</th><th>Commits</th><th>Churn</th><th>Lines</th><th>Authors</th><th>Days since change' "$TEST_ROOT/report/contribution.html"
grep -q 'Repository facts' "$TEST_ROOT/report/notion-evidence.html"
grep -q 'What was your formal mission?' "$TEST_ROOT/report/notion-evidence.html"
grep -q 'paginated contributor directory' "$TEST_ROOT/report/collaboration.html"
grep -q 'Author and system activity ownership' "$TEST_ROOT/report/collaboration.html"
grep -q 'Bus factor by system' "$TEST_ROOT/report/collaboration.html"
grep -q 'high_concentration' "$TEST_ROOT/report/collaboration.html"
grep -q 'Developer One' "$TEST_ROOT/report/collaboration.html"
grep -q '80.00%' "$TEST_ROOT/report/collaboration.html"
grep -q 'historical activity ownership' "$TEST_ROOT/report/collaboration.html"
grep -q 'Developer One' "$TEST_ROOT/report/contributors-1.html"
grep -q 'Page 1 of 1' "$TEST_ROOT/report/contributors-1.html"
grep -q 'not_scanned is not equivalent to zero vulnerabilities' "$TEST_ROOT/report/quality.html"
grep -q 'Imported coverage reports' "$TEST_ROOT/report/quality.html"
grep -q 'Istanbul' "$TEST_ROOT/report/quality.html"
grep -q 'Imported test results' "$TEST_ROOT/report/quality.html"
grep -q 'JUnit XML' "$TEST_ROOT/report/quality.html"
grep -q 'Imported linter results' "$TEST_ROOT/report/quality.html"
grep -q 'ESLint' "$TEST_ROOT/report/quality.html"
grep -q 'Imported scanner results' "$TEST_ROOT/report/quality.html"
grep -q 'npm audit' "$TEST_ROOT/report/quality.html"
grep -q 'Vulnerabilities and licenses by dependency' "$TEST_ROOT/report/quality.html"
grep -q 'CVE-TEST-1' "$TEST_ROOT/report/quality.html"
grep -q 'not_resolved.*does not mean the dependency is vulnerability-free' "$TEST_ROOT/report/quality.html"
grep -q 'High-complexity functions (AST)' "$TEST_ROOT/report/quality.html"
grep -q 'Repository health' "$TEST_ROOT/report/health.html"
grep -q 'health-trends/index.html' "$TEST_ROOT/report/health-trends.html"
grep -q 'No business impact or personal ownership is invented' "$TEST_ROOT/report/narrative.html"
grep -q 'portfolio/index.html' "$TEST_ROOT/report/portfolio.html"
grep -q 'commits_by_month.png' "$TEST_ROOT/report/charts.html"
grep -q 'class="chart"' "$TEST_ROOT/report/charts.html"
grep -q 'confirmation_required' "$TEST_ROOT/portfolio/draft.json"
grep -q 'Portfolio and CV evidence draft' "$TEST_ROOT/portfolio/index.html"
grep -q 'Author-filtered achievement candidates' "$TEST_ROOT/portfolio/index.html"
grep -q 'system-data-persistence' "$TEST_ROOT/portfolio/draft.json"
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
[[ ! -e "$TEST_ROOT/report/unity-analysis.html" ]]
[[ ! -e "$TEST_ROOT/report/android-analysis.html" ]]
[[ ! -e "$TEST_ROOT/report/flutter-analysis.html" ]]
[[ -s "$TEST_ROOT/unity-report/unity-analysis.html" ]]
[[ -s "$TEST_ROOT/android-report/android-analysis.html" ]]
grep -q 'android/index.html' "$TEST_ROOT/android-report/android-analysis.html"
[[ -s "$TEST_ROOT/flutter-report/flutter-analysis.html" ]]
grep -q 'flutter/index.html' "$TEST_ROOT/flutter-report/flutter-analysis.html"
grep -q 'Combat' "$TEST_ROOT/unity-report/unity-analysis.html"
grep -q '42' "$TEST_ROOT/unity-report/unity-analysis.html"
grep -q 'heuristic review signals, not confirmed bugs' "$TEST_ROOT/unity-report/unity-analysis.html"
grep -q 'href="index.html"' "$TEST_ROOT/report/architecture.html"
grep -q 'href="technologies.html"' "$TEST_ROOT/report/architecture.html"
grep -q '"classification_model"' "$TEST_ROOT/notion/evidence.json"
grep -q '"claims_requiring_confirmation"' "$TEST_ROOT/notion/evidence.json"
grep -q '"kind": "fact"' "$TEST_ROOT/notion/evidence.json"
grep -q '"artifact_type": "repodna_llm_evidence"' "$TEST_ROOT/llm/evidence.json"
grep -q '"schema_version": "1.0.0"' "$TEST_ROOT/llm/evidence.json"
grep -q '"artifact_type": "repodna_analysis_snapshot"' "$TEST_ROOT/snapshots/fixture.json"
grep -q '"llm_contract"' "$TEST_ROOT/llm/evidence.json"
grep -q '"kind": "inference"' "$TEST_ROOT/llm/evidence.json"
grep -q '"kind": "candidate"' "$TEST_ROOT/llm/evidence.json"
grep -q 'report/data/report.json' "$TEST_ROOT/llm/evidence.json"
grep -q 'system-data-persistence' "$TEST_ROOT/llm/evidence.json"
grep -q 'Never convert inference or candidate into fact' "$TEST_ROOT/llm/evidence.json"

printf '%s\n' 'structured reporting tests passed'
