#!/usr/bin/env bash
# Check the local instruction graph, without connecting to any original source.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python - "$ROOT_DIR" <<'PY'
from pathlib import Path
import re
import sys
from urllib.parse import unquote

root = Path(sys.argv[1]).resolve()
skill = root / '.agents/skills/repodna-audit'
itch = root / '.agents/skills/repodna-itch-format'
documents = [skill / 'SKILL.md', *sorted((skill / 'references').glob('*.md')),
             itch / 'SKILL.md', *sorted((itch / 'references').glob('*.md')),
             root / 'specs/001-readonly-audit-framework/source-inventory.md']
inventory = documents[-1].read_text(encoding='utf-8')
channel_citations = {
    'https://itch.io/docs/creators/design',
    'https://itch.io/docs/creators/quality-guidelines',
    'https://itch.io/docs/creators/css-guide',
}
assert set(re.findall(r'\| (L\d{2}) \|', inventory)) == {
    f'L{i:02d}' for i in range(1, 17)
}, 'All sixteen incorporated themes need local coverage'
for document in documents:
    body = document.read_text(encoding='utf-8')
    for link in re.findall(r'\]\(([^)]+)\)', body):
        target = unquote(link.split('#', 1)[0].strip('<>'))
        if not target:
            continue
        if re.match(r'[a-z]+://', target):
            # Dated channel evidence is optional provenance, not an instruction
            # dependency. Only the three spec-required official citations qualify.
            assert document == itch / 'references/channel-itch.md' and target in channel_citations, (
                f'External method dependency: {document.name}'
            )
            continue
        resolved = (document.parent / target).resolve()
        assert resolved.is_relative_to(root), 'Required method reference escapes checkout'
        assert resolved.is_file(), f'Missing local method reference: {document.name}'
print('PASS: sixteen local themes and all instruction references resolve offline; official channel citations are scoped evidence only.')
PY
