# Material Episode Record Schema

## 1. Purpose and scope

This document is a readable reference for [`episode-record.schema.json`](episode-record.schema.json), the JSON Schema 2020-12 definition for Material Episode Records.

The schema defines the shared machine-verifiable structure for Judgment Records (`JR`), Judgment Update Records (`JUR`), Failure Records (`FR`), and Failure Update Records (`FUR`). It permits partial drafts and applies extra structural requirements to publishable records. The related specialist standards decide qualification, applicability, materiality, and semantic completeness.

The schema identifier is `https://gov-lab.local/observe/episodes/episode-record.schema.json`.

## 2. Validation rules that apply to every record

### 2.1 Root object

Each record is an object. Additional properties are not allowed.

| Field | Type | Required | Constraints and meaning |
| --- | --- | --- | --- |
| `id` | string | Yes | Non-empty stable record identifier, independent of location and local sequence. |
| `record_type` | string | Yes | One of `JR`, `JUR`, `FR`, or `FUR`. |
| `schema_version` | string | Yes | Non-empty version of the structural format. It is not a judgment or failure classification. |
| `record_status` | string | Yes | `draft` or `publishable`. |
| `title` | string | For publishable records | Non-empty title. |
| `local_id` | string | No | Non-empty local identifier. |
| `recorded_at` | timestamp | For publishable records | Date-time at which the record was recorded. |
| `event_at` | timestamp | For publishable JUR and FUR records | Date-time of the later event. |
| `recorded_by` | [actor](#45-actor) | For publishable JUR records | Actor that recorded the update. |
| `sensitivity` | sensitivity | No | `public`, `internal`, or `restricted`. |

### 2.2 Common record fields

All fields in this section are optional unless a publishable profile in section 3 requires them.

| Field | Value |
| --- | --- |
| `source` | [source](#410-source) |
| `episode` | [episode](#411-episode) |
| `intended_outcome` | [information item](#43-information-item) |
| `success_criteria`, `constraints`, `instructions` | Array of [information items](#43-information-item) |
| `authority` | [authority](#412-authority) |
| `judgment` | [judgment](#413-judgment) |
| `actors` | Array of [actors](#45-actor) |
| `agent_context` | Array of [agent contexts](#46-agent-context) |
| `tools` | Array of [tool contexts](#49-tool-context) |
| `runtime`, `environment` | [context item](#44-context-item) |
| `artifacts`, `commands`, `tool_results`, `changes`, `tests`, `external_state`, `feedback`, `reviews`, `remediation`, `corrections`, `later_outcomes` | Array of [evidence items](#422-evidence-item) |
| `evidence` | Array of [evidence items](#422-evidence-item) for material evidence not represented more specifically elsewhere |
| `supporting_evidence`, `contrary_evidence` | Array of [evidence items](#422-evidence-item) |
| `claims`, `assumptions`, `inferences`, `hypotheses`, `tested_findings` | Array of [claims](#423-claim) |
| `outcome` | [outcome](#414-outcome) |
| `impact` | [impact](#415-impact) |
| `evaluation` | [evaluation](#416-evaluation) |
| `failure` | [failure](#417-failure) |
| `violation` | [violation](#418-violation) |
| `investigation` | [investigation](#419-investigation) |
| `corrective_actions` | Array of [corrective actions](#420-corrective-action) |
| `relationships` | Array of [relationships](#421-relationship) |

## 3. Publishable profiles

A `draft` can be partial. A `publishable` record always requires `title` and `recorded_at`, in addition to the four root fields in section 2.1. The following rules then apply by `record_type`.

| Type | Additional required root fields | Required nested fields |
| --- | --- | --- |
| `JR` | `authority`, `judgment` | `judgment.judgment_kind`, `settled_at`, `completion_boundary`, `judgment_required`, `governing_basis`, `settled_statement`, `direction`, `rationale`, and `scope`; `scope.precedent` |
| `JUR` | `event_at`, `recorded_by`, `judgment` | `judgment.subject_record_id`, `judgment.update_kind` |
| `FR` | `failure`, `violation`, `impact` | `failure.name`, `failure.harness`; `violation.statement`, `applicable_expectation`, `observed_departure` |
| `FUR` | `event_at`, `failure` | `failure.subject_record_id`, `failure.update_kind` |

These profiles only validate structure. The specialist standards determine whether a record qualifies and whether its evidence is semantically complete.

## 4. Reusable definitions

### 4.1 Shared scalar values

| Name | Representation | Permitted values or constraints |
| --- | --- | --- |
| `timestamp` | string | JSON Schema `date-time` format. |
| `availability` | string | `available`, `unavailable`, `not collected`, `restricted or unsafe to retain`, or `not applicable`. |
| `sensitivity` | string | `public`, `internal`, or `restricted`. |

### 4.2 Reference

A reference identifies evidence or another external item. No fields are required, and additional properties are not allowed.

| Field | Type | Constraints |
| --- | --- | --- |
| `id`, `kind`, `location`, `revision`, `content_hash` | string | Non-empty when present. |
| `observed_at` | timestamp | When the item was observed. |
| `excerpt`, `note` | string | Optional text. |
| `sensitivity` | sensitivity | Optional handling classification. |

### 4.3 Information item

An information item represents a statement with its availability and optional source. Additional properties are not allowed.

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of the information. |
| `statement` | string | No | The information statement. |
| `reference` | [reference](#42-reference) | No | Supporting reference. |
| `note` | string | No | Additional qualification. |

### 4.4 Context item

A context item describes runtime or environment context. Additional properties are not allowed.

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of the context. |
| `name`, `version`, `details`, `note` | string | No | Identifying or explanatory text. |
| `reference` | [reference](#42-reference) | No | Evidence for the context. |

### 4.5 Actor

An actor identifies a participant. Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `id` | string | Yes | Non-empty identifier. |
| `actor_type` | string | Yes | `person`, `software_agent`, `tool`, `service`, `organization`, or `unknown`. |
| `roles` | array of string | No | Unique values: `identified`, `proposed`, `provided_evidence`, `evaluated`, `challenged`, `settled`, `recorded`, `reviewed`, `implemented`, `validated`, `investigated`, `corrected`, or `other`. |
| `availability` | availability | No | Availability of actor information. |
| `note` | string | No | Additional qualification. |

### 4.6 Agent context

An agent context captures execution context for an agent. Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of the context. |
| `actor_id`, `system_id`, `system_version`, `model_id`, `run_id`, `note` | string | No | Identifiers or explanatory text; identifiers are non-empty when present. |
| `reasoning_configuration` | [reasoning configuration](#47-reasoning-configuration) | No | Provider- or harness-reported setting. |
| `context_window` | [context window](#48-context-window) | No | Context-window telemetry. |
| `instruction_profile`, `tool_context` | [reference](#42-reference) | No | References to the applied instruction or tool context. |

### 4.7 Reasoning configuration

Values are provider-specific and are not assumed equivalent across providers. Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of the setting. |
| `provider_setting_name`, `provider_setting_value` | string | No | Non-empty when present. |
| `source` | string | No | `runtime_metadata`, `run_configuration`, `agent_report`, `operator_report`, `inferred`, or `unknown`. |
| `reference` | [reference](#42-reference) | No | Supporting reference. |
| `note` | string | No | Additional qualification. |

### 4.8 Context window

Context-window telemetry may be reported, calculated, or estimated. Token counts and saturation are optional because providers can reserve output capacity or use different accounting methods. Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of telemetry. |
| `used_tokens` | integer | No | At least `0`. |
| `capacity_tokens` | integer | No | At least `1`. |
| `saturation_percent` | number | No | Between `0` and `100`, inclusive. |
| `window_scope` | string | No | `input_context`, `combined_context_and_output_reservation`, `provider_defined`, or `unknown`. |
| `measurement_basis` | string | No | `directly_reported`, `calculated_from_reported_counts`, `estimated`, `inferred`, or `unknown`. |
| `observed_at` | timestamp | No | Observation time. |
| `limit_reached` | boolean | No | Whether a limit was reached. |
| `reference` | [reference](#42-reference) | No | Supporting reference. |
| `note` | string | No | Additional qualification. |

### 4.9 Tool context

A tool context describes an available tool. Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of the tool context. |
| `name`, `version`, `provider`, `note` | string | No | `name` is non-empty when present. |
| `capabilities` | array of string | No | Tool capabilities. |
| `reference` | [reference](#42-reference) | No | Supporting reference. |

### 4.10 Source

A source identifies the repository and source record context. Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of source information. |
| `repository_id`, `record_path`, `work_revision` | string | No | Non-empty when present. |
| `references` | array of [references](#42-reference) | No | Related source references. |
| `limitation` | string | No | Source limitation. |

### 4.11 Episode

An episode links the record to related work. Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of episode information. |
| `episode_id` | string | No | Non-empty identifier. |
| `task_references`, `issue_references`, `request_references`, `related_episode_references` | array of [references](#42-reference) | No | Related items by kind. |
| `limitation` | string | No | Episode limitation. |

### 4.12 Authority

Authority records how direction was settled. Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of authority information. |
| `settled_by` | string | No | Non-empty identifier of the settling party. |
| `basis` | [information item](#43-information-item) | No | Basis for authority. |
| `permissions`, `established_direction` | array of [information items](#43-information-item) | No | Applicable permissions or direction. |
| `settlement_evidence` | [evidence item](#422-evidence-item) | No | Evidence of settlement. |
| `limitation` | string | No | Authority limitation. |

### 4.13 Judgment

Judgment-specific structure. The judgment specialist determines when its fields are required and whether the record qualifies as a JR or JUR. Additional properties are not allowed.

| Field | Type | Constraints |
| --- | --- | --- |
| `judgment_kind` | string | `decision`, `interpretation`, `assumption`, `tradeoff`, `conflict_resolution`, `scope_boundary`, `exception`, `intentional_departure`, or `other`. |
| `update_kind` | string | `implementation`, `validation`, `outcome`, `error`, `correction`, or `review`. |
| `settled_at` | timestamp | Settlement time. |
| `completion_boundary`, `judgment_required`, `settled_statement`, `direction`, `rationale` | [information item](#43-information-item) | Judgment content. |
| `governing_basis`, `alternatives_considered`, `revisit_triggers`, `consequences`, `accepted_tradeoffs` | array of [information items](#43-information-item) | Judgment context. |
| `scope` | object | Contains `applies_to`, `conditions`, and `excludes` as arrays of information items, and `precedent` as `case_only`, `default_in_scope`, or `binding_in_scope`. No additional properties. |
| `subject_record_id` | string | Non-empty identifier of the JR being updated. |

### 4.14 Outcome

An outcome compares expected and observed results. Additional properties are not allowed.

| Field | Type | Constraints |
| --- | --- | --- |
| `availability` | availability | Optional availability marker. |
| `expected`, `observed`, `difference` | [information item](#43-information-item) | Optional outcome information. |
| `status` | string | `met`, `partially_met`, `not_met`, or `unknown`. |

### 4.15 Impact

Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of impact information. |
| `level` | string | No | `none`, `low`, `medium`, `high`, or `unknown`. |
| `description` | string | No | Impact description. |
| `affected_scope` | array of [references](#42-reference) | No | Affected items. |

### 4.16 Evaluation

Additional properties are not allowed.

| Field | Type | Constraints |
| --- | --- | --- |
| `availability` | availability | Optional availability marker. |
| `basis` | array of string | Unique values: `user_feedback`, `test`, `review`, `policy_check`, `observation`, or `other`. |
| `evaluator` | [actor](#45-actor) | Optional evaluator. |
| `criterion` | [information item](#43-information-item) | Optional criterion. |
| `causal_status` | string | `observed`, `inferred`, `hypothesized`, or `unknown`. |
| `reference` | [reference](#42-reference) | Optional supporting reference. |
| `limitations` | string | Optional limitations. |

### 4.17 Failure

Additional properties are not allowed. If `update_kind` is `other`, `update_kind_note` is required.

| Field | Type | Constraints |
| --- | --- | --- |
| `name` | string | Non-empty failure name. |
| `classifications` | array of string | Non-empty, unique values. |
| `harness` | string | Non-empty open harness identifier; values may include `manual` or `unknown`. |
| `prevention_loci` | array of string | Unique values: `agent_level`, `tool_level`, `shared_agent_and_tool`, `task_or_external`, or `unresolved`. |
| `classification_note` | string | Optional classification qualification. |
| `subject_record_id` | string | Non-empty identifier of the FR being updated. |
| `update_kind` | string | `investigation`, `containment`, `corrective_action`, `validation`, `correction`, `review`, `recurrence`, `outcome`, or `other`. |
| `update_kind_note` | string | Required when `update_kind` is `other`. |

### 4.18 Violation

Additional properties are not allowed.

| Field | Type | Constraints |
| --- | --- | --- |
| `detected_at` | timestamp | Detection time. |
| `detection_source` | [evidence item](#422-evidence-item) | Evidence that detected the violation. |
| `statement`, `applicable_expectation`, `observed_departure` | [information item](#43-information-item) | Violation content. |
| `affected_scope` | array of [references](#42-reference) | Affected items. |
| `immediate_containment` | array of [information items](#43-information-item) | Immediate containment actions. |

### 4.19 Investigation

Additional properties are not allowed.

| Field | Type | Constraints |
| --- | --- | --- |
| `status` | string | `not_started`, `in_progress`, `completed`, `deferred`, or `not_applicable`. |
| `investigators` | array of [actors](#45-actor) | Investigators. |
| `originating_agent_account` | [information item](#43-information-item) | Account from the originating agent. |
| `findings` | array of [claims](#423-claim) | Investigation findings. |
| `evidence_limitations` | array of [information items](#43-information-item) | Limits on available evidence. |
| `completed_at` | timestamp | Completion time. |

### 4.20 Corrective action

Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `id` | string | No | Non-empty action identifier. |
| `description` | string | Yes | Non-empty action description. |
| `target` | [information item](#43-information-item) | No | Action target. |
| `disposition` | string | Yes | `proposed`, `accepted`, `rejected`, `deferred`, `implemented`, `validated`, or `ineffective`. |
| `selected_by` | [actor](#45-actor) | No | Selecting party. |
| `rationale` | [information item](#43-information-item) | No | Action rationale. |
| `implemented_at` | timestamp | No | Implementation time. |
| `validation` | [evaluation](#416-evaluation) | No | Action validation. |
| `related_record` | [reference](#42-reference) | No | Related record. |

### 4.21 Relationship

Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `type` | string | Yes | `supersedes`, `narrows`, `expands`, `exception_to`, `conflicts_with`, `depends_on`, `implements`, `validates`, `records_outcome_for`, `records_error_for`, `corrects`, `reviews`, `challenges`, `prompted_by`, `derived_from`, `investigates`, `updates`, `remediates`, `recurs_from`, `relates_to`, or `other`. |
| `target_id` | string | Yes | Non-empty stable identifier of the related record. |
| `note` | string | No | Relationship qualification. |

### 4.22 Evidence item

An evidence item describes retained evidence or evidence that is unavailable. Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `availability` | availability | Yes | Availability of the evidence. |
| `type` | string | No | `task`, `issue`, `request`, `requirement`, `policy`, `judgment`, `instruction`, `prompt`, `artifact`, `command`, `tool_result`, `change`, `test`, `external_state`, `feedback`, `review`, `evaluation`, `trace`, `transcript`, `replay`, `comparison`, `agent_account`, `investigator_finding`, or `other`. |
| `role` | string | No | `context`, `authority`, `constraint`, `supporting`, `contrary`, `detection`, `containment`, `investigation`, `validation`, `outcome`, `correction`, or `other`. |
| `reference` | [reference](#42-reference) | No | Evidence location or identity. |
| `summary`, `retention_note` | string | No | Evidence summary or retention qualification. |
| `observed_at` | timestamp | No | Observation time. |

### 4.23 Claim

Additional properties are not allowed.

| Field | Type | Required | Constraints |
| --- | --- | --- | --- |
| `status` | string | Yes | `observation`, `evaluation`, `inference`, `hypothesis`, or `tested_finding`. |
| `statement` | string | Yes | Non-empty claim statement. |
| `evidence_references`, `contrary_evidence_references` | array of [references](#42-reference) | No | Supporting or contrary evidence. |
| `limitations` | string | No | Claim limitations. |
| `tested_at` | timestamp | No | Test time. |

## 5. Validation boundary

The schema validates field names, JSON types, required fields, controlled values, selected numeric bounds, uniqueness constraints, and the publishable profiles in section 3. It does not determine whether a judgment or failure qualifies, whether a classification is correct, or whether a record is semantically complete.
