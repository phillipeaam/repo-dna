#!/usr/bin/env bash
# Static acceptance for evidence boundaries using synthetic fixture cases only.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASES="$ROOT_DIR/tests/fixtures/readonly-audit/evidence-separation-cases.md"
A1="$ROOT_DIR/.agents/skills/repodna-audit/references/forensic-a1.md"
B2="$ROOT_DIR/.agents/skills/repodna-audit/references/runtime-b2.md"
B3="$ROOT_DIR/.agents/skills/repodna-audit/references/provenance-b3.md"
for file in "$CASES" "$A1" "$B2" "$B3"; do
  test -f "$file" || { printf 'FAIL: missing evidence contract input: %s\n' "$file" >&2; exit 1; }
done
for term in 'unknown' 'planned_only' 'unresolved' 'not_measured' '60 FPS' 'release' 'benchmark'; do
  grep -Fqi "$term" "$CASES" || { printf 'FAIL: missing synthetic evidence case: %s\n' "$term" >&2; exit 1; }
done
grep -Fq 'nunca score' "$A1"
grep -Fq 'planned_only' "$A1"
grep -Fq 'não prova' "$B3"
grep -Fq 'not_measured' "$B2"
grep -Fq 'condições equivalentes' "$B2"
printf 'PASS: synthetic cases preserve authorship, implementation, release and measurement boundaries.\n'
