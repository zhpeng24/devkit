# English pattern guide

## Contents

1. [Content patterns](#1-content-patterns)
2. [Language and grammar patterns](#2-language-and-grammar-patterns)
3. [Style patterns](#3-style-patterns)
4. [Communication artifacts](#4-communication-artifacts)
5. [Filler, hedging, and generic endings](#5-filler-hedging-and-generic-endings)
6. [Binary contrasts, negative staging, and rhetorical setups](#6-binary-contrasts-negative-staging-and-rhetorical-setups)
7. [False agency, narrator distance, and meta-joiners](#7-false-agency-narrator-distance-and-meta-joiners)
8. [False positives](#8-false-positives)
9. [Human-writing signals](#9-human-writing-signals)

Treat these as context-sensitive pattern clusters, not a blacklist. First protect source-backed facts, names, numbers, dates, quotations, citations, URLs, code, document structure, and explicit author habits. A sample or explicit preference outranks these suggestions. Do not infer that a text is AI-written from any pattern.

## 1. Content patterns

- **Inflated significance, legacy, and trends:** “stands as a testament,” “pivotal,” “evolving landscape,” and claims that an ordinary fact marks a broader shift often add scale without evidence. State the concrete fact; retain a supported historical connection or attributed interpretation.
- **Notability and media roll-calls:** Do not use an uncontextualized list of outlets, followers, or “independent coverage” as proof that someone matters. Keep sourced coverage when it explains what was said or reported.
- **Superficial `-ing` analysis:** Trailing “highlighting,” “fostering,” “showcasing,” “ensuring,” or “reflecting” clauses can decorate an action with an unsupported conclusion. Keep the action and any stated, sourced purpose.
- **Promotional description:** “Nestled,” “vibrant,” “renowned,” “breathtaking,” “must-visit,” “rich heritage,” and “profound commitment” usually belong in marketing only when the requested voice and evidence support them.
- **Vague attribution:** Replace “experts say,” “observers note,” and “industry reports” with an actual named, supplied source, or remove the unsupported attribution. Never invent a source.
- **Template challenges/future section:** Do not add “Challenges and future prospects,” a generic obstacle inventory, or optimism that merely fills an outline. Keep actual risks, plans, and dates.

**Example:** `Opened by Mara Chen in 2019, the hotel offers locally sourced breakfasts.` is stronger than a sentence that makes it a vibrant testament to Millbrook's hospitality landscape and says it fosters community.

## 2. Language and grammar patterns

- **AI vocabulary clusters:** Watch for piled-up words such as *additionally, align, crucial, delve, enduring, enhance, foster, garner, highlight, intricate, key, landscape, pivotal, showcase, tapestry, testament, underscore, valuable,* and *vibrant*. Prefer the precise ordinary word when it says more; do not purge formal vocabulary used accurately.
- **Copula avoidance:** “serves as,” “stands as,” “marks,” “represents,” “boasts,” “features,” and “offers” can obscure a plain `is`, `has`, or direct verb. Use the simpler construction when it improves clarity.
- **Elegant variation and false ranges:** Do not rotate one subject through synonyms to avoid repetition, or use “from X to Y” when X and Y are not ends of a real scale. Repeat the accurate name and list the actual topics.
- **Passive voice and subjectless fragments:** Prefer a known actor when active voice makes responsibility clearer; expand fragments such as “No configuration needed.” Do not invent an actor, and retain passive voice when it is conventional, necessary, or the actor is genuinely unknown.
- **Hyphenated-pair overuse:** Keep conventional and attributive compounds (`a high-quality report`); consider unhyphenated predicate forms (`the report is high quality`). Do not mechanically rewrite technical terms.

**Example:** `The team stores the results automatically.` is clearer than `The results are preserved automatically.` only if the team or system is supplied by the source.

## 3. Style patterns

- **Rule-of-three, negative parallelism, and false symmetry:** Do not force two facts into three items or dress a simple point in “not only ... but also.” Use the source's real count and relation.
- **Em/en dashes, bold, inline-header lists, title case, emoji, and curly quotes:** These can become a uniform generated presentation. Simplify only when they form a distracting cluster or conflict with the requested format. Preserve deliberate dashes, quotation style, headings, formatting, and author samples; do not impose straight quotes or sentence-case headings by default.
- **Fragmented headers and diff-anchored prose:** A heading need not be followed by a sentence that repeats it. Outside release notes, changelogs, and migration guides, describe the present behavior rather than narrating the last diff.
- **Manufactured punchlines, staccato drama, and aphorism formulas:** Avoid a run of clipped “landing” sentences or vague formulas like “X is the currency of Y.” A single short sentence, a memorable line, or deliberate lyricism may be the writer's voice.

**Example:** Under `## Performance`, begin with the measured behavior or constraint, not `Speed matters.` Then avoid turning every following sentence into a dramatic fragment.

## 4. Communication artifacts

- **Collaborative assistant residue:** Remove “Of course,” “I hope this helps,” “Would you like me to continue?,” and “Here is an overview” when the requested output is the prose itself. Keep genuine letters, salutations, sign-offs, and dialogue.
- **Knowledge-cutoff disclaimers and speculative gap-filling:** Do not explain a model's limits, use “as of my training,” or turn missing biographical information into guesses about privacy, upbringing, or motives. State that the supplied source does not establish a fact only when that absence matters.
- **Sycophancy:** Cut performative agreement such as “Great question” or “You are absolutely right” unless it is real interpersonal correspondence the user wants preserved.

**Example:** Replace `Here is what you need to know. I hope this helps!` with the first substantive sentence.

## 5. Filler, hedging, and generic endings

- **Throat-clearing and signposting:** Cut announcements such as “here's the thing,” “let's dive in,” “without further ado,” “in this section,” and “the rest of this essay.” Start with the point.
- **Emphasis crutches and business jargon:** Question “full stop,” “let that sink in,” “make no mistake,” and vague phrases such as “game-changer,” “deep dive,” “moving forward,” or “circle back.” Replace them with the supplied action or plain language.
- **Filler and excessive hedging:** Tighten “in order to,” “due to the fact that,” “at this point in time,” and stacks such as “could potentially possibly.” Preserve qualifications that express real uncertainty, scope, politeness, legal care, or the author's voice. Never ban adverbs wholesale.
- **Persuasive authority and vague declaratives:** “At its core,” “what really matters,” “the stakes are high,” and “the reasons are structural” can announce depth without providing it. Name the specific reason or consequence when supplied.
- **Generic positive conclusions:** Do not end with “the future looks bright,” “exciting times lie ahead,” or a generic “step in the right direction.” End on the last supported fact unless the source states a concrete next step.

**Example:** `The company will publish the audit in September.` is a credible ending; `Its future looks bright.` is not evidence.

## 6. Binary contrasts, negative staging, and rhetorical setups

- **Binary contrasts and negative listings:** “Not X, but Y,” “X isn't the problem; Y is,” “not just,” and a sequence of things something is *not* create a predictable reveal. State the supported point directly. Retain contrast where the negation is necessary to preserve meaning, a quote, a deliberate author habit, or a real correction.
- **Tailing negations:** Turn fragments such as `no guessing` into a clear clause when needed, rather than tacking them on as a slogan.
- **Rhetorical setups and conversational hooks:** Do not use “What if ...?”, “Think about it,” “And that's okay,” “Honestly?”, “Look,” “Here's the thing,” or “The thing is” as theatrical runway before an ordinary claim. The same words can be natural mid-sentence or in dialogue.
- **Formulaic constructions:** Question template arcs such as “By the time X, I was Y” and indirect `X that isn't Y` phrasing only when they obscure a simpler concrete statement.

**Example:** Replace `It is not just a breakfast; it is a commitment to community.` with the supported fact: `The hotel serves locally sourced breakfasts.`

## 7. False agency, narrator distance, and meta-joiners

- **False agency:** Do not let complaints “become” fixes, decisions “emerge,” data “tell us,” markets “reward,” or cultures “shift” when this conceals the people making choices. Name a supplied actor or use a neutral construction when none is known; do not invent a person merely to force active voice.
- **Narrator-from-a-distance:** Replace floating generalizations such as “Nobody designed this,” “This happens because,” or “People tend to” with the actual actor, scene, mechanism, or bounded observation when the source provides one. Do not force `you` into formal, technical, or third-person prose.
- **Meta-joiners and performative sincerity:** Remove self-referential connectors (“as we'll see,” “let me walk you through,” “but that's another post”), “hint/spoiler,” “I promise,” and claims that something “actually matters” when they substitute for content.

**Example:** Instead of `The data tells us the policy works, and the rest of this essay explains why,` write the supplied finding and its source or method.

## 8. False positives

Do not treat any isolated word, construction, or punctuation mark as a defect. In particular, do not automatically change:

- polished grammar; mixed casual and formal registers; dry or academic prose; a formal word used precisely; common transition words used once;
- salutations, sign-offs, quotations, titles, proper names, examples that discuss a watched phrase, or correct complex formatting;
- curly quotes, an em dash, a parenthesis, a short emphatic sentence, a Wh- opener, passive voice, an inanimate subject, an adverb, or a three-item list when it is meaningful or matches an explicit author sample;
- unsupported claims solely because they are unsourced. Preserve source content unless the requested edit calls for unsupported promotional, speculative, or generic inflation to be removed; never replace it with a new claim.

Look for a cluster that obscures meaning or manufactures importance. Preserve required style, genre conventions, technical precision, quotations, and deliberate personal cadence.

## 9. Human-writing signals

Lean toward preserving specific, unusual, hard-to-fabricate detail; mixed feelings and unresolved tension; dated or subcultural references; defensible first-person choices; varied sentence length; genuine asides, parentheticals, and self-corrections; and text demonstrably written before 30 November 2022. These are reasons to edit lightly, not proof of authorship.

**Example:** `I liked it, although I still cannot say why.` may be the most honest ending. Do not replace it with a neat conclusion.

## Attribution

Adapted from [blader/humanizer](https://github.com/blader/humanizer/blob/main/SKILL.md), version 2.9.1, and [hardikpandya/stop-slop](https://github.com/hardikpandya/stop-slop), both licensed under the MIT License. Humanizer's catalog is based on Wikipedia's "Signs of AI writing" guide.
