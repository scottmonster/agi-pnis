# Judgment Records

## 1. Purpose and role

This document is the specialist standard for Judgment Records (JR) and Judgment Update Records (JUR).

It defines when a material governing judgment qualifies for retention, the judgment-specific information that a record `MUST` preserve, and how later material events affect that record.

`episode-record.md` remains the shared protocol and routing layer. `episode-record.schema.json` defines the common machine-valid field structure. This document selects and gives meaning to the schema fields required for JR and JUR records; it does not define a separate data model or duplicate the shared evidence, violation, or relationship protocol.

## 2. Terms and boundaries

### 2.1 Judgment Record

A JR preserves one completed, settled, material exercise of discretion that governs future work within an explicit scope.

It records the judgment whether later evidence supports, challenges, corrects, or follows it. Creating a JR is not a violation.

### 2.2 Judgment Update Record

A JUR preserves one later material event concerning a JR without rewriting that JR's historical content.

A JUR may record implementation, validation, outcome, review, correction, error, or challenge. A JUR is not inherently a violation: it documents a violation only when the later evidence establishes that a judgment-related departure occurred. A material judgment-related violation is also linked to an FR when it meets the Failure Record threshold in `episode-record.md` and `failure-record.md`.

### 2.3 What this standard does not record

`MUST NOT` create a JR or JUR merely for:

- an open question, tentative analysis, recommendation, or active discussion;
- a direct instruction to make an already-defined change;
- a routine, obvious, or readily reversible implementation choice;
- an ordinary status update, execution log, test result, retry, or tool call;
- internal agent reasoning, a micro-decision, private chain-of-thought, or a full transcript; or
- a failure that has no qualifying material judgment relationship.

Such information may be retained as available evidence when it materially supports a qualifying JR or JUR.

## 3. JR qualification

### 3.1 Qualification test

Create a JR only when all of the following are true:

- **Settled:** an actor with actual or delegated authority resolved the matter for a defined scope.
- **Discretionary:** the resolution required a non-obvious interpretation, assumption, trade-off, conflict resolution, or choice among materially plausible approaches.
- **Governing:** the result constrains, authorizes, prohibits, prioritizes, interprets, or establishes a meaningful default for future work.
- **Material:** losing the judgment or its rationale would create a meaningful risk of repeated debate, inconsistent work, bad generalization, mistaken authority, expensive reversal, or misunderstanding of repository history.
- **Complete:** the judgment has reached a durable completion boundary under 3.2.

`MUST NOT` assign a numeric materiality score. Breadth of effect, recurrence, reversibility, risk, uncertainty, external commitment, conflict with established direction, and precedent value are useful signals.

### 3.2 Completion boundary

A judgment has reached a durable completion boundary when an affected artifact has been created or changed, the governed work has completed, or the authorized actor directs that the judgment be recorded as complete.

A statement made during an active discussion does not, by itself, establish this boundary. Preserve the evolving discussion in its ordinary work context until the judgment qualifies.

### 3.3 Judgment kinds

Use the applicable controlled `judgment.judgment_kind` value from the common schema. The specialist vocabulary is:

- `decision`;
- `interpretation`;
- `assumption`;
- `tradeoff`;
- `conflict_resolution`;
- `scope_boundary`;
- `exception`;
- `intentional_departure`; or
- `other` only when none of the preceding kinds fit.

## 4. JR reporting requirements

### 4.1 Minimum JR report

A qualifying JR `MUST` contain the shared structural metadata, `recorded_at`, and enough judgment-specific information for a future reviewer to determine:

- what work or episode required judgment, when available;
- the question, ambiguity, conflict, trade-off, or intended departure that required discretion;
- `judgment.settled_at`, `judgment.completion_boundary`, what was settled, and the resulting direction;
- who settled it, their authority basis, and evidence supporting settlement;
- `judgment.scope`, including its applicable scope, material conditions, exclusions, and precedential force;
- the governing basis and the distinction among requirements, established direction, observations, inferences, assumptions, and uncertainty; and
- `judgment.rationale`, including material constraints and trade-offs.

A JR cannot qualify when the settled judgment, its governing authority, or its scope is unknown. Other evidence may be unavailable, not collected, restricted or unsafe to retain, or not applicable as represented by the common schema.

### 4.2 Complete JR report when available

When available and material, a complete JR additionally retains or safely references:

- the `source`, `episode`, intended outcome, constraints, and relevant established direction;
- material `actors`, `agent_context`, `instructions`, `tools`, `runtime`, and `environment` context;
- `judgment.alternatives_considered`, including the unchanged state when it was a real option;
- supporting and contrary `evidence`, its role, and evidence limitations;
- `claims` for assumptions, uncertainty, inferences, hypotheses, and tested findings;
- `judgment.revisit_triggers`;
- `judgment.consequences` and `judgment.accepted_tradeoffs`;
- `relationships` to prior or related judgments; and
- a safe `sensitivity` classification and durable references instead of secrets, private reasoning, or wholesale raw transcripts.

The shared schema's evidence availability state `MUST` be used for a material item that cannot be provided. `MUST NOT` infer a missing value or silently represent it as fact.

### 4.3 Authority and contribution

Record settlement authority and contribution separately. A person can settle an agent proposal without independently authoring its rationale. An agent can settle a judgment only when its delegated authority is recorded.

`MUST NOT` claim approval, rationale, settlement, or authority that the available evidence does not support. Silence is not approval.

Use the common `authority` and `actors` structures. A material unavailable authority, source, or episode is represented by its shared availability state and limitation rather than by omission. When the schema provides contribution roles, use only material roles such as `identified`, `proposed`, `provided_evidence`, `evaluated`, `challenged`, `settled`, `recorded`, `reviewed`, `implemented`, and `validated`.

### 4.4 Scope and precedent

Every JR `MUST` state where the judgment applies and does not apply. Use `judgment.scope.precedent` with this meaning:

- `case_only`: resolves this instance only and does not generalize automatically;
- `default_in_scope`: establishes the expected direction for analogous work within the stated scope, subject to a later material judgment; or
- `binding_in_scope`: governs the stated scope until authorized direction changes it.

A JR does not convert an assumption into a requirement, an observation into intended behavior, or a local convention into a rule outside its defined scope.

## 5. JR body structure

The Markdown body is the human-reviewable account of the structured record. Use these required sections, with the title as the document heading:

```md
# <title>

## 1. Context and scope

<Work, intended outcome, success criteria, and material boundaries.>

## 2. Judgment required

<Why routine execution was insufficient.>

## 3. Governing basis

<Requirements, established direction, observations, inferences, assumptions, and uncertainty, each identified by role.>

## 4. Judgment and direction

<What was settled and the resulting direction.>

## 5. Rationale

<Why this result was preferred, including material constraints and trade-offs.>
```

Add a numbered section only when it materially improves later understanding: objectives and constraints; options considered; agent proposal or evaluation; assumptions and uncertainty; consequences and trade-offs; evidence; or change from prior judgment.

## 6. JUR qualification and reporting

### 6.1 When to create a JUR

Create a JUR for one later material event that concerns a published JR and does not itself establish a changed governing judgment.

Use the applicable `judgment.update_kind` value from the common schema: `implementation`, `validation`, `outcome`, `review`, `correction`, or `error`.

Use `correction` when the earlier JR or JUR contains a factual or recording error. State precisely what was wrong and the corrected information. Use `error` when evidence exposes a judgment-related departure. Use a `review` JUR with a `challenges` relationship when evidence materially disputes a judgment without establishing an error. A JUR documenting implementation, successful validation, or ordinary review is not a violation.

Create a successor JR, rather than a JUR, when an authorized actor settles a changed governing judgment. Link the successor through the applicable typed relationship, such as `supersedes`, `narrows`, `expands`, or `exception_to`.

### 6.2 Minimum JUR report

A JUR `MUST` contain the shared structural metadata, `recorded_at`, `event_at`, `recorded_by`, the linked JR identifier in `judgment.subject_record_id`, `judgment.update_kind`, the material event, its evidence, and its effect on the linked judgment. Use `relationships` to identify any additional directly affected records.

For a `validation`, `outcome`, or `error` JUR, or a JUR that challenges a judgment, record the expected behavior or success criterion, observed behavior or outcome, material difference, impact, and evaluation basis when available. Distinguish observation, evaluation, inference, hypothesis, and tested finding under the common `claims` model.

For a correction or challenge that identifies a violation, include the applicable requirement, constraint, or expected behavior; observed departure; known impact; and links to the related FR or FUR when one exists. Use the failure-catalog route for classification, investigation, corrective-action, and validation details.

### 6.3 Complete JUR report when available

When available and material, a complete JUR also includes:

- the relevant `source`, `episode`, artifacts, changes, commands, tool results, tests, feedback, or external state;
- material `actors`, `agent_context`, `instructions`, `tools`, `runtime`, and `environment` context;
- supporting and contrary evidence, uncertainty, and retention limitations;
- `violation`, `investigation`, `corrective_actions`, `evaluation`, or `later_outcomes` information needed for the event; and
- typed `relationships` to the JR, related JURs, and any FR or FUR.

## 7. JUR body structure

```md
# <title>

## 1. Later event

<The material event, date, and relationship to the linked JR.>

## 2. Evidence and assessment

<Material evidence, its role, and claim status.>

## 3. Effect on the judgment

<What the event confirms, challenges, corrects, or leaves unchanged.>
```

For validation, outcome, error, or challenge, add an **Outcome comparison** section for expected behavior, observed behavior, difference, impact, and evaluation basis. For a violation, add only the material violation information needed to explain the JUR and link to the FR/FUR; `MUST NOT` duplicate the Failure Record investigation.

## 8. Relationships, history, and corrections

### 8.1 Typed relationships

Use the common schema's typed `relationships` structure. The current record is the relationship source.

Judgment relationships include `supersedes`, `narrows`, `expands`, `exception_to`, `conflicts_with`, and `depends_on`. JUR relationships include `implements`, `validates`, `records_outcome_for`, `records_error_for`, `corrects`, `reviews`, and `challenges`. Episode relationships may include `prompted_by` and `derived_from`.

Use a relationship only when it materially aids discovery or analysis. A relationship `MUST NOT` imply authority that the record has not established.

### 8.2 Immutability and succession

Published JR and JUR records are immutable historical evidence. `MUST NOT` edit them to add later knowledge, alter authority, revise rationale, or make a factual correction.

Record later implementation, validation, outcome, review, error, correction, or challenge in a new JUR. Record a changed governing judgment in a new, linked JR. The earlier record remains an account of what was known, asserted, and governing at its own time.

### 8.3 Judgment-related violations

When a JUR documents evidence that a judgment-related violation occurred, preserve that relationship without collapsing the two record families:

- the JUR explains the effect on the judgment and its history;
- the FR records the material detected violation and its failure classification; and
- a FUR records later investigation, corrective action, validation, recurrence, or outcome for the FR.

Not every challenged judgment establishes a violation. A JUR `MUST` state the evidence and claim status rather than treating a possible explanation as an established failure.

## 9. Identity, storage, and indexing

Use the shared schema's stable `id`, `record_type`, and `schema_version` fields. JR and JUR identifiers use their respective `JR` and `JUR` prefixes and remain stable independently of filename, path, or local sequence number.

Until the storage model changes by an authorized decision, initial Markdown records are stored under `.agents/tracking/records/judgments/`, and the discoverable index is `.agents/tracking/records/index.md`. A record `SHOULD` include available repository, path, episode, and revision references using the common schema; a filename or local sequence is not corpus identity.

## 10. Examples

### 10.1 JR example: settled scope interpretation

An authorized maintainer resolves an ambiguity about whether a repository convention applies to generated artifacts. The resolution selects `default_in_scope`, names the generated-artifact condition and exclusion, identifies the relevant convention and observed tooling behavior, and explains the trade-off. This is a JR because it is settled, discretionary, governing, material, and complete.

### 10.2 JUR and FR example: later judgment-related violation

A later validation finds that implementation followed an outdated interpretation rather than the linked JR. The JUR records the expected direction, observed departure, evidence, and effect on the judgment history. If the departure is material, the linked FR classifies and investigates it; its later remediation and validation belong in a FUR. The JUR itself is not automatically the violation.

## 11. Review test

Before publishing a JR, confirm that a future reviewer can determine what required judgment, what was settled, who had authority, why it was chosen, where it applies, what evidence qualified it, and what was known at settlement.

Before publishing a JUR, confirm that a future reviewer can determine the linked JR, the later event, its evidence and claim status, its effect on the judgment, and whether the event requires a successor JR or a related FR.

`MUST NOT` add irrelevant detail to compensate for an unavailable item. Use the common availability state and a concise limitation statement where the absence materially affects interpretation.
