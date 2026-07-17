#!/usr/bin/env bash

trim_count() { tr -d '[:space:]'; }

json_escape() {
    printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g'
}

html_escape() {
    printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'
}

copy_preserving_path() {
    local source_file="$1" destination_root="$2"
    mkdir -p "$destination_root/$(dirname "$source_file")"
    cp "$source_file" "$destination_root/$source_file"
}

count_current_files() { count_files_matching "$1"; }

count_historical_files() {
    local pattern="$1" awk_pattern="${1//\\/\\\\}"
    analysis_git_log --name-only --pretty=format: 2>/dev/null |
        awk -v regex="$awk_pattern" '{ line = tolower($0); if (line ~ regex) print $0 }' |
        sort -u | wc -l | trim_count
}
