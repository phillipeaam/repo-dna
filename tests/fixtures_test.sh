#!/usr/bin/env bash
set -euo pipefail
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; SOURCE_ROOT="$(cd "$TEST_DIR/.." && pwd)"
source "$TEST_DIR/helpers/fixture.sh"; TEST_ROOT="$(mktemp -d)"; trap 'rm -rf "$TEST_ROOT"' EXIT
source "$SOURCE_ROOT/src/detectors/project-type.sh"

assert_fixture_type() {
    local fixture="$1" expected="$2"
    local destination="$TEST_ROOT/$fixture"
    fixture_copy "$fixture" "$destination"
    local actual
    actual="$(cd "$destination" && detect_project_type)"
    [[ "$actual" == "$expected" ]] || { printf '%s: expected %s, got %s\n' "$fixture" "$expected" "$actual" >&2; return 1; }
}

assert_fixture_type unity-minimal Unity
assert_fixture_type android-minimal Android
assert_fixture_type flutter-minimal Flutter
assert_fixture_type godot-minimal Godot
assert_fixture_type generic-repo 'Generic Git repository'

# Versioned fixtures must not contaminate analysis of RepoDNA itself.
isolation="$TEST_ROOT/isolation"; mkdir -p "$isolation/tests/fixtures/fake" "$isolation/src"
printf 'print(1)\n' > "$isolation/src/real.py"; printf 'print(2)\n' > "$isolation/tests/fixtures/fake/ignored.py"
fixture_init_git "$isolation"; fixture_commit_as "$isolation" Fixture fixture@example.test Initial
python "$SOURCE_ROOT/collectors/generic.py" "$isolation" "$TEST_ROOT/isolation.json"
python - "$TEST_ROOT/isolation.json" <<'PY'
import json,sys
data=json.load(open(sys.argv[1],encoding="utf-8")); assert data["file_count"]==1
assert data["largest_files"][0]["path"]=="src/real.py"
PY
echo 'fixture tests passed'
