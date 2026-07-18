#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if command -v python3 >/dev/null 2>&1 && python3 -c 'import sys' >/dev/null 2>&1; then
    PYTHON_BIN=python3
elif command -v python >/dev/null 2>&1 && python -c 'import sys' >/dev/null 2>&1; then
    PYTHON_BIN=python
else
    echo "Python unavailable; skipping health trends test."
    exit 0
fi

mkdir -p "$TMP_DIR/history"
"$PYTHON_BIN" - "$TMP_DIR" <<'PY'
import json, sys
from pathlib import Path

root = Path(sys.argv[1])
def snapshot(identifier, day, score, model="1.1", author=""):
    return {
        "schema_version": "1.0.0", "artifact_type": "repodna_analysis_snapshot",
        "snapshot_id": identifier, "generated_at": f"2026-07-{day:02d}T10:00:00Z",
        "repository": {"name": "demo", "type": "Generic", "commit": identifier * 40, "branch": "develop"},
        "scope": {"privacy_mode": "standard", "author_filter": author, "git_scope": "repository", "source_included": False},
        "health": {"score": score, "grade": "B", "assessment_coverage_percent": 90, "model_version": model, "dimensions": []},
    }
(root / "history" / "first.json").write_text(json.dumps(snapshot("a", 1, 70)), encoding="utf-8")
(root / "history" / "incompatible.json").write_text(json.dumps(snapshot("x", 2, 99, author="Ada")), encoding="utf-8")
(root / "current.json").write_text(json.dumps(snapshot("b", 3, 76)), encoding="utf-8")
PY

MPLBACKEND=Agg MPLCONFIGDIR="$TMP_DIR/matplotlib" \
    "$PYTHON_BIN" "$ROOT/renderers/health_trends.py" \
    "$TMP_DIR/current.json" "$TMP_DIR/trends.json" "$TMP_DIR/index.html" \
    --history-dir "$TMP_DIR/history" --schema "$ROOT/schemas/health-trends-1.0.0.schema.json" \
    --chart "$TMP_DIR/health-score-trend.png"

"$PYTHON_BIN" - "$TMP_DIR/trends.json" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
assert data["status"] == "available"
assert data["summary"] == {"point_count": 2, "first_score": 70, "latest_score": 76, "delta": 6, "direction": "increased"}
assert [item["snapshot_id"] for item in data["points"]] == ["a", "b"]
assert data["excluded_snapshots"][0]["reasons"] == ["author filter differs"]
PY
grep -q 'Health score trends' "$TMP_DIR/index.html"
grep -q 'Assessment coverage' "$TMP_DIR/index.html"
echo "health trends test passed"
