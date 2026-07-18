#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/src/core/runtime.sh"
source "$ROOT/tests/helpers/fixture.sh"
TEMP="$(mktemp -d "${TMPDIR:-/tmp}/RepoDNA Windows compat.XXXXXX")"
trap 'rm -rf "$TEMP"' EXIT

# Windows-native separators and Git Bash drive paths normalize consistently.
native='C:\Users\Phillipe Augusto\Development\repo-dna'
normalized="$(normalize_repository_path "$native")"
[[ "$normalized" == 'C:/Users/Phillipe Augusto/Development/repo-dna' || "$normalized" == '/c/Users/Phillipe Augusto/Development/repo-dna' ]]
[[ "$(normalize_repository_path '/c/Users/Phillipe Augusto/Development/repo-dna')" == '/c/Users/Phillipe Augusto/Development/repo-dna' ]]

# Runtime resolution supports python3, python, and the Windows Python Launcher.
(
    command_exists() { [[ "$1" == py ]]; }
    py() { [[ "$1" == -c ]]; }
    [[ "$(resolve_python_runtime)" == py ]]
)
(
    command_exists() { [[ "$1" == python ]]; }
    python() { [[ "$1" == -c ]]; }
    [[ "$(resolve_python_runtime)" == python ]]
)

# CRLF content, Unicode, spaces, long paths, and normalized JSON separators.
repository="$TEMP/Repositório com espaços"
mkdir -p "$repository"
long_directory="$repository"
for index in {01..18}; do long_directory="$long_directory/segmento-$index-com-nome-longo"; done
mkdir -p "$long_directory"
printf 'print("ação")\r\nprint("segunda linha")\r\n' > "$long_directory/código.py"
printf '# Documento\r\n' > "$repository/README.md"
fixture_init_git "$repository"
git -C "$repository" config core.longpaths true
fixture_commit_as "$repository" 'José Windows' 'jose.windows@example.test' 'CRLF e caminho longo'
python "$ROOT/collectors/generic.py" "$repository" "$TEMP/windows.json"
python - "$TEMP/windows.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1],encoding="utf-8")); paths=[item["path"] for item in data["largest_files"]]
path=next(value for value in paths if value.endswith("código.py"))
assert "\\" not in path and len(path) > 260
assert next(item for item in data["largest_files"] if item["path"]==path)["lines"] == 2
assert data["git"]["contributors"][0]["name"] == "José Windows"
PY

# A positional repository path changes the analysis target before Git validation.
empty="$TEMP/fora da unidade C sem git"; mkdir -p "$empty"
if bash "$ROOT/dna-analysis.sh" "$empty" >"$TEMP/positional.log" 2>&1; then
    echo 'A non-Git positional repository was accepted.' >&2; exit 1
fi
grep -q 'Run this script from inside a Git repository' "$TEMP/positional.log"

# ZIP is verified whenever the host provides it; missing optional Unix tools are
# covered separately by runtime_fallbacks_test.sh.
if command -v zip >/dev/null 2>&1; then
    mkdir -p "$TEMP/archive source"; printf 'ok\r\n' > "$TEMP/archive source/result.txt"
    (cd "$TEMP/archive source" && zip -qr "$TEMP/windows archive.zip" .)
    unzip -t "$TEMP/windows archive.zip" >/dev/null
fi

printf 'Windows/Git Bash compatibility tests passed\n'
