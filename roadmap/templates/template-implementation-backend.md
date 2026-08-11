---
feature: ""
layer: backend
status: todo
owner: ""
---

# Backend Implementation Spec: [Feature Title]

> Technical companion to `../<feat-slug>.md` for the backend layer only.
> Do not restate the product/behavior spec here — link to it. This doc is the "how," not the "what."
> If this feature doesn't need a backend, don't create this file at all.

## Linked Feature Spec
[`<feat-slug>`](../<feat-slug>.md)

## Architecture & Data Model

Concrete plan: service/module responsible for this feature, data model/schema involved, and how state is persisted (or, if using a BaaS/real-time platform instead of a custom backend, which one and why).

## API / Event Contracts

List the exact endpoints or real-time events this feature exposes (method/path or event name, request/response or payload shape). Cross-reference the matching section in `implementation-web.md` — contracts should match on both sides, not be redefined twice.

## Shared State & Concurrency (if applicable)

For features involving multiple simultaneous participants (sessions, voting, live picks, etc.): how is shared state synced across clients, what happens on conflicting writes, and what's the reconnect/refresh behavior.

## Changes required

| File | Change |
|------|--------|
| `path/to/file` | ... |

## Automated Test Plan

Concrete, runnable tests — real file paths and the actual command to run them. Claude uses this section to self-verify the implementation once code exists; vague descriptions ("test the API works") are not acceptable here. Layer the plan the way `backend-exchange-cli`'s specs do:

1. **Unit tests** (mocked dependencies) — `path/to/test/file` — run via `<command>`
2. **Integration tests** (against a real local/dev backend instance) — `path/to/test/file` — run via `<command>`
3. **E2E test** (a full scripted flow exercising this feature end-to-end) — `path/to/test/file` — run via `<command>`

## Open questions

1. ...
