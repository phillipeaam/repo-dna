initialize_analysis_context() {
# Require Git.
command_exists git || die "Git is not installed or is not available in PATH." 3

if [[ -n "$PORTFOLIO_PROFILE" ]]; then
    [[ -f "$PORTFOLIO_PROFILE" ]] || die "Portfolio profile not found: $PORTFOLIO_PROFILE"
    PORTFOLIO_PROFILE="$(cd "$(dirname "$PORTFOLIO_PROFILE")" && pwd)/$(basename "$PORTFOLIO_PROFILE")"
fi
if [[ -n "$COMPARE_WITH" ]]; then
    [[ -f "$COMPARE_WITH" ]] || die "Comparison snapshot not found: $COMPARE_WITH"
    COMPARE_WITH="$(cd "$(dirname "$COMPARE_WITH")" && pwd)/$(basename "$COMPARE_WITH")"
fi

# Resolve Python once so collectors, renderers, and charts use the same runtime.
STRUCTURED_PYTHON="$(resolve_python_runtime || true)"
PARTIAL_ANALYSIS=false
if [[ -n "$STRUCTURED_PYTHON" ]] && ! "$STRUCTURED_PYTHON" -c 'import jsonschema' >/dev/null 2>&1; then
    printf '%s\n' 'Warning: the recommended JSON Schema module was not found.' >&2
    printf '%s\n' "  Install with: $STRUCTURED_PYTHON -m pip install -r $SCRIPT_DIR/requirements-reporting.txt" >&2
    STRUCTURED_PYTHON=''
fi
if [[ -z "$STRUCTURED_PYTHON" ]]; then
    PARTIAL_ANALYSIS=true
    printf '%s\n' 'Warning: the recommended Python reporting runtime is unavailable. Structured analysis will be skipped.' >&2
    printf '%s\n' '  Install Python 3.11+ and requirements-reporting.txt, or set REPO_DNA_PYTHON.' >&2
fi

# Require execution inside a Git repository.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    die "Run this script from inside a Git repository."

# Resolve the repository root.
REPO_ROOT="$(git rev-parse --show-toplevel)"

if [[ -n "$IGNORE_FILE" ]]; then
    IGNORE_FILE="$(normalize_repository_path "$IGNORE_FILE")"
    [[ "$IGNORE_FILE" == /* ]] || IGNORE_FILE="$REPO_ROOT/$IGNORE_FILE"
    [[ -f "$IGNORE_FILE" ]] || die "Ignore file not found: $IGNORE_FILE" 2
fi

if [[ -z "$FORGE_DATA" && -f "$REPO_ROOT/.repodna/forge-data.json" ]]; then
    FORGE_DATA="$REPO_ROOT/.repodna/forge-data.json"
elif [[ -n "$FORGE_DATA" ]]; then
    [[ -f "$FORGE_DATA" ]] || die "Forge data file not found: $FORGE_DATA"
    FORGE_DATA="$(cd "$(dirname "$FORGE_DATA")" && pwd)/$(basename "$FORGE_DATA")"
fi

# Load directory exclusion management after REPO_ROOT is available.
# shellcheck source=src/core/exclusions.sh
source "$SCRIPT_DIR/src/core/exclusions.sh"

# Load evidence-based source ownership classification.
# shellcheck source=src/core/ownership.sh
source "$SCRIPT_DIR/src/core/ownership.sh"

# Load sensitive-data detection without exposing matched values.
# shellcheck source=src/core/security.sh
source "$SCRIPT_DIR/src/core/security.sh"

# Load canonical JSON report collection.
# shellcheck source=src/reports/json.sh
source "$SCRIPT_DIR/src/reports/json.sh"

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
if [[ -n "$OUTPUT_OVERRIDE" ]]; then
    OUTPUT_OVERRIDE="$(normalize_repository_path "$OUTPUT_OVERRIDE")"
    [[ "$OUTPUT_OVERRIDE" == /* ]] || OUTPUT_OVERRIDE="$REPO_ROOT/$OUTPUT_OVERRIDE"
    [[ ! -e "$OUTPUT_OVERRIDE" ]] || die "Output path already exists: $OUTPUT_OVERRIDE" 2
    OUTPUT_DIR="$OUTPUT_OVERRIDE"
    REPORT_NAME="$(basename "$OUTPUT_DIR")"
else
    OUTPUT_DIR="$REPO_ROOT/$REPORT_NAME"
fi

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

# Define the redacted security findings folder.
SECURITY_DIR="$OUTPUT_DIR/security"

# Define the standardized report and its canonical data folder.
REPORT_DIR="$OUTPUT_DIR/report"
REPORT_DATA_DIR="$REPORT_DIR/data"

# Define Notion-ready structured evidence.
NOTION_DIR="$OUTPUT_DIR/notion"

# Define the compact evidence package prepared for downstream LLMs.
LLM_DIR="$OUTPUT_DIR/llm"

# Define packaged and optionally persisted analysis snapshots.
SNAPSHOT_DIR="$OUTPUT_DIR/snapshots"
PERSISTENT_SNAPSHOT_DIR="$REPO_ROOT/.repodna/snapshots"
SNAPSHOT_COMMIT="$(git rev-parse HEAD 2>/dev/null || true)"
SNAPSHOT_SHORT_COMMIT="${SNAPSHOT_COMMIT:0:12}"
if [[ "$PRIVACY_MODE" == strict ]]; then
    SNAPSHOT_COMMIT=''
    SNAPSHOT_SHORT_COMMIT='sanitized'
fi
SNAPSHOT_NAME="${TIMESTAMP}_${SNAPSHOT_SHORT_COMMIT:-uncommitted}.json"
SNAPSHOT_FILE="$SNAPSHOT_DIR/$SNAPSHOT_NAME"

# Define period-comparison outputs.
COMPARISON_DIR="$OUTPUT_DIR/comparison"

# Define versioned health-score trend outputs.
HEALTH_TRENDS_DIR="$OUTPUT_DIR/health-trends"

# Define per-system evidence documentation outputs.
SYSTEM_DOCUMENTATION_DIR="$OUTPUT_DIR/system-docs"

# Define the evidence-backed developer onboarding dataset.
ONBOARDING_DIR="$OUTPUT_DIR/onboarding"

# Define the lockfile-derived CycloneDX software bill of materials.
SBOM_DIR="$OUTPUT_DIR/sbom"

# Define Android-only specialized reports without creating them for other stacks.
ANDROID_DIR="$OUTPUT_DIR/android"

# Define Flutter-only specialized reports without creating them for other stacks.
FLUTTER_DIR="$OUTPUT_DIR/flutter"

# Define Godot-only specialized reports without creating them for other stacks.
GODOT_DIR="$OUTPUT_DIR/godot"

# Define Unreal-only specialized reports without creating them for other stacks.
UNREAL_DIR="$OUTPUT_DIR/unreal"

# Define approval-gated portfolio and CV evidence outputs.
PORTFOLIO_DIR="$OUTPUT_DIR/portfolio"

# Define the optional graph folder.
GRAPHS_DIR="$OUTPUT_DIR/graphs"

# Define the expected ZIP path.
ZIP_PATH="$(dirname "$OUTPUT_DIR")/${REPORT_NAME}.zip"

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
    "$SECURITY_DIR" \
    "$REPORT_DATA_DIR" \
    "$NOTION_DIR" \
    "$LLM_DIR" \
    "$SNAPSHOT_DIR" \
    "$COMPARISON_DIR" \
    "$HEALTH_TRENDS_DIR" \
    "$SYSTEM_DOCUMENTATION_DIR" \
    "$ONBOARDING_DIR" \
    "$SBOM_DIR" \
    "$PORTFOLIO_DIR" \
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
echo "Forge data : $([[ -n "$FORGE_DATA" ]] && printf configured || printf not-configured)"
echo "Output     : $DISPLAY_OUTPUT_PATH"
echo "================================================================"
echo ""

# Print the first progress step.
}
