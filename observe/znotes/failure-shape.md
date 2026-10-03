### 2.1 incorrect-rule-application - Incorrect Rule Application

**Trigger**

A materially applicable rule, requirement, or constraint was applied incorrectly, and the application materially affected the result.

**Exclusions**

- The rule was ambiguous and the record shows a reasonable interpretation.
- The departure was immaterial.
- The issue is only an unverified concern.

**Record data**

- applicable_rule
- expected_behavior
- observed_behavior
- material_effect

**Investigation data**

- contributing_factors
- prevention_loci
- recommended_corrective_action

---

Use one compact Markdown block per failure. Treat it as a classification and data contract—not a full procedure or duplicate FR template.

## 2. Rules for the shape

- `failure_id` is the stable slug in the heading, such as `incorrect-rule-application`; do not use a numeric sequence.
- `Trigger` establishes classification. It should be concrete enough to decide whether the failure applies.
- `Exclusions` are optional but strongly recommended where a failure could otherwise be over-applied.
- `Record data` adds only failure-specific data. Shared FR fields—record ID, violation, evidence, impact, relationship, and status—belong in `failure-record.md`.
- `Investigation data` is collected only if `episode.md` requires an Episode Investigation.
- A required item that cannot safely be obtained does not block a record. Mark it unavailable and state the limitation; do not invent it.
- Keep claims, evidence, inference, and hypothesis distinct in the actual FR/FUR rather than embedding those distinctions in every catalog entry.

## 3. What to omit

Do not put these in each failure definition:

- Full record templates
- Routing instructions
- Tool, model, token, or harness requirements
- Severity scoring
- Root-cause conclusions
- Exhaustive examples or prevention guidance

Those either belong in `failure-record.md`, `episode.md`, or in the individual record/investigation.

This gives each failure exactly one editable home while keeping the catalog readable and harness-agnostic.