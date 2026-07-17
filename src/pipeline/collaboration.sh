collect_collaboration() {
echo "[7/12] Exporting collaboration and repository history..."

if [[ "$PRIVACY_MODE" == strict ]]; then
    git shortlog -sn --all 2>/dev/null |
        awk '{ printf "Contributor-%d\t%s commits\n", NR, $1 }' \
        > "$PROJECT_DIR/26_all_contributors.txt"
    printf 'Branch count: %s\n' "$(git branch -a 2>/dev/null | wc -l | trim_count)" \
        > "$PROJECT_DIR/27_branches.txt"
    printf 'Tag count: %s\n' "$(git tag 2>/dev/null | wc -l | trim_count)" \
        > "$PROJECT_DIR/28_tags.txt"
    printf '%s\n' '[remote URLs omitted in strict privacy mode]' \
        > "$PROJECT_DIR/29_remotes.txt"
else
    git shortlog -sne --all > "$PROJECT_DIR/26_all_contributors.txt" 2>/dev/null || true
    git branch -a > "$PROJECT_DIR/27_branches.txt" 2>/dev/null || true
    git tag --sort=-creatordate > "$PROJECT_DIR/28_tags.txt" 2>/dev/null || true
    git remote -v > "$PROJECT_DIR/29_remotes.txt" 2>/dev/null || true
fi

# Export repository status without branch identity in strict mode.
if [[ "$PRIVACY_MODE" == strict ]]; then
    printf 'Changed working-tree entries: %s\n' \
        "$(git status --short 2>/dev/null | wc -l | trim_count)" \
        > "$PROJECT_DIR/30_repository_status.txt"
else
    git status --short --branch \
        > "$PROJECT_DIR/30_repository_status.txt" 2>/dev/null || true
fi

if [[ "$PRIVACY_MODE" == strict ]]; then
    printf 'Merge commits: %s\n' "${GIT_HISTORY[merge_commits]:-0}" \
        > "$PROJECT_DIR/31_merge_history.txt"
else
    git log --all \
        --merges \
        --date=short \
        --pretty=format:'%ad | %h | %an | %s' 2>/dev/null \
        > "$PROJECT_DIR/31_merge_history.txt" || true
fi

# Print the eighth progress step.
}
