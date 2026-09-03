# Engineering Principles Framework

## Purpose, authority, and terms

Use this framework for product code, infrastructure, interfaces, tests, configuration, documentation, and the work needed to operate them.
It helps human developers and coding agents meet present needs with systems that are adequate, understandable, changeable, and no more complex than demonstrated needs require.
It prevents speculative features, premature abstractions, excessive mechanism power, artificial boundaries, rigid hierarchies, and choices based only on aesthetic preference.

`MUST` identifies a required framework rule.
`SHOULD` identifies a default that may be departed from only when a documented present requirement, constraint, or demonstrated burden supports departure.
`MAY` identifies a permitted choice.
A **default** applies unless present evidence supports departure; a **heuristic** is a decision aid, not a mechanical rule; a **preference** may lose to a simpler adequate design; a **tie-breaker** applies only after competing options are adequate.
The framework is one sequence, not a scorecard: a later principle cannot outvote an earlier rejected gate.

> Complexity is justified only by demonstrated requirements or constraints. Do not introduce complexity that is unnecessary, speculative, premature, or insufficiently justified.

KISS governs the whole framework, including decisions before and after its sequence position.
YAGNI remains first because it decides whether a present problem exists.

## Evidence and complexity

Judge simplicity across the affected system, not by line count, file count, or local brevity.
Cost includes concepts, states, dependencies, indirection, configuration, coordination, failure modes, operational work, and maintenance.

- A **present requirement** is an accepted behavior, contractual obligation, policy, safety or security need, or committed delivery need the system must meet now.
- A **constraint** is a real limit, such as a measured performance need, platform limitation, compatibility obligation, reliability target, operating condition, or resource limit.
- A **demonstrated burden** is observable current repetition, coupling, defects, operational toil, or change cost.
- A forecast, hoped-for reuse, possible future scale, or personal preference is not evidence alone. It may justify measurement, a spike, or a reversible experiment, not permanent complexity.

## Decision flow

Apply these steps in order to every proposed addition or material change; each limits later options.
Do not continue a rejected proposal by relabeling it an abstraction, boundary, safeguard, or future-proofing.

### 1. YAGNI, scope gate: Is this needed now?

Build, retain, or expand a capability only for a present requirement, constraint, or demonstrated burden.
If not, do not build it now; record the idea only if doing so costs little and creates no implementation commitment.
**Rationale:** Future needs are uncertain, while features create immediate cost and can narrow later choices.
**Outcome:** Only work with a demonstrated reason proceeds.

### 2. KISS, governing principle: What is the simplest adequate solution?

Choose the lowest total affected-system complexity that fully meets the admitted need and required quality attributes.
A solution is inadequate if it violates a present constraint, hides a known failure, makes routine change unreasonably risky, or shifts material cost to users or operators.
**Rationale:** Local brevity can increase concepts, dependencies, states, or operational burden.
**Outcome:** Later steps may refine the simplest adequate solution, not add capability or complexity KISS rejected.

### 3. Rule of Three, abstraction gate: Does an abstraction have demonstrated evidence?

Prefer direct duplication for the first and usually second similar case while the shared shape is uncertain.
Introduce an abstraction for a stable shared responsibility shown by repeated cases, or when a present constraint requires shared behavior now.
Three is a heuristic, not a numerical law: a superficially similar third case can disprove an abstraction, while safety, compatibility, or operational constraints can justify one earlier.
**Rationale:** Early generalization guesses at variation and creates costly interfaces.
**Outcome:** Later choices implement only abstractions whose current benefit outweighs added indirection.

### 4. Principle of Least Power, mechanism choice: What is the least capable adequate mechanism?

Use the least powerful language feature, tool, runtime facility, protocol, permission, or automation that fully solves the accepted problem.
Use greater capability only when a present requirement or constraint needs it.
**Rationale:** More power adds possible behavior, states, attack surface, verification burden, and misuse paths.
**Outcome:** Structural choices cannot use it merely because it is fashionable, flexible, or convenient for hypothetical cases.

### 5. Separation of Concerns, structural rule: Where do distinct responsibilities need boundaries?

Separate work when responsibilities have materially different reasons to change, need independent control, or otherwise make the system harder to understand, test, secure, or operate.
Keep tightly related work together when a boundary mainly adds coordination, data movement, indirection, or duplicate configuration.
**Rationale:** Meaningful separation supports reasoning about one concern; artificial separation distributes one job.
**Outcome:** Later assembly respects demonstrated boundaries rather than manufacturing layers or services.

### 6. Composition over Inheritance, structural preference: How should behavior be assembled?

Prefer composition when it keeps behavior explicit, independently selectable, and less coupled than a hierarchy.
Use inheritance when the domain and language support a stable substitutable relationship and it is the simpler adequate structure.
**Rationale:** Inheritance couples descendants to parent behavior and can make variation and change hard to isolate; composition can also create excessive wrapper chains or plumbing.
**Outcome:** Use the simpler relationship that meets the accepted structure, not either technique universally.

### 7. Occam's Razor, tie-breaker: Do multiple adequate designs remain?

When options remain equally adequate after earlier steps, prefer fewer unsupported assumptions and distinct mechanisms.
Do not use this tie-breaker to reject a needed constraint, settle unequal alternatives, or replace earlier analysis.
**Rationale:** Parsimony reduces unproved commitments but does not establish truth or adequacy.
**Outcome:** It makes a clear choice without reopening scope or weakening adequacy.

## Justifying material complexity

Material complexity includes a new abstraction, service, layer, hierarchy, dependency, configuration surface, coordination protocol, permission, public contract, persistent state, deployment concern, cross-team boundary, operational process, or comparably costly mechanism.
Before accepting it, connect it to one present requirement, constraint, or demonstrated burden, then document:

1. **Trigger:** The proposed complexity and specific current cause.
2. **Insufficiency:** The simplest credible alternative and why it fails the need or costs more overall.
3. **Mechanism:** The provided capability and why a less capable mechanism or simpler structure is inadequate.
4. **System cost:** Added or removed concepts, states, dependencies, configuration, coordination, operational work, and maintenance obligations.
5. **Check:** Limit the design to evidence available now; state how the behavior or constraint will be verified and what evidence would justify reconsideration.

This test applies the canonical flow; it is not another gate and cannot override an earlier result.
Complexity is justified by a specific present cause, a considered adequate simpler option, understood cost, and verifiable benefit.
It is unnecessary when its benefit depends on an uncommitted future, vague flexibility, a pattern without a current problem, an arbitrary layer, or a local reduction that increases total burden.

## Constraints, tensions, and uncertainty

The framework does not permit under-engineering.
A present security, safety, legal, compatibility, reliability, performance, accessibility, data-integrity, or operational requirement may justify locally more complex capability, but its scope and total cost must still be minimized.

Apparent conflicts are usually resolved through the fixed sequence:

- YAGNI decides whether the need belongs in current work.
- KISS judges adequacy and total complexity throughout.
- Rule of Three defaults against premature generalization but yields to a demonstrated current constraint.
- Least Power chooses among mechanisms that meet the accepted need.
- Separation of Concerns and composition shape the accepted design without reviving rejected scope or complexity.
- Occam's Razor decides only between still-adequate alternatives.

No principle permits ignoring a proven constraint.
No downstream principle may revive scope YAGNI rejected or complexity KISS rejected.
The sequence is not a one-pass waterfall: mechanism and boundaries may be refined together when new implementation evidence changes total cost, but this must not revive scope or abstractions rejected for lack of evidence.
If evidence is incomplete and the decision is reversible, prefer the smallest reversible implementation and learn from use.
If the decision is difficult to reverse, investigate material uncertainty before committing rather than prebuilding every possible option.

## Supporting concepts

These concepts guide implementation and review within the canonical flow.
They are not stages, gates, tie-breakers, or independent authority, and they MUST NOT reorder the flow, revive YAGNI-rejected scope, justify KISS-rejected complexity, or replace a canonical principle's role.

### Single Responsibility, cohesion rule

Keep responsibilities together when they serve one purpose; separate them when they have materially different reasons to change.
Use it to test coherent ownership and change pressure, not to require one method, file, class, or service per responsibility.
Excessive splitting creates coordination and indirection that KISS and Separation of Concerns reject.
Its role is cohesion within an accepted boundary: Separation of Concerns decides whether a boundary helps; Single Responsibility keeps it focused.

### Principle of Least Astonishment, predictability rule

Prefer behavior, interfaces, names, defaults, and conventions that reasonable users and maintainers can anticipate from context.
Use it between adequate behaviors or to review surprising interface effects.
Do not retain familiar unsafe or incorrect behavior when a present requirement calls for change; make a necessary surprise explicit, local, and well signaled.
Its role is predictable use and maintenance: KISS limits total complexity, while this concept limits avoidable cognitive surprise in an accepted design.

### Law of Demeter, coupling rule

Limit dependence on another component's internal structure; prefer asking a direct collaborator for a meaningful operation over navigating long object or module chains.
Do not add pass-through wrappers, facades, or layers solely for a mechanical reading; they require the same present justification as other complexity.
Its role is protecting representation boundaries: Separation of Concerns creates useful boundaries, and this rule limits how tightly accepted boundaries depend on each other.

### Fail Fast, failure-handling rule

When continued execution cannot meaningfully recover, detect and surface invalid states and violated assumptions as near their source as practical.
Validate required inputs, invariants, and configuration at a boundary where a clear failure prevents delayed, misleading damage.
Do not fail fast when recovery, retry, fallback, partial service, or user safety is required; the failure path must meet applicable reliability and user-impact constraints.
Its role is early, diagnosable failure: KISS avoids hidden states and needless recovery machinery, while Fail Fast decides how to surface an accepted nonrecoverable failure.

## Delivery and review

For every material proposal, a human developer or coding agent MUST state the present evidence, simplest adequate option, and verification method before treating complexity as justified.
A coding agent MUST identify the available repository evidence it used, treat unverified future scenarios as speculation, and make consequential uncertainty explicit rather than inventing a need, constraint, dependency, or API behavior.
Human review validates product intent, domain constraints, and risk acceptance.
A reviewer SHOULD seek the smallest correction that restores the decision flow rather than demand a preferred pattern.

Review:

- What current requirement, constraint, or observed burden requires this change?
- What is the simplest credible option, and why is it inadequate if rejected?
- What concepts, states, dependencies, configuration, coordination, and operational work does this add?
- Is an abstraction based on stable repeated evidence or a present constraint, not a predicted third case?
- Is a more powerful mechanism, new boundary, hierarchy, or wrapper needed now?
- Is the result cohesive, predictable, appropriately decoupled, and clear about unrecoverable failures?
- How will claimed benefit and required behavior be verified?

Reassess decisions when new requirements, constraints, or observed burdens appear.
Refactoring is justified when current evidence shows the existing simple solution is no longer adequate.
Remove accidental complexity when it no longer serves its recorded cause, while preserving still-required behavior or constraints.
