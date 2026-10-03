This is a lightweight data schema for material episode records. It describes information that a judgment or failure record can make available. It does not prescribe a report file, frontmatter, serialized format, or universal required-field profile.

A record carries only the fields that materially apply. When material information is unavailable, retain that limitation rather than inventing a value.

## 1. Shared types

### 1.1 Availability

- available - The information is present in the record.
- unknown - The information may exist, but is not known to the recorder.
- not_collected - The information could have been collected but was not.
- unsafe_to_retain - The information exists but must not be stored in the record.
- not_applicable - The information does not apply to this episode.

### 1.2 Reference

- kind - The referenced item type, such as a task, conversation, file, commit, test, issue, URL, record, or other artifact.
- location - A stable link, path, or identifier that locates the referenced item.
- revision - The relevant commit, version, or observation time when the referenced item can change.
- summary - A concise explanation of why the referenced item matters.

### 1.3 Actor

- id - A stable identifier for the participant when one is known and safe to retain.
- kind - The participant type: person, agent, tool, service, organization, or unknown.
- role - The participant's material role in the episode, such as settled, proposed, implemented, reviewed, or investigated.

### 1.4 Relationship

- type - The relationship type: updates, supersedes, corrects, caused, relates_to, implements, validates, or other.
- target_id - The identifier of the related record or artifact.
- note - A concise qualification of the relationship when the relationship type alone is insufficient.

### 1.5 Optional information

Any optional field or group may state its availability as available, unknown, not_collected, unsafe_to_retain, or not_applicable. State a concise limitation when that status materially affects the record.

## 2. Common material record schema

These fields are available on every JR, JUR, FR, and FUR.

### 2.1 Material record

- id - The stable, canonical identifier of this record.
- record_type - The record family: JR, JUR, FR, or FUR.
- title - A concise, specific description of the recorded episode.
- recorded_at - The time at which this record was created.
- event_at - The time at which the recorded judgment, failure, or later update occurred, when it differs from recorded_at or is material.
- recorded_by - The actor that created the record.
- source - The repository, project, or system in which the episode occurred, with relevant work references.
- episode - The task, issue, request, conversation, or other work unit to which the record belongs.
- context - The intended outcome, constraints, and material circumstances of the work.
- actors - The people, agents, tools, services, or organizations that materially participated.
- evidence - References and concise summaries of information supporting the record.
- limitations - Material information that is unknown, unavailable, not collected, or unsafe to retain.
- relationships - Typed links to related records, work, or artifacts.
- execution_context - The technical and instruction context that materially affected the episode.

### 2.2 Execution context

- availability - Whether execution-context information is available, unknown, not collected, unsafe to retain, or not applicable.
- harness - The agent harness, workflow, or execution environment, such as manual, Codex, CI, or another system.
- provider - The provider of the participating model or agent system.
- agent_system - The name or stable identifier of the participating agent system or configuration.
- agent_version - The version, configuration revision, or stable reference for the agent system.
- model - The model identifier used by the participating agent when known.
- model_version - The model release, snapshot, or provider version when reported.
- run_id - The provider or harness run identifier when available and safe to retain.
- reasoning_configuration - The provider-reported reasoning setting or other relevant execution configuration.
- context_window - Available context-window information, including measured use, capacity, measurement basis, and whether a limit was reached.
- instruction_references - References to the system instructions, skills, policies, prompts, or task instructions that governed the work.
- tool_context - Material tools available to or used by the agent, including their provider, version, capability, and relevant result references.
- runtime - The relevant operating system, language runtime, dependency, or process context.
- environment - The relevant repository revision, branch, deployment target, configuration, or external-system state.
- commands - Commands that materially establish what was attempted, changed, or observed.
- tool_results - Material tool output, errors, or returned data that supports the record.

Execution context is optional unless it materially explains the judgment, violation, result, or limitation. A report may record a concise reference instead of retaining sensitive or voluminous details.

### 2.3 Update lineage

- subject_record_id - For a JUR or FUR, identifies the immediately preceding JR, JUR, FR, or FUR that this record updates.
- lineage - Following subject_record_id links from a JUR must ultimately reach a JR. Following subject_record_id links from a FUR must ultimately reach an FR.

## 3. Judgment record schema

### 3.1 Judgment record

- judgement_kind - The kind of judgment: decision, interpretation, assumption, tradeoff, conflict_resolution, scope_boundary, exception, or other.
- trigger - Whether the record was triggered by the user or the agent.
- activity - Whether the recorded judgment arose from user activity or agent activity.
- settled_at - The time at which the judgment became governing.
- completion_boundary - The event that made the judgment complete enough to record.
- judgement_required - The ambiguity, conflict, tradeoff, or discretionary choice that required judgment.
- governing_basis - The material information that governed the judgment.
  - requirements - Applicable explicit requirements, constraints, or user direction.
  - prior_direction - Existing judgments, policies, conventions, or decisions that applied.
  - observed_facts - Directly observed facts, implementation behavior, test results, or other evidence.
  - inferences - Conclusions reasonably drawn from evidence but not directly observed.
  - assumptions - Material propositions accepted without sufficient verification.
  - uncertainties - Material unknowns that qualify the judgment.
- authority - The actor and basis that made the judgment authoritative.
  - settled_by - The actor whose decision established the governing direction.
  - basis - The ownership, delegated authority, policy, or other basis for that actor's authority.
  - evidence - References supporting the claimed settlement and authority.
- settled_statement - The actual judgment, stated plainly.
- direction - The resulting action, constraint, authorization, or default for future work.
- rationale - The material reasons the judgment was chosen.
- scope - The boundary within which the judgment governs.
  - applies_to - The repositories, components, work classes, or artifacts within scope.
  - conditions - Conditions that must hold for the judgment to apply.
  - excludes - Cases or subjects that the judgment does not govern.
  - precedent - The intended force: case_only, default_in_scope, or binding_in_scope.
- alternatives_considered - Materially plausible options considered before settlement and why they were not chosen.
- accepted_tradeoffs - Material disadvantages, costs, or risks accepted by the judgment.
- revisit_triggers - Later conditions or evidence that should cause the judgment to be reconsidered.
- outcome - The expected and observed result when later outcome information is material and available.
- update - The change information required for a JUR.
  - subject_record_id - The JR or JUR directly updated by this record.
  - update_kind - The kind of material update: correction, supplement, changed_information, or other.
  - effect_on_judgement - How the new information changes, qualifies, or corrects the preceding judgment.
  - assessment - The resulting status: not_a_violation, concern, or violation.

## 4. Failure record schema

### 4.1 Failure record

- failure_ids - One or more stable identifiers from failures.md that classify the failure.
- detected_at - The time at which the failure or violation was detected.
- violation - The specific departure from an applicable expectation.
  - statement - A concise statement of the violation.
  - applicable_expectation - The requirement, constraint, rule, or expected behavior that applied.
  - observed_departure - What actually occurred and how it departed from the expectation.
- impact - The material effect of the failure.
  - level - The impact level: none, low, medium, high, or unknown.
  - description - A concise account of the actual or expected effect.
  - affected_scope - The affected users, systems, work, artifacts, or other scope.
- classification_data - The additional failure-specific data required by the matched failures.md definition.
- immediate_containment - Actions already taken to stop, limit, or repair the immediate effects of the violation.
- investigation - The current state and results of an Episode Investigation.
  - status - The investigation state: not_started, in_progress, completed, deferred, or not_applicable.
  - findings - Material observations, inferences, hypotheses, and conclusions from the investigation.
  - causal_status - The support for any causal account: observed, inferred, hypothesized, or unknown.
  - evidence_limitations - Gaps or limits that materially qualify the investigation.
  - prevention_loci - Where prevention may occur, such as agent, tool, instruction, workflow, task, or external system.
- corrective_actions - Recommended or completed actions addressing the violation.
  - description - The action proposed or taken.
  - status - The action state: recommended, accepted, implemented, rejected, or not_applicable.
  - owner - The responsible actor when known.
  - validation - Evidence that the action corrected the problem or reduced recurrence risk.
- update - The change information required for a FUR.
  - subject_record_id - The FR or FUR directly updated by this record.
  - update_kind - The kind of material update: investigation, containment, corrective_action, validation, correction, recurrence, outcome, or other.
  - effect - How the later event changes the understanding, impact, investigation, or corrective action of the preceding record.

A detected violation may exist before an investigation identifies a corrective action. A completed failure report includes at least one recommended corrective action established through its investigation.

## 5. Information represented through the shared fields

- Artifacts, tests, feedback, reviews, corrections, remediation, and external state - Record these as evidence when they materially support the judgment or failure.
- Claims, hypotheses, inferences, and tested findings - Record these in governing_basis or investigation.findings with their evidentiary status stated in the description.
- Sensitive or voluminous provider, model, tool, command, runtime, or environment data - Retain a safe concise summary or reference in execution_context instead of duplicating raw logs.
