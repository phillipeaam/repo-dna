#!/usr/bin/env bash

write_no_matching_commits_report() {
    cat > "$CONTRIBUTION_DIR/00_no_matching_commits.txt" <<EOF
No commits matched the selected history scope: $HISTORY_SCOPE

Inspect available authors with:
git shortlog -sne --all

The project-wide analysis was still generated successfully.
EOF
}

write_git_history_summary() {
    local specialized=''
    if [[ "$PROJECT_TYPE" == Unity || "$PROJECT_TYPE" == .NET ]]; then
        specialized="Historical C# paths changed: ${GIT_HISTORY[historical_cs_files]}"
    fi
    if [[ "$PROJECT_TYPE" == Unity ]]; then
        specialized="$specialized
Historical Unity-related paths changed: ${GIT_HISTORY[historical_unity_files]}
Historical scenes changed: ${GIT_HISTORY[historical_scenes]}
Historical prefabs changed: ${GIT_HISTORY[historical_prefabs]}
Historical animation-related files changed: ${GIT_HISTORY[historical_animations]}
Historical shader-related files changed: ${GIT_HISTORY[historical_shaders]}
Historical Editor C# files changed: ${GIT_HISTORY[historical_editor_cs]}"
    fi
    cat > "$CONTRIBUTION_DIR/00_contribution_summary.txt" <<EOF
Git History Summary
===================

History scope: $HISTORY_SCOPE
Author filter: $DISPLAY_AUTHOR
Since: ${SINCE:-Not specified}
Until: ${UNTIL:-Not specified}

First matching commit:
${GIT_HISTORY[first_commit]}

Last matching commit:
${GIT_HISTORY[last_commit]}

First commit date: ${GIT_HISTORY[first_date]:-N/A}
Last commit date: ${GIT_HISTORY[last_date]:-N/A}
Active commit days: ${GIT_HISTORY[active_days]}

Total commits: ${GIT_HISTORY[total_commits]}
Non-merge commits: ${GIT_HISTORY[non_merge_commits]}
Merge commits: ${GIT_HISTORY[merge_commits]}

Lines added: ${GIT_HISTORY[lines_added]}
Lines removed: ${GIT_HISTORY[lines_removed]}
Net line change: ${GIT_HISTORY[net_lines]}
Unique historical paths changed: ${GIT_HISTORY[unique_files]}
$specialized

Git statistics measure historical change volume, not exclusive ownership.
Rename and copy detection is enabled, but imported packages and merges may still inflate values.
EOF
}

export_git_history_details() {
    local system_keywords
    system_keywords="$(system_keywords_pattern)"

    if [[ "$PRIVACY_MODE" != strict ]]; then
        analysis_git_log --date=iso-strict --pretty=format:'%ad | %h | %an <%ae> | %s' 2>/dev/null > "$CONTRIBUTION_DIR/01_commits.txt"
        {
            echo 'Date,Hash,FullHash,AuthorName,AuthorEmail,Subject'
            analysis_git_log --date=short --pretty=format:'%ad%x09%h%x09%H%x09%an%x09%ae%x09%s' 2>/dev/null |
                awk -F '\t' 'function csv(value) { gsub(/"/, "\"\"", value); return "\"" value "\"" } { print csv($1) "," csv($2) "," csv($3) "," csv($4) "," csv($5) "," csv($6) }'
        } > "$DATA_DIR/history_commits.csv"
    fi
    analysis_git_log --date=format:'%Y' --pretty=format:'%ad' 2>/dev/null | sort | uniq -c | awk '{ print $2 "\t" $1 }' > "$CONTRIBUTION_DIR/02_commits_by_year.txt"
    analysis_git_log --date=format:'%Y-%m' --pretty=format:'%ad' 2>/dev/null | sort | uniq -c | awk '{ print $2 "\t" $1 }' > "$CONTRIBUTION_DIR/03_commits_by_month.txt"
    analysis_git_log --name-only --pretty=format: 2>/dev/null | awk 'NF' | sort | uniq -c | sort -nr > "$CONTRIBUTION_DIR/04_top_changed_files.txt"
    analysis_git_log --name-only --pretty=format: 2>/dev/null | awk 'NF { count = split($0, parts, "/"); if (count >= 3) print parts[1] "/" parts[2] "/" parts[3]; else if (count >= 2) print parts[1] "/" parts[2]; else print parts[1] }' | sort | uniq -c | sort -nr > "$CONTRIBUTION_DIR/05_top_changed_directories.txt"
    analysis_git_log --name-only --pretty=format: 2>/dev/null | awk 'NF { count = split($0, parts, "."); if (count > 1) print "." tolower(parts[count]); else print "[no_extension]" }' | sort | uniq -c | sort -nr > "$CONTRIBUTION_DIR/06_changed_file_extensions.txt"
    if [[ "$PRIVACY_MODE" != strict ]]; then
        analysis_git_log --pretty=format:'%s' 2>/dev/null | grep -Ei "$system_keywords" | sort > "$CONTRIBUTION_DIR/07_system_related_commit_subjects.txt" || true
    fi
}
