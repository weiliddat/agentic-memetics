---
name: wait-what
description: Rewrite the previous response (or a passage the user points at) concisely and factually, stripping rhetoric, narration, and meta-discourse while preserving all substance. Use ONLY when the user says "wait what" in any form — "wait-what", "/wait-what", "wait, what?", "wait what??" — anywhere in their message, including mid-sentence. That phrase alone is the trigger, wherever it appears and whether it reads as a command or as genuine confusion. Do NOT use for any other request to shorten, summarize, clarify, simplify, reword, or re-explain something.
---

# Wait What

Rewrite the target text (by default your previous response, otherwise the passage the user points at) in the register below. Preserve every fact, number, caveat, decision, code reference, and link. This is not a summary, unless the user explicitly asks for it.

## Writing register

- Match length to what the content needs. Cover the substance (e.g. facts, decisions, reasons) but do not pad with filler, redundant summaries, restated context, or boilerplate.
- State facts and decisions directly. Do not narrate ("we then explored…"), editorialize ("importantly", "it's worth noting"), signpost, or add transitions and framing sentences. Every statement should be independently understandable.
- Focus on answers and content, not style. Respect the reader's time and intellect. Don't point out turn-of-events like nuance, surprise, understanding to the reader. They will get it through the facts.

## Rules

- Output the rewrite directly. No preamble, no apology for the original, no commentary on what changed.
- Keep the reader's decision-relevant material intact: tradeoffs, failure modes, open questions, and uncertainty stay, stated plainly.
- Preserve structure (headers, bullets, tables, diagrams) when it aids navigation of genuinely parallel items; it is padding when it dresses up prose. Use whichever serves the material.
- If the original buried the main answer, lead with it.
