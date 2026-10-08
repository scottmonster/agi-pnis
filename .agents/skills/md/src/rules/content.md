# Content and Materials

## Governing Principles

- **Reliable communication:** Optimize for correct interpretation and use by an agent or human.
- **Explicit material meaning:** State important relationships, authority, scope, conditions, exceptions, and uncertainty when the source establishes them.
- **Adaptive content depth:** Use the minimum depth that fully serves the artifact, then add detail only when it materially improves correct use.
- **Canonical ownership:** Give each material concept one authoritative owner. 
- **Force from meaning:** Determine normative force from explicit language and semantic function, not formatting, capitalization, or visual prominence alone.

Formatting, capitalization, or visual prominence alone do not establish authority.


## Canonical Ownership

Each materially significant concept should have one authoritative location that completely defines it. That location is its canonical owner.

Other content may apply, summarize, route to, reference, validate, or selectively restate the concept when this materially improves local comprehension, retrieval, safety, navigation, interpretation, or execution. Secondary content does not become an alternative definition.

Use repetition only when it has material value.
A secondary statement must preserve the canonical meaning, scope, authority, force, conditions, exceptions, constraints, qualifications, and relationships.
It must not redefine, broaden, narrow, weaken, strengthen, or conflict with the canonical definition.

If secondary content diverges, the canonical definition controls and the secondary content must be corrected.

## Plain Language

Use the simplest direct and concrete language that preserves required precision and material meaning.

- Prefer familiar words, specific verbs, clear actors and actions, and straightforward sentence structures over unnecessary jargon, formality, abstraction, or complexity.
- Describe observable behavior, requirements, effects, or changes before abstract characterization or implementation terminology, unless the abstraction is necessary to understand the subject.

## Content Selection and Depth

Prefer the shortest expression that preserves material meaning and intended usability.
Do not sacrifice natural paragraph flow, semantic relationships, readability, or appropriate structure merely to reduce tokens.

Include content when it materially affects understanding, interpretation, decisions, execution, verification, or correct application.
Exclude content that does not contribute to those purposes.

Keep immediately necessary information inline.
Prefer a reliable reference when material is substantial but conditionally needed, already authoritative elsewhere, independently reusable, or disruptive to the primary flow.
Do not put critical governing or immediately actionable content behind a reference solely to shorten the document.

Include rationale, examples, definitions, background, references, and context only when they materially improve governing or actionable content.
Keep supporting detail subordinate to the content it supports.

Retain all material assumptions, dependencies, conditions, exceptions, priorities, constraints, and qualifiers.
Remove repetition that adds no material value.
Use examples when they clarify ambiguity, demonstrate a non-obvious application, show necessary syntax or output, or prevent a likely misinterpretation.

### Adaptive Content Depth

Use the minimum depth that completely and reliably serves the artifact.
Increase depth only when it materially improves correct interpretation, instruction following, decision-making, execution, verification, handling of constraints, conditions, exceptions, dependencies, uncertainty, tradeoffs, or materially different applications.

The length or detail of source material does not determine the appropriate length or detail of the output.
Apply adaptive depth independently to the document, each section, subsection, paragraph, explanation, and example.

Do not add depth merely because more source material, research, analysis, examples, or possible edge cases exist.
Do not reduce depth by removing meaning, authority, normative force, scope, conditions, exceptions, constraints, dependencies, material uncertainty, or information required for execution or verification.

Stop adding detail when it has little reasonable prospect of improving use.

## Semantic Clarity

Keep these distinctions clear when they matter:

- A requirement, recommendation, prohibition, or permission must state its force, scope, and applicable conditions.
- An instruction must state the action and material targets, inputs, conditions, dependencies, outcomes, or verification.
- A condition must identify what it governs. An exception must identify the rule it changes and its trigger. Keep constraints visible to the work they bound.
- A sequence must not imply required order among independent actions. Verification must identify what to check and, when needed, the acceptable result.
- A definition must state meaning directly and use the term consistently. A decision must remain distinct from a proposal, recommendation, or unresolved question.
- A required route must identify its destination and purpose. Keep it distinct from an optional reference.
- Rationale and examples may clarify content, but do not create unstated requirements or override governing content. Label an example when confusion is likely.
- When research-derived content matters, distinguish source evidence from assessment, conclusion, and prediction. Preserve material provenance, limitations, qualifications, disagreement, uncertainty, assumptions, and time horizon.

Use the same term for the same concept.
Combine closely related statements only when their relationship and force remain clear.
Otherwise, separate them.

## Normative Force

Normative force comes from explicit meaning and semantic function, not capitalization alone.
Direct imperatives and explicit prohibitions can be normative even without uppercase keywords.

Use standardized keywords when an exact distinction in force matters:

- `MUST`: required behavior.
- `MUST NOT`: prohibited behavior.
- `SHOULD`: recommended behavior.
- `SHOULD NOT`: discouraged behavior.
- `MAY`: permission or optional behavior.

Do not rely on `can`, `will`, `normally`, visual emphasis, capitalization, or placement when force would otherwise be ambiguous.

## Authority 

Governing content includes requirements, rules, constraints, established decisions, applicable policies, and explicit instructions.
Rationale, examples, background, summaries, references, and commentary are supporting content.
Supporting content does not override governing content unless explicit authority establishes that result.

Preserve stated authority and precedence.
Do not infer hierarchy because a statement appears later, looks more prominent, is repeated, is longer, or is easier to apply.
A more specific statement may refine a compatible general statement within its stated scope, but specificity alone does not resolve a genuine contradiction.
Formatting communicates structure, not authority, unless the governing system explicitly says otherwise.

## Validation

Before delivery, verify all applicable checks:

- **No invention:** No unsupported requirement, decision, authority, constraint, exception, relationship, or detail was introduced.
- **Completeness and depth:** The artifact contains what is necessary for understanding, decisions, execution, verification, and correct application, without retaining detail that has no material value.
- **Semantic clarity:** Governing, supporting, procedural, factual, explanatory, and illustrative content remain distinguishable where the distinction matters. Conditions, exceptions, constraints, dependencies, and verification remain connected to the correct content.
- **Authority and ownership:** Governing content remains distinct from support, conflicts and precedence were not silently resolved, and each material concept has a canonical owner.
- **Agent usability:** A consuming agent can determine what applies, what is required or optional, relevant conditions and exceptions, dependencies, actions, decisions, supporting content, and completion criteria without unnecessary reconstruction.

A conforming artifact is complete for its purpose without being exhaustive by default.

## Corrective Action

These lists capture reusable mistake patterns that need special attention during creation, revision, transformation, and audit.
They reinforce the governing rules in this file but do not create new requirements or change audit outcomes.

Before delivery, check every listed pattern that applies to the work.

### Failures

No known failure patterns.

### Warnings

No known warning patterns.
