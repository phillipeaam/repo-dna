# Contributing to RepoDNA

## Development requirements

- Git
- Bash (Git Bash on Windows)
- Python 3.11 or newer
- matplotlib

## Before changing code

Read [the architecture guide](docs/architecture.md). Keep production code under
`src/`, collectors under `collectors/`, renderers under `renderers/`, and tests
under `tests/`. Do not add a second `lib/` or `utils/` source tree.

Pipeline modules must declare functions without executing work when sourced.
Execution order belongs only in `dna-analysis.sh`.

## Validation

Run the complete suite:

```bash
bash ./tests/run.sh
```

Also check patch whitespace before committing:

```bash
git diff --check
```

Every bug fix should include a regression test. New project detectors need
priority and preferred-root cases. Privacy changes must cover standard and
strict modes. Report changes must be driven from structured JSON fixtures.

Heuristic analysis must publish its basis, confidence, and limitations. Unknown
or unavailable evidence must use an explicit state such as `not_scanned` or
`not_assessed`; it must never be represented as a zero-risk result. Changes to
the health score require a model-version update and corresponding changes to
`docs/health-score.md`.

## Pull requests

Keep changes focused, explain observable behavior changes, and call out privacy
or compatibility implications. Do not include generated report directories,
archives, credentials or private repository data.
