---
name: imagegen-frontend-mobile
description: Use when the requested deliverable is an image-only native mobile screen, app concept, or coherent iOS, Android, or cross-platform flow.
---

# Frontend Mobile Image Generation

Generate native-feeling mobile screen images and flows. This skill produces images only; it does not write SwiftUI, React Native, Flutter, HTML, or other implementation code.

## Define the flow

Identify the platform, device class, audience, product task, entry state, requested screens, navigation model, brand material, and whether the images are presentation comps or frame-free implementation references.

Use exactly the requested screens when the user gives a count. Otherwise choose the minimum set needed to explain the flow; do not add filler screens. State the screen order before generation.

## Keep one product system

Maintain a shared palette, type scale, spacing rhythm, component language, icon treatment, imagery style, navigation, and elevation model. Vary screen composition according to its job without letting the set drift into different products.

Respect platform conventions:

- safe areas, status/navigation regions, and keyboard states;
- native navigation and back behavior;
- touch targets, reachable primary actions, readable type, and clear hierarchy;
- believable loading, empty, error, permission, and success states when relevant.

Avoid phone-sized websites, random charts, floating-card clutter, pill overload, unreadable microcopy, fake complexity, generic purple-blue gradients, and inconsistent device frames. Do not invent product data, claims, logos, or permissions.

## Generate

Use the available image-generation capability. Give each screen its own clear prompt with platform, dimensions, state, content hierarchy, navigation context, visual-system rules, and relationship to adjacent screens.

Use a subtle device frame only for presentation context. When the user asks for frame-free or implementation-ready screens, render the screen itself edge to edge. Create a fresh screen or detail image instead of cropping an earlier result.

## Check and deliver

Inspect every output for safe-area correctness, readable text, touch geometry, logical transitions, consistent navigation, palette and components, unclipped content, even framing, and clear screen identity. Regenerate only failed screens.

Return the images in flow order with concise screen names. Stop before code.

_Adapted from Leonxlnx/taste-skill at `e988add20dab0fa97d7a76781c48961c8184288e`; MIT notice is provided centrally._
