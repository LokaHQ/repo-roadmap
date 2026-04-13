# Claude Code Instructions

## Roadmap Convention

This repo uses a `roadmap/` directory to track features, ideas, and challenges.

### File naming

Every roadmap entry is a markdown file with one of three prefixes:
- `feat-` — fully specced feature, ready to implement
- `idea-` — early exploration, not yet fully designed
- `challenge-` — known problem, solution still open

## Roadmap Management Rules (Strict - Always Follow)

You are the active maintainer of the roadmap in the `roadmap/` directory.

### Frontmatter (minimal)
Every roadmap file must start with this exact frontmatter block:

---
status: todo | in-progress | done | blocked | review
priority: high | medium | low
---

- Default new items to `status: todo` and `priority: medium`
- Update `status` and `priority` whenever you or the user changes the state of an item.
- Never remove the frontmatter once added.

### One-Line Overview
Every file must have a `## One-Line Overview` section right after the main title.
- It must be **one single, crisp sentence**.
- It should cohesively describe the problem-solution space (not just the goal).
- Keep it concise, high-signal, and useful for the overview table.

### When asked to save a feature, idea, or challenge

1. Use the matching template from `roadmap/template-feat.md`, `roadmap/template-idea.md`, or `roadmap/template-challenge.md`
2. Save the file as `roadmap/<prefix>-<slug>.md`
3. Add a row to the `## Current roadmap` table in `roadmap/README.md`

### When asked to load or work on a roadmap entry

Read the relevant file in full before starting — branch name, implementation steps, test plan, and open questions are all in there. Present a plan and wait for explicit approval before writing any code.

### Automatic Table Maintenance
After **any** of the following actions, you **must** regenerate the entire "Current roadmap" table in `roadmap/README.md`:

- Creating a new `feat-`, `idea-`, or `challenge-` file
- Updating status, priority, or the One-Line Overview of any roadmap file
- Marking something as done, in-progress, blocked, etc.
- Deleting or renaming a roadmap file

**How to generate the table:**
1. Scan all files in `roadmap/` that start with `feat-`, `idea-`, or `challenge-`
2. Parse the frontmatter for status and priority
3. Extract the exact text from the `## One-Line Overview` section
4. Build the markdown table with these columns:
   - File
   - Status (use emojis: ✅ done, 🚧 in-progress, ⏳ todo, ❌ blocked, 🔍 review)
   - Priority
   - One-Line Overview
5. Sort the table by: type (feat → idea → challenge), then priority (high → medium → low), then filename
6. Place the new table under the "## Current roadmap" heading. Keep the note: "(The table above is automatically maintained by Claude Code. Do not edit it manually.)"

### Useful Commands You Should Recognize
- "Update roadmap table" → Regenerate the full table now
- "Show roadmap" or "Show current roadmap" → Print a nicely formatted summary grouped by type
- "Mark [filename] as done/in-progress/blocked" → Update frontmatter + refresh table
- "Set priority of [filename] to high/medium/low" → Update + refresh table

When the user asks you to create a new feature, idea, or challenge, always:
1. Create the file using the correct template
2. Fill in a strong One-Line Overview
3. Add the frontmatter
4. Immediately update the central table