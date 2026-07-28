---
name: image-to-code-skill
description: Use when faithfully implementing a web interface from a supplied screenshot, Figma frame, approved visual reference, or requested exploratory reference.
---

# Image to Code

Treat the reference as a specification. A supplied screenshot, Figma frame, or approved image is authoritative; do not regenerate, restyle, or replace it merely because image generation is available.

If a request calls a reference approved or final but also asks to “capture the vibe,” modernize it, or skip comparison, surface the conflict. Keep the approved source authoritative unless the user explicitly changes that status; do not silently downgrade fidelity to meet a deadline.

## Choose the source

| Reference state | Action |
| --- | --- |
| Supplied or approved | Analyze and implement it faithfully. |
| No authoritative reference; visual exploration requested or materially useful | Propose/generate the smallest useful reference set, then confirm it before treating it as implementation input. |
| Pure image delivery | Route to `imagegen-frontend-web`. |

Never invent business claims, data, testimonials, logos, or asset rights. Preserve existing brand assets and mark unknown content as placeholder content.

## Analyze before coding

View each source at readable resolution. Record its viewport and inventory: section order; containers and grid; alignment and responsive behavior; typography; palette; spacing; radii; borders and shadows; imagery; controls; interactive, loading, empty, and error states. Reuse project assets/components when they match the source.

When a source lacks readable detail, request a clearer reference or create a fresh, task-scoped detail reference with the needed information. Do not crop the authoritative source and mistake the crop for new design authority.

## Implement and compare

1. Inspect the existing stack, routes, tokens, and dependencies. Implement in that stack; do not default to React, Next, Tailwind, or a replacement design system.
2. Build geometry first, then type, color, spacing, imagery, controls, and states. Keep semantics, keyboard access, contrast, reduced motion, and responsive behavior intact.
3. Render the target route at the source viewport and compare side-by-side or with an overlay. Fix measurable differences in layout, type scale/line breaks, spacing, color, borders, and assets. Check responsive variants deliberately rather than extrapolating from one viewport.
4. Run relevant project build/lint/tests and report both command results and any fidelity gaps or unavailable assets.

## Delivery

Report the authoritative source and viewport, files changed, comparison method/results, responsive viewports checked, and unresolved assumptions. Fidelity is demonstrated by comparison, not an aesthetic-only claim.

_Adapted from Leonxlnx/taste-skill at `e988add20dab0fa97d7a76781c48961c8184288e`; MIT notice is provided centrally._
