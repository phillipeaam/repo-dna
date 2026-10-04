#!/usr/bin/env bash
# Contract validator for the synthetic Markdown record; never scans analysis-output/.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_DIR="$ROOT_DIR/tests/fixtures/readonly-audit"
DOCUMENT="${1:-$FIXTURE_DIR/sample-product.md}"
test -f "$DOCUMENT" || { printf 'FAIL: missing Markdown input: %s\n' "$DOCUMENT" >&2; exit 1; }
python - "$DOCUMENT" "$FIXTURE_DIR" <<'PY'
from pathlib import Path
import re
import sys

document = Path(sys.argv[1]).resolve()
fixture_dir = Path(sys.argv[2]).resolve()
text = document.read_text(encoding="utf-8")
required = [
    "## Start Here", "## At a Glance", "## Study Map",
    "## Baseline e preservação", "## Evidências e índice",
    "## Cobertura e estado das etapas", "## Questões, conflitos e bloqueios",
    "## Histórico de verificação", "### A1 — Forense", "### B1 — Produção e arquitetura",
    "### B2 — Runtime estático", "### B3 — Release e procedência",
    "### B4 — Publicação e créditos", "### Reconciliação de fontes",
]
missing = [heading for heading in required if heading not in text]
if missing:
    raise SystemExit("FAIL: missing stable headings: " + ", ".join(missing))

definitions = re.findall(r"(?m)^\s*-\s*\[((?:E|F|C|Q)-\d{3})\]", text)
if len(definitions) != len(set(definitions)):
    raise SystemExit("FAIL: defined evidence/finding/claim/question identifiers must be unique")
evidence_ids = set(re.findall(r"\[(E-\d{3})\]", text))
for line in text.splitlines():
    if re.match(r"^\s*\[C-\d{3}\]", line) and not re.search(r"\[E-\d{3}\]", line):
        raise SystemExit("FAIL: factual claim without an evidence reference: " + line)
if "not_measured" not in text or "unresolved" not in text:
    raise SystemExit("FAIL: unknown/not-measured states must remain explicit")

# The synthetic acceptance output is isolated from the private, ignored live output.
if not document.is_relative_to(fixture_dir):
    raise SystemExit("FAIL: default contract test must use an isolated fixture, not a live output path")
markdown_files = list(fixture_dir.glob("sample-product*.md"))
if markdown_files != [document]:
    raise SystemExit("FAIL: fixture product must have exactly one canonical Markdown file")
if not evidence_ids:
    raise SystemExit("FAIL: canonical record needs a recoverable evidence index")
print("PASS: canonical structure, unique IDs, evidence index, explicit unknowns and single Markdown fixture.")
PY
