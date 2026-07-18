#!/usr/bin/env bash

# Heuristic sensitive-data detection. Raw matched values never leave awk.

secret_path_is_ignored() {
    local path="$1" pattern
    local ignore_file="${REPO_ROOT:-.}/.repodna-ignore"
    [[ -f "$ignore_file" ]] || return 1
    while IFS= read -r pattern || [[ -n "$pattern" ]]; do
        pattern="${pattern%$'\r'}"; pattern="${pattern#"${pattern%%[![:space:]]*}"}"; pattern="${pattern%"${pattern##*[![:space:]]}"}"
        [[ -z "$pattern" || "$pattern" == \#* ]] && continue
        pattern="${pattern#./}"
        if [[ "$pattern" == */ && ( "$path" == "${pattern%/}" || "$path" == "${pattern%/}"/* ) ]]; then return 0; fi
        if [[ "$path" == $pattern ]]; then return 0; fi
    done < "$ignore_file"
    return 1
}

secret_finding_is_allowed() {
    local path="$1" line="$2" type="$3" rule rule_path rule_line rule_type
    local allowlist="${REPO_ROOT:-.}/.repodna-secrets-allowlist"
    [[ -f "$allowlist" ]] || return 1
    while IFS= read -r rule || [[ -n "$rule" ]]; do
        rule="${rule%$'\r'}"; [[ -z "$rule" || "$rule" == \#* ]] && continue
        IFS='|' read -r rule_path rule_line rule_type <<< "$rule"
        [[ -n "$rule_path" && -n "$rule_line" && -n "$rule_type" ]] || continue
        [[ "$rule_path" == '*' || "$path" == $rule_path ]] || continue
        [[ "$rule_line" == '*' || "$line" == "$rule_line" ]] || continue
        [[ "$rule_type" == '*' || "$type" == "$rule_type" ]] || continue
        return 0
    done < "$allowlist"
    return 1
}

scan_file_for_potential_secrets() {
    local source_file="$1"
    grep -Iq . "$source_file" 2>/dev/null || return 0
    awk -v source_file="$source_file" '
        function trim(value) { gsub(/^[[:space:]"\047]+|[[:space:]"\047,;]+$/, "", value); return value }
        function candidate(line, value, quote, end) {
            value=line; sub(/^.*[:=][[:space:]]*/, "", value); value=trim(value)
            quote=substr(value,1,1)
            if (quote == "\"" || quote == "\047") {
                value=substr(value,2); end=index(value,quote); if (end) value=substr(value,1,end-1)
            } else sub(/[[:space:],;].*$/, "", value)
            return trim(value)
        }
        function placeholder(value, lower) {
            lower=tolower(value)
            return value == "" || lower ~ /(^|[-_.])(example|sample|dummy|placeholder|changeme|replace.?me|redacted|your.?[a-z]*|not.?set|none|null)([-_.]|$)/ || lower ~ /^x{6,}$/ || lower ~ /^\$\{[^}]+\}$/ || lower ~ /^<[^>]+>$/
        }
        function preview(value, size) {
            value=trim(value); size=length(value)
            if (size < 12) return "[REDACTED]"
            return substr(value,1,3) "****" substr(value,size-3,4)
        }
        function finding(type, severity, value) {
            value=trim(value); if (placeholder(value)) return
            print NR "\t" type "\t" severity "\t" preview(value)
        }
        {
            original=$0; lower=tolower($0); value=candidate(original)
            if (original ~ /-----BEGIN (RSA |OPENSSH |EC |DSA |PGP )?PRIVATE KEY-----/) finding("private key","Critical","private-key-material")
            if (match(original, /(AKIA|ASIA)[A-Z0-9]{16}/)) finding("AWS credential","Critical",substr(original,RSTART,RLENGTH))
            else if (lower ~ /aws[_-]?secret[_-]?access[_-]?key[[:space:]]*[:=]/) finding("AWS credential","Critical",value)
            if (lower ~ /authorization[[:space:]]*[:=][[:space:]]*["\047]?bearer[[:space:]]+/ || lower ~ /bearer[[:space:]]+[a-z0-9._~+\/=-]{12,}/) { value=original; sub(/^.*[Bb][Ee][Aa][Rr][Ee][Rr][[:space:]]+/,"",value); sub(/[[:space:]"\047,;].*$/,"",value); finding("Bearer token","High",value) }
            if (lower ~ /(api[_-]?key|api[_-]?token|access[_-]?token|client[_-]?secret|_authtoken)["\047]?[[:space:]]*[:=][[:space:]]*["\047]?[[:alnum:]_.~+\/=-]{8,}/) finding("possible API token","High",value)
            if (lower ~ /(password|passwd|pwd)["\047]?[[:space:]]*[:=][[:space:]]*["\047]?[^[:space:]"\047]{6,}/) finding("password","High",value)
            if (lower ~ /(server|data source)[[:space:]]*=.*;(user id|uid|password|pwd)[[:space:]]*=/ || lower ~ /(mongodb(\+srv)?|postgres(ql)?|mysql|sqlserver|redis):\/\/[^[:space:]]+@/) finding("connection string","High",value)
            if (lower ~ /(firebaseio\.com|firebase[_-]?(api[_-]?key|private[_-]?key|database[_-]?url))/ || (source_file ~ /(^|\/)(google-services\.json|GoogleService-Info\.plist)$/ && lower ~ /(current_key|mobilesdk_app_id|project_id|database_url)/)) finding("Firebase configuration","Medium",value)
            if (lower ~ /https?:\/\/[^\/:[:space:]]+:[^@[:space:]]+@/) finding("Git remote credential","High",value)
            if (lower ~ /https?:\/\/[^[:space:]]*(hooks\.slack\.com|discord(app)?\.com\/api\/webhooks|webhook)[^[:space:]]*/) finding("webhook URL","High",value)
            if (lower ~ /(registry|index-url|extra-index-url|packagesource|npmregistryserver)[[:space:]]*[:=]/ && lower ~ /(https?:\/\/|_authtoken|username|password)/) finding("private package registry","Medium",value)
            if (lower ~ /([a-z0-9-]+\.)+(internal|corp|local|lan)([^a-z0-9-]|$)/ || lower ~ /(10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3})/) finding("internal domain or private network address","Low",value)
        }
    ' "$source_file"
}

write_potential_secrets_report() {
    local output_file="$1" findings_file source_file line_number finding_type severity preview count=0
    findings_file="$(mktemp)" || return 1
    while IFS= read -r -d '' source_file; do
        source_file="${source_file#./}"
        [[ "$source_file" == "$REPORT_NAME"/* || "$source_file" == *_project_analysis_????-??-??_??-??-??/* ]] && continue
        [[ "$source_file" == *.zip || "$source_file" == *.tar.gz ]] && continue
        secret_path_is_ignored "$source_file" && continue
        while IFS=$'\t' read -r line_number finding_type severity preview; do
            [[ -n "$line_number" && -n "$finding_type" ]] || continue
            secret_finding_is_allowed "$source_file" "$line_number" "$finding_type" && continue
            printf '%s\t%s\t%s\t%s\t%s\n' "$source_file" "$line_number" "$finding_type" "$severity" "$preview" >> "$findings_file"
        done < <(scan_file_for_potential_secrets "$source_file")
    done < <(analysis_find -type f -print0 2>/dev/null)
    if [[ -f .git/config ]]; then
        while IFS=$'\t' read -r line_number finding_type severity preview; do
            secret_finding_is_allowed '.git/config' "$line_number" "$finding_type" && continue
            printf '%s\t%s\t%s\t%s\t%s\n' '.git/config' "$line_number" "$finding_type" "$severity" "$preview" >> "$findings_file"
        done < <(scan_file_for_potential_secrets .git/config)
    fi
    sort -u "$findings_file" -o "$findings_file"
    {
        printf '%s\n' 'Potential secrets report' '========================'
        printf '%s\n\n' 'RepoDNA performs heuristic secret detection and is not a replacement for a dedicated security scanner.'
        printf '%s\n\n' 'Matched values are masked before leaving the scanner and are never included in full.'
        while IFS=$'\t' read -r source_file line_number finding_type severity preview; do
            [[ -n "$source_file" ]] || continue; count=$((count+1))
            printf 'Potential %s\nSeverity: %s\nFile: %s\nLine: %s\nPreview: %s\n\n' "$finding_type" "$severity" "$source_file" "$line_number" "$preview"
        done < "$findings_file"
        [[ "$count" -ne 0 ]] || printf '%s\n' 'No configured sensitive-data pattern was detected.'
    } > "$output_file"
    POTENTIAL_SECRET_COUNT="$count"
    rm -f "$findings_file"
}
