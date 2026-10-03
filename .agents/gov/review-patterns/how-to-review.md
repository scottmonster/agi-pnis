# How to Review with Review Patterns

## 1. Purpose and scope

Use this library during code reviews to identify applicable patterns, verify material problems, and select useful prevention rules. Load only the material needed for the review. Do not include the entire library in routine task context or treat every entry as a required check.

The library helps interpret code; a pattern match alone does not establish a violation. Applicable requirements, actual behavior, exceptions, and evidence determine whether a finding is justified.

## 2. Size the review

Select checks based on the changed behavior, affected scope, and potential impact. Line count is a useful signal, not the deciding factor.

- Start with the requested change, its purpose, and enough surrounding code to understand its effects.
- Give small, local changes a focused review. Do not inspect unrelated components or pattern families without a reason.
- Broaden the review for changes to shared behavior, public contracts, authorization, sensitive data, persistence, concurrency, or recovery. A two-line change can affect an important boundary.
- Follow callers, dependencies, configuration, and tests when they are needed to establish the change's effects. Expand further when evidence reveals a related risk.
- Stop expanding when the relevant behavior and findings are sufficiently established. Review scope is not a mandate to improve the whole codebase.

## 3. Select and load patterns

Use filenames and category headings to locate relevant material, then read the selected sections. Search terms help discovery but do not replace understanding the changed behavior.

| Material | When to use it |
|---|---|
| `pitfalls/<language>/` | Language-specific behavior affected by the change |
| `design-concepts/` | Changes to responsibilities, boundaries, dependencies, or design |
| `ai-smells/` | Potential mistakes in interpreting, implementing, or validating the request |
| `misc/` | Relevant concerns not covered by the other families |

Within a selected family:

- Use `*-rules.md` to locate concise checks relevant to the change.
- Read the corresponding `*-catalog.md` entry to understand the pattern and its distinctions. The catalog owns the entry inventory; rules and examples are derived from it.
- Read the matching `examples/` file when the explanation, boundaries, or exceptions are needed to assess the code.
- Consult `.ops/sources/` only when provenance or supporting evidence is needed. `.ops/archive/` is historical material, not active instruction. Build workflows are for maintaining the library, not routine code review.

Reference a pattern by its family, entry index, and file link. An index alone is not unique across the library. A review-pattern identifier is not automatically an episode failure identifier.

## 4. Assess a pattern match

For each candidate issue, establish:

- The expected behavior and the applicable requirement or convention that establishes it.
- The observed behavior, with the most specific code location available.
- The conditions under which the problem occurs and its practical impact.
- Relevant exceptions, tradeoffs, and contrary evidence.

Use inspection or focused verification as needed. Do not infer a violation from a preference, example, or superficial resemblance. Apply the [findings guide](../guides/findings-guide.md): report evidenced nonconformances as findings and advisable improvements as recommendations. Label uncertainty and material limits explicitly. Combine duplicate instances unless their causes or impacts differ materially.

## 5. Record failures and decisions

Use the [episode skill](../../skills/episode/SKILL.md) when a confirmed material failure or qualifying judgement needs a durable record. Ordinary review observations and tentative recommendations do not automatically qualify.

| Outcome | Record handling |
|---|---|
| Confirmed material failure | Create an FR, or an FUR for a material update to an existing failure record. |
| Possible problem or optional improvement | Report the uncertainty or recommendation; do not create an FR solely from a pattern match. |
| Material, non-obvious decision governing future work | Create a JR, or a JUR when materially changing an existing judgement. |

Whether a prevention rule exists does not determine whether a failure occurred. A confirmed failure can lack a specific written rule; an existing rule can describe a pattern that is acceptable in the reviewed context.

The current episode skill requires a match in its own [failure catalog](../../skills/episode/src/failures.md). Match the definition's trigger and exclusions, not just its name. If none matches, preserve the evidenced finding and follow the skill's direction requirement before creating a classified record. Do not invent a failure ID or silently use a review-pattern index as one.

Investigate confirmed failures using the episode rules. Link applicable review patterns as evidence or prevention guidance without copying their full contents into the record.

## 6. Decide whether prevention should change

If an existing rule addresses the failure, reuse it and investigate why it did not prevent the problem. Consider applicability, clarity, loading, scope, and enforcement before adding more wording.

If guidance is missing or inadequate, propose a reusable rule only when it would prevent a material problem and its value exceeds its context and maintenance cost. Follow the [rule-authoring guide](.ops/rule-authoring-guide.md). Check for equivalent existing guidance and place the rule at the narrowest useful scope. Keep detailed review guidance in this library; promote only rules needed before review into implementation instructions.

Creating a rule and recording a failure are separate actions. A failure may warrant an FR and a linked JR when adopting its prevention rule is itself a qualifying judgement. Routine corrective wording does not automatically require a JR. Do not present a proposal as an adopted decision.

A review does not by itself authorize code fixes, new rules, or policy changes. Make those changes when the task authorizes them. When updating a catalog family, use its `.ops/workflows/` document and the [catalog family specification](.ops/catalog-family-spec.md) to keep the catalog, rule, and example consistent.

## 7. Report the review

Report material findings first, then useful recommendations. State the reviewed scope and any limits that affect reliance on the result. Link any episode records created and identify proposed prevention changes separately from adopted ones. If no material findings are established, say so without implying that every pattern in the library was checked.
