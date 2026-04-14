---
status: done
priority: medium
owner: "@rabb1tl0ka + @claude-sonnet-4-6"
---

# Feature Spec: Workspace Per Roadmap Item

## One-Line Overview
Replace the flat `roadmap/` file layout with per-item subdirectories so each feat, idea, and challenge has a dedicated workspace for specs, docs, and research artifacts.

## Goal
Give every roadmap item its own directory inside `roadmap/`, containing the spec file plus any supporting material (docs, research, references). Items that never need a workspace stay as flat files. Completed items move to `roadmap/archived/`.

## Expected advantages / benefits

- Research artifacts, reference docs, and notes have a natural home co-located with the spec
- Roadmap stays self-contained — no parallel directories at repo root
- Flat files still supported for simple items that don't need a workspace
- Archiving is a directory move, not a deletion — full history preserved alongside the spec
- Convention remains installable/upgradeable via existing `install.sh` / `upgrade.sh`

## Downsides / risks

- Table scanner in `roadmap/README.md` needs to handle both flat files and one-level-deep subdirs
- `CLAUDE-roadmap.md` instructions need to be updated to describe the new layout
- Existing flat items in target repos don't auto-migrate — users must promote them manually if they want a workspace
- Slightly more friction to create a new item (need to mkdir + create file vs. just create file)

## Context

### Current flow
1. Every roadmap item is a flat `.md` file in `roadmap/` (e.g. `roadmap/feat-upgrade-system.md`)
2. No place to store supporting docs or research artifacts alongside the spec
3. Done items stay in the table until manually removed — no archive concept

### Proposed flow
1. New items can be created as flat files OR as subdirs (`roadmap/feat-name/feat-name.md`)
2. Any item that grows supporting material gets promoted to a subdir and gains a `docs/` dir
3. Done items move to `roadmap/archived/` (preserving dir structure if they had a workspace)
4. Table scanner skips `roadmap/archived/` and handles both flat and subdir items

### Files involved
- `roadmap/CLAUDE-roadmap.md` — update instructions to describe new layout, archiving, and scanner behavior
- `roadmap/README.md` — table scanner must handle subdirs + skip `archived/`
- `install.sh` — create `roadmap/archived/` on fresh install
- `upgrade.sh` — create `roadmap/archived/` if missing on upgrade

**Branch:** `feat/workspace-per-item`

---

## Design

### Directory structure

```
roadmap/
  feat-upgrade-system/          ← item with workspace
    feat-upgrade-system.md
    docs/
  idea-async-digests.md         ← flat item (no workspace needed)
  challenge-something/
    challenge-something.md
    docs/
  archived/
    feat-old-thing/             ← archived item with workspace
      feat-old-thing.md
      docs/
    idea-dropped-concept.md     ← archived flat item
  templates/
  README.md
  CLAUDE-roadmap.md
```

### Table scanner logic (updated)
1. Scan `roadmap/` for entries matching `feat-*`, `idea-*`, `challenge-*`
2. For each entry:
   - If it's a `.md` file → parse directly
   - If it's a directory → look for `<dirname>.md` inside it
3. Skip anything inside `roadmap/archived/`
4. Build table as before (status, priority, owner, one-line overview)

### Archiving
- Move the entire item (file or directory) into `roadmap/archived/`
- Update the table (item disappears from active table)
- No deletion — full history stays in place

### Promotion (flat → workspace)
- When a flat item needs a workspace: `mkdir roadmap/feat-name && mv roadmap/feat-name.md roadmap/feat-name/`
- Add `docs/` dir as needed
- Table scanner picks up the new location automatically

---

## Changes required

| File | Change |
|---|---|
| `roadmap/CLAUDE-roadmap.md` | Document new layout, subdir convention, archiving, promotion |
| `roadmap/README.md` | Update table scanner to handle subdirs + skip `archived/` |
| `install.sh` | Create `roadmap/archived/` on fresh install |
| `upgrade.sh` | Create `roadmap/archived/` if missing on upgrade |

---

## Test plan

1. **Flat item still works**: create `roadmap/idea-test.md` → verify it appears in table
2. **Subdir item works**: create `roadmap/feat-test/feat-test.md` → verify it appears in table
3. **Mixed scan**: both flat and subdir items present → table shows both correctly
4. **Archive flat**: move `idea-test.md` to `archived/` → verify it disappears from table
5. **Archive subdir**: move `feat-test/` to `archived/` → verify it disappears from table
6. **Fresh install**: run `install.sh` on clean repo → verify `roadmap/archived/` exists
7. **Upgrade**: run `upgrade.sh` on old install → verify `roadmap/archived/` created if missing

---

## Open questions

1. Should Claude Code auto-promote a flat item to a subdir when asked to create a `docs/` for it, or require explicit user instruction? [Bruno: yes]
2. Should `archived/` items be listed in a separate collapsed table in `README.md`, or omitted entirely? [Bruno: ommited]
3. Should `docs/` be created automatically on subdir creation, or only when the user drops something in? [Bruno: auto add it]
