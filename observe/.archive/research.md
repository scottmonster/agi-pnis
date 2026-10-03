**Status: Strictly non-authoritative reference material.**

This document is informational only. It creates no requirements, specifications, decisions, policies, obligations, approvals, interpretations, or binding guidance of any kind. Do not treat any part of it as controlling, implied, or actionable unless an authoritative source explicitly adopts the specific content at issue. In any conflict or ambiguity, authoritative sources control without exception.


# Research finding: an evidence-first environment for learning from agent behavior

- Research date: 2026-08-15
- Scope: agent environments in which an operator needs to understand behavior, assess outcomes, diagnose recurring problems, and test improvements over time.
- Research question: What architecture best produces reliable, inspectable evidence of what agents did, what shaped their decisions, what resulted, and why results diverged from the task's needs?

## Executive conclusion

Build an **evidence-first agent observatory**: a versioned record that connects a task contract, the effective decision context, observable execution, external state changes, outcome evidence, evaluation, and tested diagnostic hypotheses.

The system's central unit should be an **episode**, not a chat transcript, an aggregate score, or an agent memory entry. Each consequential episode should make it possible to answer:

1. What was required, including constraints and acceptance conditions?
2. What information, permissions, policies, tools, state, and versions were actually available at each material decision?
3. What did the agent and external systems do?
4. What outcome followed, and what evidence establishes it?
5. How was the outcome evaluated, by whom or what, under which rubric and version?
6. What is observed fact, what is a diagnostic hypothesis, and what causal claim has been tested?

This design best fits the stated goal because it keeps the evidence needed to learn from behavior separate from the later explanation of that behavior. A conventional trace answers much of question 3. It cannot alone establish that an action was wrong, identify the requirement it violated, or show that a plausible explanation was causal.

Use OpenTelemetry as the portable correlation and live-telemetry layer, and use a separate versioned evidence store as the durable record. Model the relationships among inputs, activities, actors, outputs, and revisions as a lightweight provenance graph inspired by W3C PROV. Do not make an observability product, an LLM judge, or self-reflection the authoritative record.

## Evidence that supports the conclusion

### Telemetry standards solve correlation, not the whole research problem

OpenTelemetry semantic conventions give traces common names and meanings, which supports correlation across code, libraries, and backends. Its GenAI work includes agent, planning, retrieval, memory, and tool-execution operations. This makes it a strong substrate for recording the execution path across a heterogeneous agent environment. It does not define the task's success conditions, a causal diagnosis, or the full lifecycle of evidence needed for longitudinal learning. [OpenTelemetry semantic conventions](https://opentelemetry.io/docs/specs/semconv/) and the [GenAI agent conventions](https://github.com/open-telemetry/semantic-conventions-genai/blob/main/docs/gen-ai/gen-ai-agent-spans.md) directly support the first claim; the second is a design inference from their scope.

The OpenTelemetry project also warns that prompt content, system instructions, tool arguments, and tool results can contain sensitive data. Its current guidance says that this content is not captured by default, while opting in can capture it as structured span attributes. This supports selective content preservation with access control and a separate artifact store, rather than indiscriminate trace capture. [OpenTelemetry GenAI observability guidance](https://opentelemetry.io/blog/2026/genai-observability/)

### Provenance provides the right relationship model

W3C PROV distinguishes entities, activities, and agents. It represents inputs an activity used, entities it generated, derivations, association with actors, and delegation. Those relationships map directly to an agent episode: a retrieved document, policy version, memory entry, tool schema, and environment snapshot are entities; a model step or tool execution is an activity; the runtime, model, user, and service are agents. [W3C PROV-O](https://www.w3.org/TR/prov-o/)

This does not require RDF or a graph database. The important finding is conceptual: preserve explicit, queryable links such as `used`, `generated`, `derived_from`, `constrained_by`, and `acted_on_behalf_of`. A span hierarchy records temporal nesting; it does not by itself say which particular context artifact influenced a decision or which output revision superseded another.

### Evaluation and diagnosis require different evidence

NIST's AI RMF calls for differentiated human-AI roles and for approaches, people, and documentation that identify and track actual and emergent risks in deployed contexts. That supports recording both outcome measurements and the authority or role of the evaluator, rather than treating an opaque score as ground truth. [NIST AI RMF core](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/)

Automated graders can scale labeling, but their output is evidence about the rubric and model used, not a final fact about quality. OpenAI's evaluation APIs expose deterministic checks, similarity measures, model-based labels and scores, and combinations of graders. Separate research documents position and self-preference biases in LLM judges. The appropriate use is calibrated triage and structured analysis, backed by deterministic or domain-specific checks where possible and reviewed against human labels for consequential or ambiguous cases. [OpenAI graders reference](https://platform.openai.com/docs/api-reference/graders), [position-bias study](https://arxiv.org/abs/2406.07791), and [self-preference study](https://arxiv.org/abs/2410.21819)

Recent, still-preliminary agent-attribution research reaches a compatible result. TraceElephant reports that full execution traces and reproducible environments improve failure-attribution accuracy substantially compared with partial traces. It is a 2026 preprint and a benchmark result, not evidence that a production system can automatically determine root cause. It is useful support for preserving complete effective context and for replay, while also supporting a conservative conclusion: automation should organize evidence and propose hypotheses, not act as a root-cause oracle. [TraceElephant](https://arxiv.org/abs/2604.22708)

Finally, an agent's stated explanation or plan is useful observable output but is not conclusive evidence of the factors that caused its action. Controlled studies have found that chain-of-thought can be unfaithful to the model's actual processing in some settings. Preserve voluntarily emitted rationales when useful, but do not substitute them for context, actions, and intervention evidence. [Anthropic's chain-of-thought faithfulness study](https://www.anthropic.com/research/measuring-faithfulness-in-chain-of-thought-reasoning)

## Recommended record model

Use an immutable `episode_id` as the root key. Give every artifact a stable ID, content hash, classification, creation time, source, and version or revision identifier. Keep large or sensitive artifacts outside span attributes and refer to them from the episode.

| Evidence layer | What it establishes directly | Minimum record |
| --- | --- | --- |
| Task contract | What success, constraints, and prohibited results meant before execution | Objective, acceptance checks, applicable requirements, authority, task-contract version, risk level |
| Effective context | What could have shaped a material action | System and user instructions after compaction, retrieved material and scores, memory reads, tool schemas, permissions, policies, budgets, relevant observations |
| Execution | What the system visibly did | Model and tool calls, handoffs, retries, guardrail events, timestamps, arguments, results, errors, state transitions |
| Provenance and configuration | Which exact system and artifacts produced the behavior | Agent and harness revision, model and provider identifiers, prompts, policy and tool versions, feature flags, environment image, knowledge and memory versions |
| Outcome | What happened after execution | Deliverable, test and verifier results, user correction, external side effect, downstream state, reversal or complaint, time observed |
| Evaluation | How the outcome was assessed | Evaluator type and version, rubric, inputs, reference data, label or score, evidence, reviewer identity or role, uncertainty |
| Diagnosis | Why a deviation may have occurred | Violated requirement, observed precursor conditions, candidate decisive step, supporting and contradictory evidence, status of the hypothesis |
| Experiment | Whether a suspected condition mattered | Replay type, fixed conditions, intervention, randomization or seed where available, result, comparison, limitation |

The task contract is essential. Do not define success only through the current evaluator prompt or final text similarity. Separate hard requirements, prohibited outcomes, preferences, measurable acceptance checks, and optional reference paths. Many valid runs may reach the same desired outcome by different trajectories.

The effective context must be captured at the time of the action, not reconstructed later from the nominal configuration. In particular, preserve which conversation summary was injected, which retrieval result and revision were selected, which memories were read, which tools were available, and which permission or policy decision applied. A current prompt or current vector-store document is not evidence of what the agent saw historically.

## Data and relationship design

Use a relational event store or warehouse for normal queries, an object store for immutable artifacts, and a graph-shaped relationship table or graph projection for lineage queries. This avoids making a graph database a prerequisite while retaining the relationships the analysis needs.

At minimum, represent these relations:

- `episode -> governed_by -> task_contract_version`
- `model_step -> used -> effective_context_artifact`
- `model_step -> generated -> tool_request or output_artifact`
- `tool_execution -> used -> tool_definition_version`
- `tool_execution -> generated -> observation or state_change`
- `output_artifact -> evaluated_by -> evaluation_record`
- `evaluation_record -> assessed_against -> task_contract_version`
- `diagnostic_hypothesis -> supported_by or contradicted_by -> evidence_artifact`
- `experiment -> intervened_on -> suspected_condition`
- `episode -> comparable_to -> cohort definition or prior episode`

The record should distinguish the following claim types in both storage and user interfaces:

| Claim type | Example | Required treatment |
| --- | --- | --- |
| Observation | The agent retrieved document `D7` and invoked tool `T` with argument `x`. | Link to trace and artifact evidence. |
| Evaluation | A versioned policy checker found requirement `R3` violated. | Link to checker, input, rule version, and result. |
| Hypothesis | The stale `D7` likely led to argument `x`. | Mark as unconfirmed and link supporting and contrary evidence. |
| Tested causal finding | Changing only `D7` removed the violation under the recorded replay conditions. | Link to the controlled comparison and its limits. |
| Remediation decision | Replace or version-gate `D7`. | Link to the finding, authority, implementation, and later validation. |

This separation is the main protection against a polished but unsupported incident narrative.

## Evaluation and diagnostic loop

Run a hierarchy of assessment methods, selected by what the outcome can actually support:

- Use direct, deterministic checks first: tests, schemas, policy rules, database state, filesystem diffs, transaction receipts, numerical tolerances, and authoritative source comparisons.
- Use structured human review for ambiguous, novel, high-impact, or taxonomy-defining cases. Preserve the rubric, reviewer role, decision basis, and disagreement rather than only a verdict.
- Use calibrated LLM judges for scalable triage, categorization, and candidate explanations. Version the judge, prompt, rubric, inputs, sampling settings, and output. Periodically compare a representative sample with human assessment, including known difficult and adversarial cases.
- Treat production outcomes such as user corrections, reversals, complaints, and downstream failures as outcome signals. They can be delayed, selective, and confounded, so retain their provenance and do not assume they are a complete error rate.

When a run diverges from need, create a **failure case** that links the failed episode to the violated task-contract element and records:

- the observed deviation and its outcome evidence;
- the earliest candidate decisive step and material precursor conditions;
- a provisional failure family, such as specification, context or retrieval, state or memory, planning, tool interface, runtime environment, orchestration, guardrail, resource budget, model variability, or measurement failure;
- supporting and contradictory evidence;
- the attribution status: unreviewed, hypothesis, reproduced, confirmed for stated conditions, or rejected; and
- remediation, validation, related cases, and recurrence status.

Keep the failure taxonomy deliberately broad at first. It is a tool for finding patterns, not a claim that every incident has one universal cause. Split or merge categories only after the corpus shows a repeated, decision-useful distinction.

## Replay and causal testing

Tracing establishes sequence and correlation. It usually cannot establish why a step occurred. For important or recurring cases, use replay to test the smallest practical intervention.

Support three replay modes:

- **Recorded-observation replay:** provide recorded tool results and observations to reproduce the decision path without invoking live dependencies.
- **Environment replay:** restore a snapshot or fixture of the relevant environment and dependencies.
- **Counterfactual replay:** change one suspected factor, such as a retrieval result, tool schema, permission, prompt revision, memory item, or guardrail rule, while holding other material conditions fixed.

Record which conditions could not be held fixed, including model nondeterminism, unavailable third-party services, time-sensitive data, and changed model versions. A counterfactual result is evidence only for the conditions tested. It should not be generalized to every task or model without additional evidence.

Use replay to decide whether a proposed remedy addresses the suspected cause, merely hides the symptom, or moves failure to another point in the trajectory.

## Longitudinal analysis

Analyze condition-linked patterns rather than reducing all behavior to one quality score. Useful questions include:

- Does a failure family rise after a specific prompt, tool, policy, memory, model, or environment revision?
- Does a retrieval source improve success for one task cohort while increasing policy violations for another?
- Where in the trajectory does the first detectable critical deviation tend to occur?
- Which requirements are repeatedly missed despite a successful final-answer score?
- Which hypotheses repeatedly reproduce, and which remain unresolved?
- Did a release lower the conditional rate of its target failure without degrading another measured outcome?

For each comparison, retain cohort definitions, denominators, exposure period, task mix, system versions, outcome definition, and known confounders. A rise in incident count can reflect more traffic, a new detector, a changed task mix, or actual degradation. Do not treat unadjusted counts as a causal effect of a release.

Promote only reproduced or strongly corroborated recurring cases into regression suites. Each regression case should preserve the relevant task contract, evidence fixture or replay environment, expected checks, known applicability boundary, and link to the originating episodes. This turns historical learning into a testable safeguard without claiming that the system has learned a universal lesson.

## Privacy, security, integrity, and retention

High-fidelity evidence can expose prompts, user data, secrets, proprietary documents, credentials in tool arguments, and sensitive external results. NIST's Privacy Framework treats audit-log records as subject to data minimization. Its security guidance also notes that log content should be selected at the right level of abstraction for diagnosis and limited to information explicitly needed for audit requirements. [NIST Privacy Framework](https://www.nist.gov/privacy-framework/privacy-framework) and [NIST SP 800-171 Rev. 3](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/800-171r3/NIST.SP.800-171r3.html)

Design the evidence environment with these controls from the start:

- Classify data at capture and use an allowlist for content fields.
- Redact, tokenize, hash, or replace sensitive values with secured artifact references before export where possible.
- Separate broadly accessible operational metadata from restricted raw artifacts.
- Encrypt records and artifacts, apply role-based access, and audit access to sensitive traces.
- Preserve content hashes and write-once or append-only audit metadata for consequential episodes, while allowing required privacy deletion through a documented tombstone or restricted replacement record.
- Define retention by evidence value, risk, and legal obligations. Retain outcome and provenance metadata long enough for longitudinal comparison; retain raw content only as long as it materially supports diagnosis or replay.
- Capture declared plans and rationales only when they are necessary and permitted. Do not depend on hidden chain-of-thought for diagnosis.

For volume control, retain baseline metadata for all episodes and use deliberate rules to retain richer artifacts for errors, policy events, unusual outcomes, sampled normal cases, and cohorts needed for comparison. OpenTelemetry tail sampling can make a decision after a trace completes and thus can select for trace-wide conditions such as errors, but it should not become a reason to discard all normal evidence needed to establish a baseline. [OpenTelemetry sampling](https://opentelemetry.io/docs/concepts/sampling/)

## Practical implementation sequence

1. **Choose representative episodes and task contracts.** Start with 20 to 50 recurring tasks. Define what is required, what is prohibited, the applicable constraints, and the best available outcome checks. Establish data classification and retention rules before full-content capture.
2. **Create the canonical episode and artifact model.** Assign stable IDs, capture system versions and hashes, and implement immutable references for prompts, policies, tool definitions, retrieved material, memory, and environment fixtures.
3. **Instrument the full observable loop.** Emit correlated traces for model calls, retrieval, memory, tools, handoffs, guardrails, retries, and state-changing operations. Use OpenTelemetry conventions where they fit and add application fields for task-contract, outcome, and provenance IDs.
4. **Add outcome capture and layered evaluation.** Implement deterministic checks first, then structured human review for the cases where the checks are insufficient. Add model-based triage only after a labeled sample exists for calibration.
5. **Operate a failure-case review.** Create diagnosable cases from meaningful deviations, preserve contrary evidence, and link related cases. Review a small number regularly to improve capture gaps and taxonomy quality.
6. **Build replay for one high-value failure family.** Prefer recorded-observation replay first because it is cheaper and more stable than restoring a whole production environment. Add controlled counterfactuals once the evidence fixtures are reliable.
7. **Add cohort analysis and release gates.** Compare relevant conditional outcomes across versions, promote confirmed cases to regression suites, and require evidence that a change improves its target condition without unacceptable regression elsewhere.

## Scope boundaries and unresolved limits

This recommendation does not claim that traces reveal a model's internal reasoning or that replay always yields a unique root cause. Agent behavior can be nondeterministic, outcomes can be delayed or partially observed, and multiple factors can interact. The system should therefore show uncertainty, preserve competing hypotheses, and identify evidence gaps.

Nor does the evidence support a universal technology choice. OpenTelemetry and W3C PROV are strong, interoperable foundations for trace semantics and provenance relationships. The choice of trace viewer, warehouse, object store, graph projection, and annotation interface should follow existing infrastructure, data residency, access-control needs, and query workload. Keep each replaceable by preserving the canonical episode and artifact IDs outside any one product.

## Confidence and reconsideration

Confidence is high in the architecture's core distinctions: explicit task contracts, effective-context capture, versioned provenance, outcome evidence, evaluator provenance, and the separation of observation from diagnosis. They follow mature standards and risk-management guidance and directly address the information required by the research question.

Confidence is moderate in fully automated root-cause attribution and model-based judging. The available research shows useful gains from complete traces and reproducible environments, but it is recent, often benchmark-specific, and subject to model and evaluator bias. Human and deterministic review remain important for consequential conclusions.

Reconsider the design if evidence shows that the selected capture level misses recurring causes, privacy and retention controls prevent material diagnosis, evaluator calibration degrades, replay does not reproduce important production conditions, or a domain-specific safety, legal, or engineering method imposes stronger requirements.

## Source roles and limitations

| Source | Role in this finding | Material limitation |
| --- | --- | --- |
| [OpenTelemetry](https://opentelemetry.io/docs/specs/semconv/) and [GenAI conventions](https://github.com/open-telemetry/semantic-conventions-genai/blob/main/docs/gen-ai/gen-ai-agent-spans.md) | Primary technical evidence for interoperable trace semantics | GenAI agent conventions are still evolving and do not define the complete evidence model. |
| [W3C PROV-O](https://www.w3.org/TR/prov-o/) | Primary standard for provenance concepts and relationship types | It is a general provenance model, so its application to agents is an inference. |
| [NIST AI RMF](https://airc.nist.gov/airmf-resources/airmf/5-sec-core/) and [NIST privacy and audit guidance](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/800-171r3/NIST.SP.800-171r3.html) | Authoritative guidance for role differentiation, deployed risk tracking, log design, and minimization | Voluntary and general guidance, not a product architecture specification or binding law. |
| [OpenAI graders reference](https://platform.openai.com/docs/api-reference/graders) | Primary product evidence for multiple evaluator types | Describes available mechanisms, not proof of evaluator accuracy. |
| [TraceElephant](https://arxiv.org/abs/2604.22708) | Direct recent evidence about observability and failure attribution | A 2026 preprint and benchmark. Its measured results may not transfer to a particular agent environment. |
| [LLM-judge bias studies](https://arxiv.org/abs/2406.07791) and [chain-of-thought faithfulness research](https://www.anthropic.com/research/measuring-faithfulness-in-chain-of-thought-reasoning) | Direct evidence for evaluator and stated-rationale limitations | Results depend on models, tasks, and experimental conditions. They justify caution, not rejection of all automated evaluation or rationales. |
