**I really like this repo and its approach — it's clever, pragmatic, and feels very "AI-native" in the best way.** It's not trying to be a full-blown project management tool (which is explicitly stated, and a strength), but a lightweight, code-first convention that keeps the entire roadmap *inside the repo itself*. No Notion, no Jira, no scattered Slack threads or GitHub Projects boards that get out of sync.

### What stands out positively

- **The three clear buckets you mentioned are exactly right and well-designed**:
  - **`idea-*.md`** → "ideas worth exploring (and shaped into features or trashed)". This is the most valuable part. It gives ideas a safe, visible home where they can be discussed, fleshed out, or explicitly killed instead of lingering in someone's head or a random comment.
  - **`challenge-*.md`** → "challenges that need to be resolved". Love that these are separated from features. It forces honesty about blockers without pretending they already have solutions.
  - **`feat-*.md`** → "features ready to be implemented". These are fully specced with branch name, steps, test plan, etc., so anyone (or any AI) can pick them up and run.

  This separation creates a natural lifecycle: idea → (research/discussion) → feat (or trash), with challenges living alongside as open problems. It's simple but extremely effective for staying aligned.

- **Everything lives in `roadmap/` as plain markdown files**. Version-controlled, greppable, diffable, forkable. The `roadmap/README.md` auto-generates a clean overview table via frontmatter + Claude Code. That's elegant.

- **Designed explicitly for Claude Code (or similar AI coding tools)**. The `CLAUDE.md` instructions + templates mean the AI can:
  - Create new entries from natural language ("Save this as a feature: …")
  - Load full specs ("Load the dark mode feature")
  - Keep the overview table up to date automatically

  This is a huge win for solo devs or small teams who already live in AI-assisted workflows. The context never leaves the repo.

- **Minimalist by design**. No status tracking, assignees, or due dates (it says so upfront). If you want those, you already have GitHub Issues or whatever. This is deliberately *just* the directional spec layer.

### Minor caveats / trade-offs

- It's **heavily optimized for Claude Code users**. If your team doesn't use Claude (or another tool that can follow the CLAUDE.md instructions), the automation disappears and you're left with nice markdown files + manual table updates. Still usable, just less magical.
- For larger teams or more complex projects, you might eventually want something visual (kanban) or integrated with issues. But again, the repo acknowledges this — it's not pretending to replace everything.
- Right now the repo itself is brand new (literally hours/days old as of this moment) and the example table is still a placeholder. But that's fine — it's a template repo meant to be copied.

### Bottom line

This is one of the cleaner "roadmap in the repo" patterns I've seen. It directly solves the exact pain you described: ideas floating around, challenges getting lost, and features never quite making it from "discussion" to "ready to ship."

If you're already using (or open to using) an AI coding assistant like Claude in your workflow, I'd say **adopt this in a heartbeat**. Even without heavy AI use, the file-prefix + template structure is solid enough that it would still be better than most ad-hoc roadmaps.

It's the kind of thing that feels obvious *after* you see it — "of course the roadmap should live next to the code with clear idea/challenge/feat lanes" — but almost nobody does it this cleanly. Respect to the author (and Claude) for shipping it. Would happily use or recommend it.
