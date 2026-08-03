# simp-grill

[中文文档](./README.zh.md)

A minimal, cost-conscious skill pipeline for feature development, adapted from [mattpocock/skills](https://github.com/mattpocock/skills). Local-first: no issue tracker, no setup step, all conventions hardcoded.

## The pipeline

```
/simp-grill            interview the requirement; maintain CONTEXT.md + ADRs
/simp-to-spec [--docs] synthesise the conversation into a spec
                       (--docs persists it as a living PRD under docs/prd/)
/simp-to-tickets       split into tracer-bullet tickets under .scratch/
/simp-implement        per ticket: primary plans → secondary builds → primary reviews
/simp-code-review      standalone two-axis review, invoked manually only
```

Run `simp-grill` → `simp-to-spec` → `simp-to-tickets` in **one unbroken context window** — each builds on the same thinking. Each `/simp-implement` runs in a fresh context, one ticket at a time.

## Document map

| Document | Location | Committed | Nature | Written by |
|---|---|---|---|---|
| Glossary | `CONTEXT.md` | yes | living (terms only) | simp-grill |
| ADRs | `docs/adr/` | yes | snapshots — supersede, never edit | simp-grill / simp-to-spec |
| PRDs | `docs/prd/` (+ `README.md` index) | yes | living — amend affected sections in the same commit as the code | simp-to-spec --docs / simp-implement |
| Tickets | `.scratch/<feature>/issues/` | **no** (gitignored) | ephemeral | simp-to-tickets |
| Dev docs | `.scratch/<feature>/dev-docs/` | **no** (gitignored) | ephemeral | simp-implement |

## Rules worth knowing

- **Big vs small is chosen by invocation, not by judgement.** Want a durable PRD? Say `/simp-to-spec --docs`. Don't? Say `/simp-to-spec` and build in-session.
- **ADRs need all three**: hard to reverse, surprising without context, a real trade-off. Otherwise skip.
- **PRDs are living documents.** Any change that contradicts a PRD's described behaviour amends the affected sections in the same commit — including small fixes that never got their own PRD.
- **Tickets are scaffolding.** They are never committed; the PRD records which tickets a feature was split into (one line).
- **Two levels of review.** `simp-implement` does a lightweight per-ticket review (diff vs acceptance criteria, PRD sync). `simp-code-review` is the heavy two-axis review — run it manually when it's worth the cost, typically at feature end.
- **Implementation runs on the secondary model.** The primary writes the dev doc and reviews; the secondary reads code, edits, and runs tests.

## Installation

Symlink (or copy) the skill directories into your agent's skills directory, e.g.:

```sh
ln -s "$PWD"/simp-* ~/.agents/skills/
```
