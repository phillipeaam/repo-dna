#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .git-history-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

git -C "$TEST_ROOT" init -q
git -C "$TEST_ROOT" config user.name 'History Tester'
git -C "$TEST_ROOT" config user.email 'history@example.test'
printf 'one\n' > "$TEST_ROOT/Original.cs"
git -C "$TEST_ROOT" add Original.cs
git -C "$TEST_ROOT" commit -qm 'Initial source'
git -C "$TEST_ROOT" mv Original.cs Renamed.cs
printf 'two\n' >> "$TEST_ROOT/Renamed.cs"
git -C "$TEST_ROOT" commit -qam 'Rename source'

AUTHOR=''
DATE_FILTER=()
PRIVACY_MODE=standard
PROJECT_TYPE=.NET
source "$SOURCE_ROOT/src/core/git.sh"
source "$SOURCE_ROOT/src/core/filesystem.sh"
source "$SOURCE_ROOT/src/git/history-metrics.sh"
source "$SOURCE_ROOT/src/git/history-specialized.sh"

cd "$TEST_ROOT"
git_history_reset
collect_git_history_metrics
collect_specialized_git_metrics

[[ ${#GIT_HISTORY[@]} -ge 19 ]]
[[ "${GIT_HISTORY[total_commits]}" == 2 ]]
[[ "${GIT_HISTORY[non_merge_commits]}" == 2 ]]
[[ "${GIT_HISTORY[merge_commits]}" == 0 ]]
[[ "${GIT_HISTORY[historical_cs_files]}" -ge 1 ]]
[[ "${GIT_HISTORY[lines_added]}" -ge 2 ]]
[[ "${GIT_HISTORY[first_commit]}" == *'Initial source'* ]]
[[ "${GIT_HISTORY[last_commit]}" == *'Rename source'* ]]

PRIVACY_MODE=strict
git_history_reset
collect_git_history_metrics
[[ "${GIT_HISTORY[first_commit]}" == '[commit content omitted in strict privacy mode]' ]]
[[ "${GIT_HISTORY[last_commit]}" == '[commit content omitted in strict privacy mode]' ]]

printf '%s\n' 'Git history tests passed'
