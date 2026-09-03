# Existing-Artifact Preservation

Apply these rules when transforming or revising an existing artifact.

> **Preserve semantics, not presentation.**
>
> **Recover existing meaning. Do not invent missing meaning.**

During transformation or revision, preserve meaning, force, authority, scope, conditions, exceptions, dependencies, and relationships.

Existing wording, order, headings, formatting, and proximity are evidence of intent, not authority by themselves.

Before changing an existing artifact, recover all material within the operation's authorized boundary:

- Requirements, recommendations, instructions, procedures, constraints, and prohibitions.
- Conditions, exceptions, definitions, decisions, criteria, and dependencies.
- Verification, required routing, authority, and precedence.
- Rationale, examples, and references.

Recover the complete meaning even when it is distributed across sentences, sections, examples, or references.
Preserve every material qualifier, scope, condition, exception, and dependency.

Do not silently change `MUST` into `SHOULD`, a recommendation into a requirement, an option into an obligation, or supporting content into governing content.
Preserve material qualifiers, including timing, priority, reversibility, conditionality, and exceptions.
Preserve explicit normative force markers and labels such as `MUST`, `MUST NOT`, `SHOULD`, `MAY`, `Required`, and `Prohibited` when the source uses them to govern behavior.
Preserve the strength and scope of recommendations. Do not add feasibility qualifiers such as "when possible" or turn an advisory recommendation into an unqualified imperative or requirement.

When the source explicitly defines a normative marker convention, preserve that convention exactly. For example, if the source states that `MUST` and `MUST NOT` identify requirements, every governed requirement and prohibition that uses those markers must retain the same markers. An unqualified imperative such as "Do not" is not an equivalent substitute in that source.

Preserve original requirements, recommendations, instructions, constraints, conditions, exceptions, decisions, definitions, authority, scope, dependencies, relationships, uncertainty, disagreement, and unresolved ambiguity.
Reconstruct recovered meaning rather than merely paraphrasing the source.

Extract actionable content buried in prose, notes, summaries, parentheticals, or examples.
Reconnect a detached condition, exception, qualification, rationale, verification, or dependency to what it affects.
Do not infer a material relationship from proximity alone.
Do not treat inferred meaning as source authority. Use supported inference to organize content only when it does not broaden behavior, resolve an unresolved ambiguity, or conceal uncertainty.

For every retained relative Markdown link, filename, path, command, identifier, configuration key, and frontmatter value, preserve the source literal exactly unless the user explicitly authorizes a corresponding compatibility change.
Do not normalize, correct, or repair a literal because a supplied sibling has a different or more plausible name. If a source literal is broken, stale, or inconsistent with a supplied sibling, retain it and report the unresolved issue. Repair it only when the user authorizes the repair and any necessary dependent changes.
Validate that a rewritten relative route has the same literal target as its source route. If the source route resolved, also validate that the unchanged target resolves from the rewritten output.

When a named term governs a later decision, retain a concise local definition and consequence or a valid required route to its canonical definition.
When distinct consequential states require different actions, retain a compact state-to-action mapping when readers would otherwise need to infer a branch.
Keep each material control statement intact: its trigger, qualifiers and exceptions, force, action, and required alternative.
When the source requires a mechanism at a point of use, require its use there. Naming or defining it is not enough.

When consolidating duplicates, retain the strongest complete expression and every distinct material scope, condition, exception, authority, or emphasis.
When combining source rules, preserve each rule's scope, force, conditions, exceptions, dependencies, and outcomes. If that cannot be shown, keep the rules separate.
When statements conflict, apply explicit precedence when available.
Then determine whether scope, conditions, temporal or version differences, or a clear general-to-specific relationship resolves the apparent conflict.
Otherwise, preserve or surface the conflict.

Examples may contain material meaning, but do not generalize an example into a rule unless the source establishes that generalization.
Retain the example when its meaning cannot safely be generalized.
Preserve ambiguity when more than one material interpretation remains plausible.

## Validation

Before delivery, verify all applicable checks:

- **Preservation:** No material meaning, force, scope, authority, condition, exception, dependency, decision, relationship, uncertainty, or ambiguity was silently removed or changed.
- **Coverage trace:** Every material source statement has an equivalent target representation or a justified removal. A compressed target must not hide requirements, conditions, exceptions, dependencies, decisions, or verification criteria that must remain separately usable.
- **Decision equivalence:** For consequential transformations, test ordinary, boundary, exception, and conflict cases. The target must support materially equivalent correct decisions for its intended consumers.
- **Transformation safeguards:** Material qualifiers, recommendation strength, temporal claim form, and source-defined force markers remain intact; source literals were not silently repaired or normalized; every source-relative route retains the same target and, when it originally resolved, still resolves; later decision terms retain a local definition or valid route; consequential control statements retain their trigger, qualifiers, force, action, and required alternatives; source-required mechanisms remain required in their actual point of use.

## Corrective Action

These lists capture reusable source-to-derived mistake patterns that need special attention during revision, transformation, and comparison audit.
They reinforce the governing rules in this file but do not create new requirements or change audit outcomes.

Before delivery, check every listed pattern that applies to the work.

### Failures

No known failure patterns.

### Warnings

No known warning patterns.
