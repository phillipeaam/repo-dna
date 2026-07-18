# Changelog

- Added versioned test-execution evidence, complete-suite pass/fail aggregation, CI artifact publication, Python formatting validation, local-link verification, and portable Linux/macOS/Windows smoke gates.
- Reworked heuristic secret detection with placeholder suppression, safe previews, four severity levels, `.repodna-ignore`, value-free allowlists, dedicated fake-secret fixtures, and explicit security-scanner limitations.
- Reworked repository health model 2.0 to separate Health Score, Evidence Coverage, and confidence, with six normalized dimensions and explicit explanations for proven losses, unsupported analysis, unavailable information, and external tools not executed.
- Consolidated facts, heuristic inferences, and unobserved external evidence in the canonical analysis model; missing coverage, tests, lint, and scanner artifacts no longer become zero-valued measurements or reduce the health score.

All notable changes to RepoDNA will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and releases use [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Replaced directory-as-system grouping with evidence-based architectural
  system classification, numeric confidence, and separately typed structural
  entities for modules, packages, namespaces, infrastructure, tests, and docs.

- Removed legacy Unity/C# metric, architecture, technology, and system views
  from the canonical model; generic reports now use stack-neutral structural
  analysis exclusively, with specialized analyzers as additive sections.

- Expanded generic technology detection across runtimes, package managers,
  dependency-manifest families, build tools, CI/CD, tests, linting,
  configuration, documentation, and containerization.

- Made `report/data/report.json` the sole public analysis source, added shared
  `canonical_metrics`, and removed the exported generic collector staging file.

### Added

- A bounded RepoDNA 1.0 support contract for local Git analysis, generic Bash/Python evidence, Git intelligence, basic architecture, quality/risk ingestion, onboarding, portfolio evidence, HTML/JSON reports, and privacy controls.
- Cross-platform CI, Bats smoke tests, fixture validation, and generated-artifact contract checks.
- Automated release packaging, SHA-256 checksums, changelog extraction, and GitHub Release publishing.
