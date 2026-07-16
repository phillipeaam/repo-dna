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
    "csharp_files": ${CURRENT_CS_FILES:-0},
    "csharp_lines": ${CURRENT_CS_LINES:-0},
    "scenes": ${CURRENT_SCENES:-0},
    "prefabs": ${CURRENT_PREFABS:-0},
    "animations": ${CURRENT_ANIMATIONS:-0},
    "animator_controllers": ${CURRENT_CONTROLLERS:-0},
    "shaders": ${CURRENT_SHADERS:-0},
    "assembly_definitions": ${CURRENT_ASMDEFS:-0},
    "uxml_files": ${CURRENT_UXML:-0},
    "uss_files": ${CURRENT_USS:-0}
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
    "shader_files": ${CURRENT_SHADERS:-0},
    "ui_toolkit_files": $((${CURRENT_UXML:-0} + ${CURRENT_USS:-0})),
    "assembly_definitions": ${CURRENT_ASMDEFS:-0}
  },
  "systems": {
    "likely_system_files": $(report_line_count "$PROJECT_DIR/17_likely_system_files.txt"),
    "resources_assets": $(report_line_count "$PROJECT_DIR/10_resources_assets.txt"),
    "addressables_assets": $(report_line_count "$PROJECT_DIR/11_addressables_assets.txt")
  },
  "history": {
    "scope": "$(json_escape "$HISTORY_SCOPE")",
    "total_commits": ${TOTAL_COMMITS:-0},
    "merge_commits": ${MERGE_COMMITS:-0},
    "non_merge_commits": ${NON_MERGE_COMMITS:-0},
    "active_days": ${ACTIVE_DAYS:-0},
    "first_date": "$(json_escape "${FIRST_DATE:-}")",
    "last_date": "$(json_escape "${LAST_DATE:-}")",
    "lines_added": ${LINES_ADDED:-0},
    "lines_removed": ${LINES_REMOVED:-0},
    "unique_paths_changed": ${UNIQUE_FILES:-0}
  },
  "collaboration": {
    "contributors": ${contributor_count:-0}
  },
  "risks": {
    "potential_secret_findings": ${POTENTIAL_SECRET_COUNT:-0},
    "ownership_review_required": ${ownership_review_count:-0}
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
