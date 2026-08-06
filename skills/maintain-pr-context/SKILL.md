---
name: maintain-pr-context
description: Maintain an ephemeral repository-root PR.md as the living source of truth for pull-request work, covering scope, prior considerations, product and technical decisions, implementation status, accepted defects or deferrals, and QA. Use when either (1) beginning PR-bound work on a fresh branch and the request or available context mentions or links a Linear issue—both conditions are required for initial implicit activation—or (2) PR.md already exists for the current work, in which case read and update it throughout the task. Also use when explicitly asked to initialize, refresh, or turn this PR.md into a PR description.
---

# Maintain PR Context

Keep `PR.md` as a current working brief for one branch or worktree. Make it useful to implementers now and to reviewers and QA later. Keep it out of the pull request unless the user or repository explicitly requires otherwise.

## Apply the invariants

- Read `PR.md` before planning or changing code whenever it exists.
- Treat a matching `PR.md` as the primary statement of work scope, decisions, plan, deferrals, and validation. Reconcile contradictions with the user, Linear issue, code, or test results instead of silently choosing one.
- Update the document after every material discovery, decision, scope change, implementation milestone, accepted defect or deferral, and validation result.
- Refresh `Last updated` whenever making a material update.
- Keep it as a concise current-state summary, not a chronological activity log. Preserve rejected alternatives and earlier constraints only when they explain the present approach.
- Separate facts, decisions, plans, expectations, and observed results. Never describe planned or unrun validation as completed.
- Verify that the recorded branch matches the current branch before relying on the document. Do not overwrite context belonging to another branch.
- Do not commit or stage `PR.md` unless the user or repository explicitly makes it a tracked artifact.

## Start or resume the document

1. Find the repository root, current branch, working-tree state, and whether `PR.md` is tracked, ignored, or present.
2. For initial implicit activation, confirm both conditions:
   - The branch is fresh and intended for pull-request work. Infer this from the user's request, branch creation context, or the absence of established branch work; do not assume every non-default branch is fresh.
   - A Linear issue identifier or link appears in the request or available work context.
3. If either initial condition is absent, do not create `PR.md` implicitly. Explicit invocation overrides this gate.
4. If `PR.md` exists, read it in full and confirm its branch metadata matches. Continue from it rather than recreating it. If it belongs to different active work, preserve it and ask before replacing it.
5. Gather the Linear issue's goal, requirements, constraints, discussion, and acceptance criteria through any available issue integration. If the issue cannot be accessed, record only the context available and mark gaps rather than guessing.
6. If creating an untracked `PR.md`, prefer a repository-local exclude entry such as `/PR.md` in the path reported by `git rev-parse --git-path info/exclude`. Make the entry idempotent. Do not change the committed `.gitignore` merely for this workflow.
7. If `PR.md` is already tracked or repository policy prevents a local exclude, do not alter index or ignore policy without authorization. Warn that the file must not be included accidentally, then follow the repository's convention.
8. Locate [`assets/PR.md`](assets/PR.md) relative to this `SKILL.md`. Copy it to `<repository-root>/PR.md` with the available filesystem capability, preserving the asset as the reusable template. Do not require a harness-specific skill-directory variable or command.
9. Replace the copied prompts with concrete content. Use `None yet` where an empty section would be ambiguous. If the host can read the asset but cannot write to the repository, return the populated document for the user to save instead.

Keep every section from the template: goal and scope, past considerations, product decisions, technical decisions, implementation plan and current state, accepted defects or deferrals, and QA expectations and results.

## Maintain it during implementation

- Update scope before implementing an agreed expansion or reduction.
- Record a product decision when behavior, user experience, compatibility, or acceptance criteria are chosen.
- Record a technical decision when architecture, data shape, dependencies, migration, rollout, security, or operational behavior is chosen.
- Keep work-item checkboxes aligned with reality. Update the implemented approach after the code departs materially from the initial plan.
- Record known defects and deferrals with impact, rationale, and a concrete follow-up or explicit statement that none is planned.
- Add validation commands and QA scenarios before or while implementing. After running them, preserve the expectation and record the exact observed result, including failures or skipped checks.
- When the user changes direction, treat the user instruction as authoritative and update `PR.md` immediately so stale guidance does not remain the source of truth.
- Before handing work off, committing, or drafting the PR, reconcile the document against the current diff, working-tree status, and actual validation evidence.

## Draft the pull request description

When asked to draft or create the pull request:

1. Refresh `PR.md` from the implemented diff and latest validation results.
2. Use it to explain the goal, scope, implemented approach, reviewer-relevant product and technical decisions, accepted limitations or follow-ups, and exact QA evidence.
3. Link the Linear issue when a link is available.
4. Omit internal process detail and abandoned ideas unless they materially help review the chosen implementation.
5. Confirm `PR.md` is neither staged nor included in the pull-request diff.

Retain `PR.md` while branch work, review, or QA follow-up remains active. Remove it only as part of confirmed branch or worktree cleanup, or when the user explicitly asks.
