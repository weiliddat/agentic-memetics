---
name: maintain-pr-context
description: Maintain a populated branch-specific PR.md as the living source of truth for pull-request work, covering scope, prior considerations, product and technical decisions, implementation state, deferrals, and QA. Use when either (1) beginning PR-bound work on a fresh branch and the request or available context mentions or links a Linear issue—both conditions are required for initial implicit activation—or (2) the current managed PR.md contains active PR working context. Also use when explicitly asked to initialize, refresh, or turn PR.md into a PR description. Treat an empty managed file or inactive default-branch/detached notice as no active context.
---

# Maintain PR Context

Keep the current branch's shared `PR.md` as a concise working brief. Make it useful to implementers now and to reviewers and QA later. Keep its repository-root symlink and external target out of the pull request unless the user or repository explicitly requires otherwise.

## Resolve the current branch document

1. Find the repository root, current branch or detached state, working-tree status, and root `PR.md` file type, target, tracking, and ignore state.
2. Expect `PR.md` to be a managed symlink to the current branch's file in the shared external store. Verify the resolved target rather than trusting the root pathname alone. Some harnesses' file read or write tools refuse symlink paths; when the root `PR.md` path fails, resolve it (e.g. `realpath PR.md`) and operate on the resolved target path directly. Never replace the symlink with a regular file because a read or write to the link path failed.
3. If setup is absent, broken, or points at another branch, read [`../setup-pr-context/SKILL.md`](../setup-pr-context/SKILL.md) in full and follow its inspect or repair workflow. Do not overwrite a regular file, tracked file, unmanaged symlink, or another branch's context.
4. Read the resolved file in full before planning or changing code when it contains `<!-- pr-context: active -->` or otherwise clearly contains active PR working context.
5. Treat a zero-byte file and `<!-- pr-context: inactive -->` notice as no active context. Their existence alone must not activate this skill or expand task scope.
6. Do not initialize active context on the default branch or detached HEAD implicitly. Require an explicit user instruction.

## Apply the invariants

- Treat matching active context as the primary statement of work scope, decisions, plan, deferrals, and validation. Reconcile contradictions with the user, Linear issue, code, or test results instead of silently choosing one.
- Update the document after every material discovery, decision, scope change, implementation milestone, accepted defect or deferral, and validation result.
- Refresh `Last updated` whenever making a material update.
- Maintain the three top-level sections with different edit disciplines and in this order: `Current state`, `History`, then `Appendix`. `Current state` is rewritten in place: always the present-tense truth about the work as it stands, with no iteration narrative, "previously", or "changed X to Y". `History` is append-only in substance: add dated entries immediately before `Appendix` and do not change their meaning retroactively; the only exception is the lossless compaction rule below. Keep it focused on meaningful PR evolution: decisions, scope or direction changes, rejected approaches whose rationale still matters, and significant findings and resolutions. Do not append routine chores such as branch updates, merges or rebases to or from the default branch, conflict-free synchronizations, formatting-only passes, or other repository housekeeping. Record such an event only when it materially changes the PR's scope, design, behavior, risks, or validation evidence; describe that consequence rather than the chore itself. `Appendix` holds supporting material whose size would obscure the working brief, such as large diagrams, figures, raw data, detailed tables, logs, or exhaustive analysis.
- Keep conclusions and findings in the relevant `Current state` or `History` entry. Move only the oversized supporting material to a clearly titled `Appendix` subsection and link to it from that summary. An appendix item must not be the sole record of a decision, finding, scope change, risk, or result.
- Do not duplicate content across sections. A decision lives in `Current state`; the `History` entry records when and why it changed, referencing it rather than restating it. `Appendix` preserves the supporting detail and is referenced rather than reproduced elsewhere. When sections disagree, `Current state` is authoritative — fix the divergence.
- Keep each appendix item aligned with the summary that links to it. Before rewriting a linked `Current state` summary, decide whether its conclusion or evidence remains meaningful PR history. If it does, append a concise `History` entry with the link and preserve the appendix item's meaning; otherwise update or remove the now-uncited item. Add a new appendix item for later evidence instead of rewriting support cited by `History`.
- Distinguish context inherited from before this PR (prior attempts, Linear discussion, system constraints) from iteration within this PR. The former belongs in `Constraints and prior context`; the latter belongs in `History`.
- When `History` grows long, losslessly compact entries that later entries supersede into dated one-liners instead of deleting them. Preserve the original decision or event, its rationale when still relevant, and any appendix link needed to understand it.
- Separate facts, decisions, plans, expectations, and observed results. Never describe planned or unrun validation as completed.
- Verify that the recorded branch matches the current branch and resolved store path before relying on the document.
- Do not commit or stage the root symlink or external context file.

## Writing register

- `PR.md` is a technical working document. Write concisely and factually, without rhetoric or meta-discourse.
- Match each entry's length to what its content needs: cover the substance — the fact, the decision, the reason — but do not pad with filler, redundant summaries, restated section context, or boilerplate.
- State facts and decisions directly. Do not narrate ("we then explored…"), editorialize ("importantly", "it's worth noting"), signpost, or add transitions and framing sentences. Every entry should be independently understandable.
- Focus on answers and content, not style. Respect the reader's time and intellect. Don't point out turn-of-events like nuance, surprise, understanding to the reader. They will get it through the facts.

## Start or resume active context

1. For initial implicit activation, confirm both conditions:
   - The branch is fresh and intended for pull-request work. Infer this from the user's request, branch creation context, or the absence of established branch work; do not assume every non-default branch is fresh.
   - A Linear issue identifier or link appears in the request or available work context.
2. If either initial condition is absent, leave an empty branch file inactive. Explicit invocation overrides this gate.
3. Gather the Linear issue's goal, requirements, constraints, discussion, and acceptance criteria through any available issue integration. If the issue cannot be accessed, record only available context and mark gaps rather than guessing.
4. Locate [`assets/PR.md`](assets/PR.md) relative to this `SKILL.md`. Populate its complete structure, then write it to the current branch's external file that the managed root symlink resolves to — write to the resolved target path if the tooling refuses the symlink path. Preserve the asset as the reusable template.
5. Replace prompts with concrete content. Use `None yet` where an empty section would be ambiguous. Preserve the `<!-- pr-context: active -->` marker.
6. If active context already exists, confirm its branch metadata matches and continue from it instead of recreating it. Reconcile mismatches before editing.

Keep every template section and its order. Use `Current state` for the present truth, `History` for meaningful changes over time, and `Appendix` for oversized supporting material referenced by concise findings in one of those first two sections. Use `None yet` when the appendix has no content.

## Maintain it during implementation

- Update scope before implementing an agreed expansion or reduction.
- Record a product decision when behavior, user experience, compatibility, or acceptance criteria are chosen.
- Record a technical decision when architecture, data shape, dependencies, migration, rollout, security, or operational behavior is chosen.
- When an iteration changes direction — an approach is replaced, a review finding is resolved, scope shifts — make both updates together: rewrite the affected `Current state` sections to the new present-tense truth, and append a dated `History` entry explaining what changed and why.
- Keep work-item checkboxes aligned with reality. Update the implemented approach after the code departs materially from the initial plan.
- Record known defects and deferrals with impact, rationale, and a concrete follow-up or explicit statement that none is planned.
- Add validation commands and QA scenarios before or while implementing. After running them, preserve the expectation and record the exact observed result, including failures or skipped checks.
- When a diagram, figure, data set, log, table, or analysis becomes large enough to interrupt the working brief, summarize its relevant findings in `Current state` or the dated `History` entry, move the full material into a titled `Appendix` subsection, and add a direct Markdown link from the summary to that subsection. Keep the appendix after all `History` entries.
- When the user changes direction, treat the user instruction as authoritative and update `PR.md` immediately so stale guidance does not remain the source of truth.
- Before handing work off, committing, or drafting the PR, reconcile the document against the current diff, working-tree status, and actual validation evidence.

## Draft the pull request description

When asked to draft or create the pull request:

1. Refresh active `PR.md` from the implemented diff and latest validation results.
2. Write a standalone description for a reviewer who can see the pull request, its diff, linked issues, and checks, but none of the private working context or agent workflow that produced it. Every included detail should help them understand the change, evaluate a decision or risk, navigate the diff, or validate the behavior.
3. Draft from the present implementation and evidence, using `Current state` as source material rather than copying its structure or wording. Use `History` only to recover an explored alternative or rationale that remains relevant to understanding the final design. Consult linked `Appendix` material when its supporting detail is needed, but carry forward the relevant finding rather than the working document's internal appendix link.
4. Organize the description around the reviewer's questions, using only the sections the change needs:
   - What goal or user problem does this solve, and what is in scope?
   - What constraints or plausible approaches mattered, what was considered, and why was the chosen direction selected?
   - What behavior and implementation changed?
   - What tradeoffs, risks, limitations, or follow-ups should the reviewer know about?
   - How was it validated in ways the reviewer cannot see from CI — manual scenarios, environment-specific checks, and coverage deliberately left out?
   - Where should review begin, which files or flows deserve attention, and how can the reviewer manually exercise the change?
5. Explain decisions and rejected alternatives in plain domain and technical terms. Include exploration only when it clarifies the resulting design or a meaningful tradeoff; omit chronological iteration logs and dead ends that do not affect review.
6. Remove references to information or process the reviewer cannot inspect, including `PR.md`, separate PR context, agent activity, internal review passes such as deep thermos, and how the description was assembled. Preserve any useful finding by stating the underlying fact, risk, decision, or fix directly. For example, replace “deep thermos found an unsafe fallback” with an explanation of the unsafe fallback and how this change handles it.
7. Link the Linear issue when a link is available. Identify other context by a reviewer-visible name and link when it is necessary to understand the change; otherwise summarize the relevant point in the description.
8. Keep validation reproducible and candid, but do not restate what the platform already reports: omit pass counts, timings, and per-suite results for checks that run in CI. Describe manual and product QA the reviewer would otherwise have to guess at, and state failures, known-flaky areas, or skipped coverage explicitly, since a green build does not reveal them. Do not imply that the reviewer needs access to private tooling.
9. Read the result once from the reviewer's perspective. Remove self-referential process language, unexplained internal shorthand, claims without visible evidence, and implementation detail that does not help assess the change.
10. Confirm neither the root `PR.md` symlink nor its external target is staged or included in the pull-request diff.

Retain each branch file while its branch work, review, or QA follow-up remains active. Remove it only during confirmed PR cleanup or when the user explicitly asks.
