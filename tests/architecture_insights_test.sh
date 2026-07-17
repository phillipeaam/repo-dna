#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .architecture-insights-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/src/domain" "$TEST_ROOT/src/infrastructure" "$TEST_ROOT/cmd/server"
printf '%s\n' 'if __name__ == "__main__":' '    run()' > "$TEST_ROOT/src/main.py"
printf '%s\n' 'package main' 'func main() {}' > "$TEST_ROOT/cmd/server/main.go"

PYTHONPATH="$SOURCE_ROOT/collectors" TEST_ROOT="$TEST_ROOT" python - <<'PY'
import os
from pathlib import Path

from architecture import analyze_architecture

root = Path(os.environ["TEST_ROOT"])
files = [
    {"path": "src/main.py", "language": "Python"},
    {"path": "cmd/server/main.go", "language": "Go"},
    {"path": "src/domain/model.py", "language": "Python"},
    {"path": "src/infrastructure/database.py", "language": "Python"},
]
graphs = {"module_graph": {
    "nodes": [
        {"id": "src/domain", "files": 1, "fan_in": 2, "fan_out": 2},
        {"id": "src/infrastructure", "files": 1, "fan_in": 2, "fan_out": 2},
    ],
    "edges": [
        {"source": "src/domain", "target": "src/infrastructure", "references": 3},
        {"source": "src/infrastructure", "target": "src/domain", "references": 1},
    ],
    "cycles": [["src/domain", "src/infrastructure"]],
}}
analysis = analyze_architecture(root, files, graphs)

assert analysis["summary"]["entrypoints"] == 2, analysis["entrypoints"]
assert {item["language"] for item in analysis["entrypoints"]} == {"Python", "Go"}
assert analysis["summary"]["high_coupling_modules"] == 2
domain = next(item for item in analysis["coupling"]["modules"] if item["id"] == "src/domain")
assert domain["instability"] == 0.5 and domain["role"] == "hub"
assert analysis["summary"]["boundary_violations"] == 1
violation = analysis["boundaries"]["violations"][0]
assert violation["source_layer"] == "domain" and violation["target_layer"] == "infrastructure"
assert analysis["boundaries"]["cycles"][0]["cross_boundary"] is True
PY

printf '%s\n' 'architecture insight tests passed'
