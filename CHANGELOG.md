# Changelog

All notable changes to RepoDNA will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and releases use [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Expanded generic technology detection across runtimes, package managers,
  dependency-manifest families, build tools, CI/CD, tests, linting,
  configuration, documentation, and containerization.

- Made `report/data/report.json` the sole public analysis source, added shared
  `canonical_metrics`, and removed the exported generic collector staging file.

### Added

- A bounded RepoDNA 1.0 support contract for local Git analysis, generic Bash/Python evidence, Git intelligence, basic architecture, quality/risk ingestion, onboarding, portfolio evidence, HTML/JSON reports, and privacy controls.
- Cross-platform CI, Bats smoke tests, fixture validation, and generated-artifact contract checks.
- Automated release packaging, SHA-256 checksums, changelog extraction, and GitHub Release publishing.
