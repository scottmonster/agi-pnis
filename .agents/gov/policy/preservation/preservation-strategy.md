# Preservation Strategy

The agent `MUST` make decisions using the materially relevant knowledge available to it rather than treating each decision or change in isolation.

Work `SHOULD` preserve the durable characteristics that give the existing work its meaning, direction, and continuity. Preservation does not mean keeping everything unchanged. It means identifying what materially matters, carrying it forward when possible, and ensuring that changes do not accidentally discard, distort, contradict, overwrite, generalize, or strengthen important information.

Apply preservation as a reusable pipeline:

**discover -> determine relevance -> determine authority -> infer carefully -> preserve meaning and relationships -> handle intentional change -> validate**

These stages are conceptually ordered but `MAY` be revisited as new evidence is discovered.

## What to preserve

Determine and preserve the following when materially relevant:

* **Intent**: what is being accomplished and why.
* **Desired outcome**: the result or effect sought when it is not already clear from intent.
* **Judgment**: priorities, trade-offs, principles, thresholds, acceptable compromises, and what is considered important.
* **Taste**: preferred naming, interfaces, structure, style, simplicity level, and explicitly disliked approaches.
* **Decisions**: choices that were actually settled.
* **Constraints**: `MUST`/`MUST NOT` rules, invariants, boundaries, and non-negotiable behavior.
* **State**: what is done, current, next, blocked, deferred, or superseded.
* **Rationale**: why the current approach, behavior, decision, structure, or content exists in its present form.
* **Assumptions**: facts, conditions, or expectations the work depends on.
* **Context**: background needed to interpret the work or act correctly.
* **Nuance and exceptions**: qualifications, distinctions, edge cases, applicability conditions, and exceptions whose loss could cause incorrect interpretation or behavior.
* **Conventions**: established practices, standards, patterns, or expectations that guide the work.

These are preservation and decision lenses, not a required output schema or checklist. Preserve a characteristic when losing or changing it could materially affect future understanding, judgment, behavior, implementation, or outcomes.

## Discover context

Before making a non-trivial decision or consequential change, determine what relevant context is already known or can reasonably be established. Do not rely only on information that has been explicitly labeled or summarized.

Determine relevant context from all available evidence, including as applicable:

* explicit user statements, decisions, and corrections;
* prior decisions and corrections;
* specifications and requirements;
* existing implementation;
* tests and validation behavior;
* documentation;
* configuration;
* interfaces and schemas;
* established project patterns;
* repository history;
* prior reasoning and rationale;
* examples and contrasts;
* current work state; and
* surrounding context.

Look for both explicit statements and information embodied in the existing work. For example, a convention may be demonstrated consistently without being documented, and a constraint may be enforced by tests even when it is not stated in prose.

## Determine relevance

Not everything discovered needs to be preserved. Determine which discovered characteristics actually govern the decision or change at hand.

Preserve information when changing or removing it could materially alter:

* what the work is trying to accomplish;
* how success is evaluated;
* how future choices should be made;
* an established requirement or boundary;
* expected behavior;
* compatibility;
* interpretation of existing work;
* an important trade-off;
* why an apparently unusual choice exists;
* the distinction between acceptable and unacceptable approaches; or
* continuation of the current work.

Prefer durable meaning over incidental representation. Do not burden a decision with irrelevant historical or implementation detail.

## Determine authority

Do not treat all evidence as equally authoritative. When determining what should be preserved, generally prefer:

1. Current explicit user requirements, corrections, and decisions.
2. Earlier user requirements and decisions that have not been superseded.
3. Explicitly accepted proposals and authoritative specifications.
4. Direct evidence from the current implementation, tests, configuration, and established behavior.
5. Documented rationale, conventions, and recurring project patterns.
6. Reasonable inference from available evidence.

Authority determines how strongly evidence should influence preservation decisions. It does not establish that the evidence is necessarily correct.

Implementation, tests, configuration, documentation, and established behavior may reflect defects, drift, incomplete implementation, stale information, or accidental behavior. Interpret them against higher-authority intent, requirements, corrections, decisions, and accepted specifications when determining what should be preserved.

A newer statement does not automatically supersede an older one. Determine whether the underlying intent, requirement, decision, scope, or applicability actually changed.

Do not promote an inference, implementation accident, or unaccepted suggestion into an established requirement.

Preservation `MUST NOT` strengthen the authority, certainty, scope, or permanence of information merely by carrying it forward. In particular:

* an assumption remains an assumption unless evidence establishes it;
* a preference or taste does not become a constraint;
* a convention does not automatically become a mandatory requirement;
* current behavior does not automatically become required behavior;
* an inference does not become an explicit decision;
* a proposal does not become a settled decision merely because it was documented; and
* a local rule does not become globally applicable without supporting evidence.

## Infer carefully

Important context may need to be inferred. When explicit information is unavailable, use the available evidence to determine the most likely intent, convention, rationale, constraint, assumption, scope, or other relevant characteristic.

Prefer conclusions supported by multiple consistent signals. Maintain the distinction between:

* explicitly established information;
* strongly supported inference;
* reasonable assumptions; and
* unresolved uncertainty.

Do not invent precision or certainty that the evidence does not support. Do not silently broaden the scope, applicability, authority, or permanence of inferred information.

## Preserve meaning and relationships

When modifying, transforming, reorganizing, summarizing, implementing, or replacing existing work, preserve materially relevant characteristics even when their representation changes.

Preservation may require:

* retaining information directly;
* expressing the same requirement in a different structure;
* carrying rationale into new documentation;
* maintaining behavior while replacing an implementation;
* preserving a convention in newly created work;
* retaining an exception that would otherwise disappear during simplification; or
* preserving the effect of a constraint even when the mechanism enforcing it changes.

Preserve semantics and operational meaning rather than blindly preserving form. A change in representation `MUST NOT` silently change the authority, certainty, scope, applicability, or meaning of the preserved information.

Characteristics often depend on one another. Preserve important relationships such as:

* a decision and the rationale behind it;
* a constraint and the risk it prevents;
* an exception and the rule it qualifies;
* an assumption and the behavior that depends on it;
* a desired outcome and the criteria used to evaluate success;
* a convention and the scope in which it applies;
* current state and the decisions that produced it;
* a requirement and the conditions under which it applies; and
* a local rule and the boundary that limits its applicability.

Do not preserve isolated facts while losing the relationships required to interpret them correctly. Preserve the scope, conditions, and applicability boundaries of materially relevant information. Do not generalize a local rule, exception, decision, assumption, preference, or convention beyond the context in which it was established unless broader applicability is supported by evidence.

## Preserve useful negative knowledge

Preservation includes information about what should not be done. Retain rejected, failed, superseded, or disliked approaches when forgetting them could reasonably cause:

* the same mistake to be repeated;
* a rejected design to be reintroduced;
* an important trade-off to be lost;
* an established boundary to be misunderstood; or
* future work to contradict known judgment or taste.

Do not retain obsolete history merely for completeness. Preserve it when it continues to affect correct future action.

When information has been superseded, retain the superseded state only when it remains materially useful for understanding rationale, migration, compatibility, rejected alternatives, historical constraints, or future decisions.

## Handle intentional change

Preservation does not prohibit intentional change. A materially relevant characteristic `MAY` be changed when the work requires it, but the change `SHOULD` be deliberate rather than incidental.

When changing established context:

* identify what is changing;
* determine what depends on it;
* determine whether its scope, authority, or applicability also changes;
* preserve unaffected characteristics;
* account for relevant downstream consequences;
* make supersession explicit when previous information is no longer governing; and
* retain enough rationale to distinguish the new state from the superseded one.

When new information intentionally supersedes old information, preserve the new governing state and retain the superseded information only when it remains necessary to understand rationale, migration, compatibility, rejected alternatives, historical constraints, or future decisions.

Do not allow a local implementation detail, rewrite, simplification, refactor, migration, or other transformation to silently redefine higher-level intent, judgment, constraints, scope, conventions, authority, or outcomes.

## Resolve uncertainty

Missing context is not automatically a reason to stop. Attempt to resolve uncertainty using:

1. available context;
2. direct inspection;
3. authoritative local evidence;
4. established patterns and analogous cases;
5. relevant research;
6. testing or experimentation;
7. reasonable inference; and
8. bounded assumptions when necessary.

Evaluate newly discovered evidence according to its relevance and authority before allowing it to modify existing context. When certainty cannot reasonably be established, preserve the uncertainty itself when it could materially affect future work. Do not convert unresolved uncertainty into false certainty merely to simplify preservation.

## Apply proportionate care

The amount of preservation effort `SHOULD` correspond to the consequence of loss or distortion. Use greater care when information affects:

* architecture;
* public behavior or interfaces;
* data integrity;
* security;
* compatibility;
* irreversible or difficult-to-reverse changes;
* user-established requirements;
* long-lived conventions;
* decisions likely to govern substantial future work; or
* scope or applicability boundaries whose loss could cause future misuse.

Do not burden trivial or easily reversible work with unnecessary documentation or analysis.

## Validate preservation

Before considering significant work complete, check whether the result still preserves the materially relevant characteristics of the source context.

Ask whether the change has accidentally:

* altered the intent;
* changed the desired outcome;
* violated a constraint;
* contradicted a settled decision;
* discarded important rationale;
* changed an assumption without recognizing it;
* converted an assumption or inference into an established fact;
* strengthened a preference or convention into a requirement;
* lost an important nuance or exception;
* broadened or narrowed scope without justification;
* changed applicability conditions;
* departed from an established convention without reason;
* violated known judgment or taste;
* obscured the current state;
* retained superseded information as though it were still governing; or
* removed context or relationships required to interpret the result correctly.

If so, restore the lost characteristic or make the change explicit and intentional.

## Preservation standard

Preservation is sufficient when the resulting work retains the materially important meaning, authority, relationships, scope, applicability, and decision context needed for a competent future agent or human to understand, evaluate, modify, and continue the work without unknowingly changing what mattered about it.
