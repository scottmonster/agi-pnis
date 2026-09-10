# Build the Miscellaneous Catalog Family

Build a catalog, rules file, and one example file for every canonical concept established by the reference material in `ref/`.

Create or update only these derived outputs:

```text
../misc-catalog.md
../misc-rules.md
../examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
```

Do not modify `../../spec.md`, `../.ops/ref/`, this instruction file, or any file outside the three output locations.

## 1. Read and inventory the references

Read before drafting:

- `../../spec.md`
- Every file directly under `ref/`
- Applicable repository instructions

The reference directory is the provenance record. It may contain HTML, Markdown, text, or other readable reference formats, and it may mix narrative, examples, rationale, caveats, and one or more named ideas.

First make a complete private inventory. For each source, identify:

- its title or explicitly named concept;
- the concise claim that can serve as a catalog definition;
- material conditions, exceptions, and tradeoffs;
- whether the source explicitly presents multiple independent concepts.

Do not create an entry merely because a source contains an incidental technique, code fragment, product name, or linked article. Treat a jointly named heuristic as one entry unless the source itself establishes separate canonical concepts. Do not merge separately named concepts, and do not infer a broader taxonomy that the references do not support.

Keep reference files unchanged. They retain their URLs, examples, authorship, and explanatory context.

## 2. Catalog requirements

Create `../misc-catalog.md` as the authoritative miscellaneous inventory.

1. Use the title `# Miscellaneous Catalog`.
2. Immediately below it, include exactly this one-line declaration:

   ```markdown
   _Entry format: <index> **<canonical name>** - <concise definition>._
   ```

3. Group concepts under descriptive `##` headings based on the kind of engineering judgment involved, such as control flow, data processing, interfaces, or review practice. Do not create a catch-all heading when a meaningful technical description is available.
4. Use two-part indexes such as `1.1` when a category has no useful subcategory. Add `###` subcategories and three-part indexes only when they improve navigation.
5. Write every entry on one physical Markdown line:

   ```markdown
   <index> **<canonical name>** - <concise definition>.
   ```

6. Use the source title or explicit concept name as the canonical name. Write a faithful, self-contained definition that retains conditions needed to avoid a universal claim.
7. Do not include citations, URLs, source filenames, quotes, tables, reference commentary, or introductory prose beyond the title and entry-format declaration.

## 3. Example requirements

Create exactly one file for each catalog entry:

```text
../examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
```

Every example must use this structure:

````markdown
# <Canonical Name>

## 1. Catalog record

- **Catalog identifier:** <full index>
- **Definition:** <concise catalog-backed definition>

## 2. Scenario

### 2.1 Context

<Describe one realistic implementation, review, or design situation.>

### 2.2 Preferred shape

<Show the focused implementation or review behavior that applies the concept.>

### 2.3 Less suitable shape

<Show the same situation handled in a way that misses the concept.>

### 2.4 Why this difference matters

<Explain the concrete clarity, correctness, maintainability, or performance consequence.>

## 3. Boundaries and distinctions

<State the conditions, exceptions, or tradeoffs that keep the concept from becoming universal advice.>
````

Use a coherent code block only when code demonstrates the distinction. For architectural, review, workflow, or operational concepts, short prose, commands, diffs, or configuration excerpts may be clearer. Keep the preferred and less suitable forms anchored to the same scenario. Do not add citations or URLs.

## 4. Rules requirements

Create `../misc-rules.md` after the catalog and examples are complete.

1. Use the title `# Miscellaneous Rules`.
2. Mirror all `##` and `###` headings from `../misc-catalog.md` exactly and in the same order.
3. Under each matching heading, include one rule per catalog entry, in catalog order:

   ```markdown
   <index> **<canonical name>** - <concise actionable rule>
   ```

4. State what to prefer, avoid, or verify; when it applies; and the outcome it protects.
5. Preserve the source and example boundaries. A rule of thumb, optimization, or refactoring technique must not be presented as an unconditional requirement.
6. Do not repeat definitions, source material, citations, URLs, code, tables, checklists, or introductory prose.

## 5. Assembly and validation

Decide the complete concept inventory and final indexes before creating examples. If subagents are available, give each one mutually exclusive, contiguous catalog sections and corresponding example paths. The primary agent must integrate the final catalog and rules and perform the final validation.

Before finishing, verify that:

1. Every explicitly canonical source concept appears once, and no entry was created from incidental material.
2. Catalog indexes and canonical names are unique, and every entry occupies one physical line.
3. The catalog title, entry-format declaration, headings, and source-free content meet this instruction.
4. Rules headings match catalog headings exactly and every `(index, canonical name)` pair appears once in each artifact.
5. Every catalog entry has one matching example filename, title, catalog identifier, and definition.
6. Each example contains the catalog record, context, preferred shape, less suitable shape, consequence, and boundaries sections.
7. No URLs or citations appear in the catalog, rules, or examples.
8. No files outside the requested catalog, rules, and examples outputs were created or modified.

Report the source-concept count, catalog-entry count, rule count, example count, and validation results.
