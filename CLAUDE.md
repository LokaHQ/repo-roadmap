# Claude Code Instructions — repo-roadmap

@roadmap/CLAUDE.md

## Working on this repo

This repo is the source of the repo-roadmap convention. It dogfoods its own system — use it to track its own features, ideas, and challenges.

## Versioning

Version is tracked via **git tags** (semver: `vMAJOR.MINOR.PATCH`).

- **Patch** (`v0.x.Y+1`): bug fixes, typo corrections, script fixes
- **Minor** (`v0.X.0`): structural changes, new features, file renames, convention updates
- **Major** (`v1.0.0`): breaking changes requiring migration in user repos

To release:
```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

`install.sh` and `upgrade.sh` read the current tag via `git describe --tags --abbrev=0` and stamp it into `.roadmap-version` in the target repo.

## Release checklist
- All changes committed
- `install.sh` and `upgrade.sh` updated if any installed filenames changed
- Tag created and pushed
