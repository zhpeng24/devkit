# Issue Source and SIES Recovery

## Detect the Contract

Inspect body headings and labels:

| Signal | Interpretation |
|---|---|
| `SIES Goal Contract` / `Evaluation Contract` | Native SIES Issue |
| `用户故事`, `用户场景`, `MVP 定义` | Legacy product Issue |
| `背景`, `预期改动`, `验收标准` | Legacy Engineering Issue |
| Exploration/Prototype/Learning headings | SIES specialized profile |
| No recognizable structure | Unstructured Issue; derive the minimum contract |

Source affects field mapping, not the lifecycle. Do not reject a useful legacy
Issue only because it lacks new headings.

## Recovery Map

| SIES field | Native | Legacy product | Legacy Engineering |
|---|---|---|---|
| Outcome | Outcome | 用户故事 + 预期行为 | 背景 + 预期改动 |
| Success signals | Success signals | 验收标准 | 验收标准 |
| Non-goals/scope | Non-goals / MVP | MVP 定义 | 影响范围 |
| Constraints | Constraints | 边界与约束 | 影响范围 / 关联 |
| Key uncertainties | Key uncertainties | `needs-design` + gaps | gaps in selected change |
| Evidence | Evaluation Contract | 验收标准 + scenarios | failure evidence + 验收标准 |

Acceptance criteria are candidate evidence, not automatically automated tests.
Map each criterion to the cheapest credible observation.

## Minimum Recoverable Contract

When headings are absent, derive:

```markdown
- Outcome:
- Success signal:
- Current decision:
- Known evidence:
- Key unknown:
- Next state:
```

If repository evidence makes these clear, proceed and preserve the derivation
in the next material comment. Ask the user only when a missing answer changes
the Outcome, scope, evaluation, or irreversible impact.

## Evidence Freshness

Evidence is current only when it still matches:

- the latest Goal Contract;
- relevant code/config/dependency state;
- current environment or external contract;
- the decision threshold it was collected for.

Mark stale evidence as superseded. Do not rerun it automatically unless the
decision still depends on it.

## Review Context

A reviewer needs:

- Goal Contract and current Outcome;
- selected direction and rejected material alternatives;
- relevant Evaluation evidence;
- diff or artifact under review;
- verification map and remaining risks.

Legacy Issue bodies may be linked, but extract these fields so the reviewer
does not have to reconstruct the lifecycle.
