# Roadmap

This directory contains specs, ideas, and challenges for contributors (and for me + my local AI tools) to pick up.

## File prefixes

| Prefix       | Meaning |
|--------------|---------|
| `feat-`      | Fully specced feature — ready to implement. Branch name and test plan included. |
| `idea-`      | Early exploration — interesting direction, not yet fully designed. Good for discussion. |
| `challenge-` | Problem to solve — the what is clear, the how is open. |

## Current roadmap

| File                        | Status      | Priority | Owner | One-Line Overview |
|-----------------------------|-------------|----------|-------|-------------------|
| [feat-upgrade-system.md](feat-upgrade-system.md) | 🚧 in-progress | high | @rabb1tl0ka + @claude-sonnet-4-6 | Replace the fragile sentinel/text-patching upgrade approach with a resilient system using `@file` imports, atomic template replacement, and an audit-first content migration flow. |
| [feat-workspace-per-item.md](feat-workspace-per-item.md) | ⏳ todo | medium | | Replace the flat `roadmap/` file layout with per-item subdirectories so each feat, idea, and challenge has a dedicated workspace for specs, docs, and research artifacts. |

*(The table above is automatically maintained by Claude Code. Do not edit it manually.)*

## How to contribute

### For `feat-` files (ready to implement)

1. Pick a `feat-` file that interests you.
2. Read it fully — it includes the branch name, implementation steps, test plan, and open questions.
3. Create the branch named in the spec and implement the feature.
4. If you have questions, open an issue referencing the spec file.

### For `idea-` and `challenge-` files

Contributions can be a PR that evolves the file itself (adding design, research, proposal, or turning an idea into a full `feat-` spec) before any code is written.

### Solo Dev + AI Workflow

Claude Code (and other local AI tools) is instructed to:
- Always add/update the minimal frontmatter (`status` and `priority`)
- Keep the **One-Line Overview** section filled with one crisp sentence
- Automatically regenerate the table above after any change to a roadmap file

## Templates

Use these templates when creating new items:
- [`templates/template-feat.md`](templates/template-feat.md)
- [`templates/template-idea.md`](templates/template-idea.md)
- [`templates/template-challenge.md`](templates/template-challenge.md)