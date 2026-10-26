# simp-grill

[中文文档](./README.zh.md)

A minimal, cost-conscious skill pipeline for feature development, adapted from [mattpocock/skills](https://github.com/mattpocock/skills). Local-first: no issue tracker, no setup step, all conventions hardcoded.

## Runtime Compatibility

The pipeline is designed to work with both Kimi Code and OpenCode. The
`simp-implement`/`simp-implement-tdd` workflows stay the same; only the
secondary-agent dispatch syntax changes:

| Runtime | Dispatch | Target | Configuration |
|---|---|---|---|
| Kimi Code | `Agent` | `subagent_type="coder"` | Run `/secondary_model` |
| OpenCode | `Task` | `subagent_type="secondary"` | Configure the `secondary` agent |

Kimi Code:

```text
Agent(subagent_type="coder")
```

Omit the `model` parameter so the host's secondary-model default applies.

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
/simp-implement        per ticket: primary plans → secondary implements → primary reviews
/simp-implement-tdd    TDD variant: secondary tester/implementer pair builds test-first
/simp-code-review      standalone two-axis review, invoked manually only
```

Invoke `simp-grill` → `simp-to-spec` → `simp-to-tickets` manually, one at a time, in **one unbroken context window** — each builds on the same thinking, and none invokes the next automatically. Each `/simp-implement` runs in a fresh context, implements one ticket, then stops.

## Document map

| Document | Location | Committed | Nature | Written by |
|---|---|---|---|---|
| Glossary | `CONTEXT.md` | yes | living (terms only) | simp-grill |
| ADRs | `docs/adr/` | yes | snapshots — supersede, never edit | simp-grill / simp-to-spec |
| PRDs | `docs/prd/` (+ `README.md` index) | yes | snapshots — supersede, never edit; index carries status markers | simp-to-spec --docs |
| Tickets | `.scratch/<feature>/issues/` | **no** (gitignored) | ephemeral | simp-to-tickets |
| Dev docs | `.scratch/<feature>/dev-docs/` | **no** (gitignored) | ephemeral | simp-implement / simp-implement-tdd |

## Rules worth knowing

- **Big vs small is chosen by invocation, not by judgement.** Want a durable PRD? Explicitly invoke `/simp-to-spec --docs`. Don't? Invoke `/simp-to-spec` to synthesise it in conversation only.
- **Every stage has a gate.** Each skill completes its own work and stops. It may suggest the next command but must not invoke it. Approving the current output, saying “continue”, or listing the full pipeline in the original request does not authorize another stage; after seeing the current output, the user must explicitly invoke the next skill.
- **Independent entry is allowed.** Invoke a later skill directly when its input is sufficient. If input is missing, stop and report what is needed instead of automatically running earlier stages.
- **PRD persistence requires an explicit choice.** If `simp-grill` thinks a durable PRD would help, it may explain why and suggest `/simp-to-spec --docs`, but must never invoke it. Only the user's explicit invocation persists the PRD.
- **Boundary violations stop immediately.** Disclose what was produced and leave it in place; do not delete it or continue later work. Wait for the user's instruction.
- **ADRs need all three**: hard to reverse, surprising without context, a real trade-off. Otherwise skip.
- **PRDs are snapshots.** Once written, a PRD is never edited. New features declare supersedes in their own PRD. Code changes never touch `docs/prd/` — deviations from historical PRDs are expected and get superseded by the next PRD covering the area.
- **Tickets are scaffolding.** They are never committed; the durable record of intent is the PRD.
- **Two levels of review.** `simp-implement` does a lightweight per-ticket review (diff vs acceptance criteria, PRD fidelity). `simp-code-review` is the heavy two-axis review — run it manually when it's worth the cost, typically at feature end.
- **Implementation runs on the secondary model.** The primary writes the dev doc and reviews; the secondary reads code, edits, and runs tests.

## Installation

Symlink (or copy) the skill directories into your agent's skills directory, e.g.:

```sh
ln -s "$PWD"/simp-* ~/.agents/skills/
```
