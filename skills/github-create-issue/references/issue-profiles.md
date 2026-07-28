# SIES Issue Profiles

Use only the sections needed by the selected profile. Common SIES fields may
remain in a tracking Issue as it advances.

## Goal / Product

Use when defining an Outcome before the solution is selected.

```markdown
## SIES Goal Contract
- Outcome:
- Users/scenarios:
- Success signals:
- Non-goals / MVP:
- Constraints and impact:
- Key uncertainties:

## Evaluation Contract
- Decision to make:
- Evidence:
- Pass / fail / stop conditions:

## Relationships
```

**Ready when:** the Outcome is evaluable and the next unknown or Engineering
step is visible.

## Exploration

Use when a consequential decision lacks evidence.

```markdown
## Decision
[What choice must be made?]

## Context and constraints

## Candidate hypotheses
- Option:
  - Expected advantage:
  - Cost/risk:

## Evidence plan
- Evidence:
- Decision threshold:
- Budget/boundary:
- Stop condition:

## Output
[Decision record, prototype brief, ADR, or stop recommendation]
```

**Ready when:** the unknown, candidates, evidence, and stop condition are
explicit. Production implementation details are not required.

## Prototype

Use when a minimal artifact must answer a specific question.

```markdown
## Hypothesis

## Prototype boundary
- Included:
- Deliberately excluded:

## Evidence to collect

## Evaluation
- Pass:
- Fail:
- Stop:

## Disposal / promotion rule
[What may be reused, and what must not silently become production code?]
```

**Ready when:** the prototype can produce decision evidence without pretending
to be a complete implementation.

## Engineering / Bug

Use after a direction is selected or when a stable failure mode is already
known.

```markdown
## Goal link
[Goal Contract, parent Issue, incident, or user report]

## Current evidence / failure

## Selected change

## Scope and affected contracts

## Risks and rollout

## Verification map
- Goal or risk:
  - Evidence:
  - Persistent test: yes | no, with reason

## Done
- [ ] Selected behavior is implemented
- [ ] Goal/risk evidence is collected
- [ ] Target tests and delivery regression are recorded
```

**Ready when:** a developer can start without inventing product or architecture
decisions.

## Learning

Use for a proposed reusable improvement, not a routine retrospective.

```markdown
## Observation and evidence

## Affected class of work

## Current system behavior

## Proposed change

## Expected benefit and downside

## Adoption evidence
```

**Ready when:** evidence justifies considering a shared process, skill,
automation, or template change.

## Profile Transition

- Add material evidence as comments using a `SIES: <phase>` heading.
- Edit the Goal Contract when the Outcome changes, and mark old evidence as
  superseded.
- Link independent child Issues rather than copying their bodies.
- Do not create a new Issue solely to represent the next phase.
