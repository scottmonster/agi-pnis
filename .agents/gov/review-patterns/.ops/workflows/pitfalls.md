# Build and Maintain Language Pitfall Catalog Families

This is the shared workflow for the language-specific entrypoints in this directory. Run an individual language workflow, such as `pitfalls-typescript.md`, to work on one catalog family. Do not use this document alone to make changes across every language unless the task explicitly covers every language.

## 1. Inputs, scope, and preservation

Each language workflow identifies these paths:

- its retained historical research input at `../sources/pitfalls-<language>/<language>.md`;
- its catalog at `../../pitfalls/<language>/<language>-pitfalls-catalog.md`;
- its rules at `../../pitfalls/<language>/<language>-pitfalls-rules.md`;
- its examples at `../../pitfalls/<language>/examples/`;
- its per-entry provenance ledger at `../sources/pitfalls-<language>.md`.

Read the shared [catalog-family specification](../catalog-family-spec.md), the language workflow, the historical input, every existing derived artifact, its source ledger, and applicable repository instructions before working.

The historical input is retained evidence, not a completeness boundary. Do not modify it. Treat existing catalog identifiers, canonical names, categories, impact values, consensus values, rules, and example filenames as stable. Do not delete, rename, renumber, move, merge, or silently replace an entry. Add a category only when no existing location fits. When materially correcting an entry, update its catalog record, rule, example, and ledger record together.

Work on one language only. Do not modify another language's source input, catalog, rules, examples, or ledger while running an individual workflow.

## 2. Research objective

Build an as-comprehensive-as-practicable, source-backed catalog of language-specific pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms. Include recommendations only when the language, its specified runtime behavior, standard library, tooling, or broadly applicable ecosystem practice gives the recommendation a material language-specific consequence.

Research broadly. Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery. Search beyond conventional best-practice lists and follow terminology, limitations, edge cases, and related sources discovered during research.

For every candidate:

1. Establish a distinct failure mode or preferred practice with a material correctness, reliability, security, maintenance, performance, portability, or operational consequence.
2. Verify the candidate's name, mechanism, scope, and version or environment limits through direct authoritative sources where feasible.
3. Compare it with existing canonical names and aliases. Merge genuine duplicates, but retain entries whose condition, mechanism, consequence, or remedy materially differs.
4. Record direct supporting sources and any important uncertainty in the per-entry ledger before considering the entry complete.
5. Stop only when further research produces primarily duplicates, weakly supported claims, minor style preferences, framework-specific advice without a broadly applicable language consequence, or findings outside scope.

Prefer language specifications, official language and standard-library documentation, official tool and runtime documentation, release notes, security guidance, and maintainers' documented guidance. Use rigorous practitioner sources only when primary sources do not adequately establish the recommendation. Do not treat popularity, repetition, or search ranking as consensus.

## 3. Impact, consensus, and provenance

Every catalog entry has these independent metadata values:

- `impact: high|medium|low` measures the material consequence of misuse for correctness, reliability, security, maintenance, performance, portability, or operations.
- `consensus: high|medium|low` measures the strength and breadth of authoritative support for the recommendation.

A high-impact issue may have low consensus, and a high-consensus recommendation may have low impact. Include materially useful disputed practices only when the ledger describes the disagreement and the catalog definition does not claim more certainty than the evidence supports.

Maintain `../sources/pitfalls-<language>.md` with exactly one `## <index> <canonical name>` section per catalog entry. Each section must include direct source links, a concise statement of what each source establishes, and version, runtime, security, or consensus limitations when relevant. Keep sources, citations, URLs, research notes, and source-label explanations out of the catalog, rules, and examples.

## 4. Catalog, examples, and rules

Build or update the catalog first. It must have the language-specific title and this exact one-line declaration immediately below it:

```markdown
_Entry format: <index> **<canonical name>** _(impact: [high|medium|low]; consensus: [high|medium|low])_ - <concise definition>._
```

Organize entries under descriptive subject-matter headings, never by impact or consensus. Every entry occupies exactly one physical line:

```markdown
<index> **<canonical name>** _(impact: <high|medium|low>; consensus: <high|medium|low>)_ - <concise definition>.
```

Definitions state the hazardous or preferred behavior and its material consequence. Include a condition, runtime, or version boundary when its omission would make the guidance overbroad. Use only lowercase metadata values.

After the catalog is stable, create exactly one example file for each canonical entry at:

```text
../../pitfalls/<language>/examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
```

Each example must have a matching title and catalog identifier, one realistic language-specific scenario, complete coherent preferred and hazardous forms for the same scenario, an explanation of the concrete consequence, and a boundaries-and-distinctions section. Use the language's normal Markdown fence label. Do not use pseudocode or cite sources in examples.

Only after catalog and examples are complete, derive the rules file. Its title is `# <Language> Pitfalls Rules`; its `##` and `###` headings exactly mirror the catalog in the same order; and each entry is one physical line:

```markdown
<index> **<canonical name>** - <concise, actionable, context-aware rule>
```

Rules must say what to avoid or prefer, the condition in which it matters, and the outcome protected. They must not repeat impact, consensus, definitions, citations, URLs, source notes, code, tables, or introductory prose.

## 5. Validation and handoff

Before handoff, verify that:

1. Every catalog identifier and canonical name is unique, stable, and on one physical line.
2. Every catalog entry uses only the declared lowercase `impact` and `consensus` values.
3. The catalog contains no citations, URLs, or source labels, while every entry has exactly one matching source-ledger section.
4. Every catalog entry has exactly one matching example filename, title, and catalog identifier.
5. Every example contains the required scenario, preferred form, hazardous form, explanation, and boundaries section.
6. Rules headings match catalog headings exactly and in order.
7. Rules contain exactly one matching `(index, canonical name)` pair for every catalog entry, with no duplicates, omissions, or alias-only rules.
8. No files outside the selected language's catalog family and source ledger were modified.

Report catalog, rule, example, and source-ledger counts; the research coverage; validation performed; and material evidence limitations.
