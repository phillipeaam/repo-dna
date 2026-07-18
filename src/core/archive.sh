#!/usr/bin/env bash

create_report_archive() {
    if [[ "$PRIVACY_SCAN_FAILED" == true ]]; then
        echo "Warning: archive creation blocked by the privacy scan."
        echo "Review summary/03_privacy_scan.txt before compressing the report."
        return 0
    fi
    rm -f "$ZIP_PATH"
    if command_exists zip; then
        (cd "$(dirname "$OUTPUT_DIR")" && zip -qr "$ZIP_PATH" "$(basename "$OUTPUT_DIR")") ||
            echo "Warning: zip could not create the archive."
    elif command_exists powershell.exe && command_exists cygpath; then
        local windows_output windows_zip
        windows_output="$(cygpath -aw "$OUTPUT_DIR")"
        windows_zip="$(cygpath -aw "$ZIP_PATH")"
        powershell.exe -NoProfile -Command \
            "Compress-Archive -LiteralPath '$windows_output' -DestinationPath '$windows_zip' -Force" \
            >/dev/null 2>&1 || echo "Warning: PowerShell could not create the archive."
    elif command_exists tar; then
        TAR_PATH="$(dirname "$OUTPUT_DIR")/${REPORT_NAME}.tar.gz"
        (cd "$(dirname "$OUTPUT_DIR")" && tar -czf "$TAR_PATH" "$(basename "$OUTPUT_DIR")") ||
            echo "Warning: tar could not create the archive."
    else
        echo "No supported archive command was found."
        echo "The report folder was generated and can be compressed manually."
    fi
}

print_completion_summary() {
    echo "Potential secret findings: $POTENTIAL_SECRET_COUNT"
    echo "[12/12] Finalizing..."
    echo ""
    echo "================================================================"
    echo "Analysis export completed"
    echo "================================================================"
    echo "Duration   : $(format_duration "$((SECONDS - EXECUTION_STARTED_AT))")"
    echo "================================================================"
    printf 'Report folder:\n  %s\n\n' "$DISPLAY_OUTPUT_PATH"
    [[ ! -f "$ZIP_PATH" ]] || printf 'ZIP archive:\n  %s\n\n' "$DISPLAY_ZIP_PATH"
    if [[ -n "${TAR_PATH:-}" && -f "${TAR_PATH:-}" ]]; then
        local display_tar_path="$TAR_PATH"
        [[ "$PRIVACY_MODE" != strict ]] || display_tar_path="${TAR_PATH##*/}"
        printf 'TAR.GZ archive:\n  %s\n\n' "$display_tar_path"
    fi
    echo "Start here:"
    if [[ "$PRIVACY_MODE" == strict ]]; then
        echo "  $REPORT_NAME/report/index.html"
    else
        echo "  $REPORT_DIR/index.html"
    fi
    if [[ "${PARTIAL_ANALYSIS:-false}" == true ]]; then
        printf '\nStatus: partial analysis (recommended Python reporting runtime unavailable).\n'
        echo "================================================================"
        return 0
    fi
    printf '\nNotion guide:\n  %s/01_notion_evidence_guide.md\n' "$DISPLAY_SUMMARY_PATH"
    printf '\nPortfolio draft:\n  %s/portfolio/index.html\n' "$DISPLAY_OUTPUT_PATH"
    printf '\nAnalysis snapshot:\n  %s/snapshots/%s\n' "$DISPLAY_OUTPUT_PATH" "$SNAPSHOT_NAME"
    printf '\nPeriod comparison:\n  %s/comparison/index.html\n' "$DISPLAY_OUTPUT_PATH"
    printf '\nHealth score trends:\n  %s/health-trends/index.html\n' "$DISPLAY_OUTPUT_PATH"
    printf '\nSystem documentation:\n  %s/system-docs/index.html\n' "$DISPLAY_OUTPUT_PATH"
    printf '\nDeveloper onboarding:\n  %s/onboarding/index.html\n' "$DISPLAY_OUTPUT_PATH"
    printf '\nSoftware bill of materials:\n  %s/sbom/index.html\n' "$DISPLAY_OUTPUT_PATH"
    if [[ "$PROJECT_TYPE" == Android ]]; then
        printf '\nAndroid analysis:\n  %s/android/index.html\n' "$DISPLAY_OUTPUT_PATH"
    fi
    if [[ "$PROJECT_TYPE" == Flutter ]]; then
        printf '\nFlutter analysis:\n  %s/flutter/index.html\n' "$DISPLAY_OUTPUT_PATH"
    fi
    if [[ "$PROJECT_TYPE" == Godot ]]; then
        printf '\nGodot analysis:\n  %s/godot/index.html\n' "$DISPLAY_OUTPUT_PATH"
    fi
    if [[ "$PROJECT_TYPE" == Unreal ]]; then
        printf '\nUnreal analysis:\n  %s/unreal/index.html\n' "$DISPLAY_OUTPUT_PATH"
    fi
    if [[ "$SAVE_SNAPSHOT" == true ]]; then
        printf '\nPersisted snapshot:\n  %s/.repodna/snapshots/%s\n' "$REPO_ROOT" "$SNAPSHOT_NAME"
    fi
    printf '\nAnalysis prompt:\n  %s/02_analysis_prompt.md\n\n' "$DISPLAY_SUMMARY_PATH"
    echo "Review confidential code, e-mails, URLs, credentials, and client names"
    echo "before sharing the generated package."
    echo "================================================================"
}
