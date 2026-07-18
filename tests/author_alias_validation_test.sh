#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; TEMP="$(mktemp -d -p "$ROOT" .authors-test.XXXXXX)"; trap 'rm -rf "$TEMP"' EXIT

validate_case() {
    local name="$1" expected="$2"
    if python - "$ROOT" "$TEMP/$name" <<'PY' >/dev/null 2>"$TEMP/error.txt"
import sys
from pathlib import Path
sys.path.insert(0, str(Path(sys.argv[1]) / "collectors"))
from generic import load_author_aliases
load_author_aliases(Path(sys.argv[2]))
PY
    then
        echo "$name: invalid author file was accepted" >&2; return 1
    fi
    grep -q "$expected" "$TEMP/error.txt" || { cat "$TEMP/error.txt" >&2; return 1; }
}

mkdir -p "$TEMP/valid"
cat > "$TEMP/valid/.repodna-authors" <<'EOF'
# Canonical identities are case-insensitive.
Phillipe Augusto:
  names:
    - Phillipe Augusto de Araújo Mendonça
    - phillipe
  emails:
    - phillipe@example.test
EOF
python - "$ROOT" "$TEMP/valid" <<'PY'
import sys
from pathlib import Path
sys.path.insert(0, str(Path(sys.argv[1]) / "collectors"))
from generic import load_author_aliases
names, emails = load_author_aliases(Path(sys.argv[2]))
assert names["phillipe"] == "Phillipe Augusto"
assert emails["phillipe@example.test"] == "Phillipe Augusto"
PY

for name in unknown empty duplicate collision invalid_email empty_section; do mkdir -p "$TEMP/$name"; done
printf 'Person:\n  handles:\n    - person\n' > "$TEMP/unknown/.repodna-authors"
printf 'Person:\n  names:\n    - ""\n' > "$TEMP/empty/.repodna-authors"
printf 'Person:\n  names:\n    - alias\n    - Alias\n' > "$TEMP/duplicate/.repodna-authors"
printf 'First:\n  emails:\n    - shared@example.test\nSecond:\n  emails:\n    - SHARED@example.test\n' > "$TEMP/collision/.repodna-authors"
printf 'Person:\n  emails:\n    - not-an-email\n' > "$TEMP/invalid_email/.repodna-authors"
printf 'Person:\n  names:\n  emails:\n    - person@example.test\n' > "$TEMP/empty_section/.repodna-authors"

validate_case unknown "unknown section 'handles'"
validate_case empty 'alias cannot be empty'
validate_case duplicate 'duplicate name alias'
validate_case collision 'duplicate email alias'
validate_case invalid_email 'invalid email alias'
validate_case empty_section 'must contain at least one alias'

# The CLI must fail before emitting a report when aliases are invalid.
mkdir -p "$TEMP/repository"; cp "$TEMP/collision/.repodna-authors" "$TEMP/repository/"
if python "$ROOT/collectors/generic.py" "$TEMP/repository" "$TEMP/output.json" 2>"$TEMP/cli-error.txt"; then
    echo 'generic collector accepted conflicting author identities' >&2; exit 1
fi
grep -q '.repodna-authors:6' "$TEMP/cli-error.txt"
[[ ! -f "$TEMP/output.json" ]]
echo 'author alias validation tests passed'
