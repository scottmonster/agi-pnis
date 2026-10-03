# Material Judgment Records

## 1. Purpose

This standard preserves material human and agent judgment as durable evidence for repository review and later cross-repository analysis. It defines two immutable record types:

- **Material Judgment Record (MJR):** one completed, settled, non-obvious exercise of discretion that governs future work within an explicit scope.
- **Judgment Follow-up Record (JFR):** a later material event that records implementation, validation, outcome, error, correction, or review of an MJR without changing it.

A repository's records are the canonical evidence. A central corpus may ingest, index, and normalize them, but it `MUST NOT` become a separately editable replacement for their source records.

MJR and JFR records preserve material judgment episodes. They do not replace routine execution evidence such as task records, tool traces, test results, or evaluations. A record `MAY` reference that evidence when it materially explains the judgment or its outcome.

## 2. Core principles

1. Preserve the judgment episode. Record what required judgment, what was settled, the applicable authority, material evidence and constraints, and the rationale.
2. Keep judgment, direction, implementation, validation, outcome, error, correction, and review distinct. Record later material events as JFRs instead of rewriting the historical judgment.
3. Keep contribution, authority, and approval separate. An agent may identify, propose, or record a judgment that a person settles. Approval of an agent proposal does not make its rationale human-authored.
4. Preserve scope and force. A local decision does not become a general rule merely because it is recorded.
5. Structure information required for cross-record queries. Keep nuanced reasoning and context as concise narrative rather than forcing it into a premature taxonomy.
6. Preserve history. Published MJR and JFR files are immutable. A material changed judgment creates a linked successor MJR. A correction creates a linked JFR.
7. Capture proportionately. Do not turn MJRs into execution logs, full transcripts, or hidden chain-of-thought records.
8. Distinguish fact from explanation. Record observations, evidence-supported inferences, causal hypotheses, and unresolved uncertainty as separate claims.

## 3. MJR qualification

Create an MJR only when all four tests hold:

- **Settled:** an actor with actual or delegated authority resolved the matter for a defined scope.
- **Discretionary:** resolution required a non-obvious interpretation, assumption, trade-off, conflict resolution, or choice among materially plausible approaches.
- **Governing:** the result constrains, authorizes, prohibits, prioritizes, interprets, or establishes a meaningful default for future work.
- **Material:** losing the judgment or its rationale would create meaningful risk of repeated debate, inconsistent work, bad generalization, mistaken authority, expensive reversal, or misunderstanding of repository history.

Materiality is contextual. Do not assign a numeric materiality score. Breadth of effect, recurrence, reversibility, risk, uncertainty, external commitment, conflict with prior direction, and precedent value are useful signals.

An MJR may be a `decision`, `interpretation`, `assumption`, `tradeoff`, `conflict_resolution`, `scope_boundary`, `exception`, or `intentional_departure`. Use `other` only when none of these fit.

### 3.1 Completion boundary

Create an MJR only after the judgment episode has reached a durable completion boundary. A completion boundary exists when an affected artifact has been created or changed, the work governed by the judgment has been completed, or the authorized actor explicitly directs that the record be completed.

A settled statement in an active discussion does not by itself create an MJR. Keep the evolving discussion in its task, issue, pull request, or conversation until a completion boundary exists.

## 4. MJR exclusions

Do not create an MJR for any of the following by themselves:

- An open question, observation, requirement, recommendation, or tentative analysis.
- A direct instruction to make an already-defined change.
- A routine, obvious, or readily reversible implementation choice.
- An execution log, status report, incident report, test result, or validation result.
- An agent's internal micro-choice or exhaustive reasoning trace.
- A tentative or intermediate judgment made during an active discussion.

An open material question is not an MJR. A requirement or observation may be evidence in an MJR. A recommendation may be recorded as an agent contribution or considered option after a qualified actor settles the matter. A later implementation, validation result, or outcome links to the MJR and does not replace it.

## 5. Record ownership and discovery

Each project `MUST` maintain one discoverable canonical judgment-record location and index. Unless the repository defines another convention, use `<project_root>/docs/judgments/` and maintain `<project_root>/docs/judgments/index.md`.

The index `MUST` include each MJR and JFR's global ID, local display ID when used, type, title, publication date, scope summary when applicable, linked MJR, and link. Do not maintain a second competing index.

Use a globally unique `id` that is independent of a filename, local sequence, repository name, or path. A local display ID such as `MJR-014` may remain useful for human discussion but is not sufficient for corpus identity.

Each new MJR `MUST` identify:

- the repository through a stable `repository_id`;
- the record path; and
- the judgment episode through a task, issue, pull request, conversation, or other durable reference when available.

Use a stable reference, commit, version, timestamp, artifact ID, or minimal captured excerpt when mutable history would otherwise make the contemporaneous basis ambiguous.

## 6. MJR structure

Store canonical records as Markdown with YAML frontmatter. The frontmatter is the compact, machine-readable view used for indexing and aggregation. The Markdown body is the human-reviewable evidence.

### 6.1 Required frontmatter

```yaml
schema_version: judgment/v0.1
id: j:<globally-unique-id>
local_id: MJR-<local-sequence>
title: <concise title>

source:
  repository_id: <stable repository ID>
  path: <record path>
  work_revision: <repository revision when the judgment was made, when available>
  episode_ref: <task, issue, pull request, conversation, or other reference>
  execution_evidence_refs: []

settlement:
  settled_at: <ISO 8601 timestamp>
  recorded_at: <ISO 8601 timestamp>
  status: final
  kind: decision # See the allowed kinds above.

scope:
  applies_to: [<repository, component, task class, or artifact>]
  conditions: []
  excludes: []
  precedent: case_only # case_only | default_in_scope | binding_in_scope

authority:
  settled_by: <person or agent actor ID>
  basis: <owner decision, delegated authority, or established policy>
  settlement_evidence_ref: <reference to the settlement>

contributions:
  - actor: <person or agent actor ID>
    actor_type: person # person | software_agent
    roles: [<one or more contribution roles>]
    contribution_ref: <reference when needed>
    disposition: not_applicable # adopted | modified | rejected | not_evaluated | not_applicable

relations: []
sensitivity: internal # public | internal | restricted
```

`settled_at` is when the judgment became governing. `recorded_at` is when the completed MJR was published. They may differ. `work_revision` identifies the repository state in which the judgment was made, not the revision that published the record. Source control preserves the published record and its revision without adding a later edit to the MJR.

The record `MUST` preserve enough source evidence to substantiate the claimed settlement. Do not claim that a person supplied reasoning, settled a matter, or approved a proposal unless the available evidence supports it.

### 6.2 Actors, contribution, and authority

Use stable actor IDs that can be safely used by the central corpus. A person ID may be pseudonymous when needed. An agent actor ID `SHOULD` distinguish, when practical, the agent system or configuration from a particular run.

Use only material contribution roles:

- `identified`
- `proposed`
- `provided_evidence`
- `evaluated`
- `challenged`
- `settled`
- `recorded`
- `reviewed`
- `implemented`
- `validated`

`settled_by` identifies the actor whose judgment governs the record. `basis` identifies why that actor could settle it. `contributions` identifies what each person or agent actually did. A person may settle an agent proposal without independently authoring its rationale. An agent may settle a matter only when its delegated authority is recorded.

When an MJR or JFR arises from agent behavior, include safe agent runtime information. Omit only a field that is unknown, unavailable, or unsafe to retain:

```yaml
agent:
  system_id: <agent system or configuration ID>
  system_version: <version or configuration reference>
  model_id: <model identifier when known>
  run_id: <execution or episode ID>
  instruction_profile_ref: <policy, skill, or prompt reference>
  tool_context_ref: <available tools and material tool-result references>
```

Do not rely on a model name alone as the agent identity. Do not store private chain-of-thought. `episode_ref`, `work_revision`, `instruction_profile_ref`, `tool_context_ref`, and `run_id` together make it possible to distinguish agent behavior from differences in task context, repository state, instructions, or tools.

### 6.3 Required body sections

Every MJR `MUST` include these sections:

#### 6.3.1 Context and scope

State the work being undertaken, desired outcome, relevant success criteria, and the conditions and exclusions that materially bound the judgment.

#### 6.3.2 Judgment required

State the point at which routine execution stopped and discretion was required. Describe the ambiguity, conflict, missing information, trade-off, or intended departure. Do not substitute the conclusion for the question that required judgment.

#### 6.3.3 Governing basis

State the material decision environment as known at the time. Identify the role of relevant information rather than silently promoting one category into another:

- explicit requirement or user decision;
- established project decision or convention;
- observed implementation, test, configuration, or other fact;
- evidence-based inference;
- new assumption; or
- unresolved uncertainty.

Reference authoritative artifacts rather than reproducing whole specifications, logs, or transcripts.

#### 6.3.4 Judgment

State the settled judgment plainly. State the resulting direction separately when future work is expected to follow it.

#### 6.3.5 Rationale

Explain concisely why the judgment was preferred given the governing basis and viable alternatives. State material decision drivers, constraints, and trade-offs. Do not invent rationale not supported by the identified contributors or evidence.

### 6.4 Conditional body sections

Include a section only when it materially improves later understanding or analysis:

- **Objectives and constraints:** when competing goals shaped the result.
- **Options considered:** when materially plausible alternatives were actually available. Include the unchanged state when it was a real option. If only one defensible path existed, state why.
- **Agent proposal or evaluation:** when an agent's recommendation, analysis, or disagreement matters to alignment analysis.
- **Assumptions and uncertainty:** when incomplete information materially qualifies the judgment. State a concrete revisit trigger when known.
- **Consequences and trade-offs:** when the effects or accepted disadvantages explain the decision.
- **Evidence:** when particular requirements, observations, or artifacts materially drove the conclusion. State each item's role.
- **Change from prior judgment:** when this record changes earlier direction. Identify the prior record and what changed.

## 7. Judgment Follow-up Record structure

A JFR captures a material event after an MJR is published. It `MUST` identify one linked MJR, the record it directly concerns, its event date, the actor that recorded it, its evidence, and one of these kinds:

- `implementation`
- `validation`
- `outcome`
- `error`
- `correction`
- `review`

Use `error` when an implementation, validation, or outcome exposes a material failure. Use `correction` when a published MJR or JFR contains an error. A correction `MUST` state the exact error and correction without altering the earlier record. Use a new MJR, not a JFR, when the governing judgment itself changes.

A JFR `MUST NOT` repeat the MJR's full rationale or become a general execution log. It records only the material later event and its relationship to the MJR.

### 7.1 Outcome and evaluation evidence

For a `validation`, `outcome`, or `error` JFR, state the expected outcome or success criterion, observed outcome, difference, impact, and evaluation basis. The record `MUST` use `unknown` when the information is unavailable rather than infer it.

The record `MUST` include material successful outcomes as well as failures. Successful outcomes establish the comparison needed to distinguish isolated failures from recurring conditions and to evaluate later changes.

Use these values in an evaluation:

- `outcome`: `met`, `partially_met`, `not_met`, or `unknown`
- `impact`: `none`, `low`, `medium`, `high`, or `unknown`
- `evaluation_basis`: `user_feedback`, `test`, `review`, `policy_check`, `observation`, or `other`
- `causal_status`: `observed`, `inferred`, `hypothesized`, or `unknown`

`causal_status` classifies the support for a causal claim. A JFR `MUST NOT` state or imply a root cause as established when it is only inferred or hypothesized.

## 8. Scope and precedent

The frontmatter and narrative together `MUST` make clear where the judgment applies and where it does not. Use `precedent` as follows:

- `case_only`: resolves this instance only. Do not generalize automatically.
- `default_in_scope`: the expected direction for analogous work within the stated scope, subject to a later material judgment.
- `binding_in_scope`: governing project direction within the stated scope until changed by authorized direction.

An MJR does not turn an assumption into a requirement, an observed fact into intended behavior, or a local convention into a rule outside its scope. Future work `MUST` reassess authority, scope, conditions, and applicability before relying on it.

## 9. Relationships

Use typed relationships rather than an unqualified related-record list. Use only relationships that materially help discovery or analysis.

- Judgment relationships: `supersedes`, `narrows`, `expands`, `exception_to`, `conflicts_with`, `depends_on`.
- Follow-up relationships: `implements`, `validates`, `records_outcome_for`, `records_error_for`, `corrects`, `reviews`.
- Episode relationships: `prompted_by`, `derived_from`.

The relationship source is the current record. For example, a new record that changes an old record uses `supersedes` with the prior MJR as target. Do not use relationship types to imply authority that the record has not established.

## 10. Immutability, corrections, and review

An MJR preserves what was known and governing when it was settled. A JFR preserves what was observed or asserted when it was recorded. Neither is an account rewritten with later knowledge.

After publication, an MJR or JFR file `MUST NOT` be changed, including for editorial or factual corrections. The index may add a new record, but it `MUST NOT` alter the older record's published content.

When a material judgment changes, create a new MJR with a `supersedes`, `narrows`, `expands`, or `exception_to` relationship to the earlier record. Do not alter the earlier MJR's status or relations.

Record later implementation, validation, outcomes, errors, corrections, and reviews as JFRs. They `MUST NOT` silently change who settled the original judgment, what evidence existed at settlement, or why it was made.

A person may create a JFR that explicitly affirms, reviews, or corrects an agent-settled MJR, or create a successor MJR that narrows or supersedes it. Lack of review is not approval.

## 11. Central corpus and schema evolution

A central corpus is an ingestion and analysis layer. For every ingested item, retain the original record payload, repository identity, source path, source revision, ingestion time, and any normalization or transformation version.

The corpus may normalize older records into a current analytical schema. It `MUST NOT` overwrite the original payload or rewrite its historical meaning solely for schema consistency.

`schema_version` describes the record format. It is separate from the relationship between successor judgments. Do not mass-rewrite historical records merely to make them conform to a newer template.

### 11.1 Analysis boundary

Analysis may compare records and execution evidence to identify recurring conditions, candidate causes, and proposed interventions. It `MUST` preserve the distinction between evidence and hypothesis. A pattern does not become a rule, root-cause finding, or required agent change without sufficient supporting evidence and appropriate authorization.

## 12. Privacy, security, and retention

Set `sensitivity` according to the content's access expectations. Do not include credentials, secrets, unnecessary personal data, private chain-of-thought, or wholesale transcripts by default.

Prefer a stable reference or minimal relevant excerpt over copying raw conversation, prompt, log, or source material. A referenced artifact may remain in a restricted system while the MJR retains a non-sensitive reference. Retain durable judgment evidence longer than raw execution traces when the latter no longer add material value.

When redaction, legal deletion, or other policy requires removal, preserve a non-sensitive tombstone or provenance note when permitted so the corpus does not silently misrepresent its history.

## 13. Agent workflow

For routine work, proceed without creating a record.

For a material judgment within explicit delegated authority, the agent `MUST` settle the matter and continue the work. It `MUST` create an MJR only after the completion boundary in 3.1. It `MUST` identify its authority basis and contribution roles.

For a material judgment outside delegated authority or genuinely unresolved, the agent `MUST` surface the question to the appropriate authority before dependent work proceeds. Once it is settled and reaches a completion boundary, the agent `MUST` create an MJR that preserves the answer or approval reference. It `MUST NOT` describe a proposal, assumption, or silence from the owner as a settled user judgment.

After an MJR is published, an agent `MUST NOT` edit it. The agent `MUST` create a JFR for a later material event, or a successor MJR when the governing judgment changes.

## 14. Templates

### 14.1 MJR template

```md
---
schema_version: judgment/v0.1
id: j:<globally-unique-id>
local_id: MJR-<local-sequence>
title: <concise title>

source:
  repository_id: <stable repository ID>
  path: docs/judgments/<record>.md
  work_revision: <repository revision when the judgment was made, when available>
  episode_ref: <task, issue, pull request, conversation, or other reference>
  execution_evidence_refs: []

settlement:
  settled_at: <ISO 8601 timestamp>
  recorded_at: <ISO 8601 timestamp>
  status: final
  kind: <decision | interpretation | assumption | tradeoff | conflict_resolution | scope_boundary | exception | intentional_departure | other>

scope:
  applies_to: [<target>]
  conditions: []
  excludes: []
  precedent: <case_only | default_in_scope | binding_in_scope>

authority:
  settled_by: <actor ID>
  basis: <authority basis>
  settlement_evidence_ref: <reference>

contributions:
  - actor: <actor ID>
    actor_type: <person | software_agent>
    roles: [<identified | proposed | provided_evidence | evaluated | challenged | settled | recorded | reviewed | implemented | validated>]
    contribution_ref: <reference when needed>
    disposition: <adopted | modified | rejected | not_evaluated | not_applicable>

# Include when the record arises from agent behavior.
agent:
  system_id: <agent system or configuration ID when applicable>
  system_version: <version or configuration reference when applicable>
  model_id: <model identifier when known>
  run_id: <execution or episode ID>
  instruction_profile_ref: <policy, skill, or prompt reference>
  tool_context_ref: <available tools and material tool-result references>

relations: []
sensitivity: internal
---

# <title>

## 1. Context and scope

<Work, desired outcome, success criteria, and material boundaries.>

## 2. Judgment required

<What made routine execution insufficient.>

## 3. Governing basis

<Material requirements, established direction, facts, inferences, assumptions, and uncertainty, with their roles distinguished.>

## 4. Judgment

<The settled judgment.>

## 5. Direction

<Resulting direction for future work, if the judgment establishes direction.>

## 6. Rationale

<Why this judgment was preferable.>

## 7. Options considered

<Include only when materially plausible alternatives were actually considered.>

## 8. Assumptions and uncertainty

<Include only when material, with revisit conditions when known.>

## 9. Consequences and trade-offs

<Include only when material.>

## 10. Evidence

<Include only material evidence and its role.>

```

### 14.2 JFR template

```md
---
schema_version: judgment-follow-up/v0.1
id: jf:<globally-unique-id>
local_id: JFR-<local-sequence>
title: <concise title>

source:
  repository_id: <stable repository ID>
  path: docs/judgments/<record>.md
  work_revision: <repository revision for the later event, when available>
  episode_ref: <task, issue, pull request, conversation, or other reference>
  execution_evidence_refs: []

follow_up:
  recorded_at: <ISO 8601 timestamp>
  status: final
  kind: <implementation | validation | outcome | error | correction | review>
  mjr_id: j:<linked-MJR-ID>
  subject_id: <linked-MJR-or-JFR-ID>

recorded_by:
  actor: <person or software-agent actor ID>
  actor_type: <person | software_agent>

# Include when the record arises from agent behavior.
agent:
  system_id: <agent system or configuration ID when applicable>
  system_version: <version or configuration reference when applicable>
  model_id: <model identifier when known>
  run_id: <execution or episode ID>
  instruction_profile_ref: <policy, skill, or prompt reference>
  tool_context_ref: <available tools and material tool-result references>

# Include for validation, outcome, or error JFRs.
evaluation:
  expected_outcome: <success criterion or unknown>
  observed_outcome: <actual outcome or unknown>
  difference: <difference or unknown>
  outcome: <met | partially_met | not_met | unknown>
  impact: <none | low | medium | high | unknown>
  basis: [<user_feedback | test | review | policy_check | observation | other>]
  causal_status: <observed | inferred | hypothesized | unknown>

relations:
  - type: <implements | validates | records_outcome_for | records_error_for | corrects | reviews>
    target: <linked-MJR-or-JFR-ID>
sensitivity: internal
---

# <title>

## 1. Event

<The later material event and its date.>

## 2. Evidence

<Only the material evidence and its role.>

## 3. Effect on the linked MJR

<What the event confirms, corrects, challenges, or changes. A changed governing judgment requires a successor MJR.>

## 4. Outcome comparison

<For validation, outcome, or error records: expected outcome, observed outcome, difference, impact, and evaluation basis.>

## 5. Causal assessment

<Separate observed facts from evidence-supported inferences, hypotheses, and unresolved uncertainty.>
```

## 15. Conformance tests

### 15.1 MJR test

A competent future reviewer can determine, without rereading the entire original task or conversation:

- what required judgment;
- what was settled and what resulting direction, if any, governs;
- who contributed, who had authority, and who settled it;
- the material context, constraints, evidence, alternatives, and rationale;
- the expected outcome and success criteria, when they materially shaped the judgment;
- the scope, conditions, exclusions, and precedential force;
- how the record relates to prior direction, later implementation, and review; and
- which information was known at settlement versus learned later.

If these questions cannot be answered, add the missing material evidence or state the uncertainty. Do not compensate by adding irrelevant detail.

### 15.2 JFR test

A competent future reviewer can determine:

- the linked MJR and directly affected record;
- the later material event, its date, and its evidence;
- the actor that recorded the event; and
- for validation, outcome, and error records, the expected outcome, observed outcome, difference, impact, and evaluation basis; and
- whether each causal claim is observed, inferred, hypothesized, or unknown; and
- whether the event requires a successor MJR rather than a follow-up record.
