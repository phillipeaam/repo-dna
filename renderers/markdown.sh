#!/usr/bin/env bash

set -u

JSON_FILE="$1"
OUTPUT_DIR="$2"

mkdir -p "$OUTPUT_DIR"

json_value() {
    local key="$1"

    awk -v key="$key" '
        index($0, "\"" key "\"") {
            marker = "\"" key "\""
            value = substr($0, index($0, marker) + length(marker))
            sub(/^[[:space:]]*:[[:space:]]*/, "", value)
            if (value ~ /^"/) {
                rest = substr(value, 2)
                result = ""
                escaped = 0
                for (i = 1; i <= length(rest); i++) {
                    character = substr(rest, i, 1)
                    if (character == "\"" && !escaped) {
                        break
                    }
                    result = result character
                    if (character == "\\" && !escaped) {
                        escaped = 1
                    } else {
                        escaped = 0
                    }
                }
                value = result
                gsub(/\\n/, " ", value)
                gsub(/\\"/, "\"", value)
                gsub(/\\\\/, "\\", value)
            } else {
                sub(/[},].*$/, "", value)
                sub(/[[:space:]]+$/, "", value)
            }
            print value
            exit
        }
    ' "$JSON_FILE"
}

write_table() {
    local output_file="$1"
    shift

    {
        printf '%s\n' '| Metric | Value |'
        printf '%s\n' '|---|---:|'
        while [[ $# -gt 0 ]]; do
            printf '| %s | %s |\n' "$1" "$(json_value "$2")"
            shift 2
        done
    } >> "$output_file"
}

PROJECT_NAME="$(json_value name)"
PROJECT_TYPE="$(json_value type)"
PRIVACY_MODE="$(json_value mode)"
SOURCE_INCLUDED="$(json_value source_included)"
SCHEMA_VERSION="$(json_value schema_version)"
UNITY_ANALYSIS="$(json_value unity)"
CSHARP_ANALYSIS="$(json_value csharp)"

cat > "$OUTPUT_DIR/index.md" <<EOF
# $PROJECT_NAME report

- [Executive summary](executive-summary.md)
- [Project overview](project-overview.md)
- [Architecture](architecture.md)
- [Technologies](technologies.md)
- [Systems](systems.md)
- [Contribution](contribution.md)
- [Collaboration](collaboration.md)
- [Risks](risks.md)
- [Notion evidence](notion-evidence.md)

Generated from data/report.json (schema $SCHEMA_VERSION).
EOF

cat > "$OUTPUT_DIR/executive-summary.md" <<EOF
# Executive summary

**Project:** $PROJECT_NAME  
**Type:** $PROJECT_TYPE  
**Privacy mode:** $PRIVACY_MODE  
**Source included:** $SOURCE_INCLUDED

EOF
if [[ "$CSHARP_ANALYSIS" == true ]]; then
    write_table "$OUTPUT_DIR/executive-summary.md" \
        'C# files' csharp_files \
        'C# lines' csharp_lines \
        'Total commits' total_commits \
        'Contributors' contributors \
        'Potential secret findings' potential_secret_findings
else
    write_table "$OUTPUT_DIR/executive-summary.md" \
        'Total commits' total_commits \
        'Contributors' contributors \
        'Potential secret findings' potential_secret_findings
fi

cat > "$OUTPUT_DIR/project-overview.md" <<EOF
# Project overview

| Field | Value |
|---|---|
| Repository | $PROJECT_NAME |
| Project type | $PROJECT_TYPE |
| Code root | $(json_value code_root) |
EOF
if [[ "$UNITY_ANALYSIS" == true ]]; then
    printf '| Product | %s |\n| Company | %s |\n| Unity version | %s |\n' \
        "$(json_value product)" "$(json_value company)" "$(json_value unity_version)" \
        >> "$OUTPUT_DIR/project-overview.md"
fi
printf '%s\n\n' '## Current metrics' >> "$OUTPUT_DIR/project-overview.md"
if [[ "$UNITY_ANALYSIS" == true ]]; then
    write_table "$OUTPUT_DIR/project-overview.md" \
        'C# files' csharp_files 'C# lines' csharp_lines 'Scenes' scenes 'Prefabs' prefabs \
        'Animations' animations 'Animator controllers' animator_controllers \
        'Shaders' shaders 'Assembly definitions' assembly_definitions \
        'UXML files' uxml_files 'USS files' uss_files
elif [[ "$CSHARP_ANALYSIS" == true ]]; then
    write_table "$OUTPUT_DIR/project-overview.md" 'C# files' csharp_files 'C# lines' csharp_lines
else
    printf '%s\n' 'No project-specific source metrics are available for this project type yet.' \
        >> "$OUTPUT_DIR/project-overview.md"
fi

printf '%s\n\n' '# Architecture' > "$OUTPUT_DIR/architecture.md"
if [[ "$UNITY_ANALYSIS" == true ]]; then
    write_table "$OUTPUT_DIR/architecture.md" \
        'Scriptable objects' scriptable_objects 'MonoBehaviours' monobehaviours \
        'Interfaces' interfaces 'Architecture signals' architecture_signals \
        'Networking signals' networking_signals 'Services and data signals' services_and_data_signals \
        'Performance signals' performance_signals 'Technical debt markers' technical_debt_markers
elif [[ "$CSHARP_ANALYSIS" == true ]]; then
    write_table "$OUTPUT_DIR/architecture.md" \
        'Interfaces' interfaces 'Architecture signals' architecture_signals \
        'Networking signals' networking_signals 'Services and data signals' services_and_data_signals \
        'Performance signals' performance_signals 'Technical debt markers' technical_debt_markers
else
    printf '%s\n' 'No architecture collector is available for this project type yet.' \
        >> "$OUTPUT_DIR/architecture.md"
fi

printf '%s\n\n' '# Technologies' > "$OUTPUT_DIR/technologies.md"
if [[ "$UNITY_ANALYSIS" == true ]]; then
    write_table "$OUTPUT_DIR/technologies.md" \
        'Dependencies' dependency_count 'Shader files' shader_files \
        'UI Toolkit files' ui_toolkit_files 'Assembly definitions' assembly_definitions
else
    write_table "$OUTPUT_DIR/technologies.md" 'Dependencies' dependency_count
fi

printf '%s\n\n' '# Systems' > "$OUTPUT_DIR/systems.md"
if [[ "$UNITY_ANALYSIS" == true ]]; then
    write_table "$OUTPUT_DIR/systems.md" \
        'Likely system files' likely_system_files 'Resources assets' resources_assets \
        'Addressables assets' addressables_assets
elif [[ "$CSHARP_ANALYSIS" == true ]]; then
    write_table "$OUTPUT_DIR/systems.md" 'Likely system files' likely_system_files
else
    printf '%s\n' 'No system collector is available for this project type yet.' \
        >> "$OUTPUT_DIR/systems.md"
fi

printf '%s\n\n' '# Contribution' > "$OUTPUT_DIR/contribution.md"
write_table "$OUTPUT_DIR/contribution.md" \
    'Scope' scope \
    'Total commits' total_commits \
    'Merge commits' merge_commits \
    'Non-merge commits' non_merge_commits \
    'Active days' active_days \
    'First date' first_date \
    'Last date' last_date \
    'Lines added' lines_added \
    'Lines removed' lines_removed \
    'Unique paths changed' unique_paths_changed

printf '%s\n\n' '# Collaboration' > "$OUTPUT_DIR/collaboration.md"
write_table "$OUTPUT_DIR/collaboration.md" 'Contributors' contributors

printf '%s\n\n' '# Risks' > "$OUTPUT_DIR/risks.md"
write_table "$OUTPUT_DIR/risks.md" \
    'Potential secret findings' potential_secret_findings \
    'Ownership review required' ownership_review_required
printf '%s\n' 'See `../security/potential_secrets.txt` and the ownership classification evidence.' \
    >> "$OUTPUT_DIR/risks.md"

cat > "$OUTPUT_DIR/notion-evidence.md" <<'EOF'
# Notion evidence

Structured evidence is available at `../notion/evidence.json`. It separates
facts, evidence, inferences, personal data, and claims requiring confirmation.

Detailed raw evidence remains available in the legacy `project/` and
`contribution/` directories during the reporting migration.
EOF
