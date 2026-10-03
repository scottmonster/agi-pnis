Yes — with your correction, the architecture is cleaner if `episode.md` stays purely as the shared standard, while the two record types each get their own explicit procedural entry point.

The updated structure should be:

```text
SHARED STANDARD
episode.md
    ↓
DOMAIN STANDARDS
judgement-record.md
failure-record.md
failures.md
    ↓
DOMAIN PROCEDURES / ENTRY POINTS
judgement-record/SKILL.md
failure-record/SKILL.md
```

The important change is that there is **no `episode/SKILL.md`**. `episode.md` is consulted by the two skills as a shared standard.

### Responsibilities

```text
episode.md
  = shared normative standard

  Defines:
  - what an episode is
  - what material means
  - violation
  - concern
  - Episode Investigation
  - when an investigation is required
  - general investigation requirements
  - shared episode invariants
  - shared rules applicable to both judgement and failure records
```

```text
judgement-record.md
  = judgement record standard

  Defines:
  - JR
  - JUR
  - user-triggered vs agent-triggered
  - user-activity vs agent-activity
  - violation / concern status rules
  - when JR vs JUR is required
  - required judgement record data
  - immutability / linkage requirements
```

```text
judgement-record/SKILL.md
  = judgement operational entry point

  Handles:
  - user-triggered judgement requests
  - agent-detected material judgements
  - determining whether JR/JUR applies
  - applying episode.md
  - determining whether an Episode Investigation is required
  - performing that investigation when required
  - gathering required judgement data
  - creating the JR/JUR according to judgement-record.md
```

Then failures:

```text
failures.md
  = failure catalog

  Defines:
  - failure triggers
  - failure types
  - type-specific record data
  - type-specific evidence/information requirements
  - applicable standards when relevant
```

```text
failure-record.md
  = failure record standard

  Defines:
  - FR
  - FUR
  - failures are always material
  - failures are always violations
  - when FR vs FUR is required
  - required common failure-record data
  - linkage / immutability requirements
```

```text
failure-record/SKILL.md
  = failure operational entry point

  Handles:
  - automated failure signals
  - manual failure reports
  - failures detected during another review/process
  - consulting failures.md to match failure trigger/type
  - applying episode.md
  - determining whether an Episode Investigation is required
  - performing that investigation when required
  - gathering common + failure-type-specific data
  - creating FR/FUR according to failure-record.md
```

The resulting execution model is much simpler:

```text
JUDGEMENT PATH

judgement trigger
    ↓
judgement-record/SKILL.md
    ├─ consult episode.md
    ├─ consult judgement-record.md
    ├─ determine JR/JUR
    ├─ determine investigation requirement
    ├─ investigate if required
    └─ create JR/JUR
```

```text
FAILURE PATH

failure signal/report/detection
    ↓
failure-record/SKILL.md
    ├─ consult failures.md
    │    └─ match failure type + required data
    ├─ consult episode.md
    ├─ consult failure-record.md
    ├─ determine FR/FUR
    ├─ determine investigation requirement
    ├─ investigate if required
    └─ create FR/FUR
```

This also solves the `failures.md` problem you were wrestling with. A failure definition can live entirely in one place:

```md
### Failure: Incorrect Rule Application

**Trigger**
- A materially applicable rule was applied incorrectly.

**Record Data**
- applicable rule
- expected behavior
- observed behavior
- material effect

**Additional Investigation Data**
- cause/explanation
- prevention loci
```

The `failure-record/SKILL.md` matches that definition first. It does **not** need to collect everything immediately. It retains the matched failure definition, applies `episode.md`, and if an investigation is required, uses the same definition to know what additional information must be established.

So adding a failure remains a **one-place change in `failures.md`**.

### What I would do next

1. **Remove `episode/SKILL.md` entirely** if you've started one.
2. Strip procedural routing out of `episode.md`. Keep only shared definitions, requirements, and invariants.
3. Put all JR/JUR normative rules into `judgement-record.md`.
4. Put the actual judgement workflow into `judgement-record/SKILL.md`.
5. Put all FR/FUR normative rules into `failure-record.md`.
6. Keep `failures.md` as the extensible catalog containing each failure's trigger/type-specific data requirements.
7. Put the actual failure workflow into `failure-record/SKILL.md`.
8. Make both skills explicitly say they **MUST apply `episode.md`** when determining record/investigation requirements.

The design principle becomes:

> **`episode.md` defines the shared rules for episodes.**
> **`*-record.md` defines the rules for that record family.**
> **`*/SKILL.md` is the operational entry point that applies those standards.**
> **`failures.md` is the extensible failure catalog used by the failure-record skill.**

And importantly, you now have **two intentional entry points**, not one generic one:

```text
judgement → judgement-record/SKILL.md
failure   → failure-record/SKILL.md
```

That is probably preferable here because the agent knows immediately **what kind of workflow it is entering**, instead of going through a generic episode router and then rediscovering the domain.
