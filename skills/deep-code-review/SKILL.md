---
name: deep-code-review
description: Perform a deep, structured, multi-phase code review as a senior staff engineer. Covers PR context gathering (including Notion PEP lookup), semantic grouping of changes, parallel per-group subagent review across multiple quality criteria, and a final holistic PR evaluation. Use when asked to do a thorough or comprehensive code review, review a PR in depth, or review code changes critically.
---

# Deep Code Review

Four-phase structured review: orient → group → deep-dive → evaluate.

## Phase 1: Orient — Gather Context

Run these in parallel:

```bash
gh pr view          # title, description, author, labels, state
gh pr diff          # full unified diff
git diff master...HEAD --stat   # file change summary
git log master...HEAD --oneline # commit history
```

If `gh` is unavailable, fall back to `git diff master...HEAD`.

**Notion lookup**: If the PR title contains `[PEP-XXXXX]` (e.g. `[PEP-12345]`), search Notion via MCP for that PEP ID and read the linked page to understand requirements, acceptance criteria, and design decisions. Surface key points from the spec in Phase 4.

**If any identifiers were renamed**, immediately run a codebase-wide search for each old name before proceeding:

```bash
rg '\bOLD_NAME\b' -l
```

**Orientation output** (brief, internal — not final review):
- PR purpose and scope in 2–3 sentences
- Key Notion/spec insights if applicable
- Files changed (count + list)
- Renamed identifiers (if any): list every old name → new name pair
- Type/shape changes (if any): list every field whose type changed (e.g., scalar → array, optional → required, string → enum) with old and new types
- Files outside the diff that still reference old names (from the grep above) — these **must** be included in Phase 2 grouping and reviewed in Phase 3

---

## Phase 2: Group — Semantic Clustering

Look at the full file list from Phase 1. Group files into **semantic topics** based on:

1. PR title / description intent
2. Notion/spec acceptance criteria (if applicable)
3. The code itself (imports, function names, module paths)

Good group types (non-exhaustive — use judgment):
- **Feature logic** — new business rules, domain changes
- **API / handler layer** — new or modified endpoints
- **Data model / schema** — DB changes, validation schemas, migrations
- **UI / frontend** — component changes, store, routing
- **Infrastructure** — CI, Docker, env vars, AWS, indices, NATS topics
- **Tests** — test files, fixtures, factories
- **Shared utilities / constants** — reusable helpers, constants

**Output a grouping table** before Phase 3:

```
Group: <Name>
Purpose: <one line>
Files:
  - path/to/file.ts
  - path/to/other.ts

Group: <Name>
...
```

Verify every changed file appears in exactly one group. If a file is ambiguous, place it in the most relevant group and note it.

---

## Phase 3: Deep Review — Per-Group Subagents

Launch one subagent per group in parallel. Use the same model as the current agent for all subagents. Each subagent must:

1. **Read every file in the group** fully before forming opinions
2. **Look up related code** that is not in the PR but is referenced, called, or impacted by the changes (follow imports, base classes, shared utilities, DB queries, NATS consumers/producers)
3. **Re-evaluate files** if cross-file reading changes your understanding
4. **Rename coverage search** — if the main agent's orientation listed any renamed identifiers, run a codebase-wide search for each old name and check whether any files *outside the PR diff* still reference it:

```bash
# Replace \bOLD_NAME\b with each renamed identifier
rg '\bOLD_NAME\b'
```

For every match in a file not in the diff: read the file, assess whether the old name is now stale or broken, and report it as a **Critical | Missed coverage** issue. Do not assume the diff is complete.

> Files outside the diff are the most common source of silent regressions in rename PRs — aggregation pipelines, test fixtures, Vuex store mocks, and serializer references can all be left behind, passing CI while broken in production.

5. **Type/shape change validation** — if the orientation listed any type changes, verify for each:
   - **Validation breadth**: Does validation cover edge cases introduced by the new type? (e.g., scalar→array: duplicates, empty/invalid elements within the collection, max length; optional→required: all call sites handle the constraint)
   - **Consumer compatibility**: Do all downstream consumers (API handlers, UI components, aggregation pipelines, serializers) handle the new shape correctly?
   - **UI interaction fit**: If a UI control changed to match the new type (e.g., single→multi select), is the interaction pattern intuitive without hidden modifiers like Ctrl/Cmd+click?
   - **Test coverage for new paths**: Are there tests exercising the new validation rules and edge cases, not just the happy path?

For each file in the group, evaluate on all criteria:

### Review Criteria (apply to every file)

| Criterion | Questions to answer |
|---|---|
| **Intent & achievement** | What was the goal? Was it achieved cleanly? Any shortcuts? |
| **Code quality** | Is it readable, well-structured, idiomatic? Unnecessary complexity? |
| **Correctness & reliability** | Are there logic bugs, missing edge cases, race conditions, off-by-ones? |
| **Misuse potential** | Can a developer or user trigger unintended behavior? Are APIs/interfaces confusing? |
| **Risk** | What can go wrong in production? Data loss, silent failures, bad defaults? |
| **Alternatives** | Is there a simpler or more idiomatic approach that achieves the same goal? |
| **Test coverage** | Are tests present and meaningful? Do they cover failure paths and edge cases? |
| **Data mutations** | For migrations, backfills, jobs, or event handlers that modify persistent state: Is the operation idempotent (safe to re-run or retry on partially processed data)? Is there a reversal/rollback strategy, and does it preserve data faithfully or is it lossy? |
| **QA / manual testability** | How would a QA engineer or developer manually verify this change works? |

### Leapsome Standards (apply in every review)

- Strict typing — no `any`, no `as` assertions, no `Record<string, unknown>`
- Schema-based validation — avoid raw `JSON.parse`/`JSON.stringify`
- Constants over hard-coded strings; NATS constants for event names
- Functional over class-based code
- Prefer `for`/`for-of` over `reduce` for complex transformations
- No Vue watchers; Tailwind utilities only (no scoped custom styles)
- Centralized logging — no ad-hoc `console.log`
- Reuse existing utilities; avoid duplicating logic

### File Reference Format

When referencing files in subagent output, use Cursor-native clickable references:

- Use backticked file paths like `src/path/file.ts`
- If line-specific evidence matters, add a code citation block using Cursor's native format:

```text
```start:end:path/to/file.ts
code excerpt here
```
```

### Subagent Output Format

Each subagent returns findings in this structure:

```
## Group: <Name>

### Rename coverage
(Omit section if no identifiers were renamed.)
- OLD_NAME → NEW_NAME: searched codebase; [no remaining references outside diff | found in: file1, file2 — see issues below]

### <file-path>

**Intent**: <one sentence>

**Issues**:

[Critical | Missed coverage] <old identifier still used here — describe impact>
Location: `path/to/file.ts`
Evidence (if helpful):
```start:end:path/to/file.ts
relevant code excerpt
```
Impact: <why it matters>
Fix:
  <code suggestion>

[Critical | Bug] <description>
Location: `path/to/file.ts`
Evidence (if helpful):
```start:end:path/to/file.ts
relevant code excerpt
```
Impact: <why it matters>
Fix:
  <code suggestion>

[Nitpick | Style] <description>
Location: `path/to/file.ts`
Evidence (if helpful):
```start:end:path/to/file.ts
relevant code excerpt
```

[Clarification Needed] <question for author>
Location: `path/to/file.ts`
Evidence (if helpful):
```start:end:path/to/file.ts
relevant code excerpt
```

**Risks**: <bullet list>

**Alternatives**: <bullet list if any>

**Test coverage**: <assessment>

**QA steps**: <how to manually verify>
```

---

## Phase 4: Holistic PR Evaluation

After all subagent results are collected, synthesize into a final review.

### Final Review Structure

**Output directly as formatted markdown — do NOT wrap in a single code block.**

---

## 📊 Overview

- **PR**: #[number] — [title]
- **Author**: [name]
- **Files changed**: [N] ([added]/[modified]/[deleted])
- **Complexity**: Low / Medium / High / Very High
- **Spec / PEP**: [link or "N/A"]
- **Summary**: [2–3 sentences on intent and scope]
- **Overall assessment**: [Quality, risk level, merge readiness]

---

## 🗂️ Semantic Groups

[List groups with their files and one-line purpose each]

---

## ⚠️ Issues Found

Group by file. Within each file, order: Critical → Nitpick → Clarification.

Use format:

**Critical | [Category]**: [one sentence]
Location: `path/to/file.ts`
Evidence (if helpful):
```start:end:path/to/file.ts
relevant code excerpt
```
Impact: [if non-obvious]

```suggestion
fixed code here
```

---

_Nitpick | [Category]_: [one sentence]
Location: `path/to/file.ts`
Evidence (if helpful):
```start:end:path/to/file.ts
relevant code excerpt
```

---

_Clarification Needed_: [question]
Location: `path/to/file.ts`
Evidence (if helpful):
```start:end:path/to/file.ts
relevant code excerpt
```

---

## 🔭 Holistic Evaluation

Answer each of the following:

- **Scope completeness**: Are there obvious omissions from the stated goal/spec? What's missing?
- **Rename coverage** *(mandatory if any identifier was renamed)*: Were all usages of the old name updated? Confirm subagent rename searches found no remaining references in files outside the diff. Call out any that remain.
- **Structural / design concerns**: Any architectural issues that span multiple groups?
- **Simplicity**: Is the PR as concise as possible, or does it contain unnecessary changes or complexity?
- **Infrastructure flags**: Note any DB indices, migrations, NATS topic additions, CI changes, AWS services, env vars, or feature flags introduced

---

## 🔄 Refactoring Opportunities

- **Duplication**: Describe and suggest abstraction
- **Simplification**: Highlight complexity that could be reduced
- **Pattern reuse**: Point to better patterns already in the codebase

---

## 📝 Recommendations

### Testing gaps
- [List untested paths or scenarios]

### Follow-up work
- [Technical debt, TODOs, future PRs suggested]

### Manual QA checklist
- [ ] [Step 1]
- [ ] [Step 2]
- ...

---

## Tone

- Kind, collegial, direct
- Assume the author had good reasons; ask rather than accuse
- Be specific and actionable — no vague "this could be improved"
- Balance idealism with pragmatism; not every nitpick needs to block a merge
- Copy-friendly suggestions (easy to paste into GitHub comments)
