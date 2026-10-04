#!/usr/bin/env bash
# Static acceptance for workflow contracts; does not inspect or execute a target repository.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$ROOT_DIR/.agents/skills/repodna-audit/SKILL.md"
REFS="$ROOT_DIR/.agents/skills/repodna-audit/references"

for file in "$SKILL" "$REFS/workflow.md" "$REFS/evidence-vocabulary.md" "$REFS/forensic-a1.md" "$REFS/production-b1.md" "$REFS/runtime-b2.md" "$REFS/provenance-b3.md" "$REFS/publication-b4.md" "$REFS/consolidation.md"; do
  test -f "$file" || { printf 'FAIL: missing workflow artifact: %s\n' "$file" >&2; exit 1; }
done
for term in 'Gate 0' 'Gate 1' 'Gate 2' 'A1 Forense' 'B1 Produção' 'B2 Runtime' 'B3 Procedência' 'B4 Publicação' 'Retomada' 'Gate final de preservação'; do
  grep -Fq "$term" "$REFS/workflow.md" || { printf 'FAIL: workflow missing phase/gate: %s\n' "$term" >&2; exit 1; }
done
grep -Fq 'This feature is static only' "$SKILL"
grep -Fq 'never launched or orchestrated here' "$SKILL"
grep -Fq 'measurement' "$REFS/evidence-vocabulary.md"
grep -Fq 'not_applicable' "$REFS/evidence-vocabulary.md"
grep -Fq 'procedência' "$REFS/runtime-b2.md"
grep -Fq 'alteração de áudio' "$REFS/publication-b4.md"
grep -Fq 'até cinco minutos' "$ROOT_DIR/specs/001-readonly-audit-framework/quickstart.md"

printf 'PASS: all agent phases, safety gates, evidence states and runbooks are present.\n'
