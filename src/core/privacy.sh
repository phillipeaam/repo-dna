#!/usr/bin/env bash

run_privacy_scan() {
    local findings_file secret_regex
    findings_file="$(mktemp)" || die "Could not create the privacy scan workspace."
    secret_regex='-----BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY-----|AKIA[0-9A-Z]{16}|(api[_-]?key|client[_-]?secret|access[_-]?token|password)[[:space:]]*[:=][[:space:]]*[^[:space:]]{8,}'
    grep -RIlE -- "$secret_regex" "$OUTPUT_DIR" 2>/dev/null > "$findings_file" || true
    if [[ "$PRIVACY_MODE" == strict ]]; then
        grep -RIlE -- '([[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}|https?://|ssh://|git@[^[:space:]]+:)' "$OUTPUT_DIR" 2>/dev/null >> "$findings_file" || true
        grep -RIlF -- "$REPO_ROOT" "$OUTPUT_DIR" 2>/dev/null >> "$findings_file" || true
    fi
    sort -u "$findings_file" -o "$findings_file"
    {
        printf '%s\n' 'Privacy scan' '------------'
        printf 'Mode: %s\n' "$PRIVACY_MODE"
        if [[ -s "$findings_file" ]]; then
            PRIVACY_SCAN_FAILED=true
            printf '%s\n' 'Result: blocked' 'Potential sensitive content was found in:'
            sed "s|^$OUTPUT_DIR/||" "$findings_file"
        else
            PRIVACY_SCAN_FAILED=false
            printf '%s\n' 'Result: passed' 'No configured sensitive-content pattern was detected.'
        fi
    } > "$SUMMARY_DIR/03_privacy_scan.txt"
    rm -f "$findings_file"
}

sanitize_strict_reports() {
    local report_file
    [[ "$PRIVACY_MODE" == strict ]] || return 0
    for report_file in "$PROJECT_DIR"/{13,14,15,16,17,18,19,20,21,22,23}_*.txt; do
        [[ -f "$report_file" ]] || continue
        sed -Ei 's/^([^:]+:[0-9]+):.*/\1:[content omitted]/' "$report_file"
    done
}
