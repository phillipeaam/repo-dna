initialize_analysis_context() {
# Require Git.
command_exists git || die "Git is not installed or is not available in PATH."

if [[ -n "$PORTFOLIO_PROFILE" ]]; then
    [[ -f "$PORTFOLIO_PROFILE" ]] || die "Portfolio profile not found: $PORTFOLIO_PROFILE"
    PORTFOLIO_PROFILE="$(cd "$(dirname "$PORTFOLIO_PROFILE")" && pwd)/$(basename "$PORTFOLIO_PROFILE")"
fi

# Resolve Python once so collectors, renderers, and charts use the same runtime.
STRUCTURED_PYTHON="$(resolve_python_runtime || true)"
[[ -n "$STRUCTURED_PYTHON" ]] ||
    die "Python 3.11 or newer is required to generate the standardized reports. Install a compatible runtime or set REPO_DNA_PYTHON."

# Require execution inside a Git repository.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    die "Run this script from inside a Git repository."

# Resolve the repository root.
REPO_ROOT="$(git rev-parse --show-toplevel)"

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

# Define the redacted security findings folder.
SECURITY_DIR="$OUTPUT_DIR/security"

# Define the standardized report and its canonical data folder.
REPORT_DIR="$OUTPUT_DIR/report"
REPORT_DATA_DIR="$REPORT_DIR/data"

# Define Notion-ready structured evidence.
NOTION_DIR="$OUTPUT_DIR/notion"

# Define approval-gated portfolio and CV evidence outputs.
PORTFOLIO_DIR="$OUTPUT_DIR/portfolio"

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
    "$SECURITY_DIR" \
    "$REPORT_DATA_DIR" \
    "$NOTION_DIR" \
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
echo "Output     : $DISPLAY_OUTPUT_PATH"
echo "================================================================"
echo ""

# Print the first progress step.
}
