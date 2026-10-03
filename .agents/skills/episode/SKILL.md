---
name: episode
description: Use only when a decision will guide later work, new information significantly changes that decision, or a confirmed problem or failure needs a durable record. Do not use for ordinary work, active discussion, tentative analysis, or unconfirmed concerns.
disable-model-invocation: false
---

# Episode

Use only when a decision will guide later work, new information significantly changes that decision, or a confirmed problem or failure needs a durable record. Do not use for ordinary work, active discussion, tentative analysis, or unconfirmed concerns. The YAML blocks in `src/` describe record structure; they do not require YAML frontmatter or YAML serialization.

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
- Allocate a new JR or FR the next unused three-digit root index in its record directory. Allocate a JUR or FUR the originating JR or FR root index plus the next unused two-digit update index in that lineage. Use the index as the filename prefix and `record.index` value.
- Do not overwrite, alter, or delete an existing record.
- A completed Violation record or chain includes or inherits a recommended Corrective Action established through its Episode Investigation. Every new Corrective Action includes a reusable `rule` and a specific `description`.
