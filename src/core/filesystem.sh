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

# Signal inventories need provenance, not source content. This both reduces
# report size and prevents matched credentials from being copied to reports.
redact_signal_content() {
    sed -E 's/^([^:]+:[0-9]+):.*/\1/'
}

count_historical_files() {
    local pattern="$1" awk_pattern="${1//\\/\\\\}"
    historical_paths |
        awk -v regex="$awk_pattern" '{ line = tolower($0); if (line ~ regex) print $0 }' |
        wc -l | trim_count
}

historical_paths() {
    if [[ -n "${GIT_CHANGED_PATHS_CACHE:-}" && -f "$GIT_CHANGED_PATHS_CACHE" ]]; then
        sort -u "$GIT_CHANGED_PATHS_CACHE"
    else
        analysis_git_log --name-only --pretty=format: 2>/dev/null | awk 'NF' | sort -u
    fi
}

historical_path_changes() {
    if [[ -n "${GIT_CHANGED_PATHS_CACHE:-}" && -f "$GIT_CHANGED_PATHS_CACHE" ]]; then
        cat "$GIT_CHANGED_PATHS_CACHE"
    else
        analysis_git_log --name-only --pretty=format: 2>/dev/null | awk 'NF'
    fi
}

historical_commits() {
    if [[ -n "${GIT_COMMIT_METADATA_CACHE:-}" && -f "$GIT_COMMIT_METADATA_CACHE" ]]; then
        cat "$GIT_COMMIT_METADATA_CACHE"
    else
        analysis_git_log --date=iso-strict \
            --pretty=format:'%ad%x09%h%x09%H%x09%an%x09%ae%x09%s%x09%P' 2>/dev/null
    fi
}
