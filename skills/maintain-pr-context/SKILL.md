---
name: maintain-pr-context
description: Maintain branch-specific PR.md context. Use when managed PR.md contains substantive branch-specific working context; when beginning PR-bound work on a fresh branch with a Linear issue in the request or context; or when explicitly asked to initialize, refresh, or derive a PR description from PR.md. Empty files, unfilled templates, and checkout notices are not working context.
---

# Maintain PR Context

Keep the current branch's shared `PR.md` as a concise working brief for implementation, review, and QA. Keep its repository-root symlink and external target out of staging and the pull request unless the user or repository explicitly requires otherwise.

## Scope and authorization

For evaluation-only requests, read `PR.md` as context and keep findings in the response unless recording them is already authorized. Do not initialize or repair the context store as a side effect of an evaluation. During implementation, maintain the document within the agreed scope. Distinguish proposed changes from adopted decisions; carry forward authorization already given.

## Resolve and read the current context

- Identify the repository, current branch or detached state, working-tree status, and root `PR.md` file type, tracking, and ignore state. Verify its managed symlink target and the document's branch metadata before relying on it.
- If a tool refuses the symlink, resolve it and operate on the target. Never replace it with a regular file to work around a tool limitation, or overwrite an unmanaged file, symlink, or another branch's context.
- When setup is absent, broken, or points at the wrong branch, consult [`../setup-pr-context/SKILL.md`](../setup-pr-context/SKILL.md). Follow its repair workflow when authorized; otherwise report the problem and use only context whose ownership is established.
- Treat `PR.md` as existing working context when it contains substantive branch-specific information. An empty file, unfilled template, or default-branch/detached-HEAD notice is not working context; its existence alone does not activate this skill or expand scope. Do not initialize context on the default branch or detached HEAD without explicit instruction.
- An unfilled template contains only headings, instructions, and placeholders, without actual branch-specific goals, decisions, implementation notes, or findings. Remaining placeholders do not invalidate otherwise useful context.
- For existing working context, read branch metadata and all of `Current state` before planning or changing code. Consult relevant `History` and linked `Appendix` entries when they explain a decision, support evidence needed for the task, or resolve a material uncertainty. Do not load the entire appendix by default.

## Start or resume

Initial implicit activation requires both a fresh branch intended for PR work and a Linear issue identifier or link in the request or available context. Infer freshness from branch creation, the request, or the absence of established work; do not assume every non-default branch is fresh. Explicit invocation overrides this activation gate, but not the scope of the request.

For new context, gather the available issue goal, requirements, constraints, discussion, and acceptance criteria. Mark inaccessible information as a gap. Populate [`assets/PR.md`](assets/PR.md) in the verified external target, preserving every template section in order. Replace placeholders with concrete information or `None yet`; leave the reusable asset unchanged.

Resume matching existing working context rather than recreating it. Treat it as the working statement of scope, decisions, deferrals, and validation, while reconciling material conflicts with the user, issue, implementation, or observed results. Do not silently choose a source or present an inference as an agreed decision.

## Document model

Keep the three top-level sections in this order:

- **Current state:** present-tense scope, decisions, implemented approach, work items, risks, and validation. Rewrite it as the work evolves. Put inherited constraints and prior attempts under `Constraints and prior context`; keep this PR's iteration narrative in History.
- **History:** dated, append-only in substance, oldest first. Record meaningful changes in direction, decisions, rejected approaches, findings, and resolutions with their reasons. Omit routine housekeeping unless it changes scope, behavior, risk, or validation. Refer to current decisions rather than duplicating them. Compact superseded entries only without losing the original event or decision, still-relevant rationale, or supporting links.
- **Appendix:** oversized supporting material, such as logs, diagrams, tables, or detailed analysis. Keep its conclusions in Current state or History with links to the evidence. Never leave a decision, finding, risk, or result only in the appendix. Use `None yet` when empty.

Current state is authoritative within the document; reconcile stale or contradictory summaries. Before rewriting a summary that links to appendix evidence, preserve its finding and link in History when they remain meaningful. Otherwise update or remove the now-uncited material. Preserve evidence cited by History and add a new appendix item for later evidence rather than changing the historical support.

## Maintain during authorized work

- Record material discoveries, adopted product and technical decisions, scope changes, milestones, defects, deferrals, and validation results. Refresh `Last updated` with material updates.
- Record agreed scope changes before implementing them. When the user changes direction, update the affected Current state and append the meaningful change and rationale to History together.
- Keep the implemented approach and work-item checkboxes aligned with the code. Record defects and deferrals with impact, rationale, and a concrete follow-up or an explicit statement that none is planned.
- Add validation commands or scenarios and expected outcomes before or while implementing. Record actual results, including failures and skipped checks. Keep plans, expectations, and observed results distinct.
- Before handoff, commit, or PR drafting, reconcile relevant context against the current diff, working-tree status, and validation evidence.

Write factual, independently understandable entries. Include the substance and rationale the reader needs; omit rhetoric, boilerplate, repeated summaries, and narration of routine work.

## Draft a pull request

When asked to draft or create a PR description, read [`references/pr-description.md`](references/pr-description.md). It covers reviewer-facing scope, decisions, context, and validation; ordinary context maintenance does not require it.

Retain branch files while implementation, review, or QA follow-up remains active. Remove them only during confirmed PR cleanup or when explicitly requested.
