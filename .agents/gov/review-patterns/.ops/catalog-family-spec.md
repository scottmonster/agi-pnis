# Catalog Family Specification

## 1. Purpose

This specification defines a reusable Markdown catalog family. A family records a stable inventory of canonical entries, actionable rules derived from those entries, and one teaching example for each entry. It supports topic-specific classifications and metadata while preserving a consistent layout, identifier system, and one-line catalog-entry format.

## 2. Directory layout

```text
<repository>/
├── .ops/
│   ├── catalog-family-spec.md
│   ├── rule-authoring-guide.md
│   ├── workflows/
│   │   └── <topic>.md
│   ├── sources/
│   │   ├── <topic>.md
│   │   └── <topic>/
│   │       └── ...retained source captures and supporting material...
│   └── archive/
│       └── ...historical notes and retired material...
└── <topic>/
    ├── <topic>-catalog.md
    ├── <topic>-rules.md
    └── examples/
        └── <full-index>-<canonical-name-in-lowercase-kebab-case>.md
```

`<topic>-catalog.md` is the authoritative entry inventory. `<topic>-rules.md` and `examples/` are derived artifacts. `.ops/workflows/<topic>.md` defines the active research, build, and validation workflow for that topic. `.ops/sources/<topic>.md` holds its provenance records, and `.ops/sources/<topic>/` optionally preserves source captures or supporting material that a ledger record needs. `.ops/archive/` contains historical material only and is not active instruction. The catalog itself contains no citations, URLs, or source labels.

## 3. Catalog structure

Each catalog contains:

1. A title in the form `# <Topic> Catalog`.
2. One `Entry format` declaration immediately below the title.
3. Descriptive `##` category headings and optional `###` subcategory headings.
4. One canonical entry per physical Markdown line under the applicable subcategory.

Category headings describe the subject matter, not a priority ranking. Do not use impact, consensus, or another metadata field as the hierarchy unless that ranking is the catalog's actual primary navigation need.

## 4. Canonical entry format

Every entry uses this grammar on exactly one physical line:

```text
<full-index> **<canonical name>** [_(<optional classification>; <key>: <value>; also known as: <alias 1>, <alias 2>)_] - <concise definition>. _Related:_ <canonical name>, <canonical name>.
```

Square brackets in the grammar mean optional syntax and are not written in catalog entries. Only `<full-index>`, `<canonical name>`, and `<concise definition>` are required. The entire parenthetical metadata group, classification, keyed metadata, the `also known as` clause, and the `_Related:_` clause are independently optional.

When present, parenthetical metadata follows these rules:

1. Classification is an optional, unkeyed first item, retained for compatibility with the existing design-concepts format.
2. Every other metadata item uses a lowercase `key: value` form.
3. Separate metadata items with `; `.
4. Place catalog-defined metadata keys in the order declared by the entry format.
5. Place `also known as` last.

An alias is not a canonical entry. Related concepts must refer to canonical names in the same catalog.

Each catalog declares its actual entry format in one physical line immediately below its title. This declaration is the authority for permitted metadata keys and controlled values in that catalog. Use this form:

```markdown
_Entry format: <index> **<canonical name>** _(classification; <key>: <allowed values>; also known as: aliases)_ - <concise definition>. _Related:_ canonical concepts._
```

For a design-concepts catalog, the declaration can be:

```markdown
_Entry format: <index> **<canonical name>** _(classification; also known as: aliases)_ - <concise definition>. _Related:_ canonical concepts._
```

For a TypeScript pitfalls catalog, it can preserve the required ratings directly:

```markdown
_Entry format: <index> **<canonical name>** _(classification; impact: [high|medium|low]; consensus: [high|medium|low]; also known as: aliases)_ - <concise definition>. _Related:_ canonical concepts._
```

Examples:

```markdown
1.1.0 **Plain entry** - State a concise definition without optional metadata.
1.1.1 **Guard Clauses** _(Refactoring; also known as: replace nested conditional with guard clauses)_ - Handle exceptional or invalid cases at the start, leaving the normal path flat. _Related:_ Early Exit.
1.1.1 **Enable the strict family** _(Configuration recommendation; impact: high; consensus: high)_ - Enable the strict compiler option family as the normal baseline for type safety.
1.1.2 **Use exact optional property types** _(impact: medium; consensus: high; scope: public data contracts)_ - Preserve the distinction between an absent optional property and one explicitly set to undefined.
1.1.3 **Experimental syntax support** _(stability: experimental; audience: library authors; introduced: 5.2)_ - Use the syntax only where the supported compiler and runtime baseline is explicit.
```

## 5. Metadata

The catalog's `Entry format` declaration defines all additional metadata. Do not add a metadata key unless it is stable, useful for consumers of the catalog, consistently meaningful for every applicable entry, and has controlled values or a clear format.

When a key's meaning needs research-method detail, define that detail in the topic's `.ops/workflows/<topic>.md`. Keep the catalog declaration compact and readable.

## 6. Rules file

The rules file mirrors the catalog's category and subcategory headings in the same order, with the title `# <Topic> Rules`.

Under every matching subcategory, include exactly one rule for each canonical catalog entry in catalog order:

```text
<full-index> **<canonical name>** - <concise, actionable, context-aware rule>
```

Rules do not repeat catalog classifications, aliases, metadata, definitions, sources, or related-concept lists. They use examples to preserve boundaries and tradeoffs. A rule must not present a conditional recommendation as universally required.

## 7. Example files

Create one file per canonical entry at:

```text
examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
```

Every example identifies its canonical name and catalog identifier, explains one realistic scenario, contrasts a preferred form with a problematic or less suitable form, explains the relevant mechanism, and states boundaries or distinctions.

The topic's `.ops/workflows/<topic>.md` determines the example details. Code-design instructions can require coherent code, structural references, and a less-maintainable form. Pitfalls instructions can require a hazardous form, a preferred form, consequences, and source-backed caveats. Do not impose code or structural-reference requirements on a non-code catalog unless its instructions require them.

## 8. Stability and maintenance

After publication, treat an entry's identifier and canonical name as stable. Treat a classification as stable when the catalog uses one. Add new entries without renumbering, moving, merging, or silently replacing existing entries. Record alternate names as aliases unless they identify a materially distinct canonical entry.

When a canonical entry changes, update its catalog record, its rule, its example, and the corresponding record in `.ops/sources/<topic>.md` as applicable.

## 9. Validation contract

Before handoff, verify that:

1. Catalog identifiers are unique and every entry is one physical line.
2. Every entry conforms to the catalog's declared entry format and uses only the declared metadata.
3. Canonical names, aliases, related references, and metadata values satisfy the declared format.
4. Rules headings match catalog headings exactly and in order.
5. Rules contain exactly one matching `(index, canonical name)` pair for every catalog entry, with no alias-only rules.
6. Example filenames, titles, and identifiers map one-to-one to canonical catalog entries.
7. The catalog contains no citations, URLs, or source labels, while required provenance remains under `.ops/sources/`.
