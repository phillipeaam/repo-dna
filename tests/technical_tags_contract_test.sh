#!/usr/bin/env bash
# Static contract checks; reads only framework documentation and synthetic fixtures.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python - "$ROOT_DIR" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
fixture = root / "tests/fixtures/readonly-audit/technology-tags/README.md"
quickstart = root / "specs/001-readonly-audit-framework/quickstart.md"
contract = root / "specs/001-readonly-audit-framework/contracts/source-of-truth-markdown.md"
model = root / "specs/001-readonly-audit-framework/data-model.md"
vocabulary = root / ".agents/skills/repodna-audit/references/evidence-vocabulary.md"
production = root / ".agents/skills/repodna-audit/references/production-b1.md"
workflow = root / ".agents/skills/repodna-audit/references/workflow.md"
consolidation = root / ".agents/skills/repodna-audit/references/consolidation.md"
for path in (fixture, quickstart, contract, model, vocabulary, production, workflow, consolidation):
    assert path.is_file(), f"missing technical-tag contract artifact: {path.relative_to(root)}"
docs = {p.name: p.read_text(encoding="utf-8") for p in
        (fixture, quickstart, contract, model, vocabulary, production, workflow, consolidation)}
cases = re.findall(r"(?m)^\| `([^`]+)` \|", docs[fixture.name])
assert len(cases) >= 18 and len(cases) == len(set(cases)), "fixture needs unique declared, package, pattern, AI, codec and migration cases"
required = {
    "faceta:slug", "T-###", "O-###", "observed_use", "active_configuration",
    "installed", "transitive", "stale", "current", "baseline", "evidência",
    "pattern-false-positive", "ai-instructions-only", "codec-extension-only",
    "2.0.0 → 2.1.0", "offline",
}
corpus = "\n".join(docs.values())
missing = sorted(term for term in required if term.casefold() not in corpus.casefold())
assert not missing, f"contract omits terms/cases: {missing}"
for path in (fixture, quickstart, contract, model, vocabulary, production, workflow, consolidation):
    assert "notion.com/p/" not in docs[path.name].casefold(), "framework method must not depend on private Notion source"
assert "ffprobe" in docs[production.name] and "não invocar" in docs[production.name], "codec procedure must prohibit running a target tool"
assert "Documento 2.1.0" in (root / "tests/fixtures/readonly-audit/sample-product.md").read_text(encoding="utf-8")
print(f"PASS: {len(cases)} synthetic technology cases and schema/query/evidence rules are present.")
PY
