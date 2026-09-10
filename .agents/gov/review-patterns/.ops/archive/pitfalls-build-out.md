# Build Language Pitfall Catalog Families

Build a catalog family for every top-level Markdown source file in `../`. A source file named `<lang>.md` produces these outputs and no changes to the source file:

```text
../<lang>/<lang>-pitfalls-catalog.md
../<lang>/<lang>-pitfalls-rules.md
../<lang>/examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
```

For example, `../typescript.md` produces `../typescript/typescript-pitfalls-catalog.md`, `../typescript/typescript-pitfalls-rules.md`, and one TypeScript example file for every canonical finding.

## 1. Inputs and scope

Read before creating outputs:

- `../../spec.md`
- Every top-level `../*.md` source file
- Applicable repository instructions

Treat every top-level Markdown file under `../` as one language source, with `<lang>` derived from its lowercase filename without `.md`. The current source files are Bash, Go, JavaScript, Python, and TypeScript research records, but inventory the directory instead of hard-coding that list.

Each source record contains research instructions and assistant commentary followed by findings with these fields:

```text
Name:
Category:
Impact:
Consensus:
Description:
Why:
Source URL:
```

Use only the completed finding records, not the surrounding prompt or assistant commentary. Do not omit, merge, rename, or invent findings. Preserve every source record unchanged, including its source URLs and citations. Do not modify `../../spec.md`, any `../<lang>.md` source file, or files outside the requested language output directories.

## 2. Catalog requirements

Create `../<lang>/<lang>-pitfalls-catalog.md` as the authoritative inventory for that language.

1. Use the title `# <Language> Pitfalls Catalog`, with the language name in normal display form, such as `# TypeScript Pitfalls Catalog`.
2. Immediately below the title, add this one-line declaration:

   ```markdown
   _Entry format: <index> **<canonical name>** _(impact: [high|medium|low]; consensus: [high|medium|low])_ - <concise definition>._
   ```

3. Organize findings by technical subject matter, not by impact or consensus. Use descriptive `##` domain headings and `###` subcategory headings. Preserve each source finding's `Category` as a subcategory heading or as a clearly equivalent technical grouping. Do not use High, Medium, or Low Impact as headings.
4. Assign each finding a stable, full hierarchical index such as `1.2.3`. Number entries in their final catalog order. Do not reuse an index.
5. Write each finding on exactly one physical line:

   ```markdown
   <index> **<Name>** _(impact: <high|medium|low>; consensus: <high|medium|low>)_ - <concise definition>.
   ```

6. Copy `Impact` and `Consensus` into lowercase metadata values exactly. Use `Description` to write the concise definition. Retain a material boundary or qualification from `Why` when needed to prevent an overbroad interpretation.
7. Do not include source URLs, citations, original `Why` fields, research commentary, tables, or introductory prose beyond the title and required entry-format declaration. The unchanged source Markdown file remains the provenance record.

## 3. Example requirements

Create exactly one file per canonical catalog entry under `../<lang>/examples/`. Name every file:

```text
<full-index>-<canonical-name-in-lowercase-kebab-case>.md
```

Each file must contain this structure:

````markdown
# <Canonical Name>

## 1. Catalog record

- **Catalog identifier:** <full index>
- **Impact:** <high, medium, or low>
- **Consensus:** <high, medium, or low>
- **Definition:** <concise catalog-backed definition>

## 2. Example

### 2.1 Scenario

<One or two sentences describing one realistic language-specific situation.>

### 2.2 Preferred form

```<language>
<Complete, coherent preferred example.>
```

### 2.3 Hazardous form

```<language>
<Complete, coherent example that exhibits the same finding.>
```

### 2.4 Why this difference matters

<Explain the specific failure mode or maintenance consequence.>

## 3. Boundaries and distinctions

<State the material condition, exception, or tradeoff that prevents the rule from becoming universal.>
````

Use the language's normal Markdown fence label: `bash`, `go`, `javascript`, `python`, or `typescript`. Use actual syntactically coherent code, not pseudocode. Keep the preferred and hazardous forms focused on the same scenario and the same finding. Define or clearly provide every identifier used. Do not add source URLs or citations to examples.

## 4. Rules requirements

Create `../<lang>/<lang>-pitfalls-rules.md` only after the catalog and examples are complete.

1. Use the title `# <Language> Pitfalls Rules`.
2. Mirror every `##` and `###` heading from the matching catalog exactly and in the same order.
3. Under each matching subcategory, include exactly one rule for every canonical catalog entry, in catalog order:

   ```markdown
   <index> **<canonical name>** - <concise actionable rule>
   ```

4. Write direct, context-aware guidance. For hazards, identify what to avoid and the condition or risk. For preferred practices, state when to use the practice and the outcome it protects.
5. Keep rules short, independently useful, and conditional where the source finding establishes an exception, environment constraint, or tradeoff.
6. Do not copy impact, consensus, classifications, definitions, citations, URLs, source notes, code, tables, or introductory prose into rules.

## 5. Delegation and validation

Inventory and parse every source record before creating outputs. Divide each language's findings into mutually exclusive, contiguous catalog sections. When subagents are available, delegate one section and its example files per subagent, with no overlapping indexes or paths. The primary agent must assign final identifiers, integrate the catalog, create the rules file, and validate the complete family.

Before finishing each language, verify that:

1. Every source finding appears exactly once as a canonical catalog entry.
2. Every catalog entry has lowercase `impact` and `consensus` metadata with only `high`, `medium`, or `low` values.
3. Every catalog entry is one physical line and has a unique index and canonical name.
4. The catalog contains the required entry-format declaration and no citations or URLs.
5. Rules headings exactly match catalog headings in order.
6. Rules have exactly one matching `(index, canonical name)` pair per catalog entry, with no duplicate or alias-only rules.
7. Every catalog entry has exactly one example file with the matching index, canonical-name slug, title, and catalog identifier.
8. Each example has the required scenario, preferred form, hazardous form, explanation, and boundaries section.
9. No source file was modified and no output was created outside its `../<lang>/` directory.

Report the source finding count, catalog entry count, rule count, example count, and validation results for every language.
