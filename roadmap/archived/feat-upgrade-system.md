---
status: done
priority: high
owner: "@rabb1tl0ka + @claude-sonnet-4-6"
---

# Feature Spec: Upgrade System for repo-roadmap Convention

## One-Line Overview
Replace the fragile sentinel/text-patching upgrade approach with a resilient system using `@file` imports, atomic template replacement, and an audit-first content migration flow.

## Goal
Give repo-roadmap a proper install + upgrade lifecycle. `install.sh` sets up a target repo once. `upgrade.sh` brings an existing install up to the latest convention version — replacing templates and the instructions file atomically, never touching user content files automatically, and reporting what still needs manual migration.

## Expected advantages / benefits

- No bash text manipulation on files humans also edit
- `CLAUDE.md` in target repos never needs to change after initial install
- Upgrade is safe to run multiple times (fully idempotent)
- User reviews every content file change — no silent wrong defaults
- Version tracking via git tags makes it clear what's applied and what's new

## Downsides / risks

- `@file` import in CLAUDE.md is a Claude Code feature — other AI tools won't pick it up automatically
- Requires tagging repo-roadmap releases (lightweight discipline required)
- Content migration (frontmatter patching) is interactive — not fully automated

## Context

### Current flow
1. `install.sh <target>` copies `roadmap/` and appends `CLAUDE.md` content to the target.
2. No upgrade path exists. If the convention changes, the user must manually diff and patch.
3. Existing roadmap files in the target have no frontmatter — status, priority, owner are missing.

### Proposed flow

**Install (first time):**
1. `bash install.sh <target>` copies templates to `roadmap/` root.
2. Creates `roadmap/CLAUDE-roadmap.md` in the target (fully owned by convention).
3. Appends a single line to target's `CLAUDE.md`: `@roadmap/CLAUDE-roadmap.md`
4. Writes `.roadmap-version` with the current git tag.

**Upgrade (existing install):**
1. `bash upgrade.sh <target>` reads `.roadmap-version` to know the last applied tag.
2. Replaces templates (`template-feat.md`, `template-idea.md`, `template-challenge.md`) at `roadmap/templates/`.
3. Replaces `roadmap/CLAUDE-roadmap.md` wholesale.
4. Scans all `feat-*`, `idea-*`, `challenge-*` files and prints an **audit report**: which files are missing frontmatter, which are missing `owner`, which are missing `## One-Line Overview`.
5. Does NOT auto-patch content files. User runs migration interactively with Claude Code.
6. Updates `.roadmap-version` to the new tag.

### Files involved
- `install.sh` — rewrite to use new flow
- `upgrade.sh` — new script
- `CLAUDE.md` — extract roadmap instructions into `roadmap/CLAUDE-roadmap.md`; `CLAUDE.md` becomes a thin wrapper
- `roadmap/CLAUDE-roadmap.md` — new file, the canonical convention instructions (replaces the inline block)

---

## Design

### `roadmap/CLAUDE-roadmap.md`
Contains exactly what is currently in `CLAUDE.md` under `## Roadmap Convention` and `## Roadmap Management Rules`. This file is fully owned by the convention — safe to replace on every upgrade. Target repos import it via a single line in their `CLAUDE.md`:

```
@roadmap/CLAUDE-roadmap.md
```

### `install.sh` rewrite

```
install.sh <target-repo-path>
```

Steps:
1. Validate target is a git repo with a clean working tree (warn if dirty, don't block).
2. If `roadmap/` already exists in target → abort with clear message ("use upgrade.sh").
3. Copy `template-feat.md`, `template-idea.md`, `template-challenge.md` to `<target>/roadmap/templates/`.
4. Copy `roadmap/README.md` to `<target>/roadmap/README.md`.
5. Copy `CLAUDE.md` (convention instructions) to `<target>/roadmap/CLAUDE-roadmap.md`.
6. Append `@roadmap/CLAUDE-roadmap.md` to `<target>/CLAUDE.md` (create if missing).
7. Write current git tag to `<target>/.roadmap-version`.
8. Print summary of what was created.

### `upgrade.sh`

```
upgrade.sh <target-repo-path>
```

Steps:
1. Read `<target>/.roadmap-version`. If missing, assume `v0` (pre-convention).
2. Print: "Upgrading from <last-tag> → <current-tag>".
3. Replace templates at `<target>/roadmap/` root.
4. Replace `<target>/roadmap/CLAUDE-roadmap.md` wholesale.
5. Scan all `feat-*`, `idea-*`, `challenge-*` files and emit audit report (see below).
6. Update `<target>/.roadmap-version`.

### Audit report format

```
=== repo-roadmap upgrade audit ===
Convention: v0.1.0 → v0.2.0

✅ Templates replaced (3 files)
✅ CLAUDE-roadmap.md updated

⚠️  Content files needing migration (run: claude "migrate roadmap frontmatter"):
  roadmap/feat-team-aitpm.md          — missing: frontmatter, One-Line Overview
  roadmap/idea-on-demand-digest.md    — missing: frontmatter, One-Line Overview
  roadmap/challenge-orphaned-slack-drafts.md — missing: frontmatter, One-Line Overview
  ... (10 more)

Run the above Claude Code command to migrate interactively.
Upgrade complete. Review the above before committing.
```

### Content migration (interactive, Claude Code)

When the user runs `claude "migrate roadmap frontmatter"`, Claude Code:
1. Reads the audit report (or rescans).
2. For each file: reads it, infers reasonable `status`/`priority` from content, proposes frontmatter + One-Line Overview.
3. Shows the proposed change, waits for user confirmation before writing.
4. Never auto-assigns `status: in-progress` or `owner` — leaves those for the user.

### Version tracking

- repo-roadmap uses lightweight git tags: `v0.1.0`, `v0.2.0`, etc.
- `.roadmap-version` in target repos stores the last applied tag (one line).
- If `.roadmap-version` is missing: treated as `v0` — upgrade applies everything.
- `.roadmap-version` should be committed in the target repo.

---

## Changes required

| File | Change |
|---|---|
| `install.sh` | Full rewrite — new flow, no roadmap/ overwrite guard, writes `.roadmap-version` |
| `upgrade.sh` | New file — replace templates + CLAUDE-roadmap.md, emit audit report |
| `roadmap/CLAUDE-roadmap.md` | New file — extracted from `CLAUDE.md`, fully convention-owned |
| `CLAUDE.md` | Remove inline roadmap instructions block; keep only what's repo-roadmap-meta |
| `roadmap/README.md` | No structural change — table stays auto-generated |
| `.roadmap-version` | New file in repo-roadmap root (tags itself as the source) |

---

## Implementation steps

1. Tag current state of repo-roadmap as `v0.1.0`
2. Create `roadmap/CLAUDE-roadmap.md` by extracting the roadmap management rules from `CLAUDE.md`
3. Update `CLAUDE.md` to import via `@roadmap/CLAUDE-roadmap.md`
4. Rewrite `install.sh`
5. Write `upgrade.sh`
6. Write `.roadmap-version` at root of repo-roadmap
7. Test install on a clean temp dir
8. Test upgrade against `~/loka/code/claude-aitpm`
9. Run interactive migration on claude-aitpm's 13 existing roadmap files

---

## Test plan

1. **Fresh install test**: run `install.sh` on a clean temp git repo → verify templates at `roadmap/` root, `CLAUDE-roadmap.md` present, `CLAUDE.md` has `@roadmap/CLAUDE-roadmap.md`, `.roadmap-version` correct
2. **Idempotency test**: run `upgrade.sh` twice → no duplicate content, `.roadmap-version` unchanged on second run
3. **Audit report test**: run `upgrade.sh` against claude-aitpm → verify report lists all 13 files missing frontmatter, no files were auto-patched
4. **CLAUDE.md safety test**: run `install.sh` on a repo with existing `CLAUDE.md` → verify existing content untouched, only `@roadmap/CLAUDE-roadmap.md` appended
5. **Migration test**: run interactive migration on claude-aitpm → verify all 13 files get correct frontmatter + One-Line Overview, user confirms each

---

## Open questions

1. Should `upgrade.sh` require a clean git working tree in the target, or just warn?
2. Should `.roadmap-version` be added to `.gitignore` of target repos, or committed? (Current assumption: committed, so it's auditable.)
3. Should upgrade.sh warn if templates are NOT in `roadmap/templates/` (i.e., a very old install with templates at root)?
