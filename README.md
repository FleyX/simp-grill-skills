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
/simp-to-spec          synthesise the conversation into a spec
                       (always persists a snapshot PRD under .scratch/)
/simp-to-tickets       split the PRD into tracer-bullet tickets under .scratch/
/simp-implement [--all] per ticket: primary plans → secondary implements → primary reviews
                       (--all implements the feature's tickets sequentially)
/simp-implement-tdd [--all] TDD variant: secondary tester/implementer pair builds test-first
/simp-code-review      standalone two-axis review, invoked manually only
```

Invoke `simp-grill` → `simp-to-spec` manually in **one unbroken context window** — the spec builds on the interview. Invoke `simp-to-tickets` separately in the same window or in a fresh one with an explicit PRD path. No skill invokes the next automatically. Each implementation invocation runs in a fresh context. By default it implements one ticket; with `--all`, it implements the feature's tickets sequentially, then stops.

## Document map

| Document | Location | Committed | Nature | Written by |
|---|---|---|---|---|
| Glossary | `CONTEXT.md` | yes | living (terms only) | simp-grill |
| ADRs | `docs/adr/` | yes | snapshots — supersede, never edit | simp-grill / simp-to-spec |
| PRDs | `.scratch/<feature>/prd.md` | **no** (gitignored) | local, long-term snapshots — never edit | simp-to-spec |
| Tickets | `.scratch/<feature>/issues/` | **no** (gitignored) | ephemeral; each references its PRD | simp-to-tickets |
| Dev docs | `.scratch/<feature>/dev-docs/` | **no** (gitignored) | ephemeral | simp-implement / simp-implement-tdd |

## Rules worth knowing

- **Every spec is persisted.** `/simp-to-spec` always writes a local PRD; there is no `--docs` option or big-vs-small persistence decision.
- **Every stage has a gate.** Each skill completes its own work and stops. It may suggest the next command but must not invoke it. Approving the current output, saying “continue”, or listing the full pipeline in the original request does not authorize another stage; after seeing the current output, the user must explicitly invoke the next skill.
- **Batch implementation is explicit.** `--all` authorizes both implementation skills to finish one feature's tickets in dependency order, with a fresh secondary and a separate commit per ticket. Any failure or question stops the batch; it never authorizes another feature or skill.
- **Independent entry is allowed.** Invoke a later skill directly when its input is sufficient. A fresh-context `simp-to-tickets` invocation needs an explicit PRD path. If input is missing, stop and report what is needed instead of automatically running earlier stages.
- **PRDs are local and long-term.** They support traceability on this machine but are not shared through git. Keep them when cleaning up `.scratch/`.
- **Boundary violations stop immediately.** Disclose what was produced and leave it in place; do not delete it or continue later work. Wait for the user's instruction.
- **ADRs need all three**: hard to reverse, surprising without context, a real trade-off. Otherwise skip.
- **PRDs are historical snapshots.** Once written, a PRD is never edited. There is no PRD index or supersede mechanism. Code and tests describe current behaviour; PRDs record the intent of individual requirements.
- **Tickets are scaffolding.** They are never committed and carry the PRD path into implementation. Tickets and dev docs are disposable; PRDs are not.
- **Two levels of review.** `simp-implement` does a lightweight per-ticket review (diff vs acceptance criteria, PRD fidelity). `simp-code-review` is the heavy two-axis review — run it manually when it's worth the cost, typically at feature end.
- **Implementation runs on the secondary model.** The primary writes the dev doc and reviews; the secondary reads code, edits, and runs tests.

## Installation

Run the installer with an optional target directory:

```sh
./install.sh [target-directory]
```

On Windows:

```bat
install.bat [target-directory]
```

The default target is `~/.agents/skills` on Linux/macOS and `%USERPROFILE%\.agents\skills` on Windows. Both scripts copy every skill directory and overwrite same-named files when run again.

To symlink the skill directories instead:

```sh
ln -s "$PWD"/simp-* ~/.agents/skills/
```
