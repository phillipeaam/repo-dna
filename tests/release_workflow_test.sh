#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/repodna-release.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/repository/scripts"
cp "$SOURCE_ROOT/scripts/package-release.sh" "$TEST_ROOT/repository/scripts/"
cp "$SOURCE_ROOT/scripts/release-notes.sh" "$TEST_ROOT/repository/scripts/"
cat > "$TEST_ROOT/repository/CHANGELOG.md" <<'EOF'
# Changelog

## [Unreleased]

## [1.2.3]

- Verified release fixture.
EOF
printf '# RepoDNA fixture\n' > "$TEST_ROOT/repository/README.md"

git -C "$TEST_ROOT/repository" init -q
git -C "$TEST_ROOT/repository" config user.name 'Release Fixture'
git -C "$TEST_ROOT/repository" config user.email 'release@example.test'
git -C "$TEST_ROOT/repository" add .
git -C "$TEST_ROOT/repository" commit -qm 'Prepare release fixture'
git -C "$TEST_ROOT/repository" tag v1.2.3

(
    cd "$TEST_ROOT/repository"
    bash ./scripts/release-notes.sh v1.2.3 release-notes.md
    bash ./scripts/package-release.sh v1.2.3 dist
)

grep -q 'Verified release fixture' "$TEST_ROOT/repository/release-notes.md"
[[ -s "$TEST_ROOT/repository/dist/repodna-1.2.3.zip" ]]
[[ -s "$TEST_ROOT/repository/dist/repodna-1.2.3.tar.gz" ]]
[[ "$(wc -l < "$TEST_ROOT/repository/dist/SHA256SUMS")" -eq 2 ]]
(cd "$TEST_ROOT/repository/dist" && sha256sum -c SHA256SUMS)

printf 'release workflow helpers passed\n'
