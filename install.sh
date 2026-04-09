#!/bin/bash
# Install the roadmap convention into an existing repo.
#
# Usage: bash install.sh <target-repo-path>
# Example: bash install.sh ~/loka/code/my-project

set -e

TARGET="$1"

if [ -z "$TARGET" ]; then
    echo "Usage: bash install.sh <target-repo-path>"
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "Error: target directory '$TARGET' does not exist."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Copy roadmap/ directory
if [ -d "$TARGET/roadmap" ]; then
    echo "roadmap/ already exists in target — skipping (remove it manually if you want a fresh copy)."
else
    cp -r "$SCRIPT_DIR/roadmap" "$TARGET/roadmap"
    echo "Copied roadmap/ to $TARGET/roadmap"
fi

# CLAUDE.md — append if exists, create if not
CLAUDE_SRC="$SCRIPT_DIR/CLAUDE.md"
CLAUDE_DST="$TARGET/CLAUDE.md"

if [ -f "$CLAUDE_DST" ]; then
    echo "" >> "$CLAUDE_DST"
    echo "---" >> "$CLAUDE_DST"
    cat "$CLAUDE_SRC" >> "$CLAUDE_DST"
    echo "Appended roadmap instructions to existing $CLAUDE_DST"
else
    cp "$CLAUDE_SRC" "$CLAUDE_DST"
    echo "Created $CLAUDE_DST"
fi

echo "Done. Roadmap convention installed in $TARGET"
