#!/usr/bin/env bash

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="${1:---framework}"
if [[ "$#" -gt 1 || ( "$MODE" != "--framework" && "$MODE" != "--all" ) ]]; then
    printf '%s\n' 'Usage: bash tests/run.sh [--framework]' >&2
    exit 2
fi

# --all remains a compatibility alias, but runs only the supported framework
# contracts. Legacy target-analysis tests are intentionally not invoked.
tests=(
    readonly_audit_boundary_test.sh
    readonly_audit_scope_test.sh
    audit_workflow_contract_test.sh
    canonical_markdown_contract_test.sh
    evidence_separation_test.sh
    publication_readiness_test.sh
    multirepo_audit_test.sh
    audit_resume_migration_test.sh
    private_paths_test.sh
    public_context_test.sh
    local_method_test.sh
)

for test_file in "${tests[@]}"; do
    printf '\n==> %s\n' "$test_file"
    bash "$TEST_DIR/$test_file"
done

python "$TEST_DIR/../scripts/check-public-context.py"

printf '\nAll %d RepoDNA framework contract tests passed.\n' "${#tests[@]}"
