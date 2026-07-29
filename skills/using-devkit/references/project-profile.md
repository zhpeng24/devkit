# Devkit Project Profile

## Purpose

Use `.devkit/project.json` for project-specific facts that should not be hardcoded
into reusable skills: canonical paths, native commands, environment targets,
runtime checks, production-statistics boundaries, and report cadence.

The profile is optional and should be committed with the project when its values
are safe to share. Copy `assets/project.example.json` from the `using-devkit`
skill as a starting point.

## Discovery

1. If `DEVKIT_PROJECT_PROFILE` is set, read that exact file.
2. Otherwise resolve the Git repository root and read
   `<repo>/.devkit/project.json`.
3. If neither exists, use repository-native docs, manifests, and tools.

Do not search arbitrary parent directories beyond the repository root. Report a
malformed explicit profile instead of silently selecting another file.

## Precedence and safety

- System/developer instructions, the user's current request, and repository
  `AGENTS.md` remain authoritative.
- The profile supplies defaults and facts; it does not grant credentials, approve
  production mutation, waive confirmation, or expand filesystem/network scope.
- Never store passwords, tokens, private keys, connection strings containing
  secrets, or copied credentials. Store only secret references or credential names.
- Inspect commands before execution. Treat them as project-owned command templates,
  not trusted shell input to evaluate automatically.
- Resolve relative paths from the repository root. Preserve unknown keys for
  forward compatibility but do not invent behavior for them.

## Version 1 objects

| Object | Consumer | Typical values |
| --- | --- | --- |
| Root `schema_version` | All | Must be `1`. |
| `project` | `using-devkit` | Name, timezone, canonical workspace, repository, primary branch. |
| `sies` | `sies-engineering` | Preferred default depth and project success or risk notes. |
| `commands` | Engineering skills | Bootstrap, dev, target tests, regression, lint, typecheck, build, package. |
| `development` | `deployment-operations` | Supervisor, singleton services, dependency policy, fixed ports or tunnels. |
| `environments.<name>` | `deployment-operations` | SSH/cluster target, workdir, branch, runtime manager, manifests, health checks, deploy/rollback commands. |
| `statistics` | `production-statistics` | Approved environment, engine, database, read-only role, access method, timeouts, approved relations. |
| `reporting` | `pptx` | Archive directory, timezone, weekly label rule, tracker, categories, monthly rollup. |

All command fields are arrays so a project can keep separate commands without
shell chaining. Environment names are project-defined, commonly `testing`,
`staging`, and `production`.

`sies.default_depth` is a project preference, not a ceiling. Scope,
uncertainty, blast radius, and reversibility still determine the effective level.

## Consumer behavior

- Read only the tables relevant to the active task.
- Compare profile values with current manifests and live state; surface drift.
- When a value would materially change a live target and conflicts with repository
  docs, stop before mutation and report the conflict.
- Keep project-only hosts, schemas, component names, and reporting labels in the
  project profile or repository docs, not in Devkit skills.
