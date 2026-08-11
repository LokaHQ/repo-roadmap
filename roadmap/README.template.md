# Roadmap

This directory contains specs, ideas, and challenges for contributors (and for me + my local AI tools) to pick up.

## File prefixes

| Prefix       | Meaning |
|--------------|---------|
| `feat-`      | Fully specced feature — ready to implement. Branch name and test plan included. |
| `idea-`      | Early exploration — interesting direction, not yet fully designed. Good for discussion. |
| `challenge-` | Problem to solve — the what is clear, the how is open. |

Not a prefix, but part of the same naming system: inside a `feat-` item's `docs/` folder, `implementation-web.md` and `implementation-backend.md` are fixed filenames for layer-specific technical specs (the "how" for the web or backend build) — created only on request, never automatically. See "Working with docs/" below.

## Directory layout

Each roadmap item is either a flat `.md` file or a **workspace directory**:

```
roadmap/
  feat-big-thing/         ← workspace: spec + supporting material
    feat-big-thing.md
    docs/                 ← research, references, artifacts
      implementation-web.md      ← optional, created only on request
      implementation-backend.md  ← optional, created only on request
  idea-simple.md          ← flat: no workspace needed
  archived/               ← completed or abandoned items
```

Items start as flat files and grow into workspace directories when they need supporting material. Completed items move to `archived/` and disappear from the table below.

## Current roadmap

| File | Phase | Status | Priority | Deps | Owner | One-Line Overview |
|------|-------|--------|----------|------|-------|-------------------|

*(The table above is automatically maintained by Claude Code. Do not edit it manually.)*

## How to contribute

### For `feat-` files (ready to implement)

1. Pick a `feat-` file that interests you.
2. Read it fully — it includes the branch name, implementation steps, test plan, and open questions.
3. Create the branch named in the spec and implement the feature.
4. If you have questions, open an issue referencing the spec file.

### For `idea-` and `challenge-` files

Contributions can be a PR that evolves the file itself (adding design, research, proposal, or turning an idea into a full `feat-` spec) before any code is written.

### Working with docs/

Drop any supporting material — research notes, reference docs, screenshots, competitive analysis — into the item's `docs/` directory. Claude Code will read from it when working on that item.

One special case: `docs/implementation-web.md` and `docs/implementation-backend.md` are layer-specific technical companions to a `feat-` spec — the "how" for the web or backend build, with a concrete, runnable test plan. Ask for one by name ("create a web implementation spec for feat-X"); Claude won't create these on its own when a feature is first saved.

### Solo Dev + AI Workflow

Claude Code (and other local AI tools) is instructed to:
- Always create new items as workspace directories with `docs/` auto-created
- Auto-promote flat items to workspace dirs when `docs/` is needed
- Always add/update the minimal frontmatter (`status`, `priority`, `owner`)
- Keep the **One-Line Overview** section filled with one crisp sentence
- Automatically regenerate the table above after any change to a roadmap item
- Move completed items to `archived/` and remove them from the table

## Templates

Use these templates when creating new items:
- [`templates/template-feat.md`](templates/template-feat.md)
- [`templates/template-idea.md`](templates/template-idea.md)
- [`templates/template-challenge.md`](templates/template-challenge.md)
- [`templates/template-implementation-web.md`](templates/template-implementation-web.md) — created only on request, see "Working with docs/" above
- [`templates/template-implementation-backend.md`](templates/template-implementation-backend.md) — created only on request, see "Working with docs/" above
