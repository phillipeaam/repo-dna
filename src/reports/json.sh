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

report_dependency_manifest() {
    case "$PROJECT_TYPE" in
        Unity)   [[ -f Packages/manifest.json ]] && printf 'Packages/manifest.json' ;;
        Node)    [[ -f package.json ]] && printf 'package.json' ;;
        Python)
            if [[ -f pyproject.toml ]]; then
                printf 'pyproject.toml'
            elif [[ -f requirements.txt ]]; then
                printf 'requirements.txt'
            fi
            ;;
        Android)
            if [[ -f build.gradle.kts ]]; then
                printf 'build.gradle.kts'
            elif [[ -f build.gradle ]]; then
                printf 'build.gradle'
            fi
            ;;
        .NET)    find . -maxdepth 2 -type f -name '*.csproj' -print -quit 2>/dev/null ;;
        Flutter) [[ -f pubspec.yaml ]] && printf 'pubspec.yaml' ;;
        *)       printf '' ;;
    esac
}

report_dependency_count() {
    local manifest="$1"

    [[ -f "$manifest" ]] || { printf '0'; return; }

    case "$manifest" in
        *.csproj) grep -Eic '<PackageReference[[:space:]>]' "$manifest" || true ;;
        requirements.txt) awk 'NF && $0 !~ /^[[:space:]]*#/' "$manifest" | wc -l | tr -d '[:space:]' ;;
        *) grep -Ec '^[[:space:]]*["[:alnum:]_.@/-]+["[:space:]]*[:=]' "$manifest" || true ;;
    esac
}

write_structured_report_json() {
    local output_file="$1"
    local ownership_review_count
    local contributor_count
    local dependency_manifest
    local dependency_count
    local unity_analysis=false
    local csharp_analysis=false
    local generic_analysis_json
    local charts_json='[]'
    local -a chart_items=()

    [[ "$PROJECT_TYPE" == Unity ]] && unity_analysis=true
    [[ "$PROJECT_TYPE" == Unity || "$PROJECT_TYPE" == .NET ]] && csharp_analysis=true
    dependency_manifest="$(report_dependency_manifest)"
    dependency_count="$(report_dependency_count "$dependency_manifest")"
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
  "schema_version": "1.1",
  "generated_at": "$(json_escape "$GENERATED_AT")",
  "privacy": {
    "mode": "$(json_escape "$PRIVACY_MODE")",
    "source_included": $INCLUDE_SOURCE
  },
  "project": {
    "name": "$(json_escape "$DISPLAY_REPO_NAME")",
    "type": "$(json_escape "$PROJECT_TYPE")",
    "product": "$(json_escape "$DISPLAY_PRODUCT_NAME")",
    "company": "$(json_escape "$DISPLAY_COMPANY_NAME")",
    "code_root": "$(json_escape "$CODE_ROOT")",
    "unity_version": "$(json_escape "${UNITY_VERSION:-Unknown}")"
  },
  "analysis_profile": {
    "unity": $unity_analysis,
    "csharp": $csharp_analysis,
    "dependency_manifest": "$(json_escape "$dependency_manifest")"
  },
  "generic_analysis": $generic_analysis_json,
  "current_metrics": {
    "csharp_files": ${CURRENT_METRICS[csharp_files]:-0},
    "csharp_lines": ${CURRENT_METRICS[csharp_lines]:-0},
    "scenes": ${CURRENT_METRICS[scenes]:-0},
    "prefabs": ${CURRENT_METRICS[prefabs]:-0},
    "animations": ${CURRENT_METRICS[animations]:-0},
    "animator_controllers": ${CURRENT_METRICS[controllers]:-0},
    "shaders": ${CURRENT_METRICS[shaders]:-0},
    "assembly_definitions": ${CURRENT_METRICS[asmdefs]:-0},
    "uxml_files": ${CURRENT_METRICS[uxml]:-0},
    "uss_files": ${CURRENT_METRICS[uss]:-0}
  },
  "architecture": {
    "scriptable_objects": $(report_line_count "$PROJECT_DIR/13_scriptable_objects.txt"),
    "monobehaviours": $(report_line_count "$PROJECT_DIR/14_monobehaviours.txt"),
    "interfaces": $(report_line_count "$PROJECT_DIR/15_interfaces.txt"),
    "architecture_signals": $(report_line_count "$PROJECT_DIR/18_architecture_pattern_signals.txt"),
    "networking_signals": $(report_line_count "$PROJECT_DIR/19_networking_signals.txt"),
    "services_and_data_signals": $(report_line_count "$PROJECT_DIR/20_services_and_data_signals.txt"),
    "performance_signals": $(report_line_count "$PROJECT_DIR/21_performance_signals.txt"),
    "technical_debt_markers": $(report_line_count "$PROJECT_DIR/22_technical_debt_markers.txt")
  },
  "technologies": {
    "dependency_count": ${dependency_count:-0},
    "shader_files": ${CURRENT_METRICS[shaders]:-0},
    "ui_toolkit_files": $((${CURRENT_METRICS[uxml]:-0} + ${CURRENT_METRICS[uss]:-0})),
    "assembly_definitions": ${CURRENT_METRICS[asmdefs]:-0}
  },
  "systems": {
    "likely_system_files": $(report_line_count "$PROJECT_DIR/17_likely_system_files.txt"),
    "resources_assets": $(report_line_count "$PROJECT_DIR/10_resources_assets.txt"),
    "addressables_assets": $(report_line_count "$PROJECT_DIR/11_addressables_assets.txt")
  },
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
