#!/usr/bin/env bash

# Fail when an undefined variable is used.
set -u

# Fail a pipeline when any command inside it fails.
set -o pipefail

# Initialize optional Git-history filters.
AUTHOR=""
SINCE=""
UNTIL=""
OWNED_ROOTS=()
INCLUDE_SOURCE=false
PRIVACY_MODE='standard'

# Resolve this script's directory so it can be run from any repository folder.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load project-type and source-root detection.
# shellcheck source=lib/project-detection.sh
source "$SCRIPT_DIR/lib/project-detection.sh"

# Print an error and stop execution.
die() {
    # Print a blank line.
    echo ""

    # Print the error message to stderr.
    echo "Error: $1" >&2

    # Exit with a failure code.
    exit 1
}

# Print command-line usage.
show_usage() {
    echo "Usage:"
    echo "  bash dna-analysis.sh [options]"
    echo ""
    echo "Options:"
    echo "  --author <name-or-email>  Analyze one contributor instead of all history."
    echo "  --since <date>            Include commits on or after this date."
    echo "  --until <date>            Include commits on or before this date."
    echo "  --owned-root <path>       Mark a path as project-owned (repeatable)."
    echo "  --include-source          Copy classified C# source into the report."
    echo "  --privacy-mode <mode>     Privacy level: standard or strict."
    echo "  -h, --help                Show this help."
    echo ""
    echo "Examples:"
    echo "  bash dna-analysis.sh"
    echo "  bash dna-analysis.sh --author \"Phillipe Augusto\""
    echo "  bash dna-analysis.sh --since 2020-01-01 --until 2025-12-31"
    echo "  bash dna-analysis.sh --owned-root Assets/_Project"
    echo "  bash dna-analysis.sh --include-source"
    echo "  bash dna-analysis.sh --privacy-mode strict"
}

# Read named command-line options.
while [[ $# -gt 0 ]]; do
    case "$1" in
        --author|--since|--until|--owned-root|-owned-root|--privacy-mode)
            [[ -n "${2:-}" ]] || die "Option $1 requires a value."

            case "$1" in
                --author) AUTHOR="$2" ;;
                --since)  SINCE="$2" ;;
                --until)  UNTIL="$2" ;;
                --owned-root|-owned-root) OWNED_ROOTS+=("${2#./}") ;;
                --privacy-mode) PRIVACY_MODE="$2" ;;
            esac

            shift 2
            ;;
        --include-source)
            INCLUDE_SOURCE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            show_usage >&2
            die "Unknown option: $1"
            ;;
    esac
done

[[ "$PRIVACY_MODE" == standard || "$PRIVACY_MODE" == strict ]] ||
    die "Invalid privacy mode: $PRIVACY_MODE (expected standard or strict)."

if [[ "$PRIVACY_MODE" == strict ]]; then
    INCLUDE_SOURCE=false
fi

# Return success when a command exists.
command_exists() {
    # Ask the shell to resolve the command.
    command -v "$1" >/dev/null 2>&1
}

# Remove whitespace from a numeric result.
trim_count() {
    # Delete all whitespace characters.
    tr -d '[:space:]'
}

# Escape a value before writing it to JSON.
json_escape() {
    # Print the value without an extra newline.
    printf '%s' "$1" |

        # Escape backslashes, quotes, and line breaks.
        sed \
            -e 's/\\/\\\\/g' \
            -e 's/"/\\"/g' \
            -e ':a;N;$!ba;s/\n/\\n/g'
}

# Escape a value before writing it to HTML.
html_escape() {
    # Print the value without an extra newline.
    printf '%s' "$1" |

        # Replace HTML-sensitive characters.
        sed \
            -e 's/&/\&amp;/g' \
            -e 's/</\&lt;/g' \
            -e 's/>/\&gt;/g' \
            -e 's/"/\&quot;/g'
}

# Execute git log using the configured optional filters.
analysis_git_log() {
    local filters=(--all)

    if [[ -n "$AUTHOR" ]]; then
        filters+=(--author="$AUTHOR")
    fi

    filters+=("${DATE_FILTER[@]}")
    git log "${filters[@]}" "$@"
}

# Copy one file while preserving its relative project path.
copy_preserving_path() {
    # Read the source file path.
    local source_file="$1"

    # Read the destination root.
    local destination_root="$2"

    # Create the destination directory tree.
    mkdir -p "$destination_root/$(dirname "$source_file")"

    # Copy the file into the matching relative path.
    cp "$source_file" "$destination_root/$source_file"
}

# Scan the completed report without copying matched secret values into the result.
run_privacy_scan() {
    local findings_file
    local secret_regex
    findings_file="$(mktemp)" || die "Could not create the privacy scan workspace."
    secret_regex='-----BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY-----|AKIA[0-9A-Z]{16}|(api[_-]?key|client[_-]?secret|access[_-]?token|password)[[:space:]]*[:=][[:space:]]*[^[:space:]]{8,}'

    grep -RIlE -- "$secret_regex" "$OUTPUT_DIR" 2>/dev/null > "$findings_file" || true

    if [[ "$PRIVACY_MODE" == strict ]]; then
        grep -RIlE -- \
            '([[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}|https?://|ssh://|git@[^[:space:]]+:)' \
            "$OUTPUT_DIR" 2>/dev/null >> "$findings_file" || true
        grep -RIlF -- "$REPO_ROOT" "$OUTPUT_DIR" 2>/dev/null >> "$findings_file" || true
    fi

    sort -u "$findings_file" -o "$findings_file"

    {
        printf '%s\n' 'Privacy scan'
        printf '%s\n' '------------'
        printf 'Mode: %s\n' "$PRIVACY_MODE"

        if [[ -s "$findings_file" ]]; then
            PRIVACY_SCAN_FAILED=true
            printf '%s\n' 'Result: blocked'
            printf '%s\n' 'Potential sensitive content was found in:'
            sed "s|^$OUTPUT_DIR/||" "$findings_file"
        else
            PRIVACY_SCAN_FAILED=false
            printf '%s\n' 'Result: passed'
            printf '%s\n' 'No configured sensitive-content pattern was detected.'
        fi
    } > "$SUMMARY_DIR/03_privacy_scan.txt"

    rm -f "$findings_file"
}

# Remove matched source-line bodies from detector reports in strict mode.
sanitize_strict_reports() {
    local report_file

    [[ "$PRIVACY_MODE" == strict ]] || return 0

    for report_file in \
        "$PROJECT_DIR"/13_*.txt \
        "$PROJECT_DIR"/14_*.txt \
        "$PROJECT_DIR"/15_*.txt \
        "$PROJECT_DIR"/16_*.txt \
        "$PROJECT_DIR"/17_*.txt \
        "$PROJECT_DIR"/18_*.txt \
        "$PROJECT_DIR"/19_*.txt \
        "$PROJECT_DIR"/20_*.txt \
        "$PROJECT_DIR"/21_*.txt \
        "$PROJECT_DIR"/22_*.txt \
        "$PROJECT_DIR"/23_*.txt; do
        [[ -f "$report_file" ]] || continue
        sed -Ei 's/^([^:]+:[0-9]+):.*/\1:[content omitted]/' "$report_file"
    done
}

# Count current files matching a case-insensitive name pattern.
count_current_files() {
    # Read the file-name pattern.
    local pattern="$1"

    # Find matching files using the exclusion system.
    count_files_matching "$pattern"
}

# Count unique historical files matching a lower-case regular expression.
count_historical_files() {
    # Read the regular expression.
    local pattern="$1"

    # List every path changed in the selected history scope.
    analysis_git_log --name-only --pretty=format: 2>/dev/null |

        # Match paths using a lower-case comparison.
        awk -v regex="$pattern" '
            {
                line = tolower($0)
                if (line ~ regex) {
                    print $0
                }
            }
        ' |

        # Keep unique paths.
        sort -u |

        # Count the unique paths.
        wc -l |

        # Remove whitespace from the count.
        trim_count
}

# Require Git.
command_exists git || die "Git is not installed or is not available in PATH."

# Require execution inside a Git repository.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    die "Run this script from inside a Git repository."

# Resolve the repository root.
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Load directory exclusion management after REPO_ROOT is available.
# shellcheck source=lib/exclusions.sh
source "$SCRIPT_DIR/lib/exclusions.sh"

# Load evidence-based source ownership classification.
# shellcheck source=lib/ownership.sh
source "$SCRIPT_DIR/lib/ownership.sh"

# Resolve the repository name.
REPO_NAME="$(basename "$REPO_ROOT")"

# Record the report generation time.
GENERATED_AT="$(date '+%Y-%m-%d %H:%M:%S')"

# Create a file-safe timestamp.
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"

# Sanitize the repository name.
REPORT_REPO_NAME="$REPO_NAME"
[[ "$PRIVACY_MODE" == strict ]] && REPORT_REPO_NAME='repository'

SAFE_REPO_NAME="$(
    printf '%s' "$REPORT_REPO_NAME" |
        tr ' /\\:' '____' |
        tr -cd '[:alnum:]_.-'
)"

# Build the report folder name.
REPORT_NAME="${SAFE_REPO_NAME}_project_analysis_${TIMESTAMP}"

# Define the report root.
OUTPUT_DIR="$REPO_ROOT/$REPORT_NAME"

# Define the summary folder.
SUMMARY_DIR="$OUTPUT_DIR/summary"

# Define the project-wide analysis folder.
PROJECT_DIR="$OUTPUT_DIR/project"

# Define the Git history and contribution folder.
CONTRIBUTION_DIR="$OUTPUT_DIR/contribution"

# Define the source export folder.
SOURCE_DIR="$OUTPUT_DIR/source"

# Define the structured data folder.
DATA_DIR="$OUTPUT_DIR/data"

# Define the optional graph folder.
GRAPHS_DIR="$OUTPUT_DIR/graphs"

# Define the expected ZIP path.
ZIP_PATH="$REPO_ROOT/${REPORT_NAME}.zip"

DISPLAY_OUTPUT_PATH="$OUTPUT_DIR"
DISPLAY_SUMMARY_PATH="$SUMMARY_DIR"
DISPLAY_ZIP_PATH="$ZIP_PATH"

if [[ "$PRIVACY_MODE" == strict ]]; then
    DISPLAY_OUTPUT_PATH="$REPORT_NAME"
    DISPLAY_SUMMARY_PATH="$REPORT_NAME/summary"
    DISPLAY_ZIP_PATH="${REPORT_NAME}.zip"
fi

# Create the optional Git date-filter array.
DATE_FILTER=()

# Add the start date when provided.
if [[ -n "$SINCE" ]]; then
    # Append the Git start-date option.
    DATE_FILTER+=(--since="$SINCE")
fi

# Add the end date when provided.
if [[ -n "$UNTIL" ]]; then
    # Append the Git end-date option.
    DATE_FILTER+=(--until="$UNTIL")
fi

# Describe whether Git history covers the repository or one contributor.
if [[ -n "$AUTHOR" ]]; then
    HISTORY_SCOPE="Contributor: $AUTHOR"
    HISTORY_HEADING="Selected Author Contribution"
    HISTORY_DESCRIPTION="author-specific Git evidence"
else
    HISTORY_SCOPE="Entire repository"
    HISTORY_HEADING="Repository History"
    HISTORY_DESCRIPTION="repository-wide Git evidence"
fi

# Move to the repository root.
cd "$REPO_ROOT" || die "Could not enter the repository root."

# Detect the project and select its source root.
PROJECT_TYPE="$(detect_project_type)"
CODE_ROOT="$(detect_code_root "$PROJECT_TYPE")"

# Validate the detected source root.
[[ -d "$CODE_ROOT" ]] || die "Code root not found: $CODE_ROOT"

# Collect submodule, assembly-definition, and dependency-manifest signals.
ownership_initialize

# Create all output directories.
mkdir -p \
    "$SUMMARY_DIR" \
    "$PROJECT_DIR/packages" \
    "$CONTRIBUTION_DIR" \
    "$DATA_DIR" \
    "$GRAPHS_DIR" ||
    die "Could not create the report folders."

if [[ "$INCLUDE_SOURCE" == true ]]; then
    mkdir -p \
        "$SOURCE_DIR/reviewable_csharp" \
        "$SOURCE_DIR/likely_project_owned" ||
        die "Could not create the source export folders."
fi

if [[ "$PRIVACY_MODE" == strict ]]; then
    HISTORY_SCOPE='Sanitized Git history'
    HISTORY_DESCRIPTION='sanitized repository history metrics'
fi

if [[ "$PRIVACY_MODE" != strict ]]; then
    mkdir -p \
        "$SOURCE_DIR/project_settings" \
        "$SOURCE_DIR/documentation" ||
        die "Could not create the supporting file folders."
fi

# Print the selected configuration.
echo ""
echo "================================================================"
echo "Project and Career Analysis"
echo "================================================================"
echo "Repository : $REPO_NAME"
echo "Type       : $PROJECT_TYPE"
echo "Git scope  : $HISTORY_SCOPE"
echo "Since      : ${SINCE:-no filter}"
echo "Until      : ${UNTIL:-no filter}"
echo "Code root  : $CODE_ROOT"
echo "Owned roots: ${OWNED_ROOTS[*]:-automatic classification only}"
echo "Source     : $INCLUDE_SOURCE"
echo "Privacy    : $PRIVACY_MODE"
echo "Output     : $DISPLAY_OUTPUT_PATH"
echo "================================================================"
echo ""

# Print the first progress step.
echo "[1/12] Reading repository and project metadata..."

# Read the current branch.
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || true)"

# Read the current commit hash.
HEAD_HASH="$(git rev-parse HEAD 2>/dev/null || true)"

# Read the primary remote URL.
REMOTE_URL="$(git config --get remote.origin.url 2>/dev/null || true)"

if [[ "$PRIVACY_MODE" == strict ]]; then
    CURRENT_BRANCH='[redacted]'
    HEAD_HASH='[redacted]'
    REMOTE_URL='[redacted]'
fi

# Read the Unity editor version when available.
UNITY_VERSION="$(
    if [[ -f ProjectSettings/ProjectVersion.txt ]]; then
        grep '^m_EditorVersion:' ProjectSettings/ProjectVersion.txt |
            sed 's/^m_EditorVersion:[[:space:]]*//'
    else
        printf 'Unknown'
    fi
)"

# Read the Unity product name when available.
PRODUCT_NAME="$(
    if [[ -f ProjectSettings/ProjectSettings.asset ]]; then
        grep '^[[:space:]]*productName:' ProjectSettings/ProjectSettings.asset |
            head -n 1 |
            sed 's/^[[:space:]]*productName:[[:space:]]*//'
    else
        printf '%s' "$REPO_NAME"
    fi
)"

# Read the Unity company name when available.
COMPANY_NAME="$(
    if [[ -f ProjectSettings/ProjectSettings.asset ]]; then
        grep '^[[:space:]]*companyName:' ProjectSettings/ProjectSettings.asset |
            head -n 1 |
            sed 's/^[[:space:]]*companyName:[[:space:]]*//'
    else
        printf 'Unknown'
    fi
)"

DISPLAY_REPO_NAME="$REPO_NAME"
DISPLAY_REPO_ROOT="$REPO_ROOT"
DISPLAY_PRODUCT_NAME="${PRODUCT_NAME:-Unknown}"
DISPLAY_COMPANY_NAME="${COMPANY_NAME:-Unknown}"
DISPLAY_AUTHOR="${AUTHOR:-Not specified}"

if [[ "$PRIVACY_MODE" == strict ]]; then
    DISPLAY_REPO_NAME='repository'
    DISPLAY_REPO_ROOT='[redacted]'
    DISPLAY_PRODUCT_NAME='[redacted]'
    DISPLAY_COMPANY_NAME='[redacted]'
    DISPLAY_AUTHOR='[redacted]'
fi

# Write repository metadata.
cat > "$PROJECT_DIR/00_repository_information.txt" <<EOF
Repository name: $DISPLAY_REPO_NAME
Project type: $PROJECT_TYPE
Product name: $DISPLAY_PRODUCT_NAME
Company name: $DISPLAY_COMPANY_NAME
Repository root: $DISPLAY_REPO_ROOT
Current branch: ${CURRENT_BRANCH:-Detached HEAD or unavailable}
HEAD commit: ${HEAD_HASH:-Unavailable}
Origin remote: ${REMOTE_URL:-Unavailable}
Unity version: ${UNITY_VERSION:-Unknown}
Detected code root: $CODE_ROOT
Generated at: $GENERATED_AT
EOF

# Copy the Unity version file.
if [[ "$PRIVACY_MODE" != strict ]]; then
    cp ProjectSettings/ProjectVersion.txt "$PROJECT_DIR/" 2>/dev/null || true
    cp Packages/manifest.json "$PROJECT_DIR/packages/" 2>/dev/null || true
    cp Packages/packages-lock.json "$PROJECT_DIR/packages/" 2>/dev/null || true
fi

# Print the second progress step.
echo "[2/12] Exporting project structure and asset inventories..."

# Export a project tree without requiring the tree command, respecting exclusions.
analysis_find -type f -print 2>/dev/null |
    sed 's|^\./||' |
    sort \
    > "$PROJECT_DIR/01_folder_tree.txt"

# Export primary source directories.
analysis_find -mindepth 1 -maxdepth 2 -type d -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/02_main_directories.txt"

# Export scenes.
analysis_find -type f -iname '*.unity' -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/03_scenes.txt"

# Export prefabs.
analysis_find -type f -iname '*.prefab' -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/04_prefabs.txt"

# Export animation assets.
analysis_find -type f \( \
        -iname '*.anim' -o \
        -iname '*.controller' -o \
        -iname '*.overrideController' \
    \) -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/05_animation_assets.txt"

# Export shader assets.
analysis_find -type f \( \
        -iname '*.shader' -o \
        -iname '*.hlsl' -o \
        -iname '*.cginc' -o \
        -iname '*.compute' -o \
        -iname '*.shadergraph' \
    \) -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/06_shader_assets.txt"

# Export assembly definitions.
analysis_find -type f \( \
        -iname '*.asmdef' -o \
        -iname '*.asmref' \
    \) -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/07_assembly_definitions.txt"

# Export UI Toolkit assets.
analysis_find -type f \( \
        -iname '*.uxml' -o \
        -iname '*.uss' \
    \) -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/08_ui_toolkit_assets.txt"

# Export Timeline assets.
analysis_find -type f -iname '*.playable' -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/09_timeline_assets.txt"

# Export Resources assets.
analysis_find -type f -path '*/Resources/*' -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/10_resources_assets.txt"

# Export Addressables-related assets.
analysis_find -type f \( \
        -path '*Addressable*' -o \
        -iname '*Addressable*' \
    \) -print 2>/dev/null |
    sort \
    > "$PROJECT_DIR/11_addressables_assets.txt"

# Export likely third-party files.
while IFS= read -r source_file; do
    classify_ownership "$source_file"
    if [[ "$OWNERSHIP_CLASS" == third-party ]]; then
        printf '%s\t%s confidence\t%s\n' \
            "$source_file" "$OWNERSHIP_CONFIDENCE" "$OWNERSHIP_REASON"
    fi
done < <(analysis_find -type f -print 2>/dev/null) |
    sort > "$PROJECT_DIR/12_likely_third_party_files.txt"

# Summarize directory ownership with confidence and supporting evidence.
write_ownership_report "$PROJECT_DIR/12_ownership_classification.txt"

# Print the third progress step.
echo "[3/12] Detecting architecture, systems, and technologies..."

# Detect ScriptableObjects.
analysis_grep \
    --include='*.cs' \
    -InE \
    'CreateAssetMenu|:[[:space:]]*ScriptableObject' \
    > "$PROJECT_DIR/13_scriptable_objects.txt"

# Detect MonoBehaviours.
analysis_grep \
    --include='*.cs' \
    -InE \
    ':[[:space:]]*MonoBehaviour' \
    > "$PROJECT_DIR/14_monobehaviours.txt"

# Detect interfaces.
analysis_grep \
    --include='*.cs' \
    -InE \
    '^[[:space:]]*(public|internal|protected|private)?[[:space:]]*interface[[:space:]]+' \
    > "$PROJECT_DIR/15_interfaces.txt"

# Detect custom editor tooling.
analysis_grep \
    --include='*.cs' \
    -InE \
    'UnityEditor|CustomEditor|PropertyDrawer|EditorWindow|MenuItem' \
    > "$PROJECT_DIR/16_editor_tooling.txt"

# Define system-related keywords.
SYSTEM_KEYWORDS='Player|Character|Movement|Motor|Controller|Camera|Combat|Attack|Weapon|Damage|Health|Ability|Skill|Buff|Debuff|Inventory|Item|Equipment|Quest|Mission|Dialogue|AI|Enemy|NPC|Behavior|State|Pool|Save|Persistence|Database|Network|Multiplayer|Photon|Mirror|Fusion|Netcode|Lobby|Matchmaking|Audio|Music|Localization|Analytics|Telemetry|Achievement|Progress|Tutorial|Onboarding|UI|HUD|Menu|Input|Animation|Timeline|Addressable|Loading|Scene|Spawn|Procedural|Editor|Tool'

# Detect likely gameplay and product-system files by file name.
analysis_find -type f -iname '*.cs' -print 2>/dev/null |
    grep -Ei "$SYSTEM_KEYWORDS" |
    sort \
    > "$PROJECT_DIR/17_likely_system_files.txt" || true

# Detect common architecture patterns.
analysis_grep \
    --include='*.cs' \
    -InE \
    'Singleton|StateMachine|IState|Command|Observer|EventBus|ServiceLocator|DependencyInjection|Factory|Builder|Strategy|ObjectPool|Repository|Mediator|MVC|MVVM|Presenter' \
    > "$PROJECT_DIR/18_architecture_pattern_signals.txt"

# Detect networking technologies.
analysis_grep \
    --include='*.cs' \
    -InEi \
    'Photon|Mirror|Fusion|Netcode|NetworkBehaviour|NetworkObject|RPC|ClientRpc|ServerRpc|Bolt|FishNet|Steamworks' \
    > "$PROJECT_DIR/19_networking_signals.txt"

# Detect backend and data integrations.
analysis_grep \
    --include='*.cs' \
    -InEi \
    'HttpClient|UnityWebRequest|REST|GraphQL|Firebase|Analytics|Telemetry|WebSocket|Socket|API|JsonUtility|Newtonsoft|SQLite|LiteDB|Realm' \
    > "$PROJECT_DIR/20_services_and_data_signals.txt"

# Detect performance-related techniques.
analysis_grep \
    --include='*.cs' \
    -InEi \
    'Profiler|ObjectPool|pooling|Addressables|async|await|Task|JobHandle|BurstCompile|NativeArray|ECS|EntityManager|GC\.Alloc|Resources\.Unload|AssetBundle' \
    > "$PROJECT_DIR/21_performance_signals.txt"

# Detect technical-debt markers.
analysis_grep \
    --include='*.cs' \
    -InE \
    'TODO|FIXME|HACK|XXX' \
    > "$PROJECT_DIR/22_technical_debt_markers.txt"

# Print the fourth progress step.
echo "[4/12] Calculating current project metrics..."

# Count current C# files.
CURRENT_CS_FILES="$(count_current_files '*.cs')"

# Count current scenes.
CURRENT_SCENES="$(count_current_files '*.unity')"

# Count current prefabs.
CURRENT_PREFABS="$(count_current_files '*.prefab')"

# Count current animation clips.
CURRENT_ANIMATIONS="$(count_current_files '*.anim')"

# Count current animator controllers.
CURRENT_CONTROLLERS="$(count_current_files '*.controller')"

# Count current shader files.
CURRENT_SHADERS="$(count_current_files '*.shader')"

# Count current assembly definitions.
CURRENT_ASMDEFS="$(count_current_files '*.asmdef')"

# Count current UXML files.
CURRENT_UXML="$(count_current_files '*.uxml')"

# Count current USS files.
CURRENT_USS="$(count_current_files '*.uss')"

# Count current C# source lines.
CURRENT_CS_LINES="$(
    analysis_find -type f -iname '*.cs' -print0 2>/dev/null |
        xargs -0 cat 2>/dev/null |
        wc -l |
        trim_count
)"

# Export the largest C# files.
analysis_find -type f -iname '*.cs' -exec wc -l {} \; 2>/dev/null |
    sort -rn |
    head -n 150 \
    > "$PROJECT_DIR/23_largest_csharp_files.txt"

# Export C# file counts by directory.
analysis_find -type f -iname '*.cs' -print 2>/dev/null |
    awk -F/ '
        {
            if (NF >= 3) {
                print $1 "/" $2 "/" $3
            } else if (NF >= 2) {
                print $1 "/" $2
            } else {
                print $1
            }
        }
    ' |
    sort |
    uniq -c |
    sort -nr \
    > "$PROJECT_DIR/24_csharp_files_by_directory.txt"

# Write current project metrics.
cat > "$PROJECT_DIR/25_current_project_metrics.txt" <<EOF
Current Project Metrics
=======================

Code root: $CODE_ROOT
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

These values describe the current repository state.
They may include third-party code, imported assets, examples, and generated files.
EOF

# Print the fifth progress step.
echo "[5/12] Applying source export and privacy policy..."

if [[ "$INCLUDE_SOURCE" == true ]]; then
    while IFS= read -r source_file; do
        copy_preserving_path "$source_file" "$SOURCE_DIR/reviewable_csharp"
    done < <(
        analysis_find -type f -iname '*.cs' -print 2>/dev/null |
            while IFS= read -r source_file; do
                ownership_is_reviewable "$source_file" && printf '%s\n' "$source_file"
            done |
            sort
    )

    while IFS= read -r source_file; do
        copy_preserving_path "$source_file" "$SOURCE_DIR/likely_project_owned"
    done < <(
        analysis_find -type f -iname '*.cs' -print 2>/dev/null |
            while IFS= read -r source_file; do
                ownership_is_project_owned "$source_file" && printf '%s\n' "$source_file"
            done |
            sort
    )
fi

if [[ "$PRIVACY_MODE" != strict ]]; then
    git ls-files -z -- 'README*' '*.md' 2>/dev/null |
        while IFS= read -r -d '' documentation_file; do
            copy_preserving_path "$documentation_file" "$SOURCE_DIR/documentation"
        done

    find ProjectSettings -maxdepth 1 -type f \( \
            -iname '*.asset' -o \
            -iname '*.txt' -o \
            -iname '*.json' \
        \) 2>/dev/null |
        while IFS= read -r settings_file; do
            cp "$settings_file" "$SOURCE_DIR/project_settings/"
        done
fi

# Print the sixth progress step.
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
    printf 'Merge commits: %s\n' "${MERGE_COMMITS:-0}" \
        > "$PROJECT_DIR/31_merge_history.txt"
else
    git log --all \
        --merges \
        --date=short \
        --pretty=format:'%ad | %h | %an | %s' 2>/dev/null \
        > "$PROJECT_DIR/31_merge_history.txt" || true
fi

# Print the eighth progress step.
echo "[8/12] Creating Notion-oriented evidence guides..."

# Create the evidence guide.
cat > "$SUMMARY_DIR/01_notion_evidence_guide.md" <<'EOF'
# Notion Evidence Guide

## 📚 About the Project

Review repository information, folder structure, scenes, prefabs, package
manifests, current project metrics, README files, and Unity settings.

Describe the product, audience, goals, platforms, scope, and production context.
Do not infer the complete product purpose from file names alone.

## 🎯 My Mission

Review the contribution summary, complete commit history, system-related commit
subjects, top changed files, and top changed directories.

Combine Git evidence with personal context about responsibilities and ownership.

## 🏗 Major Systems I Contributed To

Review likely system files, architecture signals, networking signals, service
signals, top changed files, top changed directories, and exported source code.

Distinguish systems that merely exist from systems changed in the selected
history scope.

## ⚙ Engineering Contributions

Review architecture signals, performance signals, editor tooling, technical-debt
markers, large scripts, commit history, and source code.

Look for implementation, refactoring, optimization, debugging, tooling,
persistence, integration, platform, release, and production-stability work.

## 🧠 Technologies

Review package manifests, Unity version, assemblies, shaders, UI Toolkit,
Timeline, Addressables, networking, services, databases, editor tooling, and
project settings.

## 🤝 Collaboration

Review contributor lists, merge history, commit history, branches, and known
multidisciplinary team context.

Git can show integration activity, but it cannot fully prove meetings, design
collaboration, mentoring, or stakeholder relationships.

## 🌱 What I Learned

Use project complexity, newly adopted technologies, recurring problems,
refactors, and increasing ownership as evidence.

This section requires personal confirmation and should not be generated from
metrics alone.

## 🚀 Biggest Engineering Achievements

Prefer achievements combining technical difficulty, scope, ownership, reuse,
player or product impact, reliability, performance, and maintainability.

Do not use raw file-touch numbers as achievements without context.

## ⭐ Personal Reflection

Use the evidence to support a personal reflection about growth, values,
decisions, trade-offs, and how the project shaped professional identity.

This section must remain personal rather than sounding like marketing copy.
EOF

# Create a reusable analysis prompt.
cat > "$SUMMARY_DIR/02_analysis_prompt.md" <<'EOF'
# Analysis Request

Analyze this project export and Git history carefully.

Separate:

1. Current project-wide facts
2. Historical contribution signals for the selected history scope
3. Third-party or generated content
4. Evidence-supported conclusions
5. Inferences that must be labeled as inferences
6. Personal reflections that require contributor confirmation

Create a detailed Notion document with:

- 📚 About the Project
- 🎯 My Mission
- 🏗 Major Systems I Contributed To
- ⚙ Engineering Contributions
- 🧠 Technologies
- 🤝 Collaboration
- 🌱 What I Learned
- 🚀 Biggest Engineering Achievements
- ⭐ Personal Reflection

Rules:

- Do not equate files touched with files authored.
- Do not claim imported packages as original work.
- Distinguish current metrics from historical Git change volume.
- Use source code, commits, folders, packages, and settings together.
- Explain uncertainty.
- Prefer concrete systems, decisions, and impact over generic claims.
- Treat the document as personal career journaling.
EOF

# Print the ninth progress step.
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
- \`graphs/\`: optional charts

## Start here

1. \`summary/00_executive_summary.txt\`
2. \`summary/01_notion_evidence_guide.md\`
3. \`summary/02_analysis_prompt.md\`

## Limitations

- Git change volume is not exclusive authorship.
- Ownership confidence is evidence-based but still requires human review.
- Product purpose and personal learning require human context.
- Review confidential content before sharing.
EOF

# Print the tenth progress step.
echo "[10/12] Creating optional charts..."

# Create charts only when detailed, non-strict commit data exists.
if [[ "$TOTAL_COMMITS" -gt 0 && "$PRIVACY_MODE" != strict ]]; then
    # Write the Python chart generator.
    cat > "$OUTPUT_DIR/generate_graphs.py" <<'PYTHON'
from __future__ import annotations

import csv
import sys
from collections import Counter
from pathlib import Path


def load_commits(csv_path: Path) -> tuple[Counter[str], Counter[str]]:
    months: Counter[str] = Counter()
    years: Counter[str] = Counter()

    with csv_path.open("r", newline="", encoding="utf-8") as file:
        reader = csv.DictReader(file)

        for row in reader:
            date = (row.get("Date") or "").strip()

            if len(date) < 7:
                continue

            months[date[:7]] += 1
            years[date[:4]] += 1

    return months, years


def save_chart(
    labels: list[str],
    values: list[int],
    title: str,
    output_path: Path,
) -> None:
    import matplotlib.pyplot as plt

    if not labels:
        return

    width = max(9.0, min(22.0, len(labels) * 0.55))

    plt.figure(figsize=(width, 5.5))
    plt.bar(labels, values)
    plt.title(title)
    plt.xlabel("Period")
    plt.ylabel("Commits")
    plt.xticks(rotation=60, ha="right")
    plt.tight_layout()
    plt.savefig(output_path, dpi=160)
    plt.close()


def main() -> int:
    try:
        import matplotlib  # noqa: F401
    except ImportError:
        print("matplotlib is unavailable; charts were skipped.")
        return 0

    base = Path(__file__).resolve().parent
    graphs = base / "graphs"
    graphs.mkdir(parents=True, exist_ok=True)

    months, years = load_commits(base / "data" / "history_commits.csv")

    month_labels = sorted(months)
    year_labels = sorted(years)

    save_chart(
        month_labels,
        [months[label] for label in month_labels],
        "Commits by Month",
        graphs / "commits_by_month.png",
    )

    save_chart(
        year_labels,
        [years[label] for label in year_labels],
        "Commits by Year",
        graphs / "commits_by_year.png",
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())
PYTHON

    # Run the chart generator when dependencies exist.
    if command_exists python3 &&
       python3 -c 'import matplotlib' >/dev/null 2>&1; then
        # Generate charts without failing the complete report.
        python3 "$OUTPUT_DIR/generate_graphs.py" || true
    else
        # Explain why charts were skipped.
        echo "Optional charts skipped because Python 3 or matplotlib is unavailable."
    fi
fi

# Print the eleventh progress step.
echo "[11/12] Scanning privacy and creating the archive..."

PRIVACY_SCAN_FAILED=false
sanitize_strict_reports
run_privacy_scan

if [[ "$PRIVACY_SCAN_FAILED" == true ]]; then
    echo "Warning: archive creation blocked by the privacy scan."
    echo "Review summary/03_privacy_scan.txt before compressing the report."
else

# Remove an older archive with the same name.
rm -f "$ZIP_PATH"

# Use zip when available.
if command_exists zip; then
    # Create a ZIP with a clean top-level folder.
    (
        cd "$REPO_ROOT" &&
        zip -qr "$ZIP_PATH" "$REPORT_NAME"
    ) || echo "Warning: zip could not create the archive."

# Use PowerShell from Git Bash on Windows.
elif command_exists powershell.exe && command_exists cygpath; then
    # Convert the report path to Windows format.
    WINDOWS_OUTPUT="$(cygpath -aw "$OUTPUT_DIR")"

    # Convert the ZIP path to Windows format.
    WINDOWS_ZIP="$(cygpath -aw "$ZIP_PATH")"

    # Create the archive with PowerShell.
    powershell.exe -NoProfile -Command \
        "Compress-Archive -LiteralPath '$WINDOWS_OUTPUT' -DestinationPath '$WINDOWS_ZIP' -Force" \
        >/dev/null 2>&1 ||
        echo "Warning: PowerShell could not create the archive."

# Use tar.gz as a final portable fallback.
elif command_exists tar; then
    # Define the tar.gz path.
    TAR_PATH="$REPO_ROOT/${REPORT_NAME}.tar.gz"

    # Create the tar.gz archive.
    (
        cd "$REPO_ROOT" &&
        tar -czf "$TAR_PATH" "$REPORT_NAME"
    ) || echo "Warning: tar could not create the archive."

# Keep the report folder when no archive tool exists.
else
    # Explain that manual compression is still possible.
    echo "No supported archive command was found."
    echo "The report folder was generated and can be compressed manually."
fi
fi

# Print the twelfth progress step.
echo "[12/12] Finalizing..."

# Print a completion banner.
echo ""
echo "================================================================"
echo "Analysis export completed"
echo "================================================================"

# Print the report folder path.
echo "Report folder:"
echo "  $DISPLAY_OUTPUT_PATH"
echo ""

# Print the ZIP path when present.
if [[ -f "$ZIP_PATH" ]]; then
    echo "ZIP archive:"
    echo "  $DISPLAY_ZIP_PATH"
    echo ""
fi

# Print the tar.gz path when present.
if [[ -n "${TAR_PATH:-}" && -f "${TAR_PATH:-}" ]]; then
    DISPLAY_TAR_PATH="$TAR_PATH"
    [[ "$PRIVACY_MODE" == strict ]] && DISPLAY_TAR_PATH="${TAR_PATH##*/}"
    echo "TAR.GZ archive:"
    echo "  $DISPLAY_TAR_PATH"
    echo ""
fi

# Print the main starting point.
echo "Start here:"
echo "  $DISPLAY_SUMMARY_PATH/00_executive_summary.txt"
echo ""

# Print the Notion guide path.
echo "Notion guide:"
echo "  $DISPLAY_SUMMARY_PATH/01_notion_evidence_guide.md"
echo ""

# Print the reusable analysis prompt path.
echo "Analysis prompt:"
echo "  $DISPLAY_SUMMARY_PATH/02_analysis_prompt.md"
echo ""

# Print the privacy reminder.
echo "Review confidential code, e-mails, URLs, credentials, and client names"
echo "before sharing the generated package."
echo "================================================================"
