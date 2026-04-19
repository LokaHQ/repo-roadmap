---
status: review
priority: medium
owner: ""
---

# Challenge: No E2E Test for upgrade.sh + gh Integration

## One-Line Overview
`upgrade.sh` shipped with a broken `gh` flag (`-C`) that wasn't caught because there's no end-to-end test covering the `--create-pr` path against a real git repo and `gh` CLI.

## What's the problem

The `gh repo view -C` flag doesn't exist — `gh` doesn't support `-C` like `git` does. This bug slipped through because the script was only syntax-checked (`bash -n`), not run against a real target repo with `--create-pr`. The fix (using `cd "$TARGET" && gh ...` subshells) was applied after the fact.

## Why it matters

Scripts that touch git state and call external CLIs (`gh`) need to be run, not just parsed. Syntax checks don't catch wrong flags, wrong working directories, or `gh` GraphQL errors. Any future change to the `--create-pr` path could regress silently.

## Constraints

- Must: exercise the full `--create-pr` path against a real (local) git repo
- Must: catch `gh` CLI flag errors and GraphQL failures
- Must not: require a real GitHub remote (use a local bare repo or mock where possible)
- Must not: add heavy CI infrastructure — this is a lean, script-based project

## Approaches considered

| Approach | Status | Why ruled out / still open |
|----------|--------|----------------------------|
| `bash -n` syntax check only | Ruled out | Doesn't execute — misses flag errors, wrong cwd, gh failures |
| Manual test run on real repos | Current state | Catches issues but only after shipping |
| `test-upgrade.sh` script with a local bare repo + `gh` mock | Likely fix | Create a temp git repo, run upgrade.sh against it, assert outputs and branch state. Mock or skip `gh pr create` with an env flag. Needs confirmation it's sufficient. |

## Open questions

1. Is a `test-upgrade.sh` with a local bare repo + skipped `gh pr create` sufficient coverage, or do we need a real GitHub remote in CI?
2. Should `upgrade.sh` support a `--dry-run` flag that skips push and PR creation, making it easier to test locally?
