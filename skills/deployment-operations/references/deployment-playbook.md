# Deployment Playbook

## Source priority

Resolve operational facts in this order:

1. explicit user target and requested outcome;
2. repository `AGENTS.md` and approved deployment or operations docs;
3. `.devkit/project.json`;
4. checked-in manifests, env examples, CI/CD definitions, and runtime state.

Do not use a remembered host, branch, directory, port, or command when the current
source disagrees.

## Project profile mapping

Read these optional objects from `.devkit/project.json`:

| Table | Operational use |
| --- | --- |
| `project` | Canonical workspace, repository identity, primary branch, timezone. |
| `commands` | Project-approved build, target test, regression, and packaging commands. |
| `development` | Supervisor, singleton policy, local services, dependency rules. |
| `environments.<name>` | SSH or cluster target, workdir, branch, manifests, health checks, deploy and rollback defaults. |

Missing values must come from project-native sources or the user. Profile commands
are candidates to inspect, not shell text to execute blindly. Never interpolate
secrets from repository files.

## Runtime selection

### Docker Compose

Preflight:

```bash
docker compose -f <compose-file> config --quiet
docker compose -f <compose-file> ps
docker compose -f <compose-file> logs --tail=100 <service>
```

Deliver the smallest service set:

```bash
docker compose -f <compose-file> up -d --build <service...>
```

Avoid `down --volumes`. Recreate only affected services when environment or mounts
changed. Confirm image IDs or digests as well as container health.

### systemd

```bash
systemctl status <unit> --no-pager
systemctl cat <unit>
journalctl -u <unit> -n 100 --no-pager
systemctl restart <unit>
systemctl is-active <unit>
```

Check whether a user unit or system unit is authoritative before using `--user`.
Reload the daemon only when the unit definition changed.

### Kubernetes

```bash
kubectl config current-context
kubectl -n <namespace> diff -f <manifest>
kubectl -n <namespace> apply -f <manifest>
kubectl -n <namespace> rollout status <kind>/<name>
kubectl -n <namespace> rollout history <kind>/<name>
```

Resolve context and namespace before mutation. Prefer a recorded manifest or image
rollback; do not delete workloads merely to force recreation.

## Verification matrix

Select only checks that observe the goal:

| Layer | Evidence |
| --- | --- |
| Artifact | Commit, package version, image digest, rendered config. |
| Process | Runtime reports active/running and no restart loop. |
| Liveness | Process endpoint responds. |
| Readiness | Required databases, caches, queues, and upstreams are reachable. |
| Routing | Proxy, ingress, DNS, TLS, and service discovery reach the intended revision. |
| User path | One bounded authenticated or unauthenticated scenario matches the request. |
| Observability | Error rate, logs, and resource pressure do not regress during the observation window. |

Do not claim complete visual, authenticated, or external-provider verification when
credentials or tooling were unavailable.

## Rollback points

Before deployment, record the current commit, image digest, package version,
configuration revision, and migration state that matter. A rollback is ready only
when the prior artifact is available and the command to restore it is known.
