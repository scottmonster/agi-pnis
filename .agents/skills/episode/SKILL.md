---
name: episode
description: Use when a governing material judgement is established or materially updated, or a detected material failure requires a record. Do not use for active discussion, routine work, implementation, ordinary validation, execution logs, or tentative analysis.
disable-model-invocation: false
---

# Episode

Use this skill only at a qualifying judgement, update, or detected-failure record boundary. Do not use it for active discussion, routine work, implementation, ordinary validation, execution logs, or tentative analysis. The YAML blocks in `src/` describe record structure; they do not require YAML frontmatter or YAML serialization.

## 1. Read shared standards

Before classifying an episode, read:

1. `src/episode.md`
2. `src/schema.md`

Record only material, available information. Preserve material limitations and keep facts, inferences, hypotheses, and unknowns distinct. Safely summarize or reference sensitive or voluminous evidence.

## 2. Route the episode

For a material judgement or later material update, read `src/judgement-record.md` and follow the JR or JUR route.

For a detected failure or later material failure update, first read `src/failures.md` to match its definition. Then read `src/failure-record.md` and follow the FR or FUR route. If no definition matches, do not invent a failure ID; collect available common information and obtain direction before creating a classified record.

## 3. Apply record-family rules

Determine JR versus JUR, or FR versus FUR, using the applicable source standard.

For each JUR, determine status from the immediately preceding record's trigger and the current update's activity:

| Previous record | Current activity | Status | Episode Investigation |
| --- | --- | --- | --- |
| User-triggered | User-activity | Not a violation | Not required |
| User-triggered | Agent-activity | Concern | Required |
| Agent-triggered | Any activity | Violation | Required |

Perform an Episode Investigation for every Concern and Violation. FRs and FURs are always Violations and require an Episode Investigation.

Create immutable records. A JUR or FUR updates only its immediately preceding record and preserves lineage to the originating JR or FR. Record only the material delta in an update.

## 4. Write the record

Use the applicable template in `src/judgement-record.md` or `src/failure-record.md`.

- For JR and JUR, create `.agents/records/judgements/` when needed and write `<record-id>.md` there.
- For FR and FUR, create `.agents/records/failures/` when needed and write `<record-id>.md` there.
- Do not overwrite, alter, or delete an existing record.
- A completed Violation record or chain includes or inherits a recommended Corrective Action established through its Episode Investigation.
