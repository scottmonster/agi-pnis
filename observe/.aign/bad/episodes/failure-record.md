# Failure Records

**Status: Draft standard under development.**

## 1. Purpose and role

This document is the specialist standard for Failure Records (FR) and Failure Update Records (FUR).

It defines when a detected violation becomes a material failure record, how an FR or FUR is created and maintained, and the reporting profile selected from the shared schema.

`episode-record.md` remains the shared protocol and routing layer. `failure-catalog.md` defines classifications, investigation profiles, prevention loci, and detailed failure patterns. This document does not duplicate either the shared protocol or the catalog.

## 2. Terms and boundaries

### 2.1 Failure Record

An FR preserves a detected material violation so it can inform prevention, remediation, review, or future guidance.

An FR is not created merely because a catalog pattern exists, a tool call fails, a test fails, or an ordinary error occurs.

### 2.2 Failure Update Record

A FUR preserves one later material investigation, containment, corrective action, validation, correction, review, recurrence, or outcome concerning an FR.

A FUR is not itself a violation. It does not rewrite the historical content of its subject FR.

### 2.3 What this standard does not decide

This standard does not establish fault, root cause, responsibility, or a required corrective action from a classification alone.

The catalog identifies candidate prevention opportunities. A proposed corrective action becomes governing direction only if an authorized actor settles it as a new JR under `judgement-record.md`.

## 3. FR qualification and creation

### 3.1 Qualification test

Create an FR only when all of the following are true:

- **Detected violation:** available evidence establishes an action, omission, condition, or materially incorrect assumption that departed from an applicable requirement, constraint, or expected behavior.
- **Materiality:** preserving the episode can inform prevention, remediation, review, or future guidance.
- **Bounded account:** the record can state the observed departure, the applicable expectation, and the known impact or evidence limitation without inventing a root cause.

An unresolved classification does not prevent an FR. Record why classification remains unresolved and preserve the relevant availability limits.

### 3.2 Classification route

Use Section 9 to select relevant analytical modes, prevention loci, and response guidance. Use `failure-catalog.md` to select the matching category and detailed pattern.

Record the primary pattern as `failure.name`; record any category, mode, or additional pattern in `failure.classifications`; and record candidate loci in `failure.prevention_loci`.

Classifications are evidence-based analytical and preventive hypotheses. They do not prove fault, root cause, or responsibility.

## 4. FR reporting requirements

### 4.1 Minimum publishable FR

A publishable FR `MUST` satisfy the shared publishable FR profile:

- `id`, `record_type`, `schema_version`, `record_status`, title, and `recorded_at`;
- `failure.name` and `failure.harness`;
- `violation.statement`, `violation.applicable_expectation`, and `violation.observed_departure`; and
- the material impact, or an availability-aware statement of its limitation.

`failure.harness` is an open value and may be `manual` or `unknown`. It does not make the system harness-specific.

### 4.2 Complete FR report when available

When available and material, a complete FR also includes:

- `source`, `episode`, intended outcome, constraints, authority, and established direction;
- relevant actors, agent context, instructions, tools, runtime, and environment;
- affected artifacts or state, commands, tool results, changes, tests, feedback, external state, and containment;
- supporting and contrary evidence, claims, investigation findings, and availability limitations;
- classifications, candidate prevention loci, and the reason a classification remains unresolved when applicable;
- candidate corrective actions and their dispositions; and
- relationships to relevant JR, JUR, FR, or FUR records.

Use the shared availability state for material unavailable source, episode, authority, or evidence items. `MUST NOT` infer unavailable evidence or retain private chain-of-thought, secrets, or wholesale transcripts.

## 5. FR body structure

The Markdown body is the human-reviewable account of the structured record. Use these required sections, with the title as the document heading:

```md
# <title>

## 1. Detected violation

<Applicable expectation, observed departure, detection, and known scope.>

## 2. Impact and evidence

<Observed impact, evidence, claim status, availability limits, and contrary evidence.>

## 3. Classification and investigation

<Catalog classifications, candidate prevention loci, investigation findings, and uncertainty.>

## 4. Candidate corrective actions

<Containment, repair, prevention, or learning options and their dispositions.>
```

Add a numbered section only when it materially improves later understanding, such as authority, related judgment, recurrence, validation plan, or escalation.

## 6. FUR qualification and reporting

### 6.1 When to create a FUR

Create a FUR for one later material event concerning a published FR.

Use `failure.update_kind` with one of these values:

- `investigation`;
- `containment`;
- `corrective_action`;
- `validation`;
- `correction`;
- `review`;
- `recurrence`;
- `outcome`; or
- `other`, with `failure.update_kind_note`.

### 6.2 Minimum publishable FUR

A publishable FUR `MUST` satisfy the shared publishable FUR profile:

- `id`, `record_type`, `schema_version`, `record_status`, title, and `recorded_at`;
- `event_at`;
- `failure.subject_record_id` identifying the subject FR; and
- `failure.update_kind`.

### 6.3 Complete FUR report when available

When available and material, a complete FUR also includes new evidence and availability limits, investigation findings, containment or corrective-action disposition, validation, recurrence, correction, review, outcome, and relationships to related records.

## 7. FUR body structure

```md
# <title>

## 1. Later event

<Event date, update kind, and subject FR.>

## 2. New evidence and assessment

<Evidence, claim status, investigation or validation, and availability limits.>

## 3. Effect and follow-up

<Corrective-action disposition, recurrence, outcome, or remaining work.>
```

## 8. Relationships, history, and judgment effects

Use `failure.subject_record_id` to identify the FR updated by a FUR. Use typed `relationships` such as `investigates`, `updates`, `remediates`, `recurs_from`, or `relates_to` for additional discovery context.

Published FR and FUR records are immutable historical evidence. Record a later material event in a new FUR rather than changing an earlier record.

When a failure materially concerns a governing judgment, link the FR or FUR to the related JR or JUR. Use `judgement-record.md` when the failure changes, corrects, or establishes governing direction.

## 9. Failure-analysis and response guidance

### 9.1 Cross-harness analytical modes

Use one or more of these analytical modes when they help explain the failure. They are not fault assignments or prevention loci.

| Mode | Use when the material question concerns | Evidence emphasis |
| --- | --- | --- |
| Judgment, authority, and escalation | discretion, authority scope, precedent, or an unresolved question | authority, settled direction, uncertainty, escalation path |
| Task and requirement understanding | objectives, constraints, acceptance criteria, priority, or scope | applicable request, requirement, ambiguity, clarification history |
| Context and evidence availability | missing, stale, inaccessible, incorrectly retrieved, or incorrectly weighted facts | provenance, contemporaneous state, and availability limits |
| Planning and scope control | approach, ordering, stopping condition, omission, or unjustified expansion | alternatives, plan, sequence, scope rationale, stopping evidence |
| Knowledge and calibration | unsupported certainty, a material gap, or action despite uncertainty | claimed basis, uncertainty, contrary evidence, source quality |
| Tool selection and action execution | tool choice, invocation, interpretation, or unintended state change | tool input/output, permissions, version, before-and-after state |
| Verification and quality control | missing, unsuitable, misread, bypassed, or insufficient validation | criterion, validation design, test/evaluator inputs and outputs |
| Safety, policy, permission, and authority boundaries | safeguards, approvals, policy, permissions, or safe-completion conditions | applicable boundary, authorization, exposure, containment |
| Communication and feedback | clarification, limitation disclosure, feedback, timing, or reviewability | messages, feedback, recipient, timing, unanswered question |
| Memory and long-horizon state | lost, stale, unrecoverable, or misinterpreted prior information | state source, revision, retention limit, retrieval path |
| Collaboration and handoff | role ambiguity, missing context, contradictory work, or unclear responsibility | actor roles, handoff artifact, responsibility, sequence |
| Resource and termination | time, token, cost, retry, context-window, concurrency, or termination limits | limit, consumption, termination signal, attempted recovery |
| Runtime and environment | harness, model/configuration, repository state, sandbox, service, network, or dependency condition | environment identity, versions, availability, reproducibility |
| Measurement and review | test, evaluator, rubric, feedback signal, or review-process limitations | evaluator, criterion, inputs, version, bias, coverage limits |

### 9.2 Prevention loci

Prevention loci identify where a preventive change may be possible. A record may carry more than one locus or remain unresolved.

| Locus | `failure.prevention_loci` value | Candidate action direction |
| --- | --- | --- |
| Agent-level | `agent_level` | improve instructions, skills, checkpoints, routing, review triggers, or agent capability |
| Tool-level | `tool_level` | repair behavior, add validation or guardrails, improve feedback, constrain unsafe action, or improve observability |
| Shared agent-and-tool | `shared_agent_and_tool` | combine enforced checks with agent guidance, better interfaces, and verification loops |
| Task/external | `task_or_external` | clarify or defer the task, obtain authority, repair an external dependency, or document a limitation |
| Unresolved | `unresolved` | retain uncertainty, seek further evidence, and avoid premature remediation claims |

### 9.3 Category-specific response profiles

Select the profile whose category matches the primary catalog pattern in `failure-catalog.md`. All profiles use the common evidence envelope when available and material: source, episode, intended outcome, constraints, authority, actors, agent context, instructions, tools, runtime, environment, evidence, claims, violation, investigation, impact, corrective actions, evaluation, relationships, later outcomes, and sensitivity.

| Category | Establish and retain when available | Candidate actions, validation, and escalation |
| --- | --- | --- |
| Intent, specification, and scope | request version, acceptance criteria, clarification history, changed artifacts, feedback, and verification | correct scope or implementation; clarify the task; add acceptance checks or checkpoints; validate against actual requirements; escalate scope or authority conflicts |
| Repository and context-grounding | repository revision, search/retrieval evidence, definitions, callers, tests, manifests, environment, and diff location | correct the change; improve retrieval, feedback, or repository guidance; validate callers and integration; escalate architectural or data-contract inconsistencies |
| Speculative architecture and needless abstraction | current requirements, callers, alternatives, benchmarks, constraints, dependency graph, and maintenance impact | simplify or remove the addition; record a justified boundary; add evidence-based design review; validate behavior, compatibility, and reduced complexity; escalate durable architecture direction |
| Reimplementation and dependency mistakes | platform capabilities, existing repository use, dependency manifest, security and maintenance impact, and alternatives | replace unnecessary implementation or dependency; document an exception; add dependency review; validate build, behavior, compatibility, and supply-chain impact; escalate ownership approval |
| Structural bloat and maintainability | affected paths, duplication or coupling indicators, local conventions, review feedback, history, and maintenance impact | simplify, consolidate, rename, or document an exception; validate behavior and tests; escalate broad refactors or architecture changes |
| Functional correctness and robustness | reproduction inputs, expected and actual output, logs, state transitions, callers, tests, and environment | reproduce safely; trace the failing path; repair implementation or handling; add regression coverage; validate reported, edge, and integration cases; escalate data loss, high-impact runtime, or safety consequences |
| Performance and resource inefficiency | workload, benchmark, baseline, resource measurements, cost, latency, capacity, and correctness trade-offs | confirm the bottleneck; remove unnecessary work, simplify algorithm, bound use, or tune infrastructure; validate against baseline and correctness; escalate capacity, cost, or service-level impact |
| Dependency, package, build, and environment | manifests, lock files, logs, toolchain versions, installation instructions, platform matrix, and safe reproduction | correct declarations; pin, replace, or simplify dependencies and build logic; improve environment checks; validate clean build and supported platforms; escalate supply-chain, credential, or broad tooling changes |
| Testing and verification | evaluator source, negative-case evidence, commands and results, coverage of changed behavior, baseline suites, and harness changes | add or correct behavior-focused tests; restore checks; run affected suites; validate that the check fails before sound repair and passes after; escalate integrity, safety, or release-signoff concerns |
| Security and privacy | applicable policy, affected boundary and data, safe reproduction details, dependencies, logs, configuration, and containment | contain exposure when authorized; rotate credentials; repair access, input handling, defaults, or dependencies; validate safely; escalate immediately under applicable security, privacy, or incident procedures |
| Change hygiene and integration | diff, affected artifacts, generated-source relationship, callers, migration plan, feedback, and working-tree state | narrow, split, or revert unrelated work; complete migration; reconcile sources of truth; validate integration and compatibility; escalate destructive migration or public-contract change |
| Documentation, configuration, and operability | documentation/version, actual behavior, configuration schema, logs or metrics, examples, deployment plan, rollback path, and audience | correct docs, config, or examples; add diagnostics or rollback controls; remove unsafe logging; validate a supported workflow; escalate sensitive exposure or destructive deployment risk |
| Coding-agent workflow and interaction | safe task and instruction references, tool sequence and results, correction history, checkpoints, verification claims, and resource limits | separate observable workflow from hidden-reasoning claims; improve routing, clarification gates, exploration guidance, tool-result presentation, checkpoints, or review; validate comparable tasks; escalate repeated systemic or authority-boundary violations |
| Central meta-failures | evidence-gathering sequence, alternatives, change progression, verification timing, and comparable episodes | use with one or more concrete patterns; improve workflow gates, evidence access, simplification, or verification; validate recurrence reduction; escalate only when broader governing direction is needed |

### 9.4 Task, external, unresolved, and outcome conditions

Use `task_or_external` or `unresolved` when the task is underspecified, authority is unavailable, an external dependency is unavailable, or evidence cannot support a credible preventive action. Do not force the episode into a catalog pattern.

Noncompletion, incorrect output, build or runtime failure, regression, inconsistency, unacceptable nondeterminism, and failed or misleading validation are outcome signals. They may trigger investigation but are not root-cause classifications by themselves.

## 10. Identity, storage, and review

Use the shared `id`, `record_type`, `schema_version`, and `record_status` fields. FR and FUR identifiers use their respective `FR` and `FUR` prefixes and remain stable independently of filename, path, or local sequence number.

Until the storage model changes by an authorized decision, initial Markdown records are stored under `.agents/tracking/records/failures/`, and the discoverable index is `.agents/tracking/records/index.md`.

Before publishing an FR, confirm that a future reviewer can determine the observed violation, applicable expectation, impact or limitation, evidence, classification or uncertainty, and corrective-action disposition.

Before publishing a FUR, confirm that a future reviewer can determine the linked FR, later event, new evidence, effect, and remaining remediation or validation work.
