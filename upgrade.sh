#!/bin/bash
# Upgrade an existing repo-roadmap install to the current convention version.
#
# Usage: bash upgrade.sh <target-repo-path> [--create-pr]
# Example: bash upgrade.sh ~/loka/code/my-project
#          bash upgrade.sh ~/loka/code/my-project --create-pr

set -e

TARGET="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Flag parsing ──────────────────────────────────────────────────────────────

CREATE_PR=false
for arg in "$@"; do
    case $arg in
        --create-pr) CREATE_PR=true ;;
    esac
done

# ── Validation ────────────────────────────────────────────────────────────────

if [ -z "$TARGET" ]; then
    echo "Usage: bash upgrade.sh <target-repo-path> [--create-pr]"
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "Error: target directory '$TARGET' does not exist."
    exit 1
fi

if [ ! -d "$TARGET/.git" ]; then
    echo "Error: '$TARGET' is not a git repository."
    exit 1
fi

if [ ! -d "$TARGET/roadmap" ]; then
    echo "Error: no roadmap/ found in '$TARGET'."
    echo "       For a fresh install, use: bash install.sh $TARGET"
    exit 1
fi

# Warn if working tree is dirty, but don't block
if ! git -C "$TARGET" diff --quiet 2>/dev/null || ! git -C "$TARGET" diff --cached --quiet 2>/dev/null; then
    echo "Warning: '$TARGET' has uncommitted changes. Continuing anyway."
fi

# ── Version info ──────────────────────────────────────────────────────────────

CURRENT_TAG=$(git -C "$SCRIPT_DIR" describe --tags --abbrev=0 2>/dev/null || echo "untagged")
VERSION_FILE="$TARGET/.roadmap-version"

if [ -f "$VERSION_FILE" ]; then
    LAST_TAG=$(cat "$VERSION_FILE")
else
    LAST_TAG="v0 (no .roadmap-version found)"
fi

echo "=== repo-roadmap upgrade ==="
echo "Convention: $LAST_TAG → $CURRENT_TAG"
echo ""

# ── Handle old template layout (templates at root instead of templates/) ──────

if [ -f "$TARGET/roadmap/template-feat.md" ] && [ ! -d "$TARGET/roadmap/templates" ]; then
    echo "⚠️  Old template layout detected (templates at roadmap/ root) — moving to roadmap/templates/"
    mkdir -p "$TARGET/roadmap/templates"
    mv "$TARGET/roadmap/template-feat.md"      "$TARGET/roadmap/templates/" 2>/dev/null || true
    mv "$TARGET/roadmap/template-idea.md"      "$TARGET/roadmap/templates/" 2>/dev/null || true
    mv "$TARGET/roadmap/template-challenge.md" "$TARGET/roadmap/templates/" 2>/dev/null || true
fi

# ── Replace templates ─────────────────────────────────────────────────────────

mkdir -p "$TARGET/roadmap/templates"
cp "$SCRIPT_DIR/roadmap/templates/template-feat.md"      "$TARGET/roadmap/templates/"
cp "$SCRIPT_DIR/roadmap/templates/template-idea.md"      "$TARGET/roadmap/templates/"
cp "$SCRIPT_DIR/roadmap/templates/template-challenge.md" "$TARGET/roadmap/templates/"
echo "✅ Templates replaced (3 files)"

# ── Replace CLAUDE.md and roadmap/README.md ──────────────────────────────────

cp "$SCRIPT_DIR/roadmap/CLAUDE.md" "$TARGET/roadmap/CLAUDE.md"
echo "✅ roadmap/CLAUDE.md updated"

# Remove old filename if still present (renamed in v0.3.0)
if [ -f "$TARGET/roadmap/CLAUDE-roadmap.md" ]; then
    rm "$TARGET/roadmap/CLAUDE-roadmap.md"
    echo "✅ Removed stale roadmap/CLAUDE-roadmap.md"
fi

if [ ! -f "$TARGET/roadmap/README.md" ]; then
    cp "$SCRIPT_DIR/roadmap/README.md" "$TARGET/roadmap/README.md"
    echo "✅ roadmap/README.md created (was missing)"
fi

# Ensure CLAUDE.md imports the new path and remove the old one if present
CLAUDE_DST="$TARGET/CLAUDE.md"
IMPORT_LINE="@roadmap/CLAUDE.md"
OLD_IMPORT_LINE="@roadmap/CLAUDE-roadmap.md"

if [ -f "$CLAUDE_DST" ]; then
    # Remove old import line if present
    if grep -qF "$OLD_IMPORT_LINE" "$CLAUDE_DST"; then
        sed -i "/$OLD_IMPORT_LINE/d" "$CLAUDE_DST"
        echo "✅ Removed old '$OLD_IMPORT_LINE' from CLAUDE.md"
    fi
    # Add new import line if not already there
    if ! grep -qF "$IMPORT_LINE" "$CLAUDE_DST"; then
        echo "" >> "$CLAUDE_DST"
        echo "$IMPORT_LINE" >> "$CLAUDE_DST"
        echo "✅ Added '$IMPORT_LINE' to CLAUDE.md"
    fi
else
    echo "$IMPORT_LINE" > "$CLAUDE_DST"
    echo "✅ Created CLAUDE.md with '$IMPORT_LINE'"
fi

# ── Ensure archived/ exists ───────────────────────────────────────────────────

if [ ! -d "$TARGET/roadmap/archived" ]; then
    mkdir -p "$TARGET/roadmap/archived"
    echo "✅ roadmap/archived/ created"
fi

# ── Audit content files ───────────────────────────────────────────────────────

echo ""

NEEDS_MIGRATION=()

for f in \
    "$TARGET/roadmap"/feat-*.md \
    "$TARGET/roadmap"/idea-*.md \
    "$TARGET/roadmap"/challenge-*.md \
    "$TARGET/roadmap"/feat-*/feat-*.md \
    "$TARGET/roadmap"/idea-*/idea-*.md \
    "$TARGET/roadmap"/challenge-*/challenge-*.md; do
    [ -f "$f" ] || continue
    # Skip archived items
    [[ "$f" == *"/archived/"* ]] && continue

    rel="${f#$TARGET/}"
    issues=()

    # Check for frontmatter block
    if ! head -1 "$f" | grep -q "^---"; then
        issues+=("frontmatter")
    else
        # Has frontmatter — check for owner field
        if ! awk '/^---/{p++} p==1' "$f" | grep -q "^owner:"; then
            issues+=("owner field")
        fi
    fi

    # Check for One-Line Overview section
    if ! grep -q "^## One-Line Overview" "$f"; then
        issues+=("One-Line Overview")
    fi

    if [ ${#issues[@]} -gt 0 ]; then
        joined=$(IFS=", "; echo "${issues[*]}")
        NEEDS_MIGRATION+=("  $rel — missing: $joined")
    fi
done

if [ ${#NEEDS_MIGRATION[@]} -eq 0 ]; then
    echo "✅ All content files are up to date"
else
    echo "⚠️  Content files needing migration (${#NEEDS_MIGRATION[@]} files):"
    for line in "${NEEDS_MIGRATION[@]}"; do
        echo "$line"
    done
    echo ""
    echo "   Run this to migrate interactively:"
    echo "   cd $TARGET && claude \"migrate roadmap frontmatter\""
fi

# ── Update version file ───────────────────────────────────────────────────────

echo "$CURRENT_TAG" > "$VERSION_FILE"
echo ""
echo "✅ .roadmap-version updated to $CURRENT_TAG"

# ── Commit and optionally create PR ──────────────────────────────────────────

if [ "$CREATE_PR" = true ]; then
    echo ""
    BRANCH="chore/roadmap-upgrade-${CURRENT_TAG}"

    if git -C "$TARGET" show-ref --verify --quiet "refs/heads/$BRANCH"; then
        echo "⚠️  Branch '$BRANCH' already exists. Delete it or merge the existing PR first."
        exit 1
    fi

    git -C "$TARGET" checkout -b "$BRANCH"
    git -C "$TARGET" add roadmap/ CLAUDE.md .roadmap-version
    git -C "$TARGET" commit -m "chore: upgrade repo-roadmap convention ${LAST_TAG} → ${CURRENT_TAG}"
    git -C "$TARGET" push -u origin "$BRANCH"
    echo "✅ Branch '$BRANCH' pushed"

    if ! command -v gh &>/dev/null; then
        echo ""
        echo "⚠️  GitHub CLI (gh) not found — skipping PR creation."
        echo "   Install: https://cli.github.com"
        echo "   Then create the PR manually or run: gh pr create"
        exit 0
    fi

    if ! gh auth status &>/dev/null; then
        echo ""
        echo "⚠️  gh is not authenticated — skipping PR creation."
        echo "   Run: gh auth login"
        echo "   Then create the PR manually or run: gh pr create"
        exit 0
    fi

    DEFAULT_BRANCH=$(cd "$TARGET" && gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo "main")

    CHANGELOG=$(git -C "$SCRIPT_DIR" log "${LAST_TAG}..${CURRENT_TAG}" --oneline 2>/dev/null || true)
    if [ -z "$CHANGELOG" ]; then
        CHANGELOG="No changelog available (tags missing or first install)."
        CHANGELOG_MD="- $CHANGELOG"
    else
        CHANGELOG_MD=$(echo "$CHANGELOG" | sed 's/^/- /')
    fi

    CHANGED_FILES=$(git -C "$TARGET" diff --name-only HEAD~1 HEAD 2>/dev/null | sed 's/^/- /' || echo "- (unable to list)")

    PR_URL=$(cd "$TARGET" && gh pr create \
        --base "$DEFAULT_BRANCH" \
        --head "$BRANCH" \
        --title "chore: upgrade repo-roadmap convention ${LAST_TAG} → ${CURRENT_TAG}" \
        --body "$(cat <<EOF
## repo-roadmap upgrade: ${LAST_TAG} → ${CURRENT_TAG}

### What changed upstream
${CHANGELOG_MD}

### Files updated
${CHANGED_FILES}
EOF
)")

    echo ""
    echo "✅ PR created: $PR_URL"
else
    echo ""
    echo "Upgrade complete. Review changes then commit:"
    echo "  git -C $TARGET add roadmap/ CLAUDE.md .roadmap-version"
    echo "  git -C $TARGET commit -m 'chore: upgrade repo-roadmap convention ${LAST_TAG} → ${CURRENT_TAG}'"
    echo ""
    echo "  To create a PR instead: bash upgrade.sh $TARGET --create-pr"
fi
