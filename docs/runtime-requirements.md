# Runtime requirements

RepoDNA requires Bash 4.3 or newer. This minimum exists because the codebase
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
