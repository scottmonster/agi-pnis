## Assistant

## 1. The updated notes resolve the target shape

The rebuild now needs seven files:

```text
observe/new/
  episode.md
  schema.md
  judgement-record.md
  failure-record.md
  failures.md
  judgement-record/SKILL.md
  failure-record/SKILL.md
```

`schema.md` is now necessary. It is a lightweight, shared data dictionary - not JSON Schema, not a required serialization format, and not a separate procedure.

## 2. Create the shared documents

### 2.1 `episode.md`

Write the shared normative standard from `material.md` and `format.md`.

It needs to define:

- Material episodes and materiality.
- Violation, concern, corrective action, and Episode Investigation.
- When an investigation is required.
- General investigation requirements.
- Shared invariants:
  - Records are immutable.
  - Updates link to the immediately preceding record and retain lineage.
  - Evidence, inference, hypothesis, and unknown information remain distinct.
  - Unavailable information is recorded as a limitation rather than invented.
  - Sensitive or voluminous evidence is referenced or summarized safely.

It must not contain a generic workflow, a skill, failure definitions, or detailed JR/JUR and FR/FUR rules.

### 2.2 `schema.md`

Copy and lightly normalize the updated [`znotes/schema.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/znotes/schema.md) into `observe/new/schema.md`.

It should remain explicitly lightweight:

- It lists information a record can carry.
- Only material fields apply.
- It defines availability states.
- It makes execution context optional unless material.
- It defines common fields, JR/JUR fields, and FR/FUR fields.
- It does not impose JSON, YAML frontmatter, a universal required-field profile, or a report layout.

## 3. Create the domain standards

### 3.1 `judgement-record.md`

Use `material.md` and `schema.md` to define JR and JUR.

It needs to include:

- JR qualification, trigger, and activity rules.
- The constraint that a user-triggered JR is always user-activity.
- JUR qualification and exclusion of mere implementation or successful validation.
- The three JUR outcomes:
  - User-originated judgment updated by user activity - not a violation.
  - User-originated judgment updated by agent activity - concern.
  - Agent-triggered judgment updated by either activity - violation.
- Immutability and update lineage.
- A concise Markdown record template that maps to the judgment portion of `schema.md`.

Do not carry forward MJR/JFR terminology, old index requirements, or mandatory frontmatter from [`judgement_record.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/new/judgement_record.md).

### 3.2 `failure-record.md`

Use `material.md` and `schema.md` to define FR and FUR.

It needs to include:

- Failures are always material and always violations.
- FR versus FUR qualification.
- Immutable update lineage.
- Common FR/FUR data.
- The requirement that a completed failure report has at least one recommended corrective action established through its investigation.
- A concise Markdown record template that maps to the failure portion of `schema.md`.

It must keep failure-specific classification data in `failures.md`, not duplicate it.

### 3.3 `failures.md`

Copy the five updated sample definitions from [`znotes/failures.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/znotes/failures.md).

Apply the shape rules from [`failure-shape.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/znotes/failure-shape.md):

- Stable slug heading as `failure_id`.
- Trigger.
- Exclusions where needed.
- Failure-specific record data.
- Investigation data only.
- No procedure, severity scale, full record template, harness requirements, or embedded root-cause conclusion.

This replaces the old giant failure catalog. Do not port its hundreds of entries.

## 4. Replace the two skills

### 4.1 `judgement-record/SKILL.md`

Rewrite it to use JR/JUR terminology and read:

1. `episode.md`
2. `schema.md`
3. `judgement-record.md`

It must decide JR versus JUR, determine whether an Episode Investigation is required, gather only material and available data, and create the appropriate immutable record.

### 4.2 `failure-record/SKILL.md`

Write the failure entry point to:

1. Consult `failures.md` and match a failure definition.
2. Read `episode.md`, `schema.md`, and `failure-record.md`.
3. Determine FR versus FUR.
4. Determine and perform any required Episode Investigation.
5. Create the record with shared and matched failure-specific data.

## 5. Retire the incompatible rebuild artifacts

The new tree still contains legacy MJR/JFR material and a skill reference to a synchronization-owned legacy document.

These must be removed from the active rebuild or regenerated to reference the new standards:

- [`judgement_record.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/new/judgement_record.md)
- [`judgement-record/purpose.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/new/judgement-record/purpose.md)
- [`judgement-record/ref`](/home/scott/Documents/agi-pnis/gov-lab/observe/new/judgement-record/ref)
- The existing legacy content in [`judgement-record/SKILL.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/new/judgement-record/SKILL.md)

Do not modify the generated `ref/` contents directly. Either remove that legacy packaging or regenerate it after choosing the new canonical policy source.

## 6. Remaining design work

`episode.md` still needs an explicit investigation threshold. The updated notes define what an investigation is and what it must establish, but not the exact decision rule for when it is mandatory.

The standard needs a short rule, for example: investigate whenever the available trigger evidence cannot establish the expected behavior, observed departure, impact, available explanation, and prevention loci well enough to complete the record.

## 7. Verify before adopting

- Every field named in a failure definition has a place in `classification_data`.
- Every update has immediate-parent lineage and ultimate JR or FR lineage.
- The two skills reference only the new standards.
- No active document uses MJR/JFR, `episode-record`, JSON Schema, or the old catalog.
- Preserve [`observe/bad/episodes`](/home/scott/Documents/agi-pnis/gov-lab/observe/bad/episodes) and the archive until the new material is reviewed and adopted.


## User

An **Episode Investigation** is a bounded, evidence-based inquiry into a detected episode that establishes the expected and observed behavior, relevant context and impact, available explanations, and prevention loci. Required for Violations and Concerns.


## Assistant

Yes. This resolves the remaining threshold.

`episode.md` should state:

> An Episode Investigation is required for every Violation and Concern.

The skills then only need to determine whether an event is a violation, concern, or neither:

- Violation - investigate and create the required FR, FUR, or JUR.
- Concern - investigate and create the applicable JUR.
- Neither - no Episode Investigation or episode record.

A completed FR still requires at least one recommended corrective action established through that investigation.

## User

### Status

| Previous Record     | Current Activity   | Status              |
| ------------------- | ------------------ | ------------------- |
| **User-triggered**  | **User-activity**  | **NOT A VIOLATION** |
| **User-triggered**  | **Agent-activity** | **CONCERN**         |
| **Agent-triggered** | **Any activity**   | **VIOLATION**       |

### Interpretation

- **NOT A VIOLATION:** the user materially updates a user-originated judgement.
- **CONCERN:** the agent materially updates a user-originated judgement.
- **VIOLATION:** an agent-triggered judgement requires material correction or update, regardless of whether the later information comes from the user or agent.


## Assistant

This is the governing JUR status rule.

A JUR requires an Episode Investigation only when its status is `CONCERN` or `VIOLATION`.

- User activity updating a user-triggered judgement creates a JUR but does not require an investigation.
- Agent activity updating a user-triggered judgement is a concern and requires an investigation.
- Any update to an agent-triggered judgement is a violation and requires an investigation.

The JUR must still be created for every material update and linked to its immediately preceding JR or JUR.




