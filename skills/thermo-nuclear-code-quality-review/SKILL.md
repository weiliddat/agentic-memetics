---
name: thermo-nuclear-code-quality-review
description: Audits structure, simplification, maintainability, canonical ownership, and reuse. Use only when the user explicitly asks for thermo-nuclear-code-quality-review or a thermo-nuclear code quality review, or assigns this rubric through an explicitly requested thermos review.
---

# Thermo-Nuclear Code Quality Review

Demand a clear, maintainable implementation, not merely working behavior. Seek behavior-preserving restructurings that delete complexity rather than redistribute it.

## Scope and independence

Establish the comparison baseline, full change set, stated intent, and constraints. Review structural regressions and simplifications made relevant by the changes, not unrelated cleanup. Read surrounding code and trace cross-file boundaries to understand ownership and existing alternatives.

Form and record your own findings before reading PR/MR discussion or any other reviewer's output. If this rubric is assigned as one of several reviews, receive only the scope, factual context, and source material—not proposed findings. In a combined review, leave discussion reconciliation to the coordinator after all independent audits finish. Do not delegate further unless explicitly requested.

## Standards

- **Ambitious simplification.** Look for a reframing that removes entire concepts, branches, helpers, modes, or layers—"code judo." Prefer a simpler state model, ownership boundary, or default flow over polishing the same complicated idea. Refactors that only move complexity do not meet this bar.
- **Cohesive decomposition.** If the diff takes a file from below 1,000 lines to above 1,000, ask whether it should be decomposed first. Waive this strong smell only for a compelling structural reason and a clearly organized result. Extract coherent responsibilities, not arbitrary chunks merely to meet a line count.
- **No spaghetti growth.** Treat scattered feature checks, ad-hoc conditionals, one-off booleans, nullable modes, and special cases inserted into busy or unrelated flows as design problems. Look for a model or boundary that removes them; centralizing the same branching is not necessarily simpler.
- **Direct code and earned abstractions.** Prefer boring, explicit flows. Question magical generic handling, identity wrappers, pass-through helpers, and indirection that hides simple data shapes without buying clarity. Doing less or deleting a layer may be better than adding an abstraction.
- **Types and contracts.** Investigate unnecessary optionality, `any`, `unknown`, casts, and ad-hoc objects that obscure an invariant. Prefer explicit models and boundary contracts; do not accept silent fallbacks that conceal an unclear guarantee.
- **Canonical ownership and reuse.** Find the package, service, or module that owns the concept and its existing utilities, including dependency APIs. Flag feature policy scattered through shared paths, implementation details leaking through APIs, duplicated logic, and bespoke helpers that repeat a canonical capability. Verify that the existing alternative actually meets the change's requirements before recommending reuse.
- **Orchestration and atomicity.** Question avoidable serialization of independent work and related updates that leave half-applied state. Prefer parallel or atomic structure when it clearly simplifies the flow and preserves ordering and failure semantics; do not turn this into a micro-optimization checklist.

For each meaningful change, ask what a reader must now understand, what became more coupled or stateful, and whether a smaller set of concepts would deliver the same behavior. Compare the proposed remedy with the current implementation and constraints. Show what complexity disappears and what the alternative costs; unfamiliarity or personal taste is not evidence of a flaw.

## Report and approval bar

Prioritize findings in this order:

1. Structural code-quality regressions.
2. Missed opportunities for dramatic simplification.
3. Spaghetti or branching-complexity growth.
4. Boundary, abstraction, and type-contract problems.
5. File-size and decomposition concerns.
6. Modularity and abstraction issues.
7. Legibility and maintainability concerns.

Be direct and demanding, not rude. Prefer high-conviction structural findings to cosmetic nits. Give source evidence, the maintenance cost, and a concrete behavior-preserving remedy using the current harness's native code-reference and citation formatting. Resolve accessible factual questions; distinguish demonstrated problems from uncertainty.

Correct behavior alone is not enough for a favorable verdict. Treat clear structural regressions, visibly simpler models left unused, unjustified file growth, tangled special cases, unnecessary indirection, canonical-capability duplication, and misplaced ownership as presumptive reasons to revise unless a concrete justification outweighs them. Distinguish those from optional improvements; do not inflate severity merely because a refactor is possible.

State the verdict and material coverage limits. Keep material findings judged not worth fixing now in a later **Not worth fixing now** section, with a reason for each. Attribute outside findings consulted after your own audit, validating them rather than inheriting their conclusions.

Review only; do not implement fixes, post external comments, approve, or ship changes unless separately asked.
