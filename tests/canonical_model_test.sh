#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON="${PYTHON:-python}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/report.json" <<'JSON'
{"generic_analysis":{"languages":[{"name":"Python"},{"name":"Shell"}],"configuration_file_count":4,"test_file_count":7,"dependencies":{"total":11},"analysis":{"frameworks":{"detected":[{"name":"Django"}]},"systems":[{"name":"api"},{"name":"worker"}]}},"technologies":{"dependency_count":999}}
JSON

"$PYTHON" "$ROOT/renderers/canonical_model.py" "$TMP/report.json"
"$PYTHON" - "$TMP/report.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["canonical_metrics"] == {"technology_count":3,"dependency_count":11,"system_count":2,"configuration_file_count":4,"test_file_count":7}
assert data["technologies"]["dependency_count"] == 11
PY
echo "canonical model tests passed"
