# RepoDNA

[![Quality, tests, and fixtures](https://github.com/phillipeaam/repo-dna/actions/workflows/quality-tests-and-fixtures.yml/badge.svg)](https://github.com/phillipeaam/repo-dna/actions/workflows/quality-tests-and-fixtures.yml)
[![License](https://img.shields.io/github/license/phillipeaam/repo-dna)](LICENSE)

Evidence-based analysis for local Git repositories.

![RepoDNA analysis overview](assets/images/banner.png)

RepoDNA helps answer:

- What technologies and dependencies does this project use?
- How is it organized and which systems are present?
- Which files and areas changed most over time?
- Where should a new contributor start?
- Which evidence can support technical documentation or a portfolio?

It produces evidence and signals from repository contents and Git history. It
does not prove runtime behavior, formal ownership, business impact, security,
or code quality.

## What it provides

- Generic repository analysis for any Git project;
- project and technology detection;
- modules, systems, architecture, imports, symbols, and entrypoints;
- languages, dependencies, configuration, tests, CI/CD, Docker, and docs;
- Git contributors, aliases, churn, hotspots, collaboration, and history;
- quality, maintainability, privacy, and security signals;
- optional Unity, .NET, Android, Flutter, Godot, Unreal, and framework adapters;
- onboarding, system documentation, portfolio evidence, and LLM-ready JSON;
- HTML dashboards, canonical JSON, CSV data, charts, snapshots, and comparisons.

All conclusions include confidence, evidence, limitations, or an explicit
`not_observed` status where appropriate.

## Quick start

Requirements: Git, Bash 4.3+, and standard Unix tools. Python 3.11+ is
recommended for complete reports, JSON Schema validation, and charts.

```bash
git clone https://github.com/phillipeaam/repo-dna.git
cd repo-dna
python -m pip install -r requirements-reporting.txt
bash ./repodna analyze /path/to/project
```

The report is created in a timestamped directory inside the analyzed project.
Open:

```text
<analysis-directory>/report/index.html
```

Check the environment first:

```bash
bash ./repodna doctor
```

Install the command for repeated use:

```bash
bash ./install.sh
repodna analyze .
```

## Common commands

```bash
repodna analyze . --debug
repodna analyze . --privacy strict
repodna analyze . --no-history --no-graphs
repodna analyze . --snapshot
repodna analyze . --compare .repodna/snapshots/<snapshot>.json
repodna analyze . --author "Name or email"
```

Source code is excluded by default. Use `--include-source` only when sharing
the code is intentional. `--privacy strict` always disables source export,
redacts sensitive metadata, and blocks unsafe archives.

## Reports

`report/data/report.json` is the canonical analysis model. Other artifacts are
derived from it:

```text
report/index.html       HTML dashboard
report/data/report.json Canonical structured evidence
notion/evidence.json    Notion-oriented evidence
llm/evidence.json       LLM-oriented evidence
portfolio/draft.json    Confirmation-gated portfolio evidence
onboarding/dataset.json Onboarding data
security/potential_secrets.txt
```

The dashboard covers overview, technologies, architecture, systems,
contribution, quality, risks, onboarding, portfolio evidence, and raw data.

## Test locally

The default suite is intentionally fast and validates unit and contract
behavior:

```bash
bash tests/run.sh --json test-results/repodna-test-results.json
```

Additional scopes are available when needed:

```bash
bash tests/run.sh --unit
bash tests/run.sh --contract
bash tests/run.sh --integration
bash tests/run.sh --all
```

Integration tests generate complete reports, archives, privacy scans, or
cross-platform fixtures and therefore take longer.

## Privacy and exclusions

Create `.repodna-ignore` to exclude paths and use
`.repodna-secrets-allowlist` for reviewed false positives. Secret findings are
heuristic, masked, and never a replacement for a dedicated security scanner.

## Documentation

- [Version 1.0 support policy](docs/v1-support-policy.md)
- [Installation and updates](docs/installation.md)
- [CLI and doctor](docs/cli.md)
- [Architecture](docs/architecture.md)
- [Generic analysis and delivery](docs/local-delivery-analysis.md)
- [CI/CD and releases](docs/ci-cd.md)
- [Testing](docs/testing.md)
- [Privacy and secret scanning](docs/secret-scanning.md)
- [Windows and Git Bash](docs/windows-support.md)
- [Architecture insights](docs/architecture-insights.md)
- [Dependency graphs and SBOM](docs/dependency-graphs.md)
- [Health score methodology](docs/health-score.md)
- [Canonical JSON contracts](docs/canonical-json-contracts.md)
- [LLM evidence](docs/llm-evidence.md)
- [Contributing](CONTRIBUTING.md)

## License

See [LICENSE](LICENSE).
