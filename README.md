# simp-grill

[中文文档](./README.zh.md)

A minimal, cost-conscious skill pipeline for feature development, adapted from [mattpocock/skills](https://github.com/mattpocock/skills). Local-first: no issue tracker, no setup step, all conventions hardcoded.

## Runtime Compatibility

The pipeline is designed to work with both Kimi Code and OpenCode. The
`simp-implement` workflow stays the same; only the secondary-agent dispatch
syntax changes:

| Runtime | Dispatch | Target | Configuration |
|---|---|---|---|
| Kimi Code | `Agent` | `subagent_type="coder"` | Run `/secondary_model` |
| OpenCode | `Task` | `subagent_type="secondary"` | Configure the `secondary` agent |

Kimi Code:

```text
Agent(subagent_type="coder", model="secondary")
```

OpenCode:

```text
Task(subagent_type="secondary")
```

In OpenCode, `secondary` is the agent name, not a model ID. Its model must be
configured in an agent definition. Create
`~/.config/opencode/agents/secondary.md` for a global agent, or
`.opencode/agents/secondary.md` for a project-specific agent:

```markdown
---
description: Implements planned tickets and runs the relevant checks.
mode: subagent
model: opencode-go/deepseek-v4-flash
---

Implement the task described by the parent agent. Read the referenced ticket
and dev doc first, make the required changes, and run the relevant checks.
```

## The pipeline

```
/simp-grill            interview the requirement; maintain CONTEXT.md + ADRs
/simp-to-spec [--docs] synthesise the conversation into a spec
                       (--docs persists it as a snapshot PRD under docs/prd/)
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
| PRDs | `docs/prd/` (+ `README.md` index) | yes | snapshots — supersede, never edit; index carries status markers | simp-to-spec --docs |
| Tickets | `.scratch/<feature>/issues/` | **no** (gitignored) | ephemeral | simp-to-tickets |
| Dev docs | `.scratch/<feature>/dev-docs/` | **no** (gitignored) | ephemeral | simp-implement |

## Rules worth knowing

- **Big vs small is chosen by invocation, not by judgement.** Want a durable PRD? Say `/simp-to-spec --docs`. Don't? Say `/simp-to-spec` and build in-session.
- **PRD persistence requires confirmation.** If `simp-grill` thinks a durable PRD would help, it must explain why and ask the user before invoking `/simp-to-spec --docs`; without confirmation, use `/simp-to-spec` without `--docs`.
- **ADRs need all three**: hard to reverse, surprising without context, a real trade-off. Otherwise skip.
- **PRDs are snapshots.** Once written, a PRD is never edited. New features declare supersedes in their own PRD; code changes that contradict a PRD mark its index line `→ partially stale` in the same commit — including small fixes that never got their own PRD.
- **Tickets are scaffolding.** They are never committed; the PRD's index line records which tickets a feature was split into — enough for traceability.
- **Two levels of review.** `simp-implement` does a lightweight per-ticket review (diff vs acceptance criteria, PRD staleness marking). `simp-code-review` is the heavy two-axis review — run it manually when it's worth the cost, typically at feature end.
- **Implementation runs on the secondary model.** The primary writes the dev doc and reviews; the secondary reads code, edits, and runs tests.

## Installation

Symlink (or copy) the skill directories into your agent's skills directory, e.g.:

```sh
ln -s "$PWD"/simp-* ~/.agents/skills/
```
