#!/usr/bin/env bash

# Directory exclusion system for RepoDNA.
# Centralizes directory filtering for file discovery and text searches.

# Ensure the repository root is available.
[[ -n "${REPO_ROOT:-}" ]] || {
    printf '%s\n' 'REPO_ROOT is not defined.' >&2
    return 1 2>/dev/null || exit 1
}

# Load required string utilities.
if [[ -f "${REPO_ROOT}/utils/strings.sh" ]]; then
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/utils/strings.sh"
else
    printf 'Missing utility: %s\n' \
        "${REPO_ROOT}/utils/strings.sh" >&2

    return 1 2>/dev/null || exit 1
fi

# Define directories ignored in every analysis.
declare -ar IGNORED_DIRS=(
    Library
    Logs
    Temp
    Obj
    Build
    Builds
    UserSettings
    MemoryCaptures
    .git
)

# Load directory entries from .repodnaignore.
_load_repodna_ignore_directories() {
    local config_file="${REPO_ROOT}/.repodnaignore"
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

    while IFS= read -r dir || [[ -n "$dir" ]]; do
        predicates+=(
            -o
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
# All directories in IGNORED_DIRS and .repodnaignore are excluded from search.
# Usage: analysis_grep --include='*.cs' -InE 'pattern'
analysis_grep() {
    local -a grep_args=()
    local -a exclude_dirs=()

    # Collect all grep arguments
    for arg in "$@"; do
        grep_args+=("$arg")
    done

    # Exclude each directory from IGNORED_DIRS
    for dir in "${IGNORED_DIRS[@]}"; do
        exclude_dirs+=(--exclude-dir="$dir")
    done

    # Exclude each directory from .repodnaignore
    while IFS= read -r dir || [[ -n "$dir" ]]; do
        exclude_dirs+=(--exclude-dir="$dir")
    done < <(_load_repodna_ignore_directories)

    # Execute grep with all exclusions applied
    grep -R "${exclude_dirs[@]}" "${grep_args[@]}" "$CODE_ROOT" 2>/dev/null || true
}

# Count files matching a pattern while respecting exclusions.
# Usage: count_files_matching '*.cs'
count_files_matching() {
    local pattern="$1"

    analysis_find -type f -iname "$pattern" -print 2>/dev/null |
        wc -l |
        tr -d '[:space:]'
}
