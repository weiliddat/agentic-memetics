---
name: thermos
description: Launch both thermo-nuclear review subagents in parallel, then synthesize their findings. Use only when the user explicitly asks for thermos, a double thermo review, or a combined bug/security and code-quality branch audit. Do not invoke it as a follow-up to unrelated work.
---

# Thermos

Run the two thermo review passes as subagents in parallel, then synthesize their results.

## Workflow

1. Determine the review scope from the user request, PR, current branch, or relevant changed files.
2. Gather the diff and any file/context excerpts needed for reviewers to evaluate the change without guessing.
3. Read [references/subagent-assignments.md](references/subagent-assignments.md) completely, then launch both assignments concurrently with the host harness's subagent or worker mechanism:
   - A subagent using `thermo-nuclear-review` for bugs, breakages, security, devex regressions, feature-flag leaks, and other branch-audit risks.
   - A subagent using `thermo-nuclear-code-quality-review` for maintainability, structure, file-size growth, spaghetti, abstractions, and codebase-health risks.
4. Pass each subagent the same scoped diff/file context, its assignment text, and the resolved file path to its rubric, then ask it to return prioritized findings with file references and evidence.
5. After both finish, synthesize the results with findings first, deduplicated across reviewers. Weight overlapping findings more heavily, resolve disagreements with your own judgment, and keep summaries brief. Cite code using [code-reference-formatting](../code-reference-formatting/SKILL.md).

If the harness already surfaced the individual reviewer summaries to the user, do not restate them wholesale. Surface the unified verdict, the highest-signal findings, and any remaining uncertainty.

### Fallback without subagents

If the harness cannot run subagents, run the two passes sequentially in the main context, keeping separate notes per pass: `thermo-nuclear-review` first, then `thermo-nuclear-code-quality-review`. Complete each pass before starting the next so they stay meaningfully independent, then synthesize.
