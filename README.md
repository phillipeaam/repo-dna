# 🧬 RepoDNA

![License](https://img.shields.io/github/license/phillipeaam/repo-dna)
![GitHub last commit](https://img.shields.io/github/last-commit/phillipeaam/repo-dna)
![GitHub issues](https://img.shields.io/github/issues/phillipeaam/repo-dna)
![GitHub stars](https://img.shields.io/github/stars/phillipeaam/repo-dna?style=social)
![CI](https://github.com/phillipeaam/repo-dna/actions/workflows/ci.yml/badge.svg)

> **Understand the architecture, evolution and engineering behind any repository.**

![banner.png](assets/images/banner.png)

RepoDNA is an open-source repository analysis toolkit that combines **source code inspection**, **Git history**, **architecture discovery**, and **technology detection** to generate comprehensive engineering reports.

Instead of simply counting files or commits, RepoDNA correlates repository structure, source code, technologies, design patterns, and Git history to produce evidence-based reports that help developers understand **what a project is, how it evolved, and where engineering effort was invested.**

## What RepoDNA delivers

One command creates a timestamped analysis package containing:

- a linked HTML report that can be opened locally without a server;
- stack-neutral repository inventory for any Git project;
- specialized C# and Unity engineering signals when those stacks are detected;
- Git history, churn, contributors, collaboration signals, and composite hotspots;
- technology, dependency-manifest, test, CI/CD, Docker, and documentation inventories;
- ownership classification with confidence and evidence;
- redacted potential-secret findings and a pre-archive privacy scan;
- structured JSON for automation and Notion-oriented evidence;
- optional charts and explicitly opted-in source exports.

The default export does **not** copy full source code. Source inclusion requires
`--include-source`, while `--privacy-mode strict` takes precedence and removes
sensitive content from the shareable package.

## What has been implemented

| Area | Current behavior |
|---|---|
| Project detection | Detects Unity, Unreal, Godot, Android, Flutter, .NET, Node, Python, or falls back to a generic Git profile. |
| Generic analysis | Counts files and lines by language; lists largest files, directories, modules, configuration, documentation, tests, CI/CD, Docker, and dependencies. Python receives native AST analysis; other languages currently use an explicit heuristic fallback. |
| Git intelligence | Normalizes author aliases; calculates history by period, churn, frequently changed files, composite hotspots, co-authorship, shared files, and system evolution. |
| C# and Unity | Detects architecture signals, interfaces, systems, technical-debt markers, Unity assets, scenes, prefabs, shaders, assembly definitions, and Editor tooling. |
| Ownership | Combines paths, manifests, `.asmdef`, submodules, copyright signals, Git tracking, `.repodna-ignore`, and manual owned roots. |
| Privacy | Keeps source opt-in, supports strict mode, redacts secret values, scans the final package, and blocks archive creation when configured sensitive content remains. |
| Reporting | Produces navigable HTML, canonical JSON, Git CSV data, Notion evidence, security reports, and optional PNG charts. |

## Analysis flow

```text
Repository
    -> project detector and analysis profile
    -> generic and specialized collectors
    -> canonical report/data/report.json
    -> HTML and Notion renderers
    -> privacy scan
    -> ZIP/TAR archive when the scan passes
```

## Report tour

| Page | What it shows |
|---|---|
| Executive summary | Headline metrics, primary language, tests, dependencies, history period, and churn. |
| Project overview | Repository profile, inventory, largest files, and main directories. |
| Architecture | Specialized architecture signals or generic module candidates and language composition. |
| Technologies | Languages, line counts, dependency declarations, manifests, branches, and tags. |
| Systems | Confirmed specialized signals or systems inferred from historical paths for review. |
| Contribution | Git scope, additions/removals, changed paths, composite hotspots, and system evolution. |
| Collaboration | Contributors, co-authored commits, and files shared across authors. |
| Risks | Potential secrets and ownership classifications requiring review. |
| Notion evidence | Repository facts, inferences, evidence, and personal claims that still require confirmation. |
| Quality and compliance | Complexity plus imported coverage, test, linter, security-scanner, and license evidence. |
| Repository health | Versioned score, dimension evidence, assessment coverage, and limitations. |
| Evidence-based narrative | Human-readable statements generated only from structured repository facts. |
| Portfolio and CV | Approval-gated claims and X-Y-Z achievement drafts. |

## AST analysis status

RepoDNA now has a language-analyzer contract under `collectors/languages/`.
Python source is parsed with the standard-library AST. JavaScript, TypeScript,
C#, Java, Kotlin, Dart, Go, and Rust use optional Tree-sitter grammar adapters. These analyzers produce
structured classes, functions, qualified methods, parameters, imports, calls,
per-function complexity, and pattern evidence.

Every report exposes parser coverage per language:

- `ast`: a syntax-tree parser analyzed the file;
- `heuristic-fallback`: the language still uses symbol and naming heuristics;
- `parse_errors`: AST parsing failed and the safe fallback was used.

Install the optional grammar bundle with:

```bash
python -m pip install -r requirements-ast.txt
```

Without it, these languages safely use `heuristic-fallback` and the report
identifies the unavailable parser. Heuristic results are never described as AST
findings.

## Specialized framework adapters

Framework analysis runs above the language parsers and correlates declared
dependencies, imports, parsed symbols, calls, and conventional repository paths.
The first supported adapters are:

- Unity;
- ASP.NET Core;
- Spring;
- Android;
- Flutter;
- React;
- Next.js.

Each finding includes its framework family, evidence score, confidence,
languages, detected concepts, supporting files, and individual evidence rows.
A framework name is reported only after reaching the minimum evidence threshold;
medium-confidence findings remain explicitly reviewable. Framework detection
does not claim that runtime configuration is valid or that a feature is complete.

---
## 📖 Documentation

- [Bash Cheat Sheet](docs/bash-cheatsheet.md)
- [Architecture](docs/architecture.md)
- [Framework analysis methodology](docs/framework-analysis.md)
- [Module and dependency graphs](docs/dependency-graphs.md)
- [Architecture insights methodology](docs/architecture-insights.md)
- [Quality result imports](docs/quality-imports.md)
- [ATS and X-Y-Z résumé design](docs/ats-xyz-resume-design.md)
- [Repository health score methodology](docs/health-score.md)
- [Exclusion rules](EXCLUSIONS.md)
- [Contributing](CONTRIBUTING.md)
---

# ✨ Features

- 🔍 Automatic project detection
- 🏗 Architecture discovery
- 📦 Technology inventory
- 🧩 Gameplay and application system detection
- 📊 Project metrics
- 📈 Git contribution analysis
- 👥 Collaboration insights
- 🧠 Design pattern detection
- ⚙ Engineering signal detection
- Per-dependency vulnerability and license correlation from imported scanner,
  SBOM, SPDX, and license reports
- 📄 HTML, JSON, and CSV report generation
- 📚 Portfolio and documentation support

---

# 🎯 Why RepoDNA?

Every mature software project accumulates years of engineering decisions.

RepoDNA helps answer questions like:

- ❓ What technologies does this project use?
- ❓ Which gameplay or application systems exist?
- ❓ Which architectural patterns are present?
- ❓ Which areas did I contribute to?
- ❓ Which files changed the most?
- ❓ Which systems deserve documentation?
- ❓ How can I describe this project accurately on my CV or LinkedIn?
- ❓ What can I learn before making my first contribution?

---

# 💡 Use Cases

RepoDNA can be used for:

- 📚 Engineering documentation
- 🏛 Legacy code exploration
- 🧑‍💻 Developer onboarding
- 🎮 Game development portfolio analysis
- 📄 Career journaling
- 🔎 Technical due diligence
- 🤝 Knowledge transfer
- 📈 Project health assessment

---

# ⚙ Configuration

## Requirements

RepoDNA requires:

- Git;
- Bash (Git Bash on Windows);
- Python 3.11 or newer for generic collection and HTML/Notion report rendering;
- `matplotlib` for commit-history charts.
- the packages in `requirements-ast.txt` for JavaScript, TypeScript, C#, Java,
  Kotlin, Dart, Go, and Rust
  syntax-tree analysis (optional; heuristics remain available without them).

Check the installation with:

```bash
git --version
bash --version
python --version
python -c "import matplotlib; print(matplotlib.__version__)"
```

Install the chart dependency with:

```bash
python -m pip install matplotlib
python -m pip install -r requirements-ast.txt
```

If Python is installed under a non-standard command, select it explicitly:

```bash
REPO_DNA_PYTHON=/path/to/python bash ./dna-analysis.sh
```

## Quick start

Run RepoDNA from the root of the Git repository you want to analyze:

```bash
bash /path/to/repo-dna/dna-analysis.sh
```

Use `bash ./dna-analysis.sh --help` from the RepoDNA checkout to list every
option. Generated reports are written to a timestamped directory in the
analyzed repository; start with `report/index.html`.

To add personally confirmed portfolio context, copy
`.repodna-portfolio.example.json`, edit the answers and approved claim IDs, then
run:

```bash
bash ./dna-analysis.sh --portfolio-profile path/to/confirmations.json
```

Portfolio profiles are rejected in strict privacy mode because they may contain
personal information. Without a profile, RepoDNA still creates a draft, but all
personal attribution remains marked as requiring confirmation.

## Customizing Directory Exclusions

By default, RepoDNA excludes generated or dependency directories such as
`Library/`, `Build/`, `node_modules/`, `vendor/`, `Packages/`, and `.git/`.

To customize exclusions for your project, create a `.repodna-ignore` file in your repository root:

```
# Project-specific exclusions
Assets/Plugins/
Assets/Generated/
vendor/
```

`.repodna-ignore` currently supports directory entries ending in `/`. File globs
and negation rules are not supported yet.

See [EXCLUSIONS.md](./EXCLUSIONS.md) for detailed configuration documentation.

## Source Ownership

RepoDNA combines known vendor and generated paths, `.asmdef` files, dependency
manifests, Git submodules, copyright headers, `.repodna-ignore`, and Git tracking
to classify source ownership with a confidence level.

Use `--owned-root` more than once when repository-specific paths are known to be
project-owned:

```bash
bash dna-analysis.sh --owned-root Assets/_Project --owned-root Assets/Common
```

`-owned-root` is accepted as a compatibility alias. Manual owned roots take
precedence over vendor-name heuristics, but not over generated or ignored paths.
High-confidence third-party and generated files are not copied into the source
review folders.

## Author aliases

Git identities can be normalized with an optional `.repodna-authors` file in
the analyzed repository root. Copy `.repodna-authors.example` and list every
known name and e-mail under one canonical identity:

```yaml
Phillipe Augusto:
  names:
    - Phillipe Augusto
    - phillipe
  emails:
    - developer@example.com
```

Standard reports show the canonical contributor name and commit count. Strict
privacy mode replaces names and does not export e-mail addresses.

Without `--author`, the collaboration report covers the complete Git history
and creates paginated contributor pages with 20 canonical identities per page.
With `--author`, Git metrics, churn, hotspots, system evolution, collaboration,
and contributor presentation are restricted to the selected identity and its
aliases from `.repodna-authors`:

```bash
bash ./dna-analysis.sh --author "Phillipe Augusto"
```

## Privacy and Source Export

Full C# source is not copied by default. Reports contain metrics, relative paths,
signatures, classes, namespaces, package information, and Git statistics.

Source export requires explicit consent:

```bash
bash dna-analysis.sh --include-source
```

For professional or confidential repositories, strict privacy mode takes
precedence over every source-export option:

```bash
bash dna-analysis.sh --privacy-mode strict
```

Strict mode omits source, documentation and configuration copies, remote URLs,
e-mails, contributor identities, and commit messages. It redacts absolute paths
and source-line bodies from detector reports. Before compression, every mode
scans the generated package for likely secrets; strict mode additionally checks
for residual e-mails, URLs, and absolute repository paths. A finding blocks
archive creation and is listed by path in `summary/03_privacy_scan.txt`.

Every run also creates `security/potential_secrets.txt`. This report checks
analyzable files, including relevant untracked files, for possible API keys, Bearer tokens, private keys,
connection strings, Firebase and AWS credentials, authenticated Git remotes,
passwords, webhook URLs, private package registries, and internal domains or
private network addresses. Findings contain only the relative path, line number,
category, and `Value: [REDACTED]`; matched values are never written to the report.

## Structured Reports

RepoDNA writes canonical collected data to `report/data/report.json`. The HTML
renderer reads only that JSON and creates a linked, self-contained report set:

```text
report/
├── index.html
├── executive-summary.html
├── project-overview.html
├── architecture.html
├── technologies.html
├── systems.html
├── contribution.html
├── collaboration.html
├── quality.html
├── health.html
├── narrative.html
├── portfolio.html
├── risks.html
├── notion-evidence.html
└── data/
    └── report.json
```

Legacy evidence files remain available during the migration, but standardized
reports are HTML and no longer read Bash variables or collector output directly.
Every page links to the other report sections and can be opened locally without
a web server. Notion-ready structured evidence remains available at
`notion/evidence.json`; it explicitly separates facts, supporting evidence,
inferences, personal data, and claims that require confirmation.

Reports use the detected analysis profile. Unity-only product metadata, scenes,
prefabs, ScriptableObjects, MonoBehaviours, shaders, Addressables, and UI Toolkit
metrics are hidden for non-Unity projects. Unsupported project types receive an
explicit coverage note instead of a misleading table full of Unity zeroes.

The stack-neutral collector always writes
`report/data/generic-analysis.json`. It inventories languages and extensions,
file and line counts, largest files, directories, configuration, documentation,
tests, CI/CD, Docker, dependency manifests, contributors, branches, tags,
release tags, temporal history, churn, frequently changed files, hotspots, and
possible modules. This dataset is embedded into the canonical `report.json` and
is the fallback for unknown stacks.

## Internal architecture

`dna-analysis.sh` remains the backwards-compatible entrypoint and orchestrator.
Argument parsing, runtime discovery, filesystem helpers, Git execution, privacy,
and archive/finalization live under `src/core/`. Unity inventory collection is
isolated in `src/analyzers/unity.sh`, chart generation in
`src/reports/charts.py`, Git history services in `src/git/`, stack-neutral collection in `collectors/`, and
HTML/Notion presentation in `renderers/`. Specialized analyzers execute only for
matching project profiles, so generic repositories do not receive empty Unity
inventories.

The entrypoint is intentionally limited to 200 lines. Pipeline modules only
declare functions when sourced; their filenames do not control execution order.
`dna-analysis.sh` explicitly orchestrates those functions after loading:

```text
src/pipeline/
├── architecture.sh
├── charts.sh
├── collaboration.sh
├── context.sh
├── git-history.sh
├── guides.sh
├── inventory.sh
├── metadata.sh
├── metrics.sh
├── security-archive.sh
├── source-policy.sh
└── structured-reports.sh
```

`tests/architecture_test.sh` enforces the 200-line limit, verifies every sourced
module exists, and checks its Bash syntax.

Run the complete local suite with:

```bash
bash ./tests/run.sh
```

The same suite runs on Linux for every push and pull request through GitHub
Actions.

Python 3.11 or newer is required because HTML is now the standard report format. RepoDNA
stops early with an installation hint when it cannot resolve an executable
runtime. `matplotlib` is required for the optional PNG charts; the HTML reports
still work when only that package is unavailable.

The future ATS résumé design and X-Y-Z evidence contract are documented in
[`docs/ats-xyz-resume-design.md`](docs/ats-xyz-resume-design.md).

---

# 🛣 Roadmap

### Core

- [x] Repository and project-type detection
- [x] Stack-neutral language, dependency and repository inventory
- [x] Git contribution, churn, hotspot and collaboration analysis
- [x] Structured JSON and HTML report generation
- [x] AST analysis for Python, JavaScript, TypeScript, C#, Java, Kotlin, Dart, Go, and Rust

### Project detection

- [x] Unity
- [x] Unreal Engine
- [x] Godot
- [x] Android
- [x] Flutter
- [x] .NET
- [x] Node
- [x] Python
- [ ] iOS

Specialized framework evidence is currently available for Unity, ASP.NET Core,
Spring, Android, Flutter, React, and Next.js. Other detected stacks retain the
generic analyzer and explicit parser/framework coverage.

### Reports

- [x] HTML report suite
- [x] Canonical JSON
- [x] Git history CSV
- [ ] Interactive Dashboard

### Advanced Analysis

- [x] Resolved file, module, and external dependency graphs
- [x] Entrypoint, coupling, cycle, and inferred boundary analysis
- [ ] Architecture diagrams
- [x] File and per-function complexity analysis
- [x] Coverage, test, linter, and security scanner result imports
- [x] Evidence-based code ownership classification
- [x] C# design-pattern signals
- [x] Technical-debt markers
- [ ] AI-powered project summary
- [ ] Pull Request analysis

---

# 🚀 Vision

RepoDNA aims to become a universal repository analysis platform capable of helping engineers understand any software project—regardless of language, framework, or engine.

The long-term goal is to transform complex repositories into actionable engineering insights that support development, documentation, onboarding, technical reviews, and career growth.

---

# 🤝 Contributing

Contributions, ideas, feature requests, and bug reports are always welcome.

If you have suggestions for new analyzers, technologies, or report formats, feel free to open an issue or submit a pull request.

See [CONTRIBUTING.md](CONTRIBUTING.md) for architecture rules and the complete
validation workflow.

---

# 📜 License

Distributed under the **MIT License**.
