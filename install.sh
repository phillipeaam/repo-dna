#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${REPODNA_INSTALL_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/repodna}"
BIN_DIR="${REPODNA_BIN_DIR:-${XDG_BIN_HOME:-$HOME/.local/bin}}"
STAGING_DIR="${INSTALL_DIR}.installing.$$"

cleanup() { rm -rf -- "$STAGING_DIR"; }
trap cleanup EXIT

case "$INSTALL_DIR" in
    ''|/|"$SOURCE_DIR")
        printf 'Error: unsafe REPODNA_INSTALL_DIR: %s\n' "$INSTALL_DIR" >&2
        exit 2 ;;
esac
case "$BIN_DIR" in
    ''|/) printf 'Error: unsafe REPODNA_BIN_DIR: %s\n' "$BIN_DIR" >&2; exit 2 ;;
esac

[[ -f "$SOURCE_DIR/VERSION" && -f "$SOURCE_DIR/repodna" ]] || {
    printf '%s\n' 'Error: install.sh must be run from a complete RepoDNA checkout.' >&2
    exit 1
}

mkdir -p -- "$(dirname "$INSTALL_DIR")" "$BIN_DIR" "$STAGING_DIR"
for directory in collectors renderers schemas src; do
    cp -R -- "$SOURCE_DIR/$directory" "$STAGING_DIR/$directory"
done
for file in VERSION repodna dna-analysis.sh requirements-ast.txt requirements-reporting.txt LICENSE; do
    cp -- "$SOURCE_DIR/$file" "$STAGING_DIR/$file"
done
chmod +x "$STAGING_DIR/repodna" "$STAGING_DIR/dna-analysis.sh"

if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf -- "${INSTALL_DIR}.previous"
    mv -- "$INSTALL_DIR" "${INSTALL_DIR}.previous"
fi
mv -- "$STAGING_DIR" "$INSTALL_DIR"
rm -rf -- "${INSTALL_DIR}.previous"

cat > "$BIN_DIR/repodna" <<EOF
#!/usr/bin/env bash
exec bash "$INSTALL_DIR/repodna" "\$@"
EOF
chmod +x "$BIN_DIR/repodna"

version="$(tr -d '[:space:]' < "$INSTALL_DIR/VERSION")"
printf 'RepoDNA %s installed successfully.\n' "$version"
printf 'Command: %s/repodna\n' "$BIN_DIR"
case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) printf 'Add this directory to PATH: %s\n' "$BIN_DIR" ;;
esac
printf '%s\n' 'Run: repodna doctor'
