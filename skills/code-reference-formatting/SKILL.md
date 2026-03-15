---
name: code-reference-formatting
description: Format code references and previews in a portable way across coding agents and IDEs. Use when a skill or response needs file references, line ranges, or code excerpts that should stay readable and clickable across environments.
---

# Code Reference Formatting

Use this skill whenever you need to cite code in output. Other skills should point here instead of redefining file-reference rules.

## Reference Selection

Prefer a host's native clickable reference syntax when you know the current environment supports it.

- Example: Cursor-native citation blocks in Cursor
- Example: any IDE or terminal that reliably opens `filepath[:start][:end]`

If you do not know a native format for the current environment, default to the portable form:

- `path/to/file.ts`
- `path/to/file.ts:42`
- `path/to/file.ts:42:57`

Use:

- path only when the whole file matters
- `:start` when you want to point at a single line or an open-ended location
- `:start:end` when you want a bounded range

## Preview Rules

Always include an actual code preview immediately after the file reference.

- If the referenced code is short, include the full preview.
- If it is long, include the first lines and last lines with a clear omission marker in the middle.
- Keep enough context for the excerpt to stand on its own.
- Use a normal fenced code block for the preview. Add a language tag when it is obvious and useful.

## Output Pattern

Use this shape:

````markdown
`path/to/file.ts:42:57`
```ts
const start = 42;
// ...
const end = 57;
```
````

## Examples

Whole file:

````markdown
`skills/code-reference-formatting/SKILL.md`
```md
# Code Reference Formatting
...
```
````

Single line or open-ended location:

````markdown
`skills/code-reference-formatting/SKILL.md:11`
```md
Prefer a host's native clickable reference syntax when you know the current environment supports it.
```
````

Bounded range:

````markdown
`skills/code-reference-formatting/SKILL.md:15:20`
```md
If you do not know a native format for the current environment, default to the portable form:

- `path/to/file.ts`
- `path/to/file.ts:42`
- `path/to/file.ts:42:57`
```
````

Long preview:

````markdown
`path/to/large-file.ts:120:220`
```ts
export const beginWork = () => {
  setup();
  runPhaseOne();
  // ...
  finalize();
  return summary;
};
```
````
