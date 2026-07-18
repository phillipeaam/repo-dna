#!/usr/bin/env bash

readonly MINIMUM_BASH_MAJOR=4
readonly MINIMUM_BASH_MINOR=3
readonly MINIMUM_BASH_VERSION="${MINIMUM_BASH_MAJOR}.${MINIMUM_BASH_MINOR}"

bash_version_supported() {
    local major="${1:-0}"
    local minor="${2:-0}"

    ((major > MINIMUM_BASH_MAJOR ||
      (major == MINIMUM_BASH_MAJOR && minor >= MINIMUM_BASH_MINOR)))
}

require_supported_bash() {
    local major="${1:-0}"
    local minor="${2:-0}"
    local detected="${3:-${major}.${minor}}"

    if bash_version_supported "$major" "$minor"; then
        return 0
    fi

    printf 'RepoDNA requires Bash %s or newer; detected Bash %s.\n' \
        "$MINIMUM_BASH_VERSION" "$detected" >&2
    printf 'On Windows, run RepoDNA with a current Git Bash. On macOS, install a modern Bash instead of the legacy system Bash.\n' >&2
    return 1
}
