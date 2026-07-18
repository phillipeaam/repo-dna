#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; TMP_DIR="$(mktemp -d)"; trap 'rm -rf "$TMP_DIR"' EXIT
if command -v python3 >/dev/null 2>&1 && python3 -c 'import sys' >/dev/null 2>&1; then PYTHON=python3; else PYTHON=python; fi
mkdir -p "$TMP_DIR/repo/src" "$TMP_DIR/repo/docs"
printf '%s' '{"scripts":{"test":"pytest","dev":"python app.py"}}' > "$TMP_DIR/repo/package.json"
printf '%s\n' 'lint:' '\tpython -m ruff check .' > "$TMP_DIR/repo/Makefile"
printf '%s\n' 'print("hello")' > "$TMP_DIR/repo/src/app.py"
"$PYTHON" - "$ROOT" "$TMP_DIR" <<'PY'
import json, sys
from pathlib import Path
sys.path.insert(0, str(Path(sys.argv[1]) / "collectors"))
from onboarding import collect_onboarding
root=Path(sys.argv[2]) / "repo"
files=[{"path":"package.json"},{"path":"Makefile"},{"path":"src/app.py"}]
result=collect_onboarding(root, files, {"manifests":[{"path":"package.json"}]})
by_command={item["command"]:item for item in result["commands"]}
assert by_command["npm run test"]["classification"] == "declared"
assert by_command["make lint"]["classification"] == "declared"
assert by_command["npm install"]["classification"] == "suggested" and by_command["npm install"]["confirmation_required"]
report={"schema_version":"1.0","generated_at":"2026-07-17","privacy":{"mode":"standard"},"project":{"name":"demo","type":"Node","code_root":"."},"generic_analysis":{"documentation_files":["README.md"],"configuration_files":["package.json"],"test_files":["tests/app.test.js"],"ci_cd_files":[".github/workflows/ci.yml"],"docker_files":[],"dependencies":{"manifests":[{"path":"package.json","dependency_count":2}]},"possible_modules":[{"path":"src","file_count":2,"languages":{"JavaScript":2}}],"largest_files":[{"path":"src/app.js"}],"git":{"contributors":[],"author_aliases_configured":0},"analysis":{"onboarding":result,"systems":[],"architecture":{"entrypoints":[{"path":"src/app.js","kind":"application"}],"boundaries":{"summary":{}}},"graphs":{"summary":{}},"quality":{},"bus_factor_by_system":{"summary":{}}}}}
(Path(sys.argv[2]) / "report.json").write_text(json.dumps(report),encoding="utf-8")
PY
"$PYTHON" "$ROOT/renderers/onboarding.py" "$TMP_DIR/report.json" "$TMP_DIR/output" --schema "$ROOT/schemas/onboarding-dataset-1.0.0.schema.json"
grep -q 'npm run test' "$TMP_DIR/output/index.html"; grep -q 'suggested' "$TMP_DIR/output/index.html"
grep -q 'repodna_onboarding_dataset' "$TMP_DIR/output/dataset.json"
echo "onboarding tests passed"
