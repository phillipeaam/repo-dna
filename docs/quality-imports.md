# Importing quality-tool results

RepoDNA reads existing machine-readable reports; it does not execute tests,
linters, coverage tools, or security scanners. A missing report is never treated
as a passing result.

## Supported formats

- Coverage: Istanbul summary JSON, Cobertura XML, JaCoCo XML, and LCOV.
- Tests: JUnit XML, Jest JSON, and pytest-json-report.
- Linters: ESLint JSON, Ruff JSON, Checkstyle XML, and SARIF.
- Security: npm audit, pip-audit, OSV-Scanner, OWASP Dependency-Check, Trivy,
  SARIF, and CycloneDX vulnerability records.
- Dependency licenses: license-checker JSON, pip-licenses JSON,
  dotnet-project-licenses JSON, CycloneDX, and SPDX JSON.

Reports are discovered through conventional filenames and limited report
patterns. Files larger than 25 MB are rejected to bound memory consumption.
Malformed reports receive `invalid`; absent reports receive `not_observed`;
successfully parsed reports receive `imported`. A missing artifact never implies
a zero measurement or a clean result.

Normalized output correlates manifest package names and lockfile-resolved
versions with imported vulnerability and license metadata. It exports finding identifiers, severities, package
versions, license identifiers, tool names, and report paths. Diagnostic messages,
source snippets, vulnerable values, test names, and secret contents are not
exported.

The dependency status is deliberately conservative:

- `affected` means an imported scanner explicitly reported a finding for that
  dependency;
- `not_resolved` means no per-dependency result could be correlated and does
  **not** mean vulnerability-free;
- `resolved` for a license means explicit license metadata was imported;
- `unresolved` means no explicit license metadata was found.

License categories (`permissive`, `review_required`, `proprietary`, and
`unresolved`) only prioritize review. They are not legal advice and do not
determine license compatibility.

Strict privacy mode retains normalized totals while removing report paths,
per-report rows, package identities, finding identifiers, and license details.
