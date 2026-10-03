# Material Episode Records: Current Unification Direction

**Status: Temporary design documentation; non-authoritative.**

This document records the current direction for unifying material judgment and failure reporting. It creates no requirement or binding direction unless an authoritative source adopts it.

## 1. Standard and reference locations

The long-lived standards and schema will be built in observe/episodes/:

- episode-record.md;
- judgement-record.md;
- failure-catalogue.md; and
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

### 3.2 Judgment and failure are distinct

A judgment is an exercise of discretion, not a failure type. Recording qualifying judgments captures both good and bad judgment, which is necessary for later analysis of human-agent alignment.

A failure may arise without a material judgment. It may result from an agent, tool, context, environment, task, authority boundary, external dependency, or evaluation process.

## 4. episode-record.md

episode-record.md is the main entry point for the system. It defines:

- the materiality boundary for JR and FR records;
- the relationship between a work episode, JR, JUR, FR, and FUR;
- the complete canonical evidence schema;
- evidence availability, sensitivity, and claim-status conventions;
- common relationships, later remediation, and central-corpus use; and
- links to judgement-record.md and failure-catalogue.md.

The complete evidence schema is the single place that identifies all evidence the system may ever retain. It is an envelope of available information, not a requirement to collect every field for every record.

## 5. episode-record.schema.json

### 5.1 Schema role

episode-record.schema.json is the canonical structural schema. It incorporates the evidence and metadata identified in the existing judgment-record and evidence-standard references, including source references, authority, actors, safe agent and runtime information, evidence, outcomes, evaluation, relationships, and evidence availability.

episode-record.md explains the schema and system workflow in prose. The JSON Schema defines structural validity; it does not replace the semantic completeness rules in judgement-record.md or failure-catalogue.md.

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
- remediation, validation, correction, and later outcome evidence.

### 5.3 Evidence availability

The schema supports evidence items that carry a value or reference and an availability state. The controlled states are:

- available;
- unavailable;
- not collected;
- restricted or unsafe to retain; and
- not applicable.

Missing evidence is not inferred or silently represented as fact. Safe references, classifications, or limitation statements preserve the reason an underlying item cannot be retained.

### 5.4 Structural metadata

Every durable JR, JUR, FR, or FUR has structural metadata needed for identity and validation, including a stable record ID, record type, and schema version.

This metadata is separate from the evidence requirements of a particular judgment or failure report.

## 6. judgement-record.md

judgement-record.md defines the specialized JR and JUR model. It selects from the canonical schema and defines the additional information that a governing judgment requires:

- what judgment was required and settled;
- settlement authority and evidence;
- scope, conditions, exclusions, and precedential force;
- governing basis, rationale, and resulting direction; and
- judgment-specific immutability, correction, and update rules.

It records all qualifying material judgment, not routine implementation choices or agent micro-decisions.

## 7. failure-catalogue.md

failure-catalogue.md is the classification and reporting reference for FR and FUR records. It consolidates:

- cross-harness analytical modes from failure_modes.md;
- prevention loci and compressed families from failure_index.md; and
- detailed coding-agent patterns and evidence labels from large_list.md.

Its structure is:

- cross-harness analytical modes;
- prevention loci: agent-level, tool-level, shared, task/external, and unresolved; and
- detailed coding-agent patterns with evidence labels.

For each failure family or detailed pattern, the catalogue defines:

- the failure name;
- the minimum reporting fields;
- additional canonical evidence fields to capture when available; and
- the evidence profile for a complete report when available.

The minimum failure-reporting fields are failure_name and harness_name. A catalogue entry classifies an actual detected failure; it does not create an FR by itself.

harness_name remains harness-agnostic because it accepts an open value, including manual or unknown where no named harness applies.

An FR may carry several classifications. Classifications identify candidate prevention opportunities, not proven root cause or fault.

## 8. Record identity and location

The standards and schema live in observe/episodes/. The initial Markdown records live separately under .agents/tracking/records/:

    .agents/tracking/records/
      judgments/
      failures/
      index.md

Each record receives a stable identifier independent of its filename, path, and local sequence number. The record types use the JR, JUR, FR, and FUR prefixes.

Migration is deferred. The initial design establishes stable identity and discoverable locations before any later storage or corpus change.

## 9. What is not retained by default

The system does not retain a stand-alone record for:

- every successful tool call, test, command, or task;
- every routine error, retry, or transient failure;
- every internal agent decision or reasoning step;
- raw traces, full transcripts, or private chain-of-thought; or
- a catalogue pattern without a detected, material failure episode.

These artifacts may be linked when they materially support a JR, JUR, FR, or FUR.

## 10. Target document structure

The long-lived system has three documents and one schema with distinct roles:

| Artifact | Role |
| --- | --- |
| episode-record.md | Defines material episodes, the canonical evidence schema, common relationships, and the JR/JUR/FR/FUR record families. |
| episode-record.schema.json | Defines the structural record model and controlled values. |
| judgement-record.md | Defines the specialized JR and JUR record model. |
| failure-catalogue.md | Defines failure classifications and evidence profiles for FR and FUR records. |

## 11. Work deferred until records exist

### 11.1 Central corpus

Central-corpus ingestion and normalization remain deferred until repository-level JR, JUR, FR, and FUR records exist and reveal the actual cross-project query needs.

### 11.2 Detailed schema implementation

The exact JSON Schema field definitions and validation rules remain to be written in episode-record.schema.json. The location, evidence envelope, availability states, structural metadata, and profile model are already decided.
