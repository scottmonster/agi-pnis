# Maintain the Code Design Concept Catalog

Create and maintain a source-backed, as-comprehensive-as-practicable catalog of named code-level concepts related to readability and maintainability. Concepts include patterns, refactorings, techniques, code smells, and anti-patterns. Research must be rigorous, but the catalog itself must not cite sources or contain URLs.

## 1. Target and preservation rules

1.1 The only output file is `/home/scott/Documents/agi-pnis/docs/concepts/format/list_complete.md`.

1.2 If that file exists, read it before researching. Treat every existing entry as retained: do not delete, rename, renumber, move, merge, or otherwise remove an existing item.

1.3 Research only concepts that are not already represented in the existing catalog. Compare canonical names and aliases before deciding that a concept is new.

1.4 Add verified new concepts to the appropriate existing category, or add a clearly named category when none fits. Assign a full hierarchical index that continues the catalog's current structure without changing existing indexes.

1.5 If `list_complete.md` does not exist, create it with the category structure in section 5. Include every seed example in section 6 as an initial entry in its corresponding category, then continue from there.

1.6 Do not modify any file other than `list_complete.md`.

## 2. Scope

2.1 Include only established, named concepts that describe a recurring code-level structure, problem, or transformation with a material effect on readability, understandability, changeability, or maintainability.

2.2 Find concepts across these categories:

- Refactorings and implementation patterns.
- Code smells and anti-patterns.
- Control-flow and conditional-logic techniques.
- Function, parameter, data-model, object-design, dependency, persistence-boundary, asynchronous-code, and concurrent-code maintainability patterns.

2.3 Exclude generic advice, project-management practices, testing-only techniques, broad architectural styles, and language-specific idioms unless authoritative sources treat them as broadly applicable named patterns.

2.4 Treat alternate names as aliases, not separate concepts. Do not add near-duplicates. Record a material overlap or distinction in an entry only when it prevents duplicate interpretation.

## 3. Research method

3.1 Discover broadly, then verify each proposed concept against an authoritative or primary source where feasible. Prefer original pattern literature, Refactoring.com, Martin Fowler's work, Refactoring Guru, or official language documentation.

3.2 Use sources to establish the concept's name, classification, aliases, meaning, and distinction from related concepts. Do not rely on a source merely because it uses a familiar label.

3.3 Do not claim global completeness. The catalog is comprehensive only within the inclusion criteria and research performed. Preserve or add a concise scope and methodology section in `list_complete.md` that states the inclusion and exclusion criteria, source types searched, alias-handling rule, stopping rule, and meaningful gaps, disputed terminology, or source-access limitations.

3.4 Keep the scope and methodology section citation-free. It may describe source types, but it must not identify sources, use citations, or contain URLs or Markdown links.

## 4. Required catalog format

4.1 Organize entries under descriptive Markdown category headings.

4.2 Write every entry on one line in exactly this format:

`<full_index> **Concept Name** _(Classification; also known as: Alias 1, Alias 2)_ - Definition. _Related:_ Concept A, Concept B.`

4.3 `<full_index>` is the entry's complete hierarchical numeric index, such as `1.2.3`.

4.4 Use one of these classifications: `Refactoring`, `Pattern`, `Code smell`, `Anti-pattern`, or `Control-flow technique`. Omit the `also known as` clause when there are no meaningful aliases. Omit the related clause when no useful relation is available.

4.5 Keep definitions concise and concrete. State what the concept does or identifies and why that matters for understanding or maintenance.

4.6 Do not include citations, source names, footnotes, URLs, or Markdown links anywhere in `list_complete.md`.

## 5. Initial category structure

5.1 `1. Control flow and conditional logic`

- `1.1 Flattening and ordering control flow`
- `1.2 Conditions and choices`
- `1.3 Control-flow smells and asynchronous structures`

5.2 `2. Functions, statements, and parameters`

- `2.1 Naming, extraction, and local state`
- `2.2 Function contracts and arguments`

5.3 `3. Data, state, and model representation`

- `3.1 Encapsulation and representation refactorings`
- `3.2 Named model patterns`

5.4 `4. Objects, dependencies, and collaboration`

- `4.1 Object and dependency refactorings`
- `4.2 Classic object patterns`

5.5 `5. Code smells and anti-patterns`

- `5.1 Size, naming, and representation smells`
- `5.2 Duplication, coupling, and change smells`
- `5.3 Dispensable or speculative structure`

## 6. Seed examples

Use these examples when creating a missing catalog. They are also examples of the required entry format.

1.1.1 **Guard Clauses** _(Refactoring; also known as: replace nested conditional with guard clauses)_ - Handle exceptional or invalid cases at the start, leaving the normal path flat. It makes the dominant path visible and reduces nesting. _Related:_ Early Exit.

1.2.10 **Finite-State Machine (FSM)** _(Pattern)_ - Represent legal states and transitions explicitly, rather than letting them emerge from dispersed flags and conditionals. It makes state-dependent behavior and invalid transitions inspectable. _Related:_ State, Repeated Type Conditional.

2.1.11 **Split Phase** _(Refactoring)_ - Separate processing that performs different conceptual jobs into distinct stages. It makes each stage's inputs, outputs, and reasoning model clearer.

3.1.4 **Replace Primitive with Object** _(Refactoring; also known as: replace data value with object; replace type code with class)_ - Represent a domain value with a small type rather than a raw primitive. It gives validation, formatting, and rules a single explicit home. _Related:_ Primitive Obsession, Value Object.

3.2.4 **Data Mapper** _(Pattern)_ - Keep mapping between domain objects and storage representations in a separate layer. It can keep persistence details out of domain code, at the cost of another abstraction. _Related:_ Active Record.

4.1.16 **Dependency Injection** _(Pattern)_ - Supply a collaborator from outside the object, commonly through its constructor, rather than creating or locating it internally. Dependencies become visible in the contract and independently configurable. _Related:_ Service Locator.

4.2.6 **Adapter** _(Pattern)_ - Wrap an incompatible interface in one expected by clients. It isolates foreign or legacy API differences.

4.2.18 **Observer** _(Pattern)_ - Let dependents subscribe to state changes from a subject. It decouples publishers and listeners, while making event order and lifetime important.

1.3.7 **Structured Concurrency** _(Pattern)_ - Scope concurrent work so child tasks complete or are cancelled before their parent scope finishes. It keeps lifetimes, cancellation, and error propagation visible instead of leaving detached work. _Related:_ Futures/Promises.

5.2.4 **Shotgun Surgery** _(Code smell)_ - One conceptual change requires many small edits across locations. Knowledge of one rule is scattered and omissions become likely. _Related:_ Move Function.
