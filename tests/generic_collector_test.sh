#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .generic-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT" 2>/dev/null || true' EXIT

mkdir -p "$TEST_ROOT/src/module" "$TEST_ROOT/src/data" "$TEST_ROOT/tests" "$TEST_ROOT/docs" "$TEST_ROOT/.github/workflows"
printf '%s\n' 'print("hello")' > "$TEST_ROOT/src/main.py"
printf '%s\n' \
    'from collections import defaultdict' \
    'class FeatureRepository:' \
    '    def feature(self, enabled):' \
    '        if enabled:' \
    '            return defaultdict(list)' \
    '        return {}' > "$TEST_ROOT/src/module/feature.py"
printf '%s\n' 'def test_feature():' '    assert True' > "$TEST_ROOT/tests/test_feature.py"
printf '%s\n' 'def save_data():' '    return True' > "$TEST_ROOT/src/data/save.py"
printf '%s\n' 'class DataRepository:' '    pass' > "$TEST_ROOT/src/data/repository.py"
printf '%s\n' '# Sample project' > "$TEST_ROOT/README.md"
printf '%s\n' 'requests==2.32.0' > "$TEST_ROOT/requirements.txt"
printf '%s\n' 'FROM python:3.13-slim' > "$TEST_ROOT/Dockerfile"
printf '%s\n' 'name: CI' 'on: [push]' > "$TEST_ROOT/.github/workflows/ci.yml"
printf '%s\n' \
    'Canonical Developer:' \
    '  names:' \
    '    - Generic Tester' \
    '  emails:' \
    '    - generic@example.test' > "$TEST_ROOT/.repodna-authors"

git -C "$TEST_ROOT" init -q
git -C "$TEST_ROOT" config user.name 'Generic Tester'
git -C "$TEST_ROOT" config user.email 'generic@example.test'
git -C "$TEST_ROOT" add .
git -C "$TEST_ROOT" commit -qm 'Initial project'
printf '%s\n' '# changed' >> "$TEST_ROOT/src/main.py"
git -C "$TEST_ROOT" add src/main.py
git -C "$TEST_ROOT" commit -qm 'Change hotspot' -m 'Co-authored-by: Pair Developer <pair@example.test>'

python "$SOURCE_ROOT/collectors/generic.py" "$TEST_ROOT" "$TEST_ROOT/generic-analysis.json"
python "$SOURCE_ROOT/collectors/generic.py" "$TEST_ROOT" "$TEST_ROOT/generic-analysis-strict.json" --privacy-mode strict

python - "$TEST_ROOT/generic-analysis.json" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert data["file_count"] >= 7
assert any(item["name"] == "Python" and item["lines"] >= 5 for item in data["languages"])
assert "requirements.txt" in data["configuration_files"]
assert "README.md" in data["documentation_files"]
assert "tests/test_feature.py" in data["test_files"]
assert ".github/workflows/ci.yml" in data["ci_cd_files"]
assert "Dockerfile" in data["docker_files"]
assert data["dependencies"]["total"] == 1
assert data["git"]["contributors_count"] == 1
assert data["git"]["contributors"][0] == {"name": "Canonical Developer", "commits": 2}
assert data["git"]["author_aliases_configured"] >= 3
assert data["git"]["branches_count"] >= 1
assert data["git"]["churn"]["total"] > 0
assert data["git"]["hotspots"][0]["path"] == "src/main.py"
assert {"current_lines", "authors", "days_since_last_change", "score"} <= data["git"]["hotspots"][0].keys()
assert data["git"]["coauthorship"][0]["commits"] == 1
assert sum(data["git"]["system_evolution"]["Data/Persistence"].values()) == 1
assert any(item["path"] == "src" for item in data["possible_modules"])
analysis = data["analysis"]
assert "Python" in analysis["architecture"]["languages_analyzed"]
assert any(item["name"] == "Repository" for item in analysis["architecture"]["design_patterns"])
assert analysis["code"]["symbol_count"] >= 3
assert analysis["code"]["importing_file_count"] >= 1
assert any(item["name"] == "src" for item in analysis["systems"])
assert analysis["quality"]["coverage"]["status"] == "not_detected"
assert analysis["quality"]["vulnerabilities"]["status"] == "not_scanned"
assert analysis["health"]["version"] == "1.0"
assert analysis["health"]["score"] is not None
assert analysis["narrative_facts"]
PY

python - "$TEST_ROOT/generic-analysis-strict.json" <<'PY'
import json
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text(encoding="utf-8")
data = json.loads(text)
assert "src/main.py" not in text
assert "FeatureRepository" not in text
assert "requirements.txt" not in text
assert data["git"]["branches"] == []
assert data["git"]["tags"] == []
assert all(item["path"].startswith("File-") for item in data["git"]["hotspots"])
assert all(item["name"].startswith("Module-") for item in data["analysis"]["systems"])
PY

printf '%s\n' 'generic collector tests passed'
