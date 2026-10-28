---
name: simp-to-spec
description: "Synthesise the current conversation into a lightweight spec and persist it as a local snapshot PRD under .scratch/. No interview — just synthesis of what was already discussed."
disable-model-invocation: true
---

# Simp To Spec

Take the current conversation context and codebase understanding and produce a spec (aka PRD). Do NOT interview the user — just synthesise what you already know.

When following `/simp-grill`, run this in the **same unbroken context window** — the spec builds on that thinking. Independent invocation is also allowed when the conversation already contains enough requirement context. If the input is insufficient, stop and ask for the missing input; do not interview the user or invoke `/simp-grill` to fill the gap.

Every invocation persists a PRD. There is no persistence flag.

## Process

### 0. Precondition

Ensure `.scratch/` is in the project's `.gitignore`. If it isn't, add it (a one-time setup per project).

### 1. Ground yourself

Explore the repo to understand the current state of the code, if you haven't already. Read `CONTEXT.md` (if it exists) and use its vocabulary throughout the spec. Respect any ADRs in `docs/adr/` in the area you're touching. Code and tests describe current behaviour; existing PRDs are historical records of intent, not a description of current behaviour.

### 2. Agree the test seams

Sketch the seams at which you'll test the feature. Existing seams beat new ones; use the highest seam possible; the fewer the better — the ideal number is one. Check with the user that these seams match their expectations.

### 3. Write the spec

Use the template below. Keep it at the requirement and behaviour level. Leave ordinary module and interface design to tickets and dev docs; reference ADRs for decisions that meet the ADR threshold. Do NOT include specific file paths or code snippets — they go stale fast. Exception: a snippet that encodes externally observable behaviour more precisely than prose can (state machine, schema, type shape) may be inlined, trimmed to the decision-rich parts.

<spec-template>

## Problem Statement

The problem the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories and Acceptance Criteria

A numbered list covering all aspects of the feature, with observable acceptance criteria for each story:

1. As an <actor>, I want a <feature>, so that <benefit>
   - Acceptance: <observable result>

## Testing Decisions

- What makes a good test (external behaviour only, not implementation details)
- The agreed testing seams and the behaviour each covers
- Prior art for the tests (similar tests in the codebase)

## Out of Scope

What is explicitly not part of this spec.

## Related ADRs

References to relevant ADRs by number, or "None".

</spec-template>

### 4. Persist the PRD

- Write the spec to `.scratch/<feature-slug>/prd.md` and present its path with the spec.
- PRDs are local, long-term snapshots: never commit or edit them. A later requirement gets a new PRD rather than amending an old one.
- Do not create a PRD index or supersede declarations. Each PRD records the intent of one requirement; code and tests remain the authority on current behaviour.
- Keep PRDs when cleaning up tickets and dev docs.
- **ADR check.** If the conversation settled a decision that is hard to reverse, surprising without context, and the result of a real trade-off, record it as a new ADR per the `/simp-grill` ADR rules, and reference it from Related ADRs.

### 5. Stop at the stage boundary

Present the spec and STOP. Do not invoke `/simp-to-tickets`, create tickets, or implement any part of the spec. Agreement on test seams, approval of the spec, or an earlier request listing later stages is not authorization to continue.

You may suggest `/simp-to-tickets` as the next command without running it. The user must explicitly invoke it in a later message. A later invocation may use the PRD path in a fresh context.

If you realize you have crossed this boundary, stop immediately, disclose what was produced, and leave it in place. Do not delete it or continue the later stage; wait for the user's instruction.
