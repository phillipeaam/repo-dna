#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"; trap 'rm -rf "$TMP_DIR"' EXIT
if command -v python3 >/dev/null 2>&1 && python3 -c 'import sys' >/dev/null 2>&1; then PYTHON=python3; else PYTHON=python; fi

"$PYTHON" - "$TMP_DIR/report.json" <<'PY'
import json, sys
data = {
 "schema_version":"1.0", "generated_at":"2026-07-17", "project":{"name":"demo","type":"Python"},
 "generic_analysis":{"analysis":{
  "systems":[{"name":"Core API","path":"src/core","confidence":"high","file_count":5,"lines":400,"symbol_count":12,"import_references":8,"languages":{"Python":5},"dependency_manifests":["requirements.txt"],"evidence":["5 source files"],"confirmation_required":True}],
  "code":{"symbols":[{"name":"Application","path":"src/core/app.py","kind":"class"}]},
  "architecture":{"entrypoints":[{"path":"src/core/app.py","kind":"main"}],"coupling":{"modules":[{"module":"src/core","afferent":2,"efferent":3}]}},
  "author_system_ownership":{"relationships":[{"system":"Core API","author":"Alice","rank_in_system":1,"commits":10,"system_activity_share_percent":80.0,"confidence":"high"}]},
  "bus_factor_by_system":{"systems":[{"system":"Core API","bus_factor":1,"risk":"high_concentration","covered_activity_percent":80.0}]}
 },"git":{"system_evolution":{"Core API":{"2026-07":4}}}}
}
open(sys.argv[1],"w",encoding="utf-8").write(json.dumps(data))
PY
"$PYTHON" "$ROOT/renderers/system_documentation.py" "$TMP_DIR/report.json" "$TMP_DIR/system-docs" --schema "$ROOT/schemas/system-documentation-1.0.0.schema.json"
[[ -s "$TMP_DIR/system-docs/index.html" && -s "$TMP_DIR/system-docs/systems/core-api.html" && -s "$TMP_DIR/system-docs/data/core-api.json" ]]
"$PYTHON" - "$TMP_DIR/system-docs/systems.json" "$TMP_DIR/system-docs/data/core-api.json" "$ROOT/schemas/system-documentation-1.0.0.schema.json" <<'PY'
import json, sys
from jsonschema import Draft202012Validator
schema=json.load(open(sys.argv[3],encoding="utf-8")); validator=Draft202012Validator(schema)
catalog=json.load(open(sys.argv[1],encoding="utf-8")); system=json.load(open(sys.argv[2],encoding="utf-8"))
assert not list(validator.iter_errors(catalog)); assert not list(validator.iter_errors(system))
assert catalog["system_count"] == 1 and system["entrypoints"][0]["path"] == "src/core/app.py"
assert system["bus_factor"]["bus_factor"] == 1 and system["unknowns"]
PY
grep -q 'Confirmed repository facts' "$TMP_DIR/system-docs/systems/core-api.html"
grep -q 'Unknowns requiring confirmation' "$TMP_DIR/system-docs/systems/core-api.html"
echo "system documentation tests passed"
