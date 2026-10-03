**Status: Strictly non-authoritative reference material.**

This document is informational only. It creates no requirements, specifications, decisions, policies, obligations, approvals, interpretations, or binding guidance of any kind. Do not treat any part of it as controlling, implied, or actionable unless an authoritative source explicitly adopts the specific content at issue. In any conflict or ambiguity, authoritative sources control without exception.

## Research conclusion

The best way to accomplish your goal is to build an **evidence-first agent observatory**: a system that preserves enough structured, versioned, replayable evidence to reconstruct an agent run, compare it with what should have happened, form hypotheses about why it differed, and then test those hypotheses.

I would **not** make “agent memory,” an LLM judge, aggregate success scores, or an observability vendor the center of the design. Those can all be useful components, but none of them can by itself answer the question you actually care about: *what happened, what conditions shaped it, why did the outcome diverge, and is the same underlying problem recurring elsewhere?*

That conclusion follows the research guide's central requirement that evidence be matched to the particular claim being made, that inference remain distinguishable from directly established evidence, and that consequential conclusions remain auditable.  

Recent agent research reinforces this. Complete traces containing inputs and metadata materially improve failure attribution, while controlled replay and counterfactual probing improve attribution further. At the same time, even recent automated techniques remain far from perfectly identifying the decisive failure step, which means your system should assist root-cause analysis rather than pretend to automate it completely. ([arXiv][1])

### The architecture I recommend

Think of the environment as seven connected evidence layers rather than as a logging system:

| Layer                      | What it should answer                           | What to preserve                                                                                                            |
| -------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Task contract**          | What was actually needed?                       | Goal, acceptance criteria, constraints, prohibited outcomes, reference facts, permissions, risk level                       |
| **Execution trace**        | What did the agent actually do?                 | Model calls, tool calls, handoffs, retries, observations, outputs, timing and state transitions                             |
| **Decision context**       | What information could have shaped each action? | Effective model context, system instructions, retrieved material, memory reads, tool schemas, policy state, budgets         |
| **Provenance/versioning**  | Which exact system produced this behavior?      | Agent/harness commit, model/version, prompts, policies, tool versions, feature flags, environment image, knowledge versions |
| **Outcome record**         | What happened afterward?                        | Final result, environment changes, tests, user corrections, reversals, complaints, downstream effects                       |
| **Evaluation/attribution** | Where and how did behavior diverge?             | Rule checks, human labels, calibrated model judgments, failure category, candidate decisive step and supporting evidence    |
| **Experiment/replay**      | Did the suspected cause actually matter?        | Re-executions, controlled interventions, seeds, changed variable, resulting behavior and regression results                 |

The crucial difference from ordinary LLM observability is the first and last layers. A trace tells you **what happened**. A task contract tells you **whether it was actually wrong**. Replay lets you investigate **whether your explanation of the failure is causal rather than merely plausible**.

This is also why recent work on agent evaluation increasingly treats system-level behavior, intermediate artifacts, production traces and controlled redevelopment as a continuous lifecycle rather than evaluating only final responses. ([arXiv][2])

## 1. Make “what should have happened” a first-class object

This is probably the most important design decision.

For every meaningful run, associate a versioned `task_contract` describing the intended result independently of what the agent produced. It should contain the objective, mandatory constraints, forbidden actions, known success conditions and whatever ground truth is available.

Do **not** force every task to specify an exact ideal trajectory. There may be many legitimate ways to solve something. Instead distinguish between hard requirements, preferences, expected intermediate invariants, and optional reference paths.

This matters because something that looks like an “agent failure” can actually be a specification failure. The empirically developed MAST taxonomy for multi-agent systems, for example, found specification problems, inter-agent alignment problems and verification problems to be separate families of failure. ([arXiv][3])

It also prevents evaluator drift. If success exists only inside the current grader prompt, changing the grader silently changes the historical meaning of success.

## 2. Capture the *effective* context, not merely the nominal configuration

To understand why an agent acted as it did, you need the information actually available **at the moment of a decision**.

For each model step, preserve references to the exact system instructions, user messages, retained conversation context after any truncation or summarization, memory entries read, retrieved documents, retrieval scores, tool definitions, guardrails, permissions and relevant environment observations.

For each tool action, preserve its arguments, result, failure mode, retries, relevant precondition state and resulting state change.

OpenTelemetry is currently the best foundation for the live telemetry portion. Its semantic conventions provide common meaning across traces and platforms, and official OpenTelemetry instrumentation for agent runtimes can already emit agent, generation, tool, guardrail and handoff spans. ([OpenTelemetry][4])

But OpenTelemetry should be your **transport/correlation substrate**, not your entire evidence model.

Large contextual artifacts should normally live in a separate immutable or versioned artifact store. Spans can contain a content hash, artifact ID, version and classification instead of stuffing everything into trace attributes.

This also addresses privacy. OpenTelemetry's own GenAI guidance notes that full prompt, system-prompt, tool-argument and result capture can contain sensitive information and therefore content capture is not generally something to enable indiscriminately. Collector processors can redact, hash, transform or remove sensitive fields. ([OpenTelemetry][5])

A useful retention strategy is therefore **metadata for essentially all runs, richer content for diagnostically important runs, and tightly controlled secure storage for sensitive artifacts**. Tail-based sampling can retain completed traces based on errors and other trace-wide attributes when data volume requires sampling. ([OpenTelemetry][6])

## 3. Represent provenance explicitly

Ordinary parent/child spans tell you execution order. Your goal requires more.

I would introduce a lightweight provenance graph inspired by the W3C PROV model. W3C PROV represents entities, activities and responsible agents, together with relations such as an activity *using* an entity and an entity being *generated by* an activity. It was explicitly designed so provenance could support assessments of reliability and trustworthiness across heterogeneous systems. ([W3C][7])

For an agent environment, that could mean:

`retrieved_document_v7 → used_by → model_step_14`

`model_step_14 → generated → tool_request_9`

`tool_request_9 → generated → database_state_change_21`

`policy_v12 → constrained → model_step_14`

`memory_item_448 → used_by → model_step_14`

`summary_32 → derived_from → conversation_turns_1_18`

This is far more analytically valuable than simply knowing that span 14 preceded span 15.

Recent provenance research for agents independently arrives at essentially the same requirement: connect retrieved evidence, tool outputs, memory, observations, intermediate claims, actions and final outputs rather than evaluating the final answer in isolation. ([arXiv][8])

## 4. Separate observation, diagnosis and causal evidence

Your system should explicitly distinguish three different statements:

**Observation:** “The agent retrieved document X and subsequently called tool Y with parameter Z.”

**Attribution hypothesis:** “The stale content in document X may have caused parameter Z.”

**Causal evidence:** “When the identical run was replayed with only document X corrected, the failure disappeared in 17/20 controlled executions, while the original context continued failing.”

Only the first is established by tracing.

This distinction is especially important because agents and evaluators can produce very convincing explanations. Exposed reasoning, plans and reflections are valuable artifacts when available, but they should be treated as **what the model emitted**, not unquestioned evidence of the model's true causal decision process. Research on chain-of-thought faithfulness has repeatedly found that verbalized reasoning need not faithfully reveal all factors influencing a model's output. ([Anthropic][9])

Counterfactual replay is therefore one of the highest-value capabilities you can add. TraceElephant's experiments found that complete input and metadata materially improved failure attribution and that replay with counterfactual probing further improved decisive-step attribution by filtering spurious candidates. ([arXiv][1])

I would support three kinds of replay: **recorded-observation replay**, where the agent sees the exact historical tool results; **environment replay**, where an environment snapshot is restored; and **counterfactual replay**, where one suspected factor is changed while everything practical is held fixed.

## 5. Treat evaluation itself as evidence that needs provenance

Don't attach a `quality_score=0.73` to a trace and consider the problem solved.

Every evaluation should itself have an auditable record containing evaluator type, evaluator version, rubric version, input evidence, reference answer if any, output label, explanation, timestamp and ideally its own trace.

Use deterministic or domain-specific verification whenever the question supports it: tests, schema validation, transaction state, policy rules, numerical comparisons and authoritative references.

Use humans for ambiguous, novel, consequential and taxonomy-building cases.

Use LLM judges for scalable triage and labeling **after calibrating them against human examples**. OpenAI's current evaluation guidance explicitly recommends combining metrics with human judgment, while the wider literature has demonstrated position, self-preference and other judge biases. ([OpenAI Developers][10])

Phoenix has an especially useful implementation pattern here: evaluator executions can themselves be traced, retaining the evaluator inputs, prompt, model, result and timing. That is much closer to what your use case needs than storing an opaque score. ([Arize AI][11])

## 6. Create a failure record, not just a failed trace

After diagnosis, turn a run into a durable **failure case**.

A failure case should preserve the observed deviation, the requirement that was violated, the earliest suspected decisive step, precursor conditions, failure class, evidence supporting and contradicting the attribution, whether it was reproduced, affected system versions, related historical cases, proposed remediation and subsequent validation results.

The taxonomy should remain extensible.

I would start with broad families such as specification/requirements, context or retrieval, memory/state, planning/decision, tool/interface, environment/runtime, orchestration/handoff, verification/guardrail, resource/budget, model variability and measurement/evaluator failure.

Do not hard-code that as a universal truth. Your research guide specifically cautions against turning a source type, numerical scoring system or universal method into a substitute for claim-level assessment.  The empirical taxonomies are good seeds, but your own production evidence should eventually refine the categories.

Recent systems such as HarnessFix similarly normalize raw traces, connect runtime steps with the harness mechanisms that shaped them, attribute failures, and consolidate recurring diagnoses into reusable flaw records. That is much closer to your stated objective than conventional “self-reflection.” ([arXiv][12])

## 7. Learn longitudinally from conditions, not just examples

Once the above structure exists, the really valuable analysis becomes possible.

You can ask questions such as:

“Does failure type X increase specifically when retrieval source A is present?”

“Did tool version 4.8 reduce argument errors without increasing termination errors?”

“Are failures associated with a particular prompt revision, context length, model, user cohort, permission configuration or memory strategy?”

“Does the same decisive-step pattern occur across apparently unrelated tasks?”

“Are we seeing the same symptom caused by several distinct underlying conditions?”

“Did the fix actually remove the failure or merely move it later in the trajectory?”

This is where a normal analytics warehouse becomes more useful than an LLM. Store normalized run, span, outcome, evaluation, attribution and experiment tables so ordinary SQL/statistical analysis can compare cohorts and versions.

I would measure **conditional failure rates and distributions**, rather than collapsing everything into one agent-quality score. Track, for example, failure incidence by category and system version, first-critical-step location, recurrence by condition, verifier escape rate, user-correction rate, unresolved attribution rate and regression results.

Clusters or LLM-generated summaries can help discover candidate patterns, but a cluster is a lead, not a finding. Your guide similarly calls for tracing evidence lineage, examining limitations and actively challenging emerging conclusions. 

## Recommended technology stack

If I were building this now, I would use **OpenTelemetry + an independent evidence store as the foundation**.

For the interactive observability/evaluation UI, my current default would be **Arize Phoenix**, particularly for a research-oriented environment where inspectability, self-hosting and portability matter. Phoenix is open source, accepts OpenTelemetry-based traces, supports datasets/experiments, can trace evaluators and can now import ATIF trajectory files as OTel span trees. ([Arize AI][13])

**Langfuse** is a strong alternative if its production workflow and application UX fit you better. It accepts OTLP data and has trajectory, step and final-response evaluation workflows, datasets and production evaluation. ([Langfuse][14])

I would deliberately keep either one replaceable. The observability product should be a **view onto your evidence**, not the only place the evidence exists.

For portable trajectory archives, I would consider exporting ATIF alongside the canonical event/provenance data. ATIF v1.7 is an active 2026 JSON specification designed to represent complete agent interaction histories, tool calls, observations and subagent trajectories, and it is already supported outside its originating project. But because it is new and evolving, I would treat it as an interchange format rather than letting its current schema dictate your internal ontology. ([GitHub][15])

### A practical build sequence

1. **Define the task-contract and outcome schemas first.** Pick 20–50 representative tasks and write down what constitutes success, required constraints and known ways of measuring the result.
2. **Instrument the complete agent loop with OpenTelemetry.** Include model, tool, retrieval, memory, handoff, guardrail and environment operations under one correlated run identity.
3. **Add a versioned artifact/provenance layer.** Snapshot or content-address prompts, effective contexts, retrieved material, policies, tools, memory and environment versions; store behavior-shaping configuration alongside every run.
4. **Build the evaluation hierarchy.** Start with deterministic checks and manual trace review; add structured human annotations; only then introduce calibrated automated judges. Trace the evaluators too.
5. **Add diagnosis and replay.** Create failure records, link candidate decisive steps to evidence, and build one-variable counterfactual experiments for important or recurring cases.
6. **Turn confirmed cases into longitudinal data and regression tests.** Analyze conditions and cohorts, promote recurring failures into a maintained taxonomy, and run representative historical cases before releasing prompt, model, tool, policy or orchestration changes.

That sequence is intentionally different from “collect traces → ask an LLM what went wrong → add its lesson to memory.” The latter creates a plausible story quickly, but it mixes observation, interpretation and remediation and makes later auditing difficult.

## Minimum viable evidence schema

If you want one concrete design rule to use while implementing this, make every consequential run answer these questions without consulting the current production configuration:

**What did the agent need to accomplish?
What exactly did it see?
What exact rules and capabilities applied?
What did it decide and do?
What did every external dependency return?
What state changed?
What outcome was eventually observed?
Who or what judged that outcome?
What part is fact versus attribution?
Can I recreate enough of the conditions to test the attribution?**

If one of those cannot be answered, that is an observability gap worth making visible rather than filling with an inference.

## Confidence and remaining uncertainty

I have **high confidence in the core architecture**: complete execution evidence, explicit success criteria, provenance/versioning, multi-source evaluation, longitudinal analysis and replay are supported both by mature observability/provenance standards and by converging recent agent research. OpenTelemetry and W3C PROV are particularly strong foundations for the telemetry and provenance portions. ([OpenTelemetry][4])

I have **moderate confidence in today's best automated attribution techniques**. Much of the interesting root-cause work is from 2025–2026 and includes recent preprints. More importantly, TraceElephant reports only about 30–33% exact step-level attribution under its evaluated configurations even with rich observability and replay. That is evidence *against* designing an autonomous “root-cause oracle” today. ([arXiv][1])

The most defensible design is therefore one in which automation **organizes evidence, discovers candidates and performs experiments**, while the underlying evidence and uncertainties remain inspectable. That also follows your research guide's requirement that material uncertainty, missing evidence and evidentiary limitations remain visible rather than being hidden for the sake of a cleaner conclusion. 

**In short: build a laboratory notebook for agent executions, not a diary for agents.** The durable asset is the evidence graph connecting requirements → conditions → actions → outcomes → evaluations → tested explanations. Once you have that, improvement becomes a consequence of understanding rather than a substitute for it.

[1]: https://arxiv.org/html/2604.22708v1 "Seeing the Whole Elephant: A Benchmark for Failure Attribution in LLM-based Multi-Agent Systems"
[2]: https://arxiv.org/html/2411.13768v3 "Evaluation-Driven Development and Operations of LLM Agents: A Process Model and Reference Architecture"
[3]: https://arxiv.org/abs/2503.13657?utm_source=chatgpt.com "Why Do Multi-Agent LLM Systems Fail?"
[4]: https://opentelemetry.io/docs/specs/semconv/ "OpenTelemetry semantic conventions 1.44.0 | OpenTelemetry"
[5]: https://opentelemetry.io/blog/2026/genai-observability/ "Inside the LLM Call: GenAI Observability with OpenTelemetry | OpenTelemetry"
[6]: https://opentelemetry.io/docs/concepts/sampling/?utm_source=chatgpt.com "Sampling | OpenTelemetry"
[7]: https://www.w3.org/TR/prov-dm/ "PROV-DM: The PROV Data Model"
[8]: https://arxiv.org/abs/2606.04990 "[2606.04990] From Agent Traces to Trust: A Survey of Evidence Tracing and Execution Provenance in LLM Agents"
[9]: https://www.anthropic.com/research/reasoning-models-dont-say-think?utm_source=chatgpt.com "Reasoning models don't always say what they think"
[10]: https://developers.openai.com/api/docs/guides/evaluation-best-practices "Evaluation best practices | OpenAI API"
[11]: https://arize.com/docs/phoenix/evaluation/llm-evals "Evaluation - Phoenix"
[12]: https://arxiv.org/abs/2606.06324 "[2606.06324] From Failed Trajectories to Reliable LLM Agents: Diagnosing and Repairing Harness Flaws"
[13]: https://arize.com/docs/phoenix/resources/github "GitHub - Arize-ai/phoenix: AI Observability & Evaluation · GitHub"
[14]: https://langfuse.com/integrations/native/opentelemetry "OpenTelemetry (OTEL) for LLM Observability - Langfuse"
[15]: https://github.com/harbor-framework/harbor/blob/main/rfcs/0001-trajectory-format.md "harbor/rfcs/0001-trajectory-format.md at main · harbor-framework/harbor · GitHub"
