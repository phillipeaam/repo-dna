#!/usr/bin/env bash
# Static acceptance for product/repository links; reads synthetic cases only.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASES="$ROOT_DIR/tests/fixtures/readonly-audit/multirepo-cases.md"
WORKFLOW="$ROOT_DIR/.agents/skills/repodna-audit/references/workflow.md"
VOCAB="$ROOT_DIR/.agents/skills/repodna-audit/references/evidence-vocabulary.md"
for file in "$CASES" "$WORKFLOW" "$VOCAB"; do
  test -f "$file" || { printf 'FAIL: missing multi-repo contract input: %s\n' "$file" >&2; exit 1; }
done
for term in 'Atlas Next' 'Unknown Stack' 'shared@p1' '1.2.0' 'F-010' 'contada uma vez' 'not_applicable'; do
  grep -Fq "$term" "$CASES" || { printf 'FAIL: missing multi-repo fixture value: %s\n' "$term" >&2; exit 1; }
done
grep -Fq 'Produtos com vários repositórios' "$WORKFLOW"
grep -Fq 'consolidada uma vez' "$VOCAB"
printf 'PASS: explicit repo roles/baselines, successors and single shared contribution are represented.\n'
