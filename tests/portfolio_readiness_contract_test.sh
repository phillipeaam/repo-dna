#!/usr/bin/env bash
# Static acceptance for portfolio readiness; reads only synthetic framework fixtures.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$ROOT_DIR/tests/fixtures/readonly-audit/portfolio-readiness/README.md"
CONTRACT="$ROOT_DIR/specs/001-readonly-audit-framework/contracts/portfolio-readiness.md"
METHOD="$ROOT_DIR/specs/001-readonly-audit-framework/methodology.md"
QUICKSTART="$ROOT_DIR/specs/001-readonly-audit-framework/quickstart.md"
for file in "$FIXTURE" "$CONTRACT" "$METHOD" "$QUICKSTART"; do
  test -f "$file" || { printf 'FAIL: missing editorial readiness contract input: %s\n' "$file" >&2; exit 1; }
done
for term in 'sample-featured' 'sample-featured-gaps' 'sample-archive' '5 itens significativos' 'até 60' '5–10 minutos' 'não afirma que um leitor real'; do
  grep -Fq "$term" "$FIXTURE" || { printf 'FAIL: fixture missing SC-025/SC-026 case element: %s\n' "$term" >&2; exit 1; }
done
for term in '2–4 clipes/GIFs' '3–6 screenshots' '3–5 contribuições' '1–3 desafios' 'disponíveis' 'selecionados'; do
  grep -Fq "$term" "$CONTRACT" || { printf 'FAIL: contract missing Featured inventory distinction: %s\n' "$term" >&2; exit 1; }
done
grep -Fq 'até 60 segundos' "$METHOD"
grep -Fq '5–10 minutos' "$METHOD"
grep -Fq 'SC-025' "$QUICKSTART"
printf 'PASS: synthetic cases cover quick-scan timing, deep-evidence path, proportional Featured inventory and explicit media gaps.\n'
