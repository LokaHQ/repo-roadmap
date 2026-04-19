---
status: todo
priority: medium
owner: ""
---

# Idea: Dedicated GitHub Test Repo for E2E Script Testing

## One-Line Overview
Create a real GitHub repo (e.g. `rabb1tl0ka/repo-roadmap-test`) to run `install.sh` and `upgrade.sh` end-to-end so regressions like leftover files and double imports get caught before shipping.

## What's the idea

A throwaway GitHub repo used exclusively as the upgrade/install target in tests. A test script would install repo-roadmap on it, run an upgrade, and assert the resulting file state — catching issues that `bash -n` syntax checks and local-only tests miss entirely.

## Expected advantages / benefits

- Catches real-world regressions (leftover `CLAUDE-roadmap.md`, double imports, broken `gh` calls) before they reach user repos
- Tests the full path: file changes + branch creation + `gh pr create`
- Gives confidence to ship new `upgrade.sh` features without manual validation on real repos

## Downsides / risks

- Requires a real GitHub repo and `gh` auth in CI or local test runner
- Test setup/teardown needs to reset the repo state between runs (branch deletion, file resets)
- `gh pr create` in tests creates real PRs — needs a cleanup strategy or a `--dry-run` escape hatch

## What's been tried already

None. The current test plan only covers syntax checks and local exit code behavior. Two real bugs slipped through as a result:
- `gh -C` flag not supported (wrong working directory approach)
- `roadmap/CLAUDE-roadmap.md` left behind after rename, not deleted by upgrade script
- Double `@roadmap/CLAUDE*.md` import in target `CLAUDE.md`

## Open questions

1. Should this be a public or private repo? Public is simpler for CI, private avoids noise.
2. Should the test script reset state by force-pushing a known baseline branch, or by deleting and recreating the repo?
3. Is this worth wiring into a CI pipeline now, or keep it a manual test script run before tagging a release?
