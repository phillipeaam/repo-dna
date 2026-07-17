#!/usr/bin/env bash

set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d -p "$SOURCE_ROOT" .security-test.XXXXXX)"
trap 'rm -rf "$TEST_ROOT"' EXIT

source "$SOURCE_ROOT/src/core/security.sh"

analysis_find() {
    find . "$@"
}

cat > "$TEST_ROOT/secrets.txt" <<'EOF'
api_key = "super-secret-api-value"
Authorization: Bearer bearer-token-value-12345
-----BEGIN PRIVATE KEY-----
Server=db.internal;User Id=admin;Password=database-secret;
firebase_database_url = "https://sample.firebaseio.com"
aws_access_key_id = AKIAABCDEFGHIJKLMNOP
remote = https://user:git-password@example.test/private.git
password = "application-password"
webhook = https://hooks.slack.com/services/T000/B000/SECRET
registry=https://packages.corp.example/npm/;_authToken=registry-secret
service = api.company.internal
EOF

git -C "$TEST_ROOT" init -q
git -C "$TEST_ROOT" add secrets.txt
git -C "$TEST_ROOT" remote add private 'https://remote-user:remote-password@git.example.test/private.git'

REPORT_NAME='generated-report'
POTENTIAL_SECRET_COUNT=0

cd "$TEST_ROOT"
write_potential_secrets_report "$TEST_ROOT/potential_secrets.txt"

for expected_type in \
    'possible API token' \
    'Bearer token' \
    'private key' \
    'connection string' \
    'Firebase configuration' \
    'AWS credential' \
    'Git remote credential or private remote' \
    'password' \
    'webhook URL' \
    'private package registry' \
    'internal domain or private network address'; do
    grep -q "Type: $expected_type" "$TEST_ROOT/potential_secrets.txt"
done

grep -q 'Value: \[REDACTED\]' "$TEST_ROOT/potential_secrets.txt"
grep -q 'secrets.txt:1' "$TEST_ROOT/potential_secrets.txt"
grep -q '.git/config:' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'super-secret-api-value' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'bearer-token-value-12345' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'database-secret' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'registry-secret' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'remote-password' "$TEST_ROOT/potential_secrets.txt"
[[ "$POTENTIAL_SECRET_COUNT" -gt 0 ]]

printf '%s\n' 'security scan tests passed'
