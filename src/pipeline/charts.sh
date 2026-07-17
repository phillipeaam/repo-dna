create_optional_charts() {
echo "[10/12] Creating optional charts..."

# Create charts only when detailed, non-strict commit data exists.
if [[ "$TOTAL_COMMITS" -gt 0 && "$PRIVACY_MODE" != strict ]]; then
    # Run the chart generator when dependencies exist.
    if [[ -n "$STRUCTURED_PYTHON" ]] &&
       "$STRUCTURED_PYTHON" -c 'import matplotlib' >/dev/null 2>&1; then
        # Generate charts without failing the complete report.
        MPLBACKEND=Agg MPLCONFIGDIR="$OUTPUT_DIR/.matplotlib" \
            "$STRUCTURED_PYTHON" "$SCRIPT_DIR/src/reports/charts.py" \
            "$DATA_DIR/history_commits.csv" "$GRAPHS_DIR" || true
        rm -rf "$OUTPUT_DIR/.matplotlib"
    else
        # Explain why charts were skipped.
        if [[ -z "$STRUCTURED_PYTHON" ]]; then
            echo "Optional charts skipped because no executable Python runtime was found."
        else
            echo "Optional charts skipped because matplotlib is unavailable."
        fi
    fi
fi

# Print the eleventh progress step.
}
