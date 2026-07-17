#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .detection-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT
source "$SOURCE_ROOT/src/detectors/project-type.sh"

assert_detection() {
    local fixture="$1" expected_type="$2" expected_root="$3"
    local detected_type detected_root
    detected_type="$(cd "$fixture" && detect_project_type)"
    detected_root="$(cd "$fixture" && detect_code_root "$detected_type")"
    [[ "$detected_type" == "$expected_type" ]] || {
        printf 'Expected %s, got %s for %s\n' "$expected_type" "$detected_type" "$fixture" >&2
        return 1
    }
    [[ "$detected_root" == "$expected_root" ]] || {
        printf 'Expected root %s, got %s for %s\n' "$expected_root" "$detected_root" "$fixture" >&2
        return 1
    }
}

mkdir -p "$TEST_ROOT/generic" "$TEST_ROOT/unity/ProjectSettings" "$TEST_ROOT/unity/Assets" "$TEST_ROOT/node/src" \
    "$TEST_ROOT/android/app/src/main" "$TEST_ROOT/dotnet" "$TEST_ROOT/python/src" "$TEST_ROOT/priority/ProjectSettings" "$TEST_ROOT/priority/Assets" \
    "$TEST_ROOT/node-no-src" "$TEST_ROOT/dart" "$TEST_ROOT/flutter/lib"
touch "$TEST_ROOT/unity/ProjectSettings/ProjectVersion.txt"
printf '{}' > "$TEST_ROOT/node/package.json"
printf '<manifest />' > "$TEST_ROOT/android/app/src/main/AndroidManifest.xml"
printf '<Project />' > "$TEST_ROOT/dotnet/sample.csproj"
printf '[project]\nname="sample"\n' > "$TEST_ROOT/python/pyproject.toml"
touch "$TEST_ROOT/priority/ProjectSettings/ProjectVersion.txt"
printf '{}' > "$TEST_ROOT/priority/package.json"
printf '{}' > "$TEST_ROOT/node-no-src/package.json"
printf 'name: dart_package\n' > "$TEST_ROOT/dart/pubspec.yaml"
printf 'name: flutter_app\ndependencies:\n  flutter:\n    sdk: flutter\n' > "$TEST_ROOT/flutter/pubspec.yaml"

assert_detection "$TEST_ROOT/generic" 'Generic Git repository' '.'
assert_detection "$TEST_ROOT/unity" Unity Assets
assert_detection "$TEST_ROOT/node" Node src
assert_detection "$TEST_ROOT/android" Android app/src/main
assert_detection "$TEST_ROOT/dotnet" .NET .
assert_detection "$TEST_ROOT/python" Python src
assert_detection "$TEST_ROOT/priority" Unity Assets
assert_detection "$TEST_ROOT/node-no-src" Node .
assert_detection "$TEST_ROOT/dart" 'Generic Git repository' .
assert_detection "$TEST_ROOT/flutter" Flutter lib
printf '%s\n' 'project detection tests passed'
