# Runtime requirements

RepoDNA operates in dependency layers. The mandatory core requires Bash 4.3 or
newer, Git, and the basic Unix tools `awk`, `find`, `grep`, `sed`, and `sort`.
This Bash minimum exists because the codebase
uses associative arrays and namerefs (`local -n`) to keep registries and shared
helpers structured without external processes.

The entrypoint checks `BASH_VERSINFO` before sourcing modules that depend on
these features. An unsupported runtime exits with status `2` and explains both
the required and detected versions.

```text
RepoDNA requires Bash 4.3 or newer; detected Bash 3.2.57(1)-release.
On Windows, run RepoDNA with a current Git Bash. On macOS, install a modern Bash instead of the legacy system Bash.
```

Use:

```bash
bash --version
bash ./dna-analysis.sh
```

Do not invoke the entrypoint with `sh`: POSIX shells do not provide the Bash
features required by RepoDNA. Current Git Bash, modern Linux distributions,
Homebrew Bash on macOS, and current WSL distributions normally satisfy the
minimum.

## Recommended dependencies

Python 3.11+ with the JSON Schema package enables the canonical JSON model, standardized HTML dashboards,
JSON Schema validation, specialized analyzers, snapshots, SBOM, and derived
evidence datasets. Matplotlib enables charts. If Python is unavailable, RepoDNA
still creates a basic inventory, Git reports, privacy scan, partial JSON, HTML,
and archive, then exits with status `5` to make the degradation observable.

```bash
python -m pip install -r requirements-reporting.txt
```

If only Matplotlib is missing, analysis succeeds and graph generation is
skipped with an installation hint.

## Optional dependencies

- Tree-sitter improves syntax-aware architecture and pattern detection;
- Graphviz enables compatible external graph workflows;
- coverage, lint, vulnerability, and security scanners can provide importable
  evidence;
- ecosystem-specific analyzers add detail when their inputs are present.

Missing optional dependencies never abort the repository analysis. Run
`repodna doctor` before a long analysis to see each dependency's tier and the
features affected by anything unavailable.
