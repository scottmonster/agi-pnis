Develop a practical engineering-principles framework for human developers and coding agents that prevents unnecessary complexity and over-engineering.

Use `standards/principles/concept.md` as the authoritative starting point. It defines the canonical principles, their scope, roles, and intended decision sequence, as well as supporting concepts that complement the framework without participating in the canonical decision sequence. Preserve those decisions and develop them into an operational framework rather than redesigning, substituting, or reordering them.

Treat the defined decision sequence of canonical principles as fixed and authoritative. Distinguish a principle's role from its position in that sequence. In particular, KISS may serve as the governing principle throughout the framework while YAGNI remains the first decision gate. Do not infer execution order merely from conceptual importance.

The supporting concepts defined in `concept.md` are intentionally outside the canonical decision sequence. Treat them as complementary design and implementation guidance:

* **Single Responsibility** - cohesion rule.
* **Principle of Least Astonishment** - predictability rule.
* **Law of Demeter** - coupling rule.
* **Fail Fast** - failure-handling rule.

Preserve these roles. Research and operationalize the supporting concepts where they materially improve application of the framework, but do not turn them into additional decision stages, gates, tie-breakers, or sources of authority independent of the canonical principles.

Preserve the framework's central idea:

> Complexity is justified only by demonstrated requirements or constraints. Do not introduce complexity that is unnecessary, speculative, premature, or insufficiently justified.


Research the established meaning, appropriate use, limitations, and interactions of both the canonical principles and the supporting concepts. Follow `.agents/gov/guides/research-guide.md`. Use credible sources for material claims and distinguish established evidence from derived recommendations.

Use the research to clarify, support, qualify, and operationalize the existing framework. Do not add, remove, substitute, or reorder the canonical principles. Preserve the supporting concepts defined in `concept.md`, their supporting status, and their stated roles. Do not promote a supporting concept into the canonical sequence or use one to create a competing decision hierarchy.

If research identifies a material tension, limitation, or apparent contradiction, explain how it affects application of the framework without silently changing the defined principles, supporting concepts, roles, or decision sequence.

Turn the concept into a clear, usable framework that:

1. Defines each canonical principle and its role in the decision sequence.
2. Presents one canonical decision flow showing when and how each canonical principle is applied.
3. Explains how each step constrains the decisions available to later steps.
4. Defines how apparent conflicts between canonical principles should be resolved.
5. States when additional complexity, abstraction, separation, or more capable mechanisms are justified.
6. Provides observable criteria for distinguishing justified complexity from unnecessary complexity.
7. Defines material complexity broadly enough to include new abstractions, services, layers, hierarchies, dependencies, configuration surfaces, coordination protocols, permissions, public contracts, persistent state, deployment concerns, cross-team boundaries, and operational processes where they materially add cost or obligation. Requires every material addition to be connected to a present requirement, constraint, or demonstrated existing burden.
8. Provides one labelled, practical justification test for material complexity. It MUST require: **Trigger**, the specific present need; **Insufficiency**, why the simplest credible alternative fails; **Mechanism**, what capability the addition provides and why a less capable mechanism or simpler structure is inadequate; **System cost**, the affected-system costs added or removed; and **Check**, how the claim will be verified and what evidence would justify reconsideration. Make clear that this test applies the canonical flow and is not an additional gate or source of authority.
9. Evaluates simplicity in terms of total affected-system complexity, including concepts, states, dependencies, indirection, configuration, coordination, operational burden, and maintenance cost, rather than line count, file count, or local brevity alone.
10. Treats heuristics such as the Rule of Three as decision aids rather than mechanical numerical laws, while explaining when demonstrated constraints justify departing from the default.
11. Provides practical decision and code-review guidance usable by both humans and coding agents. Require coding agents to identify the available repository evidence they used, treat unverified future scenarios as speculation, and make consequential uncertainty explicit rather than inventing needs, constraints, dependencies, or API behavior. State that human review remains responsible for validating product intent, domain constraints, and risk acceptance.
12. Uses normative language only where a rule can be stated and evaluated clearly. Define **default**, **heuristic**, **preference**, and **tie-breaker**, and use those labels consistently for non-binding guidance. State that the principles are one decision sequence, not a scorecard: a later principle cannot outvote an earlier rejected gate.
13. Identifies material limitations and exceptions without weakening the framework into vague advice.
14. Explains the rationale and intended outcome behind each canonical principle and major rule so future developers and coding agents can preserve the underlying intent when applying the framework to new situations.
15. Defines each supporting concept, its role, appropriate application, limitations, and relationship to the canonical principles.
16. Keeps supporting concepts subordinate to the canonical decision flow. They may inform implementation and review decisions but MUST NOT introduce new gates, reorder the sequence, revive scope rejected by YAGNI, justify complexity rejected by KISS, or replace the role of an existing canonical principle.
17. Explains material overlap between supporting concepts and canonical principles without duplicating rules unnecessarily. Where concepts overlap, identify the distinct contribution of the supporting concept.
18. Allows implementation details, mechanism choices, and boundaries to be refined iteratively when new evidence changes their total cost. This refinement MUST NOT revive scope rejected by YAGNI or abstractions rejected for lack of evidence. Describe this as refinement within the fixed sequence, not permission to reorder or bypass it.

Avoid unnecessary duplication within the document. Do not restate the same rule or decision sequence in multiple sections merely to present it as an operating rule, procedure, reviewer rule, agent rule, rationale, or supporting concept. Prefer one authoritative statement and reference or derive related guidance from it when necessary.

Keep historical background, philosophical discussion, and principle-by-principle exposition only where they materially improve correct application of the framework.

The framework itself should follow its own simplicity principles. Do not create unnecessary taxonomies, parallel rule sets, repeated decision models, procedural layers, or distinctions that do not materially improve understanding or application.

The completed framework must be self-contained. Extract and incorporate all material meaning, limitations, rationale, and application guidance needed from the research so that external sources are not required to understand or apply the framework. Research sources are evidence used to develop and verify the framework, not runtime dependencies for humans or coding agents applying it. Do not include external links in the completed operational document unless the concept or research guide explicitly requires them.


Use the /md skill to Write the completed document to:

`standards/principles/principles.md`

The document must preserve both the rules and the reasoning behind them. Explain why the framework prefers these decisions, the failure modes it is intended to prevent, and the outcome each canonical principle and supporting concept is meant to produce. The rationale must be sufficient for future developers and coding agents to apply the framework's intent in situations not explicitly covered by the document.

The result should be concise, self-contained, practical, consistently applicable, and resistant to both over-engineering and rigid under-engineering.
