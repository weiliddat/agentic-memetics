---
name: critique
description: Evaluate work, code or otherwise, against its intent, effectiveness, execution, and design tradeoffs, explaining the judgment through a critical walkthrough. Use only when the user explicitly requests critique by name.
---

# Critique

Help the reader understand and judge the work: **what was it trying to achieve, did it succeed, and was it worth it?** Defect detection belongs inside that evaluation, not as its organizing principle.

The work can be code, a design, prose, a UI, tests, or a plan. This guidance is written for software; adapt its terms for other kinds of work.

The reader may not know every aspect of the scope, design, constraints, or decisions, especially when agents have done substantial independent work. Reconstruct enough of that context to make your judgment intelligible. Do not assume the original request, current description, implementation, and reader's mental model still agree.

## Questions that guide the critique

**What was it trying to achieve?** Establish the problem, desired outcomes, constraints, and principles behind the work. Distinguish explicitly stated intent, intent inferred from the work, and observed behavior. Consider how decisions evolved and whether the resulting design still serves the goal. Do not invent a rationale that makes the implementation seem inevitable, or call a tradeoff accepted without evidence that it was accepted. If the intent stays vague or takes a complicated account to connect the changes, investigate why. Distinguish missing context and several justified goals from work that does not fit together; where it fails to fit, say so and what that costs.

**Did it succeed?** Understand how the design produces its effects and whether actual behavior fulfills the intended outcomes. Look beyond local plausibility to relevant interactions, existing uses, and consequences. Examine whether the mental model is coherent and consistently applied: does it predict what the implementation does, or do different paths rely on incompatible assumptions? Judge the execution, not only the result. Good execution does the job with no more than it needs: less code rather than more, direct rather than convoluted, every part doing something. Single-use abstractions, indirection that only forwards, guards against states that cannot occur, and duplicated logic that must be kept in sync are execution flaws even when the behavior is correct. Judge this against the problem and the conventions of the surrounding work, not your own preferences. Bugs, omissions, surprising behavior, and incomplete consideration matter insofar as they undermine the work. Your initial difficulty understanding it is a reason to investigate, not by itself evidence of a design flaw.

**Was it worth it?** Evaluate the goal as well as the execution. Is this the right problem to solve, and are the benefits worth the complexity, operational risk, and current and future effort required to understand, maintain, and scale the result? Include the form of the work in that cost. Simple, concise code is cheaper to understand and maintain than long, convoluted, or redundant code, and every future reader pays that cost again. Prefer less over more when both serve the intent. Count form that makes the work harder to understand; do not count matters of taste. Consider the constraints under which the work was done, not an imaginary unconstrained ideal. Look for substantially simpler ways to achieve the intent, including doing less or leaving the system alone. Explain what an alternative gains and gives up; a different design is not automatically a better one.

These questions shape the reasoning; they are not a checklist to exhaust. The reporting structure is defined below.

## Ground the judgment

Establish the work and comparison being evaluated. Use available requests, decision records, relevant code, and observed or tested behavior to reconstruct its context. Resolve accessible factual questions rather than passing unfinished investigation to the reader; distinguish demonstrated behavior from inference and material uncertainty.

Search broadly for defects introduced or exposed by the changes, not just those that fit the emerging narrative or stated goal. Account for the full change set. Trace affected behavior upstream to callers, inputs, and assumptions, and downstream through consumers, state changes, and externally observable effects, including unchanged code. Compare old and new behavior and examine relevant alternative and failure paths until the affected contracts and consequences are established. Use focused checks or reproductions where useful; do not equate a clean test run with complete coverage or claim that every possible issue has been excluded.

Actively seek evidence against your emerging account. A coherent explanation can conceal a mistaken premise or implementation. For substantial changes, an independently assigned correctness review can run alongside the contextual critique using the host harness's available delegation mechanism. Give it the comparison, intent, and affected scope, and ask for evidence-backed defects, upstream/downstream impact, and coverage limits—not another final critique. Independently validate and contextualize its findings rather than accepting its labels or assuming every downside is a mistake. For small changes or when delegation is unavailable, perform that scrutiny yourself. No particular review skill, tool, reviewer count, or orchestration is required.

Keep distinct the concerns that call for different responses:

- **Mistake or omission:** the implementation fails its intended contract; identify what needs fixing.
- **Design limitation or missed consideration:** the consequence follows from the model or decision itself; explain whether changing the design is warranted.
- **Deliberate tradeoff:** establish its rationale and assess whether the line drawn is reasonable and consistently honored. A downside alone does not make it a defect.
- **Unresolved intent or evidence:** explain what remains unknown and which judgment depends on it, without turning uncertainty into a confirmed finding.

Use these distinctions to clarify the discussion, not to manufacture four lists. Recognize successful decisions when explaining why they are worth retaining; do not manufacture criticism or add praise for balance. Keep unrelated pre-existing defects and speculative improvements out of scope.

## Write for understanding and decisions

Organize the report as a critical walkthrough of the work's goals, decisions, and behavior, not as a list of findings. Use this spine and shape the rest as the work requires:

1. **Intent.** State what the work was trying to achieve: the explicit request, the intent inferred from the work, and any gap between them. Name the constraints that mattered. Keep it brief; surface any established incoherence or material uncertainty in the verdict rather than extending the opening.
2. **Verdict.** Say whether it succeeds and whether it is worth it, and what that judgment hinges on. Name any blocker here; narrative order must not hide it.
3. **Walkthrough.** Take the reader from intent to implementation to consequences. Name sections after the decisions or behaviors being judged. Show relevant entry points and connections, explain the mental model, and place tradeoffs, design concerns, questions of form, and concrete mistakes beside the paths or decisions they concern. Mark each concern by kind (mistake, design limitation, tradeoff, unresolved) where the kind is not obvious. Explain each finding once, here. Confirmed defects that do not fit the story go in a brief group where they are easiest to understand.
4. **Actions.** Close with what needs fixing, what the reader must decide, and what remains unverified. One line per item, pointing back to the walkthrough. This is an index, not a second explanation and not a ranked issue inventory.

Do not add a separate style section; raise a form finding where it matters, and only if it costs the reader something.

Optimize signal by validating, contextualizing, and deduplicating findings, not by omitting confirmed actionable defects that do not fit the main story. An accepted tradeoff does not excuse an implementation that fails the chosen contract.

Use the harness's native file-and-line-range links and code snippets to ground the critique in relevant code. Include snippets or diagrams when they reduce the reader's effort, not as decoration or a requirement for every finding.

Scale the investigation and explanation to semantic impact, uncertainty, and the reader's needs, not lines changed. A small decision with broad downstream effects may warrant a deep account; a large mechanical change may need only a concise explanation and convincing preservation evidence. Compress uncontroversial details and spend attention on consequential choices. State material verification limits without dumping an investigation log. Beyond the spine, no fixed length or sections are required.

Critique the work; do not implement fixes, post external comments, or approve or ship changes unless the user separately asks.
