# Build and Maintain the AI Coding Smells Catalog Family

Research, build, and maintain the evidence-backed catalog family for AI coding smells:

```text
../../ai-smells/ai-smells-catalog.md
../../ai-smells/ai-smells-rules.md
../../ai-smells/examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
../sources/ai-smells.md
```

The catalog is the authoritative inventory. Rules and examples are derived from it. `../sources/ai-smells/ai-smells-complete.md` is a retained historical research input. `../sources/ai-smells.md` is the maintained per-entry provenance ledger. Do not create or maintain other operational files for this catalog family.

## 1. Inputs and preservation

Read before working:

- `../catalog-family-spec.md`
- `../sources/ai-smells/ai-smells-complete.md`
- `../../ai-smells/ai-smells-catalog.md`, when it exists
- `../../ai-smells/ai-smells-rules.md`, when it exists
- Every file under `../../ai-smells/examples/`, when the directory exists
- `../sources/ai-smells.md`, when it exists
- Applicable repository instructions

Treat existing catalog identifiers, canonical names, evidence labels, categories, rules, and examples as stable. Do not delete, rename, renumber, move, merge, or silently replace an existing canonical entry. Add an entry or a category only when research establishes a materially distinct failure mode that is not already represented by an existing canonical name or alias. Update matching rules, examples, and source-ledger records whenever an entry is materially corrected.

Do not modify `../sources/ai-smells/ai-smells-complete.md`. It remains a historical taxonomy and research record, not a completeness boundary for future work.

## 2. Research objective and method

Build an as-comprehensive-as-practicable, evidence-backed catalog of recurring ways AI coding systems, coding agents, or AI-generated code can fail. Include failure modes affecting task interpretation, repository grounding, APIs and dependencies, implementation correctness, maintainability, abstraction, testing, security, operations, integration, and agent workflow.

Research broadly without using the current catalog or a predetermined taxonomy as the search space. Discover candidate categories from evidence. Search authoritative and high-quality sources including empirical research on code generation and coding agents, repository and benchmark studies, official security and software-engineering guidance, vulnerability research, package and dependency studies, and well-established engineering literature.

For every candidate:

1. Establish that it is a recurring, named or clearly distinguishable failure mode with a material coding, review, security, or maintenance consequence.
2. Check current canonical names, definitions, aliases, and nearby entries before adding it. Merge only genuine duplicates; preserve separate entries when their cause, boundary, or remediation differs materially.
3. Use direct evidence where it supports the specific failure. Do not infer prevalence, AI specificity, or causal claims merely because a conventional software-engineering smell is plausible.
4. Record enough direct sources in `../sources/ai-smells.md` for a maintainer to audit the evidence and update the entry later.
5. Stop only when further research produces primarily duplicates, weakly supported variants, ordinary language-specific issues without an AI-coding connection, or findings outside this catalog's scope.

Keep the distinction between empirical AI evidence and conventional engineering guidance explicit. The catalog is a review and reasoning aid, not a claim that every listed smell is uniquely or disproportionately caused by AI.

## 3. Evidence metadata and source ledger

Every entry has one `evidence` metadata value. Use these values consistently:

| Value | Meaning |
| --- | --- |
| `e` | Direct empirical evidence of the failure or a close equivalent in AI-generated code. |
| `a` | Evidence from coding-agent benchmarks or real coding-agent sessions. |
| `se` | Established software-engineering smell included as relevant guidance without direct evidence for that exact AI-specific subtype. |
| `e/a` | Both direct empirical and agent-observed evidence. |
| `e/se` | Direct family-level empirical evidence plus a conventional smell formulation. |
| `a/se` | Agent-observed evidence plus a conventional smell formulation. |

Assign the narrowest supported value. Do not upgrade `se` to `e`, `a`, or a combined value without evidence. Do not downgrade an existing label without reviewing its source-ledger record.

Maintain `../sources/ai-smells.md` with one section for every canonical catalog entry. Each section must use the matching identifier and canonical name, list direct source URLs, and state any material evidence limitation or distinction. Keep URLs, citations, source names, and research notes out of the catalog, rules, and examples.

## 4. Catalog requirements

Create or update `../../ai-smells/ai-smells-catalog.md` first.

1. Use the title `# AI Coding Smells Catalog`.
2. Immediately below the title, include this one-line declaration:

   ```markdown
   _Entry format: <index> **<canonical name>** _(evidence: [e|a|se|e/a|e/se|a/se])_ - <concise definition>._
   ```

3. Organize entries under descriptive `##` headings that describe failure domains, not evidence strength or priority. Preserve existing category placement unless research establishes that it is materially wrong. Use `###` subcategories only when they improve navigation.
4. Assign each new entry a full hierarchical index that continues its containing category or subcategory without changing existing indexes.
5. Write every entry on exactly one physical line:

   ```markdown
   <index> **<canonical name>** _(evidence: <value>)_ - <concise definition>.
   ```

6. Keep definitions concise, concrete, and faithful to the evidence. Include a material condition or boundary when omitting it would make the entry overbroad.
7. Do not include citations, URLs, source names, source-label explanations, research narrative, tables, or introductory prose beyond the title and entry-format declaration.

## 5. Example requirements

After the catalog inventory is stable, create or update exactly one file per canonical entry:

```text
../../ai-smells/examples/<full-index>-<canonical-name-in-lowercase-kebab-case>.md
```

Use this structure:

````markdown
# <Canonical Name>

## 1. Catalog record

- **Catalog identifier:** <full index>
- **Evidence:** <catalog evidence value>
- **Definition:** <catalog-backed definition>

## 2. Scenario

### 2.1 Context

<One realistic coding-agent, repository, code-review, or implementation situation.>

### 2.2 Safer approach

<The investigation, implementation, review, or verification behavior that avoids the failure.>

### 2.3 Failure mode

<The same situation handled in a way that exhibits the named failure.>

### 2.4 Why this difference matters

<The concrete consequence of the named failure.>

## 3. Boundaries and distinctions

<The condition, exception, tradeoff, or nearby distinction that prevents overbroad advice.>
````

Use coherent code blocks only where code directly demonstrates the failure. Use concise prose, commands, diffs, configuration excerpts, or review scenarios where the failure concerns investigation, task interpretation, testing, workflow, security, or operations. Do not force every entry into a code example. Keep safer and failure forms focused on the same scenario. Do not add citations or URLs to examples.

## 6. Rules requirements

Create or update `../../ai-smells/ai-smells-rules.md` only after catalog and examples are complete.

1. Use the title `# AI Coding Smells Rules`.
2. Mirror every catalog `##` and `###` heading exactly and in the same order.
3. Under each matching category or subcategory, include exactly one rule per canonical catalog entry in catalog order:

   ```markdown
   <index> **<canonical name>** - <concise, actionable, context-aware rule>
   ```

4. State what to avoid or verify, the condition in which it matters, and the outcome it protects.
5. Keep rules short, independently useful, and conditional where the catalog or example establishes a boundary or tradeoff.
6. Do not include evidence metadata, definitions, citations, URLs, source notes, code, tables, checklists, or introductory prose beyond the title and required headings.

## 7. Execution and validation

Work in stages: research and stabilize the catalog inventory, update the source ledger, create or update examples, derive rules, then validate the complete family. When subagents are available, divide examples and rule drafting into mutually exclusive, contiguous catalog sections. Do not assign the same index or target file to more than one subagent. The primary agent integrates all drafts and performs final validation.

Before handoff, verify that:

1. Every catalog identifier and canonical name is unique and every entry is one physical line.
2. Every entry has one valid lowercase `evidence` value and a matching source-ledger record.
3. The catalog contains the required title and entry-format declaration, with no citations, URLs, or source labels.
4. Existing entries retain their stable identifiers, canonical names, evidence values, and category placement unless a documented correction is necessary.
5. Every catalog entry has exactly one example file with matching index, canonical-name slug, title, and catalog identifier.
6. Each example has the required catalog record, context, safer approach, failure mode, explanation, and boundaries section.
7. Rules headings exactly match catalog headings in order.
8. Rules contain exactly one matching `(index, canonical name)` pair for every catalog entry, with no duplicates or omissions.
9. No rules repeat evidence metadata, source information, or catalog definitions.

Report the catalog, rule, example, and source-ledger counts; validation performed; research coverage; and material evidence limitations.
