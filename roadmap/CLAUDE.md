# Roadmap Convention

This repo uses a `roadmap/` directory to track features, ideas, and challenges.

## Directory structure

```
roadmap/
  feat-name/              ← workspace item (spec + supporting material)
    feat-name.md
    docs/
  idea-simple.md          ← flat item (no workspace needed)
  archived/               ← completed or abandoned items (omitted from table)
  templates/
  README.md
  CLAUDE.md
```

Every roadmap entry is either:
- A **flat `.md` file** — simple items with no supporting material
- A **workspace directory** — items with a spec file + `docs/` for research, references, and artifacts

## File naming

Every roadmap entry uses one of three prefixes:
- `feat-` — fully specced feature, ready to implement
- `idea-` — early exploration, not yet fully designed
- `challenge-` — known problem, solution still open

## Reviewing specs

Use `[YourName: your comment]` to annotate specs inline. Claude Code will recognize these as reviewer comments when asked to review them.

## Roadmap Management Rules (Strict - Always Follow)

You are the active maintainer of the roadmap in the `roadmap/` directory.

### Frontmatter (minimal)
Every roadmap file must start with this exact frontmatter block:

---
status: todo | in-progress | done | blocked | review | rejected
priority: high | medium | low
owner: ""
phase: ""
depends_on: []
---

- Default new items to `status: todo`, `priority: medium`, `owner: ""`, `phase: ""`, `depends_on: []`
- When someone picks up an item, set `status: in-progress` and `owner: <handle>` (e.g. `@rabb1tl0ka`, `@claude-code`)
- Update `status`, `priority`, `owner`, `phase`, and `depends_on` whenever you or the user changes the state of an item.
- Never remove the frontmatter once added.

### Phase

`phase` is an optional label that groups items into a high-level timeline. Examples: `"1"`, `"2"`, `"mvp"`, `"alpha"`. Leave empty (`""`) if the item has no phase assignment yet.

- Items in the same phase ship together — phase is a grouping, not a strict gate
- Sort items in the table by phase first (numeric phases first, unassigned last)
- Leave empty by default — only set when the user specifies a phase

### Dependencies

`depends_on` is a list of slugs this item should not be started before. Examples:
- `depends_on: ["feat-rag-memory"]`
- `depends_on: ["feat-twin-discussion-mode", "challenge-hero-build"]`
- `depends_on: []` — no dependencies

Rules:
- Slugs must match the filename prefix of the target item (e.g. `feat-rag-memory`, not the full path)
- When a user picks up an item, check its `depends_on` list and warn if any dependency is not `done`
- When generating the table, resolve each slug to a markdown link (see table generation rules below)

### Status values

| Status | Emoji | Meaning |
|--------|-------|---------|
| `todo` | ⏳ | Not started |
| `in-progress` | 🚧 | Actively being worked on |
| `done` | ✅ | Complete |
| `review` | 🔍 | Ready for review |
| `blocked` | ❌ | Cannot proceed — external impediment that may clear on its own |
| `rejected` | 🚫 | Deliberate decision not to pursue (not the same as blocked) |

**blocked vs rejected:**
- `blocked` = something outside our control is holding it back; it may become unblocked
- `rejected` = a conscious decision was made not to pursue this, at least for now

**When marking an item `rejected`:**
1. Add a `## Why this was rejected` section to the spec explaining the reasoning
2. For workspace items, you may put the rationale in `docs/why-this-was-rejected.md` instead and reference it from the spec
3. Then update `status: rejected` and refresh the table
4. Do NOT archive rejected items — keep them visible in the table so the decision is on record

### One-Line Overview
Every file must have a `## One-Line Overview` section right after the main title.
- It must be **one single, crisp sentence**.
- It should cohesively describe the problem-solution space (not just the goal).
- Keep it concise, high-signal, and useful for the overview table.

### When asked to save a feature, idea, or challenge

1. Use the matching template from `roadmap/templates/template-feat.md`, `roadmap/templates/template-idea.md`, or `roadmap/templates/template-challenge.md`
2. Create as a **workspace directory**:
   - `mkdir roadmap/<prefix>-<slug>/`
   - Create `roadmap/<prefix>-<slug>/<prefix>-<slug>.md` from the template
   - Create `roadmap/<prefix>-<slug>/docs/` (always auto-create this)
3. Add a row to the `## Current roadmap` table in `roadmap/README.md`

### Promotion (flat → workspace)

When a user asks to create a `docs/` directory for a flat item, auto-promote it:
1. Create `roadmap/<prefix>-<slug>/` directory
2. Move `roadmap/<prefix>-<slug>.md` into it
3. Create `roadmap/<prefix>-<slug>/docs/`
4. Update the table link to point to the subdir spec

### When asked to load or work on a roadmap entry

Read the relevant file in full before starting — branch name, implementation steps, test plan, and open questions are all in there. Present a plan and wait for explicit approval before writing any code.

### How to execute a roadmap item

The same loop applies whether implementing a feature or fixing a bug. The starting point differs; the loop doesn't.

**For features:** the spec defines what "done" looks like — use it as your north star.
**For bugs:** start by reproducing the bug — that *is* your first test. It must fail before you fix anything.

1. **Plan** — read the spec in full, then present a step-by-step implementation plan and wait for explicit approval before writing any code.

2. **Test each step as you go**
   - After each significant step, run the smallest test that confirms it worked
   - What files should exist? → `ls`, `find`
   - What should be in them? → `grep`, `Read`
   - What commands should work? → run them
   - What behavior should change? → test before and after

3. **When a test fails**
   - 3.1 Find what's wrong in the code, fix it, run the test again
   - 3.2 If a test keeps failing after genuine attempts — question the test itself. A broken test is still a bug.

4. **E2E at the end** — once every step passes, test the full feature end-to-end. Individual steps working is not the same as the goal being achieved.

**Ambiguity is fragility:** when in doubt about requirements or intent — don't assume, ask.

### When asked to archive an item

When marking an item as done or explicitly archiving:
1. Update `status: done` in the spec file
2. Move the entire item (file or directory) to `roadmap/archived/`
3. Remove from the active table in `roadmap/README.md`

Note: rejected items are NOT archived — they stay in the table so the decision remains visible.

### Automatic Table Maintenance
After **any** of the following actions, you **must** regenerate the entire "Current roadmap" table in `roadmap/README.md`:

- Creating a new `feat-`, `idea-`, or `challenge-` file or workspace
- Updating status, priority, phase, depends_on, or the One-Line Overview of any roadmap file
- Marking something as done, in-progress, blocked, rejected, etc.
- Archiving, deleting, or renaming a roadmap item

**How to generate the table:**
1. Scan `roadmap/` for entries matching `feat-*`, `idea-*`, `challenge-*`:
   - If it's a `.md` file → parse directly
   - If it's a directory → look for `<dirname>.md` inside it (e.g. `roadmap/feat-name/feat-name.md`)
   - Skip anything inside `roadmap/archived/`
2. Parse the frontmatter for status, priority, phase, and depends_on
3. Extract the exact text from the `## One-Line Overview` section
4. Build the markdown table with these columns:
   - **File**: flat: `[feat-name.md](feat-name.md)` / workspace: `[feat-name/](feat-name/feat-name.md)`
   - **Phase**: frontmatter `phase` value, or `—` if empty
   - **Status**: ✅ done, 🚧 in-progress, ⏳ todo, ❌ blocked, 🔍 review, 🚫 rejected
   - **Priority**: high / medium / low
   - **Deps**: for each slug in `depends_on`, generate a markdown link — workspace item: `[slug](slug/slug.md)`, flat item: `[slug](slug.md)`. Multiple deps: comma-separated. Empty: `—`
   - **Owner**: empty string if unset
   - **One-Line Overview**
5. Sort the table by: phase (numeric ascending, unassigned last), then type (feat → idea → challenge), then priority (high → medium → low), then filename
6. Place the new table under the "## Current roadmap" heading. Keep the note: "(The table above is automatically maintained by Claude Code. Do not edit it manually.)"

### Useful Commands You Should Recognize
- "Update roadmap table" → Regenerate the full table now
- "Show roadmap" or "Show current roadmap" → Print a nicely formatted summary grouped by type
- "Mark [filename] as done/in-progress/blocked" → Update frontmatter + refresh table
- "Set priority of [filename] to high/medium/low" → Update + refresh table
- "Set phase of [filename] to [phase]" → Update `phase` frontmatter + refresh table
- "Pick [filename]" or "I'm picking [filename]" → Set `status: in-progress` + `owner: <handle>` + check depends_on for unmet deps + refresh table
- "Archive [item]" → Mark done, move to `roadmap/archived/`, remove from table
- "Reject [item]" → Prompt for rationale, add `## Why this was rejected` section to spec, set `status: rejected`, refresh table

When the user asks you to create a new feature, idea, or challenge, always:
1. Create the workspace directory and spec file using the correct template
2. Create `docs/` inside the workspace
3. Fill in a strong One-Line Overview
4. Add the frontmatter (`phase` and `depends_on` default to empty — only set them if the user specified values)
5. Immediately update the central table
