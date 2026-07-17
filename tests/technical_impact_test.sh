#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .impact-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

git -C "$TEST_ROOT" init -q
git -C "$TEST_ROOT" config user.name 'Alice'
git -C "$TEST_ROOT" config user.email 'alice@example.test'
printf '%s\n' 'def run(value):' '    if value: return 1' > "$TEST_ROOT/app.py"
git -C "$TEST_ROOT" add app.py
git -C "$TEST_ROOT" commit -qm 'Add application'
mkdir -p "$TEST_ROOT/tests"
printf '%s\n' 'def run(value):' '    if value: return 1' '    for item in []: return item' > "$TEST_ROOT/app.py"
printf '%s\n' 'def test_run():' '    assert True' > "$TEST_ROOT/tests/test_app.py"
git -C "$TEST_ROOT" add app.py tests/test_app.py
git -C "$TEST_ROOT" commit -qm 'Add test and branch'

PYTHONPATH="$SOURCE_ROOT/collectors" TEST_ROOT="$TEST_ROOT" python - <<'PY'
import os
from pathlib import Path

from technical_impact import collect_technical_impact

result = collect_technical_impact(Path(os.environ["TEST_ROOT"]), [], lambda name, email: name)
assert result["status"] == "assessed" and result["contributions_analyzed"] == 2
assert result["summary"]["contributions_changing_tests"] == 1
assert result["summary"]["net_changed_source_lines"] == 5
latest = result["contributions"][0]
assert latest["author"] == "Alice"
assert latest["touched"]["files"] == 2
assert latest["touched"]["test_files"] == 1
assert latest["touched"]["additions"] == 3
assert latest["before"] == {"source_lines": 2, "estimated_complexity": 2}
assert latest["after"] == {"source_lines": 5, "estimated_complexity": 4}
assert latest["delta"] == {"source_lines": 3, "estimated_complexity": 2}
assert "tests_changed" in latest["signals"]
assert latest["measurement_confidence"] == "high"
assert latest["systems"] == ["[root]", "tests"]
PY

printf '%s\n' 'technical impact tests passed'
