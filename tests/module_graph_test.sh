#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .module-graph-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/src/a" "$TEST_ROOT/src/b" "$TEST_ROOT/web/components" "$TEST_ROOT/web/pages"
touch "$TEST_ROOT/src/a/one.py" "$TEST_ROOT/src/b/two.py"
touch "$TEST_ROOT/web/components/Button.tsx" "$TEST_ROOT/web/pages/Home.tsx"

PYTHONPATH="$SOURCE_ROOT/collectors" TEST_ROOT="$TEST_ROOT" python - <<'PY'
import os
from pathlib import Path

from graphs import build_graphs

root = Path(os.environ["TEST_ROOT"])
files = [
    {"path": "src/a/one.py", "language": "Python"},
    {"path": "src/b/two.py", "language": "Python"},
    {"path": "web/components/Button.tsx", "language": "TypeScript"},
    {"path": "web/pages/Home.tsx", "language": "TypeScript"},
]
imports = [
    {"path": "src/a/one.py", "imports": ["src.b.two", "requests"]},
    {"path": "src/b/two.py", "imports": ["src.a.one"]},
    {"path": "web/pages/Home.tsx", "imports": ["../components/Button", "react", "./Missing"]},
]
dependencies = {"manifests": [{"path": "requirements.txt", "dependencies": ["requests"]}, {"path": "package.json", "dependencies": ["react"]}]}
graphs = build_graphs(root, files, imports, dependencies)

summary = graphs["summary"]
assert summary["internal_edges"] == 3, summary
assert summary["external_references"] == 2, summary
assert summary["unresolved_imports"] == 1, summary
assert summary["cycles"] == 1, summary
assert ["src/a", "src/b"] in graphs["module_graph"]["cycles"]

home_edges = [edge for edge in graphs["file_graph"]["edges"] if edge["source"] == "web/pages/Home.tsx"]
assert any(edge.get("target") == "web/components/Button.tsx" for edge in home_edges), home_edges
assert any(edge["import"] == "./Missing" and edge["status"] == "unresolved" for edge in home_edges), home_edges

dependency_nodes = {item["id"]: item for item in graphs["dependency_graph"]["nodes"]}
assert dependency_nodes["requests"]["declared"] is True
assert dependency_nodes["react"]["import_references"] == 1
PY

printf '%s\n' 'module graph tests passed'
