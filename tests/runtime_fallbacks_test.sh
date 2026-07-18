#!/usr/bin/env bash
set -euo pipefail
SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SOURCE_ROOT/src/core/bash-version.sh"
source "$SOURCE_ROOT/src/core/runtime.sh"

bash_version_supported 4 3
bash_version_supported 5 0
if bash_version_supported 4 2; then
    echo 'Bash 4.2 was incorrectly accepted.' >&2; exit 1
fi
version_error="$(require_supported_bash 3 2 '3.2.57(1)-release' 2>&1 || true)"
[[ "$version_error" == *'requires Bash 4.3 or newer'* ]]
[[ "$version_error" == *'detected Bash 3.2.57(1)-release'* ]]

# An explicitly configured non-executable Python runtime must be rejected.
REPO_DNA_PYTHON="$SOURCE_ROOT/tests/fixtures/no-git/missing-python"
if resolve_python_runtime >/dev/null 2>&1; then
    echo 'Missing Python runtime was accepted.' >&2; exit 1
fi
unset REPO_DNA_PYTHON

# Archive generation must leave the report folder usable without compressors.
source "$SOURCE_ROOT/src/core/archive.sh"
TEST_ROOT="$(mktemp -d)"; trap 'rm -rf "$TEST_ROOT"' EXIT
REPO_ROOT="$TEST_ROOT"; OUTPUT_DIR="$TEST_ROOT/report"; REPORT_NAME=report
ZIP_PATH="$TEST_ROOT/report.zip"; PRIVACY_SCAN_FAILED=false
mkdir -p "$OUTPUT_DIR"; printf 'report\n' > "$OUTPUT_DIR/index.html"
command_exists() { return 1; }
message="$(create_report_archive)"
[[ "$message" == *'No supported archive command was found.'* ]]
[[ -f "$OUTPUT_DIR/index.html" && ! -f "$ZIP_PATH" ]]

echo 'runtime fallback tests passed'
