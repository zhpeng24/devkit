---
name: pptx
description: Use when reading, creating, editing, or validating a Microsoft PowerPoint .pptx or .potx artifact, including repository-backed weekly, monthly, project-status, architecture, MVP, release, and executive report decks.
---

# PowerPoint Artifacts

Work on the PowerPoint file itself. Preserve source artifacts, choose tools from the actual environment, and verify structure, content, and rendered slides before claiming completion.

## Route the task

| Mode | Goal |
| --- | --- |
| Inspect/read | Extract slide order, text, notes, media, layouts, and document properties without changing the file. |
| Create | Build a new deck from supplied content, brand rules, and an explicit slide outline. |
| Edit/template | Use the supplied deck or template, preserve its masters and layout language, and write a new output file. |
| Repository report | Build a weekly, monthly, project-status, architecture, MVP, or release deck from traceable repository evidence. |

Generic presentation advice without a `.pptx` or `.potx` deliverable is outside this skill.

## Preflight

1. Resolve the input and explicit output paths. Never overwrite the input unless the user clearly authorizes it.
2. Inspect the project for an existing PowerPoint library and lockfile.
3. Use a compatible installed option—such as PptxGenJS, python-pptx, or Open XML tooling—rather than assuming a package is present. Add and pin a dependency only when normal project work authorizes it.
4. Detect renderers independently. LibreOffice, PowerPoint, or another renderer may be absent; record that limitation instead of claiming visual verification.
5. Use a task-scoped temporary directory for extracted or rendered files. Reject archive entries that escape it.
6. For repository reports, read `.devkit/project.json` and
   `references/repository-reporting.md` before collecting data or choosing cadence.

## Inspect or edit

Treat `.pptx` as an Open Packaging Convention ZIP package. Before editing, inventory slide order, size, masters, layouts, theme, relationships, notes, comments, charts, media, and embedded objects.

Prefer library-level operations. Preserve unfamiliar or unsupported parts and their relationships rather than rebuilding the package from a lossy subset. When a requested edit risks dropping animation, charts, embedded media, macros, or template behavior, state the risk before changing it.

For template work, use existing masters/layouts and brand assets. Do not flatten the deck into screenshots or recreate logos, charts, citations, or numbers from memory.

## Create

Start with an outline that maps one main message to each slide. Set the slide size, theme fonts, palette, margins, and reusable layouts before adding content.

Use concise titles, readable body text, visual evidence that supports the point, and consistent alignment. Keep charts honest, label units and sources, provide useful alt text where tooling permits, and avoid fake data or decorative clutter.

## Repository reports

Separate evidence collection, narrative authoring, and deck rendering:

1. Resolve the reporting period, audience, tracker, archive location, categories,
   and cadence from the user, repository history, and optional project profile.
2. Gather repository and tracker evidence. Degrade transparently when an API or
   credential is unavailable; never make a partial deck look complete.
3. Preserve a diffable narrative source and a machine-readable evidence snapshot
   next to the deck when the project expects recurring reports.
4. Compare the previous period's plan with current evidence before writing the
   next plan. Keep plan items concrete enough to evaluate in the next report.
5. Choose a narrative arc that matches the report: weekly delivery, monthly
   rollup, or early-stage architecture/MVP. Do not force every report into one
   fixed slide order.

Use `references/repository-reporting.md` for data provenance, metric interpretation,
archive defaults, and report-specific narrative structures. Project parameters
override those defaults when they remain compatible with the user's request.

## Verify

Completion requires all applicable gates:

1. **Package:** ZIP integrity passes; `[Content_Types].xml`, `_rels/.rels`, `ppt/presentation.xml`, referenced slide parts, and relationships exist.
2. **Content:** extract slide text and notes; compare names, numbers, dates, citations, and required sections with the source.
3. **Visual:** render every slide to PDF or images with an available renderer, inspect each page for clipping, overlap, font substitution, contrast, unreadable text, broken media, and off-slide objects.
4. **Behavior:** reopen the output with an independent compatible application when practical; note features that were not verified in Microsoft PowerPoint.

If rendering is unavailable, structural and content checks may still pass, but visual QA remains unverified. Say so plainly.

## Delivery

Return the new `.pptx` path, tools and versions used, validation results, render location if any, and unresolved fidelity or compatibility risks. Keep the original file unchanged.

This is an independently written Devkit workflow based on public PowerPoint and PresentationML concepts. It does not include or derive from restricted third-party PPTX skill files.
