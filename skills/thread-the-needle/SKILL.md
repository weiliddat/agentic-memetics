---
name: thread-the-needle
description: Design-time exploration for finding an elegant solution — generate genuinely distinct framings of the problem, name the tradeoff axes, pick deliberately, and present the alternatives. Use only when the user explicitly asks for thread-the-needle or to thread the needle on a design, or when an orchestration assigns this workflow. Do not invoke it as a follow-up to unrelated work. If a planning mode is already active, run this as the content of that plan, not in addition to it.
---

# Thread the Needle

Find the solution that makes the change feel inevitable in hindsight — the right abstraction, the right boundary, the right tradeoff — rather than the solution that falls out of momentum, habit, or the first pattern that matches.

This is the design-time counterpart to a strict quality review. A reviewer can only ask "is there a code-judo move that would make this dramatically simpler?" after the complexity exists. This skill asks that question **before** any code is written, when the answer is cheapest to act on.

## When This Skill Earns Its Keep

The existing codebase exerts gravity: canonical helpers, established layers, familiar patterns. Most of the time that gravity is correct — follow it. This skill is for the cases where it is not:

- The obvious pattern-following implementation would add a mode, flag, branch, or special case to an already busy flow.
- Two or more plausible designs exist and they disagree on where a boundary or ownership should live.
- The feature feels awkward to express in the current model — a sign the model, not the feature, may need to change.
- The straightforward path works but leaves the codebase with more concepts to hold in one's head than before.
- The requirements are in tension (flexibility vs. simplicity, generality vs. directness, now vs. later) and the tension has not been named.

If invoked on a trivial or mechanical change where one reasonable design exists, say so and give the direct answer — forcing framings onto a one-liner is theater.

## Workflow

### 1. Understand the real problem

Before generating anything, establish:

- **The actual requirement**, stated independently of any implementation. Strip the request down to the behavior or capability that must exist. Often the request arrives pre-framed ("add a flag to X") — recover the underlying need first.
- **Whether the design is already decided.** A request phrased in implementation terms is a framing to see through; a design the user explicitly chose is a hard constraint. Do not run the full exploration to relitigate an explicit decision — at most note, in a sentence or two, a materially simpler alternative if one is obvious, and proceed with the mandated design unless told otherwise.
- **Hard constraints vs. soft preferences.** What is genuinely fixed (external contracts, data shapes, compatibility, deadlines) versus what is merely current (an internal structure that could change if changing it is the better move)?
- **The existing terrain.** Read the code that the change will touch and the code that owns the relevant concepts. Note the canonical patterns, the current invariants, and where complexity already concentrates. You cannot judge whether to follow the patterns until you know what they are.

### 2. Generate genuinely distinct framings

Produce **at least three framings** of the solution. A framing is not a variation in naming or file placement — it is a different answer to at least one of these questions:

- What is the core abstraction or model? What concept, if it existed, would make this feature a natural consequence?
- Where does the ownership boundary sit? Which layer, module, or component is responsible for the new behavior?
- What is the shape of the data or state? Could a different state model make whole categories of branching disappear?
- What is generalized and what is kept concrete and boring?

To force genuine diversity, deliberately include:

- **The pattern-following framing.** The solution that the existing codebase most naturally suggests. It is the baseline every alternative must beat — and often it wins.
- **The reframed problem.** At least one framing that changes the model, boundary, or state shape so the feature becomes a natural extension of the architecture rather than an addition bolted onto it. Ask: is there a code-judo move here — a re-organization that uses what already exists more effectively and makes the change dramatically simpler?
- **The subtractive framing.** At least consider: can the requirement be met by deleting or unifying something rather than adding? Can an existing mechanism absorb this behavior with a small generalization? The best solution sometimes removes more code than it adds.

If two framings would produce nearly the same code, they are one framing — go find a genuinely different one. If you cannot find three genuinely distinct framings, say so explicitly and explain why the design space is narrow; do not pad the list with strawmen.

#### Explore in parallel when subagents are available

A single context that generates framing A first will unconsciously shape framings B and C around it — instructions to "be diverse" do not prevent this. Independence does. If the host harness provides a subagent or worker mechanism, run this step as an orchestrator. (A *thread* is a direction to explore; a *framing* is what an explored thread produces.)

Reserve the fan-out for questions where the candidate framings would each require reading substantial, different parts of the code. When the design question is real but small, use the single-context protocol below instead — it is the small-question mode, not only a fallback.

1. **Write a shared problem brief** from step 1: the implementation-independent requirement, hard constraints, and terrain notes (relevant files, current invariants, canonical patterns, where complexity already concentrates). Every explorer receives the same brief. **Brief hygiene**: the brief describes the problem and the terrain — it must not name, sketch, or allude to any candidate solution. Before sending it, reread it and delete anything that only makes sense if a particular design is assumed.
2. **Spawn one explorer per thread**, each with the brief plus a distinct exploration seed, and **no visibility into the other explorers**. Explorers read code and report; they must not modify files. Seed the mandatory threads first — pattern-following, reframe-the-model, subtractive — then add threads for any specific tension the terrain revealed. A seed is a direction to push in, not a design to validate: phrase it as territory ("explore the design space where layer Y, not X, owns this behavior"), never as a sketch of an answer. Tell each explorer to develop the strongest version of its thread, read the code it would touch, and report honestly if the thread dead-ends. Two economies: if the subtractive thread is clearly empty, the orchestrator may answer it inline in a sentence ("nothing to subtract because X") instead of spending an explorer on it; and if the orchestrator notices it already prefers a design after step 1, that design **must become an explicit seed** and compete as one thread among several — a favorite kept out of the arena operates as a silent prior at evaluation time.
3. **Require a compact, uniform return shape** so results are comparable: the framing (core abstraction, boundary, data/state shape), what it adds and what it deletes, evidence from the code, its weakest point, and any discovered constraint the brief missed. Each field a few sentences plus file references — a return is a comparison input, not a design document.
4. **Steer between rounds** — at most one steering round in the usual case, two at the outside. After collecting results:
   - **Deduplicate**: two framings are the same framing if they give the same answer to all four framing questions above (abstraction, boundary, state shape, generalization) — differences in naming, file placement, or presentation don't count. Merge duplicates; convergence is signal that the design space is narrower there, not two votes for the idea.
   - **Propagate discoveries**: if one explorer surfaced a constraint or a piece of terrain the others didn't know, that invalidates the comparison — spawn replacements for the affected threads with the updated brief (or re-brief the running thread, where the harness supports continuing a worker).
   - **Fill gaps**: if all returned framings cluster on one side of a tradeoff axis, spawn a new explorer seeded from the unexplored side.
   - **Stop when marginal**: stop when a new round would only produce variations of existing framings.

The orchestrator does not explore a thread of its own — its judgment is reserved for steps 3–5.

#### Single-context protocol (fallback, and small questions)

When subagents are unavailable, or the question does not warrant a fan-out: sketch **all** framings at one or two paragraphs each *before* elaborating any of them; develop the reframed and subtractive threads before fleshing out the pattern-following one (the pattern-following framing anchors hardest because the codebase keeps suggesting it); and only then deepen the candidates. Treat your first idea as the one most in need of a genuine rival. This mitigates anchoring but does not eliminate it — note in the output that the framings were generated in a single context, so the reader can weight the alternatives accordingly.

### 3. Name the tradeoff axes

Before comparing framings, state the axes on which they actually differ. Common axes — use the ones that apply, discard the rest:

- **Concept count**: how many new ideas must a reader hold to understand the result?
- **Blast radius**: how much existing code changes, and how risky is that change?
- **Branching pressure**: does the design remove conditionals, or centralize them, or scatter them?
- **Boundary cleanliness**: are the resulting contracts explicit and typed, or do they lean on optionality, casts, and silent fallbacks?
- **Reversibility**: how hard is this to undo or evolve if the requirement shifts?
- **Generality debt**: does the design speculate about future needs, and what does that speculation cost today?
- **Effort and risk now** vs. **maintenance cost later**.

An honest comparison names where each framing is *worse*, not just where it shines. If one framing dominates on every axis, the comparison is suspect — either the alternatives are strawmen, or you have not yet found the axis on which the winner actually pays.

### 4. Evaluate and pick

For each framing, state the one or two axes where it wins and the one or two where it loses — no numeric scoring or checkmark matrices, which only decorate a decision already made. Then pick one and commit to it. The taste criteria, in priority order:

1. **Inevitable in hindsight.** The winning design should make the change feel like a natural consequence of the architecture — as if the codebase was always shaped to receive it.
2. **Deletes complexity rather than rearranging it.** Prefer the framing that removes moving pieces — branches, modes, layers, wrappers — over one that merely relocates them. A merely cleaner version of the same messy idea loses to a genuinely simpler idea.
3. **Direct and boring over clever and magical.** Generic mechanisms that hide simple data-shape assumptions, thin wrappers, and speculative indirection are costs, not features. Cleverness must pay for itself in deleted complexity, or it is a liability.
4. **Right logic in the right layer.** The design should place behavior where the concept already lives, with explicit typed boundaries — unless moving the boundary *is* the winning move, in which case move it deliberately and say so.
5. **Proportionate ambition.** Be ambitious when there is a clear path to a dramatically simpler implementation, even if it means restructuring some of the existing code. Be restrained when the restructuring is speculative. Measure twice, cut once.

The reframed or subtractive framing does not win by default — elegance that costs a large risky refactor for a small feature is the wrong tradeoff. But when a code-judo move is visible and affordable, take it; do not default to the pattern-following framing out of inertia.

### 5. Present the decision — with the alternatives

Deliver the design as a decision, not a menu. The reader should see what you chose, why it wins, and what it cost — and should be able to overrule you cheaply because the alternatives are already articulated.

Output shape:

```
## Problem
<the requirement, stated implementation-independently; hard constraints listed>

## Recommended: <framing name>
<the design in enough detail to implement: core abstraction, boundary,
data/state shape, what changes, what gets deleted>

Why it wins: <the decisive axes>
What it costs: <the axes where it loses, stated honestly>

## Alternatives considered

### <framing B name>
<two or three sentences: the core idea and its shape>
Rejected because: <the specific tradeoff that lost, not a strawman dismissal>
Would have won if: <the concrete condition under which this becomes the better pick>

### <framing C name>
...

## Tension that remains
<any tradeoff the recommendation does not resolve, decisions deferred,
or conditions under which an alternative becomes the better pick>
```

Keep the alternatives sections short but real. The `Would have won if:` line is the strawman detector: if you cannot fill it with a concrete condition, the alternative was never a real contender — go back and find one that is, or say the design space is narrow.

### 6. After the decision

- If the request was a design question, stop here — the decision document is the deliverable.
- If the request was to implement, present the decision, then proceed with the recommended framing. Pause for confirmation first only if the recommendation restructures existing code beyond the obvious scope of the request, or contradicts something the user said.
- Carry **What it costs** and **Tension that remains** forward into the change description (commit message, PR description, or equivalent), so a later reviewer can see the tradeoff was deliberate rather than accidental.

## Anti-Patterns

- **First-idea anchoring**: generating one design, then two decorative variants of it. The alternatives must be able to win.
- **Cross-pollinated explorers**: showing one explorer another's framing "for context", or the orchestrator hinting at its favorite in a seed. Independence is the entire point of fanning out; steering happens between rounds, not inside them.
- **Strawman alternatives**: framings constructed to lose so the predetermined pick looks considered.
- **Pattern gravity as a verdict**: rejecting a reframing solely because "that's not how this codebase does it." Consistency is an axis, not a trump card.
- **Elegance maximalism**: picking the most intellectually satisfying design when the boring one is cheaper, safer, and good enough. Elegance is measured in deleted complexity, not in abstraction ceremony.
- **Analysis without a pick**: presenting a balanced menu and making the reader decide. Threading the needle means committing, with the reasoning shown.
- **Skipping the terrain**: proposing framings before reading the code they would touch. A framing that ignores an existing invariant or duplicates a canonical helper is not a framing, it is a guess.
