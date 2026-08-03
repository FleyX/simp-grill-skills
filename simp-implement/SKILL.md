---
name: simp-implement
description: "Implement one ticket: primary model writes a dev doc, secondary model implements it, primary model reviews, then the ticket is closed. No TDD."
disable-model-invocation: true
---

# Simp Implement

Implement one ticket via a **primary → secondary → primary** pipeline. The primary model (you) does the two quality-sensitive ends — planning and review. The secondary model does the token-heavy middle — reading code, editing, running tests.

Tickets live at `.scratch/<feature-slug>/issues/<NN>-<slug>.md` (from `/simp-to-tickets`). Work the frontier: any ticket whose blockers are all resolved.

## Process

### 1. Write the dev doc (primary)

Read the ticket, then explore only what you need to write a precise dev doc. Check `docs/prd/README.md` for PRDs covering the modules you'll touch — if any, read the relevant sections (not whole documents).

Save the dev doc to `.scratch/<feature-slug>/dev-docs/<NN>-<slug>.md`:

<dev-doc-template>

# <NN> — <Ticket title>

## Goal

The end-to-end behaviour this ticket makes work, copied from the ticket.

## Acceptance criteria

The ticket's acceptance criteria, verbatim.

## Where to work

The modules, seams, and domain vocabulary involved (use `CONTEXT.md` terms). Name modules and seams, not exhaustive file lists.

## PRD impact

Which sections of which PRDs under `docs/prd/` this change contradicts or updates — or "None". Check the index at `docs/prd/README.md`.

## Implementation plan

Numbered steps. Each step: what to change, in which module, and why. Include interface shapes (signatures, schema, type shapes) where prose would be ambiguous. If PRD impact is not "None", include the PRD amendments as steps — they land in the SAME commit as the code.

## Verification

How the developer proves each acceptance criterion: which existing tests must stay green, which new behaviour to check.

## Out of scope

What the developer must NOT touch — adjacent refactors, speculative abstractions, unrelated cleanup.

</dev-doc-template>

Keep it decision-rich and short. This doc is the developer's entire context pack — if it forces them to re-explore the whole repo, it has failed.

### 2. Implement (secondary)

Spawn ONE `Agent` call with `subagent_type="coder"` and `model="secondary"`. The prompt must include:

- The dev doc path and the ticket path — tell it to read both in full before touching code.
- The brief: "Implement exactly the plan in the dev doc — no more, no less. Stay out of the out-of-scope list. Run typechecking and the relevant tests as you go; fix what you break. If the plan turns out to be wrong or unimplementable, STOP and report why instead of improvising a different design."
- The report format: "Report under 300 words: what you changed (modules, not line counts), verification results (typecheck, tests — with failures quoted), and any deviations from the plan with reasons."

### 3. Review (primary)

Review the result yourself — lightweight and per-ticket. The heavy two-axis review (`/simp-code-review`) is a separate, manually-invoked skill.

1. `git diff` the ticket's changes and read the diff in full.
2. Check each acceptance criterion against the diff — every one must be demonstrably satisfied.
3. Check for scope creep: anything in the diff the dev doc didn't ask for.
4. **PRD sync**: if the dev doc declared PRD impact, confirm those PRD sections were actually amended in the same change. If impact was declared "None" but the diff contradicts a PRD's described behaviour, amend that PRD section now, in the same commit.
5. Rerun the tests yourself if the developer's verification claims look off.

Then:

- **All good** → commit the work to the current branch, then close the ticket (step 4).
- **Small issues** (style, a missed edge case) → fix them yourself, commit, then close the ticket (step 4).
- **Plan was wrong or implementation is broken** → revise the dev doc, spawn a FRESH secondary agent (do not resume the old one — its context is polluted with the wrong approach) and repeat from step 2. The ticket stays open.

### 4. Close the ticket

Only after the commit lands:

- In the ticket file, check every acceptance-criterion checkbox and change the `Status:` line to `resolved`.
- Never delete the ticket file during the feature; `.scratch/` is disposable once the feature is done.

If a PRD exists for this feature, note in it (one line under Further Notes) which tickets it was split into — enough for future traceability without committing the tickets themselves.

### Escalation

If a ticket bounces back from secondary twice, or the dev doc itself needs design-level rethinking, stop and tell the user — this ticket is beyond the secondary model and should be implemented by the primary directly. Don't let secondary retry-loop indefinitely.
