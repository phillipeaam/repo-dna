#!/usr/bin/env bash

set -euo pipefail

TAG="${1:-}"
OUTPUT_FILE="${2:-release-notes.md}"
VERSION="${TAG#v}"

[[ "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]] || {
    printf 'Expected a semantic-version tag such as v1.2.3.\n' >&2
    exit 2
}
git rev-parse --verify --quiet "refs/tags/$TAG^{commit}" >/dev/null || {
    printf 'Tag does not exist: %s\n' "$TAG" >&2
    exit 2
}

awk -v version="$VERSION" '
    $0 ~ "^## \\[" version "\\]" { found=1; print; next }
    found && /^## \[/ { exit }
    found { print }
    END { if (!found) exit 3 }
' CHANGELOG.md > "$OUTPUT_FILE" || {
    rm -f "$OUTPUT_FILE"
    printf 'CHANGELOG.md has no section for version %s.\n' "$VERSION" >&2
    exit 2
}

[[ -s "$OUTPUT_FILE" ]] || {
    printf 'The changelog section for %s is empty.\n' "$VERSION" >&2
    exit 2
}
