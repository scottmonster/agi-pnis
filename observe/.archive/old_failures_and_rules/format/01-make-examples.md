# Create code-level pattern example catalog

## 1. Objective

Create one Markdown example file for every canonical concept in:

`/home/scott/Documents/agi-pnis/docs/concepts/format/list_complete.md`

Write files only under:

`/home/scott/Documents/agi-pnis/docs/concepts/format/examples/`

For each concept, create a file named from its canonical name in lowercase kebab case. Each file must contain one complete, concept-specific scenario that contrasts a good form with a less maintainable form, plus concise structural references that identify the code target. Do not create separate good and bad examples for every structural level.

For example:

- `guard-clauses.md`
- `replace-conditional-with-polymorphism.md`
- `long-parameter-list.md`

Do not create separate files for aliases. Do not modify `list_complete.md`, `structure.md`, or any other existing file.

Use subagents when they are available. You may use up to six active subagents at once when the runtime supports that capacity.

## 2. Required preparation

1. Read the repository instructions in `AGENTS.md`.
2. Read:
   - `/home/scott/Documents/agi-pnis/docs/concepts/format/list_complete.md`
   - `/home/scott/Documents/agi-pnis/docs/concepts/structure.md`
3. Inventory every canonical concept from the catalog before creating files.
4. Treat each bolded canonical concept as one output file. Merge aliases into that file.
5. Preserve the catalog’s full index, classification, aliases, definition, and related concepts. Display the classification in lowercase, consistent with the existing example files.

## 3. Delegation

Use subagents when available. Assign exactly one canonical concept and its corresponding output file to each subagent.

1. Create up to six subagents concurrently when the runtime supports that capacity. Otherwise, use the available capacity.
2. Each subagent MUST create or update exactly one example file for its assigned concept and MUST NOT create or edit any other example file.
3. Give each subagent its canonical concept, aliases, classification, target filename, related-concept distinctions, and the required file template.
4. Do not assign the same concept or target file to more than one subagent.
5. After a batch completes, assign the next unassigned concepts in another batch of up to six subagents when capacity permits. Continue until every canonical concept has one completed file.
6. The primary agent remains responsible for inventory, filename normalization, task assignment, consistency review, duplicate prevention, and final validation.

## 4. Required content for every example file

Use this structure:

````markdown
# <Canonical Concept>

## 1. Concept

- **Classification:** <lowercase classification from the catalog>
- **Catalog identifier:** <full index from the catalog>
- **Aliases:** <aliases, or “None”>
- **Definition:** <concise catalog-backed definition>
- **Why it matters:** <how it affects readability, understandability, or maintainability>
- **Related concepts:** <relevant distinctions and related concepts from the catalog>

## 2. Example

### 2.1 Scenario

<State the shared, realistic scenario in one or two sentences.>

### 2.2 Good form

```ts
// One complete code example that directly demonstrates the canonical concept.
```

### 2.3 Less maintainable form

```ts
// One complete code example of the same scenario that lacks, misuses, or exhibits the concept.
// Call it an anti-pattern only when the catalog classifies it as one.
```

### 2.4 Why this difference matters

<Explain the concept-specific mechanism that makes the good form easier to read, understand, or change.>

### 2.5 Structural references

<For each code form, provide only the shortest structural reference path that identifies its demonstrated target. The two paths may share every enclosing level and differ only at the relevant code element or target.>

```text
Good: project > package > file > function > target
Less maintainable: project > package > file > function > target
```

<Explain only the structural difference that is relevant to the canonical concept. Do not turn project, folder, package, or file organization into unrelated examples of the concept.>

## 3. Boundaries and distinctions

<Explain when the concept does not apply, when the less maintainable form is appropriate, and how the concept differs from easily confused related concepts.>
````

## 5. Example rules

1. Use actual, syntactically coherent code for every code-level example. Do not use language-neutral pseudocode as a substitute for code.
2. Use TypeScript by default so function, object, dependency, data-model, and asynchronous examples share one readable syntax. Use another real language only when it materially represents the concept better, and label the code fence with that language.
3. Use `text` blocks only for structural-reference paths and repository trees, never for code examples.
4. Use the same scenario in the good and less-maintainable forms. The contrast must directly demonstrate the canonical concept, not a different smell or a general organizational preference.
5. Each code example must be internally coherent:
   - define or clearly provide every identifier it uses;
   - use valid indentation and syntax;
   - preserve the same intended behavior unless the concept necessarily changes error handling or lifecycle behavior;
   - demonstrate the named concept directly; and
   - avoid placeholders such as `construct X here`.
6. Where complete compilation would require unimportant infrastructure, omit that infrastructure only when the remaining snippet is still valid and understandable code.
7. Follow `structure.md`: structural levels are roles, not required sections. Include only the levels that exist and materially identify the demonstrated target. Do not invent a class, package, folder, or other level.
8. Use "Less maintainable form" by default. Use "anti-pattern" only when the catalog classifies that concept as an anti-pattern. State the condition that makes the alternative less maintainable; do not imply that a direct constructor call, condition, mutation, or Service Locator is always wrong.
9. For refactorings, show the less maintainable and improved forms clearly. For code smells and anti-patterns, show the problematic and better forms clearly.
10. Every explanation must identify the concept's actual mechanism. For example, explain one shared implementation for Duplicate Code or an early return before the normal path for Guard Clauses. Do not reuse generic scaffolding or stock prose across concepts.
11. Do not use testing-only examples unless the concept itself concerns testing.

## 6. Quality and scope constraints

1. Every file must stand alone.
2. Avoid generic advice, generic repository organization claims, and generic code-ownership claims. Explain the observable code structure and its specific maintenance effect.
3. Keep each file short enough to scan. Prefer one strong before/after code scenario and structural reference over repeated partial examples.
4. Preserve material caveats. For example, do not present Service Locator as universally an anti-pattern, or every fluent interface as a Message Chain.
5. Do not add concepts not present in `list_complete.md`.
6. Do not modify files outside `docs/concepts/format/examples/`.

## 7. Validation

Before finishing:

1. Confirm that the number of created files equals the number of canonical concepts in `list_complete.md`.
2. Confirm aliases did not generate duplicate files and every file has the correct catalog identifier.
3. Confirm every file has the required concept information, one scenario, one good form, one less-maintainable form, an explanation, structural references, and boundaries and distinctions.
4. Check that all filenames are unique, lowercase kebab case, and correspond to canonical names.
5. Apply this semantic gate to every file:
   - the less-maintainable form genuinely exhibits the named smell or lacks or misuses the named pattern;
   - the good form solves the same scenario without changing unrelated concerns;
   - the examples reflect the catalog definition, and material distinctions;
   - all identifiers are defined and the code is syntactically coherent;
   - structural references use only levels that materially identify the target; and
   - no generic template prose is reused unless it is specific to the concept.
6. Run an appropriate Markdown and whitespace check.
7. Report:
   - number of concept files created;
   - any concepts whose structural references omit levels because those levels do not materially identify the target;
   - validation performed;
   - any material limitations.
