# repo-roadmap

A lightweight roadmap convention for software projects — features, ideas, and challenges tracked as markdown files, with Claude Code instructions included.

## What's included

- `roadmap/` — directory with README and templates for `feat-`, `idea-`, and `challenge-` entries
- `CLAUDE.md` — instructions for Claude Code to manage the convention automatically
- `install.sh` — script to apply the convention to an existing repo

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

## How it works

Each roadmap entry is a markdown file prefixed by type:

| Prefix | Meaning |
|---|---|
| `feat-` | Fully specced feature — ready to implement |
| `idea-` | Early exploration — not yet fully designed |
| `challenge-` | Known problem — solution still open |

See `roadmap/README.md` for contributor instructions and `roadmap/template-*.md` for the templates.
