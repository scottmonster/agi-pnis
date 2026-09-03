# Revise

Make an authorized, targeted change to an existing Markdown artifact.

Require `../rules/preservation.md`

## Establish the revision boundary

Read the target and the material needed to interpret the requested change. Identify the exact requested delta, the affected scope, and the material outside that scope that must remain intact. Do not broaden the change merely because another structure would be cleaner.

The existing artifact is the preservation baseline except where the user authorizes a change. Preserve unaffected purpose, meaning, force, authority, scope, conditions, exceptions, dependencies, uncertainty, retrieval needs, verification, and compatibility.

The selected compression level does not expand the authorized revision scope. Do not resynthesize unrelated sections unless the user explicitly expands that scope.

## Propagate the revision

After making the requested change and before validation, reconcile every part of the revised file whose correct meaning or use depends on that change. A targeted revision limits authorization to change unrelated material; it does not permit stale, contradictory, or incomplete dependent material.

Use the applicable [content and materials rules](../rules/content.md) to trace each changed requirement, decision, definition, condition, exception, dependency, or other canonical statement to related content. Update a dependent item only when the authorized change requires it. Do not use propagation as a reason to rewrite independent material or expand the user's requested scope.

Check the revised file from these angles:

- **Meaning and ownership:** Update the canonical definition, claim, rule, decision, or other source of truth, then align material restatements, summaries, labels, and local explanations with it.
- **Force and applicability:** Keep requirements, recommendations, permissions, prohibitions, audience, object, timing, triggers, conditions, exceptions, qualifications, and temporal or version scope consistent with the revision.
- **Relationships and execution:** Update affected dependencies, prerequisites, sequence steps, alternatives, state-to-action mappings, verification, escalation, routing, and cross-references.
- **Consumer access:** Update headings, navigation, links, anchors, tables, lists, examples, rationale, and point-of-use guidance when they would otherwise describe, retrieve, or demonstrate outdated material.
- **Compatibility:** Reconcile affected commands, paths, filenames, identifiers, configuration, schemas, interfaces, exact required wording, and other literals only when the user authorized the corresponding compatibility change.
- **Unresolved dependencies:** If a required dependent update needs unavailable information, a broader decision, or changes outside the authorized file or scope, preserve the evidence, report the inconsistency, and allow the delivery gate to report the unresolved failure.

Do not remove a dependent statement merely to avoid updating it when it remains material. Do not silently resolve a conflict created by the revision. Preserve independent material that does not depend on the authorized change.
