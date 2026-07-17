# RepoDNA architecture

RepoDNA is a Bash CLI with Python collectors and renderers. The public command
is always `bash ./dna-analysis.sh`; internal filenames never define execution
order.

## Layers

```text
dna-analysis.sh          Public entrypoint and explicit orchestration
src/core/                Reusable runtime, filesystem, Git, privacy and domain services
src/detectors/           Project type detection and preferred roots
src/analyzers/           Stack-specific analysis that runs only for matching profiles
src/git/                 Git metric, specialized-history and export services
src/pipeline/            Use-case stages; sourcing declares one public function
src/reports/             Structured-data and chart producers
collectors/              Python collectors that output JSON only
renderers/               Python renderers that consume canonical JSON only
tests/                   Unit, contract and end-to-end shell tests
```

There is intentionally no `lib/` directory. All production code belongs under
`src/`; a second generic code root would make ownership and dependency direction
ambiguous.

## Dependency direction

```text
dna-analysis.sh
  -> src/pipeline
      -> src/analyzers, src/core, src/reports
          -> collectors, renderers (process boundary)
```

Core modules must not source pipeline modules. Collectors do not write reports,
and renderers do not inspect the repository. Both communicate through
`report/data/report.json` and `report/data/generic-analysis.json`.

`collectors/insights.py` enriches the generic collector output with
language-aware symbols, imports, architecture and pattern signals, system
candidates, quality evidence, narrative facts, and the versioned repository
health model. It does not write presentation files.

`renderers/portfolio.py` creates an approval-gated portfolio draft. Repository
facts remain unapproved unless their claim IDs are explicitly listed in a
portfolio confirmation profile. Personal profiles are not accepted in strict
privacy mode.

The generic Git collector receives the same optional author scope as the Bash
history pipeline. It expands a selected canonical identity through
`.repodna-authors` before querying Git. Repository-wide reports render the
canonical contributor list in pages of 20; author-scoped reports do not include
unrelated contributor identities.

## Pipeline contract

Each file in `src/pipeline/`:

1. declares one public function;
2. performs no work merely by being sourced;
3. may read context initialized by `initialize_analysis_context`;
4. writes only inside the current report directory;
5. returns non-zero for an unrecoverable failure.

The entrypoint calls pipeline functions explicitly. This keeps execution order
visible without numeric filenames.

## Shared state

Bash has no native object model, so the current MVP uses documented uppercase
context variables such as `REPO_ROOT`, `PROJECT_TYPE`, `OUTPUT_DIR` and
`PRIVACY_MODE`. Module-local values should use `local`. Shared registries use
explicit global declarations (`declare -g`) and are initialized once per run.

Related outputs should be grouped instead of exposed as many globals. Git
history, for example, publishes the `GIT_HISTORY` associative registry from
small modules under `src/git/`; consumers read named keys from that contract.
Current C#/Unity metrics follow the same rule through `CURRENT_METRICS`.

Longer term, high-growth collection logic should move to Python and exchange
versioned JSON rather than add more shared Bash globals.

## Testing boundaries

- `architecture_test.sh`: entrypoint size, module existence, isolated loading and syntax.
- unit tests: arguments, detection, exclusions, ownership and security.
- collector/renderer tests: structured JSON and HTML contracts.
- `privacy_modes_test.sh`: end-to-end default, source opt-in and strict privacy modes.

Run everything with `bash ./tests/run.sh`.
