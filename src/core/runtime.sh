#!/usr/bin/env bash

# Return success when a command exists.
die() {
    local exit_code="${2:-1}"
    if declare -F log_error >/dev/null 2>&1; then log_error "$1"; else printf '\nError: %s\n' "$1" >&2; fi
    exit "$exit_code"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Resolve one executable Python runtime for every Python-backed feature.
resolve_python_runtime() {
    local candidate
    if [[ -n "${REPO_DNA_PYTHON:-}" ]]; then
        "$REPO_DNA_PYTHON" -c 'import sys; raise SystemExit(sys.version_info < (3, 11))' >/dev/null 2>&1 || return 1
        printf '%s' "$REPO_DNA_PYTHON"
        return 0
    fi
    for candidate in python3 python py; do
        if command_exists "$candidate" && "$candidate" -c 'import sys; raise SystemExit(sys.version_info < (3, 11))' >/dev/null 2>&1; then
            command -v "$candidate"
            return 0
        fi
    done
    return 1
}

# Convert Windows-native paths when running under Git Bash/MSYS.
normalize_repository_path() {
    local value="$1"
    value="${value//\\//}"
    if [[ "$value" =~ ^[A-Za-z]:/ ]] && command_exists cygpath; then
        cygpath -u "$value"
    else
        printf '%s' "$value"
    fi
}

format_duration() {
    local total_seconds="$1"
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    if ((hours > 0)); then
        printf '%dh %02dm %02ds' "$hours" "$minutes" "$seconds"
    elif ((minutes > 0)); then
        printf '%dm %02ds' "$minutes" "$seconds"
    else
        printf '%ds' "$seconds"
    fi
}
