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
printf '%s\n' '# Repository health score' > "$TEST_ROOT/docs/health-score.md"
printf '%s\n' 'requests==2.32.0' > "$TEST_ROOT/requirements.txt"
printf '%s\n' 'FROM python:3.13-slim' > "$TEST_ROOT/Dockerfile"
printf '%s\n' 'name: CI' 'on: [push]' > "$TEST_ROOT/.github/workflows/ci.yml"
printf '%s\n' \
    'Canonical Developer:' \
    '  names:' \
    '    - Generic Tester' \
    '  emails:' \
    '    - generic@example.test' \
    'Focused Developer:' \
    '  names:' \
    '    - Focus Alias' \
    '  emails:' \
    '    - focused@example.test' > "$TEST_ROOT/.repodna-authors"

git -C "$TEST_ROOT" init -q
git -C "$TEST_ROOT" config user.name 'Generic Tester'
git -C "$TEST_ROOT" config user.email 'generic@example.test'
git -C "$TEST_ROOT" add .
git -C "$TEST_ROOT" commit -qm 'Initial project'
git -C "$TEST_ROOT" tag v0.1.0
printf '%s\n' '# changed' >> "$TEST_ROOT/src/main.py"
git -C "$TEST_ROOT" add src/main.py
git -C "$TEST_ROOT" commit -qm 'Change hotspot' -m 'Co-authored-by: Pair Developer <pair@example.test>'
printf '%s\n' '# focused change' >> "$TEST_ROOT/src/module/feature.py"
git -C "$TEST_ROOT" add src/module/feature.py
git -C "$TEST_ROOT" -c user.name='Focus Alias' -c user.email='focused@example.test' commit -qm 'Focused contribution'

python "$SOURCE_ROOT/collectors/generic.py" "$TEST_ROOT" "$TEST_ROOT/generic-analysis.json"
python "$SOURCE_ROOT/collectors/generic.py" "$TEST_ROOT" "$TEST_ROOT/generic-analysis-strict.json" --privacy-mode strict
python "$SOURCE_ROOT/collectors/generic.py" "$TEST_ROOT" "$TEST_ROOT/generic-analysis-focused.json" --author 'Focused Developer'

python - "$TEST_ROOT/generic-analysis.json" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert data["file_count"] >= 7
assert any(item["name"] == "Python" and item["lines"] >= 5 for item in data["languages"])
assert "requirements.txt" in data["configuration_files"], data["configuration_files"]
assert "README.md" in data["documentation_files"]
assert "tests/test_feature.py" in data["test_files"]
assert ".github/workflows/ci.yml" in data["ci_cd_files"]
assert "Dockerfile" in data["docker_files"]
assert data["dependencies"]["total"] == 1
assert data["git"]["contributors_count"] == 2
assert data["git"]["contributors"][0] == {"name": "Canonical Developer", "commits": 2}
assert data["git"]["author_aliases_configured"] >= 3
assert data["git"]["branches_count"] >= 1
assert data["git"]["churn"]["total"] > 0
impact = data["git"]["technical_impact"]
assert impact["status"] == "assessed" and impact["contributions_analyzed"] == 3
assert all(item["author"] in {"Canonical Developer", "Focused Developer"} for item in impact["contributions"])
assert all({"before", "after", "delta", "signals", "measurement_confidence"} <= item.keys() for item in impact["contributions"])
assert any(item["path"] == "src/main.py" for item in data["git"]["hotspots"])
assert {"model", "version", "current_lines", "authors", "days_since_last_change", "score"} <= data["git"]["hotspots"][0].keys()
assert data["git"]["hotspot_model"]["model"] == "repodna-composite-hotspot"
assert data["git"]["hotspot_model"]["version"] == "1.0"
assert data["git"]["recent_tags"] == ["v0.1.0"]
assert "releases" not in data["git"]
assert data["git"]["coauthorship"][0]["commits"] == 1
assert sum(data["git"]["system_evolution"]["Data/Persistence"].values()) == 1
assert "Combat" not in data["git"]["system_evolution"]
assert any(item["path"] == "src" for item in data["possible_modules"])
analysis = data["analysis"]
assert "Python" in analysis["architecture"]["languages_analyzed"]
python_parser = next(item for item in analysis["architecture"]["parser_coverage"] if item["language"] == "Python")
assert python_parser["mode"] == "ast"
assert python_parser["ast_files"] >= 1
assert python_parser["heuristic_files"] == 0
assert any(item["name"] == "Repository" for item in analysis["architecture"]["design_patterns"])
assert analysis["code"]["symbol_count"] >= 3
assert analysis["code"]["importing_file_count"] >= 1
assert analysis["code"]["call_count"] >= 1
assert any(item["name"] == "FeatureRepository.feature" for item in analysis["code"]["complexity"]["high_complexity_functions"]) is False
assert any(item["name"] == "src" for item in analysis["systems"])
activity_ownership = analysis["author_system_ownership"]
assert activity_ownership["status"] == "assessed"
assert activity_ownership["summary"]["authors"] == 2
assert any(item["author"] == "Canonical Developer" and item["system"] == "src" for item in activity_ownership["relationships"])
assert all(item["system_activity_share_percent"] is not None for item in activity_ownership["relationships"])
bus_factor = analysis["bus_factor_by_system"]
assert bus_factor["status"] == "assessed"
assert bus_factor["summary"]["systems_assessed"] >= 1
assert analysis["quality"]["coverage"]["status"] == "not_found"
assert analysis["quality"]["vulnerabilities"]["status"] == "not_scanned"
assert analysis["health"]["version"] == "1.1"
assert analysis["health"]["score"] is not None
assert analysis["narrative_facts"]
assert analysis["onboarding"]["status"] == "collected"
assert analysis["personal_achievement_candidates"]["status"] == "requires_author_filter"
assert analysis["personal_achievement_candidates"]["candidates"] == []
assert analysis["delivery"]["releases"]["summary"]["release_count"] == 1
assert analysis["delivery"]["ci"]["summary"]["workflow_count"] == 1
assert analysis["delivery"]["ci"]["workflows"][0]["provider"] == "GitHub Actions"
assert analysis["delivery"]["ci"]["workflows"][0]["triggers"] == ["push"]
PY

python - "$TEST_ROOT/generic-analysis-focused.json" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
assert data["git"]["scope"] == "author"
assert data["git"]["author_filter"] == "Focused Developer"
assert data["git"]["contributors"] == [{"name": "Focused Developer", "commits": 1}], data["git"]["contributors"]
assert data["git"]["churn"]["total"] > 0
assert data["git"]["technical_impact"]["contributions_analyzed"] == 1
assert data["git"]["technical_impact"]["contributions"][0]["author"] == "Focused Developer"
assert data["git"]["most_changed_files"] == [{"path": "src/module/feature.py", "commits": 1}]
ownership = data["analysis"]["author_system_ownership"]
assert {item["author"] for item in ownership["relationships"]} == {"Focused Developer"}
assert all(item["system_activity_share_percent"] is None for item in ownership["relationships"])
assert data["analysis"]["bus_factor_by_system"]["status"] == "unavailable_in_author_scope"
achievements = data["analysis"]["personal_achievement_candidates"]
assert achievements["status"] == "candidates_generated"
assert achievements["author"] == "Focused Developer"
assert any(item["category"] == "system_contribution" for item in achievements["candidates"]), achievements
assert all(item["confirmation_required"] for item in achievements["candidates"])
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
assert data["git"]["recent_tags"] == []
assert "releases" not in data["git"]
assert all(item["path"].startswith("File-") for item in data["git"]["hotspots"])
assert all(item["name"].startswith("Module-") for item in data["analysis"]["systems"])
assert all(item["subject"] == "[REDACTED]" for item in data["git"]["technical_impact"]["contributions"])
assert all(item["commit"].startswith("Contribution-") for item in data["git"]["technical_impact"]["contributions"])
ownership = data["analysis"]["author_system_ownership"]
assert all(item["author"].startswith("Contributor-") for item in ownership["relationships"])
assert all(item["system"].startswith("Module-") for item in ownership["relationships"])
assert all(item["system"].startswith("Module-") for item in data["analysis"]["bus_factor_by_system"]["systems"])
assert all(author["author"].startswith("Contributor-") for item in data["analysis"]["bus_factor_by_system"]["systems"] for author in item["critical_authors"])
assert data["analysis"]["onboarding"]["status"] == "redacted_by_privacy_mode"
assert data["analysis"]["onboarding"]["commands"] == []
assert data["analysis"]["delivery"]["releases"]["status"] == "redacted_by_privacy_mode"
assert data["analysis"]["delivery"]["releases"]["releases"] == []
assert data["analysis"]["delivery"]["ci"]["workflows"] == []
assert "Canonical Developer" not in text
PY

printf '%s\n' 'generic collector tests passed'
