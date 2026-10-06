#!/usr/bin/env bash
# Static contract checks; reads only framework documentation and synthetic fixtures.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python - "$ROOT_DIR" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
fixture = root / "tests/fixtures/readonly-audit/engineering-reconstruction/README.md"
quickstart = root / "specs/001-readonly-audit-framework/quickstart.md"
spec = root / "specs/001-readonly-audit-framework/spec.md"
contract = root / "specs/001-readonly-audit-framework/contracts/source-of-truth-markdown.md"
portfolio = root / "specs/001-readonly-audit-framework/contracts/portfolio-readiness.md"
model = root / "specs/001-readonly-audit-framework/data-model.md"
methodology = root / "specs/001-readonly-audit-framework/methodology.md"
skill = root / ".agents/skills/repodna-audit/SKILL.md"
workflow = root / ".agents/skills/repodna-audit/references/workflow.md"
vocabulary = root / ".agents/skills/repodna-audit/references/evidence-vocabulary.md"
forensic = root / ".agents/skills/repodna-audit/references/forensic-a1.md"
runbook = root / ".agents/skills/repodna-audit/references/engineering-reconstruction.md"
consolidation = root / ".agents/skills/repodna-audit/references/consolidation.md"
publication = root / ".agents/skills/repodna-audit/references/publication-b4.md"
paths = (fixture, quickstart, spec, contract, portfolio, model, methodology,
         skill, workflow, vocabulary, forensic, runbook, consolidation, publication)
for path in paths:
    assert path.is_file(), f"missing reconstruction contract artifact: {path.relative_to(root)}"
docs = {p: p.read_text(encoding="utf-8") for p in paths}

case_ids = re.findall(r"(?m)^\| ([a-z0-9-]+) \|", docs[fixture])
assert len(case_ids) >= 23 and len(case_ids) == len(set(case_ids)), (
    "fixture needs unique source, attribution, confidence, result, narrative and review cases"
)

corpus = "\n".join(docs.values()).casefold()
required = {
    "fr-114", "fr-125", "fr-126", "fr-127", "sc-038", "sc-047", "sc-048", "sc-049", "sc-050", "r-###", "h-###",
    "supports", "limits", "contradicts", "context_only", "hypothesis",
    "unknown", "not_observed", "unavailable", "high", "medium", "low",
    "corroboração", "contradições", "escopo", "autoria registrada",
    "colaboração", "validação", "resultado", "zero a três", "draft",
    "accepted", "corrected", "rejected", "sem autenticação",
    "prosa", "ordem", "sc-025", "2.1.0", "procedência", "adequação",
    "independência", "origem compartilhada", "unknown", "hashes não são obrigatórios",
    "natureza da conclusão", "necessidade de verificação",
}
missing = sorted(term for term in required if term not in corpus)
assert not missing, f"reconstruction contract omits terms/criteria: {missing}"

assert "engineering-reconstruction.md" in docs[skill], "main skill must expose the applicable runbook"
assert "evidence-vocabulary.md" in docs[skill], "main skill must expose shared evidence/provenance vocabulary"
assert "fr-127" in docs[quickstart].casefold() and "sc-050" in docs[quickstart].casefold(), (
    "quickstart must trace provenance and source-fit requirements"
)
assert "hashes não são obrigatórios" in docs[quickstart].casefold(), (
    "quickstart must not require source hashes"
)
for case in ("no-git-or-supporting-material", "direct-source-fit", "secondary-source-fit",
             "personal-account-fit", "unknown-source-metadata", "stale-snapshot-source",
             "shared-origin-sources", "independent-corroboration", "dimension-mismatch",
             "source-fit-vs-claim-confidence", "conclusion-vs-verification-need"):
    assert f"| {case} |" in docs[fixture], f"missing source-provenance case: {case}"
assert "unavailable" in docs[forensic].casefold(), "A1 must preserve inaccessible private sources as unavailable"
assert "draft" in docs[consolidation].casefold() and "não publicar" in docs[consolidation].casefold(), (
    "consolidation must preserve review provenance and prohibit automatic publication"
)
assert "prosa e ordem são livres" in docs[methodology].casefold(), "methodology must allow editorial order to vary"
assert "passaram na suíte seletiva do framework" in docs[quickstart].casefold(), (
    "quickstart must record the completed framework contract validation"
)

sample = root / "tests/fixtures/readonly-audit/sample-product.md"
assert "Documento 2.1.0" in sample.read_text(encoding="utf-8"), "reconstruction remains within schema 2.1.0"
for path in paths:
    text = docs[path].casefold()
    assert "notion.com/p/" not in text, f"private research URL found in {path.relative_to(root)}"
print(f"PASS: {len(case_ids)} synthetic reconstruction cases and evidence/review rules are present.")
PY
