create_optional_charts() {
echo "[10/12] Creating optional charts..."

# Create charts only when detailed, non-strict commit data exists.
if ((GIT_HISTORY[total_commits] > 0)) && [[ "$PRIVACY_MODE" != strict ]]; then
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
            echo "Warning: Python 3.11+ was not found. Graph generation was skipped."
            echo "  Install Python and run: python -m pip install matplotlib"
        else
            echo "Warning: Matplotlib was not found. Graph generation was skipped."
            echo "  Install with: $STRUCTURED_PYTHON -m pip install matplotlib"
        fi
    fi
fi

# Print the eleventh progress step.
}

create_analysis_charts() {
    [[ "$PRIVACY_MODE" == strict ]] && return 0
    [[ -n "$STRUCTURED_PYTHON" && -f "$GENERIC_ANALYSIS_FILE" ]] || return 0
    "$STRUCTURED_PYTHON" -c 'import matplotlib' >/dev/null 2>&1 || return 0
    MPLBACKEND=Agg MPLCONFIGDIR="$OUTPUT_DIR/.matplotlib" \
        "$STRUCTURED_PYTHON" "$SCRIPT_DIR/src/reports/charts.py" \
        "$DATA_DIR/history_commits.csv" "$GRAPHS_DIR" \
        --analysis-json "$GENERIC_ANALYSIS_FILE" || true
    rm -rf "$OUTPUT_DIR/.matplotlib"
}
