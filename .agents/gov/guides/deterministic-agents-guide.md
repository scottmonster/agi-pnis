# Guidance for Designing Deterministic-Agent Workflows

Use this guidance when designing a workflow, orchestration system, or tool that combines conventional software with AI agents.

The central principle is:

> Put mechanically enforceable control in software. Use agent judgment for bounded work whose value comes from interpretation, investigation, synthesis, evaluation, adaptation, or creative technical reasoning.

Mechanically enforceable control is broader than literal determinism. External services, networks, clocks, and concurrent processes can be unpredictable while software still enforces permissions, invariants, limits, state transitions, and acceptance conditions from explicit rules and observable evidence.

## How to Use This Guidance

_MUST_ and _MUST NOT_ identify requirements intrinsic to this guidance. The remaining principles, examples, and design questions are advisory. The requirements constrain only the stated situation; they do not require a particular coordinator, runtime, topology, agent framework, or implementation language.

Examine individual decisions rather than classifying an entire component as deterministic or agentic. A workflow can combine software-controlled state and permissions with agent-directed investigation or planning. Validation can combine mechanical checks, model evaluation, and human judgment.

## Separate Control, Judgment, and Assurance

Distinguish three responsibilities:

* **Control and authority:** What may happen, when it may happen, what state is authoritative, which resources may be used, and which effects may be committed.
* **Judgment:** What the situation means, what information matters, what approach is appropriate, and how ambiguity or exceptions should be resolved.
* **Assurance:** What evidence is sufficient to accept an output, transition state, authorize an effect, or declare completion.

Control and authority commonly belong in software. Judgment commonly benefits from an agent. Assurance depends on the claim: exact properties can often be checked mechanically, while semantic quality or contextual correctness may need model or human evaluation.

## Normative Guardrails

### Enforce material invariants outside agent discretion

**Required:** A constraint whose violation could create materially unauthorized behavior, unsafe effects, corrupted workflow state, or another unacceptable outcome `MUST` be enforced by a trusted mechanism that does not depend solely on the acting agent choosing to comply.

**Prohibited:** Such an invariant `MUST NOT` rely solely on prompts, agent reasoning, self-restraint, or the agent's statement that the condition was satisfied.

**Why:** A constraint that must hold needs an enforceable boundary.

**Scope:** Material safety, authorization, integrity, and workflow invariants. Preferences and ordinary quality criteria remain outside this requirement.

### Preserve authority boundaries

**Required:** Permissions, capability limits, and approvals for protected or materially consequential effects `MUST` be determined by a trusted mechanism outside the requesting agent. When automatic policy cannot safely authorize an action, approval `MUST` come from an appropriate external authority.

**Prohibited:** An agent `MUST NOT` grant itself additional authority, approve its own escalation, or acquire authority merely because retrieved content, another agent, or a tool output instructs it to do so.

**Why:** Untrusted content or mistaken reasoning must not become a path to unauthorized effects.

**Scope:** Protected data, privileged systems, external communications, destructive operations, financial or account actions, and other consequential capabilities.

### Preserve recoverable state and safe retries

**Required:** Material workflow state, approvals, committed side effects, and completion evidence `MUST` be durably recorded or reliably reconstructible outside transient model context when recovery, concurrency handling, audit, or resumption depends on them. Automatic retry or replay of a mutating operation `MUST` make repetition safe or explicitly handle uncertainty about whether the previous attempt took effect.

**Prohibited:** A workflow `MUST NOT` use agent context, summaries, or memory as the sole authoritative record when loss, replay, retry, or concurrent execution could produce an incorrect outcome. It `MUST NOT` blindly repeat a non-idempotent side effect when duplicate execution could create a material failure.

**Why:** Model context is a working aid, not a durable transaction log. A failed observation of an effect is not evidence that the effect did not occur.

**Scope:** Long-running, resumable, concurrent, audited, failure-sensitive, or side-effecting work. Pure reads and duplicate effects known to be harmless do not require additional machinery.

### Bound autonomous execution

**Required:** An iterative agent loop capable of repeated tool use or side effects `MUST` have enforceable stopping, budget, or escalation conditions appropriate to its risk and cost.

**Prohibited:** Such a loop `MUST NOT` continue taking actions or consuming resources indefinitely solely because the model requests another step.

**Why:** Open-ended reasoning can be useful, but it can also create circular work, repeated failure, runaway cost, or uncontrolled effects.

**Scope:** Repeated tool use, self-repair loops, dynamic delegation, recursive planning, and multi-agent expansion.

### Base consequential acceptance on evidence

**Required:** Before a material workflow transition or completion claim is accepted as authoritative, the system `MUST` have evidence appropriate to the acceptance condition. Use an objective check when one is available and material. When only semantic judgment can establish acceptability, use an appropriate model or human review mechanism, or preserve the unresolved uncertainty.

**Prohibited:** A system `MUST NOT` treat an agent's unsupported assertion that work is complete, valid, safe, approved, or successful as sufficient when independent verification is materially necessary and practicable.

**Why:** A plausible final narrative does not establish that the intended state of the world was reached.

**Scope:** Consequential state transitions, externally visible commitments, safety or compliance gates, and other cases where a false success materially matters.

## Choose the Boundary Per Decision

Prefer software-controlled decisions when explicit state, rules, configuration, authorization, or observable evidence can derive the correct action adequately. Common examples include permissions, quotas, schemas, invariants, workflow state, dependencies, scheduling under explicit constraints, exact calculations, artifact storage, timeouts, retries, deduplication, and known state transitions.

Prefer agent judgment when success depends materially on interpretation or investigation that cannot be captured economically or robustly as rules. Common examples include ambiguous request interpretation, unfamiliar diagnosis, semantic decomposition, technical design, synthesis, contextual trade-offs, open-ended implementation, and semantic review.

The test is not whether an agent can perform the task. Ask whether model judgment adds useful information. If a rule is reliable and transparent, agent control usually adds variability without value. Conversely, an expanding exception tree, brittle proxy, or fixed workflow that fails under ordinary variation may indicate that semantic judgment has been encoded as rules.

## Bound Agent Work, Not Just Agent Access

Give an agent a specific objective, relevant success criteria, authoritative facts, permitted tools and information sources, resource limits, constraints, and escalation conditions. Let the agent choose its method when that choice is part of the value being sought.

A common interaction pattern is:

1. Software establishes authoritative state, constraints, permissions, and available evidence.
2. The agent performs a bounded judgment task.
3. The agent returns a result, proposal, evidence, assumptions, and relevant uncertainty.
4. Software enforces mechanical constraints and commits valid state changes or effects.
5. Model or human review supplies any remaining semantic assurance.

This is a pattern, not a required lifecycle. Control can be centralized or distributed. The important distinction is that an agent may propose what to attempt without deciding whether it has authority to do it.

Use structured inputs and outputs where later software needs exact fields, identifiers, or status. Retain free-form space where explanation, synthesis, or creative work is the point. Do not make a schema so rigid that it becomes a hidden rule engine for an inherently semantic task.

## Design Context, Tools, and Validation Deliberately

Construct context deterministically when the inputs are known from authority, dependencies, identifiers, policy, or committed state. Let agents retrieve or investigate within that boundary when relevance itself requires judgment. Treat retrieved documents, webpages, tool outputs, and memories as information or evidence, not automatically as authority.

Prefer tools with a clear purpose, unambiguous parameters, limited capability, explicit side effects, stable identifiers, input validation, and machine-readable failures. Separate preview, proposal, and commit when a consequential action benefits from review. Do not give an agent a large, overlapping tool catalog when software could resolve the distinction directly.

Use the strongest practical verifier for the property being checked. Tests, schemas, signatures, calculations, permissions, invariants, and observable state support mechanical checks. Semantic quality, contextual correctness, and value-dependent choices may need model evaluation or human review. A second agent is not automatically independent or reliable merely because it is separate.

## Match Autonomy and Recovery to Risk

Increase autonomy where actions are reversible, low-impact, well-observed, inexpensive to recover, and within evaluated conditions. Reduce autonomy or add checkpoints where effects are consequential or irreversible, permissions are broad, data is private or adversarial, success is difficult to verify, or failure can propagate before detection.

Classify predictable failures mechanically. Retry transient failures with effect-safe semantics. Return specific validation failures when an agent can revise the result. Reconcile external state after partial failure before repeating work. Stop and seek authorization when the problem is a permission or policy boundary. When diagnosis or remediation requires semantic judgment, delegate the smallest unresolved question and return control to the workflow afterward.

Human review is most useful where a person can make a meaningful decision about a consequential, ambiguous, or poorly verifiable action. Do not require ceremonial approval for harmless actions merely because they involve an agent.

## Keep Orchestration No More Complex Than Necessary

A fixed workflow is often suitable when steps and branches are known. A dynamic agent loop is useful when the path must emerge from evidence. A hybrid can make stable portions explicit while allowing bounded planning or investigation where the path is uncertain.

Likewise, a single agent is often easier to operate and evaluate than multiple agents. Add agents when they provide a concrete benefit such as distinct expertise, context isolation, parallel independent work, independent critique, or dynamic decomposition. Do not add roles merely to imitate an organization.

Revisit the boundary as the system learns. Promote repeated agent decisions into software when they become stable and mechanically specifiable. Move brittle rules back into bounded agent judgment when they accumulate exceptions or fail under normal variation. Use representative evaluations, incidents, traces, and operator feedback to check the whole system, including its prompts, tools, context, permissions, recovery behavior, and acceptance criteria.

## Decision Test

For each responsibility, ask:

1. Can explicit state, rules, configuration, and observable evidence determine the correct action reliably enough?
2. If not, what is the smallest judgment that requires an agent?
3. What authority and information does that judgment actually need?
4. What evidence can establish that the resulting work is acceptable?
5. What happens if the step is wrong, interrupted, repeated, or manipulated?
6. Does the added orchestration complexity produce enough benefit to justify its cost?

The goal is neither maximum determinism nor maximum autonomy. It is to place each decision where it can be made and controlled most reliably while preserving agent judgment where it is genuinely useful.
