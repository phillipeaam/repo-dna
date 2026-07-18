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
assert_fixture_type unreal-minimal Unreal
assert_fixture_type bash-minimal 'Generic Git repository'
assert_fixture_type python-minimal Python
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

# Versioned 1.0 ecosystem fixtures must produce their promised language evidence.
for fixture in bash-minimal python-minimal; do
    destination="$TEST_ROOT/$fixture-analysis"
    fixture_copy "$fixture" "$destination"
    fixture_init_git "$destination"
    fixture_commit_as "$destination" Fixture fixture@example.test Initial
    python "$SOURCE_ROOT/collectors/generic.py" "$destination" "$TEST_ROOT/$fixture.json"
done
python - "$TEST_ROOT/bash-minimal.json" "$TEST_ROOT/python-minimal.json" <<'PY'
import json,sys
bash=json.load(open(sys.argv[1],encoding="utf-8")); python=json.load(open(sys.argv[2],encoding="utf-8"))
assert any(item["name"]=="Shell" and item["files"]>=1 for item in bash["languages"])
assert any(item["name"]=="Python" and item["files"]>=2 for item in python["languages"])
assert python["analysis"]["architecture"]["parser_coverage"][0]["mode"]=="ast"
PY
echo 'fixture tests passed'
