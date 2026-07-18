# Repository health score methodology

RepoDNA's repository health score summarizes observable repository evidence. It
does not measure product quality, developer performance, business impact, or the
correctness of the software.

## Model contract

- Model: `RepoDNA repository health heuristic`
- Version: `2.0`
- Scale: 0-100 across assessed dimensions
- Grades: A (85+), B (70+), C (55+), D (40+), E (below 40)
- Output: `generic_analysis.analysis.health`

The report exposes two independent results. **Health Score** summarizes only
observed evidence. **Evidence Coverage** reports how much of the weighted model
could actually be evaluated. Confidence is `High` at 80% coverage, `Medium` at
50%, and `Low` below 50%.

Every check is classified as a proven good practice (`positive`), proven point
loss (`problem`), unavailable information (`not_observed`), unsupported analysis
(`unsupported`), or an external tool that was not executed/provided
(`external_not_executed`). Only `positive` and `problem` affect the health score.

## Dimensions

| Dimension | Weight | Current evidence |
|---|---:|---|
| Documentation | 15 | Detected documentation files |
| Testing | 20 | Test files, imported test outcomes, and imported line coverage |
| Architecture | 15 | AST/parser support for discovered source files |
| Security | 15 | Imported scanner findings and severity |
| Maintainability | 20 | Estimated complexity and imported linter results |
| Repository Hygiene | 15 | CI/CD, repository license, and configuration evidence |

Each dimension is displayed on a 0-100 scale, independently of its model weight.
The report lists every proven point loss and every unavailable check beneath the
dimension, so a low score can be distinguished from low evidence coverage.

## Important limitations

Python complexity is calculated from AST decision nodes at function level and
aggregated per file. Languages without an AST adapter still use decision-point
tokens. Both modes are useful for prioritization, but the report exposes parser
coverage so fallback estimates are not presented as equivalent to AST results.

RepoDNA does not infer vulnerabilities or dependency licenses from package names.
Without an ecosystem-aware scanner report, dependency security remains
`not_observed`. Without imported dependency-license metadata, dependency license
evidence remains `not_observed`.

The score must always be read together with its dimension evidence, model
version, assessment coverage, and limitations.
