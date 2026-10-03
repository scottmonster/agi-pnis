# Agent-Environment Failure Modes

**Status: Draft for discussion; non-authoritative.**

This document describes failure families that may be useful when preserving and analyzing evidence around material human or agent judgment. It creates no requirement or binding direction unless an authoritative source adopts it.

It supplements [the Judgment Evidence Extension](standard.md) and [the Material Judgment Records standard](../.agents/gov/policy/execution/judgement_record.md). It does not replace either one or require comprehensive failure tracking.

## 1. Purpose

The goal is to learn which capability or condition did not adequately support an intended outcome, and where improvement may be possible. A poor outcome is not automatically an agent-judgment failure. It may arise from the task, available information, tool or runtime environment, interaction design, or the system used to evaluate the result.

These families are prompts for investigation and cross-record comparison. They are not a universal taxonomy, a finding of root cause, or an attribution of fault.

## 2. Evidence principle

For a material episode, preserve the observed mismatch, relevant conditions, and available supporting or contrary evidence. Distinguish the following:

- **Observed outcome:** what happened or was measured.
- **Evaluation:** how the outcome was assessed against a criterion.
- **Candidate failure family:** the condition or capability that may have contributed.
- **Inference or hypothesis:** an explanation supported to a stated degree, but not directly established.
- **Tested finding:** a bounded conclusion supported by an identified comparison, replay, or other test.

Comparable successful episodes are also important evidence. They can show whether a suspected condition is a recurring limitation, an isolated event, or ordinary variation.

## 3. Failure families

### 3.1 Judgment, authority, and escalation

The agent or person exercised discretion poorly, applied authority beyond its scope, generalized a local precedent too broadly, failed to identify a material uncertainty, or did not surface an unresolved question to the appropriate authority.

### 3.2 Task and requirement understanding

The task's objective, constraints, prohibited outcomes, acceptance criteria, priority, or scope was misunderstood, missing, contradictory, or insufficiently specified.

### 3.3 Context and evidence availability

Material information was absent, stale, truncated, retrieved incorrectly, inaccessible, or incorrectly weighted. This may include lost conversation context, an omitted repository artifact, stale memory, or an incomplete environment observation.

### 3.4 Planning and scope control

The selected approach, decomposition, ordering, stopping condition, or scope control was unsuitable. Examples include pursuing an unproductive strategy, expanding the task unnecessarily, omitting a necessary step, or stopping before the work is complete.

### 3.5 Knowledge and calibration

The actor made an unsupported claim, treated uncertain information as established, failed to communicate uncertainty, or acted despite a material knowledge gap.

### 3.6 Tool selection and action execution

An unsuitable tool was selected, a suitable tool was used incorrectly, a tool result was mishandled, or an action produced an unintended state change. The failure may lie in the agent's use of the tool, the tool interface, or the tool's behavior.

### 3.7 Verification and quality control

The work was not checked when checking was needed, the wrong validation was used, a valid result was misread, a material regression went undetected, or completion was declared without adequate evidence.

### 3.8 Safety, policy, permission, and authority boundaries

An applicable safeguard, policy, permission limit, or approval boundary was missed, misinterpreted, unavailable, or prevented safe completion. This family includes both unsafe action and an environment that made the safe path unavailable.

### 3.9 Communication and feedback

The actor failed to ask a necessary question, surfaced it too late, misunderstood feedback, concealed a limitation, or communicated a result in a way that prevented accurate review or use.

### 3.10 Memory and long-horizon state

Material information was lost, stale state was reused, prior work or direction was not recovered, or state was preserved in a form that later work could not safely interpret.

### 3.11 Collaboration and handoff

People or agents had unclear roles, lost material context during a handoff, duplicated or contradicted work, or left responsibility for a decision, action, or validation ambiguous.

### 3.12 Resource and termination

Token, time, cost, retry, context-window, concurrency, or other resource limits caused looping, degraded performance, premature termination, or prevented an otherwise sound approach.

### 3.13 Runtime and environment

The harness, model or configuration version, repository state, sandbox, tool service, network, external dependency, or other environment condition limited or distorted the work.

### 3.14 Measurement and review

A test, evaluator, rubric, feedback signal, or review process was absent, incorrect, biased, incomplete, or unable to detect the outcome that matters. This is a failure of the evidence or assessment system, not necessarily of the agent or work product.

## 4. Use in material records

Use a failure family only when it materially improves understanding of a judgment episode, a JFR, or linked evidence. Record the specific observed deviation and conditions before applying a category.

The evidence should identify, where available:

- the intended outcome or criterion;
- the observed outcome and its impact;
- the evidence and evaluator that established the difference;
- the candidate failure family or families;
- supporting and contrary evidence;
- whether any explanation is observed, inferred, hypothesized, tested, or unknown; and
- the episode's applicable scope, conditions, and limitations.

Several families may apply. Do not force an episode into one category when task ambiguity, context, execution, and measurement all materially contributed.

## 5. Analytical boundary

Repeated categories can identify questions worth investigating: whether agents need clearer direction, better evidence access, different tools, stronger validation, safer authority boundaries, improved collaboration, or better evaluation.

They do not by themselves establish a root cause, a general rule, a fault assignment, or an authorized remediation. Any resulting governing direction belongs in a Material Judgment Record with its own authority, scope, rationale, and evidence.
