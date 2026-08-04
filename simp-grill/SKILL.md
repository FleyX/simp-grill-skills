---
name: simp-grill
description: "Sharpen a requirement by relentless interview, maintaining the project's CONTEXT.md glossary and ADRs as decisions crystallise."
disable-model-invocation: true
---

# Simp Grill

Interview the user relentlessly about every aspect of the requirement until you reach a shared understanding. Map the requirement as a decision tree and walk down every branch, resolving dependencies between decisions in order. For each question, provide your recommended answer.

Work through the decision tree in **rounds**. The frontier is every decision whose prerequisites are already settled. Ask the whole current frontier in one round, numbering each question and giving your recommended answer for each. Do not ask a question whose answer depends on another question that is still open in the current round; ask it in a later round after recomputing the frontier from the user's answers. Wait for the user's answers to the current round before continuing.

If a *fact* can be found by exploring the environment (filesystem, code, tools), look it up rather than asking. The *decisions*, though, belong to the user — put each one to them and wait for the answer.

Keep questions at the requirement and domain level. Do not proactively ask for implementation details such as field names, index names, file paths, class names, function names, or routine technology choices. Ask about an implementation detail only when it changes externally observable behaviour, an external contract, data compatibility, or a hard-to-reverse decision.

Do not act on the requirement until the user confirms shared understanding.

## Maintaining the domain model during the session

### Challenge against the glossary

When the user uses a term that conflicts with `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

Stress-test domain relationships with specific scenarios that probe edge cases and force the user to be precise about boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. Surface contradictions: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there — don't batch. It is a **glossary and nothing else**: no implementation details, no spec content, no scratch notes. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md). Create it lazily, at the repo root, when the first term is resolved.

### Record ADRs — only when all three are true

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. ADRs are **snapshots**: never edit one; supersede it with a new ADR. Use the format in [ADR-FORMAT.md](./ADR-FORMAT.md).

## Next step

When the interview converges, continue in the **same context window** with `/simp-to-spec`. Do not automatically choose `--docs`. If you think the feature would benefit from a durable PRD, explain why and ask the user for explicit confirmation first. Invoke `/simp-to-spec --docs` only after the user confirms; otherwise use `/simp-to-spec` without `--docs`.
