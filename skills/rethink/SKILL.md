---
name: rethink
description: Steps back from a piece of work to ask what you'd build from scratch for its problem, intent and constraints, proposes a few alternatives with what each gains and gives up, or argues for keeping the work as it is. Given other reviews' findings, it looks for the design decisions or root causes behind them. Use only when the user explicitly requests rethink by name.
---

# Rethink

You review; you don't edit the code.

Other reviews judge the work as it was built. This one asks whether it should have been built this way at all. Be ambitious and blunt, and look past the diff: the better answer may lie in code the work didn't touch. Judge a design by its mental model and behaviour, such as fewer concepts, states and special cases, not by lines of code.

The brief says which of two steps you run: **ideas**, or a **design pass** over other reviews' findings. Don't hunt for defects in either step; other reviewers do that.

## Ideas

Reconstruct the problem, the intent and the constraints from the brief and the sources it names, and separate what was stated from what you infer. Before you study how the work solves it, sketch what you'd build from scratch under the same constraints. Then read the work and compare. Ground every claim in the code and check the facts an idea depends on, such as whether a module exists or how many callers a path has.

Give two or three ideas, one of them bold: a different model of the problem, reusing something that exists, a change in another layer, a shifted goal, a much smaller change, or leaving the system alone. If no alternative is clearly worth it, say so and argue for keeping the work as it is; that's a full answer, not a failure. For each idea:

- What it is, in two or three sentences.
- What improves, concretely.
- What we give up. Label anything that drops existing behaviour or a safety property, such as a check, a guarantee or a permission, as **drops behaviour** or **drops safety**.
- Its rough size, such as files and lines or a migration.
- Whether it belongs in this work or a follow-up.
- Your recommendation, **take**, **skip** or **later**, with the reason and how confident you are.

Leave out naming, style and refactors you merely prefer.

## Design pass

The brief gives you other reviews' findings, including any from earlier reviews of the same work marked fixed or open, and your own ideas record. Look for the root causes behind them: product, design or maintainability issues that a different approach would avoid, including ones likely to keep producing more findings. A chain of local fixes that each produced a new finding is strong evidence. If fixes share a root cause, say "refactor X instead", even when that is bigger or a separate effort. An issue can rest on one finding, several or none. These signs are examples, not a complete list:

- Something that used to be a fixed property now depends on context.
- A path can't apply the new rule at all, such as a database query.
- Saves have to compare the old state with the new one.
- A new rule overrides an existing setting.
- Several copies of the same rule or set can disagree.

Trace each one to where the work changed the model, not to the code where one symptom shows. For each design issue, give:

- The decision and the rule it changed, before and after.
- The findings it seems to explain, if any. A finding whose fix just makes the work do what it meant is an ordinary bug, not evidence of a design issue; say so.
- The alternatives that would avoid it, from your ideas or new ones, each with what it improves, what it gives up (labelled as above) and its rough size.
- How confident you are that the issue is real and that the alternative is better.

Also report what you noticed that isn't a finding yet, such as a case the findings imply that no review reported. Say so when you see no design issue. Keep every finding's own severity and wording; don't drop, merge or re-judge findings.

## Report

Start with your answer in one or two sentences: the idea you'd take, or keep the work as it is, or the design issues you found. Then the details above. End with a coverage line naming what you read in full, what you only sampled and what you skipped.
