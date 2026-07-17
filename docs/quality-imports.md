# Importing quality-tool results

RepoDNA reads existing machine-readable reports; it does not execute tests,
linters, coverage tools, or security scanners. A missing report is never treated
as a passing result.

## Supported formats

- Coverage: Istanbul summary JSON, Cobertura XML, JaCoCo XML, and LCOV.
- Tests: JUnit XML, Jest JSON, and pytest-json-report.
- Linters: ESLint JSON, Ruff JSON, Checkstyle XML, and SARIF.
- Security: npm audit, pip-audit, OSV-Scanner, OWASP Dependency-Check, Trivy,
  and SARIF.

Reports are discovered through conventional filenames and limited report
patterns. Files larger than 25 MB are rejected to bound memory consumption.
Malformed reports receive `invalid`; absent reports receive `not_found` or
`not_scanned`; successfully parsed reports receive `imported`.

Normalized output contains only aggregate counts, severities, tool names, report
paths, and coverage metrics. Diagnostic messages, source snippets, vulnerable
values, test names, and secret contents are not exported.

Strict privacy mode retains normalized totals while removing report paths and
per-report rows.
