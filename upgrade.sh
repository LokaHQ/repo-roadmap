#!/bin/bash
# Upgrade an existing repo-roadmap install to the current convention version.
#
# Usage: bash upgrade.sh <target-repo-path>
# Example: bash upgrade.sh ~/loka/code/my-project

set -e

TARGET="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Validation ────────────────────────────────────────────────────────────────

if [ -z "$TARGET" ]; then
    echo "Usage: bash upgrade.sh <target-repo-path>"
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

if [ ! -f "$TARGET/roadmap/README.md" ]; then
    cp "$SCRIPT_DIR/roadmap/README.md" "$TARGET/roadmap/README.md"
    echo "✅ roadmap/README.md created (was missing)"
fi

# Ensure CLAUDE.md imports it (idempotent)
CLAUDE_DST="$TARGET/CLAUDE.md"
IMPORT_LINE="@roadmap/CLAUDE.md"

if [ -f "$CLAUDE_DST" ]; then
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
echo ""
echo "Upgrade complete. Review changes then commit:"
echo "  git -C $TARGET add roadmap/ CLAUDE.md .roadmap-version"
echo "  git -C $TARGET commit -m 'chore: upgrade repo-roadmap convention to $CURRENT_TAG'"
