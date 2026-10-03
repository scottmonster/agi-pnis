# Failure Index

**Status: Draft for discussion; non-authoritative.**

This index combines the failure names in [failure_lists.md](failure_lists.md) and [failure_modes.md](failure_modes.md). It classifies each entry by its nearest credible preventive intervention, not by proven root cause or fault.

An episode may have more than one classification. Record an entry only when available evidence supports it as a candidate. Use unresolved when the evidence does not establish a credible prevention locus.

## 1. Agent-level preventable failures

*(A change to the agent's instructions, skills, policies, planning, escalation behavior, or verification behavior could likely have prevented the deviation using the available tools, authority, and context.)*

- **Authority and escalation failure**: Does not recognize that a material question is unresolved, acts beyond delegated authority, or fails to surface the question to the appropriate authority.
- **Requirement interpretation failure**: Misunderstands the request, objective, constraint, acceptance criterion, priority, or required format.
- **Requirement-application failure**: Fails to apply an explicit, available requirement or constraint during the work.
- **Assumption and calibration failure**: Acts on unsupported assumptions, hallucinates facts or capabilities, treats uncertainty as established, or fails to disclose a material knowledge gap.
- **Context and goal-management failure**: Loses sight of material available context, drifts from the task goal, or weights relevant information poorly.
- **Clarification failure**: Fails to ask a necessary question, seek missing information, or state that under-specification prevents a safe or reliable result.
- **Planning and decomposition failure**: Selects an unsuitable approach, omits a necessary step, orders work poorly, or cannot make progress toward the objective.
- **Scope and complexity-control failure**: Adds unnecessary complexity, rewrites reusable existing work, overfits to examples, or expands the task beyond its justified scope.
- **Implementation correctness failure**: Produces incomplete, syntactically invalid, logically incorrect, or functionally incorrect work where the available evidence and capability could have supported a correct implementation.
- **Tool-use failure**: Selects an unsuitable available tool, uses an available tool incorrectly, or mishandles a material tool result.
- **Tool-recovery failure**: Fails to retry appropriately, select a viable fallback, communicate a tool limitation, or escalate after a tool error.
- **Termination-control failure**: Repeats actions without justified progress, loops, stalls, or stops before the task has reached a justified completion boundary.
- **Verification-conduct failure**: Fails to perform an available material check, applies it incorrectly, or declares success without adequate available validation.
- **Communication and feedback failure**: Misunderstands feedback, conceals a material limitation, or communicates the result in a way that prevents accurate review or use.

## 2. Tool-level preventable failures

*(A change to a tool, validator, guardrail, interface, integration, harness capability, or runtime control could likely have prevented the deviation, detected it before impact, or made safe completion feasible.)*

- **Missing capability failure**: No available tool or integrated capability could perform a material action, retrieve necessary evidence, or safely validate the intended result.
- **Tool interface failure**: A tool's interface, schema, feedback, affordances, or integration made correct use materially unreliable or impractical.
- **Tool-result failure**: A tool returned an incorrect, incomplete, stale, incompatible, or otherwise misleading result.
- **Validation-capability failure**: Available validation was missing, insufficient, unreliable, or unable to check the criterion that mattered.
- **Guardrail and precondition failure**: A missing or inadequate guardrail, confirmation, permission check, or precondition allowed an unsafe or unintended action.
- **Context-capacity failure**: Context-window, compaction, retrieval, or context-assembly behavior made material information unavailable at the point of use.
- **Memory and state-persistence failure**: The system lost, corrupted, or surfaced stale long-horizon state, prior decisions, inputs, or relevant memory.
- **Resource-control failure**: Token, time, cost, retry, concurrency, CPU, memory, or storage limits prevented completion or caused degraded behavior.
- **Dependency and compatibility failure**: A dependency was unavailable or incompatible, dependency versions conflicted, or the runtime environment differed materially from what the work required.
- **Runtime and environment failure**: A model or configuration version, sandbox, repository state, network, service, or other execution-environment condition prevented or distorted the work.

## 3. Shared agent-and-tool preventable failures

*(Both an agent-level change and a tool-level or harness-level change are credible preventive interventions. Do not assign fault from this classification.)*

- **Constraint-enforcement failure**: A defined rule, limit, specification, or output-format requirement was violated because the agent did not comply, the system did not adequately enforce it, or both.
- **Safety and permission-boundary failure**: An unauthorized action, security violation, data leakage, or other prohibited action occurred because the actor, the available controls, or both did not maintain the required boundary.
- **State-change protection failure**: A filesystem, repository, database, configuration, or other material state was deleted, overwritten, misplaced, or corrupted without adequate agent caution, tool safeguards, or both.
- **Verification interpretation failure**: A check was skipped, misread, falsely passed, or falsely failed because the agent's verification behavior, the validation capability, or both were inadequate.
- **Handoff and coordination failure**: Human or agent roles were unclear, material context was lost during handoff, work was duplicated or contradicted, or responsibility for action or validation was ambiguous.
- **Environment-readiness failure**: The actor proceeded under an incorrect environmental assumption and the system lacked adequate inspection, preflight, compatibility, or recovery support.

## 4. Task, authority, external, or unresolved conditions

*(The available evidence does not support classifying the episode as primarily agent-level or tool-level preventable, or the needed intervention lies outside the present agent-tool system.)*

- **Task-contract deficiency**: The objective, constraint, acceptance criterion, priority, or scope was missing, contradictory, or materially insufficient for safe completion.
- **Unavailable authority**: The needed decision, permission, or approval was not available in time for dependent work to proceed.
- **External dependency outage**: A third-party system, service, source, or actor failed or was unavailable outside the relevant agent-tool system's control.
- **Unresolved prevention locus**: An outcome differed from what was needed, but the available evidence cannot credibly identify an agent, tool, task, authority, or external condition that could have prevented it.

## 5. Outcome and evaluation signals

*(These describe what was observed or measured. They are not, by themselves, a prevention-locus classification.)*

- **Task noncompletion**: The intended objective was not completed.
- **Partial completion**: Some required work was completed, but one or more material parts remain incomplete.
- **Incorrect output**: The delivered result does not meet an applicable requirement or expected outcome.
- **Build or syntax failure**: The produced artifact does not parse, compile, or otherwise meet a required structural validity check.
- **Runtime failure**: The produced artifact crashes, throws an error, or otherwise fails during execution.
- **Regression**: A change breaks functionality or a previously satisfied requirement.
- **Inconsistent behavior**: Materially similar conditions produce conflicting results beyond an accepted variation boundary.
- **Unacceptable nondeterminism**: Repeated materially similar conditions produce variation that violates a stated consistency, reproducibility, or reliability need.
- **Validation failure**: A test, policy check, review, or other assessment finds that the observed result does not meet its criterion.
- **False-positive validation**: Validation reports success even though the applicable criterion was not met.
- **False-negative validation**: Validation reports failure even though the applicable criterion was met.

## 6. Use

Start with the observed outcome and its evaluation basis. Then record one or more candidate prevention loci from sections 1 through 4, together with supporting and contrary evidence, scope, conditions, and uncertainty.

Repeated entries can identify improvement opportunities. They do not establish root cause, fault, a universal lesson, or an authorized remediation. A resulting governing decision belongs in a Material Judgment Record.
