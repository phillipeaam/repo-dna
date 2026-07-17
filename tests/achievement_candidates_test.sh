#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PYTHONPATH="$SOURCE_ROOT/collectors" python - <<'PY'
from achievement_candidates import generate_achievement_candidates

impact = {"contributions": [{"commit": "abc"}, {"commit": "def"}], "summary": {"total_churn": 420, "net_changed_source_lines": -12, "contributions_changing_tests": 1, "contributions_changing_dependencies": 1, "estimated_complexity_reductions": 1}}
ownership = {"relationships": [{"author": "Alice", "system": "src", "commits": 8, "files_touched": 4, "churn": 350, "author_focus_percent": 75.0, "confidence": "medium"}]}

unfiltered = generate_achievement_candidates("", impact, ownership)
assert unfiltered["status"] == "requires_author_filter" and unfiltered["candidates"] == []
result = generate_achievement_candidates("Alice", impact, ownership)
assert result["status"] == "candidates_generated"
assert result["summary"] == {"candidates": 5, "high_confidence": 1, "medium_confidence": 4, "low_confidence": 0}
by_id = {item["id"]: item for item in result["candidates"]}
assert by_id["personal-scope-summary"]["metrics"]["commits"] == 2
assert by_id["system-src"]["metrics"]["author_focus_percent"] == 75.0
assert by_id["test-evidence"]["confirmation_required"] is True
assert by_id["complexity-reduction-evidence"]["xyz_inputs"]["accomplished_x"].startswith("personal action")
assert all(item["required_confirmations"] for item in result["candidates"])
PY

printf '%s\n' 'achievement candidate tests passed'
