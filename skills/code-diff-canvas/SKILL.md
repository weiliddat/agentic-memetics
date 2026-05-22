---
name: code-diff-canvas
description: Render code chunks and diffs as a self-contained HTML canvas page (server-side rendered with Pierre Diffs + Shiki). Use when you have multiple files, sizable diffs, or a structured walkthrough/review that would be hard to read inline in chat.
---

# Code Diff Canvas

Generate a single self-contained HTML page that displays code chunks and diffs with proper syntax highlighting and split/unified diff layouts. The page works in any browser (no server, no bundler, no CDN at runtime). Use this as an **upgrade path** from inline previews when the inline form would be too long or hard to scan.

When you need an inline reference instead, use [code-reference-formatting](../code-reference-formatting/SKILL.md).

## When to use

- A code review or PR walkthrough with ≥2 files or ≥1 sizable diff
- A code walkthrough that interleaves prose, raw code chunks, and diffs in a deliberate order (often regrouped or trimmed from `git diff`)
- A summary of edits the agent just made, where showing the before/after side-by-side is clearer than narrating

## When NOT to use

- A single-line or one-hunk change — inline preview is fine
- Pure prose answers with no code

## How it works

1. The agent writes a **manifest JSON** describing the page (title + ordered `blocks`).
2. `scripts/assemble.mjs` runs `@pierre/diffs/ssr` to render each block to HTML and writes a single `.html` file. No runtime JS dependency on Pierre — only a ~10-line inline script that wraps each diff in a Shadow DOM root so the bundled `:host`-scoped styles apply.
3. `scripts/open.sh` opens the file in the system browser (or prints a `file://` URL).

## Manifest format

```json
{
  "title": "string (required)",
  "subtitle": "string (optional)",
  "blocks": [ /* ordered list, see block types below */ ]
}
```

### Block types

The agent chooses the type per block. **Order is preserved** — interleave freely.

#### `prose` — narrative between code

```json
{ "type": "prose", "markdown": "## Section\n\nText with `code`, **bold**, *em*." }
```

Supports a tiny markdown subset: headings, paragraphs, `- bullets`, inline `` `code` ``, `**bold**`, `*em*`, `[links](url)`. Use this for section headers, explanations, callouts.

#### `code` — a standalone code chunk (no diff)

```json
{
  "type": "code",
  "name": "src/path/to/file.ts",
  "note": "Optional markdown shown above the chunk.",
  "contents": "...source text...",
  "lineNumbers": true
}
```

`name` drives Shiki language detection. Use this when you want to *show* code without comparing — e.g. "here's the new types file" or "here's a usage example for the API".

#### `diff` — synthesized before/after

```json
{
  "type": "diff",
  "name": "src/path/to/file.ts",
  "note": "Optional markdown reviewer note shown above the diff.",
  "before": "...old contents...",
  "after":  "...new contents...",
  "layout": "unified"
}
```

Use this when you have the two versions of the file (or a *trimmed/regrouped* slice of them). `layout` accepts `"unified"` (default) or `"split"`. The diff is computed by Pierre Diffs.

#### `patch` — raw unified-diff text

```json
{
  "type": "patch",
  "patch": "diff --git a/... ...",
  "note": "Optional markdown shown above each file in the patch.",
  "layout": "unified"
}
```

Use this when you have output from `git diff` / `gh pr diff`. Multi-file patches expand into one diff host per file automatically.

## Workflow

### 1. Build the manifest

Decide the *structure* first — how many sections, which files matter, what to regroup. Then produce the JSON. Save it under `/tmp/code-diff-canvas-<id>.json` (any path is fine).

For agent-edited files, prefer `diff` with `before`/`after` — you already have both strings. For PRs, prefer `patch` with `gh pr diff` output.

### 2. Render and open

Resolve the skill directory once (the assembler must run from a directory where `@pierre/diffs` resolves):

```sh
SKILL_DIR=~/.agents/skills/code-diff-canvas   # or wherever this skill is linked

OUT=$(node "$SKILL_DIR/scripts/assemble.mjs" /tmp/my-canvas.json)
"$SKILL_DIR/scripts/open.sh" "$OUT"
```

`assemble.mjs` prints the absolute path of the generated HTML to stdout. `open.sh` opens it in the system browser and prints the `file://` URL. Surface the URL in your reply so the user can re-open it.

### 3. Reply concisely

After rendering, your chat reply should be short — the canvas does the heavy lifting. Mention what the canvas covers and link to it. Don't repeat the diffs inline.

## Examples

Three runnable manifests live in [examples/](./examples/):

- [01-minimal.json](./examples/01-minimal.json) — one prose block + one synthesized diff
- [02-mixed-blocks.json](./examples/02-mixed-blocks.json) — interleaved prose / `code` / `diff`, demonstrating regrouping
- [03-patch.json](./examples/03-patch.json) — a raw `git diff` patch fed straight in

Render any of them with:

```sh
node scripts/assemble.mjs examples/01-minimal.json
```

## Setup (once per machine)

The skill ships a `package.json` pinning `@pierre/diffs`. Install before first use:

```sh
cd path/to/skills/code-diff-canvas && npm install
```

Requires Node 18+ (uses `fs/promises`, top-level await, `node:` imports).

## Theming

The page declares `color-scheme: light dark` and ships both Pierre Light and Pierre Dark themes; the browser picks based on `prefers-color-scheme`. No agent action needed.

## Notes & limitations (v1)

- **No interactivity** beyond what Pierre Diffs renders for free (hover, scroll). No collapse/expand, no per-file checkboxes, no sticky headers.
- **No CDN dependencies.** The assembled HTML embeds everything it needs.
- **Self-contained file**, no local server. Open with `file://`.
- **Patches must be unified diff format.** Pierre Diffs handles standard `git diff` output; non-standard formats may not parse.
