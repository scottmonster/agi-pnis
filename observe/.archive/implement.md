**Status: Strictly non-authoritative reference material.**

This document is informational only. It creates no requirements, specifications, decisions, policies, obligations, approvals, interpretations, or binding guidance of any kind. Do not treat any part of it as controlling, implied, or actionable unless an authoritative source explicitly adopts the specific content at issue. In any conflict or ambiguity, authoritative sources control without exception.

# Implementing an evidence-first agent observatory

## 1. Decision

### 1.1 Build an episode evidence system, not a transcript archive

Implement a portable, evidence-first observatory whose durable unit is an `episode`: one bounded agent attempt to satisfy a versioned task contract. The system `MUST` preserve enough safe, structured evidence to establish what the agent was required to do, what it was able to observe and do, what it did, what outcome followed, and how that outcome was assessed.

The observatory `MUST` keep these claim types separate:

- **Observation:** a recorded action, input, result, or state change.
- **Evaluation:** a versioned assessment of an outcome against a requirement.
- **Hypothesis:** an unconfirmed explanation of a deviation.
- **Tested finding:** a result of a bounded replay or comparison.
- **Remediation:** a change decision and its later validation.

This directly serves the stated need to distinguish recurring system problems from isolated errors. It also prevents a trace, an LLM explanation, or a score from being mistaken for causal evidence.

### 1.2 Use a small, replaceable architecture

Use OpenTelemetry and OTLP for live correlation and transport; use an independent evidence store as the system of record. Use a relational database with explicit provenance relations and a content-addressed artifact store. The first release `MUST NOT` introduce a graph database, a custom agent framework, automatic root-cause analysis, or full-environment replay.

The selected structure is adequate because the current requirements are durable evidence, cross-episode queries, controlled diagnosis, and safe retention. A trace viewer alone cannot hold the task contract, outcome evidence, diagnostic status, or immutable artifact history. Conversely, a graph database or an autonomous diagnosis system adds operational and conceptual cost before the pilot has established that ordinary relational queries cannot answer its questions.

### 1.3 Treat the observability product as a replaceable view

For a self-hosted pilot, use Arize Phoenix as the trace and evaluation interface because it supports OpenTelemetry-based traces and experiment workflows. Keep its identifiers mapped to canonical `episode_id`, `activity_id`, and `artifact_id` values held outside Phoenix. Langfuse is an acceptable alternative when its existing operational workflow is a better fit. Neither product is the authoritative evidence store.

## 2. System shape

```text
Agent runtime
  -> capture adapter -> OpenTelemetry / OTLP -> collector -> trace viewer
                     \-> episode writer -> relational evidence store
                                           -> content-addressed artifact store

Task-contract authoring -> evidence store <- outcome checks and human review
                                         <- failure review and replay runner
```

### 2.1 Capture adapter

Provide a small runtime adapter or wrapper at the agent execution boundary. It `MUST` create the `episode_id`, attach it to the root trace, and emit structured events for material operations. It uses OpenTelemetry semantic conventions where applicable and adds only the application fields needed to join an event to the canonical record.

Required capture points are:

- episode start and finish;
- task-contract revision and capture profile;
- model calls, tool calls, handoffs, retries, guardrail decisions, and errors;
- retrieval, memory, policy, permission, and tool-definition references used at a material decision;
- external observations and state-changing effects;
- produced deliverables and validation results; and
- known uncertainty, requested clarification, and declared rationale when the runtime emits them.

The adapter `MUST` record observable outputs and declared rationale only. It `MUST NOT` capture or request hidden chain-of-thought.

### 2.2 Evidence storage

Use a relational database, such as PostgreSQL, for metadata and queryable relations. Use an S3-compatible object store for large, restricted, or immutable artifacts. In a single-machine prototype, local equivalents are acceptable only if the same interfaces and content-addressing rules are retained.

Store artifact content by hash. Each artifact record `MUST` include its ID, SHA-256 or stronger digest, media type, sensitivity classification, source, creation time, retention class, and revision identity. The database stores the metadata and a locator rather than duplicating large content in trace attributes or table rows.

The initial relational model is:

| Record | Purpose | Essential fields |
| --- | --- | --- |
| `episode` | Root execution record | ID, start/end time, status, runtime identity, capture profile, root trace ID |
| `task_contract_revision` | Meaning of success before execution | ID, objective, requirements, prohibitions, acceptance checks, authority, risk class |
| `activity` | Material model, tool, evaluation, or replay step | ID, episode ID, type, time, status, trace/span IDs |
| `artifact` | Immutable input, output, context, or result | ID, digest, version, classification, locator |
| `provenance_edge` | Explicit lineage relation | subject ID, predicate, object ID, asserted time, evidence reference |
| `outcome` | Observed result after execution | episode ID, result type, value/reference, observed time, source |
| `evaluation` | Versioned assessment | contract requirement, evaluator and rubric versions, input references, result, uncertainty |
| `failure_case` | Reviewed deviation | violated requirement, status, candidate step, evidence for and against, recurrence links |
| `experiment` | Replay or controlled comparison | baseline, intervention, held conditions, uncontrolled conditions, result, limitation |

Use a small fixed predicate vocabulary for `provenance_edge`: `used`, `generated`, `derived_from`, `constrained_by`, `evaluated_by`, `supported_by`, `contradicted_by`, and `intervened_on`. This provides the useful part of a provenance graph without making a graph database an initial dependency.

### 2.3 Versioned task contracts

Every consequential episode `MUST` refer to exactly one `task_contract_revision`. The contract `MUST` distinguish:

- hard requirements and prohibited outcomes;
- preferences;
- acceptance checks and their source of truth;
- applicable permissions and policies;
- known reference facts or fixtures; and
- task risk and required review level.

The task contract `MUST NOT` exist only in an evaluator prompt. It makes before-and-after comparisons meaningful when evaluators, prompts, or models change.

### 2.4 Effective context and provenance

At each material model decision, create references to the actual context supplied then, including post-compaction instructions, selected retrieval results and scores, read memory entries, tool and policy versions, permission result, budgets, and relevant environment observations. A later copy of a prompt, document, or vector-store record is not historical evidence.

Represent activities as using and generating artifacts. For example:

```text
retrieval-result:42 --used--> model-step:8
policy:v3             --constrained_by--> model-step:8
model-step:8          --generated--> tool-request:11
tool-request:11       --generated--> state-change:14
```

## 3. Evaluation and learning loop

### 3.1 Capture outcome before diagnosis

After an episode completes, record the observable outcome: deliverable, tests, policy checks, external state, user correction, reversal, complaint, or downstream result. An outcome signal `MUST` identify its source and observation time. Delayed user feedback is evidence, not a complete error-rate measurement.

Apply assessment in this order:

1. Deterministic checks, including tests, schemas, policy rules, authoritative state, and numerical tolerances.
2. Structured human review for ambiguous, novel, consequential, and taxonomy-defining cases.
3. Versioned LLM evaluation only for triage or scalable labeling after calibration against a representative human-labeled sample.

Every evaluation `MUST` record its rubric, evaluator identity and version, inputs, result, uncertainty, and supporting evidence. The evaluator itself is traced as an `activity`.

### 3.2 Review failures as cases

Create a `failure_case` only when an outcome or evaluation identifies a meaningful deviation. It `MUST` link the violated task-contract requirement to the evidence, name the earliest candidate decisive step, retain evidence that contradicts the hypothesis, and use one of these states: `unreviewed`, `hypothesis`, `reproduced`, `confirmed_for_stated_conditions`, or `rejected`.

Start with broad, changeable failure families: specification, context or retrieval, memory or state, planning, tool interface, runtime environment, orchestration, guardrail, resource budget, model variability, and measurement. Use the pilot corpus to split, merge, or retire categories only when doing so changes a decision.

Material settled judgments remain governed by the existing Material Judgment Record process. Link an MJR or follow-up record to an episode or failure case when it supplies authority for a change; the observatory `MUST NOT` create an MJR for every run, trace, or evaluation.

### 3.3 Use replay to test, not narrate

Build replay only after a failure case has reliable evidence fixtures. Implement recorded-observation replay first: return the historically captured tool and environment observations without calling live dependencies. This is the smallest mechanism that can test an important suspected condition.

For a recurring, high-value failure family, add counterfactual replay that changes one factor while retaining the recorded contract and all practical baseline conditions. Record the intervention, seed and model settings when available, baseline and comparison outcomes, variables that could not be held fixed, and the conclusion's limits. Defer full environment restoration until recorded-observation replay cannot reproduce a case that matters.

Promote only reproduced or strongly corroborated cases into regression suites. Each regression case needs its contract, permitted fixture, expected checks, applicability boundary, and link to originating evidence.

## 4. Safety, integrity, and retention

### 4.1 Capture profiles

Use one of three explicit profiles, selected by task risk and diagnostic need:

| Profile | Stored for every matching episode | Additional content |
| --- | --- | --- |
| `metadata` | IDs, versions, timings, outcomes, error classes, and non-sensitive correlations | None |
| `diagnostic` | Metadata plus bounded, allowlisted context and tool evidence | Restricted artifacts for errors, policy events, and selected samples |
| `replay` | Diagnostic evidence plus approved replay fixtures | Only content necessary to reproduce the selected case |

Default to `metadata`. Enrichment `MUST` be a deliberate policy decision, not an accidental consequence of enabling tracing.

### 4.2 Required controls

- Classify data at capture. Allowlist content fields and redact, tokenize, truncate, or hash before export.
- Keep restricted artifacts separate from broadly visible trace metadata. Enforce least-privilege access and audit access to restricted artifacts.
- The system `MUST NOT` record secrets, credentials, raw personal data, or confidential payloads unless a named, approved diagnostic purpose requires them.
- Use append-only audit metadata and content digests for consequential records. Apply privacy deletion through a documented tombstone or restricted replacement that preserves the fact and scope of removal without retaining the protected content.
- Define retention separately for metadata, diagnostics, and replay fixtures. Keep enough baseline metadata for valid denominators and cohort comparison; retain raw content only while it materially supports diagnosis or replay.

## 5. Delivery plan

### 5.1 Phase 0 - define the pilot

Select 20 to 50 recurring task types, or a smaller representative set if that is all that currently exists. For each, author a task contract and identify the strongest available outcome check. Define data classification, capture profiles, retention, access roles, and a small initial failure taxonomy.

**Exit check:** a reviewer can state what constitutes success and which evidence will establish it for every pilot task type.

### 5.2 Phase 1 - capture and inspect episodes

Implement the schema, artifact interface, task-contract revisioning, capture adapter, OTLP export, and a trace viewer. Instrument the complete observable agent loop, but retain content according to the selected capture profile. Provide an episode page or query that joins the contract, trace, activities, artifacts, and outcome.

**Exit check:** for a sampled episode, an investigator can identify the effective context, applicable capabilities, actions, resulting artifacts, and validation without consulting current production configuration.

### 5.3 Phase 2 - establish outcomes and review

Add deterministic outcome checks, structured human review, and failure-case records. Create cohort queries that compare conditional failure rates by task type, model, prompt or policy revision, tool version, and capture profile. Add LLM triage only after human labels can measure its agreement and failure modes.

**Exit check:** a release comparison reports denominators, task mix, system versions, outcome definition, and known confounders rather than an unqualified aggregate score.

### 5.4 Phase 3 - prove one improvement loop

Choose one recurring, costly failure family. Implement recorded-observation replay, test a single suspected condition, record the result as an experiment, apply a remediation if justified, and add the confirmed case to a regression suite.

**Exit check:** the team can show the evidence chain from an episode through a bounded intervention to validation of the remediation, including its limitations.

### 5.5 Defer until evidence creates the need

Defer graph-database adoption, automatic root-cause decisions, a universal failure ontology, full-environment replay, broad prompt/content retention, and product-specific lock-in. Reconsider each only when a concrete query, unreproducible high-value failure, regulatory requirement, or measured operational burden shows that the smaller design is insufficient.

## 6. Acceptance criteria

The initial implementation is successful when it can demonstrate all of the following for its pilot scope:

1. Each episode has a stable identity, one task-contract revision, runtime/version provenance, and a correlated trace.
2. Each material action links to its effective context, governing tool or policy version where relevant, output, and observed result.
3. Outcome evaluations are reproducible from their recorded rubric, inputs, evaluator version, and evidence.
4. Failure hypotheses are visibly distinguished from recorded facts and tested findings.
5. A reviewer can compare cohorts with explicit denominators and conditions.
6. Restricted content is access-controlled, redacted before broad export, retained proportionately, and auditable.
7. At least one recurring failure can be replayed from recorded observations and converted into a regression check after a supported remediation.

## 7. Basis and limits

This plan synthesizes the evidence model in [research.md](research.md), the phased recording-and-analysis loop in [idea-and-concepts.md](idea-and-concepts.md), and the technical options in [gresearch.md](gresearch.md). It also applies the repository's standards on justified complexity, observability, testing, and security/privacy.

The architecture is a high-confidence foundation, not a claim that present tooling can determine root cause automatically. The pilot `MUST` make capture gaps, missing outcome evidence, uncertain attribution, and uncontrolled replay conditions visible. Those limitations are part of the evidence, not defects to hide.
