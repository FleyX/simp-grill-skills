---
name: simp-to-tickets
description: "Break a persisted PRD into tracer-bullet tickets with blocking edges, persisted as local markdown under .scratch/ (never committed)."
disable-model-invocation: true
---

# Simp To Tickets

Break the persisted PRD into **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it.

Tickets live **only** as local files under `.scratch/` — ephemeral work-tracking artifacts, never committed to git. The PRD at `.scratch/<feature-slug>/prd.md` is the local, long-term record of intent. Tickets are scaffolding; keep the PRD when cleaning them up.

## Process

### 0. Precondition

Ensure `.scratch/` is in the project's `.gitignore`. If it isn't, add it (a one-time setup per project).

### 1. Gather context

Read the PRD in full using the path supplied by `/simp-to-spec` in the conversation or passed explicitly as an argument. Independent invocation in a fresh context requires an explicit PRD path. If no PRD path is available, stop and ask for it; do not invoke `/simp-to-spec` or `/simp-grill` to fill the gap.

### 2. Explore the codebase (optional)

If you haven't already, explore the codebase to understand its current state. Ticket titles and descriptions should use `CONTEXT.md` vocabulary and respect ADRs in the area you're touching.

Look for opportunities to prefactor first — "make the change easy, then make the easy change."

### 3. Draft vertical slices

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring is its own first ticket

</vertical-slice-rules>

Give each ticket its **blocking edges** — the tickets that must complete before it can start. A ticket with no blockers is eligible for an explicit `/simp-implement` invocation, not automatic implementation.

**Wide refactors are the exception to vertical slicing.** A wide refactor is one mechanical change (rename a column, retype a shared symbol) whose blast radius fans across the codebase, so no vertical slice can land green. Sequence it as **expand–contract**: first add the new form beside the old (nothing breaks), then migrate call sites in batches sized by blast radius (each batch a ticket blocked by the expand, old form still present so each batch stays green), finally delete the old form in a ticket blocked by every migrate batch.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket show:

- **Title**: short descriptive name
- **Blocked by**: which tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour it makes work

Ask: Is the granularity right? Are the blocking edges correct? Should any tickets be merged or split? Iterate until the user approves.

### 5. Publish locally

Write one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). One ticket per file, never a combined file.

<ticket-template>

# <NN> — <Ticket title>

**PRD:** the path to `.scratch/<feature-slug>/prd.md`.

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the gating tickets, or "None — eligible for explicit implementation".

**Status:** ready-for-agent

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</ticket-template>

Apart from the required PRD reference, avoid specific file paths or code snippets — they go stale fast. Exception: a snippet that encodes a decision more precisely than prose (state machine, schema, type shape) may be inlined, trimmed to the decision-rich parts.

### 6. Stop at the stage boundary

Present the published tickets and STOP. Do not invoke `/simp-implement` or `/simp-implement-tdd`, even if the user approved the breakdown or originally requested implementation. Approval publishes the tickets; it does not authorize development.

You may explain that the user can explicitly invoke `/simp-implement` for one eligible ticket in a fresh context. Each ticket requires a separate invocation.

If you realize you have crossed this boundary, stop immediately, disclose what was produced, and leave it in place. Do not delete it or continue implementation; wait for the user's instruction.
