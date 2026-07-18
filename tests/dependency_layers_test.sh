#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP="$(mktemp -d)"; trap 'rm -rf "$TEMP"' EXIT
OUTPUT="$TEMP/partial report"
REPOSITORY="$TEMP/repository"
cp -R "$ROOT/tests/fixtures/generic-repo" "$REPOSITORY"
git -C "$REPOSITORY" init -q
git -C "$REPOSITORY" config user.name 'RepoDNA Test'
git -C "$REPOSITORY" config user.email 'repodna@example.invalid'
git -C "$REPOSITORY" add .
git -C "$REPOSITORY" commit -qm 'fixture'

set +e
REPO_DNA_PYTHON="$TEMP/missing-python" bash "$ROOT/dna-analysis.sh" \
    "$REPOSITORY" --output "$OUTPUT" --no-graphs > "$TEMP/run.log" 2>&1
status=$?
set -e

[[ "$status" -eq 5 ]]
[[ -f "$OUTPUT/report/index.html" ]]
[[ -f "$OUTPUT/report/data/report.json" ]]
grep -q '"status": "partial"' "$OUTPUT/report/data/report.json"
grep -q 'recommended Python reporting runtime is unavailable' "$TEMP/run.log"
grep -q 'Status: partial analysis' "$TEMP/run.log"
printf 'Dependency-layer tests passed\n'
