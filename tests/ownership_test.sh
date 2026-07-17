#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODE_ROOT='.'
OWNED_ROOTS=(Assets/_Project)

source "$REPO_ROOT/src/core/strings.sh"

_load_repodna_ignore_directories() {
    printf '%s\n' 'Ignored'
}

analysis_find() {
    find "$CODE_ROOT" "$@"
}

source "$REPO_ROOT/src/core/ownership.sh"

cd "$REPO_ROOT" || exit 1
ownership_initialize

assert_classification() {
    local path="$1"
    local expected_class="$2"
    local expected_confidence="$3"

    classify_ownership "$path"

    if [[ "$OWNERSHIP_CLASS" != "$expected_class" ||
          "$OWNERSHIP_CONFIDENCE" != "$expected_confidence" ]]; then
        printf 'FAIL: %s: expected %s/%s, got %s/%s (%s)\n' \
            "$path" "$expected_class" "$expected_confidence" \
            "$OWNERSHIP_CLASS" "$OWNERSHIP_CONFIDENCE" "$OWNERSHIP_REASON" >&2
        return 1
    fi
}

assert_classification Assets/Ignored/File.cs excluded High
assert_classification Assets/Nested/Ignored/File.cs excluded High
assert_classification Assets/Generated/File.cs generated High
assert_classification Assets/_Project/File.cs project-owned High
assert_classification Assets/Plugins/Photon/File.cs third-party High
assert_classification README.md project-owned Low
assert_classification Unknown/File.cs review-required Low

ownership_is_reviewable Unknown/File.cs
! ownership_is_reviewable Assets/Plugins/Photon/File.cs

report_file="$(mktemp)"
trap 'rm -f "$report_file"' EXIT
write_ownership_report "$report_file"
grep -q '^Ownership classification$' "$report_file"
grep -q 'Assets/_Project/' "$report_file"

printf '%s\n' 'ownership tests passed'
