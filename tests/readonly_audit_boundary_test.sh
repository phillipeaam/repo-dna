#!/usr/bin/env bash
# Acceptance harness for baseline contents. It creates and reads only its own synthetic fixture.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_ROOT="${TMPDIR:-${TEMP:-/tmp}}"
WORK_DIR="$(mktemp -d "${FIXTURE_ROOT%/}/repodna-boundary.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

REPO="$WORK_DIR/repo"
mkdir -p "$REPO"
git -C "$REPO" init -q
git -C "$REPO" config user.name "RepoDNA Fixture"
git -C "$REPO" config user.email "fixture@example.invalid"
printf 'original\n' > "$REPO/tracked.txt"
printf 'ignored.dat\n' > "$REPO/.gitignore"
git -C "$REPO" add tracked.txt .gitignore
git -C "$REPO" commit -qm "fixture baseline"
printf 'preexisting local edit\n' > "$REPO/tracked.txt"
printf 'local untracked\n' > "$REPO/untracked.txt"
printf 'local ignored\n' > "$REPO/ignored.dat"

STATUS_BEFORE="$(git -C "$REPO" status --porcelain=v1 --untracked-files=all --ignored=matching)"
grep -Fq ' M tracked.txt' <<< "$STATUS_BEFORE"
grep -Fq '?? untracked.txt' <<< "$STATUS_BEFORE"
grep -Fq '!! ignored.dat' <<< "$STATUS_BEFORE"

snapshot() {
  local root="$1" output="$2"
  (cd "$root" && find . -path './.git' -prune -o -type f -print | LC_ALL=C sort) > "$output.paths"
  : > "$output.hashes"
  while IFS= read -r relative; do
    printf '%s %s\n' "$(git -C "$root" hash-object --no-filters "$relative")" "$relative" >> "$output.hashes"
  done < "$output.paths"
}

snapshot "$REPO" "$WORK_DIR/before"
# This is the fixture's permitted read-only inspection step: enumerate/read files only.
find "$REPO" -path "$REPO/.git" -prune -o -type f -exec cat {} \; >/dev/null
snapshot "$REPO" "$WORK_DIR/after"
STATUS_AFTER="$(git -C "$REPO" status --porcelain=v1 --untracked-files=all --ignored=matching)"

cmp "$WORK_DIR/before.paths" "$WORK_DIR/after.paths"
cmp "$WORK_DIR/before.hashes" "$WORK_DIR/after.hashes"
test "$STATUS_BEFORE" = "$STATUS_AFTER"
printf 'PASS: tracked, ignored, untracked and preexisting changes remain distinguishable and unchanged.\n'
