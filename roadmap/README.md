# Roadmap

This directory contains specs, ideas, and challenges for contributors (and for me + my local AI tools) to pick up.

## File prefixes

| Prefix       | Meaning |
|--------------|---------|
| `feat-`      | Fully specced feature — ready to implement. Branch name and test plan included. |
| `idea-`      | Early exploration — interesting direction, not yet fully designed. Good for discussion. |
| `challenge-` | Problem to solve — the what is clear, the how is open. |

## Current roadmap

| File                        | Status      | Priority | One-Line Overview |
|-----------------------------|-------------|----------|-------------------|
| feat-example.md             | todo        | high     | (this will be auto-filled) |

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
- [`template-feat.md`](template-feat.md)
- [`template-idea.md`](template-idea.md)
- [`template-challenge.md`](template-challenge.md)