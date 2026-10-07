# Changelog

All changes to the maintained RepoDNA framework are recorded here. Historical
implementation details remain recoverable from Git history.

## [Unreleased]

### Removed

- Removed 236 tracked files belonging to the discontinued standalone analyzer,
  including its CLI, installer, collectors, renderers, report schemas,
  configurations, documentation and dedicated test suite.
- Removed the analyzer's Python dependency set. The supported product is now
  the `repodna-audit` and `repodna-itch-format` skills and their framework.

### Changed

- Updated the README and contributor guide to describe the maintained skills.
- Updated the audit specification and methodology to record the removal.
- Restricted the Python formatting check to the maintained scripts.
