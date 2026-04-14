# repo-roadmap

A lightweight roadmap convention for software projects — features, ideas, and challenges tracked as plain markdown files, living directly in your repo.

## The problem

Roadmap context gets scattered: Notion pages, GitHub Issues, Slack threads, sticky notes. When you (or your AI) sit down to implement something, no one knows what's planned, what's still just an idea, or what's a known blocker.

The context never stays where the code is.

## How this is different

Most "roadmap in the repo" approaches are either a single `ROADMAP.md` that becomes a wall of text, or GitHub Issues where the actual thinking gets lost in comment threads. Both blur the most important distinction: **what's ready to build vs. what's still being figured out**.

This convention enforces three clear buckets:

- **`idea-*.md`** — early exploration. Ideas get a visible home where they can be shaped, discussed, or explicitly killed instead of lingering in someone's head.
- **`challenge-*.md`** — known problems with no solution yet. Forces honesty about blockers without pretending they're already solved.
- **`feat-*.md`** — fully specced, ready to implement. Branch name, steps, test plan — anyone (or any AI) can pick one up and run.

The natural lifecycle flows from there: **idea → refinement → feat** (or trash). Challenges live alongside as open problems. It's simple, but it's the structure most ad-hoc roadmaps never get around to enforcing.

Everything is plain markdown, version-controlled, greppable, and diffable. Zero extra tooling required.

## With Claude Code

If you use Claude Code, the convention becomes fully automated:

- **Save** anything from natural language: *"Save this as a feature: add dark mode to the settings page"* → Claude picks the template, creates `roadmap/feat-dark-mode/` with the spec and a `docs/` directory ready for supporting material, adds the table row.
- **Load** any entry to start work: *"Load the dark mode feature"* → Claude reads the full spec and presents a plan before writing any code.
- **Table stays current** automatically — status, priority, and overview always reflect the actual files.
- **Archive when done**: Claude moves completed items to `roadmap/archived/` and removes them from the table. Nothing is deleted — full history stays in place.

Each item lives in its own workspace directory so research notes, reference docs, and artifacts stay co-located with the spec:

```
roadmap/
  feat-dark-mode/
    feat-dark-mode.md     ← the spec
    docs/                 ← drop anything useful here
  archived/               ← completed items, out of active tracking
```

The `CLAUDE.md` instructions wire all of this up. Without Claude Code, the convention still works — you just manage files and the table manually.

## Installation

### New repo
Use this repo as a GitHub template when creating a new repo — files are pre-populated.

### Existing repo
```bash
git clone https://github.com/rabb1tl0ka/repo-roadmap
bash repo-roadmap/install.sh /path/to/your/repo
```

The script copies `roadmap/` into the target and appends the Claude Code instructions to your `CLAUDE.md` (or creates one).

## Quickstart

After installing, tell Claude Code to save something:

> "Save this as a feature: add dark mode support to the settings page"

Or load an existing entry to start working:

> "Load the dark mode feature from the roadmap"

Claude reads the full spec — branch name, implementation steps, test plan — and presents a plan before writing any code.

## Scope

This is deliberately not a project management tool. No assignees, no due dates, no kanban boards, no GitHub Issues integration. If you need those, you already have tools for them.

This is the layer that keeps *directional thinking* — what to build, why, and how — co-located with the code that builds it.
