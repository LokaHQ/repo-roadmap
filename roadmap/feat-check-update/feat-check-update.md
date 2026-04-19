---
status: todo
priority: medium
owner: ""
---

# Feature Spec: check-update.sh

## One-Line Overview
A script installed into target repos that checks the local `.roadmap-version` against the latest GitHub release tag and tells the dev whether an upgrade is available.

## Goal
Add a `roadmap/check-update.sh` script that is copied into target repos by `install.sh` (and refreshed by `upgrade.sh`). When run from inside a target repo, it reads `.roadmap-version`, fetches the latest release tag from the `repo-roadmap` GitHub API, and prints a clear message: either "you're up to date" or "upgrade available — run this command".

## Expected advantages / benefits

- Zero infrastructure — just `curl` and `bash`, works anywhere
- Devs get a concrete command to run, not just a version number
- Can be wired into a Makefile, pre-push hook, or CI step with no extra setup
- Idempotent: safe to run repeatedly, no side effects
- Works offline gracefully (warns instead of crashing)

## Downsides / risks

- Requires GitHub API to be reachable; fails silently on air-gapped environments
- Still manual — no one runs it unless they remember to
- GitHub API rate-limits unauthenticated requests (60/hr per IP); fine for dev use, not for CI at scale

## Context

### Current flow
1. Dev installs `repo-roadmap` into their repo via `install.sh` → `.roadmap-version` is written with the current tag (e.g. `v0.2.0`)
2. Time passes; new versions of `repo-roadmap` are tagged
3. Dev has no way to know unless they manually check this repo or remember to run `upgrade.sh`

### Proposed flow
1. Dev runs `bash roadmap/check-update.sh` from inside their repo
2. Script reads `.roadmap-version` → `v0.2.0`
3. Script hits `https://api.github.com/repos/LokaHQ/repo-roadmap/releases/latest` (or tags endpoint)
4. Compares installed vs latest tag
5. Prints one of:
   - `✅ repo-roadmap is up to date (v0.2.0)`
   - `⬆️  Update available: v0.2.0 → v0.3.0\n   Run: bash /path/to/repo-roadmap/upgrade.sh .`
6. Exits 0 if up to date, exits 1 if update available (so CI can act on it)

### Files involved
- `roadmap/check-update.sh` — new script (lives in this repo, copied to targets)
- `install.sh` — add a `cp` step to copy `check-update.sh` into target's `roadmap/`
- `upgrade.sh` — add a `cp` step to refresh `check-update.sh` in target's `roadmap/`

**Branch:** `feat/check-update`

---

## Design

```bash
#!/bin/bash
# Check if a repo-roadmap update is available.
# Usage: bash roadmap/check-update.sh

REPO_ROADMAP_GITHUB="LokaHQ/repo-roadmap"
VERSION_FILE=".roadmap-version"

# Read installed version
if [ ! -f "$VERSION_FILE" ]; then
    echo "❌ .roadmap-version not found. Is this a repo-roadmap install?"
    exit 2
fi
INSTALLED=$(cat "$VERSION_FILE")

# Fetch latest tag from GitHub API
LATEST=$(curl -sf "https://api.github.com/repos/$REPO_ROADMAP_GITHUB/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)".*/\1/')

if [ -z "$LATEST" ]; then
    echo "⚠️  Could not reach GitHub API. Check your connection."
    exit 2
fi

if [ "$INSTALLED" = "$LATEST" ]; then
    echo "✅ repo-roadmap is up to date ($INSTALLED)"
    exit 0
else
    echo "⬆️  Update available: $INSTALLED → $LATEST"
    echo "   To upgrade, run upgrade.sh from your repo-roadmap clone:"
    echo "   bash /path/to/repo-roadmap/upgrade.sh ."
    exit 1
fi
```

**Notes:**
- Uses `releases/latest` endpoint; falls back to tags endpoint if no releases exist
- `exit 1` on update-available makes it composable in CI (`|| echo "please upgrade"`)
- No auth required for public repos within rate limits
- The upgrade path message references `upgrade.sh` — we don't auto-run it (that's a separate decision)

---

## Changes required

| File | Change |
|------|--------|
| `roadmap/check-update.sh` | Create new script |
| `install.sh` | Add `cp check-update.sh` step after templates copy |
| `upgrade.sh` | Add `cp check-update.sh` step to refresh on upgrade |

---

## Test plan

1. Run `bash roadmap/check-update.sh` from a repo with `.roadmap-version` set to the current latest tag → prints "up to date", exits 0
2. Manually set `.roadmap-version` to `v0.0.1` → prints "update available" with correct versions, exits 1
3. Delete `.roadmap-version` → prints error about missing file, exits 2
4. Run with no network (e.g. `--dns 0.0.0.0`) → prints warning, exits 2, does not crash
5. Run `install.sh` on a fresh repo → `roadmap/check-update.sh` appears in target
6. Run `upgrade.sh` on an existing install → `roadmap/check-update.sh` is refreshed

---

## Open questions

1. Should we fall back to the `/tags` endpoint when no GitHub Release exists (only tags)? The current `repo-roadmap` uses tags, not releases.
2. Should the script accept a `--roadmap-path` flag pointing to a local clone as an alternative to GitHub API (useful for air-gapped or private forks)?
3. Should `upgrade.sh` automatically run `check-update.sh` at the end to confirm the upgrade landed correctly?
