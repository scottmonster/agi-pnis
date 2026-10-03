# Material Episode Record Protocol

**Status: Draft standard under development.**

## 1. Purpose

This document is the entry point, shared protocol, and routing layer for the Material Episode Record system.

The system retains durable evidence about only two kinds of material episode: qualifying judgments and detected material failures.

It is not an execution-tracking system, trace archive, or record of every successful tool call, failed test, retry, routine error, internal reasoning step, or implementation choice.

The protocol is harness-agnostic.

It accepts relevant evidence from people, agents, tests, policy checks, user feedback, traces, external outcomes, and other sources without requiring a particular runtime, tool, telemetry format, or storage product.

## 2. Record model and materiality boundary

### 2.1 Durable record families

The system uses four durable record types.

| Record | Purpose |
| --- | --- |
| Judgment Record (JR) | Preserves a qualifying material judgment, including one that is later supported, challenged, corrected, or followed by a bad outcome. |
| Judgment Update Record (JUR) | Preserves a later material implementation, validation, outcome, error, correction, or review concerning a JR. |
| Failure Record (FR) | Preserves a detected material failure so it can inform prevention, review, remediation, or future guidance. |
| Failure Update Record (FUR) | Preserves a later material investigation, corrective action, validation, correction, review, recurrence, or outcome concerning an FR. |

JR and FR are the two primary record types.

JUR and FUR preserve later material events without rewriting the historical record they concern.

### 2.2 Materiality boundary

A record is created only for a material episode.

A qualifying JR captures a settled, discretionary judgment that materially affects direction, scope, constraints, precedent, or an outcome that warrants later understanding.

An FR captures a detected violation that is material enough to inform prevention, remediation, review, or future guidance.

A detected violation may be investigated or corrected without creating an FR when it does not meet that materiality boundary.

A catalog entry, routine error, failed test, or unsuccessful tool call does not by itself establish a material FR.

The detailed JR/JUR qualification rules are in [judgement-record.md](judgement-record.md).

The detailed FR/FUR qualification and reporting rules are in [failure-record.md](failure-record.md). The failure taxonomy and investigation profiles are in [failure-catalog.md](failure-catalog.md).

### 2.3 Judgment and failure are distinct

A judgment is an exercise of discretion, not a failure type.

The system retains qualifying judgments whether their later outcomes appear good or bad because both are needed to understand judgment and human-agent alignment.

A failure can occur without a material judgment.

It can arise from an agent, tool, context, environment, task, authority boundary, external dependency, or evaluation process.

## 3. Shared concepts

### 3.1 Violation

A **Violation** is an action, omission, condition, or materially incorrect assumption that departs from an applicable requirement, constraint, or expected behavior and warrants correction or other response.

An FR records an actual detected violation.

A JUR may document a violation when later evidence corrects or materially challenges a JR.

Creating a JR is not itself a violation.

Creating a JUR is not itself a violation; the underlying event it records may be one.

Creating an FR means a material failure occurred.

Creating an FUR is not itself a violation.

### 3.2 Corrective Action

A **Corrective Action** is an action taken in response to a violation to correct the departure, repair or limit its effects, restore the required state, or reduce the likelihood of recurrence.

A candidate corrective action is not adopted merely because it was proposed or recorded.

Its disposition is recorded as proposed, accepted, rejected, deferred, implemented, validated, or ineffective when that information is available and material.

Selecting a corrective action that establishes governing future direction creates a new JR.

### 3.3 Violation Investigation

A **Violation Investigation** is a bounded, evidence-based inquiry into a detected violation that establishes the expected and observed behavior, relevant context and impact, available explanations and prevention loci, and candidate corrective actions.

It does not presume a root cause, a responsible actor, or an adopted corrective action.

An originating agent's account is evidence for an investigation, not the final diagnosis.

## 4. Shared evidence model

### 4.1 Evidence principle

The conceptual evidence model is a shared envelope of evidence the system may retain, not a demand that every record collect every field.

Evidence is captured **when available** and when material to understanding the episode.

The absence, restriction, or non-applicability of material evidence is itself retained when it affects interpretation. This also applies to a material `source`, `episode`, or `authority` object: retain its availability state and safe limitation statement instead of silently omitting it.

### 4.2 Common evidence envelope

The shared schema can represent the following evidence, when available and material:

- episode, task, issue, request, and repository references;
- intended outcome, success criteria, constraints, permissions, authority, and established direction;
- actors, agent identity, instructions, tools, runtime, and relevant environment context;
- artifacts, commands, tool results, changes, tests, and external state;
- observed outcome, impact, user feedback, review, and evaluation;
- supporting and contrary evidence;
- assumptions, uncertainty, inferences, hypotheses, and tested findings;
- violation detection, applicable requirement or expectation, observed departure, affected scope, impact, and containment;
- agent and reviewer accounts, investigation findings, and evidence limitations;
- failure classifications and candidate prevention loci;
- candidate corrective actions, dispositions, and validation; and
- remediation, correction, recurrence, and later outcome evidence.

The specialist standards select and profile the applicable fields from this envelope.

They define what is needed for a qualifying JR/JUR or FR/FUR record without creating a separate, harness-specific evidence model. `failure-catalog.md` supplies the pattern vocabulary referenced by an FR or FUR.

### 4.3 Evidence availability

For evidence that is relevant to a record, use one of these availability states:

- `available`;
- `unavailable`;
- `not collected`;
- `restricted or unsafe to retain`; or
- `not applicable`.

Do not silently represent unavailable evidence as fact or infer its contents from its absence.

When underlying evidence cannot be retained, preserve a safe reference, classification, or limitation statement when doing so is permitted and material.

### 4.4 Claim status

Records distinguish the status of an evidence-based claim:

- **Observation:** a recorded action, artifact, result, state, or feedback item.
- **Evaluation:** an assessment against a stated criterion, including its evaluator and basis.
- **Inference:** a conclusion supported by available evidence but not directly observed.
- **Hypothesis:** an unconfirmed possible explanation.
- **Tested finding:** a bounded conclusion supported by a stated comparison, replay, experiment, or other test.

A record identifies source, relevant time or revision when known, and role for material evidence so a later reader can distinguish contemporaneous information from later learning.

### 4.5 Safe retention and portability

Do not retain credentials, secrets, unnecessary personal data, private chain-of-thought, or wholesale raw transcripts by default.

Prefer durable repository paths and revisions, hashes, artifact identifiers, stable external references, or concise retained excerpts over harness-specific links alone.

## 5. Common response path for a violation

When a violation is detected, the responsible person, agent, or process follows this path as applicable:

1. Preserve the observed departure and immediately available evidence.
2. Contain or repair immediate effects when authorized.
3. Retrieve the relevant task, requirement, authority, context, and execution evidence.
4. Ask the originating agent for an account when it is available.
5. Assign an agent or reviewer to investigate when the originating agent is unavailable or the violation concerns a tool or environment.
6. Use [failure-record.md](failure-record.md) to analyze the violation and candidate prevention locus, then use [failure-catalog.md](failure-catalog.md) to select the matching failure pattern.
7. Identify candidate corrective actions and record their disposition when available.
8. Preserve later material events as a JUR or FUR, as appropriate.

This path does not require a finding of root cause, responsibility, or corrective action before evidence can be retained.

## 6. Record relationships and historical preservation

### 6.1 Relationship model

Every JUR identifies the JR it concerns.

Every FUR identifies the FR it concerns.

Records may additionally link to other materially related records, evidence, tasks, artifacts, or work episodes using the relationship vocabulary defined by the applicable specialist standard and represented by the shared schema.

An episode may require both specialist routes.

For example, an FR may classify a material violation that undermined a JR, while a JUR records the judgment-specific effect or later change in governing direction.

### 6.2 Later events and corrections

Durable records preserve what was known, observed, or settled when they were published.

Do not rewrite a published record to incorporate later implementation, validation, correction, review, recurrence, or outcome.

Use a JUR or FUR for a later material event.

Use a new JR when governing direction changes.

An FR or FUR may propose, implement, or validate corrective action without implying that the corrective action is governing direction.

## 7. Routing to specialist standards

### 7.1 Judgment route

Load [judgement-record.md](judgement-record.md) when the episode may be a qualifying material judgment, a material update to one, or a possible change in governing direction.

That standard determines whether the episode qualifies as a JR or JUR and defines the judgment-specific evidence and maintenance rules.

### 7.2 Failure route

Load [failure-record.md](failure-record.md) when a detected violation may be material enough for an FR or when a later failure-related event may require an FUR. Load [failure-catalog.md](failure-catalog.md) to select the matching failure pattern.

The failure-record standard determines FR/FUR qualification, reporting, analysis, investigation, prevention, corrective action, validation, updates, and history. The catalog provides only the failure taxonomy and pattern names referenced by the record.

### 7.3 Combined route

Load both specialist standards when a violation materially concerns a judgment or when resolving a failure establishes, changes, narrows, expands, or excepts governing direction.

Use the failure catalog to understand and classify the failure.

Use the failure-record standard to create, update, and report the FR or FUR.

Use the judgment standard to preserve the judgment, its material update, or its successor direction.

## 8. Machine-readable representation and validation

### 8.1 Distinct canonical roles

This document is canonical for the conceptual evidence model and workflow: what evidence means, when it matters, availability handling, record relationships, and routing.

[episode-record.schema.json](episode-record.schema.json) is canonical for the machine-readable representation of that model: field names, types, permitted values, nesting, references, and structural validation.

The schema implements this protocol.

It does not decide whether a judgment qualifies, define a failure pattern, or replace the semantic completeness rules in the specialist standards.

If this protocol and the schema diverge, this protocol controls until the schema is deliberately updated to match it.

### 8.2 Record status and publishable profiles

Every record has the structural fields `id`, `record_type`, `schema_version`, and `record_status`. A `draft` may remain partial. A `publishable` record must meet its record-type-specific, machine-verifiable profile in the shared schema.

A publishable record has a title and `recorded_at`. The publishable profiles additionally require:

- JR: authority and the structurally required judgment fields;
- JUR: `event_at`, `recorded_by`, `judgment.subject_record_id`, and `judgment.update_kind`;
- FR: `failure.name`, `failure.harness`, and the structurally required violation fields; and
- FUR: `event_at`, `failure.subject_record_id`, and `failure.update_kind`.

`failure.harness` accepts an open value, including `manual` or `unknown`, when no named harness applies.

These profiles validate only machine-verifiable structure. The specialist standards still determine whether the episode actually qualifies and whether its available evidence is semantically complete.

## 9. Record locations and stable identity

The standards and schema live in `observe/episodes/`.

Initial Markdown records live under `.agents/tracking/records/`:

```text
.agents/tracking/records/
  judgments/
  failures/
  index.md
```

Each record receives a stable identifier independent of its filename, path, and local sequence number.

Record IDs use the `JR`, `JUR`, `FR`, and `FUR` prefixes.

Migration and central-corpus ingestion are deferred until repository-level records exist and show the actual cross-project needs.

## 10. Responsibilities of the related files

| Artifact | Responsibility |
| --- | --- |
| episode-record.md | Shared protocol and routing layer: material episodes, shared concepts, evidence model, response path, record relationships, and specialist-document selection. |
| episode-record.schema.json | Shared machine-valid record shape: fields, relationships, availability states, references, and controlled values. |
| judgement-record.md | Judgment specialist: JR/JUR qualification, maintenance, and judgment-specific reporting rules. |
| failure-record.md | Failure-record specialist: FR/FUR qualification, reporting, updates, and historical maintenance. |
| failure-catalog.md | Failure vocabulary reference: categorized failure patterns and evidence labels. |
