---
name: simp-implement
description: "Implement one ticket, or all tickets in a feature with --all: primary model writes dev docs, secondary models implement, primary reviews, then tickets are closed. No TDD (for test-first, use simp-implement-tdd)."
disable-model-invocation: true
---

# Simp Implement

Implement tickets via a **primary → secondary → primary** pipeline. The primary model (you) does the two quality-sensitive ends — planning and review. The secondary model does the token-heavy middle — reading code, editing, running tests.

Tickets live at `.scratch/<feature-slug>/issues/<NN>-<slug>.md` (from `/simp-to-tickets`). Work the frontier: any ticket whose blockers are all resolved.

## Arguments and ticket selection

- **No `--all`** → implement one eligible ticket, then stop.
- **`--all`** → explicit authorization to implement every ticket in the starting ticket's feature. Do not cross into another feature or invoke another skill.
- Start with the user's specified ticket, or the lowest-numbered eligible ticket when none is specified. A specified ticket must be eligible; otherwise stop and report its blockers.
- Execute tickets sequentially. After each commit, choose the lowest-numbered eligible unresolved ticket; never implement tickets in parallel.
- Any failure, unresolved review finding, commit problem, or question requiring user judgement stops the entire batch. Do not skip the problem and continue with another ticket.

## Process

### 1. Write the dev doc (primary)

Read the ticket and the PRD it references in full, then explore only what you need to write a precise dev doc. The PRD records this requirement's intent; code and tests describe current behaviour. Do not consult historical PRDs to judge current behaviour.

Save the dev doc to `.scratch/<feature-slug>/dev-docs/<NN>-<slug>.md`:

<dev-doc-template>

# <NN> — <Ticket title>

**PRD:** the PRD path copied from the ticket.

## Goal

The end-to-end behaviour this ticket makes work, copied from the ticket.

## Acceptance criteria

The ticket's acceptance criteria, verbatim.

## Where to work

The modules, seams, and domain vocabulary involved (use `CONTEXT.md` terms). Name modules and seams, not exhaustive file lists.

## Implementation plan

Numbered steps. Each step: what to change, in which module, and why. Include interface shapes (signatures, schema, type shapes) where prose would be ambiguous.

## Verification

How the developer proves each acceptance criterion: which existing tests must stay green, which new behaviour to check.

## Out of scope

What the developer must NOT touch — adjacent refactors, speculative abstractions, unrelated cleanup.

</dev-doc-template>

Keep it decision-rich and short. This doc is the developer's entire context pack — if it forces them to re-explore the whole repo, it has failed.

### 2. Implement (secondary)

Dispatch exactly ONE secondary developer call using the syntax supported by the host:

- **Kimi Code**: spawn one `Agent` call with `subagent_type="coder"` and **omit the `model` parameter** so the host's secondary-model default applies. NEVER pass `model="primary"` — the primary model does only the dev doc and the review.
- **OpenCode**: spawn one `Task` call with `subagent_type="secondary"`. Do not pass `model="secondary"`: `secondary` is the OpenCode agent name, and its model is configured by the agent (for example, `opencode-go/deepseek-v4-flash`).

The prompt must include:

- The dev doc path and the ticket path — tell it to read both in full before touching code.
- The brief: "Implement exactly the plan in the dev doc — no more, no less. Stay out of the out-of-scope list. Run typechecking and the relevant tests as you go; fix what you break. If the plan turns out to be wrong or unimplementable, STOP and report why instead of improvising a different design."
- The report format: "Report under 300 words: what you changed (modules, not line counts), verification results (typecheck, tests — with failures quoted), and any deviations from the plan with reasons."

### 3. Review (primary)

Review the result yourself — lightweight and per-ticket. The heavy two-axis review (`/simp-code-review`) is a separate, manually-invoked skill.

1. `git diff` the ticket's changes and read the diff in full.
2. Check each acceptance criterion against the diff — every one must be demonstrably satisfied.
3. Check for scope creep: anything in the diff the dev doc didn't ask for.
4. **PRD fidelity**: if the diff contradicts the PRD referenced by the current ticket, flag it to the user before committing. Historical PRDs do not describe current behaviour. Never edit the PRD.
5. Rerun the tests yourself if the developer's verification claims look off.

Then:

- **All good** → commit the work to the current branch, then close the ticket (step 4).
- **Small issues** (style, a missed edge case) → fix them yourself, commit, then close the ticket (step 4).
- **Plan was wrong or implementation is broken** → revise the dev doc, spawn a FRESH secondary agent (do not resume the old one — its context is polluted with the wrong approach) and repeat from step 2. The ticket stays open.

### 4. Close the ticket

Only after the commit lands:

- In the ticket file, check every acceptance-criterion checkbox and change the `Status:` line to `resolved`.
- Never delete the ticket file during the feature. Tickets and dev docs are disposable once the feature is done; keep the PRD.

### 5. Advance or stop

- **Without `--all`** → report the committed ticket and STOP. Remaining unblocked tickets are not authorization to continue.
- **With `--all`** → recompute the current feature's frontier after closing the ticket:
  1. If an eligible unresolved ticket exists, select the lowest-numbered one and return to step 1 with a FRESH secondary agent. Never resume a previous ticket's secondary.
  2. If unresolved tickets remain but none are eligible, STOP and report the blocking dependency or status problem.
  3. If every ticket in the feature is resolved, report each completed ticket and its commit, then STOP.

Never invoke `/simp-code-review` or any other skill. `--all` authorizes only sequential implementation within the current feature.

If you realize you have crossed this boundary, stop immediately, disclose what was produced, and leave it in place. Do not delete it or continue the later work; wait for the user's instruction.

### Escalation

If a ticket bounces back from secondary twice, or the dev doc itself needs design-level rethinking, stop and tell the user — this ticket is beyond the secondary model and should be implemented by the primary directly. Don't let secondary retry-loop indefinitely.
