#!/usr/bin/env bash
# Static acceptance for migration/resume semantics with synthetic fixture data.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASES="$ROOT_DIR/tests/fixtures/readonly-audit/audit-resume-cases.md"
WORKFLOW="$ROOT_DIR/.agents/skills/repodna-audit/references/workflow.md"
CONSOLIDATION="$ROOT_DIR/.agents/skills/repodna-audit/references/consolidation.md"
for file in "$CASES" "$WORKFLOW" "$CONSOLIDATION"; do
  test -f "$file" || { printf 'FAIL: missing resume contract input: %s\n' "$file" >&2; exit 1; }
done
for term in 'possible_use' 'not_verified' 'repo@a1' 'b2' 'stale' 'A1/B1' 'sucessor'; do
  grep -Fqi "$term" "$CASES" || { printf 'FAIL: missing resume fixture case: %s\n' "$term" >&2; exit 1; }
done
grep -Fiq 'revalidar findings dependentes' "$WORKFLOW"
grep -Fq 'marcam conclusões afetadas como stale' "$CONSOLIDATION"
grep -Fq 'compatibilidade' "$CONSOLIDATION"
printf 'PASS: legacy provenance, interrupted checkpoints and changed baselines remain explicit.\n'
