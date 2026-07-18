#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .quality-import-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

printf '%s\n' '{"total":{"lines":{"total":100,"covered":82,"pct":82},"statements":{"total":110,"covered":88,"pct":80},"functions":{"total":20,"covered":15,"pct":75},"branches":{"total":30,"covered":18,"pct":60}}}' > "$TEST_ROOT/coverage-summary.json"
printf '%s\n' '{"$schema":"./test-execution-1.0.0.schema.json","schema_version":"1.0","artifact_type":"repodna_test_execution","started_at":"2026-07-18T00:00:00Z","test_execution":{"status":"passed","total":41,"passed":41,"failed":0,"skipped":0,"duration_seconds":18.4},"tests":[]}' > "$TEST_ROOT/repodna-test-results.json"
printf '%s\n' '<testsuites><testsuite name="unit" tests="10" failures="1" errors="1" skipped="2" time="3.5"/></testsuites>' > "$TEST_ROOT/junit.xml"
printf '%s\n' '[{"filePath":"src/app.ts","messages":[{"severity":2},{"severity":1}]}]' > "$TEST_ROOT/eslint-report.json"
printf '%s\n' '{"vulnerabilities":{"lodash":{"severity":"high","via":[{"source":12345,"severity":"high"}]}}}' > "$TEST_ROOT/npm-audit.json"
printf '%s\n' '{"lodash@4.17.20":{"licenses":"MIT"},"copyleft-lib@1.0.0":{"licenses":"GPL-3.0-only"}}' > "$TEST_ROOT/license-checker.json"

PYTHONPATH="$SOURCE_ROOT/collectors" TEST_ROOT="$TEST_ROOT" python - <<'PY'
import os
from pathlib import Path

from quality import import_quality_results
from quality.importers import _normalized_package

assert _normalized_package("pkg:npm/%40scope/package@1.2.3") == "@scope/package"
assert _normalized_package("pkg:pypi/Requests@2.32.0") == "requests"
assert _normalized_package("pkg:maven/org.example/library@1.0.0") == "org.example:library"

dependencies = {"manifests": [{"path": "package.json", "dependencies": ["lodash", "requests"]}], "total": 2}
quality = import_quality_results(Path(os.environ["TEST_ROOT"]), dependencies)
coverage = quality["coverage"]
assert coverage["status"] == "imported"
assert coverage["line_coverage_percent"] == 82
assert coverage["reports"][0]["tool"] == "Istanbul"
tests = quality["tests"]
assert tests["status"] == "imported"
assert tests["execution_status"] == "failed"
assert (tests["total"], tests["passed"], tests["failed"], tests["errors"], tests["skipped"]) == (51, 47, 1, 1, 2)
assert tests["duration_seconds"] == 21.9
runner = next(item for item in tests["reports"] if item["tool"] == "RepoDNA test runner")
assert runner["total"] == 41 and runner["passed"] == 41

linters = quality["linters"]
assert linters["status"] == "imported" and linters["issues"] == 2
assert linters["severities"] == {"error": 1, "warning": 1}

security = quality["vulnerabilities"]
assert security["status"] == "imported" and security["findings"] == 1
assert security["severities"] == {"high": 1}

licenses = quality["dependency_licenses"]
assert licenses["status"] == "imported" and len(licenses["packages"]) == 2
resolution = quality["dependency_resolution"]
by_name = {item["name"]: item for item in resolution["dependencies"]}
assert resolution["summary"] == {"dependencies": 3, "direct_dependencies": 2, "affected_dependencies": 1, "license_resolved": 2, "license_review_required": 1, "license_unresolved": 1}
assert by_name["lodash"]["vulnerability_status"] == "affected"
assert by_name["lodash"]["vulnerabilities"] == [{"id": "12345", "severity": "high", "source": "npm audit"}]
assert by_name["lodash"]["license_category"] == "permissive"
assert by_name["requests"]["vulnerability_status"] == "not_resolved"
assert by_name["requests"]["license_status"] == "unresolved"
assert by_name["copyleft-lib"]["direct"] is False
assert by_name["copyleft-lib"]["license_category"] == "review_required"
PY

printf '%s\n' 'quality importer tests passed'
