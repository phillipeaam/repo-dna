#!/usr/bin/env bash

# Execute git log using the configured optional filters.
analysis_git_log() {
    local filters=(--all --find-renames --find-copies)
    [[ -n "${AUTHOR:-}" ]] && filters+=(--author="$AUTHOR")
    filters+=("${DATE_FILTER[@]}")
    git log "${filters[@]}" "$@"
}
