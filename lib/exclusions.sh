#!/usr/bin/env bash

# Directory exclusion system for DNA analysis
# Provides centralized functions to filter out ignored directories
# and respect .repodnaignore patterns across all file operations

# Source string utilities if available (provides string_trim)
if [[ -n "${REPO_ROOT:-}" && -f "${REPO_ROOT}/utils/strings.sh" ]]; then
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/utils/strings.sh"
fi

# Define common directories to ignore across all projects.
# These are typically generated, cached, or third-party directories.
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

# Helper: Load directory patterns from .repodnaignore file.
# Internal use only - parses .repodnaignore for directory patterns.
_load_repodnaignore_directories() {
    local config_file="${REPO_ROOT}/.repodnaignore"

    [[ -f "$config_file" ]] || return 0

    while IFS= read -r pattern || [[ -n "$pattern" ]]; do
        [[ -z "$pattern" ]] && continue
        [[ "$pattern" =~ ^[[:space:]]*# ]] && continue

        pattern="$(string_trim "$pattern")"
        [[ -z "$pattern" ]] && continue

        if [[ "$pattern" == */ ]]; then
            printf '%s\n' "${pattern%/}"
        fi
    done < "$config_file"
}

# Helper: Build find predicates from IGNORED_DIRS and .repodnaignore.
# Internal use only - used by analysis_find().
_build_find_prune_predicates() {
    local first=true

    for dir in "${IGNORED_DIRS[@]}"; do
        if [[ "$first" == true ]]; then
            printf '-name %s' "$dir"
            first=false
        else
            printf ' -o -name %s' "$dir"
        fi
    done

    while IFS= read -r dir || [[ -n "$dir" ]]; do
        printf ' -o -name %s' "$dir"
    done < <(_load_repodnaignore_directories)
}

# Build find predicate arguments for paths to exclude.
# Returns -path and -path/* patterns suitable for find -prune.
# This is more precise than -name for complex paths.
build_find_path_predicates() {
    local first=true
    local dir

    # Add Git metadata (always excluded)
    printf '-path */.git -o -path */.git/*'
    first=false

    # Add output and report directories (analysis artifacts)
    printf ' -o -path "%s" -o -path "%s/*"' "$OUTPUT_DIR" "$OUTPUT_DIR"
    printf ' -o -path "./%s" -o -path "./%s/*"' "$REPORT_NAME" "$REPORT_NAME"

    # Add each directory from IGNORED_DIRS
    for dir in "${IGNORED_DIRS[@]}"; do
        printf ' -o -path "*/%s" -o -path "*/%s/*"' "$dir" "$dir"
    done

    # Add each directory from .repodnaignore
    while IFS= read -r dir || [[ -n "$dir" ]]; do
        printf ' -o -path "*/%s" -o -path "*/%s/*"' "$dir" "$dir"
    done < <(_load_repodnaignore_directories)
}

# Find source files while respecting all exclusion rules.
# All directories in IGNORED_DIRS and .repodnaignore are pruned.
# Usage: analysis_find -type f -iname '*.cs' -print
analysis_find() {
    find "$CODE_ROOT" \( \
            -path '*/.git' -o -path '*/.git/*' -o \
            -path "$OUTPUT_DIR" -o -path "$OUTPUT_DIR/*" -o \
            -path "./$REPORT_NAME" -o -path "./$REPORT_NAME/*" -o \
            \( $(_build_find_prune_predicates) \) \
        \) -prune -o "$@"
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
    done < <(_load_repodnaignore_directories)

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
