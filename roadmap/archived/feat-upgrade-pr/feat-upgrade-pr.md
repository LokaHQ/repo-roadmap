---
status: done
priority: medium
owner: "@rabb1tl0ka"
---

# Feature Spec: Automated Upgrade PR

## One-Line Overview
Add a `--create-pr` flag to `upgrade.sh` that branches, commits, pushes, and opens a changelog-driven PR so upgrades land as reviewable changes instead of direct commits.

## Goal
By default `upgrade.sh` continues to commit directly to the current active branch. When `--create-pr` is passed, it additionally creates a branch `chore/roadmap-upgrade-vX.Y.Z`, commits the changes, pushes, and opens a GitHub PR with a description generated from the git log of the repo-roadmap source between the previous and current version tags.

## Expected advantages / benefits

- Upgrades are always reviewable before merging — no surprise changes on main
- PR description is auto-generated from real commit history — zero extra maintenance
- Consistent branch/commit naming across all repos
- `gh` unavailability is handled gracefully: branch is still pushed, user gets a clear message

## Downsides / risks

- Requires `gh` CLI installed and authenticated when `--create-pr` is used
- If the target repo doesn't use GitHub, `gh pr create` will fail (handled gracefully)
- Branch may already exist if a previous upgrade PR was never merged

## Context

### Current flow
1. User runs `bash upgrade.sh <target>`
2. Script replaces convention files in place on the current branch
3. User manually stages, commits, branches, pushes, and creates a PR

### Proposed flow (default — unchanged)
1. User runs `bash upgrade.sh <target>`
2. Script applies all file changes and commits directly to the current branch (existing behavior)

### Proposed flow (`--create-pr`)
1. User runs `bash upgrade.sh <target> --create-pr`
2. Script applies all file changes
3. Script creates branch `chore/roadmap-upgrade-vX.Y.Z`, commits, and pushes
4. If `gh` is available and authenticated → opens PR against the repo's default branch, prints PR URL
5. If `gh` is missing or unauthenticated → prints clear message with install/auth instructions; branch is still pushed

### Files involved
- `upgrade.sh` — all new logic goes here

**Branch:** `feat/upgrade-pr`

---

## Design

### Flag parsing

```bash
CREATE_PR=false
for arg in "$@"; do
    case $arg in
        --create-pr) CREATE_PR=true ;;
    esac
done
```

### Branch creation (only when `--create-pr`)

```bash
BRANCH="chore/roadmap-upgrade-${CURRENT_TAG}"

if git -C "$TARGET" show-ref --verify --quiet "refs/heads/$BRANCH"; then
    echo "⚠️  Branch $BRANCH already exists. Delete it or merge the existing PR first."
    exit 1
fi

git -C "$TARGET" checkout -b "$BRANCH"
```

### Commit

```bash
git -C "$TARGET" add roadmap/ CLAUDE.md .roadmap-version
git -C "$TARGET" commit -m "chore: upgrade repo-roadmap convention ${LAST_TAG} → ${CURRENT_TAG}"
git -C "$TARGET" push -u origin "$BRANCH"
```

### `gh` check and PR creation

```bash
if ! command -v gh &>/dev/null; then
    echo ""
    echo "✅ Branch pushed: $BRANCH"
    echo "⚠️  GitHub CLI (gh) not found — skipping PR creation."
    echo "   Install: https://cli.github.com, then run: gh pr create"
    exit 0
fi

if ! gh auth status &>/dev/null; then
    echo ""
    echo "✅ Branch pushed: $BRANCH"
    echo "⚠️  gh is not authenticated — skipping PR creation."
    echo "   Run: gh auth login, then run: gh pr create"
    exit 0
fi

DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name -C "$TARGET")
```

### Changelog generation

```bash
CHANGELOG=$(git -C "$SCRIPT_DIR" log "${LAST_TAG}..${CURRENT_TAG}" --oneline 2>/dev/null)

if [ -z "$CHANGELOG" ]; then
    CHANGELOG="No changelog available (tags missing or first install)."
fi

# Format as markdown list
CHANGELOG_MD=$(echo "$CHANGELOG" | sed 's/^/- /')
```

### PR body (assembled as a heredoc)

```bash
PR_BODY=$(cat <<EOF
## repo-roadmap upgrade: ${LAST_TAG} → ${CURRENT_TAG}

### What changed upstream
${CHANGELOG_MD}

### Files updated
$(git -C "$TARGET" diff --name-only HEAD~1 HEAD)
EOF
)

gh pr create \
  --base "$DEFAULT_BRANCH" \
  --title "chore: upgrade repo-roadmap convention ${LAST_TAG} → ${CURRENT_TAG}" \
  --body "$PR_BODY"
```

---

## Changes required

| File | Change |
|------|--------|
| `upgrade.sh` | Add `--create-pr` flag parsing, branch creation, push, `gh` check, `gh pr create` |

---

## Test plan

1. Run `upgrade.sh <target>` (no flag) → verify direct commit to current branch, no branch created
2. Run `upgrade.sh <target> --create-pr` with `gh` not installed → verify branch pushed, clear install message printed
3. Run `upgrade.sh <target> --create-pr` with `gh` not authenticated → verify branch pushed, clear auth message printed
4. Run `upgrade.sh <target> --create-pr` with `gh` ready → verify branch created, PR opened against default branch, PR URL printed
5. Run `--create-pr` again on same repo (branch exists) → verify clear error message, exit 1
6. Run on a repo with no `.roadmap-version` → verify fallback changelog message, PR still created

---

## Open questions

None — all resolved.
