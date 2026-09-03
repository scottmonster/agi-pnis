# Structure and Format

**USER STATEMENT:**

> Markdown should optimize for fast comprehension, reliable instruction-following, and easy scanning.
>
> Keep content concise, structured, and semantically explicit.
>
> Make requirements, constraints, conditions, exceptions, procedures, and supporting information easy to distinguish.
>
> Prefer short sentences, focused paragraphs, headings, and lists.
> Use structure to make relationships and priorities obvious.
>
> Avoid long, dense prose.
>
> Do not bury important instructions, conditions, dependencies, or exceptions inside paragraphs.
>
> Rules, constraints, priorities, and exceptions should be immediately identifiable to improve instruction adherence and compliance.

This standard applies primarily to `AGENTS.md`, `SKILL.md`, standards, policies, specifications, guides, plans, task documents, reference documents, READMEs, and overview documents.
A file-type profile may specialize these requirements, but does not replace them.

A consuming agent or human should be able to determine the document's purpose, authoritative information, applicable behavior, conditions, exceptions, dependencies, supporting content, and completion criteria without unnecessary reconstruction.

Structure and format MUST not change material meaning, force, scope, authority, conditions, exceptions, dependencies, compatibility, or required access.

## Governing Principles

- **Retrieval-oriented style:** Make material content easy to locate, including when sections are retrieved independently.
- **Purpose-driven structure:** Choose a structure that exposes the content's relationships. Do not impose a universal document shape or fixed section length.

## Composition

Group content by shared purpose, scope, subject, or dependency, not merely because it appeared together in the source.
Order it by the relationships needed for correct use, including authority, preconditions, dependency, sequence, scope, priority, and comprehension.

Keep related content connected:

- Put conditions with what they condition and exceptions with the rule they modify.
- Keep constraints visible to bounded work and dependencies before or with dependent content.
- Associate verification with what it verifies.
- Place necessary rationale and examples near the content they support.
- Present governing or necessary context before dependent content when practical.

Use deeper hierarchy only when it improves navigation, conditional access, comprehension, or independent use.
Do not require an agent to read explanatory prose to discover a rule.

## File-Type Adaptation

Adapt depth, representation, and emphasis to the artifact's purpose, authority, consultation pattern, execution needs, consequences of misinterpretation, and required inline context.
Apply this adaptation to each passage as well as the artifact overall.
File type informs the choice but does not determine it.

- **Operational documents:** For `AGENTS.md`, `SKILL.md`, plans, and task documents, prioritize actions, constraints, dependencies, sequences, routing, and verification. Make prerequisites and completion criteria easy to locate.
- **Governing documents:** For standards, policies, and specifications, prioritize principles, requirements, constraints, definitions, conditions, exceptions, decisions, authority, and verification. Keep force and scope explicit. Do not let explanation obscure a rule.
- **Guides:** Prioritize recommendations, instructions, criteria, rationale, examples, and references. Do not make advisory guidance mandatory without authority.
- **Reference documents:** Prioritize definitions, stable facts, mappings, criteria, and references. Optimize for lookup. Do not bury governing instructions in passive reference material.
- **READMEs and overviews:** Prioritize purpose, orientation, initial-use instructions, routing, and authoritative references. Keep the introduction concise.

## Presentation

### Plain Language

Use the simplest direct and concrete language that preserves required precision and material meaning.

- Prefer familiar words, specific verbs, clear actors and actions, and straightforward sentence structures over unnecessary jargon, formality, abstraction, or complexity.
- Describe observable behavior, requirements, effects, or changes before abstract characterization or implementation terminology, unless the abstraction is necessary to understand the subject.

### Structure and Retrieval

Use one document title and headings that represent meaningful hierarchy.
Use consistent levels, concise descriptive names, and no skipped levels without a structural reason.
Do not create headings for trivial fragments.

Give each section a coherent purpose.
Split sections when different subjects, scopes, conditions, or functions would otherwise be difficult to distinguish or scan.
Do not fragment tightly related content.

Choose the representation that exposes the relationship:

- Use focused prose for tightly connected content.
- Use unordered lists for parallel independent items.
- Use ordered lists only for meaningful sequence or priority.
- Use tables for compact mappings, comparisons, and matrices.
- Use code blocks for multiline literal content.
- Use references for material that should be retrieved elsewhere.

Do not choose a representation merely for visual variety or impose fixed section lengths.
A complex section may be longer than a simple one.

For large artifacts, use descriptive headings and precise cross-references.
A cross-reference should identify an authoritative destination and explain its relevance when it is not obvious.
Do not add navigation with little retrieval value.
Use nesting only for genuine parent-child relationships, and prefer flatter structure when it is clearer.

### Writing and Prominence

Keep independently enforceable rules separately identifiable when practical.
Do not split a tightly coupled condition and consequence merely to shorten a sentence.

Keep paragraphs focused.
Convert parallel content to a list when that better exposes the relationship.
Use lists or subsections when prose becomes difficult to scan.
Do not bury requirements, constraints, conditions, dependencies, or exceptions in explanatory prose.

Front-load purpose and scope when later content depends on them.
Lead with a governing rule, action, decision, or conclusion before its explanation when practical.
Keep triggering conditions and material qualifiers adjacent to what they affect.

Use literal, predictable headings such as `Scope`, `Requirements`, `Procedure`, `Verification`, `Exceptions`, `Rationale`, `Examples`, and `References` when accurate.
A heading must not be the sole indication of authority, scope, or force.

Prefer short, direct sentences, active voice when the actor matters, and imperative wording for direct instructions.
A longer sentence is appropriate when it more clearly preserves one tightly coupled statement.
Avoid filler, vague directions, decorative prose, and unnecessary transitions.
Name exact files, paths, commands, tools, identifiers, inputs, outputs, and artifacts when known and material.

Use the simplest terminology that remains precise and consistent.
Preserve established technical terms when they communicate more accurately than ordinary language.
Define unfamiliar technical terms when their meaning is necessary for correct interpretation or use.

Use direct statements of desired behavior.
Use a prohibition when a boundary, unsafe action, invalid state, or forbidden behavior must be explicit.
Do not weaken a precise prohibition merely to phrase it positively.

For a significant procedure, state the action, relevant trigger, and verification when needed.
State success criteria when correctness would otherwise require inference.

Make progressively retrieved sections locally comprehensible with the minimum necessary scope, terminology, conditions, and references.
Do not require unrelated sections to discover an essential qualifier or duplicate a full canonical definition only to make every section self-contained.

Use recurring presentation patterns only when they improve comprehension or retrieval.
Do not create empty sections or superficial consistency that obscures the content's real structure.

### Independently Usable Content and Semantic Lines

Choose paragraph structure from the function and relationships of the content.

Use an ordinary prose paragraph when its sentences form one continuous explanation, argument, description, narrative, interpretation, or synthesis and no part needs to be independently located, applied, compared, revised, or verified.
A sentence boundary alone does not justify a new source line.

Content must be separately identifiable when finding it independently could change interpretation, a decision, an action, verification, or the handling of a condition or exception.
This includes requirements, prohibitions, permissions, actions, conditions, exceptions, dependencies, prerequisites, alternatives, warnings, decisions, findings, limitations, uncertainty, verification criteria, and completion criteria.
Supporting rationale does not require separate identification merely because it occupies a separate sentence.

When applying format, determine what must be separately identifiable from the applicable content model, not only from the artifact's surface syntax.
Treat each separately testable directive, conditional branch, exception, dependency, warning, decision criterion, verification criterion, or completion criterion as distinct even when several appear in one sentence.
A shared topic, heading, sentence, paragraph, or section does not make separately testable content tightly coupled.

Choose the smallest structure that exposes the applicable relationships:

- Use semantic source lines when related directives, conditions, exceptions, dependencies, or other separately identifiable content share one paragraph-level purpose but need to be located, applied, compared, revised, or verified independently.
- Use a list when the content forms a collection, sequence, comparison, or set that requires visible separation in rendered Markdown.
- Use separate paragraphs or subsections when the subject, scope, purpose, or governing context changes.

For governing, operational, and advisory prose, use one complete directive or independently usable control statement per physical source line by default.
Keep related source lines contiguous when they share one paragraph-level purpose.
Do not insert a blank line merely because a separately identifiable directive, condition, exception, or dependency begins.
Insert a blank line only when the paragraph-level subject, scope, purpose, or governing context changes.

Split a multi-sentence source line unless the additional sentences explain the same directive, condition, exception, or explanation and cannot be applied, checked, or revised independently.
Split a compound sentence at a clause boundary when its clauses contain separately testable directives, conditions, exceptions, dependencies, decisions, or verification criteria.
Keep a control statement's trigger, governed action, qualifiers, exceptions, dependencies, required alternative, and verification together when separating them would obscure or change their relationship.
Place supporting rationale on another source line when combining it with the associated directive or control statement would make that statement difficult to identify.
Do not combine separately testable directives, conditions, exceptions, dependencies, or criteria solely to reduce tokens or preserve paragraph flow.

In explanatory, narrative, descriptive, or interpretive prose, retain ordinary paragraph flow unless semantic lines materially improve independent use.

For example, the following operational paragraph contains three separately testable instructions with one paragraph-level purpose:

```md
When the facility closes, lock the exterior door.
If a visitor remains inside, notify the supervisor instead of activating the alarm.
Record the closure time in the daily log.
```

The lines remain contiguous because they belong to one closing procedure.
The conditional line keeps its trigger, governed action, and required alternative together.

After drafting, inspect every non-list prose source line in governing, operational, and advisory content.
If a line contains multiple separately testable directives, conditions, exceptions, dependencies, or criteria, split it at the boundary between them or use a list before delivery.
Then inspect blank lines and remove any that separate related statements sharing one paragraph-level purpose.

A single source line break within a paragraph usually does not create visible separation in rendered Markdown.
Use a list, separate paragraph, or subsection when the distinction must be visible after rendering.
Do not use hard line breaks as a general substitute for semantic structure.

Apply these rules to prose only.
Do not use semantic lines to alter the syntax or literal meaning of code blocks, tables, lists, blockquotes, or other Markdown structures.

### Markdown Formatting

Formatting must expose meaning rather than decorate the artifact:

- Use ATX headings with `#`. Do not use bold text as a heading substitute.
- Separate paragraphs and structural blocks with blank lines. Do not use arbitrary line wrapping or whitespace as a substitute for semantic structure.
- Use `-` for unordered lists. Keep list items parallel, use one item per separately identifiable entry, and avoid deep nesting.
- Keep tables concise. Do not use them for ordinary prose, sequential procedures, or long cell paragraphs.
- Use inline code for literal paths, commands, identifiers, keys, values, and syntax. Use fenced blocks for multiline literal content, specify a language when useful, and preserve exact syntax when needed.
- Use blockquotes for quotations, preserved user statements, or source material that must remain distinct, not as decorative callouts.
- Use emphasis only for local distinctions that improve scanning. Do not use it as the sole signal of authority, force, priority, condition, or exception.
- Use repository-relative paths for repository files and inline code for literal paths. Use descriptive link text for human navigation and stable authoritative destinations. Keep immediately necessary information inline.
- Markdown tables MUST use column widths padded with spaces so that each column is visually aligned, including the header, separator row, and all body rows.

## Validation

Before delivery, verify all applicable checks:

- **Structure and retrieval:** Hierarchy, grouping, order, representation, navigation, and nesting reflect genuine relationships. Important content is quickly findable and locally comprehensible when partial retrieval is likely.
- **Writing and formatting:** Language is direct, concrete, consistent, and appropriately normative. Markdown exposes semantic structure rather than substituting for it.
- **Normative force:** Normative force is explicit when needed and does not depend on formatting or capitalization alone.
- **Paragraph flow:** Continuous explanatory, narrative, descriptive, or interpretive prose is not fragmented solely at sentence boundaries. Governing, operational, or advisory statements with one paragraph-level purpose are not promoted to separate paragraphs merely to make them identifiable.
- **Independent-content visibility:** Determine what must be separately identifiable from the applicable content model. Each independently usable requirement, condition, exception, dependency, warning, decision, finding, limitation, uncertainty, or verification criterion is separately identifiable. No physical source line conceals multiple separately testable statements merely by combining their wording.
- **Representation:** Semantic source lines remain contiguous when the statements they contain share one paragraph-level purpose. Lists expose collections, sequences, comparisons, or content requiring visible rendered separation. Separate paragraphs or subsections mark paragraph-level changes in subject, scope, purpose, or governing context.

## Corrective Action

These lists capture reusable Markdown structure and presentation mistake patterns that need special attention during creation, revision, transformation, and audit.
They reinforce the governing rules in this file but do not create new requirements or change audit outcomes.

Before delivery, check every listed pattern that applies to the work.

### Failures

No known failure patterns.

### Warnings

- Do not merge independent governing directives or term definitions into one prose line solely to compress text; retain semantic lines or list items when independent retrieval matters.
