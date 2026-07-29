# Read-Only Database Access

Provisioning a production statistics account is a separate DBA/deployment change,
not part of a routine statistics request.

## Required properties

- Dedicated login used only for reporting.
- No ownership, administration, role creation, database creation, replication, or
  write privileges.
- Access limited to approved aggregate tables or sanitized reporting views.
- Default read-only transactions plus short statement, lock, and idle timeouts.
- Credentials stored in an approved secret manager or host secret channel.
- Auditability and rotation appropriate to the production environment.

Prefer sanitized views that omit emails, tokens, credential references, IP
addresses, free-form payloads, and other personal or secret data not required by
the metric.

## PostgreSQL DBA-only template

Review identifiers, relations, default privileges, and secret handling before
execution:

```sql
-- DBA-only; never run inside the production-statistics workflow.
CREATE ROLE <stats_role>
  LOGIN
  PASSWORD '<secret-from-approved-channel>'
  NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION;

GRANT CONNECT ON DATABASE <database> TO <stats_role>;
GRANT USAGE ON SCHEMA <reporting_schema> TO <stats_role>;
GRANT SELECT ON <approved_view_or_table>, <another_relation> TO <stats_role>;

ALTER ROLE <stats_role> SET default_transaction_read_only = on;
ALTER ROLE <stats_role> SET statement_timeout = '30s';
ALTER ROLE <stats_role> SET lock_timeout = '3s';
ALTER ROLE <stats_role> SET idle_in_transaction_session_timeout = '60s';
ALTER ROLE <stats_role> SET search_path = <reporting_schema>;
```

Use the database-native equivalent for other engines. Never paste a real password
into the SQL file or shell history.

## Verification

Verify the role identity, read-only defaults, a bounded approved `SELECT`, and
expected failure for representative write, DDL, locking, and unapproved-relation
attempts. Remove any temporary verification object using the DBA account only
after the access review is complete.
