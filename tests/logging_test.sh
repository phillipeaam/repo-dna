#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP="$(mktemp -d)"; trap 'rm -rf "$TEMP"' EXIT

source "$ROOT/src/core/logging.sh"
REPODNA_LOG_LEVEL=DEBUG
logger_init
logger_attach_file "$TEMP/repodna-debug.log"
log_debug 'request=https://internal.example token=super-secret-value user@example.com C:\Users\Private\repo' >/dev/null
logger_cleanup

grep -q '\[DEBUG\]' "$TEMP/repodna-debug.log"
grep -q '\[REDACTED_URL\]' "$TEMP/repodna-debug.log"
grep -q '\[REDACTED_EMAIL\]' "$TEMP/repodna-debug.log"
grep -q '\[REDACTED_PATH\]' "$TEMP/repodna-debug.log"
grep -q 'token=\[REDACTED\]' "$TEMP/repodna-debug.log"
! grep -q 'super-secret-value\|internal.example\|user@example.com\|Users\\Private' "$TEMP/repodna-debug.log"

REPOSITORY="$TEMP/repository"; OUTPUT="$TEMP/debug report"
cp -R "$ROOT/tests/fixtures/generic-repo" "$REPOSITORY"
git -C "$REPOSITORY" init -q
git -C "$REPOSITORY" config user.name 'Private Test Author'
git -C "$REPOSITORY" config user.email 'private.author@example.invalid'
git -C "$REPOSITORY" add .
git -C "$REPOSITORY" commit -qm 'fixture'

bash "$ROOT/repodna" analyze "$REPOSITORY" --output "$OUTPUT" --no-history --no-graphs --debug > "$TEMP/cli.log" 2>&1
[[ -s "$OUTPUT/logs/repodna-debug.log" ]]
grep -q '\[INFO\] Reading repository and project metadata' "$OUTPUT/logs/repodna-debug.log"
grep -q '\[DEBUG\] Repository inventory collected' "$OUTPUT/logs/repodna-debug.log"
! grep -q 'private.author@example.invalid\|Private Test Author' "$OUTPUT/logs/repodna-debug.log"
! grep -q '^+ ' "$TEMP/cli.log"
printf 'Logging tests passed\n'
