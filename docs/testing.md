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
`shfmt` enforces the entrypoint and selected maintained shell modules, expanding
as older modules are mechanically normalized.

The Bats suite in `tests/bats/` covers fast CLI, detection, exclusion, security,
fixture-isolation, and runtime-fallback behavior. The existing standalone Bash
tests remain the detailed integration suite; Bats calls the same public test
scripts instead of maintaining duplicate assertions.

`tests/artifact_contract_test.sh` performs a real analysis, parses every
generated JSON document, checks the canonical report contract, verifies the HTML
entrypoint, and confirms that the ZIP or TAR archive contains it.
