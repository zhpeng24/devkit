---
name: imagegen-frontend-web
description: Use when the requested deliverable is an image-only website concept, section mockup, landing-page comp, or coherent set of web design references.
---

# Frontend Web Image Generation

Generate implementation-readable website references, not code and not generic mood art. Stop after delivering the requested images.

## Set the scope

Read the page purpose, audience, brand material, content, viewport, requested sections, and intended downstream use. Existing brand assets and approved references are authoritative.

Choose the smallest image set that makes the requested design readable:

- one requested hero remains one image;
- separate sections when combining them would make type, spacing, or controls hard to inspect;
- do not expand an unspecified request into an arbitrary six- or eight-section site;
- if a full flow is genuinely required, name the sections before generation.

## Establish one design bible

Keep palette, typography, spacing, radii, borders, imagery treatment, icon style, and tone consistent across the set. Give each section a clear job—hook, explain, prove, compare, or convert—while varying composition intentionally.

Avoid default purple-blue AI gradients, repeated left-copy/right-image sections, equal card rows, nested rounded boxes, decorative pills, fake dashboards, fake logos, testimonials, metrics, or awards. Use only supplied facts and assets with known rights.

## Generate

Use the available image-generation capability. Each prompt should identify:

- exact section and viewport;
- hierarchy and short readable copy;
- grid, focal point, negative space, and CTA placement;
- palette, type character, media treatment, and surface details;
- continuity rules shared with the rest of the set;
- implementation constraints such as visible controls and realistic proportions.

Keep text sparse enough to remain legible. Prefer a fresh standalone image over cropping an earlier render when a section or detail needs its own reference.

## Check and deliver

Inspect every image for readable type, coherent hierarchy, consistent system, unclipped content, plausible website geometry, useful implementation detail, and brand continuity. Regenerate only failed frames.

Return the images in requested order with a short section label. Do not append HTML, CSS, React, or implementation instructions unless the user separately asks to move into an image-to-code workflow.

_Adapted from Leonxlnx/taste-skill at `e988add20dab0fa97d7a76781c48961c8184288e`; MIT notice is provided centrally._
