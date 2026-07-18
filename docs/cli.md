# RepoDNA command-line interface

The public 1.0 CLI is the root `repodna` executable. `dna-analysis.sh` remains
the internal-compatible engine and may still be called by existing automation.

Commands are `analyze`, `doctor`, `init`, `version`, and `help`. `analyze`
supports repository targeting, output selection, author filtering, a preferred
entry format, privacy mode, custom ignore files, graph/history suppression,
snapshots, comparisons, and normal, verbose, quiet, or debug output.

`--format` selects the entry format announced by the CLI. The canonical bundle
continues to retain JSON plus linked report artifacts so all rendered values
remain derived from the same evidence model.

`repodna init [repository]` creates missing `.repodna-ignore`,
`.repodna-secrets-allowlist`, `.repodna-authors`, and `.repodna/` entries. It
never overwrites an existing configuration file.

Exit codes are stable:

| Code | Meaning |
|---:|---|
| 0 | Success |
| 1 | Analysis error |
| 2 | Invalid command or arguments |
| 3 | Missing required dependency |
| 4 | Privacy/security block; report remains available but archive is blocked |
| 5 | Partial analysis |

`doctor` checks Git, Bash, Python, optional Python modules, ShellCheck,
Graphviz, archive backends, temporary-directory writes, current-directory
permissions, locale, UTF-8 signals, and Bash compatibility before a long run.
