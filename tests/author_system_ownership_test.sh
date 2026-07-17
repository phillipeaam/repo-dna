#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PYTHONPATH="$SOURCE_ROOT/collectors" python - <<'PY'
from author_system_ownership import analyze_author_system_ownership

systems = [
    {"name": "src", "path": "src", "confidence": "high"},
    {"name": "tests", "path": "tests", "confidence": "medium"},
]
git_data = {
    "scope": "repository",
    "author_filter": "",
    "_file_author_activity": {
        "src/app.py": {
            "Alice": {"commits": 8, "churn": 700},
            "Bob": {"commits": 2, "churn": 100},
        },
        "src/service.py": {"Alice": {"commits": 4, "churn": 400}},
        "src/model.py": {"Alice": {"commits": 2, "churn": 100}},
        "tests/test_app.py": {"Bob": {"commits": 3, "churn": 120}},
    },
}

result = analyze_author_system_ownership(systems, git_data)
rows = {(item["author"], item["system"]): item for item in result["relationships"]}
alice = rows[("Alice", "src")]
bob_src = rows[("Bob", "src")]
bob_tests = rows[("Bob", "tests")]
assert result["status"] == "assessed"
assert result["summary"] == {"authors": 2, "systems": 2, "relationships": 3, "high_confidence_relationships": 1}
assert alice["rank_in_system"] == 1 and alice["system_activity_share_percent"] == 87.5
assert alice["author_focus_percent"] == 100.0 and alice["confidence"] == "high"
assert bob_src["system_activity_share_percent"] == 12.5
assert bob_src["author_focus_percent"] == 40.0
assert bob_tests["author_focus_percent"] == 60.0

git_data["scope"] = "author"
git_data["author_filter"] = "Alice"
filtered = analyze_author_system_ownership(systems, git_data)
assert all(item["system_activity_share_percent"] is None for item in filtered["relationships"])
PY

printf '%s\n' 'author-system ownership tests passed'
