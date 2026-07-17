# 🧬 RepoDNA

![License](https://img.shields.io/github/license/phillipeaam/repo-dna)
![GitHub last commit](https://img.shields.io/github/last-commit/phillipeaam/repo-dna)
![GitHub issues](https://img.shields.io/github/issues/phillipeaam/repo-dna)
![GitHub stars](https://img.shields.io/github/stars/phillipeaam/repo-dna?style=social)

> **Understand the architecture, evolution and engineering behind any repository.**

![banner.png](assets/images/banner.png)

RepoDNA is an open-source repository analysis toolkit that combines **source code inspection**, **Git history**, **architecture discovery**, and **technology detection** to generate comprehensive engineering reports.

Instead of simply counting files or commits, RepoDNA correlates repository structure, source code, technologies, design patterns, and Git history to produce evidence-based reports that help developers understand **what a project is, how it evolved, and where engineering effort was invested.**

---
## 📖 Documentation

- [Bash Cheat Sheet](docs/bash-cheatsheet.md)
- Architecture *(coming soon)*
- Roadmap
- Contributing
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
- Python 3 for generic collection and HTML/Notion report rendering;
- `matplotlib` for commit-history charts.

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
```

If Python is installed under a non-standard command, select it explicitly:

```bash
REPO_DNA_PYTHON=/path/to/python bash ./dna-analysis.sh
```

## Customizing Directory Exclusions

By default, RepoDNA excludes common directories like `Library/`, `Plugins/`, `Build/`, and `.git/`. 

To customize exclusions for your project, create a `.repodnaignore` file in your repository root:

```
# Project-specific exclusions
Assets/Plugins/
Assets/Generated/
vendor/
**/*.generated.cs
```

See [EXCLUSIONS.md](./EXCLUSIONS.md) for detailed configuration documentation.

## Source Ownership

RepoDNA combines known vendor and generated paths, `.asmdef` files, dependency
manifests, Git submodules, copyright headers, `.repodnaignore`, and Git tracking
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

Python 3 is required because HTML is now the standard report format. RepoDNA
stops early with an installation hint when it cannot resolve an executable
runtime. `matplotlib` is required for the optional PNG charts; the HTML reports
still work when only that package is unavailable.

The future ATS résumé design and X-Y-Z evidence contract are documented in
[`docs/ats-xyz-resume-design.md`](docs/ats-xyz-resume-design.md).

---

# 🛣 Roadmap

### Core

- [ ] Repository detection
- [ ] Multi-language architecture analysis
- [ ] Git contribution analysis
- [ ] Report generation

### Supported Platforms

- [ ] Unity
- [ ] Unreal Engine
- [ ] Godot
- [ ] Android
- [ ] iOS
- [ ] Flutter
- [ ] .NET

### Reports

- [ ] HTML report suite
- [ ] JSON
- [ ] CSV
- [ ] Interactive Dashboard

### Advanced Analysis

- [ ] Dependency graph
- [ ] Architecture diagrams
- [ ] Complexity analysis
- [ ] Code ownership analysis
- [ ] Design pattern detection
- [ ] Technical debt report
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

---

# 📜 License

Distributed under the **MIT License**.
