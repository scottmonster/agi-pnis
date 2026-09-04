---
name: judgement-record
description: Create or update a material Judgement Record (JR) or Judgement Update Record (JUR) using the episode and judgement-record standards.
disable-model-invocation: true
---

# Judgement Record

Use this skill when work establishes a material judgement or later material information changes an existing JR or JUR.

## 1. Read the standards

Before classifying or creating a record, read these files in order:

1. `../../gov/policy/execution/episodes/episode.md`
2. `../../gov/policy/execution/episodes/schema.md`
3. `../../gov/policy/execution/episodes/judgement-record.md`

Use the YAML blocks as a data dictionary and concise template notation. They do not require YAML serialization or frontmatter.

## 2. Determine the record type

- Create a JR when the judgement is discretionary, governing, and material. Authority and completion-boundary information is recorded only when material; neither blocks an otherwise qualifying JR.
- Create a JUR only when later material information changes, corrects, supplements, or identifies an error in the immediately preceding JR or JUR.
- Do not create a JUR for implementation or validation that leaves the judgement materially unchanged.
- Record a user-triggered JR as user-activity. Do not record it as agent-activity.
- For routine work, active discussion, an open question, a recommendation, a direct instruction, an ordinary implementation choice, or an ordinary test result, create no JR unless the standard independently establishes that it qualifies.

## 3. Determine JUR status and investigation

For every JUR, inspect the trigger on the immediately preceding record and the current update's activity:

| Previous record | Current activity | Status | Episode Investigation |
| --- | --- | --- | --- |
| User-triggered | User-activity | Not a violation | Not required |
| User-triggered | Agent-activity | Concern | Required |
| Agent-triggered | Any activity | Violation | Required |

For a concern or Violation, perform an Episode Investigation. Establish expected and observed behavior, relevant context and impact, available explanations, and prevention loci. Record JUR prevention loci in `investigation.findings.prevention_loci`.

## 4. Create the record

- Use the applicable template in `../../gov/policy/execution/episodes/judgement-record.md`.
- Create `.agents/records/judgements/` if it does not exist, then write `.agents/records/judgements/<record-id>.md`. Do not overwrite a record.
- Record only material, available information. Preserve material limitations using the availability vocabulary in `schema.md`; do not invent information.
- Keep observed facts, inference, assumptions, hypotheses, and unknowns distinct. Safely summarize or reference sensitive or voluminous evidence.
- Create immutable records. A JUR's `update.subject_record_id` identifies the immediately preceding JR or JUR and its lineage reaches a JR.
- A JUR records only material information introduced by the update. Do not copy unchanged judgement information.
- Set JUR `update.assessment` to `not_a_violation`, `concern`, or `violation` as determined above.
- A Violation JUR is complete only when it includes or inherits at least one recommended Corrective Action established through its investigation.

## 5. Preserve authority and history

Attribute authority, contribution, approval, and rationale accurately. Do not represent an agent proposal, assumption, or owner silence as a settled user judgement.

When capturing an earlier judgement, inspect relevant artifacts and preserve missing information as uncertainty rather than inventing it.
