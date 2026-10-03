# Routing Failure Definitions

Yes — that design can work well, and it avoids duplicating failure definitions.

The key is to let each failure definition in `failure-catalog.md` contain both the **trigger** and the **data contract**, without requiring that the data be collected at the moment the trigger fires.

For example:

## 1. Failure: Incorrect Rule Application

**Trigger**

- A rule was applied incorrectly in a way that materially affected the result.

**Record Data**

- `applicable_rule`
- `expected_behavior`
- `observed_behavior`
- `material_effect`
- `source`

**Investigation Data**

- `contributing_factors`
- `prevention_loci`
- `recommended_corrective_action`

## 2. Flow

```text
Review Trigger
  → failure-catalog.md
      → evaluate failure triggers
      → if matched:
          → identify failure type
          → retain reference to matched failure definition
  → episode-record.md
      → determine:
          - record required?
          - investigation required?
      → if investigation required:
          → perform Episode Investigation
          → use matched failure definition's Investigation Data requirements
      → if record required:
          → use matched failure definition's Record Data requirements
          → route to failure-record.md
              → FR / FUR
```

So `failure-catalog.md` has two roles, both tied to the same failure definition:

```text
FAILURE DEFINITION
├─ Trigger               ← used before episode-record.md
├─ Record Data           ← used when creating FR/FUR
└─ Investigation Data    ← used only if episode-record.md requires investigation
```

That means adding a new failure only requires adding one block to `failure-catalog.md`.

For example:

## 3. Failure: Unsupported Assumption

**Trigger**

- A materially relied-upon assumption is found to lack required support.

**Record Data**

- `assumption`
- `basis_used`
- `missing_support`
- `material_effect`

**Investigation Data**

- `origin_of_assumption`
- `available_evidence`
- `prevention_loci`
- `recommended_corrective_action`

No changes to `episode-record.md` are needed because `episode-record.md` does not care what the failure type is. It only cares about the generic outputs:

- detected episode
- `failure_type`
- `matched_definition`
- `record_required?`
- `investigation_required?`

Then the matched failure definition acts almost like a **schema/config object** that travels through the episode.

## 4. Suggested Routing

```text
Review Trigger
  → failure-catalog.md
      → detect/classify failure
      → return:
          - failure type
          - matched failure definition
          - available trigger evidence
  → episode-record.md
      → determine record/investigation requirements
      → if investigation required:
          → Episode Investigation
              → satisfy generic investigation requirements
              → satisfy matched failure's Investigation Data
      → if record required:
          → failure-record.md
              → create FR/FUR using:
                  - generic FR/FUR fields
                  - matched failure's Record Data
                  - investigation results, if any
```

This also gives you a useful distinction inside `failure-catalog.md`:

> **`Record Data` defines what the failure record must preserve. It does not imply that an investigation is required to obtain that data.**

Some fields may already be known from the triggering event. Others may be populated by an investigation if one is required.

You could even make each failure definition extremely compact:

## 5. Compact Failure Definition

### 5.1 Incorrect Rule Application

**Trigger:** A rule is materially applied incorrectly.

**Record**

- `applicable_rule`
- `expected_behavior`
- `observed_behavior`
- `material_effect`

**Investigate**

- `contributing_factors`
- `prevention_loci`
- `recommended_corrective_action`

## 6. Architecture

- **`failure-catalog.md`** = failure catalog + schemas
- **`episode-record.md`** = process decision engine
- **Investigation** = evidence generation
- **`failure-record.md`** = persistence rules

That seems closest to what you're trying to achieve without forcing the same failure to be defined in two places.
