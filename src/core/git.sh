#!/usr/bin/env bash

# Execute git log using the configured optional filters.
analysis_git_log() {
    # Copy detection is intentionally excluded here: applying -C to every
    # historical diff is quadratic on large repositories. Rename detection
    # preserves path continuity at a predictable cost.
    local filters=(--all --find-renames)
    [[ -n "${AUTHOR:-}" ]] && filters+=(--author="$AUTHOR")
    filters+=("${DATE_FILTER[@]}")
    git log "${filters[@]}" "$@"
}
