# Visual and PowerPoint Skills Design

Date: 2026-07-28

## Goal

Add five focused Devkit skills:

- `taste-skill`
- `image-to-code-skill`
- `imagegen-frontend-web`
- `imagegen-frontend-mobile`
- `pptx`

The first four are compact Devkit adaptations of the corresponding
`Leonxlnx/taste-skill` pages. The PowerPoint skill is independently written
because the referenced Anthropic material is not redistributable.

## Source and license decisions

### Taste family

Source reviewed at `Leonxlnx/taste-skill` commit
`e988add20dab0fa97d7a76781c48961c8184288e`.

The source is MIT licensed. Devkit will:

- preserve attribution and the full MIT notice;
- adapt the useful workflow ideas instead of copying four 900–1,400-line
  instruction pages;
- omit the upstream `blocks/` convention because those files do not exist;
- turn React/Next/Tailwind choices into contextual examples;
- replace hard image-count defaults with the smallest readable set that meets
  the user's requested scope;
- keep supplied designs, brand rules, accessibility, platform constraints, and
  user instructions above taste defaults.

### PowerPoint

The referenced `anthropics/skills/skills/pptx` directory was reviewed at commit
`b29e7cf65e5cb78a5ac33d582270551bc74a14eb`. Its `LICENSE.txt` prohibits
extraction, retained copies, derivatives, and redistribution.

Devkit will not copy or adapt its prose, scripts, schemas, or directory tree.
`skills/pptx/SKILL.md` will be a clean-room workflow based on public file-format
facts and independently selected tools such as PptxGenJS, python-pptx,
LibreOffice, and standard ZIP/XML checks.

## Skill boundaries

| Skill | Owns | Does not own |
|---|---|---|
| `taste-skill` | Web design inference, redesign audit, visual-system choices, production UI quality | Native mobile, pure image delivery, dashboard/product-flow redesign, PowerPoint |
| `image-to-code-skill` | Supplied/generated web reference analysis and faithful frontend implementation | Pure concept-image delivery, native mobile, unrelated code fixes |
| `imagegen-frontend-web` | Image-only website section concepts and coherent web reference sets | Code generation or mobile app screens |
| `imagegen-frontend-mobile` | Image-only native mobile screens and flows | Websites or SwiftUI/React Native/Flutter implementation |
| `pptx` | Reading, creating, editing, and validating `.pptx`/`.potx` artifacts | Generic web slides, presentation coaching without a PowerPoint artifact |

Routing rules:

1. A supplied screenshot, Figma frame, or approved reference is authoritative;
   do not regenerate it merely because image generation is available.
2. `imagegen-*` skills stop after image delivery.
3. `image-to-code-skill` owns the transition from reference to implementation.
4. `taste-skill` may inform web implementation but must not override the
   project stack, existing design system, accessibility, or explicit brief.
5. `pptx` preserves input files and writes a new output unless the user
   explicitly authorizes overwriting.

## Shared quality contract

The four visual skills should:

- infer audience, page/screen purpose, brand assets, platform, and constraints;
- avoid generic centered-gradient heroes, repetitive equal cards, nested boxes,
  meaningless pills, fake data, fake testimonials, and unlicensed brand assets;
- establish a coherent palette, type hierarchy, spacing rhythm, radii, imagery
  treatment, and motion policy;
- make image count proportional to requested sections or screens;
- preserve readable text, implementation clarity, responsive behavior, reduced
  motion, keyboard use, contrast, and real UI states where applicable;
- verify against the source rather than declaring fidelity from memory.

The PowerPoint skill should:

- select an available library already compatible with the project;
- preflight required runtimes and renderers instead of assuming installation;
- preserve templates, masters, relationships, notes, and unsupported content
  conservatively when editing;
- test ZIP/package integrity and required PresentationML parts;
- extract and compare content;
- render to PDF/images when possible and visually inspect every slide;
- report renderer/tool gaps without claiming successful visual QA.

## Project integration

All five directories use a frontmatter `name` matching the directory, per the
existing validator. Add each skill to:

- `README.md`
- `skills/using-devkit/SKILL.md`

Refresh plugin descriptions so Devkit no longer presents itself as only a
Python/type-safety toolkit.

Create `THIRD_PARTY_NOTICES.md` with the full MIT notices for:

- `Leonxlnx/taste-skill`
- `blader/humanizer`
- `hardikpandya/stop-slop`

Record the PowerPoint clean-room boundary without copying the restricted
license text.

## Repository audit

The existing skills and platform files have active callers or distinct roles.
No tracked file has enough evidence for safe deletion.

Repair instead:

- replace `using-dev` references to unavailable mandatory
  `architecture-designer`, `self-improving`, and `debug-pro` capabilities with
  available or explicit local fallbacks;
- validate local skill references;
- validate that every public skill is discoverable in both README and
  `using-devkit` (except `using-devkit` itself);
- keep cross-platform manifests and bootstrap hooks.

## Acceptance

- All five skills pass the official skill validator.
- After the complete feature batch is implemented, a small set of
  high-information regression checks covers the routing boundaries.
- `npm test`, shell syntax checks, executable-bit checks, local-reference
  checks, discovery checks, placeholder checks, and `git diff --check` pass in
  the final regression.
- The final diff contains no Anthropic PPTX content or derivative scripts.
- Tests are selected for real failure modes and useful assertions; per-file
  repeated full-suite runs and review-agent loops are not required.
