#!/usr/bin/env bash

# Fail when an undefined variable is used.
set -u

# Fail a pipeline when any command inside it fails.
set -o pipefail

# Record the Bash process start time for the final execution summary.
EXECUTION_STARTED_AT=$SECONDS

# Resolve this script's directory so it can be run from any repository folder.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load project-type and source-root detection.
# shellcheck source=src/detectors/project-type.sh
source "$SCRIPT_DIR/src/detectors/project-type.sh"
# shellcheck source=src/core/runtime.sh
source "$SCRIPT_DIR/src/core/runtime.sh"
# shellcheck source=src/core/arguments.sh
source "$SCRIPT_DIR/src/core/arguments.sh"
# shellcheck source=src/core/filesystem.sh
source "$SCRIPT_DIR/src/core/filesystem.sh"
# shellcheck source=src/core/privacy.sh
source "$SCRIPT_DIR/src/core/privacy.sh"
# shellcheck source=src/core/archive.sh
source "$SCRIPT_DIR/src/core/archive.sh"
# shellcheck source=src/core/git.sh
source "$SCRIPT_DIR/src/core/git.sh"
# shellcheck source=src/analyzers/unity.sh
source "$SCRIPT_DIR/src/analyzers/unity.sh"
# shellcheck source=src/git/history-export.sh
source "$SCRIPT_DIR/src/git/history-export.sh"
# shellcheck source=src/git/history-metrics.sh
source "$SCRIPT_DIR/src/git/history-metrics.sh"
# shellcheck source=src/git/history-specialized.sh
source "$SCRIPT_DIR/src/git/history-specialized.sh"

parse_arguments "$@"

# Load independent pipeline modules. Sourcing only declares functions.
# shellcheck source=src/pipeline/architecture.sh
source "$SCRIPT_DIR/src/pipeline/architecture.sh"
# shellcheck source=src/pipeline/charts.sh
source "$SCRIPT_DIR/src/pipeline/charts.sh"
# shellcheck source=src/pipeline/collaboration.sh
source "$SCRIPT_DIR/src/pipeline/collaboration.sh"
# shellcheck source=src/pipeline/context.sh
source "$SCRIPT_DIR/src/pipeline/context.sh"
# shellcheck source=src/pipeline/git-history.sh
source "$SCRIPT_DIR/src/pipeline/git-history.sh"
# shellcheck source=src/pipeline/guides.sh
source "$SCRIPT_DIR/src/pipeline/guides.sh"
# shellcheck source=src/pipeline/inventory.sh
source "$SCRIPT_DIR/src/pipeline/inventory.sh"
# shellcheck source=src/pipeline/metadata.sh
source "$SCRIPT_DIR/src/pipeline/metadata.sh"
# shellcheck source=src/pipeline/metrics.sh
source "$SCRIPT_DIR/src/pipeline/metrics.sh"
# shellcheck source=src/pipeline/security-archive.sh
source "$SCRIPT_DIR/src/pipeline/security-archive.sh"
# shellcheck source=src/pipeline/source-policy.sh
source "$SCRIPT_DIR/src/pipeline/source-policy.sh"
# shellcheck source=src/pipeline/structured-reports.sh
source "$SCRIPT_DIR/src/pipeline/structured-reports.sh"

# Orchestrate the analysis explicitly; filenames do not define execution order.
initialize_analysis_context
collect_metadata
collect_inventory
collect_architecture
collect_metrics
apply_source_policy
collect_git_history
collect_collaboration
write_guides
write_structured_reports
create_optional_charts
run_security_and_archive
