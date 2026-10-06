#!/usr/bin/env bash
# Historical entrypoint retained to fail safely for existing callers.
set -u
printf '%s\n' 'The legacy DNA analysis pipeline is retired and will not inspect or modify a repository.' >&2
printf '%s\n' 'Use the repodna-audit Codex skill; see README.md for the supported workflow.' >&2
exit 2
