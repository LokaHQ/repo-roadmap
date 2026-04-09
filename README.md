# repo-roadmap

A lightweight roadmap convention for software projects — features, ideas, and challenges tracked as markdown files, with Claude Code instructions included.

## What problem does this solve?

Roadmap context gets scattered: Notion pages, GitHub Issues, Slack threads, sticky notes. When you ask Claude Code to implement something, it has no idea what's planned, what's still an idea, or what's a known blocker.

This convention puts roadmap entries directly in the repo as markdown files. Claude Code reads them automatically, follows the right templates, and keeps the table in `roadmap/README.md` up to date — no manual tracking required.

## What it does NOT do

- Not a project management tool — no status tracking, assignment, or due dates
- Does not integrate with GitHub Issues, Jira, or Notion
- Requires Claude Code — the `CLAUDE.md` instructions only work with Claude Code (CLI or IDE extension)
- Does not enforce any workflow on contributors who don't use Claude Code

## Installation

### New repo
Use this repo as a GitHub template when creating a new repo — files are pre-populated.

### Existing repo
```bash
git clone https://github.com/rabb1tl0ka/repo-roadmap
bash repo-roadmap/install.sh /path/to/your/repo
```

The script:
- Copies `roadmap/` into the target (skips if already exists)
- Copies `CLAUDE.md` into the target, or appends to an existing one

## Quickstart

After installing, tell Claude Code to save something:

> "Save this as a feature: add dark mode support to the settings page"

Claude will pick the right template, create `roadmap/feat-dark-mode.md`, and add a row to `roadmap/README.md`.

To work on an existing entry:

> "Load the dark mode feature from the roadmap"

Claude reads the full spec — branch name, implementation steps, test plan — and presents a plan before writing any code.

## How it works

Each roadmap entry is a markdown file prefixed by type:

| Prefix | Meaning |
|---|---|
| `feat-` | Fully specced feature — ready to implement |
| `idea-` | Early exploration — not yet fully designed |
| `challenge-` | Known problem — solution still open |

See `roadmap/README.md` for contributor instructions and `roadmap/template-*.md` for the templates.
