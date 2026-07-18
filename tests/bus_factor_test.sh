#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHONPATH="$ROOT/collectors" python - <<'PY'
from bus_factor import analyze_bus_factor
ownership = {"author_filter": "", "relationships": [
    {"system": "Core", "author": "Alice", "commits": 12, "files_touched": 5, "system_activity_share_percent": 60.0, "confidence": "high", "system_confidence": "high"},
    {"system": "Core", "author": "Bob", "commits": 6, "files_touched": 3, "system_activity_share_percent": 30.0, "confidence": "medium", "system_confidence": "high"},
    {"system": "Core", "author": "Carol", "commits": 2, "files_touched": 1, "system_activity_share_percent": 10.0, "confidence": "low", "system_confidence": "high"},
    {"system": "Build", "author": "Alice", "commits": 10, "files_touched": 3, "system_activity_share_percent": 100.0, "confidence": "high", "system_confidence": "medium"},
]}
result = analyze_bus_factor(ownership)
by_system = {item["system"]: item for item in result["systems"]}
assert result["summary"] == {"systems_assessed": 2, "critical_systems": 1, "minimum_bus_factor": 1}
assert by_system["Core"]["bus_factor"] == 2 and by_system["Core"]["covered_activity_percent"] == 90.0
assert [item["author"] for item in by_system["Core"]["critical_authors"]] == ["Alice", "Bob"]
assert by_system["Build"]["bus_factor"] == 1 and by_system["Build"]["risk"] == "high_concentration"
filtered = analyze_bus_factor({"author_filter": "Alice", "relationships": ownership["relationships"]})
assert filtered["status"] == "unavailable_in_author_scope" and filtered["systems"] == []
PY
echo "bus factor tests passed"
