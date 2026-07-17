#!/usr/bin/env bash

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tests=(
    architecture_test.sh
    arguments_test.sh
    project_detection_test.sh
    exclusions_test.sh
    ownership_test.sh
    author_system_ownership_test.sh
    git_history_test.sh
    security_scan_test.sh
    generic_collector_test.sh
    ast_analysis_test.sh
    framework_analysis_test.sh
    module_graph_test.sh
    architecture_insights_test.sh
    quality_importers_test.sh
    reporting_test.sh
    privacy_modes_test.sh
)

for test_file in "${tests[@]}"; do
    printf '\n==> %s\n' "$test_file"
    bash "$TEST_DIR/$test_file"
done

printf '\nAll RepoDNA tests passed.\n'
