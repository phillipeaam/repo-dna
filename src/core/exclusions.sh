#!/usr/bin/env bash

# Directory exclusion system for RepoDNA.
# Centralizes directory filtering for file discovery and text searches.

# Ensure the repository root is available.
[[ -n "${REPO_ROOT:-}" ]] || {
    printf '%s\n' 'REPO_ROOT is not defined.' >&2
    return 1 2>/dev/null || exit 1
}

# Load required string utilities relative to this module, not the analyzed repo.
# shellcheck source=src/core/strings.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/strings.sh"

# Define directories ignored in every analysis.
declare -gar IGNORED_DIRS=(
    Library
    Logs
    Temp
    Obj
    Build
    Builds
    UserSettings
    MemoryCaptures
    node_modules
    vendor
    Packages
    .git
    .repodna
    .idea
    tests/fixtures
)

# Load directory entries from .repodna-ignore.
_load_repodna_ignore_directories() {
    local config_file="${IGNORE_FILE:-${REPO_ROOT}/.repodna-ignore}"
    local pattern

    [[ -f "$config_file" ]] || return 0

    while IFS= read -r pattern || [[ -n "$pattern" ]]; do
        pattern="$(string_trim "$pattern")"

        [[ -z "$pattern" ]] && continue
        [[ "$pattern" =~ ^# ]] && continue

        if [[ "$pattern" == */ ]]; then
            printf '%s\n' "${pattern%/}"
        fi
    done < "$config_file"
}

# Append find-compatible prune predicates to the array named by $1.
build_find_prune_predicates() {
    local -n predicates="$1"
    local dir
    local first=true

    for dir in "${IGNORED_DIRS[@]}"; do
        if [[ "$first" == true ]]; then
            first=false
        else
            predicates+=(-o)
        fi

        predicates+=(
            -path "*/$dir"
            -o
            -path "*/$dir/*"
        )
    done

    # Never analyze the report directory while it is being generated.
    if [[ -n "${REPORT_NAME:-}" ]]; then
        if [[ "$first" == true ]]; then
            first=false
        else
            predicates+=(-o)
        fi

        predicates+=(
            -path "*/$REPORT_NAME"
            -o
            -path "*/$REPORT_NAME/*"
        )
    fi

    while IFS= read -r dir || [[ -n "$dir" ]]; do
        # Preserve a valid find expression if built-in exclusions become empty.
        if [[ "$first" == true ]]; then
            first=false
        else
            predicates+=(-o)
        fi
        predicates+=(
            -path "*/$dir"
            -o
            -path "*/$dir/*"
        )
    done < <(_load_repodna_ignore_directories)
}

# Find files while pruning all ignored directories.
# Usage: analysis_find -type f -iname '*.cs' -print
analysis_find() {
    local -a prune=()

    [[ -d "${CODE_ROOT:-}" ]] || {
        printf 'Invalid CODE_ROOT: %s\n' \
            "${CODE_ROOT:-unset}" >&2
        return 1
    }

    build_find_prune_predicates prune

    find "$CODE_ROOT" \
        \( "${prune[@]}" \) \
        -prune \
        -o \
        "$@"
}

# Search recursively while respecting all exclusion rules.
# All directories in IGNORED_DIRS and .repodna-ignore are excluded from search.
# NOTE: like grep itself, this returns non-zero when nothing matches.
# Only real errors (e.g. invalid CODE_ROOT) are treated as failures here.
# Usage: analysis_grep --include='*.cs' -InE 'pattern'
analysis_grep() {
    local -a grep_args=("$@")
    local -a exclude_dirs=()
    local dir

    # Reject an invalid root instead of silently searching an empty path.
    [[ -d "${CODE_ROOT:-}" ]] || {
        printf 'Invalid CODE_ROOT: %s\n' \
            "${CODE_ROOT:-unset}" >&2
        return 1
    }

    # Exclude each directory from IGNORED_DIRS
    for dir in "${IGNORED_DIRS[@]}"; do
        exclude_dirs+=(--exclude-dir="$dir")
    done

    # Exclude each directory from .repodna-ignore
    while IFS= read -r dir || [[ -n "$dir" ]]; do
        exclude_dirs+=(--exclude-dir="$dir")
    done < <(_load_repodna_ignore_directories)

    # Execute grep with all exclusions applied.
    # Preserve grep's status so callers can distinguish matches from no matches.
    grep -R "${exclude_dirs[@]}" "${grep_args[@]}" "$CODE_ROOT" 2>/dev/null
}

# Count files matching a pattern while respecting exclusions.
# Usage: count_files_matching '*.cs'
count_files_matching() {
    local pattern="$1"

    analysis_find -type f -iname "$pattern" -print 2>/dev/null |
        wc -l |
        tr -d '[:space:]'
}
