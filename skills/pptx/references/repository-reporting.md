# Repository-Backed Reporting

## Reporting contract

Before collecting data, resolve:

- audience and decision the deck should support;
- weekly, monthly, milestone, architecture, MVP, release, or custom period;
- timezone and inclusive date bounds;
- repository and tracker sources;
- archive directory, prior report, and required output files;
- project vocabulary for Epics, features, bugs, hotfixes, releases, and milestones.

Read `reporting` from `.devkit/project.json` when available. Project settings may
change cadence, labels, tracker, or archive layout. The default weekly convention is
Monday–Sunday, labeled by Friday, using the project timezone. Default archive root is
`docs/reports/`.

## Evidence collection

1. Detect the repository platform from the configured remote.
2. Collect non-merge commits, contributors, and bounded line additions/deletions
   from local git for the exact period.
3. Collect issues, PRs/MRs, milestones, and labels through the platform CLI or API
   when authenticated access exists.
4. Normalize timestamps, states, authors, labels, and identifiers before counting.
   Apply the period to creation, close, and merge timestamps yourself rather than
   trusting a coarse API filter.
5. If tracker access is unavailable, continue with git-only evidence only when that
   can still answer the request. Mark tracker data unavailable in the deck and
   evidence snapshot.

Never place tokens in report sources. Do not invent missing Issues, Epics, business
domains, contributors, metrics, or completion states.

## Durable source bundle

For recurring reports, keep three adjacent artifacts:

```text
report.md   # diffable narrative, plan, risks, and slide outline
data.json   # normalized evidence, definitions, period, and provenance
report.pptx # rendered deliverable
```

The evidence snapshot should include:

- report type, label, timezone, start/end, and generation time;
- repository remote, platform, data-source availability, and source notes;
- commit, contributor, issue, and PR/MR aggregates plus source identifiers;
- category mapping and definitions used for completion ratios;
- caveats and any manually supplied facts.

Keep the source bundle free of secrets and raw personal or production records.
Commit or archive all three together when project policy calls for traceability.

## Metric interpretation

- Exclude merge commits when counting individual delivery commits unless the team
  defines another stable rule.
- Treat lines added/deleted as change-volume evidence, not productivity.
- Keep category mapping stable across periods. Allow multi-label items to appear in
  multiple category views, but disclose that category totals may exceed raw totals.
- Label every ratio with its numerator and denominator, such as “merged PRs / all
  PRs” or “completed Issues / all tracked Issues.”
- Derive next-period plans from open milestones, unresolved work, risks, and
  previous carry-over. Avoid unmeasurable “继续推进” items.
- Do not create a composite health score unless its formula, inputs, and weights are
  explicit and stable across the archive.

## Narrative arcs

### Weekly delivery

1. Outcome-led cover and period.
2. Previous-plan versus actual evidence.
3. Current outcomes and key repository signals.
4. Feature, defect, hotfix, release, or Epic progress as relevant.
5. Risks, blockers, and decisions.
6. Concrete next-period plan.

### Monthly rollup

1. Month outcome and major change.
2. Week-by-week trend and totals.
3. Milestone, Epic, quality, and release movement.
4. Risks and operational lessons.
5. Next-month goals and acceptance signals.

Create a monthly rollup automatically only when the project profile requests it.
Sparse periods should remain sparse; do not pad them with decorative content.

### Architecture, MVP, or project-status report

1. Goal, audience, current stage, and decision required.
2. Confirmed product domains and system boundaries.
3. Architecture and technology choices with evidence and trade-offs.
4. MVP/release scope, milestones, dependencies, and acceptance criteria.
5. Engineering collaboration from goal/Epic to executable work, evaluation, PR/MR,
   CI, regression, and learning.
6. Recent evidence, risks, and next focus.

Use only domains, roles, tools, and milestones confirmed by the repository or user.
Do not repeat obsolete tools merely because they appeared in an older report.

## Archive and continuity

When no project convention exists, use:

```text
docs/reports/
  index.md
  <year>/<weekly-label>/{report.md,data.json,weekly-<label>.pptx}
  <year>/monthly-<yyyy-mm>/{report.md,data.json,monthly-<yyyy-mm>.pptx}
```

Link adjacent recurring reports and read the previous report before authoring
plan-versus-actual. For the first report, state that no predecessor exists instead
of fabricating carry-over.

## Visual rules

- Use one main message per slide and put interpretation in the title or a concise
  callout.
- Prefer editable native charts when practical and always label units and sources.
- Keep exact-value tables available when a chart summarizes auditable metrics.
- Rewrite or split dense prose before shrinking text.
- Use the supplied template or brand system; recurring reports should not be
  redesigned every period.

_Generalized from the TongmingLAIC repository-report skill at
`acf84fafe17c7264ab74905098745520cde8ad25`; fixed project templates and renderer
code are intentionally not included._
