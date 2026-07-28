---
name: humanizing-writing
description: Use when rewriting or reviewing Chinese or English prose that sounds AI-generated, formulaic, overly polished, promotional, generic, or unlike the author's voice, including everyday writing, technical documentation, and pull request descriptions.
---

# Humanizing Writing

## Core Principle

Keep the writer's meaning, evidence, and recognizable voice. Replace only the patterns that make the prose feel generic or manufactured; do not translate unless asked.

## Route the Task

Apply the relevant routes before drafting:

```text
Chinese input -> read references/chinese-patterns.md
English input -> read references/english-patterns.md
Mixed input -> read both only when both prose portions require editing
Everyday writing -> preserve personality and uneven rhythm
Technical documentation -> prefer precise, neutral, current-state wording
PR description -> state problem, actual change, verification, and known risk
```

For Chinese everyday writing, apply the Chinese catalog before drafting: lead with the source's concrete person, place, time, or action, and retain every supported action. Remove a generic significance, promotional outcome, or future-looking claim only when it is both unsupported and merely restates or inflates adjacent concrete actions. Preserve a claim with independent support, named attribution, a citation, or a specific verifiable result; if its status is unclear, ask rather than delete it. Do not replace a removed claim with a softer inferred effect.

## Preservation Contract

Inventory and retain every source-backed fact, name, number, date, quotation, citation, URL, code block, frontmatter field, command, and identifier. Preserve the requested language, document structure, and deliberate author habits when they are supported by samples. Treat a cluster of patterns as evidence; judge an isolated word or punctuation mark in context. Never claim to determine whether a text was AI-authored.

## Calibrate the Voice

Use author samples and explicit tone requests as the primary style guide. Otherwise, match the source's audience and form: let everyday prose retain its personal cadence, keep technical prose direct and factual, and make PR prose operational and reviewable.

## Rewrite Loop

Follow this sequence exactly:

```text
classify -> calibrate -> inventory facts/protected spans -> draft -> audit -> final
```

During `audit`, answer:

1. What still sounds formulaic or machine-shaped?
2. Did the draft add or alter any fact, name, number, date, quotation, citation, URL, code, command, or identifier?

Then review qualitatively for directness, rhythm, reader trust, authenticity, and information density. Do not calculate a numeric score or threshold.

## Output by Invocation Mode

Return a clean rewritten result by default. When the user provides author samples, use them to guide the result. When the user asks for “only the result,” return only the rewritten text. In file mode, preserve paths, frontmatter, headings, links, code, and the file's requested format; summarize changed files only if requested. In embedded mode, preserve surrounding content and edit only the requested span.

## Quick Reference

Produce prose that states the concrete point early, keeps supported details, varies rhythm naturally, and leaves the reader with a credible sense of what is known. For a PR, make the problem, actual change, verification, and known risk easy to find.

## Common Mistakes

Avoid smoothing away a writer's intentional quirks, turning personal prose into a report, or turning technical material into marketing. Preserve uncertainty and missing evidence instead of filling gaps with plausible details.

## Final Check

Deliver the requested language and scope, with protected material unchanged and the chosen scenario's reader needs met. For Chinese everyday prose, make a final separate pass for a cluster of generic framing, promotional outcome claims, or generic industry/future conclusions; if the source supplies only concrete actions and no independent evidence for those claims, remove the whole claim rather than paraphrasing it. Return the output shape the user requested.

## References

Load the routed language catalog before editing prose: `references/chinese-patterns.md` or `references/english-patterns.md`.
