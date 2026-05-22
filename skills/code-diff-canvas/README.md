# code-diff-canvas

Renders code chunks and diffs as a single self-contained HTML page with proper syntax highlighting (Pierre Diffs + Shiki, server-side rendered).

For **agent-facing usage** (when to invoke, manifest schema, workflow), see [SKILL.md](./SKILL.md). This README covers **how the skill works under the hood** so you can debug, extend, or rebuild it.

## Goal

Provide a "canvas" view of code/diffs that works **everywhere a browser does** — VSCode/Cursor/Zed integrated terminals, standalone CLIs (Codex, Claude Code, Amp), or just a desktop browser. The artifact is a single `.html` file opened via `file://`. No server, no CDN, no IDE-specific APIs.

The design is inspired by Cursor's [`pr-review-canvas`](https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/pr-review-canvas) skill, but stripped of Cursor-specific assumptions and rebuilt on [`@pierre/diffs`](https://www.npmjs.com/package/@pierre/diffs) instead of a hand-rolled diff renderer.

## Layout

```
skills/code-diff-canvas/
├── SKILL.md              # agent-facing instructions
├── README.md             # (this file) implementation notes
├── package.json          # pins @pierre/diffs
├── .gitignore            # ignores node_modules + lockfile
├── scripts/
│   ├── assemble.mjs      # SSR + page assembly
│   └── open.sh           # POSIX sh opener
└── examples/
    ├── 01-minimal.json
    ├── 02-mixed-blocks.json
    └── 03-patch.json
```

## End-to-end flow

```
manifest.json ──► assemble.mjs ──► self-contained .html ──► open.sh ──► browser
                       │                    │
                       │                    └─ inline script wraps
                       │                       each diff in Shadow DOM
                       │                       on DOMContentLoaded
                       │
                       └─ @pierre/diffs/ssr renders each block
                          (preloadDiffHTML / preloadFile / preloadPatchFile)
```

1. **Agent writes a manifest** — an ordered list of typed blocks (`prose`, `code`, `diff`, `patch`). See [SKILL.md](./SKILL.md#manifest-format) for the schema.
2. **`assemble.mjs` renders each block** to an HTML string using `@pierre/diffs/ssr`. Prose blocks go through a tiny built-in markdown converter.
3. **Page is assembled** — a fixed shell with page-level CSS, the rendered blocks in order, and a small hydration script appended.
4. **`open.sh` opens the file** in the system browser and prints the `file://` URL.

## Why server-side rendering?

`@pierre/diffs` exposes both client-side (`@pierre/diffs`) and SSR (`@pierre/diffs/ssr`) entry points. We use SSR because:

- **The artifact is portable.** A single `.html` file with no `<script src="…">` to a CDN works in offline sandboxes, email previews, and air-gapped review.
- **No bundler needed.** SSR runs once at assembly time; the agent doesn't have to deal with import maps, ESM CDNs, or version pinning at runtime.
- **Fewer moving parts.** The only client JS is a ~10-line hydration shim we own.

The trade-off: no live interactivity beyond what HTML/CSS gives us (hover, scroll). For v1 this is fine — the skill is a *reading* surface, not an editor.

## The Shadow DOM hydration trick

Pierre's SSR output assumes its HTML will live inside a Shadow DOM (a Pierre custom element called `diffs-container`). The bundled CSS uses `:host` selectors, which only resolve in Shadow DOM.

Two ways to satisfy this:

1. Ship Pierre's `web-components.js` to register `<diffs-container>` and adopt the bundled stylesheet. Heavier (extra script, separate stylesheet adoption), and the children would still need to be moved into the shadow root.
2. **Roll our own.** Each prerendered diff already includes its `:host`-scoped styles inline as a `<style data-core-css>` block. If we put that HTML inside *any* shadow root, the styles activate.

We chose (2). [`assemble.mjs`](./scripts/assemble.mjs) wraps each diff in:

```html
<div class="diff-host" data-pierre-diff>...prerendered html...</div>
```

and emits this hydration script at the bottom of the page:

```js
document.addEventListener('DOMContentLoaded', () => {
  for (const host of document.querySelectorAll('[data-pierre-diff]')) {
    if (host.shadowRoot) continue;
    const root = host.attachShadow({ mode: 'open' });
    while (host.firstChild) root.appendChild(host.firstChild);
  }
});
```

Net result: the prerendered HTML is moved into a shadow root we created on the fly, the inline `<style data-core-css>` styles activate, and we have **zero runtime dependency on Pierre's JS**.

## Block types and the SSR functions they map to

| Block type | SSR function used | Purpose |
|-----------|------------------|---------|
| `prose` | *(none — internal markdown converter)* | Narrative between code |
| `code` | `preloadFile` | Show one file/snippet, no diff |
| `diff` | `preloadDiffHTML` (with `oldFile`/`newFile`) | Synthesized diff from before/after pair |
| `patch` | `preloadPatchFile` | Raw unified diff; expands multi-file patches into one host per file |

All diff/code blocks pass `theme: { dark: 'pierre-dark', light: 'pierre-light' }` so the SSR output contains both themes; the browser picks via `prefers-color-scheme`.

## Markdown in prose blocks

The `prose` block accepts a tiny markdown subset, implemented inline in [`assemble.mjs`](./scripts/assemble.mjs) (`renderMarkdown`):

- Headings `#`–`######`
- Paragraphs (blank-line separated)
- Bullet lists `- item`
- Inline `` `code` ``, `**bold**`, `*em*`, `[label](url)`

This is deliberately minimal — pulling in a full markdown lib (`marked`, `remark`, etc.) would more than triple the dependency footprint for a feature most prose blocks don't need. If you need richer markdown, swap `renderMarkdown` for a real lib without touching anything else.

## Page CSS

Page-level styles (the canvas wrapper, headings, prose, `block-note` callouts) live in `PAGE_CSS` in [`assemble.mjs`](./scripts/assemble.mjs). They're inlined into a `<style>` tag in `<head>`.

The **diff styles** are *not* in `PAGE_CSS`. Each Pierre diff ships its own `<style data-core-css>` block alongside its content, scoped via Shadow DOM. This means:

- The page CSS can never accidentally leak into a diff (Shadow DOM boundary).
- The diff CSS can never leak into the page (it's `:host`-scoped).

Both layers honor `color-scheme: light dark` and use `light-dark()` color functions.

## The opener script

[`scripts/open.sh`](./scripts/open.sh) is intentionally boring:

1. Resolve absolute path (POSIX-portable, no `realpath`).
2. Try `open` (macOS), then `xdg-open` (Linux). Failures are non-fatal.
3. Always print the `file://` URL on stdout — even if launching the browser failed, the agent can include the URL in its reply for the user to click.

We **deliberately don't try IDE-specific in-app browsers**. VSCode/Cursor/Zed CLIs vary, the in-app browsers have inconsistent feature support, and the system browser works everywhere — including when launched from an integrated terminal. The user can always hijack the URL and open it wherever they prefer.

Per [AGENTS.md](../../AGENTS.md), the opener is written for `/bin/sh` (no Bash extensions, no `realpath`, no `local`, no `[[ ]]`).

## Bundle size & performance

Each diff currently emits the full Pierre asset bundle inline:

| Component | Approx size per diff |
|-----------|---------------------:|
| SVG icon sprite | ~8 KB |
| Core CSS (`<style data-core-css>`) | ~30 KB |
| Themed token styles (Pierre Light + Dark) | ~10 KB |
| Diff content + line tokens | varies |

A 5-diff page lands around ~250 KB, mostly dedup-able boilerplate. Two future optimizations:

1. **Sprite & core-CSS dedupe.** Strip the sprite and `<style data-core-css>` from all-but-one diff during assembly, since they're identical across all hosts in the same page.
2. **Single shared shadow root** with hosts as light-DOM siblings. More invasive — would require rewriting Pierre's `:host` selectors.

Neither is necessary for v1 — pages well under 1 MB load instantly from disk.

## Setup & invocation

One-time per machine:

```sh
cd skills/code-diff-canvas
npm install   # installs @pierre/diffs (~6 transitive deps, ships its own Shiki)
```

Build a canvas:

```sh
node scripts/assemble.mjs path/to/manifest.json   # writes /tmp/code-diff-canvas-<ts>.html, prints path
sh scripts/open.sh /tmp/code-diff-canvas-<ts>.html
```

Or pipe a manifest via stdin:

```sh
some-command-that-emits-json | node scripts/assemble.mjs -
```

## Verifying changes

After modifying `assemble.mjs` or any block-rendering logic:

```sh
node scripts/assemble.mjs examples/01-minimal.json /tmp/v.html
node scripts/assemble.mjs examples/02-mixed-blocks.json /tmp/v2.html
node scripts/assemble.mjs examples/03-patch.json /tmp/v3.html
```

Open each in a browser and confirm: title renders, prose has headings, code chunks have syntax colors, diffs show add/remove rows, multi-file patches split into separate cards. Headless Chrome works for automated visual checks:

```sh
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --hide-scrollbars \
  --window-size=1100,1800 --screenshot=/tmp/v.png \
  --virtual-time-budget=2000 file:///tmp/v.html
```

## Known limitations (v1)

- No interactivity beyond Pierre's defaults (hover, scroll). No collapsible sections, sticky headers, per-file checkboxes, or comments.
- Each diff is rendered as a fully-isolated Shadow DOM subtree, so global "expand all hunks" or cross-diff search is not possible.
- The markdown subset in `prose` blocks is intentionally minimal; tables, fenced code blocks, and HTML pass-through are not supported (use a `code` block for code).
- Pierre's `patch` parser expects standard unified diff. Exotic formats (combined diffs from octopus merges, binary diffs) may not parse.

## References

- [Pierre Diffs documentation](https://diffs.com/docs)
- [`@pierre/diffs` on npm](https://www.npmjs.com/package/@pierre/diffs)
- [Cursor's pr-review-canvas skill](https://github.com/cursor/plugins/tree/main/cursor-team-kit/skills/pr-review-canvas) — original inspiration
- [Shiki](https://shiki.style/) — underlying syntax highlighter
