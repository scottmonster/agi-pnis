# Build and Maintain the Miscellaneous Catalog Family

Research, build, and maintain the source-backed catalog family for engineering concepts that do not belong in a more specific catalog family.

```text
Catalog: ../../misc/misc-catalog.md
Rules: ../../misc/misc-rules.md
Examples: ../../misc/examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
Source ledger: ../sources/misc.md
Retained source material: ../sources/misc/
```

The catalog is the authoritative inventory. Rules and examples are derived artifacts. The source ledger and retained source material preserve provenance and context. Do not create or maintain other operational files for this catalog family.

## 1. Inputs and preservation

Read before working:

- `../catalog-family-spec.md`
- `../../misc/misc-catalog.md`, when it exists
- `../../misc/misc-rules.md`, when it exists
- Every file under `../../misc/examples/`, when the directory exists
- `../sources/misc.md`, when it exists
- Every relevant file under `../sources/misc/`, when the directory exists
- Applicable repository instructions

Treat existing catalog identifiers, canonical names, categories, rules, examples, ledger records, and retained source files as stable. Do not delete, rename, renumber, move, merge, or silently replace an existing canonical entry. Do not edit a retained source capture. When an existing entry is materially corrected, update its catalog record, rule, example, and source-ledger record together.

## 2. Research objective and scope

Build an as-comprehensive-as-practicable catalog of established, named engineering heuristics, techniques, review practices, or implementation concepts that are materially useful but do not belong in a more specific catalog family already in this repository.

Research broadly without using a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery. Prefer primary sources, authoritative technical documentation, original articles, and established engineering literature. Retain a source capture only when its context is needed for maintenance or review and it can be stored lawfully and faithfully; otherwise record a direct URL in the source ledger.

For every candidate:

1. Establish that it is a named or clearly distinguishable engineering concept with a material consequence for clarity, correctness, maintainability, performance, reliability, or review quality.
2. Check the existing catalog and other catalog families before adding it. Do not duplicate a concept owned by another family.
3. Preserve a source's stated conditions, exceptions, and tradeoffs. A source's incidental code fragment, product name, or linked article is not automatically a canonical concept.
4. Treat a jointly named heuristic as one entry unless the source establishes its parts as independent canonical concepts with distinct applications and boundaries.
5. Record direct support and material limitations in `../sources/misc.md` before considering an entry complete.

Do not use Miscellaneous as a catch-all for generic advice, language-specific pitfalls, code design concepts, AI coding smells, or findings that have a better existing home.

## 3. Source ledger

Maintain `../sources/misc.md` with one `## <index> <canonical name>` section per catalog entry. Each section must link to direct source URLs or retained source captures, state what the source establishes, and record material scope, author, date, provenance, or evidence limitations when relevant.

Keep citations, URLs, source filenames, quotations, and research narrative out of the catalog, rules, and examples. A retained source capture provides context and provenance; it is not itself active instruction.

## 4. Catalog requirements

Create or update `../../misc/misc-catalog.md` first.

1. Use the title `# Miscellaneous Catalog`.
2. Immediately below the title, include this one-line declaration:

   ```markdown
   _Entry format: <index> **<canonical name>** - <concise definition>._
   ```

3. Organize entries under descriptive `##` headings based on the engineering judgment involved. Use `###` subcategories and three-part indexes only when they improve navigation.
4. Use two-part indexes when a category has no useful subcategory. Do not change existing indexes.
5. Write every entry on exactly one physical line:

   ```markdown
   <index> **<canonical name>** - <concise definition>.
   ```

6. Use the source's explicit concept name where available. Write a faithful, self-contained definition that retains conditions needed to avoid a universal claim.
7. Do not include citations, URLs, source names, source filenames, quotes, tables, research commentary, or introductory prose beyond the title and entry-format declaration.

## 5. Examples and rules

After the catalog inventory is stable, create exactly one example per canonical entry at:

```text
../../misc/examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
```

Each example identifies its canonical name and catalog identifier, describes one realistic implementation, review, or design situation, contrasts a preferred shape with a less suitable shape for the same situation, explains the concrete consequence, and states the relevant boundaries or tradeoffs. Use coherent code only where it demonstrates the distinction. Do not add citations or URLs.

Only after catalog and examples are complete, create or update `../../misc/misc-rules.md` with the title `# Miscellaneous Rules`. Mirror all catalog `##` and `###` headings exactly and in order. Under each matching heading, include one physical line per catalog entry:

```markdown
<index> **<canonical name>** - <concise, actionable, context-aware rule>
```

Rules must state what to prefer, avoid, or verify; when it applies; and the outcome protected. They must not repeat definitions, source material, citations, URLs, code, tables, checklists, or introductory prose.

## 6. Validation and handoff

Before handoff, verify that:

1. Every canonical source concept appears once, and no entry was created from incidental material.
2. Catalog indexes and canonical names are unique, stable, and each entry occupies one physical line.
3. Every catalog entry has exactly one source-ledger record, one rule, and one matching example file.
4. Example filenames, titles, and catalog identifiers map one-to-one to canonical catalog entries.
5. Each example contains a scenario, preferred shape, less suitable shape, explanation, and boundaries section.
6. Rules headings match catalog headings exactly and in order, with exactly one matching `(index, canonical name)` pair per entry.
7. The catalog, rules, and examples contain no citations, URLs, or source labels.

Report catalog, rule, example, and source-ledger counts; research coverage; validation performed; and material source limitations.
