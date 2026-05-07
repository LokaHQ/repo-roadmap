---
status: todo
priority: medium
owner: ""
phase: ""
depends_on: []
---

# Feature Spec: Notion Publish — Child Pages

## One-Line Overview
Publish archived roadmap items as child pages under a configured Notion parent page — no database, no schema, just a single command that posts the content and saves the URL back to frontmatter.

## Goal
Allow users to share resolved roadmap items with non-repo stakeholders via Notion, by posting the full markdown content of an archived item as a new child page under a user-configured Notion parent page. Publishing is one-way (repo → Notion), manually triggered, and scoped to archived items only — which are static by definition, so no update/idempotency logic is needed.

## Reference implementation

This was already piloted in `~/loka/projects/zenqms/zenqms-ai-2ndbrain` (ZenQMS SOW4). That repo's project-level `CLAUDE.md` contains the full working workflow. Use it as the reference for this spec.

Key decisions validated there:
- Publish **archive-only** — items are static at that point, no update logic needed
- Full markdown content, frontmatter stripped before posting
- Plain title — no emoji prefix, no type prefix
- `notion_url` written back to the archived spec's frontmatter as the "already published" signal
- Instructions live in the **project-level CLAUDE.md**, not `roadmap/CLAUDE.md` — keeps the roadmap convention upgradeable across repos

## Expected advantages / benefits

- Non-repo stakeholders get visibility without needing Git access
- Dead simple — no Notion database schema, no Status property mapping, no opt-in plumbing
- Safe upgrade path: config lives in project CLAUDE.md, not roadmap/CLAUDE.md, so upgrades never overwrite it
- Archive-only scope eliminates the stale content problem entirely

## Downsides / risks

- No filtering or views — all published items live flat under one parent page; harder to navigate if volume grows
- No status sync — Notion pages don't reflect frontmatter status changes (not needed for archived items, but worth noting)
- Requires Notion MCP to be connected and authed in the user's Claude Code session

## Context

### Current flow
1. User archives a roadmap item (moves to `roadmap/archived/`, status: done)
2. Non-repo stakeholders have no visibility

### Proposed flow
1. User archives a roadmap item
2. User says "publish [item slug] to Notion" (judgment call — not automatic)
3. Claude reads the archived spec, strips frontmatter, posts full content as a child page under the configured parent page
4. Claude saves the returned Notion URL to `notion_url` in the archived spec's frontmatter
5. Stakeholders can read the item in Notion; page is read-only

### Files involved
- `roadmap/CLAUDE.md` — add `notion_url` to frontmatter spec; document that Notion config lives in project CLAUDE.md, not here
- `roadmap/templates/template-feat.md` — add `notion_url: ""` to frontmatter block
- `roadmap/templates/template-idea.md` — same
- `roadmap/templates/template-challenge.md` — same
- `install.sh` — add opt-in prompt "Enable Notion publishing? (y/n)"; if yes, prompt for parent page URL and inject `NOTION_ROADMAP_PAGE` + publishing instructions into the project-level CLAUDE.md
- `upgrade.sh` — detect `NOTION_ROADMAP_PAGE` presence; if found, inject `notion_url: ""` into any existing items that are missing it

**Branch:** `feat/notion-publish-page`

---

## Design

### Frontmatter field
Every roadmap item gains one optional field:

```yaml
notion_url: ""
```

- Empty = never published
- Non-empty = URL of the published Notion page (signals "already done")

### Project CLAUDE.md config
`install.sh` injects this only when the user opts in:

```
NOTION_ROADMAP_PAGE: ""   # Notion parent page URL for roadmap publishing
```

User fills in the page URL. Claude reads this when executing a publish command.
**Presence of this line = opted in.** `upgrade.sh` uses this as the sole signal.

### Publish command
Recognized phrases:
- `publish feat-fast-sync`
- `publish [item slug]`

Claude's steps:
1. Resolve slug → file path in `roadmap/archived/`
2. Confirm item is archived (status: done) — if not, stop and tell the user
3. Check `NOTION_ROADMAP_PAGE` in project CLAUDE.md — if absent, tell the user Notion publishing is not enabled and suggest opt-in
4. Read spec, strip frontmatter block from content
5. Fetch `notion://docs/enhanced-markdown-spec` for correct Notion markdown formatting
6. Call `notion-create-pages` with the parent page ID and full content; convert markdown tables to Notion XML table format
7. Write returned URL to `notion_url` in the archived spec's frontmatter

---

## Changes required

| File | Change |
|------|--------|
| `roadmap/CLAUDE.md` | Add `notion_url` to frontmatter spec; note that Notion config lives in project CLAUDE.md |
| `roadmap/templates/template-feat.md` | Add `notion_url: ""` to frontmatter |
| `roadmap/templates/template-idea.md` | Same |
| `roadmap/templates/template-challenge.md` | Same |
| `install.sh` | Add Notion opt-in prompt; inject `NOTION_ROADMAP_PAGE` + publishing instructions into project CLAUDE.md |
| `upgrade.sh` | Detect `NOTION_ROADMAP_PAGE`; add `notion_url: ""` to existing items missing it |

---

## Test plan

1. Install fresh repo, answer "n" to Notion prompt — verify `NOTION_ROADMAP_PAGE` does NOT appear in project CLAUDE.md
2. In that repo, run `publish feat-xyz` — verify Claude responds "Notion publishing is not enabled"
3. Install fresh repo, answer "y", provide a parent page URL — verify `NOTION_ROADMAP_PAGE` appears in project CLAUDE.md and items get `notion_url: ""`
4. Archive an item, run `publish [slug]` — verify a child page is created under the configured parent, correct title and content, frontmatter stripped
5. Verify `notion_url` is written back to the archived spec
6. Try to publish a non-archived item — verify Claude refuses
7. Run `upgrade.sh` on a repo with `NOTION_ROADMAP_PAGE` — verify `notion_url: ""` is added to any items missing it

---

## Open questions

None — reference implementation already validated in zenqms SOW4 repo.
