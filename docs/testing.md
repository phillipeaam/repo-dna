# Automated testing

RepoDNA uses Bash integration/unit scripts plus small versioned fixtures. Run all
tests locally with:

```bash
bash ./tests/run.sh
```

## Fixtures

`tests/fixtures/` contains minimal repository structures for Unity, Android,
Flutter, generic, no-Git, empty, spaces, Unicode, multiple-author, and large-file
scenarios. Tests copy these files to an isolated temporary directory before
creating Git history or modifying them. Nested `.git` directories are never
versioned; commits, authors, submodules, and symlinks are constructed at runtime.

The shared helpers live in `tests/helpers/fixture.sh`. The fixture directory is
excluded by both Bash and Python file discovery so artificial Unity, Android, or
Flutter files do not contaminate RepoDNA's own metrics.

## Edge cases

The suite verifies paths with spaces, Unicode paths and authors, missing author
commits, repositories without remotes, directories without Git, repositories
without commits, large files, submodules, symlinks where the operating system
allows them, missing Python configuration, and missing archive tools.

## CI and portability

GitHub Actions runs the test suite on Ubuntu, macOS, and Windows. Windows commands
use Git Bash. WSL is not represented by a GitHub-hosted runner and remains a
manual or future self-hosted validation target.

The lint job runs ShellCheck at error severity across Bash source and tests.
`shfmt` currently enforces the main entrypoint and will expand gradually as
existing modules are mechanically normalized. Bats may be adopted incrementally
for new tests; rewriting the working Bash suite is not a prerequisite.
