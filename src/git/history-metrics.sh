#!/usr/bin/env bash

declare -gA GIT_HISTORY=()

git_history_reset() {
    GIT_HISTORY=(
        [total_commits]=0 [first_commit]='' [last_commit]=''
        [first_date]='' [last_date]='' [active_days]=0 [unique_files]=0
        [lines_added]=0 [lines_removed]=0 [net_lines]=0
        [merge_commits]=0 [non_merge_commits]=0
        [historical_cs_files]=0 [historical_unity_files]=0
        [historical_scenes]=0 [historical_prefabs]=0
        [historical_animations]=0 [historical_shaders]=0
        [historical_editor_cs]=0
    )
}

collect_git_history_metrics() {
    GIT_HISTORY[total_commits]="$(analysis_git_log --pretty=format:'%H' 2>/dev/null | awk 'NF { count++ } END { print count + 0 }')"
    ((GIT_HISTORY[total_commits] > 0)) || return 0

    GIT_HISTORY[first_commit]="$(analysis_git_log --reverse --date=short --pretty=format:'%ad | %h | %an <%ae> | %s' 2>/dev/null | head -n 1)"
    GIT_HISTORY[last_commit]="$(analysis_git_log --date=short --pretty=format:'%ad | %h | %an <%ae> | %s' 2>/dev/null | head -n 1)"
    if [[ "$PRIVACY_MODE" == strict ]]; then
        GIT_HISTORY[first_commit]='[commit content omitted in strict privacy mode]'
        GIT_HISTORY[last_commit]='[commit content omitted in strict privacy mode]'
    fi
    GIT_HISTORY[first_date]="$(analysis_git_log --reverse --date=short --pretty=format:'%ad' 2>/dev/null | head -n 1)"
    GIT_HISTORY[last_date]="$(analysis_git_log --date=short --pretty=format:'%ad' 2>/dev/null | head -n 1)"
    GIT_HISTORY[active_days]="$(analysis_git_log --date=short --pretty=format:'%ad' 2>/dev/null | sort -u | awk 'NF { count++ } END { print count + 0 }')"
    GIT_HISTORY[unique_files]="$(analysis_git_log --name-only --pretty=format: 2>/dev/null | awk 'NF' | sort -u | awk 'NF { count++ } END { print count + 0 }')"
    read -r GIT_HISTORY[lines_added] GIT_HISTORY[lines_removed] GIT_HISTORY[net_lines] <<EOF
$(analysis_git_log --pretty=tformat: --numstat 2>/dev/null | awk '$1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ { added += $1; removed += $2 } END { printf "%d %d %d\n", added + 0, removed + 0, added - removed }')
EOF
    GIT_HISTORY[merge_commits]="$(analysis_git_log --merges --pretty=format:'%H' 2>/dev/null | awk 'NF { count++ } END { print count + 0 }')"
    GIT_HISTORY[non_merge_commits]="$(analysis_git_log --no-merges --pretty=format:'%H' 2>/dev/null | awk 'NF { count++ } END { print count + 0 }')"
}
