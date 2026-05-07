---
status: blocked
priority: medium
owner: ""
phase: ""
depends_on: ["feat-notion-publish-page"]
---

# Feature Spec: Notion Publish — Database

> **Before implementing this — read this note.**
>
> A simpler version of this was already piloted in `~/loka/projects/zenqms/zenqms-ai-2ndbrain` (ZenQMS SOW4 repo).
> That implementation publishes archived roadmap items as **child pages under a single Notion parent page** (not a database),
> using the Notion MCP `notion-create-pages` tool. No schema, no Status property mapping, no opt-in plumbing.
>
> Key decisions made there that are worth reconsidering before going the database route:
> - Publish **on archive only** — items are static by then, so idempotent updates are unnecessary
> - Full markdown content, frontmatter stripped, plain title (no emoji/type prefix)
> - `notion_url` written back to the archived spec's frontmatter as the "already published" signal
> - Instructions live in the **project-level CLAUDE.md**, not `roadmap/CLAUDE.md` — keeps the roadmap convention upgradeable
>
> The database approach (this spec) adds Status sync, schema awareness, and idempotent updates — worth it
> if you need Notion filtering/views across many items or live (non-archived) publishing. If you're just
> sharing resolved items with a small internal audience, the simpler page-based approach is likely enough.

## One-Line Overview
Publish any roadmap item to a Notion database with a single command, storing the resulting page URL back in the item's frontmatter for future updates.

## Goal
Allow users to push roadmap items from the repo into a configured Notion database, so non-technical collaborators can read and comment on items without needing repo access. Publishing is one-way (repo → Notion), manually triggered, and idempotent: the first publish creates the Notion page, subsequent publishes update it in place.

## Expected advantages / benefits

- Non-repo users get visibility into roadmap items without needing Git access
- Comments left on Notion pages are readable by Claude via the Notion MCP
- No schema assumptions — works with any Notion database (title + status + body only)
- Explicit, honest naming: `notion_url` field makes the Notion dependency clear
- Idempotent: running publish twice doesn't create duplicate pages

## Downsides / risks

- Requires Notion MCP to be connected and authed in the user's Claude Code session
- Markdown → Notion block conversion may lose some formatting (tables, code blocks need testing)
- One-way sync means Notion content gets overwritten on every publish — any edits made directly in Notion will be lost
- Users must manually set `NOTION_ROADMAP_DB` in their repo's CLAUDE.md — easy to forget

## Context

### Current flow
1. User works on roadmap items locally in `roadmap/`
2. Non-repo users have no visibility unless given repo access
3. No connection between the repo and any external collaboration tool

### Proposed flow
1. User installs repo-roadmap; `install.sh` prompts "Enable Notion publishing? (y/n)"
   - Yes → injects `NOTION_ROADMAP_DB: ""` into the repo's CLAUDE.md and adds `notion_url` to templates
   - No → Notion-related fields and config are omitted entirely
2. User fills in the Notion database URL in CLAUDE.md
3. User says "publish feat-fast-sync" (or any item slug)
4. Claude:
   a. Reads the item's frontmatter and markdown content
   b. Derives the title prefix from the filename: `[feat]`, `[idea]`, or `[challenge]`
   c. Constructs the full Notion title: `[feat] Fast Sync`
   d. Checks `notion_url` in frontmatter:
      - Empty → creates a new page in the configured DB, writes the URL back to frontmatter
      - Present → updates the existing page in place
   e. Sets Notion `Status` property to match the item's frontmatter `status`
   f. Sets page body to the full markdown content (frontmatter stripped)
5. Non-repo users can now read the item in Notion and leave comments
6. User can ask Claude to "check Notion comments for feat-fast-sync" — Claude fetches them via MCP

### Files involved
- `roadmap/CLAUDE.md` — add `notion_url` to frontmatter convention; document "publish [item]" command
- `roadmap/templates/template-feat.md` — add `notion_url: ""` to frontmatter (always present in source; Claude omits it when creating new items in repos where `NOTION_ROADMAP_DB` is absent)
- `roadmap/templates/template-idea.md` — same as above
- `roadmap/templates/template-challenge.md` — same as above
- `install.sh` — add opt-in prompt; conditionally inject `NOTION_ROADMAP_DB: ""` into generated CLAUDE.md
- `upgrade.sh` — detect opt-in state via `NOTION_ROADMAP_DB` presence; add `--enable-notion` flag for retroactive opt-in

**Branch:** `feat/notion-publish`

---

## Design

### Frontmatter field
Every roadmap item gains one new optional field:

```yaml
notion_url: ""
```

- Empty string = never published
- Non-empty = URL of the existing Notion page; publish will update it

### CLAUDE.md config (per repo)
`install.sh` injects this only when the user opts in:

```
NOTION_ROADMAP_DB: ""   # Notion database URL for roadmap publishing
```

User fills in the database URL (e.g. `https://www.notion.so/loka/33646e8c...`). Claude reads this when executing a publish command.

**Presence of this line = opted in.** `upgrade.sh` uses this as the sole signal — if absent, all Notion-related upgrade steps are skipped.

### Retroactive opt-in via upgrade.sh
For users who skipped Notion at install time and want to enable it later:

```bash
upgrade.sh --enable-notion
```

This:
1. Injects `NOTION_ROADMAP_DB: ""` into the repo's CLAUDE.md
2. Adds `notion_url: ""` to all existing roadmap items that don't have it
3. Warns the user to fill in `NOTION_ROADMAP_DB` before publishing

### Title format
Prefix is derived from the item's filename:
- `feat-*` → `[feat]`
- `idea-*` → `[idea]`
- `challenge-*` → `[challenge]`

Full title: `[feat] Fast Sync` (human-readable portion comes from the `# Feature Spec: Title` heading, not the slug).

### Status mapping

| Roadmap status | Notion Status value |
|----------------|---------------------|
| `todo`         | `Not started`       |
| `in-progress`  | `In progress`       |
| `done`         | `Done`              |
| `review`       | `In review`         |
| `blocked`      | `Blocked`           |
| `rejected`     | `Cancelled`         |

(Only set if the Notion DB has a `Status` property — Claude should check the schema first and skip if not present.)

### Publish command
Recognized phrases:
- `publish feat-fast-sync`
- `publish idea-twin-mode`
- `publish [item slug]`

Claude's steps:
1. Resolve slug → file path (workspace dir or flat file)
2. Check `NOTION_ROADMAP_DB` in CLAUDE.md:
   - Absent → tell the user Notion publishing is not enabled in this repo; suggest running `upgrade.sh --enable-notion`; stop
   - Present but empty → prompt the user to provide the Notion database URL; do not proceed until provided
3. Read frontmatter + content; strip frontmatter from body before sending
4. Fetch DB schema via `notion-fetch` on `NOTION_ROADMAP_DB` to get data source ID and property names
5. If the DB schema has no `Status` property → warn the user and stop; wait for instruction before proceeding
6. If `notion_url` is empty: call `notion-create-pages`, capture returned URL
7. If `notion_url` is set: call `notion-update-page` with the existing page ID
8. Write `notion_url: <url>` back to the item's frontmatter
9. Skip roadmap table regeneration (notion_url doesn't appear in the table)

### Reading Notion comments
Recognized phrases:
- `check Notion comments for feat-fast-sync`
- `what comments are on [item slug] in Notion`

Claude fetches the page via `notion-fetch` with `include_discussions: true` and surfaces the comments inline.

---

## Changes required

| File | Change |
|------|--------|
| `roadmap/CLAUDE.md` | Add `notion_url` to frontmatter spec; document publish command and comment-reading command |
| `roadmap/templates/template-feat.md` | Add `notion_url: ""` to frontmatter block; Claude omits this field when creating new items in repos where `NOTION_ROADMAP_DB` is absent |
| `roadmap/templates/template-idea.md` | Same as above |
| `roadmap/templates/template-challenge.md` | Same as above |
| `install.sh` | Add opt-in prompt "Enable Notion publishing? (y/n)"; if yes, inject `NOTION_ROADMAP_DB: ""` into generated CLAUDE.md |
| `upgrade.sh` | Check for `NOTION_ROADMAP_DB` presence to detect opt-in state; skip all Notion steps if absent. Add `--enable-notion` flag: injects `NOTION_ROADMAP_DB: ""`, adds `notion_url: ""` to all existing items, warns user to fill in the DB URL |

---

## Test plan

**Install / upgrade opt-in flow**
1. Install fresh repo via `install.sh`, answer "n" to Notion prompt — verify `NOTION_ROADMAP_DB` does NOT appear in CLAUDE.md
2. In that repo, create a new roadmap item — verify `notion_url` is absent from its frontmatter
3. Run `publish feat-xyz` in that repo — verify Claude responds with "Notion publishing is not enabled" and suggests `upgrade.sh --enable-notion`
4. Install fresh repo, answer "y" — verify `NOTION_ROADMAP_DB: ""` appears in CLAUDE.md and new items get `notion_url: ""` in frontmatter
5. Run `upgrade.sh` on a repo without `NOTION_ROADMAP_DB` — verify all Notion steps are skipped silently
6. Run `upgrade.sh --enable-notion` on the same repo — verify `NOTION_ROADMAP_DB: ""` is injected, `notion_url: ""` added to all existing items, and warning to fill in the DB URL is printed

**Publish flow**
7. Set `NOTION_ROADMAP_DB` to a real Notion database URL; run `publish feat-notion-publish` — verify a new Notion page is created with title `[feat] Notion Publish`, correct status, and full markdown body
8. Verify `notion_url` is written back to `feat-notion-publish.md` frontmatter
9. Run publish again — verify the existing page is updated, not duplicated
10. Change `status` to `in-progress`, publish again — verify Notion Status field updates
11. Run `publish feat-notion-publish` with `NOTION_ROADMAP_DB` present but empty — verify Claude prompts for the DB URL before proceeding
12. Ask "check Notion comments for feat-notion-publish" — verify Claude surfaces any comments

---

## Open questions

None — all resolved during spec review.
