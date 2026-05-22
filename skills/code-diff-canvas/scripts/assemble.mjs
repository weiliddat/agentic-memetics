#!/usr/bin/env node
// Assemble a code-diff-canvas HTML file from a JSON manifest.
//
// Usage:
//   node scripts/assemble.mjs <manifest.json> [output.html]
//
// If <manifest.json> is "-", read JSON from stdin.
// If [output.html] is omitted, write to /tmp/code-diff-canvas-<timestamp>.html.
// On success, prints the absolute path of the output file to stdout.

import { readFile, writeFile } from 'node:fs/promises';
import { resolve as resolvePath } from 'node:path';
import {
  preloadDiffHTML,
  preloadFile,
  preloadPatchFile,
} from '@pierre/diffs/ssr';

const THEME = { dark: 'pierre-dark', light: 'pierre-light' };

// --- Tiny markdown subset (headings, **bold**, *italic*, `code`, paragraphs)
function escapeHTML(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}
function renderMarkdown(md) {
  const lines = String(md).split('\n');
  const out = [];
  let para = [];
  const flush = () => {
    if (!para.length) return;
    out.push(`<p>${inline(para.join(' '))}</p>`);
    para = [];
  };
  const inline = (s) =>
    escapeHTML(s)
      .replace(/`([^`]+)`/g, '<code>$1</code>')
      .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
      .replace(/(^|[^*])\*([^*]+)\*/g, '$1<em>$2</em>')
      .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
  for (const line of lines) {
    if (/^#{1,6}\s/.test(line)) {
      flush();
      const m = line.match(/^(#{1,6})\s+(.*)$/);
      out.push(`<h${m[1].length}>${inline(m[2])}</h${m[1].length}>`);
    } else if (/^\s*-\s+/.test(line)) {
      flush();
      out.push(`<li>${inline(line.replace(/^\s*-\s+/, ''))}</li>`);
    } else if (line.trim() === '') {
      flush();
    } else {
      para.push(line);
    }
  }
  flush();
  // Wrap consecutive <li> in <ul>
  const joined = out
    .join('\n')
    .replace(/(?:^|\n)((?:<li>[\s\S]*?<\/li>\n?)+)/g, (_m, lis) => `\n<ul>\n${lis}</ul>`);
  return joined;
}

// --- Block renderers
async function renderBlock(block) {
  switch (block.type) {
    case 'prose':
      return `<section class="block prose">${renderMarkdown(block.markdown ?? '')}</section>`;

    case 'code': {
      // Render a single code chunk (no diff). `name` drives language detection.
      const { prerenderedHTML } = await preloadFile({
        file: { name: block.name ?? 'snippet.txt', contents: block.contents ?? '' },
        options: { theme: THEME, disableLineNumbers: block.lineNumbers === false },
      });
      return wrapDiffHost(prerenderedHTML, block.note);
    }

    case 'diff': {
      // Synthesized diff from before/after content (most useful when an agent
      // is showing edits it just made).
      const html = await preloadDiffHTML({
        oldFile: { name: block.name ?? 'a', contents: block.before ?? '' },
        newFile: { name: block.name ?? 'b', contents: block.after ?? '' },
        options: { theme: THEME, diffStyle: block.layout ?? 'unified' },
      });
      return wrapDiffHost(html, block.note);
    }

    case 'patch': {
      // Multi-file unified-diff patch (e.g. `git diff` / `gh pr diff` output).
      // Each file becomes its own diff host.
      const results = await preloadPatchFile({
        patch: block.patch ?? '',
        options: { theme: THEME, diffStyle: block.layout ?? 'unified' },
      });
      return results.map((r) => wrapDiffHost(r.prerenderedHTML, block.note)).join('\n');
    }

    default:
      return `<section class="block prose"><p><em>Unknown block type: ${escapeHTML(block.type)}</em></p></section>`;
  }
}

function wrapDiffHost(prerenderedHTML, note) {
  const noteHTML = note
    ? `<div class="block-note">${renderMarkdown(note)}</div>`
    : '';
  return `<section class="block diff">${noteHTML}<div class="diff-host" data-pierre-diff>${prerenderedHTML}</div></section>`;
}

// --- Hydration script: attach Shadow DOM to each diff host.
const HYDRATION_SCRIPT = `
document.addEventListener('DOMContentLoaded', () => {
  for (const host of document.querySelectorAll('[data-pierre-diff]')) {
    if (host.shadowRoot) continue;
    const root = host.attachShadow({ mode: 'open' });
    while (host.firstChild) root.appendChild(host.firstChild);
  }
});
`.trim();

// --- Page-level CSS (the diff itself ships its own styles inside Shadow DOM).
const PAGE_CSS = `
:root {
  color-scheme: light dark;
  --page-bg: light-dark(#fafafa, #0e0e10);
  --page-fg: light-dark(#1a1a1a, #e5e5e5);
  --page-muted: light-dark(#666, #999);
  --page-border: light-dark(#e5e5e5, #2a2a2a);
  --page-surface: light-dark(#ffffff, #18181b);
}
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; }
body {
  background: var(--page-bg);
  color: var(--page-fg);
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
  font-size: 14px;
  line-height: 1.55;
}
.canvas { max-width: 920px; margin: 0 auto; padding: 32px 20px 80px; }
.canvas-header { border-bottom: 1px solid var(--page-border); padding-bottom: 16px; margin-bottom: 24px; }
.canvas-header h1 { margin: 0 0 4px; font-size: 22px; font-weight: 600; }
.canvas-header .subtitle { color: var(--page-muted); font-size: 13px; }
.block { margin: 20px 0; }
.block.diff { background: var(--page-surface); border: 1px solid var(--page-border); border-radius: 8px; overflow: hidden; }
.block-note { padding: 12px 16px; border-bottom: 1px solid var(--page-border); background: var(--page-surface); }
.block-note p:first-child { margin-top: 0; }
.block-note p:last-child { margin-bottom: 0; }
.diff-host { display: block; }
.prose h1, .prose h2, .prose h3 { margin: 24px 0 8px; }
.prose h2 { font-size: 18px; }
.prose h3 { font-size: 15px; color: var(--page-muted); }
.prose p { margin: 8px 0; }
.prose code {
  font-family: ui-monospace, "SF Mono", Menlo, monospace;
  font-size: 12.5px;
  background: var(--page-surface);
  border: 1px solid var(--page-border);
  border-radius: 4px;
  padding: 1px 5px;
}
.prose ul { padding-left: 22px; }
.prose a { color: inherit; }
`.trim();

function buildPage({ title, subtitle, body }) {
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escapeHTML(title || 'Code Diff Canvas')}</title>
<style>${PAGE_CSS}</style>
</head>
<body>
<main class="canvas">
  <header class="canvas-header">
    <h1>${escapeHTML(title || 'Code Diff Canvas')}</h1>
    ${subtitle ? `<div class="subtitle">${escapeHTML(subtitle)}</div>` : ''}
  </header>
  ${body}
</main>
<script>${HYDRATION_SCRIPT}</script>
</body>
</html>
`;
}

// --- Main
async function main() {
  const [, , manifestArg, outputArg] = process.argv;
  if (!manifestArg) {
    console.error('Usage: node assemble.mjs <manifest.json|-> [output.html]');
    process.exit(2);
  }
  const raw =
    manifestArg === '-'
      ? await new Promise((res, rej) => {
          let data = '';
          process.stdin.setEncoding('utf8');
          process.stdin.on('data', (c) => (data += c));
          process.stdin.on('end', () => res(data));
          process.stdin.on('error', rej);
        })
      : await readFile(manifestArg, 'utf8');

  const manifest = JSON.parse(raw);
  const blocks = manifest.blocks ?? [];
  const rendered = [];
  for (const block of blocks) {
    rendered.push(await renderBlock(block));
  }
  const html = buildPage({
    title: manifest.title,
    subtitle: manifest.subtitle,
    body: rendered.join('\n'),
  });

  const outPath = resolvePath(
    outputArg || `/tmp/code-diff-canvas-${Date.now()}.html`
  );
  await writeFile(outPath, html, 'utf8');
  console.log(outPath);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
