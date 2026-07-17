collect_git_history() {
    echo "[6/12] Calculating Git history and contribution metrics..."
    git_history_reset
    collect_git_history_metrics
    if ((GIT_HISTORY[total_commits] == 0)); then
        write_no_matching_commits_report
        return 0
    fi
    collect_specialized_git_metrics
    write_git_history_summary
    export_git_history_details
}
