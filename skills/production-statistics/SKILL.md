---
name: production-statistics
description: Use when the user explicitly requests production or live business and operational statistics from a database and the work must remain read-only. Do not use for development, debugging, staging data, deployment, health checks, schema migrations, data repair, or any data-changing task.
---

# Production Statistics

Answer production metric questions with bounded, read-only aggregate queries and
sanitized outputs. Keep this workflow separate from deployment and debugging.

## Trigger gate

Use only when all are true:

- the user explicitly identifies production/live data or an approved production
  reporting source;
- the request defines or implies a metric, time range, or reporting question;
- the result can be produced without changing data or schema.

Do not trigger merely because a development task mentions users, requests, counts,
or a dashboard. Clarify the environment, metric definition, time window, timezone,
filters, and dimensions only when they materially change the result.

## Resolve the data contract

1. Read `.devkit/project.json` and repository reporting docs when present.
2. Resolve the approved production target, database engine, connection mechanism,
   timezone, read-only role, query limits, and approved relations or sanitized
   views. Never guess credentials, hosts, container names, or schemas.
3. Use a dedicated statistics role. Do not reuse an application owner,
   administrator, superuser, deployment account, or shared developer credential.
4. If the read-only role or approved access path does not exist, stop and request a
   separate authorized DBA/deployment task. See
   `references/read-only-database.md`.

Project configuration supplies defaults, not authorization. Keep credentials in
the approved secret channel and out of prompts, commands, repository files,
screenshots, charts, and reports.

## Read-only contract

Allowed:

- `SELECT`, read-only CTEs, `SHOW`, and metadata reads;
- aggregate counts, sums, rates, percentiles, distributions, and bounded trends;
- session-local timeouts and explicit read-only transactions.

Forbidden:

- DML, DDL, procedure calls, grants, role changes, locks, `SELECT ... FOR UPDATE`,
  temporary objects, indexes, refreshes, maintenance commands, or exports of raw
  sensitive records;
- marking, cleaning, backfilling, repairing, or optimizing production data;
- querying with an administrator because the read-only account is inconvenient.

Offer a read-only alternative with filters, `CASE`, CTEs, or aggregate labels when
the user combines statistics with a forbidden mutation.

## Query workflow

1. Define numerator, denominator, entity, event time, inclusive/exclusive bounds,
   timezone, filters, grouping, and whether late-arriving data matters.
2. Inspect unfamiliar schemas through approved metadata reads. Do not inspect git
   merely to infer what production is running.
3. Start an explicit read-only transaction and set short statement, lock, and idle
   timeouts using the database-native equivalent.
4. Prefer indexed time predicates, bounded dimensions, and aggregates. Stop and
   narrow a query that requires an unexplained wide scan or returns raw rows.
5. Sanity-check totals against a second aggregation or known invariant when the
   decision is important.
6. Roll back or end the read-only transaction, then report the metric definition,
   window, timezone, source, aggregate result, data freshness, and caveats.

PostgreSQL shape:

```sql
BEGIN TRANSACTION READ ONLY;
SET LOCAL statement_timeout = '30s';
SET LOCAL lock_timeout = '3s';
SET LOCAL idle_in_transaction_session_timeout = '60s';

-- bounded SELECT-only aggregates

ROLLBACK;
```

## Present the result

| Data shape | Preferred output |
| --- | --- |
| A few headline metrics | KPI table and one concise takeaway. |
| Exact dimensional values | Markdown table with definitions and filters. |
| Time series | Line chart plus table fallback. |
| Category comparison | Bar chart plus table fallback. |
| Part-to-whole with 2–6 categories | Pie or donut only when percentages matter. |
| Composition over time | Stacked bar or area chart with a readable legend. |

Use only sanitized aggregates in charts or rich visual artifacts. Avoid a chart
when it hides caveats, contains too many categories, or has fewer than two
comparable points.

## Report

Lead with the answer. Include exact values, metric definitions, environment,
window, timezone, query summary, limitations, and freshness. Do not paste raw
production records, secrets, full SQL containing sensitive predicates, or claims
that exceed the observed data.

_Generalized from the TongmingLAIC project production-statistics skill at
`acf84fafe17c7264ab74905098745520cde8ad25`; project endpoints, tables, and
credentials are intentionally excluded._
