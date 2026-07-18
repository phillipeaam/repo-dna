#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP="$(mktemp -d)"; trap 'rm -rf "$TEMP"' EXIT

export REPODNA_INSTALL_DIR="$TEMP/data with spaces/repodna"
export REPODNA_BIN_DIR="$TEMP/bin with spaces"

bash "$ROOT/install.sh" > "$TEMP/install.log"
[[ -x "$REPODNA_BIN_DIR/repodna" ]]
[[ -f "$REPODNA_INSTALL_DIR/VERSION" ]]
[[ ! -d "$REPODNA_INSTALL_DIR/tests" ]]
[[ "$(bash "$REPODNA_BIN_DIR/repodna" --version)" == "RepoDNA $(tr -d '[:space:]' < "$ROOT/VERSION")" ]]

# Re-running the installer is the supported local update path.
bash "$ROOT/install.sh" > "$TEMP/update.log"
[[ "$(bash "$REPODNA_BIN_DIR/repodna" version)" == "RepoDNA $(tr -d '[:space:]' < "$ROOT/VERSION")" ]]
grep -q 'installed successfully' "$TEMP/update.log"

set +e
REPODNA_INSTALL_DIR=/ REPODNA_BIN_DIR="$TEMP/bin" bash "$ROOT/install.sh" >/dev/null 2>&1
status=$?
set -e
[[ "$status" -eq 2 ]]
printf 'Installation tests passed\n'
