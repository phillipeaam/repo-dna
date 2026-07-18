write_structured_reports() {
local CONTRIBUTION_TEXT PROJECT_IDENTITY_TEXT CURRENT_METRICS_TEXT
local JSON_REPO JSON_PROJECT_TYPE JSON_PRODUCT JSON_COMPANY JSON_AUTHOR
local JSON_GENERATED JSON_UNITY JSON_FIRST_COMMIT JSON_LAST_COMMIT
local SOURCE_FOLDER_DESCRIPTION PROJECT_README_METADATA
echo "[9/12] Writing summaries and structured data..."

# Build the Git-history summary fragment.
if ((GIT_HISTORY[total_commits] > 0)); then
    # Include metrics for the selected history scope.
    CONTRIBUTION_TEXT="Total commits: ${GIT_HISTORY[total_commits]}
Active commit days: ${GIT_HISTORY[active_days]}
First commit date: ${GIT_HISTORY[first_date]:-N/A}
Last commit date: ${GIT_HISTORY[last_date]:-N/A}"
    if [[ "$PROJECT_TYPE" == Unity || "$PROJECT_TYPE" == .NET ]]; then
        CONTRIBUTION_TEXT="$CONTRIBUTION_TEXT
Historical C# paths changed: ${GIT_HISTORY[historical_cs_files]}"
    fi
    if [[ "$PROJECT_TYPE" == Unity ]]; then
        CONTRIBUTION_TEXT="$CONTRIBUTION_TEXT
Historical Unity-related paths changed: ${GIT_HISTORY[historical_unity_files]}
Historical scenes changed: ${GIT_HISTORY[historical_scenes]}
Historical prefabs changed: ${GIT_HISTORY[historical_prefabs]}"
    fi
else
    # Explain the missing history match.
    CONTRIBUTION_TEXT="No commits matched the selected history scope: $HISTORY_SCOPE"
fi

# Build profile-specific text without leaking Unity concepts into generic reports.
PROJECT_IDENTITY_TEXT="Repository: $DISPLAY_REPO_NAME
Project type: $PROJECT_TYPE
Code root: $CODE_ROOT
Generated at: $GENERATED_AT"
CURRENT_METRICS_TEXT='See report/data/generic-analysis.json for stack-neutral metrics.'
if [[ "$PROJECT_TYPE" == Unity ]]; then
    PROJECT_IDENTITY_TEXT="$PROJECT_IDENTITY_TEXT
Product name: $DISPLAY_PRODUCT_NAME
Company name: $DISPLAY_COMPANY_NAME
Unity version: ${UNITY_VERSION:-Unknown}"
    CURRENT_METRICS_TEXT="C# files: ${CURRENT_METRICS[csharp_files]}
C# source lines: ${CURRENT_METRICS[csharp_lines]}
Unity scenes: ${CURRENT_METRICS[scenes]}
Unity prefabs: ${CURRENT_METRICS[prefabs]}
Animation clips: ${CURRENT_METRICS[animations]}
Animator controllers: ${CURRENT_METRICS[controllers]}
Shader files: ${CURRENT_METRICS[shaders]}
Assembly definitions: ${CURRENT_METRICS[asmdefs]}
UXML files: ${CURRENT_METRICS[uxml]}
USS files: ${CURRENT_METRICS[uss]}"
elif [[ "$PROJECT_TYPE" == .NET ]]; then
    CURRENT_METRICS_TEXT="C# files: ${CURRENT_METRICS[csharp_files]}
C# source lines: ${CURRENT_METRICS[csharp_lines]}"
fi

# Write the executive summary.
cat > "$SUMMARY_DIR/00_executive_summary.txt" <<EOF
Project and Career Analysis
=================================

Project
-------
$PROJECT_IDENTITY_TEXT

Current Project Metrics
-----------------------
$CURRENT_METRICS_TEXT

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
    "csharp_files": ${CURRENT_METRICS[csharp_files]},
    "csharp_source_lines": ${CURRENT_METRICS[csharp_lines]},
    "unity_scenes": ${CURRENT_METRICS[scenes]},
    "unity_prefabs": ${CURRENT_METRICS[prefabs]},
    "animation_clips": ${CURRENT_METRICS[animations]},
    "animator_controllers": ${CURRENT_METRICS[controllers]},
    "shader_files": ${CURRENT_METRICS[shaders]},
    "assembly_definitions": ${CURRENT_METRICS[asmdefs]},
    "uxml_files": ${CURRENT_METRICS[uxml]},
    "uss_files": ${CURRENT_METRICS[uss]}
  }
}
EOF

# Write contribution JSON when commits matched.
if ((GIT_HISTORY[total_commits] > 0)); then
    # Escape commit text.
    JSON_FIRST_COMMIT="$(json_escape "${GIT_HISTORY[first_commit]}")"
    JSON_LAST_COMMIT="$(json_escape "${GIT_HISTORY[last_commit]}")"

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
    "total_commits": ${GIT_HISTORY[total_commits]},
    "non_merge_commits": ${GIT_HISTORY[non_merge_commits]},
    "merge_commits": ${GIT_HISTORY[merge_commits]},
    "active_days": ${GIT_HISTORY[active_days]},
    "lines_added": ${GIT_HISTORY[lines_added]},
    "lines_removed": ${GIT_HISTORY[lines_removed]},
    "net_lines": ${GIT_HISTORY[net_lines]},
    "unique_historical_paths_changed": ${GIT_HISTORY[unique_files]},
    "historical_csharp_paths_changed": ${GIT_HISTORY[historical_cs_files]},
    "historical_unity_paths_changed": ${GIT_HISTORY[historical_unity_files]},
    "historical_scenes_changed": ${GIT_HISTORY[historical_scenes]},
    "historical_prefabs_changed": ${GIT_HISTORY[historical_prefabs]},
    "historical_animation_files_changed": ${GIT_HISTORY[historical_animations]},
    "historical_shader_files_changed": ${GIT_HISTORY[historical_shaders]},
    "historical_editor_csharp_files_changed": ${GIT_HISTORY[historical_editor_cs]}
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
PROJECT_README_METADATA=''
if [[ "$PROJECT_TYPE" == Unity ]]; then
    PROJECT_README_METADATA="**Product:** $DISPLAY_PRODUCT_NAME
**Company:** $DISPLAY_COMPANY_NAME
**Unity version:** ${UNITY_VERSION:-Unknown}"
fi
cat > "$OUTPUT_DIR/README.md" <<EOF
# Project and Career Analysis

**Repository:** $DISPLAY_REPO_NAME
**Project type:** $PROJECT_TYPE
**Git history scope:** $HISTORY_SCOPE
$PROJECT_README_METADATA
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
- \`llm/evidence.json\`: compact, provenance-rich evidence prepared for LLM use
- \`snapshots/\`: validated point-in-time analysis snapshot and versioned schema
- \`comparison/\`: structured and navigable comparison with a previous snapshot
- \`health-trends/\`: compatible health-score history, exclusions, and optional chart
- \`system-docs/\`: evidence-based HTML and JSON documentation per detected system
- \`onboarding/\`: entrypoints, commands, repository map, workflow evidence, and unknowns
- \`sbom/\`: lockfile-derived dependency inventory and CycloneDX 1.6 JSON
$([[ "$PROJECT_TYPE" != Android ]] || printf '%s\n' '- `android/`: Android components, dependencies, permissions, screens, data, networking, and variants')
$([[ "$PROJECT_TYPE" != Flutter ]] || printf '%s\n' '- `flutter/`: Flutter widgets, routes, state, localization, channels, tests, and flavors')
$([[ "$PROJECT_TYPE" != Godot ]] || printf '%s\n' '- `godot/`: Godot project settings, scenes, scripts, resources, gameplay systems, plugins, exports, and review signals')
- \`portfolio/\`: approval-gated portfolio and CV evidence draft
- \`graphs/\`: optional charts

## Start here

1. \`report/index.html\`
2. \`notion/evidence.json\`
3. \`comparison/index.html\`
4. \`health-trends/index.html\`
5. \`system-docs/index.html\`
6. \`onboarding/index.html\`
7. \`llm/evidence.json\`
8. \`sbom/index.html\`
9. \`report/data/report.json\`

## Limitations

- Git change volume is not exclusive authorship.
- Ownership confidence is evidence-based but still requires human review.
- Product purpose and personal learning require human context.
- Review confidential content before sharing.
EOF

# Print the tenth progress step.
}
