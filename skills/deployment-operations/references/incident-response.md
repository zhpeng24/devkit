# Incident Response

## Triage loop

1. State the symptom, affected users, environment, and first known time.
2. Reproduce or identify the exact failing probe without broadening impact.
3. Collect bounded read-only evidence: status, readiness, recent logs, rendered
   config, dependency reachability, routing, and host or cluster capacity.
4. Locate the failing layer.
5. Apply the smallest reversible mitigation or fix.
6. Repeat the original probe and one adjacent-layer probe.
7. Record timeline, evidence, action, residual risk, and follow-up.

## Layer map

Move from the user edge inward:

1. DNS, TLS, CDN, load balancer, ingress, or reverse proxy;
2. frontend/static delivery and browser-visible configuration;
3. API or application process;
4. database, cache, queue, object store, or external provider;
5. worker, scheduler, or asynchronous delivery;
6. container runtime, orchestrator, service discovery, mounts, or permissions;
7. host capacity, filesystem, network, or kernel limits.

Do not jump to database repair, service teardown, or infrastructure replacement
before the evidence identifies that layer.

## Common evidence patterns

- **Alive but not ready:** check dependency endpoints, credentials references,
  migrations, and readiness-specific logs.
- **Frontend works but API fails:** inspect routing target, API base configuration,
  CORS/auth boundaries, and the API revision actually serving traffic.
- **New config has no effect:** compare rendered config with the running process and
  recreate or reload only the affected unit.
- **Restart loop:** inspect exit status, bounded logs, resource limits, health-check
  timing, and missing mounts or environment references.
- **Container cannot reach a sibling:** verify network membership and service
  discovery; `127.0.0.1` names the current container, not the sibling.
- **Disk or memory pressure:** identify the owning resource and retention policy
  before deleting data or logs.

## Evidence to report

Report the exact failing probe, failed layer, observed evidence, action taken,
recovery probe, user impact, whether data or secrets were touched, and any
unverified surface. Keep secrets and raw sensitive payloads out of incident notes.
