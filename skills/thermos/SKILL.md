---
name: thermos
description: Combines independent correctness/security and code-quality audits, with prioritized findings and explicit deferrals. Use only when the user explicitly asks for thermos or a double thermo review. Do not invoke it as a follow-up to unrelated work.
---

# Thermos

Run two independent audits of the same changes, then validate and combine their findings.

## Independent audits

1. Establish the review scope, comparison baseline, full change set, stated intent, and relevant constraints. Gather the diff and enough source context to start; reviewers must be able to inspect further code rather than guess from excerpts. Exclude PR/MR discussion, other review output, and suggested findings from the handoff.
2. Read both component rubrics by file path. Resolve these paths relative to this skill's parent directory under the repository or linked skills root. If the harness stores skills in separate or versioned directories, locate the corresponding installed `SKILL.md` files using its exposed skill locations instead. Pass the actual resolved paths; do not invoke components by registered skill name:
   - [../thermo-nuclear-review/SKILL.md](../thermo-nuclear-review/SKILL.md): correctness, security, breakage, developer experience, and feature leaks.
   - [../thermo-nuclear-code-quality-review/SKILL.md](../thermo-nuclear-code-quality-review/SKILL.md): structure, simplification, boundaries, canonical ownership, and reuse.
3. Use the host harness's available delegation mechanism to assign one isolated reviewer to each rubric, preferably concurrently. Give each the same factual handoff and its resolved rubric path. Ask for its own evidence-backed findings, priorities, reasons for deferral, and coverage limits—not a combined verdict. Neither reviewer may read discussion or another reviewer's output before completing and recording its own audit. Do not pass findings between reviewers.
4. Collect both independent reports before consulting discussion or starting synthesis. If the harness supports isolated reviewers but not concurrency, run them sequentially without giving the second the first report. If isolated contexts are unavailable, perform two sequential passes yourself with separate notes and no discussion or synthesis until both finish; disclose that shared context prevents fully independent reviewers. If a rubric is missing or an audit cannot finish, report the limitation rather than claiming a complete thermos review.

## Combine without losing findings

After both audits finish, if a PR/MR exists and either audit has medium-or-higher findings, consult its discussion through available authorized access. Validate and attribute any outside findings incorporated. Resolve accessible factual questions and disagreements against the code, contracts, and constraints; do not accept a finding solely because a reviewer asserted it.

Merge true duplicates, preserving their evidence and attribution; keep distinct failure modes or remedies separate even when they share a location. Agreement can strengthen an evidence-backed conclusion but is not a vote for higher severity. Prioritize by demonstrated impact, urgency, and the value and cost of the remedy. Preserve material disagreements and uncertainty.

Lead with prioritized actionable findings, each with source evidence, consequences, and a concrete remedy. Follow with a concise unified verdict and material coverage limits. Use the current harness's native code-reference and citation formatting; do not restate the individual reports wholesale.

End with **Not worth fixing now**: list every reviewer finding not retained as actionable or merged into another finding, with its source and the specific reason it was rejected, deferred, or judged outweighed by cost. Include incorporated discussion findings handled the same way. Distinguish invalid findings, intentional tradeoffs, low-value improvements, and unresolved evidence. Say **None** if this section is empty. Nothing may disappear merely because it does not fit the summary.

Review only; do not implement fixes, post external comments, approve, or ship changes unless separately asked.
