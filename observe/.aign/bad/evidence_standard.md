# Judgment Evidence Extension

**Status: Draft for discussion; non-authoritative.**

This document describes a proposed extension to [the Material Judgment Records standard](../.agents/gov/policy/execution/judgement_record.md). It creates no requirement or binding direction unless an authoritative source adopts it.

## 1. Purpose

The Material Judgment Records (MJR) standard preserves a completed, material exercise of discretion: what was settled, who had authority, the applicable context and constraints, rationale, scope, and resulting direction.

The proposed Judgment Evidence Extension preserves available evidence that surrounds, explains, tests, or follows that judgment. Its purpose is to make that evidence discoverable, attributable, and comparable across repositories without turning an MJR into an execution log or a full failure-management system.

## 2. Core separation

| Record or evidence | Principal question |
| --- | --- |
| MJR | What material judgment was settled, by whom, and with what scope and authority? |
| JFR | What material later implementation, validation, outcome, error, correction, or review concerns that judgment? |
| Judgment evidence | What available facts, artifacts, execution context, evaluation, or analysis help explain or assess the judgment episode? |

An execution trace is not a judgment. A test result, user correction, or failed outcome is not a settled interpretation. A diagnostic hypothesis or replay result does not silently revise an earlier MJR. Each may be linked evidence when it materially helps a future reviewer understand the record.

## 3. Scope boundary

This extension is evidence-oriented, not harness-oriented.

It does not require a specific agent runtime, telemetry protocol, trace viewer, storage product, task system, or failure taxonomy. It can link to evidence from any of those systems through stable references, identifiers, revisions, hashes, or concise retained excerpts.

It also does not require complete evidence for every judgment. A judgment record remains valid when a trace, task contract, outcome measurement, or replay fixture was not created, is unavailable, is unsafe to retain, or is not material. The extension should record the evidence that exists and material gaps or limits when those affect interpretation.

This extension does not create a requirement to capture every run, tool call, micro-decision, internal reasoning trace, failure, or remediation. It is a portable way to relate available evidence to material judgment records.

## 4. Evidence that may be linked when available

### 4.1 Before or at settlement

- Task, issue, request, or task-contract references.
- Applicable requirements, policies, prior judgments, permissions, or project direction.
- Repository, artifact, prompt, instruction, tool, model, or environment revisions.
- Relevant observations, source material, alternatives, assumptions, and uncertainty.
- Agent runtime identity and available capabilities when agent behavior is material to the episode.

### 4.2 Execution and produced artifacts

- Trace, transcript, command, tool-result, handoff, or state-change references.
- Inputs, outputs, deliverables, diffs, commits, tests, and other produced artifacts.
- Effective context or retrieval evidence when it is available and material.
- Declared plan or rationale as observable output, without treating it as proof of an agent's internal reasoning.

### 4.3 Later outcome, evaluation, and analysis

- User feedback, review, validation, test, policy-check, or downstream-outcome evidence.
- Evaluator identity, rubric, version, inputs, and limitations.
- Diagnostic hypotheses, including supporting and contrary evidence.
- Replay, comparison, or experiment evidence, including conditions held fixed and material limits.
- Links to related episodes, recurring patterns, remediation decisions, and successor judgments.

## 5. Evidence and claim status

The extension should preserve the difference between these claim types:

- **Observation:** a recorded action, artifact, result, state, or feedback item.
- **Evaluation:** an assessment against a stated criterion, including its evaluator and basis.
- **Inference:** a conclusion supported by available evidence but not directly observed.
- **Hypothesis:** an unconfirmed possible explanation.
- **Tested finding:** a bounded conclusion supported by a comparison, replay, or other stated test.

An evidence link should identify its source, revision or observation time when known, and its role in the episode. A later reviewer must be able to distinguish what was known when the judgment was settled from what was learned later.

## 6. Relationship to MJR and JFR records

MJR and JFR files remain the canonical records of the judgment and later material events. Evidence may be referenced directly from their existing `execution_evidence_refs` fields or from a separate, linked evidence record when the evidence needs more structure or is shared by several records.

A separate evidence record should identify:

- the linked MJR or JFR and, when available, the underlying task or execution episode;
- the evidence item's type, source, stable reference, revision, and sensitivity;
- when the evidence was created or observed;
- the claim type and its role in interpreting the judgment;
- material availability limits, redactions, or uncertainty; and
- any relationship to other evidence, such as supporting, contradicting, derived-from, or evaluating.

The evidence record adds context. It does not alter the settled authority, rationale, scope, or historical content of an MJR. A material change to governing judgment remains a successor MJR; a material later event remains a JFR.

## 7. Portability and retention

Evidence references should remain meaningful outside the originating harness whenever practical. Prefer durable repository paths and revisions, content hashes, artifact identifiers, stable external references, or concise retained excerpts over product-specific links alone.

The extension should preserve only evidence that is material and safe to retain. It should not require private chain-of-thought, credentials, secrets, unnecessary personal data, or wholesale raw transcripts. When evidence cannot be retained, the record may preserve a safe reference, classification, or statement of the limitation.

## 8. Intended analytical value

By keeping judgment records distinct from available supporting evidence, the combined corpus can later examine:

- how human and agent contributions, authority, and settlements differ;
- which context, constraints, or evidence recur around similar judgments;
- whether outcomes or later reviews support, challenge, or narrow prior direction; and
- whether a candidate lesson is local to a source, condition, or harness, or is supported across several contexts.

The corpus must not turn correlation, a repeated pattern, or a local record into a universal rule without appropriate evidence and authority.

## 9. Design principle

The durable unit is a material judgment record with an optional, structured evidence neighborhood. The objective is not comprehensive surveillance of agent execution. It is durable, harness-agnostic evidence that lets future reviewers understand and assess meaningful judgment in its actual context.
