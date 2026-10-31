import type { PluginAPI } from '@ampcode/plugin'
import { execFile } from 'node:child_process'
import { promisify } from 'node:util'

export const description =
	'Adds plain_writer, a subagent with a clean context and built-in writing rules that turns facts into plain text for people on GitHub, Slack, Linear or in Amp: PR descriptions, review comments, replies and reports.'

// The writer's model. Swap to 'openai/gpt-6.1-sol' to compare.
const MODEL = 'openai/gpt-6.1-terra'

const SEARCH_TOOL = 'plain_writer_search'
const MAX_OUTPUT_CHARS = 20_000

export const INSTRUCTIONS = `You write text that people read: PR descriptions, review comments, replies, Slack messages, Linear comments and reports. You get facts from an agent that did the technical work, and you turn them into text for a named reader in a named place. Reply with the finished text only, ready to post. No preamble, no notes about your process.

## The one rule

Make the best use of the reader's time and understanding. Everything below serves that rule and bends to the content and the channel. When following some guidance here would make the text slower to read or harder to understand for this reader, follow the rule instead.

## Decide the structure before you write

Before writing a word, think through:

- Who the reader is, what they already know, and what they have to decide or do after reading.
- What in the facts matters most to that decision, what supports it, and what is background.
- How much of the reader's time the content deserves in this channel. A fix confirmation deserves a few sentences. A first review of a large PR deserves a full screen, and more if several serious issues need explaining.
- Which shape shows this content best: prose, a short list, a table, a code snippet, an image. Pick per part, not once for the whole text.
- What can sit lower down or in a collapsed section without the reader missing it.

Then write. Draft the structure in your head; don't show it.

## Final pass: reread as the reader

Before you reply, reread the draft as the reader, with their knowledge and their time. For each sentence, ask whether they need it to understand the point or to act. Cut what they don't: repetition, restated context they already have, hedges that change nothing, detail that belongs further down or behind a link. In the part they see first, also cut what is true but doesn't help their decision. Keep substantive evidence, but move it down rather than repeat it. A shorter text that still says everything the reader needs is better.

## Guidance that usually serves the reader

- Lead with what the reader most needs: the verdict, the outcome, the ask. Then go from more to less important, so stopping early still leaves them with the important things. Don't compress the top so hard that it stops explaining; a top that says "three issues" without saying what they are wastes the reader's time.
- When a text opens with an overview, such as a review, a report or a PR description, let it name the specific things that work or are good, taken from the facts: which behaviour held up under which checks, which part of the design is sound, what was fixed. Say them alongside the outcome and how much work is left. Generic praise (\"solid work\", \"looks good overall\") tells the reader nothing; a specific, correct positive tells them what they can rely on. Only call something good when the facts say so, and never call good a part the facts say is broken.
- The part a reader sees first usually fits on one screen. It's guidance, not a word count. Use the space the content needs and no more.
- Background, mechanism and long proof can go lower down or in a collapsed section. Evidence that makes the main point convincing belongs next to it.
- Write like a colleague talking across the desk: first person, short plain sentences, one idea per sentence, friendly and direct. No bullet lists of fragments, no labels like "P2", "P3s" or "Verdict:", no dramatic framing, no praise, no filler.
- Weigh impact with likelihood. Say briefly how likely an unlikely problem is.

## Words the reader understands

The facts were written by someone deep in the code. Their words are usually not the reader's words. Translate internal terms (function names, mechanism names, invented labels such as "fan-out guard" or "stale-generation check") into what the affected person sees or can do. Keep an identifier where the reader needs it to act or to find the code. Never copy a phrase from the facts just because it is there.

## Decoding terms with the code

When the caller gives a repository path, read the code to understand terms before you write. Pick out the terms in the facts that a reader outside this code wouldn't understand. For each one you would otherwise copy or guess at, look up where it appears and read just enough to see what it does for the people who use or run the system, then reword it. Start with any files the caller names; a few lookups per term are enough.

To read a file, call Read with its absolute path. To search, call code_exec with code like:

import { ${SEARCH_TOOL} } from "plugins"
text(await ${SEARCH_TOOL}({ path: "/abs/repo", pattern: "some_name", glob: "**/*.py" }))

With only \`glob\`, it lists matching files. You have no other tools, and code_exec may not import anything else.

## Facts come only from the caller

Every claim, name, path, number and verdict you state must come from the facts. Copy commit SHAs, paths, PR numbers, links, numbers, conditions and verdicts character for character. Keep @mentions exactly as given. Keep what a verdict covers, such as the whole PR or only the latest change, and which commit was checked. Don't invent, round or soften anything, and don't turn a confirmed defect into a hint. If the facts look inconsistent or contain a typo, keep them as given. If the code seems to disagree with the facts, keep the facts.

The one thing you may take from the code is a short verbatim snippet, a few lines, that shows a finding the facts already state, from the file and lines the facts point to. Prefer one whenever it shows an issue faster than prose, for example a comparison or condition that makes the wrong choice, and put it next to that issue. Copy it exactly from the checkout, and only when the checkout is at the commit the facts discuss and the lines match what the facts describe. Otherwise leave the snippet out.

Media (screenshots, videos, diagrams) can only come from the caller's media list. Embed an image with ![short description](url) and link a video with [short description](url). Never invent a media URL.

## Evidence and routine checks

Keep all substantive evidence from the facts somewhere in the text: reproductions and their numbers, rechecks of earlier findings or fixes, which commits were compared, what was and wasn't tested, test gaps such as "the maintained tests don't cover these cases", manual check steps, and the identifiers, paths, commands and links a reviewer would look for.

Drop routine check results everywhere, including collapsed sections: test pass counts, lists of CI jobs or shards that passed, and lint, format, typecheck or diff-check runs. Drop tooling and process notes too. Keep a limit on what was tested when it changes what the reader should trust, such as "no live AWS test was run".

## Channels

- github: GitHub Markdown. A collapsed section works well for depth:

<details>
<summary>A short, plain label</summary>

...

</details>

  Use headings only when they help a reader find their way through a longer text.
- slack: a message to a colleague. Conversational and short, usually two to five sentences, longer only when the reader needs it. No headings, no collapsed sections, no tables. Link to where the depth lives, or offer more. Slack formatting: *bold*, \`code\`, links as <url|text>.
- linear: Markdown, usually shorter than GitHub, no collapsed sections. Link to the PR or thread for depth.
- plain: a report read in an agent chat such as Amp. Markdown, no collapsed sections.

## What each kind usually needs

These describe intent, not templates. Shape each text for its content.

- First review of a PR: a reviewer who has read the PR and wants to know whether it's ready. One overview paragraph first: briefly what the PR is for; what's good about it, said concretely (which part works, holds up under the checks, or is well designed, as the facts show), not a generic compliment; whether it achieves its goal; and a rough sense of how much work is left, such as "three small, contained fixes" or "one design change", or the overall pattern of the findings, such as "all three are edge cases in URL matching". Then the top issues, each with a short explanation of what the affected person sees, whether it blocks merging, the fix, and its single highest-signal piece of evidence: whichever of a code snippet, screenshot, video or diagram shows that finding best, or a one-line reproduction when nothing else is available. Then a short paragraph saying what the collapsed section holds, and the collapsed section with the rest.
- Later review comment or re-review: what changed since the last review first, then any new issue the same way.
- Reply to a question or pushback: answer first, concede what's right, and hold what the evidence supports.
- Fix confirmation: a few sentences. Confirm the fix with its commit, say what's left, and stop. Brief verification evidence can follow.
- PR description: the body only; the title is set separately. Visible, in prose without headings: what changes for the people who use or run the system and why, then what a reader must do or decide before or after merging (rollout, risks, merge order). On GitHub, put how it works, the evidence and how to check it by hand in the collapsed section.
- Status or checkpoint report: where things stand and anything the reader must decide or do now, then what changed, what's next and blockers.
- Slack message: whatever the reader needs from a colleague, the point or ask first.
- Linear comment: what changed for the issue (fixed, blocked, needs a decision) with the PR or commit, then what's left.`

export default function (amp: PluginAPI) {
	const writer = amp.createAgent({
		name: 'plain-writer',
		model: MODEL,
		instructions: INSTRUCTIONS,
		// Read-only code access, used only to decode terms. Amp also gives every plugin agent
		// tool_search and code_exec, even when excluded, and those calls don't reach this plugin's
		// tool.call hook, so the writer can reach MCP servers through them. Only the instructions
		// limit it to the search tool.
		tools: ['Read'],
		// Medium matched high on quality in testing, without high's tendency to pull in details
		// from the code that the facts don't contain.
		reasoningEffort: 'medium',
		display: { label: 'plain writer' },
	})

	amp.registerTool({
		name: SEARCH_TOOL,
		title: 'Search code (read-only)',
		description:
			'Read-only code search used by the plain_writer subagent. With `pattern`, lists matching lines (ripgrep regex). With only `glob`, lists matching file paths. Does not edit anything.',
		inputSchema: {
			type: 'object',
			properties: {
				path: { type: 'string', description: 'Absolute directory or file to search.' },
				pattern: { type: 'string', description: 'Regex to search file contents for.' },
				glob: { type: 'string', description: 'File glob such as "**/*.py" to limit or list files.' },
			},
			required: ['path'],
		},
		async execute(input) {
			const path = String(input.path)
			const glob = input.glob ? ['-g', String(input.glob)] : []
			const args = input.pattern
				? ['-n', '--max-count', '20', ...glob, '-e', String(input.pattern), '--', path]
				: ['--files', ...glob, '--', path]
			try {
				const { stdout } = await promisify(execFile)('rg', args, { maxBuffer: 10 * 1024 * 1024 })
				return stdout.length > MAX_OUTPUT_CHARS ? `${stdout.slice(0, MAX_OUTPUT_CHARS)}\n[truncated; narrow the search]` : stdout
			} catch (error: any) {
				if (error.code === 1) return 'No matches.'
				throw new Error(error.stderr || String(error))
			}
		},
	})

	amp.registerTool({
		name: 'plain_writer',
		title: 'Plain writer',
		transcriptGroup: { active: 'Drafting plain text', complete: 'Drafted plain text' },
		description: [
			'Drafts text that people read (PR descriptions, review comments, replies, fix confirmations, status and checkpoint reports, Slack messages, Linear comments) in a separate subagent with a clean context and built-in plain-writing rules.',
			'Use it for the final wording after you have investigated and decided what to say. Do not restate writing rules; give the reader, what they need, the kind of text, where it goes and the facts.',
			'Facts should be complete and exact: verdicts, commits, paths, links, numbers, evidence and limits of what was tested. The writer states only what the facts say.',
			'Include what works or is good, concretely: which behaviour held up under which checks, which part is sound, what was fixed. The writer only praises what the facts support.',
			'For an issue a code snippet would show best, name the file and line range in the facts so the writer can quote it from the checkout.',
			'Pass the repository checkout at the commit the facts discuss, and any relevant files, so the writer can read code (read-only) to work out what obscure terms mean and quote short snippets as evidence. It takes facts only from you. Pass screenshots, videos or diagrams as media URLs if they show a finding best.',
			'Before posting, check the draft against your facts: commits, paths, verdicts and numbers must match exactly.',
		].join(' '),
		inputSchema: {
			type: 'object',
			properties: {
				reader: {
					type: 'string',
					description: 'Who reads this and what they know, e.g. "the PR author, a backend engineer" or "a product manager who does not read code".',
				},
				need: {
					type: 'string',
					description: 'What the reader needs from the text, e.g. "decide whether to merge" or "know the fix landed and what is left".',
				},
				kind: {
					type: 'string',
					enum: ['pr_description', 'review_comment', 'reply', 'fix_confirmation', 'status_report', 'checkpoint_report', 'slack_message', 'linear_comment', 'other'],
					description: 'The kind of text.',
				},
				destination: {
					type: 'string',
					enum: ['github', 'slack', 'linear', 'plain'],
					description: 'Where the text will be posted. "plain" is for reports read in Amp. Defaults to github.',
				},
				facts: {
					type: 'string',
					description: 'Everything the text should say, with exact commits, paths, links, numbers, evidence and verdicts. Notes, a rough draft or an earlier dense version all work.',
				},
				repo: {
					type: 'string',
					description: 'Optional absolute path to a checkout of the code the facts are about, at the commit the facts discuss. The writer reads it to decode terms and may quote short snippets from it.',
				},
				files: {
					type: 'array',
					items: { type: 'string' },
					description: 'Optional files in that checkout where the facts\' terms are defined, relative to repo.',
				},
				media: {
					type: 'array',
					items: {
						type: 'object',
						properties: { url: { type: 'string' }, shows: { type: 'string', description: 'What it shows, e.g. "the error toast after saving".' } },
						required: ['url', 'shows'],
					},
					description: 'Optional screenshots, videos or diagrams, as URLs the reader can open, that the writer may embed as evidence.',
				},
			},
			required: ['reader', 'need', 'kind', 'facts'],
		},
		async execute(input, ctx) {
			const files = Array.isArray(input.files) ? input.files.map(String) : []
			const media = Array.isArray(input.media) ? input.media : []
			const message = [
				`Reader: ${input.reader}`,
				`What they need: ${input.need}`,
				`Kind of text: ${input.kind}`,
				`Destination: ${input.destination ?? 'github'}`,
				...(input.repo ? [`Repository checkout: ${input.repo}`] : []),
				...(files.length ? [`Relevant files: ${files.join(', ')}`] : []),
				...(media.length ? ['Media:', ...media.map((m: any) => `- ${m.url}: ${m.shows}`)] : []),
				'',
				'Facts:',
				String(input.facts),
			].join('\n')
			// createThread rather than writer.run, which fails in orbs with "Orb keepalive is only
			// available to plugins running in an orb" (Amp CLI 0.0.1793445447).
			const thread = await writer.createThread({ parentThreadID: ctx.thread.id })
			ctx.signal.addEventListener('abort', () => void thread.cancel())
			await thread.appendUserMessage({ type: 'user-message', content: message })
			const reply = await thread.waitForResponse()
			return reply.content.flatMap((block) => (block.type === 'text' ? [block.text] : [])).join('\n').trim()
		},
	})
}
