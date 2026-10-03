```

we need to add something in there about progressive context loading... maybe even a few notes about progressive context loading

* The system is currently **harness-agnostic** and must work across any harness.
* Because we cannot guarantee what information any particular harness will make available, requirements should lean heavily on **"when available."**
* Do **not** require data or information unless we can reasonably verify that it will be available across the applicable harnesses.
* Once the system is complete and working, we may introduce **harness-specific requirements** where availability can be guaranteed.
* This principle is contextual and should be applied within reason.
  * For example, when investigating a **"did not follow a rule"** violation, the broken rule and why it was broken should already be known and can reasonably be expected as available context.
* It is **critical** to preserve this distinction: required information must be limited to what we can currently verify will be available for the applicable harness.



essentially, you are saying to completely decouple the failure definitions from the episode. This would make sense because by the time we are even loading episode-record.md (the entry point) we should already know that we have already experienced an episode. which right now consist of either a failure or judgement.

the episode dir would become:
episode:
  - episode-record.md
  - failure-record.md
  - judgement-record.md

episodes is then conforming to the progressive loading because `episode-record.md` defines what is shared between `failure-record.md` and `judgement-record.md`. and then `failure-record.md` and `judgement-record.md` both describe what they need individually.


Agreed. “Layers” suggests three versions of the same content. They are different artifacts with different jobs:

- **Reference:** complete, authoritative definitions.
- **Prevention guidance:** compact rules for implementation.
- **Review protocol:** process and coverage triggers that select applicable prevention guidance and reference material.

The review protocol is not a compressed rule catalog. It is the retrieval and coverage mechanism.


Make it a coverage router:

```
Changed surface or risk
  → mandatory review domains
  → relevant prevention rules / reference entries
  → finding or explicit “reviewed, no violation found”
```

for example
```
Public API or schema change → compatibility, callers, migration, tests
External input or authorization → security and validation
New dependency/build change → reproducibility, supply chain, environment
Agent code change → intent, repository grounding, verification, integration
```
This reduces false negatives because review is driven by what changed, not only by whatever happens to look suspicious.

and then

```
Confirmed standards violation
  → assess related failure patterns as needed
  → assess materiality
  → if material, load episode-record.md and create an FR
```



No review system can guarantee detection through prose alone. Use automated checks where possible, and require the reviewer to state the applicable domains reviewed and any evidence limits.

This captures the model well. One important correction:

For a “did not follow a rule” violation, require the **applicable rule** and **observed departure** when available and necessary to establish the violation.

Do not require knowing **why it was broken**. That is an investigation finding—possibly an inference or unresolved—because a harness may not expose it and the actor may not know reliably.

So:

```text
Required to establish violation:
  applicable rule / expectation
  observed departure

Investigate when available:
  why it happened
  prevention locus
  corrective action
```


```


# Episode Records, Failure Knowledge, and Progressive Context Loading

**Status: Draft design note.**

## 1. Purpose

This note separates the system that records material work episodes from the knowledge used to prevent and review failures.

The separation supports progressive context loading: an agent loads only the information needed for the current task, review question, or confirmed material episode.

## 2. Harness-agnostic evidence requirements

### 2.1 Current boundary

The system is currently harness-agnostic and `MUST` work across any applicable harness.

Requirements `MUST` rely only on information that can reasonably be expected to be available across those harnesses.

Information that may not be available is retained or investigated **when available**. Its absence, restriction, or non-applicability may itself be material context.

The system `MUST NOT` require data merely because that data would improve an investigation. A later harness-specific standard may add requirements when that harness can guarantee their availability.

### 2.2 Violation evidence and investigation

To establish a did-not-follow-a-rule violation, the record needs enough evidence to identify:

- the applicable rule, requirement, constraint, or expectation; and
- the observed departure from it.

Why the departure occurred is not required to establish the violation. It is an investigation finding that may be observed, inferred, hypothesized, unresolved, unavailable, or unsafe to retain.

When available, an investigation may identify the relevant decision context, prevention locus, contributing conditions, candidate corrective actions, and validation evidence.

## 3. Episode-record system

The episode-record system records actual material episodes. It does not define the failure patterns used to discover or classify them.

Its conceptual documents are:

```text
episodes/
  episode-record.md
  failure-record.md
  judgement-record.md
```

`episode-record.md` defines the shared evidence model, materiality boundary, relationships, and routing.

`failure-record.md` defines what is required to record and maintain a material failure episode.

`judgement-record.md` defines what is required to record and maintain a material judgment episode.

`episode-record.schema.json` remains the shared machine-readable representation. It supports these documents but is not an additional conceptual route for ordinary work.

Failure definitions are intentionally outside this system. By the time an agent loads the episode-record system, it has identified a candidate material episode and is deciding whether or how to retain it.

## 4. Guidance artifacts

The failure and standards systems use three different artifacts with different purposes.

### 4.1 Reference

The reference is the complete, authoritative definition set. It defines each standard or failure pattern, its applicability, boundaries, evidence, investigation needs, related patterns, and prevention or response considerations.

### 4.2 Prevention guidance

Prevention guidance contains compact, actionable rules used while planning, implementing, or modifying work.

It is a deliberate compression of the reference, not a complete replacement for it. A prevention rule can point to the relevant reference entries and failure patterns.

### 4.3 Review protocol

The review protocol is a coverage and retrieval mechanism, not a compressed rule catalog. It uses the changed surface, task, and risk to determine which prevention guidance and reference entries the reviewer must examine.

For example:

```text
Public API or schema change
  → compatibility, callers, migration, and tests

External input or authorization
  → security and validation

New dependency or build change
  → reproducibility, supply chain, and environment

Agent code change
  → intent, repository grounding, verification, and integration
```

The protocol should require the reviewer to state the applicable domains reviewed and material evidence limits. Automated checks should cover detectable conditions where practical; prose review alone cannot guarantee detection.

## 5. Progressive context loading

Progressive context loading begins with the smallest sufficient working context and retrieves more information only when the task, changed surface, evidence, or uncertainty establishes its relevance.

### 5.1 Implementation route

```text
Task and applicable prevention guidance
  → reference material only when needed for an unfamiliar rule, ambiguity, exception, or material trade-off
```

### 5.2 Review route

```text
Changed surface or risk
  → review-protocol coverage triggers
  → applicable prevention guidance and reference entries
  → confirmed or rejected findings
  → relevant failure definitions when classification helps
  → materiality assessment
  → episode-record system only for a material episode
```

The review protocol reduces false negatives by requiring coverage based on the work under review, rather than relying only on a reviewer noticing a suspicious pattern. It does not require loading every standard or failure definition for every review.

## 6. Recording route

A standards finding does not automatically create a durable episode record. Routine findings may be corrected without retention.

When a violation is confirmed, assess any relevant failure pattern and then assess materiality.

```text
Confirmed standards violation or detected failure
  → assess related failure patterns when useful
  → assess materiality
  → if material, load episode-record.md
  → route to failure-record.md or judgement-record.md as applicable
```

Failure classification helps explain and prevent a material episode. It does not itself prove cause, fault, or responsibility.
