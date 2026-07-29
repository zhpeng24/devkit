---
name: deployment-operations
description: Use when planning, executing, diagnosing, verifying, hardening, or rolling back deployments and runtime operations, including releases, Docker Compose, containers, systemd, Kubernetes, health checks, incidents, environment configuration, production or staging troubleshooting, and local development runtime startup.
---

# Deployment Operations

Operate from observed state and an explicit target contract. Prefer the smallest
reversible change that restores or advances the requested outcome.

## Resolve the operating contract

1. Read repository instructions, deployment docs, manifests, environment
   examples, and the optional `.devkit/project.json`.
2. Resolve the target environment, host or cluster, working directory, branch or
   artifact, runtime manager, health probes, and rollback unit.
3. Treat project-profile values as defaults, not authorization. Never infer
   permission for production mutation, data deletion, secret rotation, volume
   removal, migration rollback, or another irreversible action.
4. If target identity is still ambiguous and the next command can affect live
   traffic or data, stop and ask for that target. Read-only discovery can proceed.

Use `references/deployment-playbook.md` for runtime-specific commands and project
profile mappings. Use `references/incident-response.md` for outages and degraded
service.

## Route the request

| Mode | Required outcome |
| --- | --- |
| Plan | Produce a target-specific sequence, evidence gates, rollback point, and stop conditions. |
| Development runtime | Start or reconcile the project-approved local processes and dependencies. |
| Deploy | Deliver a known commit, image, or package and verify user-visible readiness. |
| Diagnose | Locate the failing layer from read-only evidence before changing state. |
| Rollback | Restore a known-good artifact or configuration and repeat the same probes. |
| Harden | Improve secrets, permissions, resource limits, observability, or runbooks without inventing live state. |

## Operate

1. **Preflight.** Inspect worktree state, artifact identity, target reachability,
   runtime configuration, dependencies, capacity, and current health. Validate
   Compose, systemd, or Kubernetes configuration before applying it.
2. **Declare evidence.** Name the exact success probes and the rollback boundary.
   A process being alive is not readiness; include dependency and user-path probes
   when the goal depends on them.
3. **Change one coherent unit.** Update only the requested services or resources.
   Prefer rolling/recreate operations over teardown. Do not use volume deletion,
   force pushes, hard resets, or unreviewed migration reversal as shortcuts.
4. **Verify.** Re-run the failed or target probe, then one upstream and one
   downstream check when applicable. Confirm the deployed commit, image digest,
   package version, or configuration revision.
5. **Record.** Report target, artifact, commands, concise results, data or secrets
   touched, rollback status, and remaining risk. Update the project runbook when
   ports, environment variables, runtime contracts, or operator actions changed.

## Development runtime

- Prefer the canonical workspace, supervisor, service set, ports, and dependency
  policy declared by the project profile or repository docs.
- Inspect existing listeners, working directories, and redacted environments
  before starting new processes. When a project declares singleton services or
  tunnels, reconcile the existing process instead of creating alternate ports.
- Respect environment precedence. Shell variables may override `.env` files;
  verify the running process uses the intended dependency endpoints.
- Do not replace unavailable approved dependencies with local containers or mocks
  unless the project contract or user explicitly allows that fallback.
- Keep frontends, APIs, workers, and tunnels on the same approved checkout and
  environment boundary.

## Rollback

Identify whether rollback means an image, package, commit, configuration, feature
flag, or database migration. Restore the smallest known-good unit and preserve the
failed artifact and evidence for diagnosis. Database and data rollbacks require an
explicit reviewed plan; do not improvise a down migration.

## Red flags

- Guessing the production host, cluster, directory, branch, namespace, or compose file.
- Treating `healthz` as proof that dependencies and user flows are ready.
- Dumping complete environments, secrets, tokens, or unbounded logs into output.
- Restarting every service when one bounded service changed.
- Using teardown or data deletion to solve a configuration problem.
- Declaring recovery without repeating the original failing probe.

_Generalized from the TongmingLAIC project deployment skill at
`acf84fafe17c7264ab74905098745520cde8ad25`; project-specific endpoints and
runtime rules are intentionally excluded._
