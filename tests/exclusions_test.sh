#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .exclusions-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/src" "$TEST_ROOT/vendor" "$TEST_ROOT/Ignored" "$TEST_ROOT/generated-report"
printf 'visible\n' > "$TEST_ROOT/src/visible.txt"
printf 'hidden\n' > "$TEST_ROOT/vendor/dependency.txt"
printf 'hidden\n' > "$TEST_ROOT/Ignored/custom.txt"
printf 'hidden\n' > "$TEST_ROOT/generated-report/report.txt"
printf 'Ignored/\n' > "$TEST_ROOT/.repodnaignore"

REPO_ROOT="$TEST_ROOT"
CODE_ROOT='.'
REPORT_NAME='generated-report'
source "$SOURCE_ROOT/src/core/exclusions.sh"
cd "$TEST_ROOT"

results="$(analysis_find -type f -print | sort)"
grep -q './src/visible.txt' <<< "$results"
! grep -q 'vendor/dependency.txt' <<< "$results"
! grep -q 'Ignored/custom.txt' <<< "$results"
! grep -q 'generated-report/report.txt' <<< "$results"
[[ "$(count_files_matching '*.txt')" == 1 ]]

grep -q visible < <(analysis_grep -n 'visible')
if analysis_grep -n 'missing-pattern' >/dev/null; then
    echo 'analysis_grep should preserve the no-match status.' >&2
    exit 1
fi

printf '%s\n' 'exclusion tests passed'
