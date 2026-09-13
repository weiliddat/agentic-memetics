---
name: code-walkthrough
description: Explain code or a feature in logical sections, connecting intent to implementation. Use only when the user explicitly asks for code-walkthrough or a code walkthrough.
---

# Code Walkthrough

Help the reader understand how the requested code works, why it is structured that way, and how its parts connect. Match depth to the question and the reader's familiarity.

## Scope and structure

Read the code needed to explain the requested behavior. Follow related types, callers, configuration, tests, or linked design context when they affect the explanation. Distinguish observed behavior from inferred intent and unresolved questions. For PR-scoped walkthroughs, use the relevant diff and comparison baseline.

Mention suspected defects or incomplete behavior you notice, distinguishing confirmed behavior from concerns that need verification. Do not turn the walkthrough into a review.

Start with a useful mental model, then group the explanation by coherent concepts or steps. Choose the order that makes the code easiest to understand:

- For a feature, follow the flow from its entry point through processing and side effects to the result.
- For a module, introduce its responsibilities and interfaces before the implementation details.
- For domain logic, explain the concepts, rules, and state transitions.
- For an algorithm, establish its input/output contract and approach before the consequential steps and tradeoffs.

Combine these approaches when useful. Explain each section's purpose and mechanism together, connecting sections across file boundaries. Include assumptions, failure paths, and tradeoffs where they affect understanding. Avoid a fixed template or a separate section for every file.

## Code references and snippets

Use the current harness's native code-reference and link formatting. Where possible, link references and code blocks back to the original file and relevant lines, placing the link next to the excerpt. Verify paths and line numbers against the source being explained. If clickable references are unavailable, give a readable file path and line location.

Include concise code snippets when requested or when they help explain the behavior. Keep the relevant source intact and enough context to make the excerpt understandable. Replace long, less relevant sections with comments that summarize the omitted work in pseudocode, using the source language's comment syntax. For example, an omission might read `// ... validate the remaining fields and collect errors ...`.

Make omissions and any illustrative pseudocode distinguishable from actual source. Preserve ordering and conditions that matter to the explanation; do not hide a relevant branch or side effect to shorten a snippet. A reference alone is sufficient when showing the code would add little.

## Diagrams

Use a diagram when it explains relationships, control flow, state transitions, or interactions more concisely and clearly than long or dense prose. Prefer Mermaid when the harness supports it; otherwise use a compact ASCII diagram.

Keep labels tied to the code's actual concepts and show only the relationships needed for the explanation. Put source links alongside the diagram where useful. Let the diagram carry the structure and use prose for behavior or qualifications it cannot convey clearly, without repeating the full flow in text.
