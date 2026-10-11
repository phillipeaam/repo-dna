#!/usr/bin/env bash
# Ensure local targets and canonical output stay private and untracked.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for private_path in target-repos/sample analysis-output/sample.md private-context/sample.md; do
    git -C "$ROOT_DIR" check-ignore --no-index -q "$private_path" || {
        printf 'FAIL: private path is not ignored: %s\n' "$private_path" >&2
        exit 1
    }
done

tracked_private="$(git -C "$ROOT_DIR" ls-files -- target-repos analysis-output private-context)"
[[ -z "$tracked_private" ]] || {
    printf 'FAIL: private target/output paths are tracked:\n%s\n' "$tracked_private" >&2
    exit 1
}
printf 'PASS: target-repos/, analysis-output/ and private-context/ are ignored and contain no tracked files.\n'
