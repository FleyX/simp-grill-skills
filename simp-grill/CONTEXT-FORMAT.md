# CONTEXT.md Format

Single-context only: one `CONTEXT.md` at the repo root. Create it lazily — when the first term is resolved.

## Structure

```md
# {Project Name}

{One or two sentence description of what this project is.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this project's domain.** General programming concepts (timeouts, error types, utility patterns) don't belong, even if the project uses them extensively.
- **Group terms under subheadings** when natural clusters emerge; a flat list is fine for a cohesive single area.
- **Glossary only.** No implementation details, no decisions (those are ADRs), no spec content.
