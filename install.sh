#!/bin/bash
# Install the repo-roadmap convention into an existing repo.
#
# Usage: bash install.sh <target-repo-path>
# Example: bash install.sh ~/loka/code/my-project

set -e

TARGET="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Validation ────────────────────────────────────────────────────────────────

if [ -z "$TARGET" ]; then
    echo "Usage: bash install.sh <target-repo-path>"
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

if [ -d "$TARGET/roadmap" ]; then
    echo "Error: roadmap/ already exists in '$TARGET'."
    echo "       To upgrade an existing install, use: bash upgrade.sh $TARGET"
    exit 1
fi

# Warn if working tree is dirty, but don't block
if ! git -C "$TARGET" diff --quiet 2>/dev/null || ! git -C "$TARGET" diff --cached --quiet 2>/dev/null; then
    echo "Warning: '$TARGET' has uncommitted changes. Continuing anyway."
fi

# ── Get current version tag ───────────────────────────────────────────────────

CURRENT_TAG=$(git -C "$SCRIPT_DIR" describe --tags --abbrev=0 2>/dev/null || echo "untagged")

# ── Install ───────────────────────────────────────────────────────────────────

echo "Installing repo-roadmap convention ($CURRENT_TAG) into $TARGET..."
echo ""

# Create roadmap/templates/ and roadmap/archived/
mkdir -p "$TARGET/roadmap/templates"
mkdir -p "$TARGET/roadmap/archived"

# Copy templates
cp "$SCRIPT_DIR/roadmap/templates/template-feat.md"      "$TARGET/roadmap/templates/"
cp "$SCRIPT_DIR/roadmap/templates/template-idea.md"      "$TARGET/roadmap/templates/"
cp "$SCRIPT_DIR/roadmap/templates/template-challenge.md" "$TARGET/roadmap/templates/"
echo "✅ Templates copied to roadmap/templates/"
echo "✅ roadmap/archived/ created"

# Copy roadmap README
cp "$SCRIPT_DIR/roadmap/README.md" "$TARGET/roadmap/README.md"
echo "✅ roadmap/README.md created"

# Copy convention instructions (fully owned by convention, safe to replace on upgrade)
cp "$SCRIPT_DIR/roadmap/CLAUDE.md" "$TARGET/roadmap/CLAUDE.md"
echo "✅ roadmap/CLAUDE.md created"

# Wire into target's CLAUDE.md
CLAUDE_DST="$TARGET/CLAUDE.md"
IMPORT_LINE="@roadmap/CLAUDE.md"

if [ -f "$CLAUDE_DST" ]; then
    if grep -qF "$IMPORT_LINE" "$CLAUDE_DST"; then
        echo "ℹ️  CLAUDE.md already imports roadmap/CLAUDE.md — skipping"
    else
        echo "" >> "$CLAUDE_DST"
        echo "$IMPORT_LINE" >> "$CLAUDE_DST"
        echo "✅ Appended '$IMPORT_LINE' to existing CLAUDE.md"
    fi
else
    echo "$IMPORT_LINE" > "$CLAUDE_DST"
    echo "✅ Created CLAUDE.md with '$IMPORT_LINE'"
fi

# Write version file
echo "$CURRENT_TAG" > "$TARGET/.roadmap-version"
echo "✅ .roadmap-version set to $CURRENT_TAG"

echo ""
echo "Done. Commit the new files to finish the install:"
echo "  git -C $TARGET add roadmap/ CLAUDE.md .roadmap-version"
echo "  git -C $TARGET commit -m 'chore: install repo-roadmap convention ($CURRENT_TAG)'"
