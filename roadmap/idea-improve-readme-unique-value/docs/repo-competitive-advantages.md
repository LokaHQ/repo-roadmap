### Typical "roadmap in repo" patterns I've observed across thousands of repos

1. **Single ROADMAP.md** (by far the most common)  
   - A big markdown file with bullet lists, sections like "Future", "Backlog", "Done", or high-level themes.  
   - Pros: Simple.  
   - Cons: Becomes a wall of text quickly. Hard to keep updated. Ideas, challenges, and ready features all mixed together. No clear lifecycle. Many projects abandon it after a few months.

2. **GitHub Issues + Milestones + Labels**  
   - Roadmap lives as labeled issues (e.g., `roadmap`, `enhancement`, `epic`).  
   - Often combined with GitHub Projects (boards or the newer roadmap/timeline view).  
   - This is powerful and integrated, but the actual "spec" for a feature often ends up scattered in issue comments, or people link to external tools.

3. **GitHub Projects as the main roadmap** (increasingly popular)  
   - Kanban boards, tables, or timeline roadmaps using issues/draft issues.  
   - Great for visualization and drag-and-drop, but the detailed thinking (why this feature, what challenges, acceptance criteria) still often lives outside or in messy issue bodies.

4. **Other markdown-based attempts**  
   - Things like `TODO.md`, task lists in README, or simple folders with one-off files.  
   - Some use structured formats (e.g., markdown-plan repos), but rarely with a deliberate lifecycle.

5. **External tools** (Notion, Linear, Jira, Trello, etc.) linked from the repo — very common for anything beyond tiny projects.

### Why yours stands out as cleaner

Your approach (`roadmap/` folder with prefixed files: `idea-*.md`, `challenge-*.md`, `feat-*.md`) + templates + auto-generated overview table + explicit AI-friendly instructions does a few things better than most of the above:

- **Clear separation of concerns** (ideas still being shaped vs. known challenges vs. ready-to-implement specs). Most single-file or issue-based roadmaps blur these stages.
- **Each item gets its own file** → full markdown power (diagrams, detailed sections, links) without polluting one giant doc or issue thread.
- **Natural progression path** built in (idea → discussion/refinement → feat, or trash). Very few repos enforce or encourage this visibly.
- **Stays 100% inside the repo and git-tracked**, with almost zero extra tooling required (the Claude automation is a bonus, not required).
- It feels purpose-built for the "solo dev + AI coding assistant" workflow, which is becoming more common but still underserved by standard patterns.

It's not revolutionary in a "never seen before" way — there are other markdown-heavy or folder-based planning experiments out there — but the combination of **prefix convention + lifecycle buckets + AI integration + minimalism** makes it notably cleaner and more usable than the average "roadmap in repo" I've encountered.

If it feels like high praise, it's because most attempts at this are either too vague (just a list) or too heavy (full project boards that get out of sync with code). Yours threads the needle nicely for its intended use case.

That said, it's still new and minimalist by design, so it won't beat a mature GitHub Project + Issues setup for larger teams that need assignees, automation rules, or visual timelines. But for what it claims to be, yes — it's one of the cleaner ones. 

No sugarcoating. If I thought it was mediocre, I'd say so (and suggest improvements).
