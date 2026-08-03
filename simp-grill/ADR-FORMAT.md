# ADR Format

ADRs live in `docs/adr/` with sequential numbering: `0001-slug.md`, `0002-slug.md`. Create the directory lazily — only when the first ADR is needed. Scan for the highest existing number and increment by one.

ADRs are **snapshots**: once written, never edit. To revisit a decision, write a new ADR and mark the old one `superseded by ADR-NNNN`.

## Template

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

That's it. An ADR can be a single paragraph. The value is in recording *that* a decision was made and *why* — not in filling out sections.

## Optional sections

Only when they add genuine value — most ADRs won't need them:

- **Status** frontmatter (`proposed | accepted | superseded by ADR-NNNN`)
- **Considered Options** — when the rejected alternatives are worth remembering
- **Consequences** — when non-obvious downstream effects need calling out

## When to write one

All three must be true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why on earth did they do it this way?"
3. **The result of a real trade-off** — genuine alternatives existed and you picked one for specific reasons

### What qualifies

- **Architectural shape.** "The write model is event-sourced, the read model is projected into Postgres."
- **Technology choices that carry lock-in.** Database, message bus, auth provider — the ones that would take a quarter to swap out.
- **Boundary and scope decisions.** "Customer data is owned by the Customer module; others reference it by ID only." The explicit no-s are as valuable as the yes-s.
- **Deliberate deviations from the obvious path.** Anything where a reasonable reader would assume the opposite.
- **Constraints not visible in the code.** "We can't use AWS because of compliance requirements."
- **Rejected alternatives when the rejection is non-obvious** — otherwise someone will suggest them again in six months.
