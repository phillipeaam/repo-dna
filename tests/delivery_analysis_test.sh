#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d -p "$ROOT" .delivery-test.XXXXXX)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/.github/workflows"
git -C "$TMP" init -q
git -C "$TMP" config user.name 'Release Author'
git -C "$TMP" config user.email 'release@example.test'

printf 'one\n' > "$TMP/app.txt"
git -C "$TMP" add app.txt
GIT_AUTHOR_DATE='2026-01-01T12:00:00+00:00' GIT_COMMITTER_DATE='2026-01-01T12:00:00+00:00' git -C "$TMP" commit -qm 'Initial release'
git -C "$TMP" tag v1.0.0

printf 'two\n' >> "$TMP/app.txt"
git -C "$TMP" add app.txt
GIT_AUTHOR_DATE='2026-01-11T12:00:00+00:00' GIT_COMMITTER_DATE='2026-01-11T12:00:00+00:00' git -C "$TMP" commit -qm 'Add delivery feature'
GIT_COMMITTER_DATE='2026-01-11T12:00:00+00:00' git -C "$TMP" tag -a v1.1.0 -m 'Release 1.1.0'

printf 'three\n' >> "$TMP/app.txt"
git -C "$TMP" add app.txt
GIT_AUTHOR_DATE='2026-01-21T12:00:00+00:00' GIT_COMMITTER_DATE='2026-01-21T12:00:00+00:00' git -C "$TMP" commit -qm 'Unreleased change'

cat > "$TMP/CHANGELOG.md" <<'MD'
# Changelog
## [1.1.0]
- Delivery feature.
## [1.0.0]
- Initial release.
MD
cat > "$TMP/.github/workflows/ci.yml" <<'YAML'
name: CI
on:
  push:
  pull_request:
  workflow_dispatch:
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
    steps:
      - uses: actions/checkout@v4
      - name: Test
        run: bash tests/run.sh
  release:
    permissions:
      contents: write
    steps:
      - name: Publish artifact
        uses: actions/upload-artifact@v4
YAML
cat > "$TMP/.gitlab-ci.yml" <<'YAML'
stages:
  - build
  - test
build_app:
  stage: build
  script:
    - make
test_app:
  stage: test
  script:
    - make test
YAML

PYTHONPATH="$ROOT/collectors" python - "$TMP" <<'PY'
import sys
from pathlib import Path
from delivery_analysis import analyze_delivery

root=Path(sys.argv[1])
result=analyze_delivery(root,[".github/workflows/ci.yml",".gitlab-ci.yml"])
releases=result["releases"]
assert releases["status"]=="assessed"
assert releases["summary"]["release_count"]==2
assert releases["summary"]["semantic_release_count"]==2
assert releases["summary"]["annotated_tag_count"]==1
assert releases["summary"]["latest_release"]=="v1.1.0"
assert releases["summary"]["average_days_between_releases"]==10.0
assert releases["summary"]["documented_release_count"]==2
assert releases["releases"][0]["commits_since_previous"]==1
assert releases["unreleased"]["commits"]==1 and releases["unreleased"]["churn"]==1

ci=result["ci"]
assert ci["status"]=="assessed" and ci["summary"]["workflow_count"]==2
assert ci["summary"]["providers"]=={"GitHub Actions":1,"GitLab CI":1}
assert ci["summary"]["job_count"]==4
github=next(item for item in ci["workflows"] if item["provider"]=="GitHub Actions")
assert github["name"]=="CI" and set(github["triggers"])=={"push","pull_request","workflow_dispatch"}
assert github["test_job_count"]==1 and github["deployment_job_count"]==1
assert github["signals"]["matrix"] and github["signals"]["write_permissions"]
assert len(github["signals"]["floating_action_references"])==2
print("local release and CI analysis tests passed")
PY
