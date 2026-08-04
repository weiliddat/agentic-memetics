---
name: deep-thermos
description: Run the combined deep-code-review pipeline plus both thermo-nuclear whole-diff passes in one parallel wave, then synthesize a single deduplicated report. Use only when the user explicitly asks for deep-thermos or the combined deep review and thermos audit.
---

# Deep Thermos

Composed review: deep-code-review's territory pipeline (orient → group → per-group deep dives) plus the two thermo-nuclear whole-diff lens reviews, merged into one synthesized report.

This skill references its component skills instead of restating them. It contains only the orchestration delta and the synthesis rules. If a referenced component cannot be found, stop and tell the user; do not improvise a replacement rubric.

## Components

All components are sibling directories of this skill (resolve paths relative to this skill's parent directory; this works both in-repo and under a linked skills root such as `~/.agents/skills`):

- `deep-code-review/SKILL.md` — read and execute this yourself; you are its orchestrator.
- `thermo-nuclear-review/SKILL.md` — assigned to a subagent by file path.
- `thermo-nuclear-code-quality-review/SKILL.md` — assigned to a subagent by file path.

Do not load the `thermos` skill. Deep-thermos replaces its orchestration; loading both would give you two competing plans.

## Procedure

Read `deep-code-review/SKILL.md` in full and execute it with exactly these replacements:

1. **Phases 1–3 run as written**, including the rename sweep and type/shape-change inventory in Phase 1 and the grouping table in Phase 2.
2. **Phase 3's parallel wave gains two extra reviewers.** Launch the two thermo lens subagents in the same message as the per-group subagents so everything runs concurrently.
3. **Phase 4 is replaced** by the Synthesis section below. Do not emit deep-code-review's Phase 4 report separately.

### The two thermo lens assignments

Give each thermo subagent:

- the repository path, base and head identifiers, and any user intent or acceptance criteria
- the Phase 1 orientation output: PR purpose, renamed identifiers (old → new), type/shape changes, and any out-of-diff files that still reference old names
- the instruction to read and apply its rubric from the file path:
  - Reviewer A: `thermo-nuclear-review/SKILL.md` (correctness, security, breakage, devex, feature-gate leaks)
  - Reviewer B: `thermo-nuclear-code-quality-review/SKILL.md` (structural simplification, abstractions, boundaries, spaghetti growth)
- the instruction to return prioritized findings with code evidence, the concrete failure or maintenance scenario, and confidence

Reference rubrics by file path, not by skill name — a plain file read works in every harness, whereas skill-name resolution does not, and the component skills are gated to explicit invocation so a name-based load may not fire.

Each reviewer must complete independently: do not show any reviewer another reviewer's output, and do not read PR/MR discussion during orientation — Reviewer A's rubric handles that itself, after its own audit.

### Fallback without subagents

If the harness cannot run subagents, execute sequentially with separate notes per pass: the per-group reviews first, then Reviewer A's rubric, then Reviewer B's. Complete each pass before consulting the next so they stay meaningfully independent, then synthesize.

## Synthesis (replaces deep-code-review Phase 4)

Collect all findings from the per-group subagents and both thermo reviewers, then:

1. **Dedupe by file:line before writing anything.** Merge findings that describe the same defect in different vocabularies; keep the clearest statement and note corroboration.
2. **Verify high-impact findings against the repository** before presenting them. Resolve disagreements between reviewers with direct code evidence; preserve material uncertainty instead of forcing consensus.
3. **Treat independent overlap as corroborating evidence, not severity inflation.** A finding is Critical because of its impact, not because three reviewers noticed it.
4. **Use deep-code-review's severity taxonomy as canonical** (Critical / Nitpick / Clarification Needed). Map thermo-quality presumptive blockers to `Critical | Structural`. Map thermo correctness findings by their own calibrated severity.
5. **Report using deep-code-review's Phase 4 structure.** Fold thermo correctness findings into Issues Found; fold thermo structural findings into Issues Found and the Holistic Evaluation's structural/design concerns. Attribute a finding's source lens only when it aids triage.
6. **Prefer a small number of high-conviction findings over cosmetic nits** at the report level, not just per reviewer. If structural Criticals exist, cut cosmetic nits rather than appending them.
7. State explicitly when no qualifying findings remain in a category.

Do not implement fixes unless the user also asks for changes.
