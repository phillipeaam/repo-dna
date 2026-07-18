run_security_and_archive() {
log_info "Scanning privacy and creating the archive"

PRIVACY_SCAN_FAILED=false
sanitize_strict_reports
POTENTIAL_SECRET_COUNT=0
write_potential_secrets_report "$SECURITY_DIR/potential_secrets.txt" ||
    die "Could not create the potential secrets report."
log_debug "$POTENTIAL_SECRET_COUNT potential secret findings require review."

if [[ -z "$STRUCTURED_PYTHON" ]]; then
    write_basic_partial_report || die "Could not create the dependency-free partial report."
    run_privacy_scan
    create_report_archive
    print_completion_summary
    return 0
fi

GENERIC_ANALYSIS_FILE="$OUTPUT_DIR/.generic-analysis.json"
if [[ -n "$STRUCTURED_PYTHON" ]]; then
    GENERIC_COLLECTOR_ARGS=(--report-name "$REPORT_NAME" --privacy-mode "$PRIVACY_MODE")
    [[ -z "$AUTHOR" ]] || GENERIC_COLLECTOR_ARGS+=(--author "$AUTHOR")
    [[ "$NO_HISTORY" == false ]] || GENERIC_COLLECTOR_ARGS+=(--no-history)
    [[ -z "$FORGE_DATA" ]] || GENERIC_COLLECTOR_ARGS+=(--forge-data "$FORGE_DATA")
    "$STRUCTURED_PYTHON" "$SCRIPT_DIR/collectors/generic.py" \
        "$REPO_ROOT" "$GENERIC_ANALYSIS_FILE" "${GENERIC_COLLECTOR_ARGS[@]}" ||
        die "Could not collect the generic repository analysis."
    "$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/validate_json.py" \
        "$GENERIC_ANALYSIS_FILE" "$SCRIPT_DIR/schemas/generic-analysis-1.2.0.schema.json" ||
        die "Generic analysis JSON violates its schema."
else
    printf '%s\n' '{"schema_version":"1.0","collector":"generic","available":false,"reason":"Python runtime unavailable"}' \
        > "$GENERIC_ANALYSIS_FILE"
fi

[[ "$NO_GRAPHS" == true ]] || create_analysis_charts

write_structured_report_json "$REPORT_DATA_DIR/report.json" ||
    die "Could not create the canonical report JSON."
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/canonical_model.py" \
    "$REPORT_DATA_DIR/report.json" || die "Could not finalize the canonical analysis model."
rm -f "$GENERIC_ANALYSIS_FILE"
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/validate_json.py" \
    "$REPORT_DATA_DIR/report.json" "$SCRIPT_DIR/schemas/report-1.3.0.schema.json" ||
    die "Canonical report JSON violates its schema."
cp "$SCRIPT_DIR/schemas/report-1.3.0.schema.json" "$REPORT_DATA_DIR/report-1.3.0.schema.json" ||
    die "Could not package the canonical report schema."
cp "$SCRIPT_DIR/schemas/generic-analysis-1.2.0.schema.json" "$REPORT_DATA_DIR/generic-analysis-1.2.0.schema.json" ||
    die "Could not package the generic analysis schema."
cp "$SCRIPT_DIR/schemas/generic-analysis-core-1.0.0.schema.json" "$REPORT_DATA_DIR/generic-analysis-core-1.0.0.schema.json" ||
    die "Could not package the canonical generic-analysis schema."
cp "$SCRIPT_DIR/schemas/forge-data-1.0.0.schema.json" "$REPORT_DATA_DIR/forge-data-1.0.0.schema.json" ||
    die "Could not package the provider-neutral forge-data schema."

"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/sbom.py" \
    "$REPORT_DATA_DIR/report.json" "$SBOM_DIR" ||
    die "Could not render the lockfile-derived CycloneDX SBOM."

if [[ "$PROJECT_TYPE" == Android ]]; then
    "$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/android_reports.py" \
        "$REPORT_DATA_DIR/report.json" "$ANDROID_DIR" \
        --schema "$SCRIPT_DIR/schemas/android-analysis-1.0.0.schema.json" ||
        die "Could not render Android reports."
    cp "$SCRIPT_DIR/schemas/android-analysis-1.0.0.schema.json" \
        "$ANDROID_DIR/android-analysis-1.0.0.schema.json" ||
        die "Could not copy the Android analysis schema."
fi
if [[ "$PROJECT_TYPE" == Flutter ]]; then
    "$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/flutter_reports.py" \
        "$REPORT_DATA_DIR/report.json" "$FLUTTER_DIR" \
        --schema "$SCRIPT_DIR/schemas/flutter-analysis-1.0.0.schema.json" ||
        die "Could not render Flutter reports."
    cp "$SCRIPT_DIR/schemas/flutter-analysis-1.0.0.schema.json" \
        "$FLUTTER_DIR/flutter-analysis-1.0.0.schema.json" ||
        die "Could not copy the Flutter analysis schema."
fi
if [[ "$PROJECT_TYPE" == Godot ]]; then
    "$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/godot_reports.py" \
        "$REPORT_DATA_DIR/report.json" "$GODOT_DIR" \
        --schema "$SCRIPT_DIR/schemas/godot-analysis-1.0.0.schema.json" ||
        die "Could not render Godot reports."
    cp "$SCRIPT_DIR/schemas/godot-analysis-1.0.0.schema.json" \
        "$GODOT_DIR/godot-analysis-1.0.0.schema.json" ||
        die "Could not copy the Godot analysis schema."
fi
if [[ "$PROJECT_TYPE" == Unreal ]]; then
    "$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/unreal_reports.py" \
        "$REPORT_DATA_DIR/report.json" "$UNREAL_DIR" \
        --schema "$SCRIPT_DIR/schemas/unreal-analysis-1.0.0.schema.json" ||
        die "Could not render Unreal reports."
    cp "$SCRIPT_DIR/schemas/unreal-analysis-1.0.0.schema.json" \
        "$UNREAL_DIR/unreal-analysis-1.0.0.schema.json" ||
        die "Could not copy the Unreal analysis schema."
fi

SNAPSHOT_BRANCH="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
[[ "$PRIVACY_MODE" != strict ]] || SNAPSHOT_BRANCH='[redacted]'
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/snapshot.py" \
    "$REPORT_DATA_DIR/report.json" "$SNAPSHOT_FILE" \
    --schema "$SCRIPT_DIR/schemas/analysis-snapshot-1.0.0.schema.json" \
    --commit "$SNAPSHOT_COMMIT" --branch "$SNAPSHOT_BRANCH" ||
    die "Could not create the versioned analysis snapshot."
cp "$SCRIPT_DIR/schemas/analysis-snapshot-1.0.0.schema.json" \
    "$SNAPSHOT_DIR/analysis-snapshot-1.0.0.schema.json" ||
    die "Could not copy the analysis snapshot schema."

COMPARISON_BASELINE="$COMPARE_WITH"
if [[ -z "$COMPARISON_BASELINE" && -d "$PERSISTENT_SNAPSHOT_DIR" ]]; then
    COMPARISON_BASELINE="$(find "$PERSISTENT_SNAPSHOT_DIR" -maxdepth 1 -type f -name '*.json' \
        ! -name 'analysis-snapshot-*.schema.json' -print 2>/dev/null | sort | tail -n 1)"
fi
COMPARISON_ARGS=()
[[ -z "$COMPARISON_BASELINE" ]] || COMPARISON_ARGS+=(--baseline "$COMPARISON_BASELINE")
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/snapshot_compare.py" \
    "$SNAPSHOT_FILE" "$COMPARISON_DIR/comparison.json" "$COMPARISON_DIR/index.html" \
    --schema "$SCRIPT_DIR/schemas/analysis-comparison-1.0.0.schema.json" \
    "${COMPARISON_ARGS[@]}" || die "Could not compare analysis periods."
cp "$SCRIPT_DIR/schemas/analysis-comparison-1.0.0.schema.json" \
    "$COMPARISON_DIR/analysis-comparison-1.0.0.schema.json" ||
    die "Could not copy the period-comparison schema."

HEALTH_TREND_ARGS=(--history-dir "$PERSISTENT_SNAPSHOT_DIR")
if [[ "$PRIVACY_MODE" != strict ]] && "$STRUCTURED_PYTHON" -c 'import matplotlib' >/dev/null 2>&1; then
    HEALTH_TREND_ARGS+=(--chart "$HEALTH_TRENDS_DIR/health-score-trend.png")
fi
MPLBACKEND=Agg MPLCONFIGDIR="$OUTPUT_DIR/.matplotlib" \
    "$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/health_trends.py" \
    "$SNAPSHOT_FILE" "$HEALTH_TRENDS_DIR/trends.json" "$HEALTH_TRENDS_DIR/index.html" \
    --schema "$SCRIPT_DIR/schemas/health-trends-1.0.0.schema.json" \
    "${HEALTH_TREND_ARGS[@]}" || die "Could not build health-score trends."
rm -rf "$OUTPUT_DIR/.matplotlib"
cp "$SCRIPT_DIR/schemas/health-trends-1.0.0.schema.json" \
    "$HEALTH_TRENDS_DIR/health-trends-1.0.0.schema.json" ||
    die "Could not copy the health-trends schema."

"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/system_documentation.py" \
    "$REPORT_DATA_DIR/report.json" "$SYSTEM_DOCUMENTATION_DIR" \
    --schema "$SCRIPT_DIR/schemas/system-documentation-1.0.0.schema.json" ||
    die "Could not render structured system documentation."
cp "$SCRIPT_DIR/schemas/system-documentation-1.0.0.schema.json" \
    "$SYSTEM_DOCUMENTATION_DIR/system-documentation-1.0.0.schema.json" ||
    die "Could not copy the system-documentation schema."

"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/onboarding.py" \
    "$REPORT_DATA_DIR/report.json" "$ONBOARDING_DIR" \
    --schema "$SCRIPT_DIR/schemas/onboarding-dataset-1.0.0.schema.json" ||
    die "Could not render the onboarding dataset."
cp "$SCRIPT_DIR/schemas/onboarding-dataset-1.0.0.schema.json" \
    "$ONBOARDING_DIR/onboarding-dataset-1.0.0.schema.json" ||
    die "Could not copy the onboarding schema."

"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/html.py" \
    "$REPORT_DATA_DIR/report.json" "$REPORT_DIR/index.html" ||
    die "Could not render the standardized HTML reports."
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/notion.py" \
    "$REPORT_DATA_DIR/report.json" "$NOTION_DIR/evidence.json" ||
    die "Could not render the Notion evidence JSON."
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/validate_json.py" \
    "$NOTION_DIR/evidence.json" "$SCRIPT_DIR/schemas/notion-evidence-1.0.0.schema.json" ||
    die "Notion evidence JSON violates its schema."
cp "$SCRIPT_DIR/schemas/notion-evidence-1.0.0.schema.json" "$NOTION_DIR/notion-evidence-1.0.0.schema.json" ||
    die "Could not package the Notion evidence schema."
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/llm_evidence.py" \
    "$REPORT_DATA_DIR/report.json" "$LLM_DIR/evidence.json" \
    --schema "$SCRIPT_DIR/schemas/llm-evidence-1.0.0.schema.json" ||
    die "Could not render the LLM evidence JSON."
cp "$SCRIPT_DIR/schemas/llm-evidence-1.0.0.schema.json" "$LLM_DIR/schema.json" ||
    die "Could not copy the versioned LLM evidence schema."

PORTFOLIO_ARGS=()
[[ -z "$PORTFOLIO_PROFILE" ]] || PORTFOLIO_ARGS+=(--confirmations "$PORTFOLIO_PROFILE")
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/portfolio.py" \
    "$REPORT_DATA_DIR/report.json" "$PORTFOLIO_DIR/draft.json" "$PORTFOLIO_DIR/index.html" \
    "${PORTFOLIO_ARGS[@]}" ||
    die "Could not render the portfolio evidence draft."
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/validate_json.py" \
    "$PORTFOLIO_DIR/draft.json" "$SCRIPT_DIR/schemas/portfolio-draft-1.0.0.schema.json" ||
    die "Portfolio draft JSON violates its schema."
cp "$SCRIPT_DIR/schemas/portfolio-draft-1.0.0.schema.json" "$PORTFOLIO_DIR/portfolio-draft-1.0.0.schema.json" ||
    die "Could not package the portfolio draft schema."

run_privacy_scan
if [[ "$SAVE_SNAPSHOT" == true ]]; then
    mkdir -p "$PERSISTENT_SNAPSHOT_DIR" ||
        die "Could not create the persistent snapshot directory."
    cp "$SNAPSHOT_FILE" "$PERSISTENT_SNAPSHOT_DIR/$SNAPSHOT_NAME" ||
        die "Could not persist the versioned analysis snapshot."
    cp "$SCRIPT_DIR/schemas/analysis-snapshot-1.0.0.schema.json" \
        "$PERSISTENT_SNAPSHOT_DIR/analysis-snapshot-1.0.0.schema.json" ||
        die "Could not persist the analysis snapshot schema."
fi
create_report_archive
print_completion_summary
}
