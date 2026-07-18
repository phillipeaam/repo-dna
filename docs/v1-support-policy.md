# Version 1.0 support policy

RepoDNA 1.0 favors a small reliable contract over universal or runtime-complete
analysis.

## Product promise

> RepoDNA analyzes a local Git repository and produces evidence-based reports
> about its technologies, architecture, systems, contribution history,
> maintainability, risks, onboarding, and professional portfolio evidence.

“Evidence-based” means every fact, metric, inference, candidate, confidence, and
unknown is derived from local repository content, Git history, an explicitly
provided import, or personal confirmation. Repository evidence is never promoted
to proof of runtime behavior, business impact, formal ownership, security, or
overall code quality.

## Stable core

| Capability | 1.0 guarantee |
|---|---|
| Repository | Local, non-bare Git repository with readable working tree and history |
| Generic analysis | Stack-neutral fallback for every detected or unknown project type |
| Validated ecosystems | Bash and Python repositories; Python has native AST, Bash uses explicit static heuristics |
| Inventory | Languages, extensions, lines, files, directories, manifests, documentation, tests, CI/CD, and containers |
| Git evidence | History, optional author scope, aliases, contributors, churn, versioned hotspots, collaboration, and temporal evolution |
| Structure | Module/system candidates, symbols, imports, dependencies, entrypoints, coupling, cycles, and inferred boundaries when evidence exists |
| Quality and risks | Static maintainability/risk signals and conservative ingestion of versioned external coverage, test, linter, license, and scanner results |
| Onboarding | Entrypoints, declared or suggested commands, repository map, workflow evidence, and explicit unknowns |
| Portfolio evidence | Repository facts and author-filtered candidates; personal ownership and impact always require confirmation |
| Reports | Offline HTML navigation and JSON artifacts validated against packaged versioned Schemas |
| Privacy | No source export by default, strict sanitization, exclusions, redacted secret findings, and archive blocking when the privacy scan fails |

Support means the analyzer produces a valid report and communicates unavailable
or unassessed evidence explicitly. It does not mean every row will contain a
finding: empty evidence is valid when the repository does not contain that data.

## Additional specialized adapters

Unity, Unreal, Godot, Android, Flutter, .NET, Node, language AST adapters, and
framework adapters are shipped and tested as extensions of the stable core.
They provide additional static evidence when their markers are detected, while
the generic dataset remains the common fallback and interoperability contract.

For 1.0 these adapters do not promise:

- compilation, dependency installation, test execution, packaging, deployment,
  editor import, or application startup;
- complete interpretation of generated, binary, dynamically loaded, or runtime-
  configured behavior;
- parity between every language, engine, framework, or package manager;
- absence of vulnerabilities, defects, licensing conflicts, or technical debt.

## Environment contract

- Git with a readable local repository;
- Bash 4.3 or newer;
- Python 3.11 or newer;
- required packages from `requirements-reporting.txt`;
- optional Tree-sitter packages from `requirements-ast.txt` for the documented
  language adapters;
- optional `matplotlib` support for PNG charts.

CI validates the core on Linux, macOS, and Windows Git Bash. Reports expose
parser, importer, privacy, and assessment status so optional capabilities cannot
silently appear equivalent to validated evidence.

## Compatibility

Versioned JSON Schemas, snapshot contracts, health-score versions, and hotspot
model versions define machine-readable compatibility. A breaking change to the
stable core requires a new major contract version or an explicit migration path.

Features outside this document may evolve during the 1.x line as long as they do
not weaken the stable core or silently change the meaning of existing evidence.
