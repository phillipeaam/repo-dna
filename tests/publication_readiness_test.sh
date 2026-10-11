#!/usr/bin/env bash
# Static acceptance for reconciliation/publication rules with synthetic data only.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASES="$ROOT_DIR/tests/fixtures/readonly-audit/publication-cases.md"
CONSOLIDATION="$ROOT_DIR/.agents/skills/repodna-audit/references/consolidation.md"
B4="$ROOT_DIR/.agents/skills/repodna-audit/references/publication-b4.md"
for file in "$CASES" "$CONSOLIDATION" "$B4"; do
  test -f "$file" || { printf 'FAIL: missing publication contract input: %s\n' "$file" >&2; exit 1; }
done
for term in incorporated retained_context distinct_project historical_superseded irrelevant; do
  grep -Fq "$term" "$CASES"
  grep -Fq "$term" "$CONSOLIDATION"
done
for term in 'Link: unknown' 'embed: unknown' 'cópia: unknown' 'crop: unknown' 'download/rehosting: unknown' 'alteração de áudio: unknown'; do
  grep -Fq "$term" "$CASES" || { printf 'FAIL: missing independent media action: %s\n' "$term" >&2; exit 1; }
done
grep -Fq 'Publicação atual não implica permissão' "$B4"
grep -Fq 'desconhecida' "$B4"
grep -Fq 'não editar' "$CONSOLIDATION" || grep -Fq 'nunca executa a limpeza' "$CONSOLIDATION"
printf 'PASS: reconciliation classes, readonly sources and separate unknown media permissions are specified.\n'
