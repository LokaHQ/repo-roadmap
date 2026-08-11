---
feature: ""
layer: fullstack
status: todo
owner: ""
---

# Fullstack Implementation Spec: [Feature Title]

> Technical companion to `../<feat-slug>.md` covering both web and backend in one document — use this when the stack integrates the two (e.g. Next.js API routes/Server Actions, Convex, tRPC) rather than running them as genuinely separate systems.
> Do not restate the product/behavior spec here — link to it. This doc is the "how," not the "what."
> Use this INSTEAD of `implementation-web.md` + `implementation-backend.md`, not alongside them. If the stack has two genuinely separate systems (different deploy units, different owners), use the split templates instead.

## Linked Feature Spec
[`<feat-slug>`](../<feat-slug>.md)

## Architecture & Data Model

Concrete plan: pages/components/routes involved, the server functions/API routes/mutations this feature introduces, and how state is persisted and kept in sync between client and server within the single framework.

## Internal Contracts

Since client and server are the same system here, this is lighter than a cross-service contract: the function/route signatures, payload shapes, and events this feature introduces or touches.

## Shared State & Concurrency (if applicable)

For features involving multiple simultaneous participants (sessions, voting, live picks, etc.): how is shared state synced across clients, what happens on conflicting writes, and what's the reconnect/refresh behavior.

## Changes required

| File | Change |
|------|--------|
| `path/to/file` | ... |

## Automated Test Plan

Concrete, runnable tests — real file paths and the actual command to run them. Claude uses this section to self-verify the implementation once code exists; vague descriptions ("test that it works") are not acceptable here.

1. **Unit tests** — `path/to/test/file` — run via `<command>`
2. **Integration tests** (client + server exercised together, e.g. against a local dev instance) — `path/to/test/file` — run via `<command>`
3. **E2E test** (a full scripted user flow, browser-driven) — `path/to/test/file` — run via `<command>`

## Open questions

1. ...
