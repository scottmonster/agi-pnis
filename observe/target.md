# Episode-Record Rebuild Target

## 1. Objective

The active episode-record standards live in the single `.agents/skills/episode/` package. Its root `SKILL.md` is the only operational entry point; the five active standards live in `src/`.

This rebuild replaces the design of `observe/bad/episodes/`; it does not revise that directory in place. `observe/.archive/original/` is source material only. Do not restore its MJR/JFR model, required frontmatter, index convention, or large record model.

`tood.md` is the accepted simplification for the staged rebuild. Its schema uses compact YAML blocks as readable structural notation. Records may use Markdown sections, lists, or YAML. They do not require YAML frontmatter or a serialized format.

## 2. Completion boundary

The rebuild is complete when this active package exists:

```text
.agents/skills/episode/
  SKILL.md
  purpose.md
  agents/openai.yaml
  src/episode.md
  src/schema.md
  src/judgement-record.md
  src/failure-record.md
  src/failures.md
  tests/validate_templates.py
```

JR and JUR records are written to `.agents/records/judgements/`. FR and FUR records are written to `.agents/records/failures/`. The `episode` skill creates its record directory when needed; the repository does not retain empty record directories.

The historical and staged material remains outside the active skill package. It is preserved and is not a competing active policy source.

## 3. Shared standards

### 3.1 `episode.md`

Define material episode and materiality, Violation, Concern, Corrective Action, and Episode Investigation.

An Episode Investigation is a bounded, evidence-based inquiry into a detected episode that establishes expected and observed behavior, relevant context and impact, available explanations, and prevention loci. It is required for every Violation and Concern.

A completed Violation record includes or inherits at least one recommended Corrective Action established through its Episode Investigation. A Violation may be recorded before that action is known, but it remains incomplete until the action is established.

Define shared evidence, availability, limitation, safe-retention, relationship, and immutability rules. Failures are always material Violations. The applicable judgement standard determines JR and JUR status.

Do not put an operational workflow, skill, failure definition, report template, or record-family-specific rule in `episode.md`.

### 3.2 `schema.md`

Define a lightweight data dictionary with YAML code blocks for these groups:

```yaml
record:
  index:
judgement:
failure:
violation:
investigation:
corrective_actions:
update:
execution_context:
```

The common `record` group is small. Do not make `recorded_by`, `actors`, `context`, `evidence`, `limitations`, or `execution_context` universal required groups. They may appear only when material.

Use `record.index` as the quoted filename prefix. New JR and FR records receive the next unused three-digit root index. JUR and FUR records use their originating root index plus the next unused two-digit update index. Use `<index>-<record_type>-<slug>.md`; never reuse an index. Existing immutable records may have only the indexed filename.

Every new Corrective Action includes a concise, reusable `rule` plus its specific `description`. The rule must prevent the observed pattern without episode-specific paths, dates, record IDs, or incidental detail.

Use `execution_context.summary` and `execution_context.references` only when technical, instructional, environmental, model, tool, or runtime information materially explains the episode. Do not recreate a telemetry schema.

Use availability states for information that is unavailable, unknown, not collected, unsafe to retain, or not applicable. Record only material, available information and state a material limitation rather than inventing a value.

`failure` contains the stable analysis fields: `failure_ids`, `trigger`, `detected_at`, `expectation`, `observed`, `impact`, `prevention_loci`, and `classification_data`. `violation` contains only a concise statement.

For an FR or FUR, `failure.trigger` is the signal or event that detected the failure. It is distinct from the user-or-agent trigger for JR and JUR records.

An FUR inherits its failure classification through `update.subject_record_id`; it includes `failure_ids` only when classification changes. A JUR investigation records prevention loci in `investigation.findings.prevention_loci`; an FR or FUR records the current analysis value in `failure.prevention_loci`.

## 4. Record-family standards

### 4.1 `judgement-record.md`

Define JR and JUR qualification, trigger and activity rules, update lineage, immutable records, and concise YAML-based templates.

User-triggered JRs are always user-activity. Agent-triggered JRs may arise from user-activity or agent-activity.

For each material JUR, determine status from the preceding record's trigger and the current activity:

| Previous record | Current activity | Status | Investigation |
| --- | --- | --- | --- |
| User-triggered | User-activity | Not a violation | Not required |
| User-triggered | Agent-activity | Concern | Required |
| Agent-triggered | Any activity | Violation | Required |

Every JUR links to the immediately preceding JR or JUR and ultimately traces to a JR. A JUR records only material information introduced by the update.

Use the compact `judgement` group. Do not make settlement time, completion boundary, authority, direction, alternatives, tradeoffs, or outcome first-class schema fields. Record those details only when material within basis, scope, rationale, or contextual text.

### 4.2 `failure-record.md`

Define FR and FUR qualification, immutable update lineage, concise YAML-based templates, and common failure information.

FRs and FURs are always material Violations. Every FUR links to the immediately preceding FR or FUR and ultimately traces to an FR. An FUR records only its material delta, `update.subject_record_id`, `update.kind`, and `update.effect`.

Put expectation, observed behavior, impact, classification data, and prevention loci in `failure`. Keep `violation` to its concise statement. Do not use a corrective-action owner field.

### 4.3 `failures.md`

Keep the five compact definitions:

- `incorrect-rule-application`
- `unsupported-material-assumption`
- `unverified-completion-claim`
- `material-instruction-noncompliance`
- `material-evidence-omission`

Each definition has one stable slug heading and only a Trigger, Exclusions when needed, failure-specific Record data, and Investigation data.

Failure-specific Record data belongs in `failure.classification_data`. Failure-specific Investigation data belongs in named entries under `investigation.findings`. `failure.prevention_loci` is a shared current-analysis field, not duplicated in definitions.

Do not add procedure, templates, telemetry, severity scoring, root-cause conclusions, or the old large catalog.

## 5. Operational entry point

### `episode/SKILL.md`

The single root skill reads `src/episode.md` and `src/schema.md` for every episode.

For a material judgement or update, it reads `src/judgement-record.md`, determines JR or JUR, applies the JUR status matrix, performs a required Episode Investigation, and creates the applicable immutable record.

For a detected failure or update, it first matches `src/failures.md`, then reads `src/failure-record.md`, determines FR or FUR, performs the required Episode Investigation, and creates the applicable immutable record.

The skill uses root-relative `src/` paths, treats YAML as illustrative structure rather than required serialization, applies the delta-only update rule, uses indexed record filenames, and creates the applicable record directory before writing. Automatic invocation is enabled only for the plain-language decision and confirmed-problem boundary. There are no nested judgement-record or failure-record skills.

## 6. Migration and verification

Do not copy the old JSON Schema, `episode-record.md`, old failure catalog, or MJR/JFR policy into the active package. Do not remove or modify archived material unless a later adoption decision requires it.

Before adoption, verify that:

- YAML examples are syntactically valid and match their documented rules.
- `purpose.md`, `SKILL.md`, and `agents/openai.yaml` conform to `.agents/gov/sop/skill-creation.md`.
- `tests/validate_templates.py` passes.
- No active document uses MJR, JFR, `episode-record`, required frontmatter, or a detailed telemetry inventory.
- Every failure-definition field has a defined storage location.
- JUR and FUR templates are delta-only.
- User-triggered, user-activity JURs need no Episode Investigation.
- User-triggered, agent-activity JURs are concerns and require an Episode Investigation.
- Any agent-triggered JUR and every FR or FUR are Violations and require an Episode Investigation.
- Completed Violation records meet the Corrective Action rule.
- The standards are harness-agnostic and retain only material, available information.
