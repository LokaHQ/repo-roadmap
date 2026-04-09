# Claude Code Instructions

## Roadmap Convention

This repo uses a `roadmap/` directory to track features, ideas, and challenges.

### File naming

Every roadmap entry is a markdown file with one of three prefixes:
- `feat-` — fully specced feature, ready to implement
- `idea-` — early exploration, not yet fully designed
- `challenge-` — known problem, solution still open

### When asked to save a feature, idea, or challenge

1. Use the matching template from `roadmap/template-feat.md`, `roadmap/template-idea.md`, or `roadmap/template-challenge.md`
2. Save the file as `roadmap/<prefix>-<slug>.md`
3. Add a row to the `## Current roadmap` table in `roadmap/README.md`

### When asked to load or work on a roadmap entry

Read the relevant file in full before starting — branch name, implementation steps, test plan, and open questions are all in there. Present a plan and wait for explicit approval before writing any code.
