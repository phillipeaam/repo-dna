#!/usr/bin/env bash
# Static acceptance for optional surface review using synthetic framework fixtures only.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$ROOT_DIR/tests/fixtures/readonly-audit/portfolio-surface/README.md"
CONTRACT="$ROOT_DIR/specs/001-readonly-audit-framework/contracts/portfolio-readiness.md"
QUICKSTART="$ROOT_DIR/specs/001-readonly-audit-framework/quickstart.md"
RUNBOOK="$ROOT_DIR/.agents/skills/repodna-audit/references/portfolio-surface-review.md"
TEMPLATE="$ROOT_DIR/.agents/skills/repodna-audit/references/consolidation.md"
test -f "$FIXTURE" || { printf 'FAIL: missing synthetic surface fixture\n' >&2; exit 1; }
test -f "$CONTRACT" || { printf 'FAIL: missing surface contract\n' >&2; exit 1; }
test -f "$QUICKSTART" || { printf 'FAIL: missing surface quickstart\n' >&2; exit 1; }
test -f "$RUNBOOK" || { printf 'FAIL: missing surface runbook\n' >&2; exit 1; }
test -f "$TEMPLATE" || { printf 'FAIL: missing canonical consolidation template\n' >&2; exit 1; }

# Every FR-089 observation dimension must occur exactly once in the synthetic matrix,
# with a permitted state and non-empty evidence, observation/reason and limitation.
python - "$FIXTURE" "$RUNBOOK" "$TEMPLATE" <<'PY'
import sys
from pathlib import Path

fixture, runbook, template = [Path(name).read_text(encoding="utf-8") for name in sys.argv[1:]]
expected = {
    "positioning", "narrative-information-architecture", "discovery-grouping",
    "cases-evidence", "visual-readability", "mobile-reflow", "tablet-reflow",
    "reading-order", "touch-targets", "keyboard-navigation", "focus-visibility",
    "accessible-names", "semantic-structure", "contrast", "reduced-motion",
    "animated-media-controls", "contact-conversion", "maintenance-consistency",
    "unavailable-media", "performance",
}
rows = {}
for line in fixture.splitlines():
    if not line.startswith("|"):
        continue
    cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
    if len(cells) != 5 or cells[0] not in expected:
        continue
    rows.setdefault(cells[0], []).append(cells[1:])

missing = sorted(expected - rows.keys())
duplicates = sorted(key for key, values in rows.items() if len(values) != 1)
invalid = []
for key, values in rows.items():
    status, evidence, note, limit = values[0]
    if status not in {"finding", "not_observed"} or not all((evidence, note, limit)):
        invalid.append(key)
if missing or duplicates or invalid:
    print(f"FAIL: surface matrix missing={missing}, duplicates={duplicates}, invalid={sorted(invalid)}", file=sys.stderr)
    raise SystemExit(1)

for label, document in (("runbook", runbook), ("canonical template", template)):
    absent = sorted(key for key in expected if f"`{key}`" not in document)
    if absent:
        print(f"FAIL: {label} omits FR-089 dimensions: {absent}", file=sys.stderr)
        raise SystemExit(1)

for term in ("Resumo executivo", "arquitetura/direção recomendada", "gaps de conteúdo/evidência"):
    if term.casefold() not in template.casefold():
        print(f"FAIL: canonical template omits FR-090 output: {term}", file=sys.stderr)
        raise SystemExit(1)
PY

for term in '1440×900' '390×844' 'unavailable-prototype' 'nenhuma nota' 'mídia' 'performance'; do
  grep -Fqi "$term" "$FIXTURE" || { printf 'FAIL: fixture missing boundary: %s\n' "$term" >&2; exit 1; }
done
for term in 'P0–P3' 'not_observed' 'não autenticar' 'benchmark ou certificação'; do
  grep -Fq "$term" "$CONTRACT" || { printf 'FAIL: contract missing safety/scoring rule: %s\n' "$term" >&2; exit 1; }
done
grep -Fq 'nenhuma ação muda estado' "$QUICKSTART"
printf 'PASS: optional surface contract covers every FR-089 dimension with evidence/reason and limits.\n'
