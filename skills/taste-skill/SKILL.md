---
name: taste-skill
description: Use when designing or redesigning a visually expressive web page, campaign, marketing surface, or editorial interface.
---

# Web Design Taste

Create a page-specific visual system, not a copied aesthetic. This skill owns web design direction and implementation quality; it does not own image-only deliverables or reference-to-code fidelity work.

## Scope and routing

Use for expressive web pages and redesigns. Route pure image concepts to `imagegen-frontend-web`; route an approved screenshot, Figma frame, or reference-led implementation to `image-to-code-skill`. Do not use it to redesign product flows, native mobile UI, or to impose a framework.

## Read before changing

1. Inspect the brief: audience, page purpose, conversion/action, real content, success criteria, constraints, and source assets.
2. For an existing UI, audit its routes, components, tokens, breakpoints, states, accessibility, and what users already recognize. Preserve what works before proposing a change.
3. Identify the actual stack, installed dependencies, and local conventions. Keep the existing framework and component system unless the brief explicitly authorizes a change.

Existing design tokens, components, logos, imagery, and brand rules are authoritative. Do not replace them with a personal palette, substitute unlicensed assets, or invent claims, metrics, testimonials, or product data.

## Define the visual grammar

Write a short direction before implementation: hierarchy, palette use, type scale, spacing rhythm, shape/radius, image treatment, density, and motion policy. Make those choices fit the audience and content; avoid generic centered-gradient heroes, uniform card grids, nested containers, decorative pills, and repeated boxed sections when they do not serve the page.

Use purposeful variation in composition while keeping a coherent system. Prefer real content and assets; label unknown content as a placeholder rather than presenting it as fact.

## Build and verify

- Implement in the project stack and verify any dependency before using it; do not default to React, Next, Tailwind, or a new UI kit.
- Cover narrow and wide viewports, keyboard focus, semantic structure, contrast, touch targets, loading/empty/error states where relevant, and `prefers-reduced-motion` for nonessential animation.
- Check images and fonts for license/permission and provide useful fallbacks.
- Run the project’s relevant build/lint/tests, then inspect the rendered page at representative viewports. Compare against the intended hierarchy and grammar, noting concrete issues such as overflow, weak contrast, broken states, or inconsistent tokens.

## Delivery

State the visual direction, files changed, verification commands/results, and any remaining asset or content assumptions. Do not claim quality solely because the result “looks polished.”

_Adapted from Leonxlnx/taste-skill at `e988add20dab0fa97d7a76781c48961c8184288e`; MIT notice is provided centrally._
