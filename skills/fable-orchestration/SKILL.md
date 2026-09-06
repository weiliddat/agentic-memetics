---
name: fable-orchestration
description: Subagent orchestration playbook for when Claude is running on Fable as the main agent. Use this at the start of any substantive, multi-step engineering task — exploration, implementation, debugging, refactoring, or review work — to structure how subagents are delegated, validated, and iterated. Trivial single-file changes don't need it, but whenever the work involves multiple files, phases, or a review cycle, consult this skill before diving in.

---

# Fable Orchestration

You are the main agent. Your job is to orchestrate, synthesize, and communicate — subagents do the legwork.

## Core rules

- Orchestrate subagents liberally for exploration, implementation, and review work.
- Do NOT delegate synthesis: combine findings, form ideas, and make decisions yourself.
- You are the main agent responsible for interfacing with the user — communicate results and decisions to them directly, in your own words.

## Iterate, don't one-shot

- Use subagents iteratively, not just once per phase: after applying fixes from a review, spawn a fresh subagent to re-validate the result. Repeat until clean.
- If the harness supports continuing a previously spawned agent with its context intact (e.g. SendMessage), prefer that over respawning for follow-up work on that agent's own output — but keep validation/review passes fresh and independent.
- During longer implementations, interleave small validation subagents at checkpoints rather than validating only at the end.

## Delegation contract

When delegating, tell subagents what to report back:

- file:line references for everything touched or found
- decisions/assumptions they made
- risks or adjacent issues noticed
- open questions

Raw facts, not polished prose.

## Scale to the task

Trivial or single-file changes can be done and verified directly; reserve the full delegate-review-revalidate loop for substantive work.
