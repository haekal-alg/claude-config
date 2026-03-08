#!/usr/bin/env bash
set -euo pipefail

# Smart Commit Script - Conventional Commits
# Stages all changes, generates a conventional commit message, and pushes.

CUSTOM_MSG="${1:-}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}>${NC} $1"; }
err()  { echo -e "${RED}!${NC} $1" >&2; }

# Get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
info "Branch: $BRANCH"

# Check for changes
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    err "No changes to commit."
    exit 0
fi

# Stage all changes
git add -A
info "Staged all changes."

# Show what's being committed
echo ""
git diff --cached --stat
echo ""

# Generate or use provided commit message
if [ -n "$CUSTOM_MSG" ]; then
    COMMIT_MSG="$CUSTOM_MSG"
else
    # Auto-detect commit type from changed files
    CHANGED=$(git diff --cached --name-only)

    # Count file types
    CODE_FILES=$(echo "$CHANGED" | grep -ciE '\.(ts|tsx|js|jsx|py|java|kt|go|rs|rb|php|cs|cpp|c|h|hpp|swift|scala|clj|edn|ex|exs|hs|lua|r|m|mm|pl|sh|bash|zsh|fish|sql|css|scss|sass|less|html|vue|svelte|dart|zig|nim|v|jl|f90|ml|mli|elm|purs|rkt)$' || true)
    DOC_FILES=$(echo "$CHANGED" | grep -ciE '\.md$' || true)
    TEST_FILES=$(echo "$CHANGED" | grep -ciE 'test|spec|__test' || true)
    BUILD_FILES=$(echo "$CHANGED" | grep -ciE 'webpack|tsconfig|package\.json|\.eslint|\.prettier|electron-builder|Makefile|CMakeLists|build\.gradle|pom\.xml|Cargo\.toml|setup\.py|pyproject\.toml|go\.mod|Gemfile|composer\.json' || true)
    CI_FILES=$(echo "$CHANGED" | grep -ciE '\.github/|\.gitlab-ci|Jenkinsfile|\.circleci' || true)
    TOTAL_FILES=$(echo "$CHANGED" | wc -l | tr -d ' ')

    NEW_FILES=$(git diff --cached --diff-filter=A --name-only | wc -l | tr -d ' ')
    MODIFIED_FILES=$(git diff --cached --diff-filter=M --name-only | wc -l | tr -d ' ')

    # Determine type based on majority of changes
    TYPE="chore"
    SCOPE=""
    SUBJECT="Update files"

    if [ "$CODE_FILES" -gt 0 ]; then
        # Code changes take priority
        if [ "$NEW_FILES" -gt 0 ]; then
            TYPE="feat"
        else
            TYPE="refactor"
        fi
    elif [ "$TEST_FILES" -gt 0 ]; then
        TYPE="test"
    elif [ "$CI_FILES" -gt 0 ]; then
        TYPE="ci"
    elif [ "$BUILD_FILES" -gt 0 ]; then
        TYPE="build"
    elif [ "$DOC_FILES" -gt 0 ] && [ "$DOC_FILES" -eq "$TOTAL_FILES" ]; then
        # Only docs if ALL changed files are .md
        TYPE="docs"
    fi

    # Try to detect scope from common path prefix
    if [ "$CODE_FILES" -gt 0 ]; then
        COMMON_DIR=$(echo "$CHANGED" | grep -oE '^src/[^/]+/[^/]+/' | sort | uniq -c | sort -rn | head -1 | awk '{print $2}' | sed 's|^src/||;s|/$||;s|.*/||')
        if [ -n "$COMMON_DIR" ]; then
            SCOPE="$COMMON_DIR"
        fi
    fi

    # Build subject from changed files
    if [ "$(echo "$CHANGED" | wc -l | tr -d ' ')" -eq 1 ]; then
        FILENAME=$(basename "$CHANGED" | sed 's/\.[^.]*$//')
        SUBJECT="Update $FILENAME"
    else
        # Summarize by directory
        DIRS=$(echo "$CHANGED" | grep -oE '^[^/]+/[^/]+' | sort -u | head -3 | tr '\n' ', ' | sed 's/,$//')
        SUBJECT="Update $DIRS"
    fi

    # Truncate subject to 50 chars
    if [ -n "$SCOPE" ]; then
        MAX_LEN=$((50 - ${#TYPE} - ${#SCOPE} - 4))  # type(scope):
        COMMIT_MSG="${TYPE}(${SCOPE}): ${SUBJECT:0:$MAX_LEN}"
    else
        MAX_LEN=$((50 - ${#TYPE} - 2))  # type:
        COMMIT_MSG="${TYPE}: ${SUBJECT:0:$MAX_LEN}"
    fi
fi

# For large changes (>3 files), append a body listing changed areas
if [ -z "$CUSTOM_MSG" ] && [ "$TOTAL_FILES" -gt 3 ]; then
    BODY=""
    DIRS_LIST=$(echo "$CHANGED" | grep -oE '^[^/]+(/[^/]+)?' | sort -u | head -8)
    while IFS= read -r dir; do
        COUNT=$(echo "$CHANGED" | grep -c "^${dir}" || true)
        BODY="${BODY}\n- ${dir} (${COUNT} files)"
    done <<< "$DIRS_LIST"
    COMMIT_MSG="${COMMIT_MSG}\n\nChanged areas:${BODY}"
fi

info "Commit: $COMMIT_MSG"

# Commit (no AI co-author)
git commit -m "$(echo -e "$COMMIT_MSG")"

# Push
info "Pushing to origin/$BRANCH..."
git push -u origin "$BRANCH"

info "Done."
