# Repository health score methodology

RepoDNA's repository health score summarizes observable repository evidence. It
does not measure product quality, developer performance, business impact, or the
correctness of the software.

## Model contract

- Model: `RepoDNA repository health heuristic`
- Version: `1.0`
- Scale: 0-100 across assessed dimensions
- Grades: A (85+), B (70+), C (55+), D (40+), E (below 40)
- Output: `generic_analysis.analysis.health`

The report includes a separate assessment coverage percentage. A dimension that
cannot be verified is marked `not_assessed`, excluded from the score denominator,
and lowers assessment coverage. It is never treated as a passing result.

## Dimensions

| Dimension | Maximum | Current evidence |
|---|---:|---|
| Documentation | 15 | Detected documentation files |
| Testing evidence | 20 | Test files and coverage artifacts |
| Automation | 15 | CI/CD and Docker files |
| Maintainability | 20 | Estimated decision-point complexity |
| Knowledge distribution | 15 | Contributors visible in Git history |
| Governance | 10 | Repository license evidence |
| Dependency security | 5 | External scanner report evidence |

## Important limitations

Python complexity is calculated from AST decision nodes at function level and
aggregated per file. Languages without an AST adapter still use decision-point
tokens. Both modes are useful for prioritization, but the report exposes parser
coverage so fallback estimates are not presented as equivalent to AST results.

RepoDNA does not infer vulnerabilities or dependency licenses from package names.
Without an ecosystem-aware scanner report, dependency security remains
`not_scanned`. Without resolved package metadata, dependency licenses remain
`not_scanned`.

The score must always be read together with its dimension evidence, model
version, assessment coverage, and limitations.
