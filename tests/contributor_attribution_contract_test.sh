#!/usr/bin/env bash
# Static contributor contract checks; uses synthetic identities only.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python - "$ROOT_DIR" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
fixture = root / "tests/fixtures/readonly-audit/contributors/README.md"
quickstart = root / "specs/001-readonly-audit-framework/quickstart.md"
contract = root / "specs/001-readonly-audit-framework/contracts/source-of-truth-markdown.md"
model = root / "specs/001-readonly-audit-framework/data-model.md"
vocabulary = root / ".agents/skills/repodna-audit/references/evidence-vocabulary.md"
forensic = root / ".agents/skills/repodna-audit/references/forensic-a1.md"
workflow = root / ".agents/skills/repodna-audit/references/workflow.md"
consolidation = root / ".agents/skills/repodna-audit/references/consolidation.md"
skill = root / ".agents/skills/repodna-audit/SKILL.md"
paths = (fixture, quickstart, contract, model, vocabulary, forensic, workflow, consolidation, skill)
for path in paths:
    assert path.is_file(), f"missing contributor contract artifact: {path.relative_to(root)}"
docs = {p.name: p.read_text(encoding="utf-8") for p in paths}
cases = re.findall(r"(?m)^\| `([^`]+)` \|", docs[fixture.name])
assert len(cases) >= 10 and len(cases) == len(set(cases)), "fixture needs unique identity, credit, non-code and incomplete-history cases"
corpus = "\n".join(docs.values())
required = {
    "P-###", "K-###", "CODEOWNERS", "committer", "co-author", "bot-and-ai",
    "third-party-media", "non-code-work", "shallow-history", "individual-tech-link",
    "contribuidores identificados no escopo", "personal_account", "partial",
    "P → K → O/T → E", "não herdar", "divulgação",
}
missing = sorted(term for term in required if term.casefold() not in corpus.casefold())
assert not missing, f"attribution contract omits: {missing}"
assert "For contributor/experience questions" in docs[skill.name], "skill entry must point to qualified individual lookup"
print(f"PASS: {len(cases)} synthetic contributor cases and conservative attribution rules are present.")
PY
