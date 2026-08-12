---
name: code-walkthrough
description: Walk through code or a feature by reading relevant files, identifying logical sections, and explaining each with clear intent and technical details. Use only when the user explicitly asks for code-walkthrough or a code walkthrough.
---

# Code Walkthrough

Guide a reader through a codebase, module, or feature by gathering context, identifying logical sections, and explaining each with clear intent and technical details.

## Workflow

Copy this checklist and track progress:

```
Code Walkthrough Progress:
- [ ] Step 1: Understand scope and gather code
- [ ] Step 2: Classify the code and choose a structure
- [ ] Step 3: Group into logical sections
- [ ] Step 4: Draft and refine output (validate code blocks in reasoning)
- [ ] Step 5: Format for reader
```

---

## Step 1: Understand Scope and Gather Code

### Determine what to walk through

Clarify scope from the user's request:

- **Specific files/directories** — read them directly
- **A feature or behavior** — search the codebase to find all relevant code (handlers, services, models, utils, tests)
- **Part of a PR** — use `gh pr diff` and filter to the relevant files

### Read the code

Read all files in scope. For complex features, also read:

- Related types/interfaces/models
- Callers and callees of key functions
- Configuration or constants that affect behavior

### Check for additional context

If the user mentions a ticket, PR, or design doc, gather that context too.

---

## Step 2: Classify the Code and Choose a Structure

The walkthrough structure should match the nature of the code. Assess the code and pick the best structure — or combine elements from multiple.

### Structure A: Technical / Infrastructure Code

Use when the code is primarily about **data structures, APIs, system plumbing, or framework integration** (e.g., database layers, API clients, middleware, workers, SDK wrappers).

Order sections by:

1. **Data models / types** — schemas, interfaces, enums that define the domain
2. **External interfaces** — API endpoints, message queues, webhooks, third-party integrations
3. **Core functions / methods** — the main logic, ordered by importance or call flow
4. **Configuration / wiring** — setup, dependency injection, env vars, feature flags
5. **Error handling / edge cases** — how failures are managed

### Structure B: Domain / Business Logic Code

Use when the code is primarily about **rules, policies, state machines, or workflows** (e.g., permission systems, billing logic, approval workflows, scoring algorithms).

Order sections by:

1. **Domain concepts** — the key entities and their relationships
2. **Rules / policies** — the business rules encoded in the code, with the conditions and outcomes
3. **State transitions / workflows** — how data moves through states
4. **Decision points** — where branching logic determines behavior
5. **Edge cases / special handling** — exceptions to the main flow

### Structure C: Feature / End-to-End Flow

Use when the code spans **multiple layers** and the user wants to understand a feature holistically (e.g., "how does conversation archiving work?", "walk me through the review cycle flow").

Order sections by:

1. **Entry point** — where the flow begins (API handler, UI action, cron job, event)
2. **Data flow** — how data moves through the system, layer by layer
3. **Core processing** — the main transformation or business logic
4. **Side effects** — notifications, analytics, cache updates, external calls
5. **Output / result** — what the user sees or what state changes

### Structure D: Algorithm / Computation Code

Use when the code is primarily about a **non-trivial algorithm, data transformation, or computation** (e.g., ranking, matching, aggregation, parsing).

Order sections by:

1. **Input / output contract** — what goes in, what comes out
2. **Algorithm overview** — high-level approach before diving into code
3. **Step-by-step breakdown** — each phase of the computation
4. **Optimizations / trade-offs** — performance choices, approximations
5. **Correctness considerations** — invariants, boundary conditions

### Combining structures

Many features will benefit from mixing. For example, a feature walkthrough (Structure C) might use Structure B ordering within the "Core processing" section if that section is logic-heavy. Use your judgment — the goal is to create the most natural reading order for the specific code.

### Adapting to the user's request

- If the user asks "how does X work?" — favor flow-based structures (C or D)
- If the user asks "explain this module" — favor structural approaches (A or B)
- If the user asks about a specific behavior or bug — start from the relevant code path and expand outward
- If the user says "walk me through these files" — follow the file structure but reorder for clarity

---

## Step 3: Group into Logical Sections

Break the code into groups, each representing a coherent concept or step.

1. **Name each group clearly** — the title should tell the reader what they'll learn
2. **Order by the chosen structure** — follow the structure from Step 2
3. **Keep groups focused** — each group should cover one logical unit
4. **Include relevant context** — if understanding a group requires code from outside the primary scope, include it as "Related Code"

---

## Step 4: Draft and Refine Output

Before presenting to the user, draft the complete walkthrough in your thinking/reasoning block, then review and refine it.

### 4a. Draft in Reasoning

In your thinking block, compose the full walkthrough including all groups and code references.

### 4b. Review the Draft

Check the following before outputting:

**Structure & Flow:**

- Does the ordering match the chosen structure from Step 2?
- Is each group focused on a single logical concept?
- Should any groups be merged or split?
- Would a reader understand group N without having read group N+1?

**Conciseness:**

- Does each explanation focus on intent ("why") not just description ("what")?
- Are there redundant or overly verbose sections to trim?
- Is the level of detail appropriate for the user's request?

**Code References:**
- Use `skills/code-reference-formatting/SKILL.md` for file references and code previews
- Prefer the environment's native clickable format when you know it
- Otherwise use `filepath[:start][:end]` and put the preview directly underneath

### 4c. Output Refined Version

After reviewing, output the final walkthrough to the user.

---

## Step 5: Format for Reader

### Section template

For each group, present information in this structure:

```markdown
### [Group Title]

**Purpose:**
[What this section of code is responsible for and why it exists]

**How it works:**
[Explain the implementation — what the code does, key decisions, and non-obvious behavior]

**Key Code:**
[Use the shared `code-reference-formatting` skill for references and previews]

**OPTIONAL: Related Code:**
[Code outside the primary scope that helps understand this section. Format it with the shared `code-reference-formatting` skill.]

**OPTIONAL: Notes:**
[Anything worth calling out: trade-offs, risks, gotchas, incomplete work, potential improvements]
```

Adjust the template per section — not every section needs every field. Skip fields that would be empty or redundant.

### Code Reference Format

Use the shared `code-reference-formatting` skill. Do not redefine file-reference rules here.

---

## Output Example

````markdown
## Code Walkthrough: Conversation Auto-Archiving

### 1. Data Model

**Purpose:**
Defines what a conversation looks like and which fields control archiving behavior.

**Key Code:**

`modules/leapy/models/conversation.model.ts:12:28`
```ts
export interface Conversation {
    _id: ObjectId;
    companyId: ObjectId;
    userId: ObjectId;
    status: 'active' | 'archived';
    lastMessageAt: Date;
    // ...
}
```

---

### 2. Archive Job (Entry Point)

**Purpose:**
A scheduled job that finds and archives stale conversations. This is where the flow begins.

**How it works:**
Runs on a cron schedule. Queries for conversations that have been inactive longer than the configured threshold, then archives them in batches.

**Key Code:**

`modules/leapy/jobs/autoArchiveConversations.job.ts:1:35`
```ts
export const autoArchiveConversationsJob = async () => {
    const threshold = subDays(new Date(), ARCHIVE_AFTER_DAYS);
    const conversations = await findStaleConversations(threshold);
    // ... batch processing
};
```

**Notes:**
- Uses batching to avoid overwhelming the database
- Threshold is configurable via `ARCHIVE_AFTER_DAYS` constant

---

### 3. Archive Logic

**Purpose:**
Performs the actual state transition and cleanup when archiving a conversation.

**How it works:**
Sets status to `archived`, deletes associated AI checkpoints to free storage, and emits an event for downstream consumers.

**Key Code:**

`modules/leapy/services/conversation.service.ts:40:65`
```ts
export const archiveConversation = async (conversationId: ObjectId) => {
    await updateConversation(conversationId, { status: 'archived' });
    await deleteCheckpoints(conversationId);
    await emitEvent('conversation.archived', { conversationId });
};
```

**Related Code:**

`modules/ai/utils/deleteCheckpoints.util.ts:1:20`
```ts
// Checkpoint cleanup called during archiving
export const deleteCheckpoints = async (threadId: string) => {
    // ...
};
```

**Notes:**
- Checkpoint deletion is fire-and-forget — a failure here won't block the archive
- The emitted event is consumed by the analytics service
````

---

## Tips

- **Match depth to the ask** — a quick "how does X work?" needs less detail than "explain this module thoroughly"
- **Start with the big picture** — give the reader a mental model before diving into code
- **Highlight non-obvious behavior** — call out surprising logic, implicit assumptions, or hidden side effects
- **Note incomplete or concerning code** — if something looks like a bug or tech debt, mention it
- **Connect the dots** — explain how sections relate to each other, especially across file boundaries
