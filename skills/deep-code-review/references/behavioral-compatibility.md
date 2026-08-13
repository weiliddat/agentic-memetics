# Behavioral Compatibility Review Guide

Use this guide to find regressions where changed code remains locally plausible but alters an existing workflow, variant, default, or failure boundary.

## Discovery and risk ranking

1. Identify material changed decisions: guards, predicates, defaults, filters, capability checks, dispatch rules, fallbacks, retries, and exception boundaries that can alter an externally observable outcome.
2. Reconstruct old behavior from the merge base. Record the old and new observable outcomes without relying on names or stated intent.
3. Shortlist the pre-existing entry points and behaviorally distinct variants that reach those decisions, including relevant out-of-diff callers, persisted/default values, provider/backend types, interactive and scheduled flows, and single-item versus fan-out execution.
4. Rank paths by blast radius, common or business-critical use, silent outcome changes, shared predicates/defaults, destructive or partial state, and weak test evidence.

Do not exhaustively trace low-impact local branches merely because they changed syntactically. Do not construct a Cartesian product of inputs and modes. Start with the highest-risk paths, choose representative variants for each behaviorally distinct axis, and expand only when code or evidence suggests a different outcome. Stop once equivalence or intentional breakage is established with adequate evidence.

## What to verify

- When one predicate or capability replaces another, compare their truth tables over relevant existing variants. A broader-looking abstraction can be narrower because of defaults or legacy data.
- For fan-out work such as loops, queues, batches, or multi-tenant processing, consider failures at material newly added fallible operations. Determine the intended atomicity boundary first, then check both directions: aborting genuinely independent work and continuing after a failure that should be fatal.
- Inspect relevant tests for previously successful behavior, the new path, and material failure cases. Passing new happy-path tests do not establish backward compatibility.

Failure containment is not a mandate to add exception handling. Failing loudly and atomically is correct when the operation owns one unit of work or cannot continue safely. Recommend catching only at a boundary that can recover, classify, retry, skip a genuinely independent unit, or add useful context while preserving propagation and observability. Prefer simpler control flow, moving optional or fallible setup out of shared paths, validation, transactions, or an existing orchestration boundary over broad catch-log-continue handling.

## Reporting discipline

Keep the path inventory as internal working notes. Report only evidenced regressions, meaningful missing coverage, or uncertainty that remains after following accessible code. If no behavioral compatibility finding qualifies, briefly state the high-risk path axes checked so the clean result is auditable without dumping the inventory.
