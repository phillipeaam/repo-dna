collect_git_history() {
echo "[6/12] Calculating Git history and contribution metrics..."

# Count commits in the selected history scope.
TOTAL_COMMITS="$(
    analysis_git_log --pretty=format:'%H' 2>/dev/null |
        awk 'NF { count++ } END { print count + 0 }'
)"

# Handle history scopes that contain no commits.
if [[ "$TOTAL_COMMITS" -eq 0 ]]; then
    # Write an explanatory report.
    cat > "$CONTRIBUTION_DIR/00_no_matching_commits.txt" <<EOF
No commits matched the selected history scope: $HISTORY_SCOPE

Inspect available authors with:
git shortlog -sne --all

The project-wide analysis was still generated successfully.
EOF
else
    # Read the first matching commit.
    FIRST_COMMIT="$(
        analysis_git_log \
            --reverse \
            --date=short \
            --pretty=format:'%ad | %h | %an <%ae> | %s' 2>/dev/null |
            head -n 1
    )"

    # Read the last matching commit.
    LAST_COMMIT="$(
        analysis_git_log \
            --date=short \
            --pretty=format:'%ad | %h | %an <%ae> | %s' 2>/dev/null |
            head -n 1
    )"

    if [[ "$PRIVACY_MODE" == strict ]]; then
        FIRST_COMMIT='[commit content omitted in strict privacy mode]'
        LAST_COMMIT='[commit content omitted in strict privacy mode]'
    fi

    # Read the first commit date.
    FIRST_DATE="$(
        analysis_git_log \
            --reverse \
            --date=short \
            --pretty=format:'%ad' 2>/dev/null |
            head -n 1
    )"

    # Read the last commit date.
    LAST_DATE="$(
        analysis_git_log \
            --date=short \
            --pretty=format:'%ad' 2>/dev/null |
            head -n 1
    )"

    # Count active commit days.
    ACTIVE_DAYS="$(
        analysis_git_log \
            --date=short \
            --pretty=format:'%ad' 2>/dev/null |
            sort -u |
            awk 'NF { count++ } END { print count + 0 }'
    )"

    # Count unique historical paths changed.
    UNIQUE_FILES="$(
        analysis_git_log \
            --name-only \
            --pretty=format: 2>/dev/null |
            awk 'NF' |
            sort -u |
            awk 'NF { count++ } END { print count + 0 }'
    )"

    # Calculate historical line-change volume.
    read -r LINES_ADDED LINES_REMOVED NET_LINES <<EOF
$(
        analysis_git_log \
            --pretty=tformat: \
            --numstat 2>/dev/null |
            awk '
                $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ {
                    added += $1
                    removed += $2
                }

                END {
                    printf "%d %d %d\n",
                        added + 0,
                        removed + 0,
                        added - removed
                }
            '
)
EOF

    # Count merge commits.
    MERGE_COMMITS="$(
        analysis_git_log --merges --pretty=format:'%H' 2>/dev/null |
            awk 'NF { count++ } END { print count + 0 }'
    )"

    # Count non-merge commits.
    NON_MERGE_COMMITS="$(
        analysis_git_log --no-merges --pretty=format:'%H' 2>/dev/null |
            awk 'NF { count++ } END { print count + 0 }'
    )"

    # Count historical C# paths changed.
    HISTORICAL_CS_FILES="$(count_historical_files '\.cs$')"

    # Count historical Unity-related paths changed.
    HISTORICAL_UNITY_FILES="$(
        count_historical_files \
            '\.(cs|unity|prefab|asset|mat|anim|controller|overridecontroller|shader|hlsl|cginc|compute|shadergraph|asmdef|asmref|uxml|uss|playable|spriteatlas|rendertexture|physicmaterial|physicsmaterial2d)$'
    )"

    # Count historical scenes changed.
    HISTORICAL_SCENES="$(count_historical_files '\.unity$')"

    # Count historical prefabs changed.
    HISTORICAL_PREFABS="$(count_historical_files '\.prefab$')"

    # Count historical animation-related files changed.
    HISTORICAL_ANIMATIONS="$(
        count_historical_files \
            '\.(anim|controller|overridecontroller|playable)$'
    )"

    # Count historical shader-related files changed.
    HISTORICAL_SHADERS="$(
        count_historical_files \
            '\.(shader|hlsl|cginc|compute|shadergraph)$'
    )"

    # Count historical editor scripts changed.
    HISTORICAL_EDITOR_CS="$(
        analysis_git_log --name-only --pretty=format: 2>/dev/null |
            awk '
                {
                    line = tolower($0)
                    if (line ~ /\.cs$/ && line ~ /(^|\/)editor(\/|$)/) {
                        print $0
                    }
                }
            ' |
            sort -u |
            awk 'NF { count++ } END { print count + 0 }'
    )"

    # Write the contribution summary.
    cat > "$CONTRIBUTION_DIR/00_contribution_summary.txt" <<EOF
Git History Summary
===================

History scope: $HISTORY_SCOPE
Author filter: $DISPLAY_AUTHOR
Since: ${SINCE:-Not specified}
Until: ${UNTIL:-Not specified}

First matching commit:
$FIRST_COMMIT

Last matching commit:
$LAST_COMMIT

First commit date: ${FIRST_DATE:-N/A}
Last commit date: ${LAST_DATE:-N/A}
Active commit days: $ACTIVE_DAYS

Total commits: $TOTAL_COMMITS
Non-merge commits: $NON_MERGE_COMMITS
Merge commits: $MERGE_COMMITS

Lines added: $LINES_ADDED
Lines removed: $LINES_REMOVED
Net line change: $NET_LINES
Unique historical paths changed: $UNIQUE_FILES

Historical C# paths changed: $HISTORICAL_CS_FILES
Historical Unity-related paths changed: $HISTORICAL_UNITY_FILES
Historical scenes changed: $HISTORICAL_SCENES
Historical prefabs changed: $HISTORICAL_PREFABS
Historical animation-related files changed: $HISTORICAL_ANIMATIONS
Historical shader-related files changed: $HISTORICAL_SHADERS
Historical Editor C# files changed: $HISTORICAL_EDITOR_CS

Git statistics measure historical change volume, not exclusive ownership.
Renames, imported packages, generated files, and merges may inflate values.
EOF

    if [[ "$PRIVACY_MODE" != strict ]]; then
        # Export readable commit history.
        analysis_git_log \
            --date=iso-strict \
            --pretty=format:'%ad | %h | %an <%ae> | %s' 2>/dev/null \
            > "$CONTRIBUTION_DIR/01_commits.txt"

        # Export commit history as CSV.
        {
        # Write the CSV header.
        echo "Date,Hash,FullHash,AuthorName,AuthorEmail,Subject"

        # Convert Git records into escaped CSV rows.
        analysis_git_log \
            --date=short \
            --pretty=format:'%ad%x09%h%x09%H%x09%an%x09%ae%x09%s' 2>/dev/null |
            awk -F '\t' '
                function csv(value) {
                    gsub(/"/, "\"\"", value)
                    return "\"" value "\""
                }

                {
                    print csv($1) "," \
                          csv($2) "," \
                          csv($3) "," \
                          csv($4) "," \
                          csv($5) "," \
                          csv($6)
                }
            '
        } > "$DATA_DIR/history_commits.csv"
    fi

    # Count commits by year.
    analysis_git_log \
        --date=format:'%Y' \
        --pretty=format:'%ad' 2>/dev/null |
        sort |
        uniq -c |
        awk '{ print $2 "\t" $1 }' \
        > "$CONTRIBUTION_DIR/02_commits_by_year.txt"

    # Count commits by month.
    analysis_git_log \
        --date=format:'%Y-%m' \
        --pretty=format:'%ad' 2>/dev/null |
        sort |
        uniq -c |
        awk '{ print $2 "\t" $1 }' \
        > "$CONTRIBUTION_DIR/03_commits_by_month.txt"

    # Rank changed files.
    analysis_git_log --name-only --pretty=format: 2>/dev/null |
        awk 'NF' |
        sort |
        uniq -c |
        sort -nr \
        > "$CONTRIBUTION_DIR/04_top_changed_files.txt"

    # Rank changed directories.
    analysis_git_log --name-only --pretty=format: 2>/dev/null |
        awk '
            NF {
                count = split($0, parts, "/")

                if (count >= 3) {
                    print parts[1] "/" parts[2] "/" parts[3]
                } else if (count >= 2) {
                    print parts[1] "/" parts[2]
                } else {
                    print parts[1]
                }
            }
        ' |
        sort |
        uniq -c |
        sort -nr \
        > "$CONTRIBUTION_DIR/05_top_changed_directories.txt"

    # Rank changed file extensions.
    analysis_git_log --name-only --pretty=format: 2>/dev/null |
        awk '
            NF {
                count = split($0, parts, ".")

                if (count > 1) {
                    print "." tolower(parts[count])
                } else {
                    print "[no_extension]"
                }
            }
        ' |
        sort |
        uniq -c |
        sort -nr \
        > "$CONTRIBUTION_DIR/06_changed_file_extensions.txt"

    if [[ "$PRIVACY_MODE" != strict ]]; then
        analysis_git_log --pretty=format:'%s' 2>/dev/null |
            grep -Ei "$SYSTEM_KEYWORDS" |
            sort \
            > "$CONTRIBUTION_DIR/07_system_related_commit_subjects.txt" || true
    fi
fi

# Print the seventh progress step.
}
