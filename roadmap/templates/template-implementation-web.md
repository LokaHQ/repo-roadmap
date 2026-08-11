---
feature: ""
layer: web
status: todo
owner: ""
---

# Web Implementation Spec: [Feature Title]

> Technical companion to `../<feat-slug>.md` for the web/frontend layer only.
> Do not restate the product/behavior spec here — link to it. This doc is the "how," not the "what."

## Linked Feature Spec
[`<feat-slug>`](../<feat-slug>.md)

## Architecture & State

Concrete plan for this layer: screens/components involved, state management approach, routing, and how this layer talks to the backend (API calls, events, subscriptions) or manages local-only state if there's no backend for this feature.

## API / Data Contracts

If a backend exists for this feature, list the exact requests/events this layer sends and receives (endpoint, payload shape, event name). Cross-reference the matching section in `implementation-backend.md` if one exists — contracts should match on both sides, not be redefined twice.

If there's no backend involved, state that explicitly and describe the local state shape instead.

## Changes required

| File | Change |
|------|--------|
| `path/to/file` | ... |

## Automated Test Plan

Concrete, runnable tests — real file paths and the actual command to run them. Claude uses this section to self-verify the implementation once code exists; vague descriptions ("test the UI works") are not acceptable here.

1. **Unit/component tests** — `path/to/test/file` — run via `<command>`
2. **Integration tests** (mocked backend, if applicable) — `path/to/test/file` — run via `<command>`
3. **E2E test** (real user flow, browser-driven) — `path/to/test/file` — run via `<command>`

## Open questions

1. ...
