run_security_and_archive() {
echo "[11/12] Scanning privacy and creating the archive..."

PRIVACY_SCAN_FAILED=false
sanitize_strict_reports
POTENTIAL_SECRET_COUNT=0
write_potential_secrets_report "$SECURITY_DIR/potential_secrets.txt" ||
    die "Could not create the potential secrets report."

GENERIC_ANALYSIS_FILE="$REPORT_DATA_DIR/generic-analysis.json"
if [[ -n "$STRUCTURED_PYTHON" ]]; then
    GENERIC_COLLECTOR_ARGS=(--report-name "$REPORT_NAME" --privacy-mode "$PRIVACY_MODE")
    [[ -z "$AUTHOR" ]] || GENERIC_COLLECTOR_ARGS+=(--author "$AUTHOR")
    "$STRUCTURED_PYTHON" "$SCRIPT_DIR/collectors/generic.py" \
        "$REPO_ROOT" "$GENERIC_ANALYSIS_FILE" "${GENERIC_COLLECTOR_ARGS[@]}" ||
        die "Could not collect the generic repository analysis."
else
    printf '%s\n' '{"schema_version":"1.0","collector":"generic","available":false,"reason":"Python runtime unavailable"}' \
        > "$GENERIC_ANALYSIS_FILE"
fi

write_structured_report_json "$REPORT_DATA_DIR/report.json" ||
    die "Could not create the canonical report JSON."

"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/html.py" \
    "$REPORT_DATA_DIR/report.json" "$REPORT_DIR/index.html" ||
    die "Could not render the standardized HTML reports."
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/notion.py" \
    "$REPORT_DATA_DIR/report.json" "$NOTION_DIR/evidence.json" ||
    die "Could not render the Notion evidence JSON."

PORTFOLIO_ARGS=()
[[ -z "$PORTFOLIO_PROFILE" ]] || PORTFOLIO_ARGS+=(--confirmations "$PORTFOLIO_PROFILE")
"$STRUCTURED_PYTHON" "$SCRIPT_DIR/renderers/portfolio.py" \
    "$REPORT_DATA_DIR/report.json" "$PORTFOLIO_DIR/draft.json" "$PORTFOLIO_DIR/index.html" \
    "${PORTFOLIO_ARGS[@]}" ||
    die "Could not render the portfolio evidence draft."

run_privacy_scan
create_report_archive
print_completion_summary
}
