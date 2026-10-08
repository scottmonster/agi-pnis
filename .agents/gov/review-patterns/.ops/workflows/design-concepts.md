# Build and Maintain the Code Design Concept Catalog Family

Research, build, and maintain the source-backed catalog family for code design concepts:

```text
../../design-concepts/design-concepts-catalog.md
../../design-concepts/design-concepts-rules.md
../../design-concepts/examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
../sources/design-concepts.md
```

The catalog is the authoritative inventory. Rules and examples are derived from it. `../sources/design-concepts.md` is the retained provenance ledger. Do not create or maintain other operational files for this catalog family.

## 1. Inputs and preservation

Read before working:

- `../catalog-family-spec.md`
- `../../design-concepts/design-concepts-catalog.md`, when it exists
- `../../design-concepts/design-concepts-rules.md`, when it exists
- Every file under `../../design-concepts/examples/`, when the directory exists
- `../sources/design-concepts.md`, when it exists
- Applicable repository instructions

Treat existing catalog identifiers, canonical names, classifications, aliases, and categories as stable. Do not delete, rename, renumber, move, merge, or silently replace an existing canonical entry. Add a category or subcategory only when no existing location fits. Update the matching rules, example, and source-ledger record whenever an existing entry is materially corrected.

## 2. Research objective and scope

Build an as-comprehensive-as-practicable catalog of established, named, code-level concepts that materially affect readability, understandability, changeability, maintainability, or reasoning about code. Eligible concepts include refactorings, patterns, control-flow techniques, code smells, and anti-patterns.

Research broadly without using a predetermined taxonomy as the search space. Discover categories from the evidence, then fit verified concepts into the catalog's existing hierarchy where appropriate. Search beyond familiar pattern lists for meaningful concepts in control flow, functions, parameters, data and state, object collaboration, dependencies, persistence boundaries, asynchronous and concurrent code, and code-quality failures.

Exclude generic advice, project-management practices, testing-only techniques, broad architectural styles, and language-specific idioms unless authoritative sources establish them as broadly applicable named code-level concepts.

For every proposed concept:

1. Verify its name, meaning, classification, aliases, and material distinctions through authoritative or primary sources where feasible.
2. Prefer original pattern literature, official language documentation, Refactoring.com, Martin Fowler's work, and other primary or established references.
3. Compare it against existing canonical names and aliases before adding it. Treat alternate names as aliases unless they identify a materially distinct concept.
4. Stop only when further research is producing primarily duplicates, narrow variants, weakly supported terminology, or concepts outside the defined scope.

Do not claim global completeness. Keep source URLs and source notes only in `../sources/design-concepts.md`, with one navigable source record for every canonical catalog entry. Do not copy citations, URLs, source names, or research narrative into the catalog, rules, or examples.

## 3. Catalog requirements

Create or update `../../design-concepts/design-concepts-catalog.md` first.

1. Use the title `# Code Design Concept Catalog`.
2. Immediately below the title, include this one-line declaration:

   ```markdown
   _Entry format: <index> **<canonical name>** _(<classification>; also known as: aliases)_ - <concise definition>. _Related:_ canonical concepts._
   ```

3. Organize canonical entries under descriptive `##` categories and `###` subcategories. Use headings to describe subject matter, not priority.
4. Assign new entries a full hierarchical index that continues the containing category and subcategory without changing any existing index.
5. Write every entry on exactly one physical line:

   ```markdown
   <index> **<canonical name>** _(<classification>; also known as: <alias 1>, <alias 2>)_ - <concise definition>. _Related:_ <canonical name>, <canonical name>.
   ```

6. Use only these classifications: `Refactoring`, `Pattern`, `Code smell`, `Anti-pattern`, or `Control-flow technique`.
7. Omit aliases and related concepts when none is materially useful. Related concepts must be canonical names in this catalog.
8. Keep each definition concise and concrete. State what the concept does or identifies and why it matters for understanding or maintenance, including a material tradeoff when needed.
9. Keep `../sources/design-concepts.md` synchronized with catalog entries, identifiers, and canonical names. Record direct source URLs there, not in the catalog.

## 4. Example requirements

After the catalog inventory is stable, create or update exactly one example file per canonical entry:

```text
../../design-concepts/examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
```

Use this structure:

````markdown
# <Canonical Concept>

## 1. Concept

- **Classification:** <lowercase classification>
- **Catalog identifier:** <full index>
- **Aliases:** <aliases, or "None">
- **Definition:** <catalog-backed definition>
- **Why it matters:** <concept-specific maintenance effect>
- **Related concepts:** <relevant distinctions, or "None">

## 2. Example

### 2.1 Scenario

<One or two sentences describing one realistic shared scenario.>

### 2.2 Good form

```ts
<Complete, syntactically coherent TypeScript example.>
```

### 2.3 Less maintainable form

```ts
<Complete example of the same scenario that lacks, misuses, or exhibits the concept.>
```

### 2.4 Why this difference matters

<Explain the concept's actual mechanism and maintenance effect.>

### 2.5 Structural references

```text
Good: <shortest useful containment path to the target>
Less maintainable: <shortest useful containment path to the target>
```

## 3. Boundaries and distinctions

<State when the concept does not apply, when the less maintainable form is appropriate, and how nearby concepts differ.>
````

Use actual, syntactically coherent code, TypeScript by default. The two forms must represent the same scenario and directly demonstrate the canonical concept. Define or clearly provide every identifier, avoid pseudocode and placeholder implementations, and preserve intended behavior unless the concept necessarily changes error handling or lifecycle behavior.

Structural references use only the containment levels that exist and materially identify the demonstrated target, such as project, package, file, type, function, statement, or line. Do not invent a class, directory, package, or other level. Do not treat a structural-reference level as a separate example of the concept.

Use "Less maintainable form" by default. Call the form an anti-pattern only when the catalog classifies that entry as an anti-pattern. Preserve caveats: do not portray a direct constructor call, condition, mutation, Service Locator, or other alternative as universally wrong.

## 5. Rules requirements

Create or update `../../design-concepts/design-concepts-rules.md` only after catalog and examples are complete.

1. Use the title `# Code Design Concept Rules`.
2. Mirror every catalog `##` and `###` heading exactly and in the same order.
3. Under each matching subcategory, include exactly one rule for every canonical catalog entry in catalog order:

   ```markdown
   <index> **<canonical name>** - <concise, actionable, context-aware rule>
   ```

4. For code smells and anti-patterns, state what to avoid and the relevant condition or risk. For patterns, refactorings, and control-flow techniques, state when to use the concept and the outcome it should achieve.
5. Keep rules short, specific, and independently useful. Preserve boundaries and tradeoffs from the catalog and examples. Do not present conditional guidance as universally required.
6. Do not include classifications, aliases, definitions, related-concept lists, code, citations, URLs, source notes, tables, checklists, or introductory prose beyond the title and required headings.

## 6. Execution and validation

Work in stages: research and stabilize the catalog inventory, create or update examples, derive rules, then validate the complete family. When subagents are available, divide examples and rule drafting into mutually exclusive, contiguous catalog sections. Do not assign the same index or target file to more than one subagent. The primary agent integrates all drafts and performs final validation.

Before handoff, verify that:

1. Every catalog identifier is unique, stable, and on one physical line.
2. The catalog uses only the allowed classifications and contains no citations, URLs, or source labels.
3. Aliases do not create duplicate entries, rules, or examples.
4. Each catalog entry has one matching source-ledger record and exactly one matching example file.
5. Example titles, identifiers, and filenames match their canonical catalog entries.
6. Each example has the required concept record, coherent shared scenario, good form, less maintainable form, explanation, structural references, and boundaries section.
7. Rules headings exactly match catalog headings in order.
8. Rules have exactly one matching `(index, canonical name)` pair for every catalog entry, with no duplicates, omissions, or alias-only rules.
9. Every rule is one physical line and contains no prohibited catalog or source metadata.

Report catalog, rule, example, and source-ledger counts, along with validation performed and any material research limitations.
