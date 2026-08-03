---
name: simp-to-spec
description: "Synthesise the current conversation into a spec. With --docs, also persist it as a living PRD under docs/prd/ and maintain the PRD index. No interview — just synthesis of what was already discussed."
disable-model-invocation: true
---

# Simp To Spec

Take the current conversation context and codebase understanding and produce a spec (aka PRD). Do NOT interview the user — just synthesise what you already know.

Run this in the **same unbroken context window** as the preceding `/simp-grill` session — the spec builds on that thinking.

## Arguments

- **No argument** → synthesise the spec in conversation only, then continue straight to `/simp-to-tickets`. Nothing is persisted. Use for small, single-session work.
- **`--docs`** → additionally persist the spec as a durable PRD (step 4). Use for features whose intent must survive after the context window is gone.

## Process

### 1. Ground yourself

Explore the repo to understand the current state of the code, if you haven't already. Read `CONTEXT.md` (if it exists) and use its vocabulary throughout the spec. Respect any ADRs in `docs/adr/` in the area you're touching.

### 2. Agree the test seams

Sketch the seams at which you'll test the feature. Existing seams beat new ones; use the highest seam possible; the fewer the better — the ideal number is one. Check with the user that these seams match their expectations.

### 3. Write the spec

Use the template below. Do NOT include specific file paths or code snippets — they go stale fast. Exception: a snippet that encodes a decision more precisely than prose can (state machine, schema, type shape) may be inlined, trimmed to the decision-rich parts.

<spec-template>

## Problem Statement

The problem the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list covering all aspects of the feature:

1. As an <actor>, I want a <feature>, so that <benefit>

## Implementation Decisions

- The modules that will be built/modified, and their interfaces
- Architectural decisions (reference ADRs by number where one exists)
- Schema changes, API contracts, specific interactions

## Testing Decisions

- What makes a good test (external behaviour only, not implementation details)
- Which modules will be tested, at which seams
- Prior art for the tests (similar tests in the codebase)

## Out of Scope

What is explicitly not part of this spec.

## Further Notes

Anything else worth recording.

</spec-template>

### 4. With `--docs`: persist the PRD

- Write the spec to `docs/prd/<feature-slug>.md`.
- Update the index at `docs/prd/README.md` — one line per PRD: `<feature-slug>` → the modules/areas it covers, linked. Create the index if missing. The index exists so future work can find relevant PRDs **without reading them all**; keep lines short.
- **Amend affected historical PRDs.** Use the index to find existing PRDs whose described behaviour this feature changes. Update only the affected sections so each PRD describes current behaviour — never rewrite whole documents. Note at the end of the new PRD which sections of which historical PRDs it amends.
- **ADR check.** If the conversation settled a decision that is hard to reverse, surprising without context, and the result of a real trade-off, record it as a new ADR per the `/simp-grill` ADR rules, and reference it from the spec's Implementation Decisions.

### 5. Continue

Proceed to `/simp-to-tickets` in the same context window.
