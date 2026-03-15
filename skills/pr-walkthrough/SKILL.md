---
name: pr-walkthrough
description: Walk through a pull request by gathering context, grouping related changes, and explaining each group for reviewers. Use when the user asks to understand, review, or walk through a PR.
---

# PR Walkthrough

Guide reviewers through a pull request by gathering context, identifying logical groups of changes, and explaining each group with clear intent and technical details.

## Context Management Strategy

Large PR diffs can consume most of the agent's context window, leaving little room for producing high-quality walkthrough explanations. To avoid this:

1. **Main agent** handles lightweight steps (PR metadata, file list, ticket lookup) and the final walkthrough output
2. **Subagents** handle context-heavy steps (reading full diff, reading source files, grouping changes) and return condensed structured summaries
3. This keeps the main agent's context clean for the most important part: composing the walkthrough

## Workflow

Copy this checklist and track progress:

```
PR Walkthrough Progress:
- [ ] Step 1: Gather PR context and file list
- [ ] Step 2: Delegate analysis to subagent(s)
- [ ] Step 3: Draft and refine output (validate code blocks in reasoning)
- [ ] Step 4: Format for reviewer
```

---

## Step 1: Gather PR Context and File List

This step runs in the **main agent** to collect lightweight metadata.

### Get PR description and file list

```bash
# Get PR description and metadata
gh pr view

# Get file list with change stats (lightweight — NOT the full diff)
gh pr diff --stat
```

**Important:** Do NOT run `gh pr diff` (full diff) in the main agent. The full diff will be read by subagents in Step 2.

### Check for ticket reference

Look for a ticket prefix (e.g., `PEP-12345`) in:

- PR title
- Branch name

If found, search Notion MCP for additional context:

```
Use the Notion MCP to search for the ticket ID (e.g., "PEP-12345") to retrieve:
- Goal/objective of the work
- Acceptance criteria
- Design decisions
```

---

## Step 2: Delegate Analysis to Subagent(s)

Launch a `generalPurpose` subagent (do NOT set `model` — let it inherit the parent's thinking model) to perform the context-heavy analysis. This keeps the full diff and file contents out of the main agent's context.

### Subagent prompt template

Use the Task tool with `subagent_type: "generalPurpose"`. Do NOT set `model`. Compose the prompt as follows, filling in the `{variables}`:

````
You are analyzing PR #{pr_number} for a walkthrough. Here is context from the PR:

**PR Title:** {title}
**PR Description:**
{description}

**Files changed (from --stat):**
{diff_stat_output}

**Ticket context (if any):**
{ticket_context_or_none}

## Your Tasks

### 1. Get the full diff

Run: `gh pr diff {pr_number}`

### 2. Read additional context if needed

For complex changes, read surrounding code to understand how changed code fits into the larger system. Focus on:
- Function/class signatures that are called or extended
- Related types and interfaces
- Configuration or routing that ties components together

### 3. Group related changes

Break the diff into logical groups. For each group:

1. **Identify change themes** — What are the distinct logical units?
   - New features or capabilities
   - Refactoring or restructuring
   - Bug fixes
   - Configuration changes
   - Test additions/modifications

2. **Prioritize groups** — Order by importance:
   - Core business logic changes first
   - Supporting infrastructure second
   - Tests and configuration last

### 4. Return structured output

Return your analysis in EXACTLY this format for each group:

```
=== GROUP: [Group Title] ===
INTENT: [1-2 sentence explanation of what this change aims to achieve and why]
TECHNICAL: [Description of how the code achieves this goal, including key implementation details]
FILES:
- `path/to/file.ts:startLine:endLine`: [brief description of what changed in this range]
- `path/to/other.ts:startLine:endLine`: [brief description]
RELATED_UNCHANGED:
- `path/to/related.ts:startLine:endLine`: [why this unchanged code is relevant]
REVIEW_NOTES:
- Correctness: [assessment]
- Risks: [any potential risks]
- Decisions: [key decisions made and alternatives]
- Testing: [how to test + QA considerations]
=== END GROUP ===
```

IMPORTANT:
- Line numbers in FILES must be exact line numbers from the current files on disk (not diff line numbers). Verify by reading the file.
- Include 3-5 lines of context in each range so snippets are meaningful.
- Every group must have at least one file reference.
- Order groups by importance (core logic first, tests/config last).
````

### When to use multiple subagents

For very large PRs (30+ files across clearly separate areas), you MAY split into 2-3 parallel subagents, each handling a subset of files. Include the file list partition in each subagent's prompt so they know their scope. Each subagent should still return the same structured format.

### After subagent(s) return

The main agent receives condensed structured summaries (not the raw diff). Use these summaries to compose the walkthrough in Step 3.

---

## Step 3: Draft and Refine Output

Before presenting to the user, draft the complete walkthrough in your thinking/reasoning block, then review and refine it.

### 3a. Draft in Reasoning

In your thinking block, compose the full walkthrough using the subagent's structured group summaries. For code references, use the file paths and line ranges provided by the subagent.

### 3b. Review the Draft

Check the following before outputting:

**Structure & Flow:**

- Are groups ordered by importance (core logic first, tests/config last)?
- Is each group focused on a single logical change?
- Should any groups be merged or split?

**Conciseness:**

- Does each explanation focus on intent ("why") not just description ("what")?
- Are there redundant or overly verbose sections to trim?

**Code References:**
- Use `skills/code-reference-formatting/SKILL.md` for all references and previews
- Prefer the environment's native clickable format when you know it
- Otherwise use `filepath[:start][:end]` with the preview directly underneath

### 3c. Verify Key Code References

If any code reference from the subagent seems uncertain, read just those specific line ranges (small, targeted reads) to confirm accuracy before including them in the output.

### 3d. Output Refined Version

After reviewing, output the final walkthrough to the user.

---

## Step 4: Format for Reviewer

For each group, present information in this structure:

```markdown
### [Group Title]

**Goal/Intent:**
[Explain what this change aims to achieve and why]

**Technical Implementation:**
[Describe how the code achieves (or doesn't fully achieve) this goal]

**Files Changed:**
[Use the shared `code-reference-formatting` skill for references and previews]

**OPTIONAL: Related unchanged code:**
[If there are code structures not in the diff but are still relevant, format them with the shared `code-reference-formatting` skill]

**Review Notes:**
[Brief evaluation covering: correctness, potential risks, key decisions made, sane alternatives if applicable, how to test this change, and QA considerations for affected user flows/behaviors]
```

### Code Reference Format

Use the shared `code-reference-formatting` skill. Do not redefine file-reference rules here.

---

## Output Example

````markdown
## PR Walkthrough: Add user permission checks to API endpoints

### 1. Permission Service Implementation

**Goal/Intent:**
Introduce a centralized permission checking service to validate user access before processing API requests.

**Technical Implementation:**
Creates a new `PermissionService` class that:

- Accepts user context and resource identifiers
- Queries the permissions table for matching grants
- Returns a boolean indicating access level

The implementation uses caching to avoid repeated database lookups.

**Files Changed:**

`src/services/PermissionService.ts:1:25`
```ts
export class PermissionService {
    private cache: Map<string, boolean>;

    async checkAccess(userId: string, resourceId: string): Promise<boolean> {
        const cacheKey = `${userId}:${resourceId}`;
        if (this.cache.has(cacheKey)) {
            return this.cache.get(cacheKey)!;
        }
        // ... database lookup
    }
}
```

`src/types/permissions.ts:1:12`
```ts
export interface Permission {
    userId: string;
    resourceId: string;
    level: 'read' | 'write' | 'admin';
}
```

**Related Code:**

`src/services/UserService.ts:45:60`
```ts
// User context retrieval used by PermissionService
async getUserContext(userId: string): Promise<UserContext> {
    // ...
}
```

**Review Notes:**

- Correctness: Logic is sound; cache key format prevents collisions
- Risk: In-memory cache not shared across instances—consider Redis for multi-node deployments
- Decision: Using Map over WeakMap is appropriate here since we need string keys
- Alternative: Could use a decorator pattern instead of explicit service calls
- Testing: Call `checkAccess` with valid/invalid user-resource pairs; verify cache hits on repeated calls
- QA: Verify users with different permission levels see appropriate content; check permission changes take effect without requiring re-login

---

### 2. API Endpoint Integration

**Goal/Intent:**
Apply permission checks to existing API endpoints to enforce access control.

**Technical Implementation:**
Adds middleware that:

- Extracts user from request context
- Calls PermissionService before route handler
- Returns 403 if access denied

**Files Changed:**

`src/middleware/authMiddleware.ts:12:35`
```ts
export const checkPermissions = async (req, res, next) => {
    const user = req.context.user;
    const hasAccess = await permissionService.checkAccess(user.id, req.params.id);
    if (!hasAccess) {
        return res.status(403).json({ error: 'Forbidden' });
    }
    next();
};
```

`src/routes/users.ts:8:15`
```ts
router.get('/users/:id', checkPermissions, userController.getUser);
router.put('/users/:id', checkPermissions, userController.updateUser);
```

**Review Notes:**

- Correctness: Middleware runs before controller, but doesn't handle async errors—unhandled rejection if `checkAccess` throws
- Risk: Missing permission check on DELETE route if one exists
- Decision: Using middleware over route-level guards keeps routes clean
- Testing: Send requests to protected endpoints with/without valid auth; confirm 403 response for unauthorized access
- QA: Navigate to user profile pages as different roles; confirm unauthorized users see a proper error page instead of broken UI
````

---

## Tips

- **Be concise but complete** - Reviewers want to understand intent, not read the code twice
- **Highlight non-obvious decisions** - Call out trade-offs or alternatives considered
- **Note incomplete work** - If something is partially implemented, say so
- **Link related PRs** - If this PR depends on or relates to others, mention them
