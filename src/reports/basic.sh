#!/usr/bin/env bash

# Produce a small, dependency-free report when the recommended Python runtime
# is unavailable. This is intentionally not the canonical analysis model.
write_basic_partial_report() {
    local file_count tracked_count json_repository json_project_type html_repository html_project_type
    mkdir -p "$REPORT_DIR" "$REPORT_DATA_DIR"
    file_count="$(analysis_find -type f -print 2>/dev/null | wc -l | tr -d '[:space:]')"
    tracked_count="$(git ls-files 2>/dev/null | wc -l | tr -d '[:space:]')"
    json_repository="$(json_escape "$DISPLAY_REPO_NAME")"
    json_project_type="$(json_escape "$PROJECT_TYPE")"
    html_repository="${DISPLAY_REPO_NAME//&/&amp;}"; html_repository="${html_repository//</&lt;}"; html_repository="${html_repository//>/&gt;}"
    html_project_type="${PROJECT_TYPE//&/&amp;}"; html_project_type="${html_project_type//</&lt;}"; html_project_type="${html_project_type//>/&gt;}"
    cat > "$REPORT_DATA_DIR/report.json" <<EOF
{
  "artifact_type": "repodna_partial_analysis",
  "status": "partial",
  "repository": "$json_repository",
  "project_type": "$json_project_type",
  "metrics": {
    "files_observed": ${file_count:-0},
    "git_tracked_files": ${tracked_count:-0},
    "commits_observed": ${GIT_HISTORY[total_commits]:-0}
  },
  "unavailable_features": [
    {
      "dependency": "Python 3.11+ with JSON Schema support",
      "features": ["canonical model", "HTML dashboards", "JSON Schema validation", "specialized analyzers", "SBOM", "snapshots"]
    }
  ]
}
EOF
    cat > "$REPORT_DIR/index.html" <<EOF
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>RepoDNA partial analysis</title></head>
<body><main><h1>RepoDNA partial analysis</h1>
<p>The repository inventory and Git reports were generated, but the recommended
Python reporting runtime was unavailable. Canonical and specialized reports were skipped.</p>
<dl><dt>Repository</dt><dd>$html_repository</dd><dt>Project type</dt><dd>$html_project_type</dd>
<dt>Files observed</dt><dd>${file_count:-0}</dd><dt>Git tracked files</dt><dd>${tracked_count:-0}</dd></dl>
<p><strong>Enable the complete report:</strong>
<code>python -m pip install -r requirements-reporting.txt</code></p>
</main></body></html>
EOF
}
