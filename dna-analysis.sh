#!/usr/bin/env bash

# Fail when an undefined variable is used.
set -u

# Fail a pipeline when any command inside it fails.
set -o pipefail

# Read the required Git author filter.
AUTHOR="${1:-}"

# Read the optional contribution start date.
SINCE="${2:-}"

# Read the optional contribution end date.
UNTIL="${3:-}"

# Read the optional Unity source root.
CODE_ROOT="${4:-Assets}"

# Define common Unity-generated directories that must be ignored.
IGNORED_DIRS=(Library Logs Temp Obj Build Builds UserSettings MemoryCaptures .git)

# Define common third-party folder names.
THIRD_PARTY_REGEX='(^|/)(Plugins|ThirdParty|Third-Party|External|Vendor|SDK|AssetStore|AssetsStore|Packages)(/|$)'

# Print an error and stop execution.
die() {
    # Print a blank line.
    echo ""

    # Print the error message to stderr.
    echo "Error: $1" >&2

    # Exit with a failure code.
    exit 1
}

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

# Execute git log using the configured author and date filters.
author_git_log() {
    # Query all branches and tags for the selected author.
    git log --all --author="$AUTHOR" "${DATE_FILTER[@]}" "$@"
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

# Count current files matching a case-insensitive name pattern.
count_current_files() {
    # Read the file-name pattern.
    local pattern="$1"

    # Find matching files under the configured source root.
    find "$CODE_ROOT" -type f -iname "$pattern" 2>/dev/null |

        # Count the results.
        wc -l |

        # Remove whitespace from the count.
        trim_count
}

# Count unique historical files matching a lower-case regular expression.
count_historical_files() {
    # Read the regular expression.
    local pattern="$1"

    # List every path changed by the selected author.
    author_git_log --name-only --pretty=format: 2>/dev/null |

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

# Require an author filter.
if [[ -z "$AUTHOR" ]]; then
    # Print usage information.
    echo "Usage:"
    echo "  bash dna-analysis.sh \"Author name or e-mail\""
    echo ""
    echo "Optional date range:"
    echo "  bash dna-analysis.sh \"Author\" \"2017-01-01\" \"2022-12-31\""
    echo ""
    echo "Optional custom code root:"
    echo "  bash dna-analysis.sh \"Author\" \"\" \"\" \"Assets/_Project\""
    echo ""
    echo "Inspect available authors with:"
    echo "  git shortlog -sne --all"

    # Stop because the required argument is missing.
    exit 1
fi

# Resolve the repository root.
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Resolve the repository name.
REPO_NAME="$(basename "$REPO_ROOT")"

# Record the report generation time.
GENERATED_AT="$(date '+%Y-%m-%d %H:%M:%S')"

# Create a file-safe timestamp.
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"

# Sanitize the repository name.
SAFE_REPO_NAME="$(
    printf '%s' "$REPO_NAME" |
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

# Define the author contribution folder.
CONTRIBUTION_DIR="$OUTPUT_DIR/contribution"

# Define the source export folder.
SOURCE_DIR="$OUTPUT_DIR/source"

# Define the structured data folder.
DATA_DIR="$OUTPUT_DIR/data"

# Define the optional graph folder.
GRAPHS_DIR="$OUTPUT_DIR/graphs"

# Define the expected ZIP path.
ZIP_PATH="$REPO_ROOT/${REPORT_NAME}.zip"

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

# Move to the repository root.
cd "$REPO_ROOT" || die "Could not enter the repository root."

# Validate the configured source root.
[[ -d "$CODE_ROOT" ]] || die "Code root not found: $CODE_ROOT"

# Create all output directories.
mkdir -p \
    "$SUMMARY_DIR" \
    "$PROJECT_DIR/packages" \
    "$CONTRIBUTION_DIR" \
    "$SOURCE_DIR/all_csharp" \
    "$SOURCE_DIR/likely_project_owned" \
    "$SOURCE_DIR/project_settings" \
    "$SOURCE_DIR/documentation" \
    "$DATA_DIR" \
    "$GRAPHS_DIR" ||
    die "Could not create the report folders."

# Print the selected configuration.
echo ""
echo "================================================================"
echo "Unity Project and Career Analysis"
echo "================================================================"
echo "Repository : $REPO_NAME"
echo "Author     : $AUTHOR"
echo "Since      : ${SINCE:-no filter}"
echo "Until      : ${UNTIL:-no filter}"
echo "Code root  : $CODE_ROOT"
echo "Output     : $OUTPUT_DIR"
echo "================================================================"
echo ""

# Print the first progress step.
echo "[1/12] Reading repository and Unity metadata..."

# Read the current branch.
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || true)"

# Read the current commit hash.
HEAD_HASH="$(git rev-parse HEAD 2>/dev/null || true)"

# Read the primary remote URL.
REMOTE_URL="$(git config --get remote.origin.url 2>/dev/null || true)"

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

# Write repository metadata.
cat > "$PROJECT_DIR/00_repository_information.txt" <<EOF
Repository name: $REPO_NAME
Product name: ${PRODUCT_NAME:-Unknown}
Company name: ${COMPANY_NAME:-Unknown}
Repository root: $REPO_ROOT
Current branch: ${CURRENT_BRANCH:-Detached HEAD or unavailable}
HEAD commit: ${HEAD_HASH:-Unavailable}
Origin remote: ${REMOTE_URL:-Unavailable}
Unity version: ${UNITY_VERSION:-Unknown}
Configured code root: $CODE_ROOT
Generated at: $GENERATED_AT
EOF

# Copy the Unity version file.
cp ProjectSettings/ProjectVersion.txt "$PROJECT_DIR/" 2>/dev/null || true

# Copy the package manifest.
cp Packages/manifest.json "$PROJECT_DIR/packages/" 2>/dev/null || true

# Copy the package lock file.
cp Packages/packages-lock.json "$PROJECT_DIR/packages/" 2>/dev/null || true

# Print the second progress step.
echo "[2/12] Exporting project structure and asset inventories..."

# Export a project tree without requiring the tree command.
find . \
    -type d \( \
        -name Library -o \
        -name Logs -o \
        -name Temp -o \
        -name Obj -o \
        -name Build -o \
        -name Builds -o \
        -name UserSettings -o \
        -name MemoryCaptures -o \
        -name .git -o \
        -name "$REPORT_NAME" \
    \) -prune -o \
    -print 2>/dev/null |
    sed 's|^\./||' |
    sort \
    > "$PROJECT_DIR/01_folder_tree.txt"

# Export primary source directories.
find "$CODE_ROOT" -mindepth 1 -maxdepth 2 -type d 2>/dev/null |
    sort \
    > "$PROJECT_DIR/02_main_directories.txt"

# Export scenes.
find "$CODE_ROOT" -type f -iname '*.unity' 2>/dev/null |
    sort \
    > "$PROJECT_DIR/03_scenes.txt"

# Export prefabs.
find "$CODE_ROOT" -type f -iname '*.prefab' 2>/dev/null |
    sort \
    > "$PROJECT_DIR/04_prefabs.txt"

# Export animation assets.
find "$CODE_ROOT" -type f \( \
        -iname '*.anim' -o \
        -iname '*.controller' -o \
        -iname '*.overrideController' \
    \) 2>/dev/null |
    sort \
    > "$PROJECT_DIR/05_animation_assets.txt"

# Export shader assets.
find "$CODE_ROOT" -type f \( \
        -iname '*.shader' -o \
        -iname '*.hlsl' -o \
        -iname '*.cginc' -o \
        -iname '*.compute' -o \
        -iname '*.shadergraph' \
    \) 2>/dev/null |
    sort \
    > "$PROJECT_DIR/06_shader_assets.txt"

# Export assembly definitions.
find "$CODE_ROOT" -type f \( \
        -iname '*.asmdef' -o \
        -iname '*.asmref' \
    \) 2>/dev/null |
    sort \
    > "$PROJECT_DIR/07_assembly_definitions.txt"

# Export UI Toolkit assets.
find "$CODE_ROOT" -type f \( \
        -iname '*.uxml' -o \
        -iname '*.uss' \
    \) 2>/dev/null |
    sort \
    > "$PROJECT_DIR/08_ui_toolkit_assets.txt"

# Export Timeline assets.
find "$CODE_ROOT" -type f -iname '*.playable' 2>/dev/null |
    sort \
    > "$PROJECT_DIR/09_timeline_assets.txt"

# Export Resources assets.
find "$CODE_ROOT" -type f -path '*/Resources/*' 2>/dev/null |
    sort \
    > "$PROJECT_DIR/10_resources_assets.txt"

# Export Addressables-related assets.
find "$CODE_ROOT" -type f \( \
        -path '*Addressable*' -o \
        -iname '*Addressable*' \
    \) 2>/dev/null |
    sort \
    > "$PROJECT_DIR/11_addressables_assets.txt"

# Export likely third-party files.
find "$CODE_ROOT" -type f 2>/dev/null |
    awk -v regex="$THIRD_PARTY_REGEX" '$0 ~ regex' |
    sort \
    > "$PROJECT_DIR/12_likely_third_party_files.txt"

# Print the third progress step.
echo "[3/12] Detecting architecture, systems, and technologies..."

# Detect ScriptableObjects.
grep -RInE \
    --include='*.cs' \
    'CreateAssetMenu|:[[:space:]]*ScriptableObject' \
    "$CODE_ROOT" 2>/dev/null \
    > "$PROJECT_DIR/13_scriptable_objects.txt" || true

# Detect MonoBehaviours.
grep -RInE \
    --include='*.cs' \
    ':[[:space:]]*MonoBehaviour' \
    "$CODE_ROOT" 2>/dev/null \
    > "$PROJECT_DIR/14_monobehaviours.txt" || true

# Detect interfaces.
grep -RInE \
    --include='*.cs' \
    '^[[:space:]]*(public|internal|protected|private)?[[:space:]]*interface[[:space:]]+' \
    "$CODE_ROOT" 2>/dev/null \
    > "$PROJECT_DIR/15_interfaces.txt" || true

# Detect custom editor tooling.
grep -RInE \
    --include='*.cs' \
    'UnityEditor|CustomEditor|PropertyDrawer|EditorWindow|MenuItem' \
    "$CODE_ROOT" 2>/dev/null \
    > "$PROJECT_DIR/16_editor_tooling.txt" || true

# Define system-related keywords.
SYSTEM_KEYWORDS='Player|Character|Movement|Motor|Controller|Camera|Combat|Attack|Weapon|Damage|Health|Ability|Skill|Buff|Debuff|Inventory|Item|Equipment|Quest|Mission|Dialogue|AI|Enemy|NPC|Behavior|State|Pool|Save|Persistence|Database|Network|Multiplayer|Photon|Mirror|Fusion|Netcode|Lobby|Matchmaking|Audio|Music|Localization|Analytics|Telemetry|Achievement|Progress|Tutorial|Onboarding|UI|HUD|Menu|Input|Animation|Timeline|Addressable|Loading|Scene|Spawn|Procedural|Editor|Tool'

# Detect likely gameplay and product-system files by file name.
find "$CODE_ROOT" -type f -iname '*.cs' 2>/dev/null |
    grep -Ei "$SYSTEM_KEYWORDS" |
    sort \
    > "$PROJECT_DIR/17_likely_system_files.txt" || true

# Detect common architecture patterns.
grep -RInE \
    --include='*.cs' \
    'Singleton|StateMachine|IState|Command|Observer|EventBus|ServiceLocator|DependencyInjection|Factory|Builder|Strategy|ObjectPool|Repository|Mediator|MVC|MVVM|Presenter' \
    "$CODE_ROOT" 2>/dev/null \
    > "$PROJECT_DIR/18_architecture_pattern_signals.txt" || true

# Detect networking technologies.
grep -RInEi \
    --include='*.cs' \
    'Photon|Mirror|Fusion|Netcode|NetworkBehaviour|NetworkObject|RPC|ClientRpc|ServerRpc|Bolt|FishNet|Steamworks' \
    "$CODE_ROOT" 2>/dev/null \
    > "$PROJECT_DIR/19_networking_signals.txt" || true

# Detect backend and data integrations.
grep -RInEi \
    --include='*.cs' \
    'HttpClient|UnityWebRequest|REST|GraphQL|Firebase|Analytics|Telemetry|WebSocket|Socket|API|JsonUtility|Newtonsoft|SQLite|LiteDB|Realm' \
    "$CODE_ROOT" 2>/dev/null \
    > "$PROJECT_DIR/20_services_and_data_signals.txt" || true

# Detect performance-related techniques.
grep -RInEi \
    --include='*.cs' \
    'Profiler|ObjectPool|pooling|Addressables|async|await|Task|JobHandle|BurstCompile|NativeArray|ECS|EntityManager|GC\.Alloc|Resources\.Unload|AssetBundle' \
    "$CODE_ROOT" 2>/dev/null \
    > "$PROJECT_DIR/21_performance_signals.txt" || true

# Detect technical-debt markers.
grep -RInE \
    --include='*.cs' \
    'TODO|FIXME|HACK|XXX' \
    "$CODE_ROOT" 2>/dev/null \
    > "$PROJECT_DIR/22_technical_debt_markers.txt" || true

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
    find "$CODE_ROOT" -type f -iname '*.cs' -print0 2>/dev/null |
        xargs -0 cat 2>/dev/null |
        wc -l |
        trim_count
)"

# Export the largest C# files.
find "$CODE_ROOT" -type f -iname '*.cs' -exec wc -l {} \; 2>/dev/null |
    sort -rn |
    head -n 150 \
    > "$PROJECT_DIR/23_largest_csharp_files.txt"

# Export C# file counts by directory.
find "$CODE_ROOT" -type f -iname '*.cs' 2>/dev/null |
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
echo "[5/12] Exporting source code for detailed review..."

# Copy all current C# files.
while IFS= read -r source_file; do
    # Preserve the original project path.
    copy_preserving_path "$source_file" "$SOURCE_DIR/all_csharp"
done < <(
    find "$CODE_ROOT" -type f -iname '*.cs' 2>/dev/null |
        sort
)

# Copy likely project-owned C# files.
while IFS= read -r source_file; do
    # Preserve the original project path.
    copy_preserving_path "$source_file" "$SOURCE_DIR/likely_project_owned"
done < <(
    find "$CODE_ROOT" -type f -iname '*.cs' 2>/dev/null |
        awk -v regex="$THIRD_PARTY_REGEX" '$0 !~ regex' |
        sort
)

# Copy root documentation.
find . -maxdepth 2 -type f \( \
        -iname 'README*' -o \
        -iname '*.md' \
    \) 2>/dev/null |
    while IFS= read -r documentation_file; do
        # Preserve the original documentation path.
        copy_preserving_path "$documentation_file" "$SOURCE_DIR/documentation"
    done

# Copy useful Unity project settings.
find ProjectSettings -maxdepth 1 -type f \( \
        -iname '*.asset' -o \
        -iname '*.txt' -o \
        -iname '*.json' \
    \) 2>/dev/null |
    while IFS= read -r settings_file; do
        # Copy the settings file.
        cp "$settings_file" "$SOURCE_DIR/project_settings/"
    done

# Print the sixth progress step.
echo "[6/12] Calculating author-specific Git contribution metrics..."

# Count commits matching the author filter.
TOTAL_COMMITS="$(
    author_git_log --pretty=format:'%H' 2>/dev/null |
        awk 'NF { count++ } END { print count + 0 }'
)"

# Handle repositories where the author filter matches no commits.
if [[ "$TOTAL_COMMITS" -eq 0 ]]; then
    # Write an explanatory report.
    cat > "$CONTRIBUTION_DIR/00_no_matching_author.txt" <<EOF
No commits matched the author filter: $AUTHOR

Inspect available authors with:
git shortlog -sne --all

The project-wide analysis was still generated successfully.
EOF
else
    # Read the first matching commit.
    FIRST_COMMIT="$(
        author_git_log \
            --reverse \
            --date=short \
            --pretty=format:'%ad | %h | %an <%ae> | %s' 2>/dev/null |
            head -n 1
    )"

    # Read the last matching commit.
    LAST_COMMIT="$(
        author_git_log \
            --date=short \
            --pretty=format:'%ad | %h | %an <%ae> | %s' 2>/dev/null |
            head -n 1
    )"

    # Read the first contribution date.
    FIRST_DATE="$(
        author_git_log \
            --reverse \
            --date=short \
            --pretty=format:'%ad' 2>/dev/null |
            head -n 1
    )"

    # Read the last contribution date.
    LAST_DATE="$(
        author_git_log \
            --date=short \
            --pretty=format:'%ad' 2>/dev/null |
            head -n 1
    )"

    # Count active contribution days.
    ACTIVE_DAYS="$(
        author_git_log \
            --date=short \
            --pretty=format:'%ad' 2>/dev/null |
            sort -u |
            awk 'NF { count++ } END { print count + 0 }'
    )"

    # Count unique historical paths changed.
    UNIQUE_FILES="$(
        author_git_log \
            --name-only \
            --pretty=format: 2>/dev/null |
            awk 'NF' |
            sort -u |
            awk 'NF { count++ } END { print count + 0 }'
    )"

    # Calculate historical line-change volume.
    read -r LINES_ADDED LINES_REMOVED NET_LINES <<EOF
$(
        author_git_log \
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
        author_git_log --merges --pretty=format:'%H' 2>/dev/null |
            awk 'NF { count++ } END { print count + 0 }'
    )"

    # Count non-merge commits.
    NON_MERGE_COMMITS="$(
        author_git_log --no-merges --pretty=format:'%H' 2>/dev/null |
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
        author_git_log --name-only --pretty=format: 2>/dev/null |
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
Author Contribution Summary
===========================

Author filter: $AUTHOR
Since: ${SINCE:-Not specified}
Until: ${UNTIL:-Not specified}

First matching commit:
$FIRST_COMMIT

Last matching commit:
$LAST_COMMIT

First contribution date: ${FIRST_DATE:-N/A}
Last contribution date: ${LAST_DATE:-N/A}
Active contribution days: $ACTIVE_DAYS

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

    # Export readable commit history.
    author_git_log \
        --date=iso-strict \
        --pretty=format:'%ad | %h | %an <%ae> | %s' 2>/dev/null \
        > "$CONTRIBUTION_DIR/01_commits.txt"

    # Export commit history as CSV.
    {
        # Write the CSV header.
        echo "Date,Hash,FullHash,AuthorName,AuthorEmail,Subject"

        # Convert Git records into escaped CSV rows.
        author_git_log \
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
    } > "$DATA_DIR/author_commits.csv"

    # Count commits by year.
    author_git_log \
        --date=format:'%Y' \
        --pretty=format:'%ad' 2>/dev/null |
        sort |
        uniq -c |
        awk '{ print $2 "\t" $1 }' \
        > "$CONTRIBUTION_DIR/02_commits_by_year.txt"

    # Count commits by month.
    author_git_log \
        --date=format:'%Y-%m' \
        --pretty=format:'%ad' 2>/dev/null |
        sort |
        uniq -c |
        awk '{ print $2 "\t" $1 }' \
        > "$CONTRIBUTION_DIR/03_commits_by_month.txt"

    # Rank changed files.
    author_git_log --name-only --pretty=format: 2>/dev/null |
        awk 'NF' |
        sort |
        uniq -c |
        sort -nr \
        > "$CONTRIBUTION_DIR/04_top_changed_files.txt"

    # Rank changed directories.
    author_git_log --name-only --pretty=format: 2>/dev/null |
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
    author_git_log --name-only --pretty=format: 2>/dev/null |
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

    # Export system-related commit subjects.
    author_git_log --pretty=format:'%s' 2>/dev/null |
        grep -Ei "$SYSTEM_KEYWORDS" |
        sort \
        > "$CONTRIBUTION_DIR/07_system_related_commit_subjects.txt" || true
fi

# Print the seventh progress step.
echo "[7/12] Exporting collaboration and repository history..."

# Export all contributors.
git shortlog -sne --all \
    > "$PROJECT_DIR/26_all_contributors.txt" 2>/dev/null || true

# Export all branches.
git branch -a \
    > "$PROJECT_DIR/27_branches.txt" 2>/dev/null || true

# Export all tags.
git tag --sort=-creatordate \
    > "$PROJECT_DIR/28_tags.txt" 2>/dev/null || true

# Export remotes.
git remote -v \
    > "$PROJECT_DIR/29_remotes.txt" 2>/dev/null || true

# Export repository status.
git status --short --branch \
    > "$PROJECT_DIR/30_repository_status.txt" 2>/dev/null || true

# Export merge history.
git log --all \
    --merges \
    --date=short \
    --pretty=format:'%ad | %h | %an | %s' 2>/dev/null \
    > "$PROJECT_DIR/31_merge_history.txt" || true

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

Distinguish systems that merely exist from systems the selected author changed.

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

Analyze this Unity project export and Git history carefully.

Separate:

1. Current project-wide facts
2. Historical contribution signals for the selected author
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

# Build the author-summary fragment.
if [[ "$TOTAL_COMMITS" -gt 0 ]]; then
    # Include author metrics.
    CONTRIBUTION_TEXT="Total commits: $TOTAL_COMMITS
Active contribution days: $ACTIVE_DAYS
First contribution date: ${FIRST_DATE:-N/A}
Last contribution date: ${LAST_DATE:-N/A}
Historical C# paths changed: $HISTORICAL_CS_FILES
Historical Unity-related paths changed: $HISTORICAL_UNITY_FILES
Historical scenes changed: $HISTORICAL_SCENES
Historical prefabs changed: $HISTORICAL_PREFABS"
else
    # Explain the missing author match.
    CONTRIBUTION_TEXT="No commits matched the author filter: $AUTHOR"
fi

# Write the executive summary.
cat > "$SUMMARY_DIR/00_executive_summary.txt" <<EOF
Unity Project and Career Analysis
=================================

Project
-------
Repository: $REPO_NAME
Product name: ${PRODUCT_NAME:-Unknown}
Company name: ${COMPANY_NAME:-Unknown}
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

Selected Author Contribution
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
9. source/likely_project_owned/
10. summary/02_analysis_prompt.md

Warnings
--------
Review confidential source code, commit messages, e-mails, URLs, client names,
tokens, and credentials before sharing this archive.

Current project metrics and historical contribution metrics measure different
things. Files touched are not the same as files authored.
EOF

# Escape JSON values.
JSON_REPO="$(json_escape "$REPO_NAME")"
JSON_PRODUCT="$(json_escape "${PRODUCT_NAME:-Unknown}")"
JSON_COMPANY="$(json_escape "${COMPANY_NAME:-Unknown}")"
JSON_AUTHOR="$(json_escape "$AUTHOR")"
JSON_GENERATED="$(json_escape "$GENERATED_AT")"
JSON_UNITY="$(json_escape "${UNITY_VERSION:-Unknown}")"

# Write project JSON.
cat > "$DATA_DIR/project_summary.json" <<EOF
{
  "repository": "$JSON_REPO",
  "product_name": "$JSON_PRODUCT",
  "company_name": "$JSON_COMPANY",
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

# Write the main README.
cat > "$OUTPUT_DIR/README.md" <<EOF
# Unity Project and Career Analysis

**Repository:** $REPO_NAME  
**Product:** ${PRODUCT_NAME:-Unknown}  
**Selected author:** $AUTHOR  
**Unity version:** ${UNITY_VERSION:-Unknown}  
**Generated:** $GENERATED_AT

## Purpose

This package combines a current Unity project review, an author-specific Git
contribution report, source-code export, collaboration evidence, and a Notion
career-journaling guide.

## Main folders

- \`summary/\`: executive summary and Notion analysis guides
- \`project/\`: current project structure, systems, and technologies
- \`contribution/\`: author-specific Git evidence
- \`source/all_csharp/\`: all current C# source
- \`source/likely_project_owned/\`: source excluding common vendor folders
- \`source/project_settings/\`: selected Unity settings
- \`data/\`: JSON and CSV exports
- \`graphs/\`: optional charts

## Start here

1. \`summary/00_executive_summary.txt\`
2. \`summary/01_notion_evidence_guide.md\`
3. \`summary/02_analysis_prompt.md\`

## Limitations

- Git change volume is not exclusive authorship.
- Third-party-folder detection is heuristic.
- Product purpose and personal learning require human context.
- Review confidential content before sharing.
EOF

# Print the tenth progress step.
echo "[10/12] Creating optional charts..."

# Create charts only when author commit data exists.
if [[ "$TOTAL_COMMITS" -gt 0 ]]; then
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

    months, years = load_commits(base / "data" / "author_commits.csv")

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
echo "[11/12] Creating the archive..."

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

# Print the twelfth progress step.
echo "[12/12] Finalizing..."

# Print a completion banner.
echo ""
echo "================================================================"
echo "Analysis export completed"
echo "================================================================"

# Print the report folder path.
echo "Report folder:"
echo "  $OUTPUT_DIR"
echo ""

# Print the ZIP path when present.
if [[ -f "$ZIP_PATH" ]]; then
    echo "ZIP archive:"
    echo "  $ZIP_PATH"
    echo ""
fi

# Print the tar.gz path when present.
if [[ -n "${TAR_PATH:-}" && -f "${TAR_PATH:-}" ]]; then
    echo "TAR.GZ archive:"
    echo "  $TAR_PATH"
    echo ""
fi

# Print the main starting point.
echo "Start here:"
echo "  $SUMMARY_DIR/00_executive_summary.txt"
echo ""

# Print the Notion guide path.
echo "Notion guide:"
echo "  $SUMMARY_DIR/01_notion_evidence_guide.md"
echo ""

# Print the reusable analysis prompt path.
echo "Analysis prompt:"
echo "  $SUMMARY_DIR/02_analysis_prompt.md"
echo ""

# Print the privacy reminder.
echo "Review confidential code, e-mails, URLs, credentials, and client names"
echo "before sharing the generated package."
echo "================================================================"
