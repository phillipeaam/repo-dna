#!/usr/bin/env python3
"""Check known research metadata in framework files and Git's index.

This is a sharing guard, not a general secret scanner or a repository audit.
It never scans ignored private input/output areas and never executes target code.
"""

import argparse
import os
from pathlib import Path
import re
import subprocess
import sys


PRIVATE_ROOTS = {'target-repos', 'analysis-output', 'private-context'}
PERSONAL_PAGE = re.compile(
    r'https?://(?:app[.]notion[.]com/p/|(?:www[.])?notion[.]so/)[^\s)>]+',
    re.IGNORECASE,
)
PERSONAL_PATH = re.compile(
    r'(?:[A-Za-z]:[\\/]+Us' + r'ers[\\/]+|/c/Us' + r'ers/|/Us' + r'ers/|/ho' + r'me/)'
    r'(?!<|Your\b|Example\b|USER\b|user\b|person\b)[^\\/\r\n"<>]+',
    re.IGNORECASE,
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path,
                        default=Path(__file__).resolve().parents[1])
    parser.add_argument('--terms', type=Path)
    parser.add_argument('--ref', help='Also check the exact commit tree being distributed')
    args = parser.parse_args()
    root = args.repo.resolve()
    env = {**os.environ, 'GIT_OPTIONAL_LOCKS': '0'}

    def git(*parts, input_data=None):
        return subprocess.run(['git', '-C', str(root), *parts], env=env,
                              input=input_data, check=True, capture_output=True).stdout

    terms_file = args.terms or root / 'private-context/known-sensitive-terms.txt'
    terms = []
    if terms_file.is_file():
        terms = [re.compile(r'(?<!\w)' + re.escape(term.strip()) + r'(?!\w)', re.I)
                 for term in terms_file.read_text(encoding='utf-8-sig').splitlines()
                 if term.strip() and not term.strip().startswith('#')]

    def safe_path(path):
        if path.split('/', 1)[0] in PRIVATE_ROOTS:
            return path.split('/', 1)[0] + '/[redacted]'
        for pattern in [PERSONAL_PAGE, PERSONAL_PATH, *terms]:
            path = pattern.sub('[redacted]', path)
        return path

    findings = set()

    def inspect(path, data, surface):
        if path.split('/', 1)[0] in PRIVATE_ROOTS:
            findings.add((surface, safe_path(path), 'tracked-private-area'))
            return
        if b'\x00' in data:
            return  # Known metadata checks cover text; binary requires human review.
        text = data.decode('utf-8', errors='replace')
        # Personal paths can leak from source examples/configs as well as docs;
        # apply the check to every decodable text blob, independent of suffix.
        rules = [('personal-source-link', PERSONAL_PAGE),
                 ('personal-user-path', PERSONAL_PATH)]
        rules += [('known-private-term', pattern) for pattern in terms]
        for name, pattern in rules:
            if pattern.search(text) or pattern.search(path):
                findings.add((surface, safe_path(path), name))

    try:
        indexed = []
        for entry in filter(None, git('ls-files', '--stage', '-z').split(b'\0')):
            metadata, path = entry.split(b'\t', 1)
            _, object_id, stage = metadata.split()
            if stage != b'0':
                raise OSError('Unmerged index requires review')
            indexed.append((path.decode('utf-8'), object_id))
        def inspect_objects(entries, surface):
            # Object IDs avoid path quoting and one process reads the exact
            # stored version, even when working documents have been sanitized.
            blobs = git('cat-file', '--batch',
                        input_data=b''.join(oid + b'\n' for _, oid in entries))
            offset = 0
            for path, _ in entries:
                header_end = blobs.index(b'\n', offset)
                _, kind, size = blobs[offset:header_end].split()
                if kind != b'blob':
                    raise OSError('Non-blob entry requires review')
                start = header_end + 1
                data = blobs[start:start + int(size)]
                offset = start + int(size) + 1
                inspect(path, data, surface)

        inspect_objects(indexed, 'index')
        if args.ref:
            commit = git('rev-parse', '--verify', '--end-of-options',
                         args.ref + '^{commit}').decode().strip()
            entries = []
            for entry in filter(None, git('ls-tree', '-r', '-z', commit).split(b'\0')):
                metadata, path = entry.split(b'\t', 1)
                _, _, object_id = metadata.split()
                entries.append((path.decode('utf-8'), object_id))
            inspect_objects(entries, 'release_ref')
        current = git('ls-files', '-z', '--cached', '--others',
                      '--exclude-standard').decode('utf-8').split('\0')
        for path in sorted(set(filter(None, current))):
            if path.split('/', 1)[0] in PRIVATE_ROOTS:
                inspect(path, b'', 'working_tree')
                continue
            file = root / path
            if file.is_symlink() or not file.resolve().is_relative_to(root):
                findings.add(('working_tree', safe_path(path), 'unreviewed-link'))
            elif file.is_file():
                inspect(path, file.read_bytes(), 'working_tree')
    except (OSError, subprocess.CalledProcessError, UnicodeError, ValueError):
        print('BLOCKED: unable to inspect the selected framework files/index.',
              file=sys.stderr)
        return 2

    for surface, path, rule in sorted(findings):
        print(f'BLOCKED: {surface}: {path}: {rule}', file=sys.stderr)
    if findings:
        return 1
    print('PASS: known metadata checks passed for worktree, index and any requested release ref. '
          'Human review of unknown confidential information and binaries is required.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
