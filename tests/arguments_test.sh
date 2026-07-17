#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SOURCE_ROOT/src/core/runtime.sh"
source "$SOURCE_ROOT/src/core/arguments.sh"

parse_arguments
[[ -z "$AUTHOR" && -z "$SINCE" && -z "$UNTIL" ]]
[[ "$INCLUDE_SOURCE" == false && "$PRIVACY_MODE" == standard ]]
[[ ${#OWNED_ROOTS[@]} -eq 0 ]]

parse_arguments --author Developer --since 2024-01-01 --until 2025-01-01 \
    --owned-root ./src --owned-root Assets/Project --include-source
[[ "$AUTHOR" == Developer && "$SINCE" == 2024-01-01 && "$UNTIL" == 2025-01-01 ]]
[[ "$INCLUDE_SOURCE" == true ]]
[[ "${OWNED_ROOTS[*]}" == 'src Assets/Project' ]]

parse_arguments --include-source --privacy-mode strict
[[ "$PRIVACY_MODE" == strict && "$INCLUDE_SOURCE" == false ]]

if (parse_arguments --privacy-mode unsafe) >/dev/null 2>&1; then
    echo 'Invalid privacy mode was accepted.' >&2
    exit 1
fi
if (parse_arguments --since) >/dev/null 2>&1; then
    echo 'Missing option value was accepted.' >&2
    exit 1
fi
if (parse_arguments --unknown) >/dev/null 2>&1; then
    echo 'Unknown option was accepted.' >&2
    exit 1
fi

printf '%s\n' 'argument tests passed'
