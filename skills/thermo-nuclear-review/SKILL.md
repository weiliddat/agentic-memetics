---
name: thermo-nuclear-review
description: Audits correctness, security, breaking changes, developer experience, and feature-gate leaks. Use only when the user explicitly asks for thermo-nuclear-review or a thermo-nuclear correctness review, or assigns this rubric through an explicitly requested thermos review.
---

# Thermo-Nuclear Review

Audit the scoped changes thoroughly for bugs, broken contracts, and security vulnerabilities. Trace consequences rather than judging the diff in isolation.

## Scope and independence

Establish the comparison baseline, full change set, stated intent, and affected contracts. Report issues introduced or exposed by these changes, not unrelated pre-existing defects. Read unchanged callers, dependencies, and consumers to establish the impact.

Form and record your own findings before reading PR/MR discussion or any other reviewer's output. If this rubric is assigned as one of several reviews, receive only the scope, factual context, and source material—not proposed findings. In a combined review, leave discussion reconciliation to the coordinator after all independent audits finish. Do not delegate further unless explicitly requested.

## Audit

- **Correctness and breakage.** Trace cross-package effects and affected user and developer workflows end to end. Check changed contracts against existing callers and consumers, including failure and alternative paths. Investigate relevant state, concurrency, retry, and error-handling consequences rather than assuming local success proves the operation correct.
- **Security.** Follow affected trust boundaries, untrusted inputs, permissions, secrets, and data exposure through the real execution path. Establish who can trigger a failure or bypass a safeguard and what they gain.
- **Developer experience.** Catch changes to secret loading, environment variables, ports, networking, or mandatory scripts/setup that break the existing run/build workflow. New alternatives and ordinary package-manager dependency installation are not regressions unless they impose unusual manual setup.
- **Feature leaks.** Trace feature flags and internal-only checks across entry points and downstream paths. Look for features becoming reachable outside their intended gate.
- **Intentional changes.** Do not label deliberate, well-constrained breakage a defect merely because it changes existing behavior. Still flag unrecognized consequences, materially underestimated harm, or evidence of malicious intent. Establish the intended scope rather than inventing an accepted tradeoff.

Resolve accessible factual questions before reporting: if backend handling could settle a client concern, read the backend. Use focused checks or reproductions where they help and are safe. Do not present unfinished research as a confirmed issue; state material access or verification limits when they cannot be resolved.

Calibrate priority to demonstrated impact and realistic triggering conditions. Thoroughness does not justify inflated severity or speculative findings.

## Report

For a standalone review, if a PR/MR exists and your own audit has medium-or-higher findings, consult its discussion only now. Validate outside findings independently, merge duplicates, and attribute anything incorporated from another reviewer.

Lead with prioritized findings. For each, give the affected behavior or contract, a concrete failure/security path, source evidence, and an actionable remedy. Use the current harness's native code-reference and citation formatting. State the verdict and material coverage limits; if there are no actionable findings, say so without claiming the change cannot contain defects.

Keep material findings judged not worth fixing now in a later **Not worth fixing now** section, with a reason for each. Distinguish an accepted intentional change, a deferred issue, and an unconfirmed concern.

Review only; do not implement fixes, post external comments, approve, or ship changes unless separately asked.
