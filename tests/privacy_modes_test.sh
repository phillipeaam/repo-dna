#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .privacy-test.XXXXXX)"

cleanup() {
    cd "$SOURCE_ROOT" || return
    rm -rf "$TEST_ROOT" 2>/dev/null || true
}

trap cleanup EXIT

create_fixture() {
    local fixture="$1"

    mkdir -p "$fixture/lib" "$fixture/utils" "$fixture/renderers" "$fixture/collectors" "$fixture/src/core" "$fixture/src/reports" "$fixture/src/analyzers" "$fixture/src/code"
    cp "$SOURCE_ROOT/dna-analysis.sh" "$fixture/"
    cp "$SOURCE_ROOT/lib/"*.sh "$fixture/lib/"
    cp "$SOURCE_ROOT/utils/"*.sh "$fixture/utils/"
    cp "$SOURCE_ROOT/renderers/"*.py "$fixture/renderers/"
    cp "$SOURCE_ROOT/collectors/"*.py "$fixture/collectors/"
    cp "$SOURCE_ROOT/src/core/"*.sh "$fixture/src/core/"
    cp "$SOURCE_ROOT/src/reports/"*.py "$fixture/src/reports/"
    cp "$SOURCE_ROOT/src/analyzers/"*.sh "$fixture/src/analyzers/"
    printf '%s\n' '<Project Sdk="Microsoft.NET.Sdk" />' > "$fixture/sample.csproj"
    printf '%s\n' 'namespace Sample { public class Example { string api_key = "test-secret-value"; } }' > "$fixture/src/code/Example.cs"

    git -C "$fixture" init -q
    git -C "$fixture" config user.name 'Private Developer'
    git -C "$fixture" config user.email 'private@example.test'
    git -C "$fixture" remote add origin 'https://example.test/private/repository.git'
    git -C "$fixture" add .
    git -C "$fixture" commit -qm 'Confidential project setup'
}

find_report() {
    find "$1" -maxdepth 1 -type d -name '*_project_analysis_*' -print -quit
}

default_fixture="$TEST_ROOT/default-project"
create_fixture "$default_fixture"
(cd "$default_fixture" && bash ./dna-analysis.sh >/dev/null)
default_report="$(find_report "$default_fixture")"
[[ -n "$default_report" ]]
[[ -f "$default_report/security/potential_secrets.txt" ]]
[[ -f "$default_report/report/data/report.json" ]]
[[ -f "$default_report/report/data/generic-analysis.json" ]]
[[ -f "$default_report/report/index.html" ]]
grep -q '"schema_version": "1.1"' "$default_report/report/data/report.json"
grep -q '"generic_analysis"' "$default_report/report/data/report.json"
[[ -f "$default_report/report/executive-summary.html" ]]
[[ -f "$default_report/notion/evidence.json" ]]
grep -q 'Type: possible API token' "$default_report/security/potential_secrets.txt"
grep -q 'Value: \[REDACTED\]' "$default_report/security/potential_secrets.txt"
! grep -q 'test-secret-value' "$default_report/security/potential_secrets.txt"
! find "$default_report/source" -type f -name '*.cs' -print -quit 2>/dev/null | grep -q .
printf '%s\n' 'default mode passed'

source_fixture="$TEST_ROOT/source-project"
create_fixture "$source_fixture"
(cd "$source_fixture" && bash ./dna-analysis.sh --include-source >/dev/null)
source_report="$(find_report "$source_fixture")"
find "$source_report/source" -type f -name '*.cs' -print -quit | grep -q .
grep -q 'Result: blocked' "$source_report/summary/03_privacy_scan.txt"
[[ ! -f "$source_report.zip" ]]
printf '%s\n' 'source opt-in passed'

strict_fixture="$TEST_ROOT/strict-project"
create_fixture "$strict_fixture"
(cd "$strict_fixture" && bash ./dna-analysis.sh --include-source --privacy-mode strict >/dev/null)
strict_report="$(find_report "$strict_fixture")"
[[ -n "$strict_report" ]]
[[ ! -d "$strict_report/source" ]]
[[ ! -f "$strict_report/data/history_commits.csv" ]]
grep -q 'Origin remote: \[redacted\]' "$strict_report/project/00_repository_information.txt"
grep -q 'Result: passed' "$strict_report/summary/03_privacy_scan.txt"
! grep -RFiq 'private@example.test' "$strict_report"
! grep -RFiq 'https://example.test/private/repository.git' "$strict_report"
! grep -RFiq 'Confidential project setup' "$strict_report"
printf '%s\n' 'strict mode passed'

printf '%s\n' 'privacy mode tests passed'
