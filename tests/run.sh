#!/usr/bin/env bash

set -uo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE=""
if [[ "${1:-}" == --json ]]; then
    [[ -n "${2:-}" ]] || { printf '%s\n' 'Usage: tests/run.sh [--json output.json]' >&2; exit 2; }
    OUTPUT_FILE="$2"
fi

tests=(
    fixtures_test.sh architecture_test.sh arguments_test.sh cli_test.sh installation_test.sh dependency_layers_test.sh project_detection_test.sh
    exclusions_test.sh ownership_test.sh author_system_ownership_test.sh bus_factor_test.sh
    system_documentation_test.sh onboarding_test.sh technical_impact_test.sh
    achievement_candidates_test.sh git_history_test.sh delivery_analysis_test.sh
    forge_import_test.sh security_scan_test.sh generic_collector_test.sh
    author_alias_validation_test.sh ast_analysis_test.sh framework_analysis_test.sh
    unity_analysis_test.sh android_analysis_test.sh flutter_analysis_test.sh
    godot_analysis_test.sh unreal_analysis_test.sh module_graph_test.sh
    architecture_insights_test.sh quality_importers_test.sh dependency_inventory_test.sh
    period_comparison_test.sh health_trends_test.sh reporting_test.sh canonical_schema_test.sh
    canonical_model_test.sh charts_test.sh artifact_contract_test.sh release_workflow_test.sh
    privacy_modes_test.sh edge_cases_test.sh runtime_fallbacks_test.sh windows_compatibility_test.sh
)

started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
start_seconds=$SECONDS
passed=0 failed=0 skipped=0
result_rows=()

for test_file in "${tests[@]}"; do
    printf '\n==> %s\n' "$test_file"
    test_start=$SECONDS
    if bash "$TEST_DIR/$test_file"; then
        status=passed; passed=$((passed + 1))
    else
        status=failed; failed=$((failed + 1))
    fi
    result_rows+=("$test_file|$status|$((SECONDS - test_start))")
done

duration=$((SECONDS - start_seconds))
total=${#tests[@]}
status=passed; [[ "$failed" -eq 0 ]] || status=failed

if [[ -n "$OUTPUT_FILE" ]]; then
    mkdir -p "$(dirname "$OUTPUT_FILE")"
    {
        printf '{\n  "$schema": "./test-execution-1.0.0.schema.json",\n'
        printf '  "schema_version": "1.0",\n  "artifact_type": "repodna_test_execution",\n'
        printf '  "started_at": "%s",\n  "test_execution": {\n' "$started_at"
        printf '    "status": "%s",\n    "total": %d,\n    "passed": %d,\n    "failed": %d,\n    "skipped": %d,\n    "duration_seconds": %d\n  },\n' "$status" "$total" "$passed" "$failed" "$skipped" "$duration"
        printf '  "tests": [\n'
        for index in "${!result_rows[@]}"; do
            IFS='|' read -r name test_status test_duration <<< "${result_rows[$index]}"
            printf '    {"name": "%s", "status": "%s", "duration_seconds": %d}' "$name" "$test_status" "$test_duration"
            [[ "$index" -eq $((total - 1)) ]] || printf ','
            printf '\n'
        done
        printf '  ]\n}\n'
    } > "$OUTPUT_FILE"
    printf '\nTest execution evidence: %s\n' "$OUTPUT_FILE"
fi

if [[ "$failed" -eq 0 ]]; then
    printf '\nAll %d RepoDNA tests passed in %d seconds.\n' "$total" "$duration"
else
    printf '\n%d of %d RepoDNA tests failed in %d seconds.\n' "$failed" "$total" "$duration" >&2
fi
[[ "$failed" -eq 0 ]] && exit 0
exit 1
