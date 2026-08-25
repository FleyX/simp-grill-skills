---
name: simp-implement
description: "Implement one ticket: primary model writes a dev doc, a secondary tester/implementer pair builds it test-first (red→green at pre-agreed seams), primary reviews, then the ticket is closed."
disable-model-invocation: true
---

# Simp Implement

Implement one ticket via a **primary → secondary pair → primary** pipeline. The primary model (you) does the two quality-sensitive ends — planning and review. The secondary models do the token-heavy middle — reading code, writing tests, implementing, running tests.

Tests come first. A **tester** secondary writes failing tests at the seams declared in the dev doc; an **implementer** secondary makes them green without ever touching the test files. The two roles never share an agent, so no model grades its own work.

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

Which sections of which PRDs under `docs/prd/` this change contradicts — or "None". Check the index at `docs/prd/README.md`. Informational only: simp-implement never writes to `docs/prd/` — supersede declarations belong to simp-to-spec.

## Seams under test

The public boundaries where behaviour is observed — one line per seam: the interface and which acceptance criteria it covers. "None" only for pure plumbing with no observable behaviour. Tests live at these seams and nowhere else.

## Slices

Vertical slices, one per red → green cycle. Each slice: the seam under test, the exact behaviour the test asserts (with concrete expected values from an independent source — the ticket, a worked example, a known-good literal), and a note on the minimal implementation. Include interface shapes (signatures, schema, type shapes) where prose would be ambiguous.

## Verification

Which slice's test covers each acceptance criterion, which existing tests must stay green, and the full-suite run after the final slice.

## Out of scope

What the developer must NOT touch — adjacent refactors, speculative abstractions, unrelated cleanup.

</dev-doc-template>

Keep it decision-rich and short. This doc is the entire context pack for both secondaries — if it forces them to re-explore the whole repo, it has failed.

If the seams aren't obvious from the ticket, confirm them with the user before dispatching — no test gets written at an unconfirmed seam.

### 2. Implement (secondary pair)

Both roles — tester and implementer — ALWAYS run as subagents on the secondary model. The primary never writes tests or implementation code itself; apart from the dev doc (step 1) and the review (step 3), all code reading/writing happens inside these subagents.

Work the dev doc's slices in order, two dispatches per slice, using the syntax supported by the host:

- **Kimi Code**: spawn `Agent` calls with `subagent_type="coder"` and **omit the `model` parameter** so the host's secondary-model default applies. NEVER pass `model="primary"` — the primary model does only the dev doc and the review.
- **OpenCode**: spawn `Task` calls with `subagent_type="secondary"`. 

Across slices you may resume each role's previous agent — the tester never reads implementation code, so resuming keeps the isolation intact. Within a slice, never let one agent do both jobs.

**Tester prompt** must include:

- The dev doc path and the ticket path — tell it to read both in full before writing anything.
- The brief: "Write exactly ONE failing test for the current slice, at the seam named in the dev doc. Test behaviour through the public interface, not internals. Expected values come only from the dev doc or ticket — never recompute them the way an implementation would. Do not read the feature's implementation files; work from the dev doc and the seam's public surface. Run the test and confirm it fails for the right reason. If the seam is untestable or the slice spec is wrong, STOP and report why instead of improvising."
- The report format: "Report under 150 words: the test file path, what the test asserts, and the failure output proving red."

**Implementer prompt** must include:

- The dev doc path, the ticket path, and the test file path from the tester.
- The brief: "Make the failing test green with the minimal implementation. Do NOT modify the test file — if the test cannot pass without changing it, STOP and report why. Stay out of the out-of-scope list. Run this slice's test and typechecking as you go; fix what you break. If the plan turns out to be wrong or unimplementable, STOP and report why instead of improvising a different design."
- The report format: "Report under 300 words: what you changed (modules, not line counts), verification results (typecheck, tests — with failures quoted), and any deviations from the plan with reasons."

After the final slice, the implementer runs the full test suite once and includes the result in its report.

### 3. Review (primary)

Review the result yourself — lightweight and per-ticket. The heavy two-axis review (`/simp-code-review`) is a separate, manually-invoked skill.

1. `git diff` the ticket's changes and read the diff in full.
2. Check each acceptance criterion against the diff — every one must be demonstrably satisfied.
3. Check for scope creep: anything in the diff the dev doc didn't ask for — including tests written outside the declared seams.
4. **TDD discipline**: every acceptance criterion is covered by a behaviour test at a declared seam, and it passes. Tests are not implementation-coupled (mocking internal collaborators, testing privates) and not tautological (expected values recomputed the way the code does). Test files are untouched since the tester produced them — verify with the diff.
5. **PRD fidelity**: if the diff contradicts the current feature's own PRD, flag it to the user before committing. Contradictions with historical PRDs are expected — they were declared as supersedes by the feature's PRD (or will be, by the next PRD covering the area). Never write to `docs/prd/`.
6. Rerun the tests yourself if either secondary's verification claims look off.

Then:

- **All good** → commit the work to the current branch, then close the ticket (step 4).
- **Small issues** (style, a missed edge case) → fix them yourself, commit, then close the ticket (step 4).
- **Plan was wrong, test is wrong, or implementation is broken** → revise the dev doc, spawn FRESH secondary agents (do not resume the old ones — their context is polluted with the wrong approach) and repeat from step 2. The ticket stays open.

### 4. Close the ticket

Only after the commit lands:

- In the ticket file, check every acceptance-criterion checkbox and change the `Status:` line to `resolved`.
- Never delete the ticket file during the feature; `.scratch/` is disposable once the feature is done.

### Escalation

If a ticket bounces back from either secondary role twice, or the dev doc itself needs design-level rethinking, stop and tell the user — this ticket is beyond the secondary models and should be implemented by the primary directly. Don't let secondaries retry-loop indefinitely.
