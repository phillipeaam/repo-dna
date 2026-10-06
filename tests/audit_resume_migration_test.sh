#!/usr/bin/env bash
# Static acceptance for migration/resume semantics with synthetic fixture data.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASES="$ROOT_DIR/tests/fixtures/readonly-audit/audit-resume-cases.md"
WORKFLOW="$ROOT_DIR/.agents/skills/repodna-audit/references/workflow.md"
CONSOLIDATION="$ROOT_DIR/.agents/skills/repodna-audit/references/consolidation.md"
TECHNOLOGY_FIXTURE="$ROOT_DIR/tests/fixtures/readonly-audit/technology-tags/README.md"
QUICKSTART="$ROOT_DIR/specs/001-readonly-audit-framework/quickstart.md"
for file in "$CASES" "$WORKFLOW" "$CONSOLIDATION" "$TECHNOLOGY_FIXTURE" "$QUICKSTART"; do
  test -f "$file" || { printf 'FAIL: missing resume contract input: %s\n' "$file" >&2; exit 1; }
done
for term in 'possible_use' 'not_verified' 'repo@a1' 'b2' 'stale' 'A1/B1' 'sucessor'; do
  grep -Fqi "$term" "$CASES" || { printf 'FAIL: missing resume fixture case: %s\n' "$term" >&2; exit 1; }
done
grep -Fiq 'revalidar findings dependentes' "$WORKFLOW"
grep -Fq 'marcam conclusões afetadas como stale' "$CONSOLIDATION"
grep -Fq 'compatibilidade' "$CONSOLIDATION"
for term in 'legacy-2.0.0' '2.0.0 → 2.1.0' 'E-001' 'F-001' 'C-001' 'Q-001' 'baseline legada' 'atualiza o mesmo Markdown'; do
  grep -Fq "$term" "$TECHNOLOGY_FIXTURE" || { printf 'FAIL: migration fixture omits preservation rule: %s\n' "$term" >&2; exit 1; }
done
grep -Fq 'atualizar o mesmo arquivo para 2.1.0' "$QUICKSTART"
printf 'PASS: legacy provenance, interrupted checkpoints and changed baselines remain explicit.\n'
