#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .charts-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

cat > "$TEST_ROOT/commits.csv" <<'CSV'
Date,Hash,FullHash,AuthorName,AuthorEmail,Subject
2026-01-10,a,a,Alice,alice@example.test,First
2026-02-10,b,b,Bob,bob@example.test,Second
CSV

cat > "$TEST_ROOT/analysis.json" <<'JSON'
{
  "git": {
    "contributors": [{"name": "Alice", "commits": 8}, {"name": "Bob", "commits": 3}],
    "hotspots": [{"path": "src/app.py", "score": 42.5}, {"path": "src/data.py", "score": 21.0}],
    "system_evolution": {"UI": {"2026-01": 2, "2026-02": 1}, "Data": {"2026-02": 3}},
    "technical_impact": {
      "contributions": [
        {"date": "2026-01-10", "touched": {"additions": 40, "deletions": 10}, "delta": {"estimated_complexity": 2}, "signals": ["configuration_changed"]},
        {"date": "2026-02-10", "touched": {"additions": 15, "deletions": 25}, "delta": {"estimated_complexity": -3}, "signals": ["refactor_candidate", "dependencies_changed"]}
      ]
    }
  },
  "analysis": {
    "systems": [{"name": "src", "file_count": 12}, {"name": "tests", "file_count": 5}]
  }
}
JSON

MPLBACKEND=Agg MPLCONFIGDIR="$TEST_ROOT/.matplotlib" python "$SOURCE_ROOT/src/reports/charts.py" \
    "$TEST_ROOT/commits.csv" "$TEST_ROOT/output" --analysis-json "$TEST_ROOT/analysis.json"

for chart in \
    commits_by_month.png commits_by_year.png churn_by_month.png hotspots.png \
    systems.png authors.png system_evolution.png architecture_evolution.png; do
    [[ -s "$TEST_ROOT/output/$chart" ]]
done

printf '%s\n' 'chart tests passed'
