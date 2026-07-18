#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .artifact-test.XXXXXX)"
PROJECT_ROOT="$TEST_ROOT/sample-project"

cleanup() {
    local status=$?
    if [[ "${KEEP_TEST_ROOT:-false}" == true ]]; then
        printf 'Artifact test workspace retained at: %s\n' "$TEST_ROOT" >&2
        return
    fi
    if [[ "${CI:-false}" == true && "$status" -ne 0 ]]; then
        printf 'Artifact test workspace retained at: %s\n' "$TEST_ROOT" >&2
        return
    fi
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

mkdir -p "$PROJECT_ROOT/src"
cp "$SOURCE_ROOT/dna-analysis.sh" "$PROJECT_ROOT/"
for directory in collectors renderers schemas src; do
    cp -R "$SOURCE_ROOT/$directory" "$PROJECT_ROOT/"
done
printf '%s\n' '<Project Sdk="Microsoft.NET.Sdk" />' > "$PROJECT_ROOT/sample.csproj"
printf '%s\n' 'namespace Sample { public sealed class Program { } }' > "$PROJECT_ROOT/src/Program.cs"

git -C "$PROJECT_ROOT" init -q
git -C "$PROJECT_ROOT" config user.name 'CI Fixture'
git -C "$PROJECT_ROOT" config user.email 'ci-fixture@example.test'
git -C "$PROJECT_ROOT" add .
git -C "$PROJECT_ROOT" commit -qm 'Create artifact fixture'

(cd "$PROJECT_ROOT" && bash ./dna-analysis.sh >/dev/null)

REPORT_ROOT="$(find "$PROJECT_ROOT" -maxdepth 1 -type d -name '*_project_analysis_*' -print -quit)"
[[ -n "$REPORT_ROOT" ]]
[[ -s "$REPORT_ROOT/report/data/report.json" ]]
[[ -s "$REPORT_ROOT/report/index.html" ]]

python - "$REPORT_ROOT" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
documents = list(root.rglob("*.json"))
assert documents, "the generated report contains no JSON documents"
for path in documents:
    with path.open(encoding="utf-8") as stream:
        json.load(stream)

canonical = json.loads((root / "report/data/report.json").read_text(encoding="utf-8"))
assert canonical["schema_version"] == "1.1"
assert canonical["project"]["type"] == ".NET"
assert "generic_analysis" in canonical
print(f"validated {len(documents)} generated JSON documents")
PY

if [[ -s "$PROJECT_ROOT/$(basename "$REPORT_ROOT").zip" ]]; then
    ARCHIVE_PATH="$PROJECT_ROOT/$(basename "$REPORT_ROOT").zip"
    unzip -Z1 "$ARCHIVE_PATH" > "$TEST_ROOT/archive-contents.txt"
    grep -Eq '(^|[\\/])report[\\/]index\.html$' "$TEST_ROOT/archive-contents.txt"
elif [[ -s "$PROJECT_ROOT/$(basename "$REPORT_ROOT").tar.gz" ]]; then
    ARCHIVE_PATH="$PROJECT_ROOT/$(basename "$REPORT_ROOT").tar.gz"
    tar -tzf "$ARCHIVE_PATH" > "$TEST_ROOT/archive-contents.txt"
    grep -Eq '(^|[\\/])report[\\/]index\.html$' "$TEST_ROOT/archive-contents.txt"
else
    printf 'Expected a generated ZIP or TAR.GZ archive.\n' >&2
    exit 1
fi

printf 'generated report and archive contract passed: %s\n' "$ARCHIVE_PATH"
