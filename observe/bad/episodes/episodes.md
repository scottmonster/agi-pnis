# Material Episode Records: Current Unification Direction

**Status: Temporary design documentation; non-authoritative.**

This document records the current direction for unifying material judgment and failure reporting. It creates no requirement or binding direction unless an authoritative source adopts it.

## 1. Standard and reference locations

The long-lived standards and schema will be built in observe/episodes/:

- episode-record.md;
- judgement-record.md;
- failure-record.md;
- failure-catalog.md; and
- episode-record.schema.json.

The following files remain reference sources during the design and consolidation work:

- ../evidence_standard.md;
- ../failure_index.md;
- ../failure_modes.md;
- ../judgement_record.md; and
- ../large_list.md.

The reference sources are retained. They are not removed as part of this work.

## 2. Purpose and boundary

The system preserves only material episodes. It is not a full execution-tracking system, a trace archive, or a record of every tool call, successful test, routine error, or internal decision.

The system remains harness-agnostic. It accepts available evidence from people, agents, tests, policy checks, user feedback, traces, external outcomes, and other sources without requiring a particular runtime or capture mechanism.

## 3. Material episodes

### 3.1 Record families

The system retains two primary kinds of material episode:

- **Judgment Records (JR):** all qualifying material judgments, including judgments later supported, challenged, corrected, or followed by a bad outcome.
- **Failure Records (FR):** detected material failures retained because understanding and preventing them can improve future work.

Later material events use corresponding update records:

- **Judgment Update Records (JUR):** later implementation, validation, outcome, error, correction, or review concerning a JR.
- **Failure Update Records (FUR):** later remediation, validation, correction, review, recurrence, or outcome concerning an FR.

Not every work episode creates a durable record. A JR is created only when it meets the material-judgment qualification threshold. An FR is created only when the detected failure is material enough to inform prevention, review, remediation, or future guidance.

A detected violation may be investigated or corrected without creating a durable FR. An FR is created only when that violation meets the materiality boundary.

### 3.2 Judgment and failure are distinct

A judgment is an exercise of discretion, not a failure type. Recording qualifying judgments captures both good and bad judgment, which is necessary for later analysis of human-agent alignment.

A failure may arise without a material judgment. It may result from an agent, tool, context, environment, task, authority boundary, external dependency, or evaluation process.

### 3.3 Violation, Corrective Action, and Violation Investigation

**Violation:** an action, omission, condition, or materially incorrect assumption that departs from an applicable requirement, constraint, or expected behavior and warrants correction or other response.

**Corrective Action:** an action taken in response to a violation to correct the departure, repair or limit its effects, restore the required state, or reduce the likelihood of recurrence.

**Violation Investigation:** a bounded, evidence-based inquiry into a detected violation that establishes the expected and observed behavior, relevant context and impact, available explanations and prevention loci, and candidate corrective actions. It does not presume a root cause, a responsible actor, or an adopted corrective action.

An FR records an actual detected violation. A JUR may document a violation when later evidence corrects or materially challenges a JR, but a JUR that records successful implementation, validation, or review is not itself a violation. A FUR records later investigation, corrective action, validation, recurrence, or outcome; it is not itself a violation.

### 3.4 Violation response

When a violation is detected, the response path is:

- preserve the observed departure and immediate evidence;
- contain or repair immediate effects when authorized;
- retrieve the relevant task, requirement, context, and execution evidence;
- ask the originating agent for an account when it is available;
- assign an agent or reviewer to analyze the evidence when the originating agent is unavailable or the violation concerns a tool or environment;
- classify the violation and candidate prevention locus;
- identify one or more candidate corrective actions;
- record whether each corrective action is proposed, accepted, rejected, deferred, implemented, validated, or ineffective; and
- record later material events in a JUR or FUR.

An account from the originating agent is evidence for the investigation, not the final diagnosis.

If selecting a corrective action establishes governing future direction, that selection is recorded as a new JR.

## 4. episode-record.md

episode-record.md is the shared protocol and routing layer for the system. It is the main entry point. It defines:

- the materiality boundary for JR and FR records;
- the relationship between a work episode, JR, JUR, FR, and FUR;
- the shared concepts of violation, Violation Investigation, Corrective Action, evidence availability, claim status, and record relationship;
- the shared evidence model and its canonical schema;
- the violation response path and common relationships; and
- which specialist document to load next.

episode-record.md routes a qualifying judgment to judgement-record.md and a detected material violation to failure-record.md. failure-record.md loads failure-catalog.md to classify the failure and select its applicable investigation profile. An episode may involve both the judgment and failure routes when a violation materially concerns a judgment.

The document introduces JR, JUR, FR, and FUR, but does not duplicate the specialized qualification, diagnostic, or reporting rules. It can contain a compact category or index view when that materially improves routing; it does not repeat the complete failure catalog.

The shared evidence model identifies all evidence the system may ever retain. It is an envelope of available information, not a requirement to collect every field for every record.

## 5. episode-record.schema.json

### 5.1 Schema role

episode-record.schema.json is the canonical machine-valid shared record shape. It incorporates the evidence and metadata identified in the existing judgment-record and evidence-standard references, including source references, authority, actors, safe agent and runtime information, evidence, outcomes, evaluation, relationships, and evidence availability.

episode-record.md is canonical for the conceptual evidence model and workflow: what evidence means, when it matters, availability handling, routing, and record relationships. episode-record.schema.json is canonical for the machine-readable representation of that model: field names, types, permitted values, nesting, and structural validation.

The JSON Schema implements the Markdown standard; it does not decide whether a judgment qualifies, define a failure pattern, or replace the semantic completeness rules in judgement-record.md and failure-record.md. If the conceptual standard and schema diverge, the conceptual standard controls until the schema is deliberately updated to match it.

### 5.2 Common evidence envelope

The schema covers, when available and material:

- episode, task, issue, request, and repository references;
- intended outcome, constraints, permissions, authority, and established direction;
- actors, agent identity, instructions, tools, runtime, and relevant environment context;
- artifacts, commands, tool results, changes, tests, and external state;
- observed outcome, impact, user feedback, review, and evaluation;
- failure classifications and prevention locus;
- supporting and contrary evidence;
- assumptions, uncertainty, inferences, hypotheses, and tested findings; and
- violation detection, applicable requirement or expectation, observed departure, affected scope, impact, and containment;
- agent or reviewer accounts, investigation findings, and evidence limitations;
- candidate corrective actions, their disposition, and their validation; and
- remediation, validation, correction, and later outcome evidence.

### 5.3 Evidence availability

The schema supports evidence items that carry a value or reference and an availability state. Material source, episode, and authority objects also carry an availability state and a safe limitation statement when their contents cannot be retained. The controlled states are:

- available;
- unavailable;
- not collected;
- restricted or unsafe to retain; and
- not applicable.

Missing evidence is not inferred or silently represented as fact. Safe references, classifications, or limitation statements preserve the reason an underlying item cannot be retained.

### 5.4 Structural metadata and publishable profiles

Every durable JR, JUR, FR, or FUR has structural metadata needed for identity and validation, including a stable record ID, record type, schema version, and record status.

A `draft` record may remain partial. A `publishable` record must satisfy its record-type-specific, machine-verifiable schema profile. Those profiles require a shared title and record time, then require the applicable FR, FUR, JR, or JUR structural fields. The specialist standards continue to decide semantic qualification and completeness from available evidence.

### 5.5 Violation Investigation evidence

All data retrieved during a Violation Investigation belongs to the canonical schema. When available and material, it includes:

- the detection source, detection time, and violation statement;
- the applicable requirement, constraint, or expected behavior;
- the observed departure, affected artifacts or state, scope, and impact;
- the relevant contemporaneous task, authority, context, tool, agent, runtime, and environment evidence;
- immediate containment, repair, or state-restoration activity;
- the originating agent's account, including its availability or reason it could not be obtained;
- the identity, role, and findings of a later investigating agent or reviewer;
- candidate failure classifications, prevention loci, supporting evidence, and contrary evidence;
- candidate corrective actions and their disposition; and
- later validation, recurrence, and outcome evidence.

The schema does not require every investigation to supply every item. The relevant catalog profile identifies the items to capture when available.

## 6. judgement-record.md

judgement-record.md is the judgment specialist document. It selects from the canonical schema and defines whether a situation qualifies as a JR or JUR, and the additional information that a governing judgment requires:

- what judgment was required and settled;
- settlement authority and evidence;
- scope, conditions, exclusions, and precedential force;
- governing basis, rationale, and resulting direction; and
- judgment-specific immutability, correction, and update rules.

It records all qualifying material judgment, not routine implementation choices or agent micro-decisions. episode-record.md introduces the JR/JUR route and directs qualifying cases here without duplicating these rules.

## 7. failure-record.md

failure-record.md is the failure-record specialist document. It selects from the canonical schema and defines whether a detected violation qualifies as an FR or FUR, and the additional information that a failure record requires:

- FR/FUR qualification and materiality application;
- minimum and complete-when-available reporting requirements;
- analytical modes, prevention loci, investigation, corrective-action, validation, and escalation guidance;
- update, correction, remediation, validation, recurrence, and historical maintenance; and
- relationships to JR and JUR records when a failure concerns a judgment.

It directs classification to failure-catalog.md without duplicating the catalog's detailed taxonomy or profiles.

## 8. failure-catalog.md

failure-catalog.md is the failure vocabulary reference. It contains only the catalog of failures and the evidence labels needed to interpret it. It consolidates:

- cross-harness analytical modes from failure_modes.md;
- prevention loci and compressed families from failure_index.md; and
- detailed coding-agent patterns and evidence labels from large_list.md.

Its structure is a navigable category hierarchy of detailed coding-agent patterns with evidence labels.

The catalog provides failure names, short descriptions where available, categories, and evidence labels. It does not define investigation, prevention, corrective action, validation, escalation, FR/FUR creation, updates, or reporting.

The minimum failure-reporting concepts are failure name and harness name. Their canonical schema paths are `failure.name` and `failure.harness`; the prose labels are not literal field names. A catalog entry classifies an actual detected failure; it does not create an FR by itself.

`failure.harness` remains harness-agnostic because it accepts an open value, including manual or unknown where no named harness applies.

An FR may carry several classifications. Classifications identify candidate prevention opportunities, not proven root cause or fault.

## 9. Record identity and location

The standards and schema live in observe/episodes/. The initial Markdown records live separately under .agents/tracking/records/:

    .agents/tracking/records/
      judgments/
      failures/
      index.md

Each record receives a stable identifier independent of its filename, path, and local sequence number. The record types use the JR, JUR, FR, and FUR prefixes.

Migration is deferred. The initial design establishes stable identity and discoverable locations before any later storage or corpus change.

## 10. What is not retained by default

The system does not retain a stand-alone record for:

- every successful tool call, test, command, or task;
- every routine error, retry, or transient failure;
- every internal agent decision or reasoning step;
- raw traces, full transcripts, or private chain-of-thought; or
- a catalog pattern without a detected, material failure episode.

These artifacts may be linked when they materially support a JR, JUR, FR, or FUR.

## 11. Target document structure

The long-lived system has four documents and one schema with distinct roles:

| Artifact | Role |
| --- | --- |
| episode-record.md | Shared protocol and routing layer: material episodes, universal concepts, response path, evidence model, record relationships, and specialist-document selection. |
| episode-record.schema.json | Shared machine-valid record shape: fields, relationships, availability states, and controlled values. |
| judgement-record.md | Judgment specialist: JR/JUR qualification, maintenance, and judgment-specific reporting rules. |
| failure-record.md | Failure-record specialist: FR/FUR qualification, reporting, updates, and historical maintenance. |
| failure-catalog.md | Failure classification reference: taxonomy, profiles, prevention loci, and detailed patterns. |

## 12. Work deferred until records exist

### 12.1 Central corpus

Central-corpus ingestion and normalization remain deferred until repository-level JR, JUR, FR, and FUR records exist and reveal the actual cross-project query needs.

### 12.2 Detailed schema implementation

The initial JSON Schema field definitions and publishable-record validation rules are defined in episode-record.schema.json. Future revisions may refine them as repository records reveal actual cross-project needs.
