#!/usr/bin/env bash

# Detect potential sensitive data without emitting matched values.

scan_file_for_potential_secrets() {
    local source_file="$1"

    grep -Iq . "$source_file" 2>/dev/null || return 0

    awk -v source_file="$source_file" '
        function finding(type) {
            print NR "\t" type
        }

        {
            original = $0
            lower = tolower($0)

            if (original ~ /-----BEGIN (RSA |OPENSSH |EC |DSA |PGP )?PRIVATE KEY-----/) {
                finding("private key")
            }

            if (original ~ /(AKIA|ASIA)[A-Z0-9]{16}/ ||
                lower ~ /aws[_-]?secret[_-]?access[_-]?key[[:space:]]*[:=]/) {
                finding("AWS credential")
            }

            if (lower ~ /authorization[[:space:]]*[:=][[:space:]]*["\047]?bearer[[:space:]]+/ ||
                lower ~ /bearer[[:space:]]+[a-z0-9._~+\/=-]{12,}/) {
                finding("Bearer token")
            }

            if (lower ~ /(api[_-]?key|api[_-]?token|access[_-]?token|client[_-]?secret)["\047]?[[:space:]]*[:=][[:space:]]*["\047]?[[:alnum:]_.~+\/-]{8,}/) {
                finding("possible API token")
            }

            if (lower ~ /(password|passwd|pwd)["\047]?[[:space:]]*[:=][[:space:]]*["\047]?[^[:space:]"\047]{4,}/) {
                finding("password")
            }

            if (lower ~ /(server|data source)[[:space:]]*=.*;(user id|uid|password|pwd)[[:space:]]*=/ ||
                lower ~ /(mongodb(\+srv)?|postgres(ql)?|mysql|sqlserver|redis):\/\/[^[:space:]]+@/) {
                finding("connection string")
            }

            if (lower ~ /(firebaseio\.com|firebase[_-]?(api[_-]?key|private[_-]?key|database[_-]?url))/ ||
                (source_file ~ /(^|\/)(google-services\.json|GoogleService-Info\.plist)$/ &&
                 lower ~ /(current_key|mobilesdk_app_id|project_id|database_url)/)) {
                finding("Firebase configuration")
            }

            if (lower ~ /https?:\/\/[^\/:[:space:]]+:[^@[:space:]]+@/ ||
                lower ~ /git@[^[:space:]]+:[^[:space:]]+/) {
                finding("Git remote credential or private remote")
            }

            if (lower ~ /https?:\/\/[^[:space:]]*(hooks\.slack\.com|discord(app)?\.com\/api\/webhooks|webhook)[^[:space:]]*/) {
                finding("webhook URL")
            }

            if (lower ~ /(registry|index-url|extra-index-url|packageSource|npmregistryserver)[[:space:]]*[:=]/ &&
                lower ~ /(https?:\/\/|_authtoken|username|password)/) {
                finding("private package registry")
            }

            if (lower ~ /([a-z0-9-]+\.)+(internal|corp|local|lan)([^a-z0-9-]|$)/ ||
                lower ~ /(10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3})/) {
                finding("internal domain or private network address")
            }
        }
    ' "$source_file"
}

write_potential_secrets_report() {
    local output_file="$1"
    local findings_file
    local source_file
    local line_number
    local finding_type
    local count=0

    findings_file="$(mktemp)" || return 1

    while IFS= read -r -d '' source_file; do
        source_file="${source_file#./}"

        [[ "$source_file" == "$REPORT_NAME"/* ]] && continue
        [[ "$source_file" == *_project_analysis_????-??-??_??-??-??/* ]] && continue
        [[ "$source_file" == *.zip || "$source_file" == *.tar.gz ]] && continue

        while IFS=$'\t' read -r line_number finding_type; do
            [[ -n "$line_number" && -n "$finding_type" ]] || continue
            printf '%s\t%s\t%s\n' "$source_file" "$line_number" "$finding_type" \
                >> "$findings_file"
        done < <(scan_file_for_potential_secrets "$source_file")
    done < <(analysis_find -type f -print0 2>/dev/null)

    if [[ -f .git/config ]]; then
        while IFS=$'\t' read -r line_number finding_type; do
            [[ -n "$line_number" && -n "$finding_type" ]] || continue
            printf '%s\t%s\t%s\n' '.git/config' "$line_number" "$finding_type" \
                >> "$findings_file"
        done < <(scan_file_for_potential_secrets .git/config)
    fi

    sort -u "$findings_file" -o "$findings_file"

    {
        printf '%s\n' 'Potential secrets report'
        printf '%s\n' '========================'
        printf '%s\n\n' 'Matched values are never included in this report.'

        while IFS=$'\t' read -r source_file line_number finding_type; do
            [[ -n "$source_file" ]] || continue
            count=$((count + 1))
            printf '%s\n' 'Potential secret found:'
            printf '%s:%s\n' "$source_file" "$line_number"
            printf 'Type: %s\n' "$finding_type"
            printf '%s\n\n' 'Value: [REDACTED]'
        done < "$findings_file"

        if [[ "$count" -eq 0 ]]; then
            printf '%s\n' 'No configured sensitive-data pattern was detected.'
        fi
    } > "$output_file"

    POTENTIAL_SECRET_COUNT="$count"
    rm -f "$findings_file"
}
