#!/usr/bin/env bash

collect_git_history() {
    log_info "Collecting Git history and contribution metrics"
    git_history_reset
    GIT_CHANGED_PATHS_CACHE="$OUTPUT_DIR/.git-changed-paths.cache"
    GIT_COMMIT_METADATA_CACHE="$OUTPUT_DIR/.git-commit-metadata.cache"
    analysis_git_log --name-only --pretty=format: 2>/dev/null | awk 'NF' > "$GIT_CHANGED_PATHS_CACHE"
    analysis_git_log --date=iso-strict \
        --pretty=format:'%ad%x09%h%x09%H%x09%an%x09%ae%x09%s%x09%P' 2>/dev/null \
        > "$GIT_COMMIT_METADATA_CACHE"
    collect_git_history_metrics
    if ((GIT_HISTORY[total_commits] == 0)); then
        write_no_matching_commits_report
        rm -f "$GIT_CHANGED_PATHS_CACHE" "$GIT_COMMIT_METADATA_CACHE"
        return 0
    fi
    collect_specialized_git_metrics
    write_git_history_summary
    export_git_history_details
    rm -f "$GIT_CHANGED_PATHS_CACHE" "$GIT_COMMIT_METADATA_CACHE"
}
