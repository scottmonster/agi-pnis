# Material Episode Records: Unification Decisions

**Status: Draft design record; non-authoritative.**

This document records the current design decisions for unifying material judgment, outcome, and failure evidence. It creates no requirement or binding direction unless an authoritative source adopts it.

This is temporary design documentation, not a long-lived operational entry point.

## 1. Purpose

The system is intended to preserve durable, structured evidence about meaningful work across repositories, especially work involving agents. It supports review now and later analysis of human judgment, agent judgment, outcomes, limitations, and alignment.

The system remains harness-agnostic. It does not require a particular agent runtime, telemetry protocol, trace viewer, storage product, or complete execution log.

## 2. Unifying concept

### 2.1 Material work episode

A material work episode is the unifying unit. It is a bounded, meaningful attempt, event, or sequence of work that can be reviewed later in its contemporaneous context.

A material episode may include:

- an intended outcome and applicable constraints;
- available evidence and execution context;
- an observed outcome and evaluation;
- zero or more failure or deviation classifications;
- zero or more material judgments; and
- later review, remediation, correction, implementation, validation, or outcome evidence.

### 2.2 Judgment is not a failure

A judgment is an exercise of discretion. It may be sound, unsound, later disproved, or unrelated to a later failure.

A failure may arise without a material judgment, such as from a missing capability, environment condition, context limit, external dependency, or inadequate evaluation.

The system preserves material successful episodes and correctly handled uncertainty as well as failures. They provide the comparison needed to understand limitations and alignment.

## 3. Record model

### 3.1 Material Episode Record

The umbrella record model is a Material Episode Record (MER). It records the material episode and the available evidence needed to understand it.

An MER may represent:

- a judgment episode;
- a deviation or failure episode;
- an outcome or review episode; or
- a material success or comparison episode.

### 3.2 Material Judgment Record

A Material Judgment Record (MJR) is a specialized MER for a completed, settled, non-obvious exercise of discretion that governs future work within an explicit scope.

Every MJR is an MER. An MER is not necessarily an MJR.

An MJR retains the additional information that only a governing judgment requires, including the judgment required, authority, settlement, scope, precedential force, rationale, and resulting direction.

### 3.3 Judgment Follow-up Record

A Judgment Follow-up Record (JFR) remains the record for a later material implementation, validation, outcome, error, correction, or review that directly concerns an MJR.

An MER may link to zero or more MJR or JFR records when material judgment is involved. A material failure does not require an MJR or JFR when no governing judgment was made.

## 4. Evidence model

### 4.1 Available evidence

An MER may preserve available evidence about:

- the task, request, issue, or intended outcome;
- constraints, authority, policy, and established direction;
- agent identity, instructions, tools, and runtime context;
- relevant artifacts, commands, tool results, changes, tests, and external state;
- observed outcomes, user feedback, review, and evaluation;
- failure or deviation classifications; and
- diagnostic hypotheses, replay, comparison, remediation, and later results.

The MER does not require complete evidence. It does not require raw traces, full transcripts, tool logs, private chain-of-thought, or any harness-specific capture format.

### 4.2 Evidence availability

For a material evidence type, an MER distinguishes one of these states when the distinction affects interpretation:

- linked and available;
- unavailable;
- not collected;
- restricted or unsafe to retain; or
- not applicable.

Evidence absence is not silently filled with inference. The record preserves a safe reference, classification, or limitation when retaining the underlying content is unsafe or inappropriate.

### 4.3 Claim status

The record distinguishes:

- an observation;
- an evaluation;
- an inference;
- a hypothesis; and
- a tested finding.

An observed sequence, an evaluator result, or a repeated pattern does not by itself establish root cause, fault, or a universal rule.

## 5. Failure classification

### 5.1 Classification role

Failure classifications are analytical vocabulary, not record types. They help describe candidate conditions, limitations, and prevention opportunities within an MER.

Several classifications may apply to one episode. A classification identifies a plausible prevention locus or analytical pattern; it does not assign fault or establish causality.

### 5.2 Taxonomy roles

[failure_modes.md](../failure_modes.md) provides cross-harness analytical modes, such as judgment, context, planning, verification, safety, environment, and measurement.

[failure_index.md](../failure_index.md) provides the compressed taxonomy of coding-agent prevention families.

[large_list.md](../large_list.md) provides the detailed coding-pattern catalogue, evidence labels, and supporting context.

The failure index and detailed catalogue are coding-agent vocabulary profiles. They do not limit MERs to coding work or imply that all material episodes require a failure classification.

### 5.3 Outcome and evaluation

An outcome or evaluation establishes what was observed or assessed. It is distinct from the explanation of why it occurred.

The record preserves the intended outcome or criterion, observed outcome, impact, evaluation basis, and known limitations when they are available and material.

## 6. Materiality boundary

An MER is created only when preserving the episode can materially improve later review, learning, or future direction.

Examples include:

- a meaningful deviation or safety concern;
- a recurring or novel limitation;
- a disagreement between human and agent judgment;
- a material success that establishes a useful comparison case; or
- an episode that leads to a judgment, remediation, or explicit guidance.

Routine tool errors, ordinary failed tests, and exhaustive execution traces are not durable MERs by themselves. They may be linked as evidence when material to a retained episode.

## 7. Target document structure

The target has three documents with distinct roles.

### 7.1 episode_record.md

This becomes the main entry point for the Material Episode Record system. It defines:

- what a material episode is and when to retain one;
- common episode identity, scope, actors, intended outcome, observed outcome, and evidence;
- evidence captured when available, including explicit absence or retention limitations;
- claim status: observation, evaluation, inference, hypothesis, and tested finding;
- episode specializations:
  - Material Judgment Record (MJR);
  - material deviation or failure episode;
  - outcome or review episode; and
  - material success or comparison episode;
- relationships, later follow-up, remediation, and corpus use; and
- links to the specialized MJR/JFR standard and Failure Catalogue.

A failure is not a separate record type for every catalogue item. An episode records an observed deviation and then optionally classifies it using the Failure Catalogue.

### 7.2 judgement_record.md

This remains the specialized standard for the MJR and JFR record types. It defines the additional structure required for governing material judgment:

- settlement and authority;
- governing scope and precedent;
- judgment required, rationale, and direction; and
- immutability, corrections, and judgment-specific follow-up.

It is the detailed standard for one specialized MER type, rather than the system's main entry point.

### 7.3 failure_catalogue.md

This becomes the classification reference. It merges the current failure-mode, failure-index, and detailed-catalogue material:

- cross-harness analytical modes, including judgment, context, planning, verification, safety, environment, and measurement;
- prevention loci: agent-level, tool-level, shared, task/external, and unresolved; and
- detailed coding-agent patterns with evidence labels.

The three documents answer distinct questions:

| Document | Question |
| --- | --- |
| episode_record.md | What episode evidence is retained, and how do records relate? |
| judgement_record.md | How is a governing material judgment recorded? |
| failure_catalogue.md | How is a deviation or limitation classified when evidence supports classification? |

## 8. Decisions not yet made

The following require later design work:

- the minimum frontmatter and body structure for an MER;
- the record and relationship model for later events concerning an MER that has no linked MJR;
- stable identifiers, locations, indexes, and migration for the consolidated records;
- the exact threshold for creating a stand-alone failure or success episode record;
- which evidence-availability states belong in structured fields versus narrative; and
- central-corpus ingestion and normalization details.

These unresolved details do not change the decisions in sections 2 through 7.


- **Minimum MER frontmatter and body structure:** Defines the smallest consistent set of machine-readable fields and narrative sections for every Material Episode Record. It makes records comparable across repositories without forcing irrelevant detail.

- **Later events for an MER without an MJR:** Defines how to append or link later validation, outcomes, corrections, remediation, or review when no governing judgment exists. This preserves history without incorrectly creating an MJR.

- **Stable identifiers, locations, indexes, and migration:** Defines how records are uniquely identified, where they live, how people discover them, and how older records remain usable after consolidation. It protects cross-repository analysis and prevents broken references.

- **Threshold for stand-alone failure or success episodes:** Defines which outcomes are material enough to retain as their own MER. This prevents the system from becoming a log of every test result while preserving episodes that support learning or comparison.

- **Structured versus narrative evidence availability:** Decides which absence states need standardized fields and which can remain explanatory prose. This balances reliable querying with flexibility for unusual or sensitive situations.

- **Central-corpus ingestion and normalization:** Defines how repository records are copied, indexed, and made comparable in the cross-project corpus without replacing or rewriting the source records. It preserves original evidence while enabling later analysis.








