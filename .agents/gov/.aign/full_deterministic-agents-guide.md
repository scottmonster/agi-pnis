# Guidance for Designing Deterministic–Agent Workflows

## Purpose

Use this guidance when designing workflows, orchestration systems, and tools that combine conventional software with AI agents.

The central design principle is:

> Put control in deterministic software when the correct action can be derived reliably from explicit state, rules, configuration, and observable evidence. Use agent judgment for bounded work whose value comes from interpretation, synthesis, investigation, evaluation, adaptation, or creative technical reasoning.

This principle is a decision aid, not a required architecture. A sound system may be centralized or distributed, sequential or event-driven, single-agent or multi-agent, short-lived or durable. The relevant question is not whether a component is called a coordinator, workflow engine, tool, or agent, but whether the responsibility actually benefits from probabilistic judgment.

Here, **deterministic control** means that a control decision is governed by explicit software logic over available inputs. It does not imply that networks, clocks, external APIs, or distributed systems are themselves perfectly deterministic.

## Separate three kinds of responsibility

A useful mental model is to distinguish:

* **Control and authority:** What may happen, when it may happen, what state is authoritative, which resources may be used, and which effects may be committed.
* **Judgment:** What the situation means, what information is relevant, what plan or explanation is best, what anomaly matters, or how to handle ambiguity.
* **Assurance:** What evidence is sufficient to accept an output, transition state, authorize an effect, or declare completion.

These responsibilities can be implemented together or separately. The distinction is useful because they often need different mechanisms.

In particular, do not assume that validation is always deterministic. Exact schemas, invariants, calculations, tests, signatures, permissions, and state transitions are good candidates for deterministic checks. Semantic quality, contextual correctness, novelty, usefulness, or ambiguous policy interpretation may require model-based or human judgment.

## Normative requirements

The following requirements constrain only the situations described in their scope.

### 1. Enforce authority independently of agent preference

**Required:** Where an agent can access protected resources or cause material side effects, effective permissions, capability limits, and required approvals `MUST` be enforced by mechanisms the agent cannot redefine merely by generating different text or choosing a different plan.

**Prohibited:** A system `MUST NOT` rely only on prompts, agent self-restraint, agent self-classification, or instructions embedded in untrusted content to enforce access or action boundaries.

**Why:** Agent reasoning can be mistaken or manipulated. A control boundary that exists only in model behavior can disappear precisely when the model misinterprets the task or follows hostile content.

**Scope:** Agent access to credentials, private data, external communications, code execution, financial or account actions, production systems, destructive operations, privilege changes, or other consequential capabilities.

### 2. Preserve authoritative state when recovery depends on it

**Required:** Material workflow state, approvals, committed side effects, and completion evidence `MUST` be durably recorded or reliably reconstructible outside transient model context when correct recovery, concurrency handling, audit, or resumption depends on them.

**Prohibited:** A workflow `MUST NOT` use an agent's current context, summary, or memory as the sole authoritative record of such state when loss, replay, retry, or concurrent execution could produce an incorrect outcome.

**Why:** Model context is a working representation, not a durable transaction log. Recovery is unsafe when the system cannot distinguish intended work from completed, pending, failed, or already-committed work.

**Scope:** Long-running, resumable, concurrent, audited, failure-sensitive, or side-effecting workflows.

### 3. Make automatic retries safe for side effects

**Required:** Automatic retry or replay of a mutating operation `MUST` use semantics that make repetition safe or explicitly handle uncertainty about whether the previous attempt took effect. Suitable mechanisms can include idempotency, deduplication, at-most-once execution, transactional commits, compensating actions, or reconciliation.

**Prohibited:** A system `MUST NOT` blindly retry a non-idempotent side effect when duplicate execution could create a materially incorrect result.

**Why:** Infrastructure and agent failures can occur after an external effect succeeds but before success is observed. Retrying without effect-aware semantics can duplicate charges, messages, writes, reservations, or other actions.

**Scope:** Automated retries, replay, redrive, recovery, or repeated agent attempts involving external mutation.

### 4. Bound autonomous execution

**Required:** An agent loop capable of repeated tool use or side effects `MUST` have enforceable stopping, budget, or escalation conditions appropriate to its risk and cost.

**Prohibited:** Such a loop `MUST NOT` be able to continue taking actions or consuming resources indefinitely solely because the model continues requesting another step.

**Why:** Open-ended reasoning is useful precisely because its path is not known in advance. That same property can create runaway cost, repeated failure, circular work, or uncontrolled effects without an external bound.

**Scope:** Iterative or recursive agent execution, dynamic delegation, repeated tool use, self-repair loops, and multi-agent expansion.

### 5. Require evidence appropriate to consequential completion claims

**Required:** Before a material workflow transition or completion claim is accepted as authoritative, the system `MUST` have evidence appropriate to the acceptance condition. When an objective check is available and material, use it. When only semantic judgment can establish acceptability, use an appropriate model or human review mechanism, or preserve the unresolved uncertainty.

**Prohibited:** A system `MUST NOT` treat an agent's unsupported assertion that work is complete, valid, safe, approved, or successful as sufficient when independent verification is materially necessary and practicable.

**Why:** Agents can stop early, misunderstand requirements, or mistake partial progress for completion. Acceptance should depend on evidence that addresses the actual success condition.

**Scope:** Consequential state transitions, externally visible commitments, safety or compliance gates, user-facing completion, and other cases where a false success would materially matter.

## Decide what should be deterministic

Prefer deterministic control when the decision can be expressed and maintained reliably from explicit inputs.

Common candidates include:

* workflow state transitions whose conditions are explicit;
* dependency readiness and scheduling;
* stable routing rules with well-defined categories;
* permissions, quotas, budgets, rate limits, and capability exposure;
* identity, authentication, authorization, and policy enforcement;
* exact calculations, normalization, parsing, serialization, and schema checks;
* artifact naming, storage, versioning, and provenance bookkeeping;
* retry policy, timeout handling, checkpointing, deduplication, and reconciliation;
* known ordering, fan-out, fan-in, and concurrency constraints;
* objective preconditions and postconditions;
* deterministic context assembly from authoritative records;
* tool invocation that is fully implied by explicit state or policy;
* acceptance checks with reliable executable or otherwise mechanical criteria.

The test is not whether an agent *can* perform the responsibility. Ask whether model judgment adds useful information. If software can derive the correct action more cheaply, transparently, and reliably, agent control usually adds unnecessary variability.

Do not confuse “implemented with an LLM at temperature zero” with deterministic control. If correctness depends on model interpretation, the responsibility remains probabilistic even when outputs are usually stable.

## Decide what genuinely benefits from agent judgment

Agent judgment is most useful where the desired behavior cannot be captured economically or robustly as explicit rules.

Typical examples include:

* interpreting ambiguous or unstructured requests;
* investigating a problem when the relevant path is not known in advance;
* forming and revising plans from intermediate evidence;
* diagnosing failures and generating hypotheses;
* synthesizing information across heterogeneous sources;
* choosing among technically valid approaches using contextual trade-offs;
* drafting, transforming, or explaining complex material;
* semantic review where acceptable outputs can vary legitimately;
* resolving exceptions whose meaning depends on context;
* deciding what additional information to seek;
* adapting tool use when the correct sequence emerges only during execution.

An agent is especially justified when a deterministic implementation would become a growing proxy for human interpretation: a large rule tree, exception catalog, brittle classifier stack, or workflow graph whose maintenance cost reflects semantic complexity rather than genuine process structure.

Even when judgment is necessary, broad authority is not. An agent can recommend a route, plan, patch, classification, or action while deterministic mechanisms retain responsibility for whether that proposal is permitted, committed, retried, or accepted.

## Choose control at the narrowest useful boundary

Avoid treating an entire workflow as either deterministic or agentic. Place the boundary around individual decisions.

A useful interaction pattern is:

1. deterministic logic establishes the current authoritative state, constraints, permissions, and available evidence;
2. the agent performs a bounded judgment task;
3. the agent returns a proposal, result, requested action, evidence, and relevant uncertainty in a form the surrounding system can inspect;
4. deterministic checks enforce mechanical constraints and permissions;
5. semantic or human review is used where mechanical checks cannot establish acceptance;
6. the system, not the model's prose, commits authoritative state changes and external effects.

This is a pattern, not a required topology. The same responsibilities can be distributed across services, embedded in tools, represented in an event log, or implemented in another form.

## Design agent interfaces as contracts

Give each agent interaction enough structure that the surrounding system can reason about it.

Useful inputs can include:

* the bounded objective;
* authoritative facts and current state;
* relevant artifacts or evidence;
* explicit constraints and non-goals;
* allowed tools or capabilities;
* acceptance criteria that are known in advance;
* resource or iteration budgets;
* what uncertainty or ambiguity should trigger escalation.

Useful outputs can include:

* the result or proposed action;
* structured fields needed by downstream logic;
* evidence or artifact references;
* assumptions and unresolved uncertainty;
* requested follow-up information;
* a status that distinguishes success, partial progress, blocked work, and failure.

Prefer structured interfaces where downstream software needs exact fields or choices. Preserve free-form space where the task genuinely requires explanation, synthesis, or creative judgment.

Do not force all agent work into schemas so rigid that the schema becomes a hidden rule engine for an inherently semantic task.

## Design tools to narrow ambiguity and blast radius

A tool is an authority boundary as well as an agent convenience.

Prefer tools that:

* have one clear purpose or a small coherent purpose;
* expose unambiguous names and parameters;
* separate reads from materially different writes when that improves control;
* validate inputs and enforce invariants themselves;
* return concise, meaningful results with stable identifiers;
* expose only the data and capability needed for the task;
* make important side effects explicit;
* support idempotency or reconciliation where repetition is possible;
* distinguish preview, proposal, and commit when the action benefits from review;
* return machine-readable error conditions that support reliable recovery.

If the correct tool is fully implied by workflow state, software can select it. If tool choice depends on semantic understanding or investigation, let the agent choose from the smallest useful authorized set.

Avoid giving an agent a large overlapping tool catalog and then asking the model to resolve distinctions that the tool design itself leaves ambiguous.

## Construct context deliberately

Treat context selection as another mixed control problem.

Deterministic construction is often preferable for:

* governing instructions;
* permissions and task constraints;
* authoritative workflow state;
* required records known from explicit identifiers or dependencies;
* stable configuration and policy;
* prior committed results that the current step depends on.

Agent-directed retrieval is often useful when relevance itself requires investigation, such as locating evidence, exploring a codebase, or identifying which documents matter.

Keep trust and relevance separate. Content can be highly relevant while still being untrusted. Retrieved text, tool output, webpages, messages, documents, and other external material should normally be treated as evidence or data, not as new authority.

For long-running work, keep recoverable source state and artifacts outside the context window. Summaries and memories are useful working aids, but they can omit information and should not silently replace authoritative records.

## Validate with the mechanism that fits the claim

Use the strongest practical verifier for the property being checked, not one universal validation method.

**Deterministic checks** are strong for properties such as schema conformance, exact values, permissions, invariants, signatures, tests, static analysis, resource limits, and observable state.

**Model-based evaluation** can be useful for semantic criteria, open-ended outputs, contextual relevance, comparative quality, or cases where many valid answers exist. Treat it as probabilistic, calibrate it against representative human judgments where important, and avoid using it as if it were a formal proof.

**Human review** is appropriate when consequences, accountability, domain expertise, value judgments, or unresolved ambiguity exceed what automated assurance can support. Human review is not automatically necessary for every agent action; place it where it materially changes risk or quality.

Combine methods when they check different failure modes. For example, a code change can pass deterministic tests yet still require semantic review for maintainability or product intent.

## Treat plans as proposals, not ground truth

Agent-generated plans are useful when decomposition itself requires judgment. They can also be wrong or become stale as new evidence appears.

Consider separating:

* **planning:** what the agent currently believes should happen;
* **authorization:** which actions the system permits;
* **execution state:** what has actually happened;
* **acceptance:** what evidence establishes that the result is good enough.

A plan can be revised without rewriting history or silently changing permissions.

When the entire sequence and branching logic are stable and known in advance, encode that structure directly rather than repeatedly asking an agent to rediscover it.

## Match autonomy to consequence and recoverability

Autonomy is not a binary property. An agent can have wide discretion over reasoning while having narrow discretion over effects.

Increase autonomy when:

* the environment is trusted;
* actions are reversible or low-impact;
* feedback is fast and informative;
* objective progress signals are available;
* failures are cheap to detect and recover;
* the agent has demonstrated reliable performance on representative tasks.

Reduce autonomy or add checkpoints when:

* effects are irreversible or externally consequential;
* permissions are broad;
* private or adversarial data is involved;
* success is hard to verify;
* failure can propagate before detection;
* legal, safety, financial, or organizational accountability requires review;
* the agent is operating outside evaluated conditions.

Prefer risk-based intervention to approval fatigue. Requiring a person to approve every harmless action can train reviewers to click through mechanically while obscuring the few actions that deserve attention.

## Recover by failure type

Do not treat every failure as “ask the agent again.”

Distinguish at least:

* **transient infrastructure failure:** retry using effect-safe semantics;
* **deterministic validation failure:** return the specific failed condition and let the agent revise if revision is useful;
* **agent reasoning or execution failure:** provide new evidence, change strategy, use a stronger or specialized model, or escalate;
* **missing or ambiguous information:** obtain the information rather than hallucinating through the gap;
* **permission or policy failure:** stop or seek authorized approval; do not let repeated reasoning bypass the boundary;
* **partial external failure:** reconcile actual external state before deciding what to repeat;
* **repeated or unclear failure:** preserve artifacts and trace, stop consuming budget, and escalate.

Checkpoint at boundaries that let work resume without repeating expensive reasoning or unsafe effects. Preserve enough history to understand what the agent saw, decided, attempted, and actually changed when that distinction matters.

## Avoid unnecessary agent autonomy

Warning signs include:

* the agent chooses a branch even though an explicit rule already determines it;
* the agent decides whether it has permission rather than asking an authorization mechanism;
* the agent maintains workflow status only in its own memory;
* the agent decides that a mechanical test passed without running or checking it;
* the agent is asked to rediscover a fixed sequence on every run;
* the agent selects among nearly identical tools whose distinction could be encoded directly;
* the agent decides retry timing, duplicate handling, or transaction semantics that infrastructure can enforce;
* a multi-agent hierarchy exists mainly to imitate an organization rather than to improve quality, context separation, parallelism, or control.

Replacing these responsibilities with software usually improves reproducibility, latency, cost, debuggability, and auditability without sacrificing useful intelligence.

## Avoid brittle over-automation

Warning signs on the other side include:

* rapidly growing rules that encode subtle semantic exceptions;
* branches based on concepts that humans themselves cannot define consistently;
* a workflow graph that must enumerate unpredictable investigative paths;
* deterministic validators that reject valid variation because they measure a proxy rather than the real requirement;
* excessive preprocessing that removes context the agent needs for judgment;
* routing rules that are less reliable than a well-evaluated semantic classifier;
* forcing open-ended work into fixed stages that prevent useful adaptation;
* hard-coded scaffolding retained after model capability or task conditions change.

When rules become a fragile surrogate for judgment, move the semantic decision into a bounded agent step while preserving deterministic controls around authority, evidence, and state.

## Choose orchestration complexity only when it earns its cost

No single orchestration style is generally required.

A fixed workflow is often appropriate when steps and branches are known. A dynamic agent loop is useful when the path must emerge from evidence. A hybrid can keep stable portions explicit while allowing agents to plan or investigate within selected regions.

A single agent is often easier to evaluate and operate than multiple agents. Add additional agents when they provide a concrete benefit such as:

* distinct expertise or instructions;
* context isolation;
* parallel independent work;
* independent critique or evaluation;
* separation of conflicting objectives;
* decomposition too dynamic for a single context.

Do not add agents merely to create roles. Every handoff adds another probabilistic interface, additional context management, latency, cost, and failure surface.

Likewise, do not require a central coordinator merely because deterministic control exists. State and control can be distributed as long as authority, consistency, recovery, and observability remain adequate for the task.

## Evaluate the whole system, not only the model

Agent reliability depends on the model, prompts, tools, context construction, permissions, orchestration, environment, and recovery behavior.

Evaluate representative end-to-end tasks and important failure conditions. Depending on the system, useful measures can include:

* task outcome quality;
* false success and premature completion;
* tool-selection and argument errors;
* policy or permission violations;
* duplicate or missing side effects;
* recovery after interruption;
* performance under ambiguous, malformed, stale, or adversarial inputs;
* human intervention rate and value;
* latency, token use, external cost, and number of steps;
* regression after model, prompt, tool, policy, or workflow changes.

Use deterministic regression checks wherever the expected property is exact. Add model or human graders for semantic properties. Test the boundaries between components, not just each component in isolation.

## Revisit the boundary over time

The correct deterministic–agent split can change.

Move work toward deterministic software when repeated agent behavior reveals a stable rule, invariant, reusable transformation, or common tool sequence that no longer benefits from judgment.

Move work toward agent judgment when deterministic logic accumulates unstable exceptions, fails under normal variation, or requires continual manual rule maintenance to approximate semantic understanding.

Reassess controls when models, tools, threat conditions, costs, or workflow requirements change. Preserve stable external contracts where possible so that the reasoning component can evolve without rewriting authority, state, and recovery mechanisms.

## Compact decision test

For each responsibility, ask:

1. **Can the correct action be derived reliably from explicit state, rules, configuration, and observable evidence?**
   If yes, prefer deterministic control.

2. **Does success depend on interpretation, investigation, synthesis, contextual trade-offs, or adaptation to evidence that cannot be enumerated economically?**
   If yes, consider bounded agent judgment.

3. **What authority does this decision need?**
   Grant only the capabilities needed; keep enforceable limits outside agent preference.

4. **How will the result be accepted?**
   Use mechanical checks for mechanical properties and semantic or human review for genuinely semantic properties.

5. **What happens if the step is wrong, interrupted, repeated, or manipulated?**
   Design state, retries, checkpoints, escalation, and observability according to that consequence.

6. **Is the chosen complexity paying for itself?**
   Prefer the simplest design that meets the required quality, flexibility, safety, and operational needs.

