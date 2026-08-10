---
name: maintain-pr-context
description: Maintain a populated branch-specific PR.md as the living source of truth for pull-request work, covering scope, prior considerations, product and technical decisions, implementation state, deferrals, and QA. Use when either (1) beginning PR-bound work on a fresh branch and the request or available context mentions or links a Linear issue—both conditions are required for initial implicit activation—or (2) the current managed PR.md contains active PR working context. Also use when explicitly asked to initialize, refresh, or turn PR.md into a PR description. Treat an empty managed file or inactive default-branch/detached notice as no active context.
---

# Maintain PR Context

Keep the current branch's shared `PR.md` as a concise working brief. Make it useful to implementers now and to reviewers and QA later. Keep its repository-root symlink and external target out of the pull request unless the user or repository explicitly requires otherwise.

## Resolve the current branch document

1. Find the repository root, current branch or detached state, working-tree status, and root `PR.md` file type, target, tracking, and ignore state.
2. Expect `PR.md` to be a managed symlink to the current branch's file in the shared external store. Verify the resolved target rather than trusting the root pathname alone.
3. If setup is absent, broken, or points at another branch, read [`../setup-pr-context/SKILL.md`](../setup-pr-context/SKILL.md) in full and follow its inspect or repair workflow. Do not overwrite a regular file, tracked file, unmanaged symlink, or another branch's context.
4. Read the resolved file in full before planning or changing code when it contains `<!-- pr-context: active -->` or otherwise clearly contains active PR working context.
5. Treat a zero-byte file and `<!-- pr-context: inactive -->` notice as no active context. Their existence alone must not activate this skill or expand task scope.
6. Do not initialize active context on the default branch or detached HEAD implicitly. Require an explicit user instruction.

## Apply the invariants

- Treat matching active context as the primary statement of work scope, decisions, plan, deferrals, and validation. Reconcile contradictions with the user, Linear issue, code, or test results instead of silently choosing one.
- Update the document after every material discovery, decision, scope change, implementation milestone, accepted defect or deferral, and validation result.
- Refresh `Last updated` whenever making a material update.
- Maintain the two halves with different edit disciplines. `Current state` is rewritten in place: always the present-tense truth about the work as it stands, with no iteration narrative, "previously", or "changed X to Y". `History` is append-only: dated entries added at the bottom, never edited retroactively.
- Do not duplicate content across the halves. A decision lives in `Current state`; the `History` entry records when and why it changed, referencing it rather than restating it. When the halves disagree, `Current state` is authoritative — fix the divergence.
- Distinguish context inherited from before this PR (prior attempts, Linear discussion, system constraints) from iteration within this PR. The former belongs in `Constraints and prior context`; the latter belongs in `History`.
- When `History` grows long, compact entries that later entries supersede into dated one-liners instead of deleting them.
- Separate facts, decisions, plans, expectations, and observed results. Never describe planned or unrun validation as completed.
- Verify that the recorded branch matches the current branch and resolved store path before relying on the document.
- Do not commit or stage the root symlink or external context file.

## Start or resume active context

1. For initial implicit activation, confirm both conditions:
   - The branch is fresh and intended for pull-request work. Infer this from the user's request, branch creation context, or the absence of established branch work; do not assume every non-default branch is fresh.
   - A Linear issue identifier or link appears in the request or available work context.
2. If either initial condition is absent, leave an empty branch file inactive. Explicit invocation overrides this gate.
3. Gather the Linear issue's goal, requirements, constraints, discussion, and acceptance criteria through any available issue integration. If the issue cannot be accessed, record only available context and mark gaps rather than guessing.
4. Locate [`assets/PR.md`](assets/PR.md) relative to this `SKILL.md`. Populate its complete structure, then write it through the managed root symlink to the current branch's external file. Preserve the asset as the reusable template.
5. Replace prompts with concrete content. Use `None yet` where an empty section would be ambiguous. Preserve the `<!-- pr-context: active -->` marker.
6. If active context already exists, confirm its branch metadata matches and continue from it instead of recreating it. Reconcile mismatches before editing.

Keep every template section. `Current state` holds goal and scope, constraints and prior context, product decisions, technical decisions, implemented approach and work items, accepted deviations and deferrals, and QA expectations and results. `History` holds the append-only dated iteration log.

## Maintain it during implementation

- Update scope before implementing an agreed expansion or reduction.
- Record a product decision when behavior, user experience, compatibility, or acceptance criteria are chosen.
- Record a technical decision when architecture, data shape, dependencies, migration, rollout, security, or operational behavior is chosen.
- When an iteration changes direction — an approach is replaced, a review finding is resolved, scope shifts — make both updates together: rewrite the affected `Current state` sections to the new present-tense truth, and append a dated `History` entry explaining what changed and why.
- Keep work-item checkboxes aligned with reality. Update the implemented approach after the code departs materially from the initial plan.
- Record known defects and deferrals with impact, rationale, and a concrete follow-up or explicit statement that none is planned.
- Add validation commands and QA scenarios before or while implementing. After running them, preserve the expectation and record the exact observed result, including failures or skipped checks.
- When the user changes direction, treat the user instruction as authoritative and update `PR.md` immediately so stale guidance does not remain the source of truth.
- Before handing work off, committing, or drafting the PR, reconcile the document against the current diff, working-tree status, and actual validation evidence.

## Draft the pull request description

When asked to draft or create the pull request:

1. Refresh active `PR.md` from the implemented diff and latest validation results.
2. Draft from the `Current state` half: goal, scope, implemented approach, reviewer-relevant product and technical decisions, accepted limitations or follow-ups, and exact QA evidence.
3. Link the Linear issue when a link is available.
4. Omit `History` and other internal process detail unless a specific entry materially helps review the chosen implementation.
5. Confirm neither the root `PR.md` symlink nor its external target is staged or included in the pull-request diff.

Retain each branch file while its branch work, review, or QA follow-up remains active. Remove it only during confirmed PR cleanup or when the user explicitly asks.
