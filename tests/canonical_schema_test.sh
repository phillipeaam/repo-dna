#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; ROOT="$(cd "$TEST_DIR/.." && pwd)"
TEMP="$(mktemp -d -p "$ROOT" .schema-test.XXXXXX)"; trap 'rm -rf "$TEMP"' EXIT
mkdir -p "$TEMP/repository"; printf 'print("ok")\n' > "$TEMP/repository/app.py"
git -C "$TEMP/repository" init -q; git -C "$TEMP/repository" config user.name Fixture; git -C "$TEMP/repository" config user.email fixture@example.test
git -C "$TEMP/repository" add .; git -C "$TEMP/repository" commit -qm Initial
python "$ROOT/collectors/generic.py" "$TEMP/repository" "$TEMP/generic.json"
python "$ROOT/renderers/validate_json.py" "$TEMP/generic.json" "$ROOT/schemas/generic-analysis-1.1.0.schema.json"
python - "$TEMP/generic.json" "$TEMP/invalid.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1],encoding="utf-8")); data.pop("analysis")
json.dump(data,open(sys.argv[2],"w",encoding="utf-8"))
PY
if python "$ROOT/renderers/validate_json.py" "$TEMP/invalid.json" "$ROOT/schemas/generic-analysis-1.1.0.schema.json" >/dev/null 2>&1; then
    echo 'validator accepted a generic analysis without its required analysis field' >&2; exit 1
fi
echo 'canonical JSON schema tests passed'
