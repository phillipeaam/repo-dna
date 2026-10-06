#!/usr/bin/env bash
# Behavioral privacy cases use only a disposable synthetic Git repository.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python - "$ROOT_DIR/scripts/check-public-context.py" <<'PY'
from pathlib import Path
import subprocess
import sys
import tempfile

checker = Path(sys.argv[1])
assert checker.is_file(), 'Privacy checker is not implemented yet'
with tempfile.TemporaryDirectory(prefix='repodna-public-context-') as tmp:
    root = Path(tmp)
    def git(*args):
        return subprocess.run(['git', '-C', str(root), *args], check=True,
                              capture_output=True)
    def check(ok, terms=None, ref=None):
        args = [sys.executable, str(checker), '--repo', str(root)]
        if terms:
            args += ['--terms', str(terms)]
        if ref:
            args += ['--ref', ref]
        result = subprocess.run(args, capture_output=True, text=True)
        assert (result.returncode == 0) == ok, result.stdout + result.stderr
        return result.stdout + result.stderr
    git('init', '-q')
    (root / '.gitignore').write_text('/private-context/\n', encoding='utf-8')
    (root / 'notes.md').write_text('Generalized method.\n', encoding='utf-8')
    git('add', '.gitignore', 'notes.md')
    check(True)
    private = 'https://' + 'app.' + 'notion.com/p/' + 'a' * 32
    (root / 'notes.md').write_text(private, encoding='utf-8')
    result = check(False)
    assert private not in result
    git('add', 'notes.md')
    (root / 'notes.md').write_text('Clean working document.', encoding='utf-8')
    result = check(False)  # Old index must still block.
    assert 'index' in result and private not in result
    git('add', 'notes.md')
    check(True)
    area = root / 'private-context'
    area.mkdir()
    (area / 'original.md').write_text(private, encoding='utf-8')
    check(True)  # Ignored research is not scanned or published.
    git('add', '-f', 'private-context/original.md')
    check(False)  # Ignore does not protect previously tracked content.
    git('rm', '--cached', '-f', 'private-context/original.md')
    terms = area / 'known-sensitive-terms.txt'
    terms.write_text('Fictional Confidential Client\n', encoding='utf-8')
    (root / 'notes.md').write_text('Fictional Confidential Client', encoding='utf-8')
    result = check(False, terms)
    assert 'Fictional Confidential Client' not in result
    # Sensitive values used in technical/contributor and reconstructed
    # narrative fields must be detected without appearing in diagnostics.
    reconstruction_fields = (
        ('Tag or credit: ', 'Synthetic Framework Vendor Alias'),
        ('R-001 hypothesis and source attribution: ', 'Synthetic Reconstruction Alias'),
        ('H-001 personal_account and decision note: ', 'Synthetic Private Decision Detail'),
    )
    for field, private_value in reconstruction_fields:
        terms.write_text(private_value + '\n', encoding='utf-8')
        (root / 'notes.md').write_text(field + private_value, encoding='utf-8')
        result = check(False, terms)
        assert private_value not in result
    (root / 'notes.md').write_text('Clean method.', encoding='utf-8')
    # A local user's path is private even when no terms file is available.
    (root / 'notes.md').write_text('C:' + '\\Users\\' + 'Synthetic Person\\work',
                                   encoding='utf-8')
    check(False)
    (root / 'notes.md').write_text('C:' + '\\Users\\' + '<user>\\work', encoding='utf-8')
    check(True)
    raw_path = 'C:' + '\\Users\\' + 'Synthetic Person\\repo'
    escaped_path = raw_path.replace('\\', '\\\\')
    examples = {
        'path_example.py': 'home = "' + escaped_path + '"',
        'path_example.sh': '# private path: ' + raw_path,
        'path_example.json': '{"workspace": "' + escaped_path + '"}',
    }
    for filename, content in examples.items():
        sample = root / filename
        sample.write_text(content, encoding='utf-8')
        result = check(False)
        assert 'personal-user-path' in result, filename + ': ' + result
        assert 'Synthetic Person' not in result
        sample.unlink()
    git('config', 'user.name', 'Synthetic Fixture')
    git('config', 'user.email', 'fixture@example.invalid')
    (root / 'notes.md').write_text(private, encoding='utf-8')
    git('add', 'notes.md')
    git('-c', 'core.hooksPath=' + str(root / 'no-hooks'), 'commit', '-qm', 'Private fixture')
    private_commit = git('rev-parse', 'HEAD').stdout.decode().strip()
    (root / 'notes.md').write_text('Generalized release.', encoding='utf-8')
    git('add', 'notes.md')
    check(True)
    result = check(False, ref=private_commit)
    assert 'release_ref' in result and private not in result
print('PASS: worktree, stale index, ignored/tracked research and redacted diagnostics.')
PY
