# Visual and PowerPoint Skills Implementation Plan

> **For implementers:** Follow the repository's selected skill-development,
> test-first, task-report, review-package, and scoped-fix workflow. Work directly
> on `main`; the user explicitly authorized it.

**Goal:** Integrate four compact, MIT-attributed Taste-family skills and one
clean-room PowerPoint skill, then repair audit-confirmed discovery and
orchestration defects.

**Architecture:** Five narrow skill entry points share principles but not
runtime ownership. Image-generation skills produce images only;
`image-to-code-skill` translates web references into code; `taste-skill`
guides web design and implementation quality; `pptx` owns PowerPoint artifacts.

**Sources:** See
`docs/specs/2026-07-28-visual-artifact-skills-design.md`.

---

## Task 1: Add web design and image-to-code skills

**Files:**

- Create: `skills/taste-skill/SKILL.md`
- Create: `skills/image-to-code-skill/SKILL.md`

### Step 1: Record behavior before the skills exist

Use fresh-context controls for:

1. a redesign request in an existing Vue project with supplied brand tokens;
2. a screenshot-to-code request where the supplied screenshot is authoritative.

Record whether the controls default to React/Next, overwrite the supplied
system, regenerate the source, or skip source/fidelity analysis. Keep the report
under the ignored SDD task workspace.

### Step 2: Implement `taste-skill`

Frontmatter name must be `taste-skill`; description must begin `Use when`.

Required behavior:

- narrow scope to visually expressive web pages and redesigns;
- inspect brief, audience, source assets, existing stack, and constraints;
- audit before changing an existing UI;
- define a contextual visual grammar rather than a fixed aesthetic;
- treat existing design systems and user assets as authoritative;
- keep accessibility, responsiveness, reduced motion, states, dependency
  verification, asset rights, and real-content honesty;
- avoid framework lock-in and generic AI layout defaults;
- route pure image work and image-to-code work to their owning skills.

Do not reference a nonexistent block library.

### Step 3: Implement `image-to-code-skill`

Frontmatter name must be `image-to-code-skill`; description must begin
`Use when`.

Required behavior:

- supplied screenshots/Figma/approved images remain the source of truth;
- generate references only when no authoritative reference exists and visual
  exploration is actually requested or useful;
- inspect images at readable resolution;
- inventory viewport, sections, layout, typography, color, spacing, radii,
  shadows, imagery, controls, and states before coding;
- implement in the existing project stack;
- compare rendered output at the source viewport and responsive variants;
- generate a fresh detail reference rather than cropping when needed;
- do not invent business claims, data, testimonials, or asset rights.

### Step 4: Forward-test and refine

Run fresh-context versions of both controls after loading the new skill. Patch
only observed gaps. Expected:

- the Vue redesign preserves stack and supplied tokens;
- the screenshot workflow does not regenerate an authoritative source;
- both outputs include concrete verification, not an aesthetic-only claim.

### Step 5: Validate and commit

Run the official quick validator for both skills, `git diff --check`, and the
repository validator. README discovery failure is expected until Task 4.

Commit: `feat: add visual web workflow skills`

---

## Task 2: Add image-only web and mobile skills

**Files:**

- Create: `skills/imagegen-frontend-web/SKILL.md`
- Create: `skills/imagegen-frontend-mobile/SKILL.md`

### Step 1: Record behavior before the skills exist

Use fresh-context controls:

1. request one implementation-ready website hero concept;
2. request three frame-free native mobile flow screens.

Record unwanted code output, arbitrary six/eight-image expansion, web/mobile
scope confusion, unreadable text, or forced device frames.

### Step 2: Implement the web image skill

Frontmatter name must be `imagegen-frontend-web`.

Required behavior:

- image-only website references; never switch to code;
- choose the smallest readable set that covers requested sections;
- one independent image per section when separation improves readability;
- maintain one design bible across a set while varying composition by section;
- keep section purpose, copy hierarchy, conversion path, media direction,
  implementation clarity, and small-laptop readability;
- avoid hard default section counts and generic AI composition.

### Step 3: Implement the mobile image skill

Frontmatter name must be `imagegen-frontend-mobile`.

Required behavior:

- image-only native mobile screens and flows;
- choose iOS, Android, or cross-platform rules from the brief;
- honor safe areas, native navigation, reachable controls, readable type,
  platform patterns, flow logic, and set consistency;
- use a device frame only when presentation context benefits; omit it for
  frame-free implementation references;
- generate the requested/minimum useful screens without arbitrary expansion;
- never output SwiftUI, React Native, Flutter, HTML, or web layouts.

### Step 4: Forward-test and refine

Expected:

- one requested web hero remains one image and no code;
- three requested frame-free mobile screens remain three coherent,
  implementation-readable images and no code.

Do not invoke expensive image generation for validation; fresh agents may
describe the exact tool actions and deliverable contract without calling the
image tool.

### Step 5: Validate and commit

Run the official quick validator for both skills, `git diff --check`, and the
repository validator. README discovery failure is expected until Task 4.

Commit: `feat: add frontend image generation skills`

---

## Task 3: Add a clean-room PowerPoint skill

**Files:**

- Create: `skills/pptx/SKILL.md`

### Step 1: Preserve the clean-room boundary

Do not copy, translate, rearrange, or vendor any Anthropic PPTX prose, scripts,
schemas, or assets. Use only the design contract and public tool/file-format
knowledge.

Record a fresh-context control for: “Edit quarterly-review.pptx using its
template, preserve the original, and verify the result.” Note whether it would
overwrite the input, assume unavailable tools, or skip rendered inspection.

### Step 2: Implement the workflow

Frontmatter name must be `pptx`; description must begin `Use when` and narrowly
mention PowerPoint `.pptx`/`.potx` artifacts.

Required sections:

- route create, inspect/read, and edit/template modes;
- choose project-compatible PptxGenJS, python-pptx, Open XML tooling, or an
  existing project library after preflight;
- preserve the source and write to an explicit output path;
- preserve templates, masters, layouts, relationships, notes, media, and
  unsupported features conservatively;
- use task-scoped temporary directories and safe archive handling;
- check ZIP integrity and core PresentationML parts;
- extract and compare required content;
- render to PDF/images with an available renderer and inspect every slide;
- report missing tools or unverified Office fidelity honestly;
- avoid fake citations, data, logos, and unlicensed assets.

### Step 3: Forward-test and refine

Fresh-context tests:

1. the edit control above;
2. a new 16:9 five-slide technical deck request with explicit content and no
   installed renderer guaranteed.

Expected:

- explicit non-overwriting output;
- tool preflight and fallback reporting;
- structural, content, and visual QA gates;
- no claim of rendered success when no renderer is available.

### Step 4: Validate and commit

Run the official quick validator, `git diff --check`, and repository validation
with only the expected discovery gap.

Commit: `feat: add clean-room pptx workflow`

---

## Task 4: Integrate discovery, licensing, metadata, and audit repairs

**Files:**

- Create: `THIRD_PARTY_NOTICES.md`
- Modify: `README.md`
- Modify: `skills/using-devkit/SKILL.md`
- Modify: `skills/using-dev/SKILL.md`
- Modify: `skills/using-dev/references/orchestration-cheatsheet.md`
- Modify: `scripts/validate.sh`
- Modify: `plugin.json`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `gemini-extension.json`

### Step 1: Add third-party notices

Include the full MIT copyright and permission notices for:

- Leonxlnx, Taste Skill, 2026;
- Siqi Chen, Humanizer, 2025;
- Hardik Pandya, Stop Slop, 2025.

Identify the adapted file families and source URLs. Add a short clean-room note
that no Anthropic PPTX material is distributed; do not copy its restricted
license text.

### Step 2: Add discovery and public documentation

List all five skills in the README table and `using-devkit` table. Add concise
README capability sections and update the skill tree. Link
`THIRD_PARTY_NOTICES.md` from the license section.

Update plugin/marketplace/Gemini descriptions from the obsolete
Python-only wording to the actual toolkit scope. Keep versions synchronized;
do not bump a version unless existing project policy requires it.

### Step 3: Repair `using-dev`

Remove mandatory routing to unavailable `architecture-designer`,
`self-improving`, and `debug-pro`.

Use capability-aware routes:

- architecture: `brainstorming`/`writing-plans` when available, plus the local
  ADR process;
- debugging: `systematic-debugging` when available, otherwise an explicit
  cause-first local fallback;
- completion: `verification-before-completion` when available, otherwise run
  the project tests/checks directly;
- retrospective: local `references/postmortem.md`, not a nonexistent skill.

Honor an explicit user request to skip issue/design ceremony while retaining
safe verification. Update the orchestration cheatsheet consistently.

### Step 4: Strengthen repository validation test-first

Before adding the new checks, demonstrate that the current validator misses:

- a skill-local missing `references/...` target;
- a skill absent from `using-devkit`.

Add checks that:

- every relative Markdown link and inline `references/`, `scripts/`, or
  `assets/` path in each `SKILL.md` exists;
- every skill except `using-devkit` appears in `using-devkit`;
- existing README discovery remains enforced.

Use a temporary probe skill to prove the new validator fails for both defects,
then remove the probe and prove the real repository passes. Do not use
destructive Git reset/checkout cleanup.

### Step 5: Audit deletion decision

Record the evidence-backed result: no tracked skill or platform-support file is
safe to delete. Keep distinct entry points, live references, manifests, hooks,
installers, and historical design records. Do not delete files based only on
age, size, or similar names.

### Step 6: Validate and commit

Run `npm test`, shell syntax validation, `git diff --check`, and the official
quick validator for all five new skills plus `humanizing-writing`.

Commit: `docs: integrate visual artifact skills`

---

## Task 5: Run holistic behavioral evaluation

**Files:**

- Modify only if an observed failure requires it:
  - `skills/taste-skill/SKILL.md`
  - `skills/image-to-code-skill/SKILL.md`
  - `skills/imagegen-frontend-web/SKILL.md`
  - `skills/imagegen-frontend-mobile/SKILL.md`
  - `skills/pptx/SKILL.md`
  - discovery/validation files owned by Task 4

### Step 1: Run five fresh-context scenarios

One per skill, with full skill-file reads and no shared conversational context.
Record prompt, output, and pass/fail in the ignored task report.

### Step 2: Check routing conflicts

Confirm:

- pure web image work does not produce code;
- mobile image work does not produce web or native implementation code;
- a supplied web reference is not regenerated;
- taste guidance does not override an existing stack/system;
- PowerPoint work preserves input and does not claim unavailable QA.

### Step 3: Patch only observed gaps

Do not add speculative rules. Re-run each failed scenario in a fresh context
until it passes.

### Step 4: Run deterministic verification

Run:

```bash
npm test
scripts/check-humanizing-placeholders.sh
git diff --check
```

Run the official quick validator for all six new/recent skills. Confirm:

- no unresolved local references;
- every skill is discoverable;
- no placeholder markers in the humanizing skill/plan;
- no Anthropic PPTX file, script, schema, or copied notice exists.

### Step 5: Commit observed refinements

Commit only if Task 5 changes tracked files:

`test: verify visual artifact skill behavior`

---

## Final review

Generate a whole-plan review package from the integration merge base through
HEAD. Review requirements, implementation, tests, licensing boundary, routing,
catalog consistency, and audit decisions. Resolve every P0–P2 finding through
the bounded fix/re-review loop, run final verification, then clean the ignored
SDD workspace.
