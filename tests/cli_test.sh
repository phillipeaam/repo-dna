#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP="$(mktemp -d)"; trap 'rm -rf "$TEMP"' EXIT

[[ "$(bash "$ROOT/repodna" version)" == 'RepoDNA 1.0.0' ]]
bash "$ROOT/repodna" help | grep -q 'repodna analyze \[repository\]'
bash "$ROOT/repodna" doctor > "$TEMP/doctor.txt"
grep -q '^Git .*✓' "$TEMP/doctor.txt"
grep -q '^Bash .*✓' "$TEMP/doctor.txt"
grep -q '^Python .*✓' "$TEMP/doctor.txt"
grep -q '^Tree-sitter ' "$TEMP/doctor.txt"

mkdir -p "$TEMP/project"
bash "$ROOT/repodna" init "$TEMP/project" >/dev/null
[[ -f "$TEMP/project/.repodna-ignore" ]]
[[ -f "$TEMP/project/.repodna-authors" ]]
[[ -f "$TEMP/project/.repodna-secrets-allowlist" ]]
printf 'custom\n' > "$TEMP/project/.repodna-ignore"
bash "$ROOT/repodna" init "$TEMP/project" >/dev/null
grep -q '^custom$' "$TEMP/project/.repodna-ignore"

set +e
bash "$ROOT/repodna" unknown > /dev/null 2>&1; status=$?
set -e
[[ "$status" -eq 2 ]]

printf 'CLI tests passed\n'
