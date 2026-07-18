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
    echo "Python unavailable; skipping period comparison test."
    exit 0
fi

"$PYTHON_BIN" - "$ROOT" "$TMP_DIR" <<'PY'
import copy, json, sys
from pathlib import Path
sys.path.insert(0, str(Path(sys.argv[1]) / "renderers"))
from snapshot_compare import build, validate, render

def snapshot(identifier, files, author="", version="1.0.0"):
    return {
        "schema_version": version, "artifact_type": "repodna_analysis_snapshot",
        "snapshot_id": identifier, "generated_at": f"2026-07-{identifier}T10:00:00Z",
        "repository": {"name": "demo", "type": "Generic", "commit": identifier * 40, "branch": "develop"},
        "scope": {"privacy_mode": "standard", "author_filter": author, "git_scope": "repository", "source_included": False},
        "inventory": {"files": files, "languages": [{"name": "Python", "files": files, "lines": files * 10}], "configuration_files": 1, "documentation_files": 1, "test_files": 2, "ci_cd_files": 1, "docker_files": 0, "dependency_declarations": 3},
        "architecture": {"summary": {"symbols": files}, "design_patterns": [], "graph_summary": {"cycles": 0}},
        "systems": [{"name": "Core", "file_count": files, "lines": files * 10, "symbol_count": files, "import_references": 1}],
        "quality": {"coverage": {"line_coverage_percent": 70}, "tests": {"total": 2, "passed": 2}, "linters": {"issues": 1}, "vulnerabilities": {"findings": 0}, "dependencies": {"resolved": 3}},
        "health": {"score": 80 + files, "grade": "B", "assessment_coverage_percent": 90, "model_version": "1"},
        "git": {"contributors": 2, "churn": {"total": files * 5}, "hotspot_model": {"model": "repodna-composite-hotspot", "version": "1.0"}, "hotspots": [{"path": "src/app.py", "score": files * 2}], "technical_impact_summary": {}}, "risks": {"potential_secret_findings": 0}
    }

baseline, current = snapshot("1", 10), snapshot("2", 14)
result = build(current, baseline)
assert result["status"] == "compared"
assert result["inventory"]["files"]["delta"] == 4
assert result["languages"][0]["metrics"]["lines"]["delta"] == 40
assert result["systems"][0]["metrics"]["file_count"]["delta"] == 4
assert result["architecture"]["summary"]["symbols"]["delta"] == 4
assert result["git"]["hotspots"]["comparable"] is True
assert result["git"]["hotspots"]["files"][0]["score"]["delta"] == 8
different_hotspot = snapshot("2", 14); different_hotspot["git"]["hotspot_model"]["version"] = "2.0"
different_result = build(different_hotspot, baseline)
assert different_result["status"] == "compared"
assert different_result["git"]["hotspots"]["comparable"] is False
assert any("hotspot" in warning.lower() for warning in different_result["compatibility"]["warnings"])
assert build(current)["status"] == "no_baseline"
assert build(snapshot("2", 14, author="Ada"), baseline)["status"] == "scope_mismatch"
assert build(snapshot("2", 14, version="2.0.0"), baseline)["status"] == "incompatible_schema"
validate(result, Path(sys.argv[1]) / "schemas" / "analysis-comparison-1.0.0.schema.json")
assert "Period comparison" in render(result)
Path(sys.argv[2], "baseline.json").write_text(json.dumps(baseline), encoding="utf-8")
Path(sys.argv[2], "current.json").write_text(json.dumps(current), encoding="utf-8")
PY

"$PYTHON_BIN" "$ROOT/renderers/snapshot_compare.py" \
    "$TMP_DIR/current.json" "$TMP_DIR/comparison.json" "$TMP_DIR/index.html" \
    --baseline "$TMP_DIR/baseline.json" \
    --schema "$ROOT/schemas/analysis-comparison-1.0.0.schema.json"

[[ -s "$TMP_DIR/comparison.json" && -s "$TMP_DIR/index.html" ]]
echo "period comparison test passed"
