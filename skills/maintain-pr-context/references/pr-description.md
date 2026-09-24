# Draft the pull request description

When asked to draft or create the pull request:

1. Reconcile active `PR.md` with the implemented diff and latest validation results. Refresh it when context updates are authorized; otherwise keep corrections in the response.
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
6. Remove references to information or process the reviewer cannot inspect, including `PR.md`, separate PR context, agent activity, internal review passes, and how the description was assembled. Preserve any useful finding by stating the underlying fact, risk, decision, or fix directly. For example, replace “an internal review found an unsafe fallback” with an explanation of the unsafe fallback and how this change handles it.
7. Link the Linear issue when a link is available. Identify other context by a reviewer-visible name and link when it is necessary to understand the change; otherwise summarize the relevant point in the description.
8. Keep validation reproducible and candid, but do not restate what the platform already reports: omit pass counts, timings, and per-suite results for checks that run in CI. Describe manual and product QA the reviewer would otherwise have to guess at, and state failures, known-flaky areas, or skipped coverage explicitly, since a green build does not reveal them. Do not imply that the reviewer needs access to private tooling.
9. Read the result once from the reviewer's perspective. Remove self-referential process language, unexplained internal shorthand, claims without visible evidence, and implementation detail that does not help assess the change.
10. Confirm neither the root `PR.md` symlink nor its external target is staged or included in the pull-request diff.

