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

cp "$SOURCE_ROOT/tests/fixtures/secrets-fake/detections.env" "$TEST_ROOT/fixture-secrets.env"
cp "$SOURCE_ROOT/tests/fixtures/secrets-fake/false-positives.env" "$TEST_ROOT/false-positives.env"
printf '%s\n' 'ignored.env' > "$TEST_ROOT/.repodna-ignore"
printf '%s\n' 'API_KEY=ignored-secret-value-12345' > "$TEST_ROOT/ignored.env"
printf '%s\n' 'secrets.txt|8|password' > "$TEST_ROOT/.repodna-secrets-allowlist"

git -C "$TEST_ROOT" init -q
git -C "$TEST_ROOT" add secrets.txt
git -C "$TEST_ROOT" remote add private 'https://remote-user:remote-password@git.example.test/private.git'

REPORT_NAME='generated-report'
REPO_ROOT="$TEST_ROOT"
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
    'Git remote credential' \
    'password' \
    'webhook URL' \
    'private package registry' \
    'internal domain or private network address'; do
    grep -q "Potential $expected_type" "$TEST_ROOT/potential_secrets.txt"
done

grep -q 'Severity: Critical' "$TEST_ROOT/potential_secrets.txt"
grep -q 'Severity: High' "$TEST_ROOT/potential_secrets.txt"
grep -q 'Severity: Medium' "$TEST_ROOT/potential_secrets.txt"
grep -q 'Severity: Low' "$TEST_ROOT/potential_secrets.txt"
grep -q 'File: secrets.txt' "$TEST_ROOT/potential_secrets.txt"
grep -q 'Line: 1' "$TEST_ROOT/potential_secrets.txt"
grep -q 'Preview: fak\*\*\*\*7D2A' "$TEST_ROOT/potential_secrets.txt"
grep -q 'not a replacement for a dedicated security scanner' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'File: ignored.env' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'File: false-positives.env' "$TEST_ROOT/potential_secrets.txt"
# The allowlist suppresses only the password finding on line 8.
! grep -q '^Line: 8$' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'super-secret-api-value' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'bearer-token-value-12345' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'database-secret' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'registry-secret' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'remote-password' "$TEST_ROOT/potential_secrets.txt"
! grep -q 'fake-live-shaped-token-7D2A' "$TEST_ROOT/potential_secrets.txt"
[[ "$POTENTIAL_SECRET_COUNT" -gt 0 ]]

printf '%s\n' 'security scan tests passed'
