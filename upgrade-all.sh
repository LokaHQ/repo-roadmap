#!/bin/bash
# Upgrade repo-roadmap convention in all repos listed in repos.txt.
#
# Usage: bash upgrade-all.sh [--create-pr]
# Setup: cp repos.txt.example repos.txt  (then fill in your repo paths)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPOS_FILE="$SCRIPT_DIR/repos.txt"

if [ ! -f "$REPOS_FILE" ]; then
    echo "Error: repos.txt not found."
    echo "       cp repos.txt.example repos.txt  and fill in your repo paths."
    exit 1
fi

PASS=()
FAIL=()

while IFS= read -r line || [ -n "$line" ]; do
    # Skip blank lines and comments
    [[ -z "$line" || "$line" == \#* ]] && continue

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "▶ $line"
    echo ""

    if bash "$SCRIPT_DIR/upgrade.sh" "$line" "$@"; then
        PASS+=("$line")
    else
        FAIL+=("$line")
        echo "⚠️  upgrade failed for $line — continuing with next repo"
    fi

    echo ""
done < "$REPOS_FILE"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Done. ${#PASS[@]} succeeded, ${#FAIL[@]} failed."

if [ ${#FAIL[@]} -gt 0 ]; then
    echo ""
    echo "Failed repos:"
    for r in "${FAIL[@]}"; do
        echo "  ✗ $r"
    done
    exit 1
fi
