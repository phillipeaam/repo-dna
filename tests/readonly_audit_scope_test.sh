#!/usr/bin/env bash
# Static contract acceptance: never probes or writes to a selected/real repository.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTRACT="$ROOT_DIR/specs/001-readonly-audit-framework/contracts/readonly-boundary.md"
MATRIX="$ROOT_DIR/tests/fixtures/readonly-audit/README.md"
TASKS="$ROOT_DIR/specs/001-readonly-audit-framework/tasks.md"
WORK_DIR="$(mktemp -d "${TMPDIR:-${TEMP:-/tmp}}/repodna-scope.XXXXXX")"
trap 'chmod -R u+w "$WORK_DIR" 2>/dev/null || true; rm -rf "$WORK_DIR"' EXIT

for file in "$CONTRACT" "$MATRIX" "$TASKS"; do
  test -f "$file" || { printf 'FAIL: missing contract input: %s\n' "$file" >&2; exit 1; }
done

for term in 'symlinks/junctions' 'Git directory/worktree/object store' 'submódulo' 'host' 'bloquear'; do
  grep -Fqi "$term" "$CONTRACT" || { printf 'FAIL: readonly contract missing scope term: %s\n' "$term" >&2; exit 1; }
done
for term in 'Windows' 'Linux' 'macOS' 'unverified' 'SC-013'; do
  grep -Fqi "$term" "$MATRIX" || { printf 'FAIL: host matrix missing profile evidence: %s\n' "$term" >&2; exit 1; }
done
grep -Fq 'continuar com status de preservação não verificado' "$CONTRACT"
grep -Fq 'analysis-output/' "$CONTRACT"
grep -Fiq 'antes da leitura substantiva' "$CONTRACT"
grep -Fq 'em cada perfil suportado' "$TASKS"

# Exercise a deny-write probe only against disposable test data, never a selected repository.
TARGET="$WORK_DIR/target"
GIT_DIR="$WORK_DIR/git-metadata"
OUTPUT="$WORK_DIR/analysis-output"
mkdir -p "$TARGET" "$GIT_DIR" "$OUTPUT"
printf 'fixture\n' > "$TARGET/existing.txt"
printf 'git fixture\n' > "$GIT_DIR/existing.txt"
chmod -R a-w "$TARGET" "$GIT_DIR"

check_denied() {
  local path="$1" operation="$2" original="$3" probe
  case "$operation" in
    create)
      probe="$path/new.txt"
      printf 'probe\n' > "$probe" 2>/dev/null || true
      test ! -e "$probe" ;;
    change)
      probe="$path/existing.txt"
      printf 'changed\n' > "$probe" 2>/dev/null || true
      test "$(cat "$probe" 2>/dev/null || true)" = "$original" ;;
    delete)
      probe="$path/existing.txt"
      rm -f "$probe" 2>/dev/null || true
      test -e "$probe" ;;
  esac
}

denied=1
for operation in create change delete; do
  check_denied "$TARGET" "$operation" 'fixture' || denied=0
  check_denied "$GIT_DIR" "$operation" 'git fixture' || denied=0
done
printf 'output\n' > "$OUTPUT/probe.txt"
test -s "$OUTPUT/probe.txt"

if test "$denied" -eq 1; then
  printf 'PROFILE PROBE: deny-write fixture passed; profile still requires matrix review.\n'
else
  printf 'PROFILE PROBE: unsupported; fixture accepted a write, so static audit proceeds only with warning and preservation unverified.\n'
  grep -Fq 'unverified' "$MATRIX"
fi

printf 'PASS: scope resolution, procedural readonly warning, separate output and profile matrix are specified.\n'
