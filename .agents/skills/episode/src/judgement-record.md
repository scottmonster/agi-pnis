# Judgement Records

## 1. Scope and storage

A Judgement Record (JR) preserves a material, non-obvious exercise of discretion that governs future work within an explicit scope.

A Judgement Update Record (JUR) preserves later material information that changes, corrects, supplements, or identifies an error in a JR or JUR.

Each JR and JUR is one Markdown file in `.agents/records/judgements/`. A JR filename is `<root-index>-JR-<slug>.md`, such as `001-JR-access-rule.md`. A JUR filename is `<root-index>.<update-index>-JUR-<slug>.md`, such as `001.00-JUR-access-rule-corrected.md`. Root indexes have three digits and update indexes have two digits. The skill creates the directory when needed. Records are immutable and their files are the canonical record.

`record.index` matches the filename prefix. A JUR uses the root index of its originating JR and the next unused update index for that lineage. `record.id` remains the stable relationship identifier.

Use [episode.md](episode.md) for shared requirements and [schema.md](schema.md) for the data dictionary.

## 2. JR qualification

Create a JR when all conditions hold:

- It required non-obvious interpretation, assumption, tradeoff, conflict resolution, or choice.
- It governs future work by constraining, authorizing, prohibiting, prioritizing, interpreting, or setting a meaningful default.
- It is material. Losing it or its rationale would risk repeated debate, inconsistent work, mistaken authority, costly reversal, or misunderstanding of history.

Actual or delegated authority and a durable completion boundary do not determine whether a JR qualifies. Record them in `basis`, `scope`, `rationale`, or contextual text only when they materially explain the judgement.

Do not create a JR for an open question, direct instruction, routine implementation choice, execution log, ordinary test result, tentative discussion, private reasoning, or recommendation that does not govern work.

The `judgement` group records the judgement. `basis`, `scope`, and `rationale` may include authority, material alternatives, tradeoffs, direction, outcome, and context only when they are needed to understand the judgement. Those details are not separately required fields.

### 2.1 Trigger and activity

A JR is user-triggered when the user explicitly requests that a material judgement be recorded. A user-triggered JR is always user-activity.

A JR is agent-triggered when the agent determines that an interaction establishes or requires a material judgement. An agent-triggered JR may arise from user-activity or agent-activity.

Do not present an agent proposal, assumption, or a user's silence as a settled user judgement. Preserve uncertainty rather than inventing authority, rationale, or evidence.

## 3. JUR qualification, status, and lineage

Create a JUR when later material information changes, corrects, supplements, or identifies an error in the immediately preceding JR or JUR.

Do not create a JUR for implementation or successful validation that leaves the preceding judgement materially unchanged.

A JUR links to its immediately preceding record with `update.subject_record_id`; its chain ultimately reaches a JR. It records only material information introduced by the update, not a copy of the preceding record.

Determine status from the immediately preceding record's trigger and the current update's activity:

| Previous record | Current activity | Status | Episode Investigation |
| --- | --- | --- | --- |
| User-triggered | User-activity | Not a violation | Not required |
| User-triggered | Agent-activity | Concern | Required |
| Agent-triggered | Any activity | Violation | Required |

A concern or Violation JUR requires an Episode Investigation under [episode.md](episode.md). A Violation JUR is complete only when it includes or inherits a recommended Corrective Action established through that investigation. For a JUR investigation, record prevention loci in `investigation.findings.prevention_loci`.

## 4. Templates

The YAML blocks are concise Markdown templates, not required record serialization. Omit groups and fields that are not material. Add context, evidence, limitations, or execution context only where they materially qualify a group.

### 4.1 JR

```yaml
# JR: <title>
record:
  id: <stable ID>
  index: "<next three-digit root index>"
  record_type: JR
  title: <concise title>
  recorded_at: <time>
  event_at: <when material>
  source: <repository, project, or system>
  episode: <work reference>
  summary: <concise episode summary>

judgement:
  kind: <kind>
  trigger: <user | agent>
  activity: <user | agent>
  statement: <governing judgement>
  basis: <material requirements, facts, assumptions, uncertainty, and authority>
  scope: <where the judgement applies and does not apply>
  rationale: <material reasons, including direction or tradeoffs when needed>
  revisit_triggers: <conditions for reconsideration, when material>
```

### 4.2 JUR

```yaml
# JUR: <title>
record:
  id: <stable ID>
  index: "<originating root index>.<next two-digit update index>"
  record_type: JUR
  title: <concise title>
  recorded_at: <time>
  event_at: <when material>
  source: <repository, project, or system>
  episode: <work reference>
  summary: <concise update summary>
  relationships:
    - type: updates
      target_id: <immediately preceding JR or JUR>

judgement:
  kind: <only when changed>
  trigger: <user | agent>
  activity: <user | agent>
  statement: <only when changed>
  basis: <only material update information>
  scope: <only when changed>
  rationale: <only when changed>
  revisit_triggers: <only when changed>

update:
  subject_record_id: <immediately preceding JR or JUR>
  kind: <correction | supplement | changed_information | other>
  effect: <how the linked judgement changes>
  assessment: <not_a_violation | concern | violation>

investigation: # required for concern or violation
  status: <in_progress | completed | deferred>
  findings:
    prevention_loci: <when investigated>
  causal_status: <observed | inferred | hypothesized | unknown>
  evidence: <when material>
  limitations: <when material>

corrective_actions: # required to complete a violation JUR unless inherited
  - rule: <reusable instruction that prevents the pattern>
    description: <recommended action>
    target: <where it applies>
    status: recommended
    validation: <when performed>
```
