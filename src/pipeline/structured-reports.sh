write_structured_reports() {
echo "[9/12] Writing summaries and structured data..."

# Build the Git-history summary fragment.
if [[ "$TOTAL_COMMITS" -gt 0 ]]; then
    # Include metrics for the selected history scope.
    CONTRIBUTION_TEXT="Total commits: $TOTAL_COMMITS
Active commit days: $ACTIVE_DAYS
First commit date: ${FIRST_DATE:-N/A}
Last commit date: ${LAST_DATE:-N/A}
Historical C# paths changed: $HISTORICAL_CS_FILES
Historical Unity-related paths changed: $HISTORICAL_UNITY_FILES
Historical scenes changed: $HISTORICAL_SCENES
Historical prefabs changed: $HISTORICAL_PREFABS"
else
    # Explain the missing history match.
    CONTRIBUTION_TEXT="No commits matched the selected history scope: $HISTORY_SCOPE"
fi

# Write the executive summary.
cat > "$SUMMARY_DIR/00_executive_summary.txt" <<EOF
Project and Career Analysis
=================================

Project
-------
Repository: $DISPLAY_REPO_NAME
Project type: $PROJECT_TYPE
Product name: $DISPLAY_PRODUCT_NAME
Company name: $DISPLAY_COMPANY_NAME
Unity version: ${UNITY_VERSION:-Unknown}
Code root: $CODE_ROOT
Generated at: $GENERATED_AT

Current Project Metrics
-----------------------
C# files: $CURRENT_CS_FILES
C# source lines: $CURRENT_CS_LINES
Unity scenes: $CURRENT_SCENES
Unity prefabs: $CURRENT_PREFABS
Animation clips: $CURRENT_ANIMATIONS
Animator controllers: $CURRENT_CONTROLLERS
Shader files: $CURRENT_SHADERS
Assembly definitions: $CURRENT_ASMDEFS
UXML files: $CURRENT_UXML
USS files: $CURRENT_USS

$HISTORY_HEADING
----------------------------
$CONTRIBUTION_TEXT

Recommended Review Order
------------------------
1. summary/00_executive_summary.txt
2. summary/01_notion_evidence_guide.md
3. project/00_repository_information.txt
4. project/17_likely_system_files.txt
5. project/18_architecture_pattern_signals.txt
6. contribution/00_contribution_summary.txt
7. contribution/04_top_changed_files.txt
8. contribution/05_top_changed_directories.txt
9. project/12_ownership_classification.txt
10. summary/02_analysis_prompt.md

Warnings
--------
Review confidential source code, commit messages, e-mails, URLs, client names,
tokens, and credentials before sharing this archive.

Current project metrics and historical contribution metrics measure different
things. Files touched are not the same as files authored.
EOF

# Escape JSON values.
JSON_REPO="$(json_escape "$DISPLAY_REPO_NAME")"
JSON_PROJECT_TYPE="$(json_escape "$PROJECT_TYPE")"
JSON_PRODUCT="$(json_escape "$DISPLAY_PRODUCT_NAME")"
JSON_COMPANY="$(json_escape "$DISPLAY_COMPANY_NAME")"
JSON_AUTHOR="$(json_escape "$DISPLAY_AUTHOR")"
JSON_GENERATED="$(json_escape "$GENERATED_AT")"
JSON_UNITY="$(json_escape "${UNITY_VERSION:-Unknown}")"

# Write project JSON.
cat > "$DATA_DIR/project_summary.json" <<EOF
{
  "repository": "$JSON_REPO",
  "project_type": "$JSON_PROJECT_TYPE",
  "product_name": "$JSON_PRODUCT",
  "company_name": "$JSON_COMPANY",
  "history_scope": "$(json_escape "$HISTORY_SCOPE")",
  "author_filter": "$JSON_AUTHOR",
  "generated_at": "$JSON_GENERATED",
  "unity_version": "$JSON_UNITY",
  "code_root": "$(json_escape "$CODE_ROOT")",
  "current_project_metrics": {
    "csharp_files": $CURRENT_CS_FILES,
    "csharp_source_lines": $CURRENT_CS_LINES,
    "unity_scenes": $CURRENT_SCENES,
    "unity_prefabs": $CURRENT_PREFABS,
    "animation_clips": $CURRENT_ANIMATIONS,
    "animator_controllers": $CURRENT_CONTROLLERS,
    "shader_files": $CURRENT_SHADERS,
    "assembly_definitions": $CURRENT_ASMDEFS,
    "uxml_files": $CURRENT_UXML,
    "uss_files": $CURRENT_USS
  }
}
EOF

# Write contribution JSON when commits matched.
if [[ "$TOTAL_COMMITS" -gt 0 ]]; then
    # Escape commit text.
    JSON_FIRST_COMMIT="$(json_escape "$FIRST_COMMIT")"
    JSON_LAST_COMMIT="$(json_escape "$LAST_COMMIT")"

    # Write contribution metrics.
    cat > "$DATA_DIR/contribution_summary.json" <<EOF
{
  "history_scope": "$(json_escape "$HISTORY_SCOPE")",
  "author_filter": "$JSON_AUTHOR",
  "since": "$(json_escape "$SINCE")",
  "until": "$(json_escape "$UNTIL")",
  "first_commit": "$JSON_FIRST_COMMIT",
  "last_commit": "$JSON_LAST_COMMIT",
  "metrics": {
    "total_commits": $TOTAL_COMMITS,
    "non_merge_commits": $NON_MERGE_COMMITS,
    "merge_commits": $MERGE_COMMITS,
    "active_days": $ACTIVE_DAYS,
    "lines_added": $LINES_ADDED,
    "lines_removed": $LINES_REMOVED,
    "net_lines": $NET_LINES,
    "unique_historical_paths_changed": $UNIQUE_FILES,
    "historical_csharp_paths_changed": $HISTORICAL_CS_FILES,
    "historical_unity_paths_changed": $HISTORICAL_UNITY_FILES,
    "historical_scenes_changed": $HISTORICAL_SCENES,
    "historical_prefabs_changed": $HISTORICAL_PREFABS,
    "historical_animation_files_changed": $HISTORICAL_ANIMATIONS,
    "historical_shader_files_changed": $HISTORICAL_SHADERS,
    "historical_editor_csharp_files_changed": $HISTORICAL_EDITOR_CS
  }
}
EOF
fi

# Describe optional folders without claiming that source was copied by default.
if [[ "$INCLUDE_SOURCE" == true ]]; then
    SOURCE_FOLDER_DESCRIPTION='- `source/`: explicitly requested classified C# source'
else
    SOURCE_FOLDER_DESCRIPTION='- `source/`: omitted (use --include-source outside strict mode)'
fi

# Write the main README.
cat > "$OUTPUT_DIR/README.md" <<EOF
# Project and Career Analysis

**Repository:** $DISPLAY_REPO_NAME
**Project type:** $PROJECT_TYPE
**Product:** $DISPLAY_PRODUCT_NAME
**Git history scope:** $HISTORY_SCOPE
**Unity version:** ${UNITY_VERSION:-Unknown}  
**Privacy mode:** $PRIVACY_MODE
**Source included:** $INCLUDE_SOURCE
**Generated:** $GENERATED_AT

## Purpose

This package combines a current project review, $HISTORY_DESCRIPTION,
collaboration evidence, and a Notion career-journaling guide.

## Main folders

- \`summary/\`: executive summary and Notion analysis guides
- \`project/\`: current project structure, systems, and technologies
- \`contribution/\`: $HISTORY_DESCRIPTION
$SOURCE_FOLDER_DESCRIPTION
- \`data/\`: JSON and CSV exports
- \`security/\`: redacted potential-secret findings
- \`report/\`: standardized HTML reports rendered from canonical JSON
- \`report/index.html\`: navigation entry point for the HTML report set
- \`notion/evidence.json\`: facts, evidence, inferences, and confirmation prompts
- \`graphs/\`: optional charts

## Start here

1. \`report/index.html\`
2. \`notion/evidence.json\`
3. \`report/data/report.json\`

## Limitations

- Git change volume is not exclusive authorship.
- Ownership confidence is evidence-based but still requires human review.
- Product purpose and personal learning require human context.
- Review confidential content before sharing.
EOF

# Print the tenth progress step.
}
