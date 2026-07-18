#!/usr/bin/env bash

# Structured report data collection. Renderers must consume the generated JSON.

report_line_count() {
    local source_file="$1"

    if [[ -f "$source_file" ]]; then
        awk 'NF { count++ } END { print count + 0 }' "$source_file"
    else
        printf '0'
    fi
}

write_structured_report_json() {
    local output_file="$1"
    local ownership_review_count
    local contributor_count
    local unity_analysis=false
    local android_analysis=false
    local flutter_analysis=false
    local godot_analysis=false
    local unreal_analysis=false
    local generic_analysis_json
    local charts_json='[]'
    local -a chart_items=()

    [[ "$PROJECT_TYPE" == Unity ]] && unity_analysis=true
    [[ "$PROJECT_TYPE" == Android ]] && android_analysis=true
    [[ "$PROJECT_TYPE" == Flutter ]] && flutter_analysis=true
    [[ "$PROJECT_TYPE" == Godot ]] && godot_analysis=true
    [[ "$PROJECT_TYPE" == Unreal ]] && unreal_analysis=true
    if [[ -f "${GENERIC_ANALYSIS_FILE:-}" ]]; then
        generic_analysis_json="$(cat "$GENERIC_ANALYSIS_FILE")"
    else
        generic_analysis_json='{"available":false,"reason":"generic collector output missing"}'
    fi

    ownership_review_count="$(
        grep -c 'review-required' "$PROJECT_DIR/12_ownership_classification.txt" 2>/dev/null || true
    )"
    contributor_count="$(report_line_count "$PROJECT_DIR/26_all_contributors.txt")"
    [[ ! -f "$GRAPHS_DIR/commits_by_month.png" ]] ||
        chart_items+=('{"title":"Commits by month","path":"../graphs/commits_by_month.png"}')
    [[ ! -f "$GRAPHS_DIR/commits_by_year.png" ]] ||
        chart_items+=('{"title":"Commits by year","path":"../graphs/commits_by_year.png"}')
    [[ ! -f "$GRAPHS_DIR/churn_by_month.png" ]] ||
        chart_items+=('{"title":"Churn by month (analyzed contributions)","path":"../graphs/churn_by_month.png"}')
    [[ ! -f "$GRAPHS_DIR/hotspots.png" ]] ||
        chart_items+=('{"title":"Composite hotspots","path":"../graphs/hotspots.png"}')
    [[ ! -f "$GRAPHS_DIR/systems.png" ]] ||
        chart_items+=('{"title":"Detected systems by source files","path":"../graphs/systems.png"}')
    [[ ! -f "$GRAPHS_DIR/authors.png" ]] ||
        chart_items+=('{"title":"Commits by author","path":"../graphs/authors.png"}')
    [[ ! -f "$GRAPHS_DIR/system_evolution.png" ]] ||
        chart_items+=('{"title":"System evolution by month","path":"../graphs/system_evolution.png"}')
    [[ ! -f "$GRAPHS_DIR/architecture_evolution.png" ]] ||
        chart_items+=('{"title":"Architecture-related change signals","path":"../graphs/architecture_evolution.png"}')
    if ((${#chart_items[@]} > 0)); then
        charts_json="[$(IFS=,; printf '%s' "${chart_items[*]}")]"
    fi

    cat > "$output_file" <<EOF
{
  "\$schema": "./report-1.3.0.schema.json",
  "schema_version": "1.3",
  "generated_at": "$(json_escape "$GENERATED_AT")",
  "privacy": {
    "mode": "$(json_escape "$PRIVACY_MODE")",
    "source_included": $INCLUDE_SOURCE
  },
  "project": {
    "name": "$(json_escape "$DISPLAY_REPO_NAME")",
    "type": "$(json_escape "$PROJECT_TYPE")",
    "code_root": "$(json_escape "$CODE_ROOT")"
  },
  "analysis_profile": {
    "unity": $unity_analysis,
    "android": $android_analysis,
    "flutter": $flutter_analysis,
    "godot": $godot_analysis,
    "unreal": $unreal_analysis
  },
  "generic_analysis": $generic_analysis_json,
  "canonical_metrics": {},
  "history": {
    "scope": "$(json_escape "$HISTORY_SCOPE")",
    "total_commits": ${GIT_HISTORY[total_commits]:-0},
    "merge_commits": ${GIT_HISTORY[merge_commits]:-0},
    "non_merge_commits": ${GIT_HISTORY[non_merge_commits]:-0},
    "active_days": ${GIT_HISTORY[active_days]:-0},
    "first_date": "$(json_escape "${GIT_HISTORY[first_date]:-}")",
    "last_date": "$(json_escape "${GIT_HISTORY[last_date]:-}")",
    "lines_added": ${GIT_HISTORY[lines_added]:-0},
    "lines_removed": ${GIT_HISTORY[lines_removed]:-0},
    "unique_paths_changed": ${GIT_HISTORY[unique_files]:-0}
  },
  "collaboration": {
    "contributors": ${contributor_count:-0}
  },
  "risks": {
    "potential_secret_findings": ${POTENTIAL_SECRET_COUNT:-0},
    "ownership_review_required": ${ownership_review_count:-0}
  },
  "visualizations": {
    "charts": $charts_json
  },
  "evidence": {
    "legacy_project_directory": "../project",
    "legacy_contribution_directory": "../contribution",
    "security_report": "../security/potential_secrets.txt",
    "privacy_scan": "../summary/03_privacy_scan.txt"
  }
}
EOF
}
