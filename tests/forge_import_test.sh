#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d -p "$ROOT" .forge-test.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/forge.json" <<'JSON'
{
  "$schema":"./forge-data-1.0.0.schema.json","schema_version":"1.0.0","artifact_type":"repodna_forge_data","provider":"gitlab","exported_at":"2026-07-18T12:00:00Z",
  "repository":{"name":"demo","owner":"team","host":"gitlab.example.test","external_id":"42"},
  "scope":{"complete":true,"from":"2026-01-01T00:00:00Z","to":"2026-07-18T12:00:00Z","notes":[]},
  "issues":[
    {"id":"i1","number":1,"title":"Public issue","state":"closed","url":null,"created_at":"2026-01-01T00:00:00Z","closed_at":"2026-01-03T00:00:00Z","author":{"id":"u1","username":"alice","display_name":"Alice","aliases":["Alice Dev"]},"labels":["bug"],"assignees":[],"milestone":null,"comments_count":3,"confidential":false},
    {"id":"i2","number":2,"title":"Secret client issue","state":"open","url":"https://internal.example.test/i/2","created_at":"2026-02-01T00:00:00Z","closed_at":null,"author":{"id":"u2","username":"bob","display_name":"Bob","aliases":[]},"labels":["client-secret"],"assignees":[{"id":"u1","username":"alice","display_name":"Alice","aliases":[]}],"milestone":"Private","comments_count":1,"confidential":true}
  ],
  "pull_requests":[
    {"id":"p1","number":10,"title":"Add API","state":"merged","url":null,"created_at":"2026-03-01T00:00:00Z","closed_at":"2026-03-03T00:00:00Z","author":{"id":"u1","username":"alice","display_name":"Alice","aliases":[]},"labels":["feature"],"draft":false,"merged_at":"2026-03-03T00:00:00Z","merge_commit":"abc","source_branch":"feature/api","target_branch":"main","participants":[],"reviewers":[{"id":"u2","username":"bob","display_name":"Bob","aliases":[]}],"commits_count":2,"changed_files":4,"additions":120,"deletions":20,"comments_count":2,"review_comments_count":5},
    {"id":"p2","number":11,"title":"Improve docs","state":"open","url":null,"created_at":"2026-04-01T00:00:00Z","closed_at":null,"author":{"id":"u2","username":"bob","display_name":"Bob","aliases":[]},"labels":["docs"],"draft":false,"merged_at":null,"merge_commit":null,"source_branch":"docs","target_branch":"main","participants":[],"reviewers":[{"id":"u1","username":"alice","display_name":"Alice","aliases":[]}],"commits_count":1,"changed_files":2,"additions":30,"deletions":2,"comments_count":0,"review_comments_count":1}
  ],
  "releases":[
    {"id":"r1","tag":"v1.0.0","name":"One","draft":false,"prerelease":false,"published_at":"2026-05-01T00:00:00Z","author":{"id":"u1","username":"alice","display_name":"Alice","aliases":[]},"assets_count":2,"url":null}
  ]
}
JSON

PYTHONPATH="$ROOT/collectors" python - "$TMP/forge.json" <<'PY'
import json,sys
from pathlib import Path
from forge_import import import_forge_data

path=Path(sys.argv[1])
data=import_forge_data(path,local_tags=["v1.0.0","v0.9.0"])
assert data["status"]=="imported" and data["provider"]=="gitlab"
assert data["issue_metrics"]["average_close_days"]==2.0
assert data["pull_request_metrics"]["merged"]==1 and data["pull_request_metrics"]["average_time_to_merge_days"]==2.0
assert data["release_metrics"]=={"total":1,"published":1,"drafts":0,"prereleases":0,"assets":2}
assert data["collaboration"]=={"unique_people":2,"reviewers":2}
assert data["release_correlation"]["matched_tags"]==["v1.0.0"] and data["release_correlation"]["local_only_tags"]==["v0.9.0"]
confidential=next(item for item in data["issues"] if item["id"]=="i2")
assert confidential["title"]=="[confidential issue omitted]" and confidential["url"] is None and confidential["labels"]==[]

alice=import_forge_data(path,"Alice Dev",local_tags=["v1.0.0"])
assert alice["summary"]=={"issues":2,"pull_requests":2,"releases":1,"source_issues":2,"source_pull_requests":2,"source_releases":1}
assert next(item for item in alice["issues"] if item["id"]=="i2")["selected_author_roles"]==["assignee"]
assert next(item for item in alice["pull_requests"] if item["id"]=="p2")["selected_author_roles"]==["reviewer"]

strict=import_forge_data(path,"",privacy_mode="strict",local_tags=["v1.0.0"])
assert strict["status"]=="redacted_by_privacy_mode" and strict["issues"]==[] and strict["pull_requests"]==[] and strict["releases"]==[]
assert strict["repository"]["name"]=="[redacted]" and strict["release_correlation"]["matched_tags"]==[]

invalid=json.loads(path.read_text(encoding="utf-8")); invalid.pop("provider")
bad=path.with_name("invalid.json"); bad.write_text(json.dumps(invalid),encoding="utf-8")
try:
    import_forge_data(bad)
except ValueError as error:
    assert "Forge data violates" in str(error)
else:
    raise AssertionError("invalid forge data was accepted")
print("provider-neutral forge import tests passed")
PY
