#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAIN_SCRIPT="$SOURCE_ROOT/dna-analysis.sh"
MAX_MAIN_LINES=200
MAIN_LINES="$(wc -l < "$MAIN_SCRIPT" | tr -d '[:space:]')"

if ((MAIN_LINES > MAX_MAIN_LINES)); then
    printf 'dna-analysis.sh has %s lines; maximum is %s.\n' "$MAIN_LINES" "$MAX_MAIN_LINES" >&2
    exit 1
fi

bash -n "$MAIN_SCRIPT"
while IFS= read -r module; do
    [[ -f "$SOURCE_ROOT/$module" ]] || {
        printf 'Missing sourced module: %s\n' "$module" >&2
        exit 1
    }
    bash -n "$SOURCE_ROOT/$module"
    bash -c 'source "$1"' _ "$SOURCE_ROOT/$module"
done < <(sed -n 's/^# shellcheck source=//p' "$MAIN_SCRIPT")

printf 'architecture tests passed (%s main lines)\n' "$MAIN_LINES"
