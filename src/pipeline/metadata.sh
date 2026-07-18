collect_metadata() {
log_info "Reading repository and project metadata"

# Read the current branch.
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || true)"

# Read the current commit hash.
HEAD_HASH="$(git rev-parse HEAD 2>/dev/null || true)"

# Read the primary remote URL.
REMOTE_URL="$(git config --get remote.origin.url 2>/dev/null || true)"

if [[ "$PRIVACY_MODE" == strict ]]; then
    CURRENT_BRANCH='[redacted]'
    HEAD_HASH='[redacted]'
    REMOTE_URL='[redacted]'
fi

# Read the Unity editor version when available.
UNITY_VERSION="$(
    if [[ -f ProjectSettings/ProjectVersion.txt ]]; then
        grep '^m_EditorVersion:' ProjectSettings/ProjectVersion.txt |
            sed 's/^m_EditorVersion:[[:space:]]*//'
    else
        printf 'Unknown'
    fi
)"

# Read the Unity product name when available.
PRODUCT_NAME="$(
    if [[ -f ProjectSettings/ProjectSettings.asset ]]; then
        grep '^[[:space:]]*productName:' ProjectSettings/ProjectSettings.asset |
            head -n 1 |
            sed 's/^[[:space:]]*productName:[[:space:]]*//'
    else
        printf '%s' "$REPO_NAME"
    fi
)"

# Read the Unity company name when available.
COMPANY_NAME="$(
    if [[ -f ProjectSettings/ProjectSettings.asset ]]; then
        grep '^[[:space:]]*companyName:' ProjectSettings/ProjectSettings.asset |
            head -n 1 |
            sed 's/^[[:space:]]*companyName:[[:space:]]*//'
    else
        printf 'Unknown'
    fi
)"

DISPLAY_REPO_NAME="$REPO_NAME"
DISPLAY_REPO_ROOT="$REPO_ROOT"
DISPLAY_PRODUCT_NAME="${PRODUCT_NAME:-Unknown}"
DISPLAY_COMPANY_NAME="${COMPANY_NAME:-Unknown}"
DISPLAY_AUTHOR="${AUTHOR:-Not specified}"

if [[ "$PRIVACY_MODE" == strict ]]; then
    DISPLAY_REPO_NAME='repository'
    DISPLAY_REPO_ROOT='[redacted]'
    DISPLAY_PRODUCT_NAME='[redacted]'
    DISPLAY_COMPANY_NAME='[redacted]'
    DISPLAY_AUTHOR='[redacted]'
fi

# Write repository metadata.
cat > "$PROJECT_DIR/00_repository_information.txt" <<EOF
Repository name: $DISPLAY_REPO_NAME
Project type: $PROJECT_TYPE
Product name: $DISPLAY_PRODUCT_NAME
Company name: $DISPLAY_COMPANY_NAME
Repository root: $DISPLAY_REPO_ROOT
Current branch: ${CURRENT_BRANCH:-Detached HEAD or unavailable}
HEAD commit: ${HEAD_HASH:-Unavailable}
Origin remote: ${REMOTE_URL:-Unavailable}
Detected code root: $CODE_ROOT
Generated at: $GENERATED_AT
EOF

if [[ "$PROJECT_TYPE" == Unity ]]; then
    printf 'Unity version: %s\n' "${UNITY_VERSION:-Unknown}" >> "$PROJECT_DIR/00_repository_information.txt"
fi

# Copy the Unity version file.
if [[ "$PROJECT_TYPE" == Unity && "$PRIVACY_MODE" != strict ]]; then
    cp ProjectSettings/ProjectVersion.txt "$PROJECT_DIR/" 2>/dev/null || true
    cp Packages/manifest.json "$PROJECT_DIR/packages/" 2>/dev/null || true
    cp Packages/packages-lock.json "$PROJECT_DIR/packages/" 2>/dev/null || true
fi

# Print the second progress step.
}
