#!/usr/bin/env bats

setup() {
    export REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
}

run_repo_test() {
    run bash "$REPO_ROOT/tests/$1"
    if [[ "$status" -ne 0 ]]; then
        printf '%s\n' "$output" >&3
    fi
    [[ "$status" -eq 0 ]]
}

@test "CLI argument parsing" {
    run_repo_test arguments_test.sh
}

@test "automatic project detection" {
    run_repo_test project_detection_test.sh
}

@test "repository exclusions" {
    run_repo_test exclusions_test.sh
}

@test "security findings are redacted" {
    run_repo_test security_scan_test.sh
}

@test "versioned fixtures remain isolated" {
    run_repo_test fixtures_test.sh
}

@test "runtime fallbacks are graceful" {
    run_repo_test runtime_fallbacks_test.sh
}
