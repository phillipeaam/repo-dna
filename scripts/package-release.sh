#!/usr/bin/env bash

set -euo pipefail

TAG="${1:-}"
OUTPUT_DIR="${2:-dist}"

[[ "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]] || {
    printf 'Expected a semantic-version tag such as v1.2.3.\n' >&2
    exit 2
}
git rev-parse --verify --quiet "refs/tags/$TAG^{commit}" >/dev/null || {
    printf 'Tag does not exist: %s\n' "$TAG" >&2
    exit 2
}

VERSION="${TAG#v}"
PACKAGE_NAME="repodna-$VERSION"
mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR/$PACKAGE_NAME.zip" "$OUTPUT_DIR/$PACKAGE_NAME.tar.gz" "$OUTPUT_DIR/SHA256SUMS"

git archive --format=zip --prefix="$PACKAGE_NAME/" --output="$OUTPUT_DIR/$PACKAGE_NAME.zip" "$TAG"
git archive --format=tar.gz --prefix="$PACKAGE_NAME/" --output="$OUTPUT_DIR/$PACKAGE_NAME.tar.gz" "$TAG"

(cd "$OUTPUT_DIR" && sha256sum "$PACKAGE_NAME.zip" "$PACKAGE_NAME.tar.gz" > SHA256SUMS)
printf 'Created %s release artifacts in %s.\n' "$TAG" "$OUTPUT_DIR"
