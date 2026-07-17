#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .quality-import-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

printf '%s\n' '{"total":{"lines":{"total":100,"covered":82,"pct":82},"statements":{"total":110,"covered":88,"pct":80},"functions":{"total":20,"covered":15,"pct":75},"branches":{"total":30,"covered":18,"pct":60}}}' > "$TEST_ROOT/coverage-summary.json"
printf '%s\n' '<testsuites><testsuite name="unit" tests="10" failures="1" errors="1" skipped="2" time="3.5"/></testsuites>' > "$TEST_ROOT/junit.xml"
printf '%s\n' '[{"filePath":"src/app.ts","messages":[{"severity":2},{"severity":1}]}]' > "$TEST_ROOT/eslint-report.json"
printf '%s\n' '{"metadata":{"vulnerabilities":{"info":0,"low":1,"moderate":2,"high":1,"critical":0,"total":4}}}' > "$TEST_ROOT/npm-audit.json"

PYTHONPATH="$SOURCE_ROOT/collectors" TEST_ROOT="$TEST_ROOT" python - <<'PY'
import os
from pathlib import Path

from quality import import_quality_results

quality = import_quality_results(Path(os.environ["TEST_ROOT"]), 1)
coverage = quality["coverage"]
assert coverage["status"] == "imported"
assert coverage["line_coverage_percent"] == 82
assert coverage["reports"][0]["tool"] == "Istanbul"

tests = quality["tests"]
assert tests["status"] == "imported"
assert (tests["total"], tests["passed"], tests["failed"], tests["errors"], tests["skipped"]) == (10, 6, 1, 1, 2)

linters = quality["linters"]
assert linters["status"] == "imported" and linters["issues"] == 2
assert linters["severities"] == {"error": 1, "warning": 1}

security = quality["vulnerabilities"]
assert security["status"] == "imported" and security["findings"] == 4
assert security["severities"]["high"] == 1 and security["severities"]["medium"] == 2
assert "total" not in security["severities"]
PY

printf '%s\n' 'quality importer tests passed'
