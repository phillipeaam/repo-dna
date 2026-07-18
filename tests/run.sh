#!/usr/bin/env bash

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tests=(
    fixtures_test.sh
    architecture_test.sh
    arguments_test.sh
    project_detection_test.sh
    exclusions_test.sh
    ownership_test.sh
    author_system_ownership_test.sh
    bus_factor_test.sh
    system_documentation_test.sh
    onboarding_test.sh
    technical_impact_test.sh
    achievement_candidates_test.sh
    git_history_test.sh
    delivery_analysis_test.sh
    forge_import_test.sh
    security_scan_test.sh
    generic_collector_test.sh
    ast_analysis_test.sh
    framework_analysis_test.sh
    unity_analysis_test.sh
    android_analysis_test.sh
    flutter_analysis_test.sh
    module_graph_test.sh
    architecture_insights_test.sh
    quality_importers_test.sh
    dependency_inventory_test.sh
    period_comparison_test.sh
    health_trends_test.sh
    reporting_test.sh
    charts_test.sh
    artifact_contract_test.sh
    release_workflow_test.sh
    privacy_modes_test.sh
    edge_cases_test.sh
    runtime_fallbacks_test.sh
)

for test_file in "${tests[@]}"; do
    printf '\n==> %s\n' "$test_file"
    bash "$TEST_DIR/$test_file"
done

printf '\nAll RepoDNA tests passed.\n'
