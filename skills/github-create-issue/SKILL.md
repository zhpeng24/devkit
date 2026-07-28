---
name: github-create-issue
description: Use when a GitHub issue needs to be created for a product goal, exploration, prototype, bug, feature, architecture change, optimization, learning, documentation, security, or tech-debt item.
---

# Adaptive GitHub Issue Creation

Create the smallest Issue that preserves the current SIES decision. Do not
force discovery, experiments, Engineering, and learning into one static
seven-section template.

## Select an Issue Profile

Read `references/issue-profiles.md` and select by the Issue's immediate purpose:

| Purpose | Profile |
|---|---|
| Define a product or system Outcome | Goal / Product |
| Resolve a consequential unknown | Exploration |
| Produce evidence with a minimal artifact | Prototype |
| Deliver a selected solution or repair | Engineering / Bug |
| Propose a reusable system improvement | Learning |

The profile may change as evidence grows. Update or comment on the existing
tracking Issue rather than creating a new Issue for every SIES phase.

## Common Quality Gate

Before creation, confirm:

- **Primary Outcome:** one result owns the Issue, even if it spans several
  phases;
- **Current decision:** the Issue states what must be decided or delivered now;
- **Bounded uncertainty:** unknowns are explicit rather than hidden as facts;
- **Evaluable evidence:** success, failure, or stop can be observed;
- **Traceability:** known Issue, PR, ADR, incident, or user-report links exist;
- **No duplicate:** an existing open Issue does not already own the Outcome.

An Exploration Issue need not be implementation-ready. An Engineering Issue
must be.

## Split by Independence

Create child Issues only when work can be decided, rejected, shipped, or
parallelized independently. A single tracking Issue may legitimately contain
Goal, Exploration, Evaluation, and Engineering history for one Outcome.

## Authorization

- Explicit “create”, “submit”, “直接建” or equivalent language authorizes the
  GitHub write; do not add a duplicate preview gate.
- Draft-only or analysis requests do not authorize creation.
- Ask one question only when a missing answer changes the primary Outcome,
  evaluation, scope, or irreversible impact.

## Labels

Preserve repository labels when they already express the work. Common labels:

`bug`, `feature`, `enhancement`, `architecture`, `optimization`, `innovation`,
`tech-debt`, `documentation`, `security`, `ux`, `needs-design`, and `P0`–`P3`.

Add `sies` or a current-phase label only when the repository benefits from
querying it. Create missing labels only as part of an authorized Issue action.

## Safe Submission

- Sanitize the title to one line.
- Pass generated Markdown through `--body-file`, never command substitution.
- Use the returned URL or structured `gh issue view <url> --json number` output
  for later mutation.

```bash
issue_body_file="$(mktemp)"
trap 'rm -f "$issue_body_file"' EXIT

cat >"$issue_body_file" <<'EOF'
## SIES Goal Contract
...
EOF

gh issue create \
  --title "[module] observable outcome" \
  --label "feature,sies" \
  --body-file "$issue_body_file"
```

After creation, return the URL, selected profile, and next unresolved decision.

## Red Flags

- Filling optional sections with generic prose;
- defining acceptance only as “all tests pass”;
- pretending an unknown solution is already selected;
- splitting every lifecycle phase into a separate Issue;
- mixing independent Outcomes because they share a release date;
- creating GitHub state when the user requested only a draft;
- asking for a preview after the user already authorized direct creation.
