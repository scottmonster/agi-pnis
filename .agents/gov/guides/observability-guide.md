# Agent Observability and Diagnosability Guidance

Use this guidance when designing, executing, or reviewing agent work that may need to be understood after it fails, stalls, diverges, or produces an uncertain result.

This guide helps make consequential work diagnosable. It complements `agent-recovery-guide.md`: recovery guidance concerns what to do after progress breaks down; this guidance concerns what information should exist so the breakdown can be understood. It does not require a telemetry system, fixed log format, exhaustive transcript, or universal checkpoint process.

## Normative Guardrails

These requirements apply only to consequential work and the information needed to understand it.

### Preserve a reconstructable basis

**Required:** Consequential work `MUST` preserve enough information to reconstruct the material basis of an important result, failure, state change, or handoff. This includes, as applicable, the objective, governing constraints, relevant inputs and environment, consequential action, observed result, verification status, and material uncertainty or side-effect risk.

**Prohibited:** Consequential work `MUST NOT` depend on an important decision, state change, or claimed outcome that cannot be understood to the degree reasonably necessary for the task without making that limitation visible.

**Why:** A later agent or reviewer cannot diagnose a result from an action alone when the objective, conditions, evidence, or state are unknown.

### Keep execution status distinct

**Required:** An agent `MUST` distinguish, when material, between an intended action, an attempted action, a returned result, an observed state change, a verified outcome, and an unresolved or inferred outcome.

**Prohibited:** An agent `MUST NOT` represent an attempt, an unverified response, or an inference as confirmation that the intended outcome occurred.

**Why:** A successful-looking operation can fail to achieve the task, and an error or timeout can leave the external state uncertain.

### Preserve useful diagnostic evidence

**Required:** When an error, unexpected result, negative finding, or state-changing action could materially affect recovery or a later decision, the agent `MUST` preserve the relevant evidence or a usable reference to it.

**Prohibited:** The agent `MUST NOT` discard or obscure material evidence in a way that causes a later actor to repeat the same investigation or guess about consequential state.

**Why:** Useful negative results, observed failures, and state evidence reduce repeated work and make recovery more reliable.

### Keep observability proportionate and safe

**Required:** Records, traces, checkpoints, and summaries `MUST` be proportionate to the work's consequence, reversibility, diagnostic value, and applicable security, privacy, and retention constraints.

**Prohibited:** An agent `MUST NOT` collect or retain secrets, sensitive information, exhaustive transcripts, or low-value telemetry merely for completeness when they are unnecessary for the work or violate applicable constraints.

**Why:** More records do not necessarily create better diagnosis, and unnecessary records can create cost, clutter, and exposure.

## Decide What Needs to Be Observable

Focus on information that could change later understanding or recovery. Useful questions include:

* What outcome was intended, and which constraints governed it?
* What state or evidence would show whether that outcome occurred?
* Which inputs, assumptions, environment conditions, dependencies, or permissions could explain a different result?
* Which actions could create material side effects, partial execution, or uncertain state?
* What evidence would prevent the next agent from repeating the same failed investigation?

Do not record every internal thought or ordinary low-risk action. Preserve the smallest set of information that makes consequential work understandable.

## Make Evidence Usable

Useful observability can take different forms: concise state notes, command or tool results, test output, error messages, structured action records, checkpoints, links to artifacts, version or configuration identifiers, external records, or a handoff summary.

Choose a form that lets a later actor answer, where relevant:

* What was the intended outcome?
* What was actually attempted?
* What was observed rather than assumed?
* What changed, and what may have changed?
* What was verified, inferred, or left unknown?
* Which evidence supports the current diagnosis or next step?

Prefer stable references to large raw artifacts when they preserve the needed evidence. A concise summary should retain the objective, established state, consequential actions and results, unresolved uncertainty, and relevant next steps rather than merely shortening a transcript.

## Use Feedback That Can Change the Decision

When practical, seek evidence that distinguishes between meaningful recovery paths: direct state inspection, an executable test, a known-good comparison, an authoritative record, a reproducible failure, a counterexample, or an independent evaluation.

Record the conditions that materially affect interpretation. An error message without the relevant input, environment, or preceding state may be less useful than a smaller record that preserves those relationships.

## Preserve Continuity Across Boundaries

Long-running work, context limits, delegation, and handoffs can all break continuity. When that risk is material, preserve the high-value state before it is lost:

* the objective and governing constraints;
* confirmed facts and material assumptions;
* current environment or external state;
* consequential actions, results, and side-effect concerns;
* eliminated explanations and useful negative results; and
* unresolved questions, blockers, and the next useful directions.

Use checkpoints, persistent notes, a fresh context, delegation, or a handoff only when they improve continuity for the task. They are alternatives, not required stages.

## Relationship to Recovery

Observability should make recovery more effective, not replace it. When work fails, use the available evidence to determine whether to contain harm, inspect state, test an explanation, change approach, verify an outcome, or escalate. If the available evidence is insufficient, make that limitation visible rather than inventing a history or state.

For minor and clearly transient work, lightweight evidence may be enough. For recurrent, irreversible, externally visible, or high-impact work, stronger traceability can prevent the same failure from being rediscovered and can make a safe handoff possible.
