# Episode-Record Finalization Plan

## 1. Purpose

This document defines the work needed to adopt the simplification proposed in `tood.md`, revise the staged rebuild in `new/episodes/`, and activate the approved standards under `.agents/`.

This is a design revision and migration, not only a `schema.md` edit.

Keep `00status.md` and `01status.md` as historical status records. Do not modify `bad/` or archived source material as part of this work.

## Status

Sections 1 through 5 are complete in the staged rebuild at `new/episodes/`. The split-package activation plan in section 6 is superseded by `03episode-skill.md`. The active implementation is the single `.agents/skills/episode/` package; existing staged and historical files remain in place.

## 2. Adoption decisions

The following decisions are explicit in `target.md`:

- `tood.md` is the authoritative simplified schema design.
- Every completed Violation record includes or inherits a recommended corrective action. A Violation may be recorded before that action is known.
- The current prevention loci appear once in `failure.prevention_loci` for FR and FUR analysis. A JUR investigation uses `investigation.findings.prevention_loci`.
- `failure.trigger` is the failure-detection signal or event, distinct from the user-or-agent trigger for a JR or JUR.
- An FUR inherits failure classification through `update.subject_record_id` and includes `failure_ids` only when classification changes.
- Failure-definition investigation data is stored in named `investigation.findings` entries; shared investigation fields remain separate.
- The two record directories are created when the relevant skill first writes a record; the repository does not retain empty directories.
- New records use indexed filenames: a three-digit root index for JR and FR, and that root plus a two-digit update index for JUR and FUR. Existing immutable records need not gain a `record.index` field.
- Every new Corrective Action includes a generic, reusable `rule` and a specific `description`.
- Automatic episode-skill invocation is enabled only for the plain-language boundary of a decision that guides later work or a confirmed problem needing a durable record.

## 3. Simplified schema

Rewrite `new/episodes/schema.md` as a concise data dictionary that uses YAML code blocks for structure. YAML is illustrative only. Records may use Markdown sections, lists, or YAML; no YAML frontmatter or serialized format is required.

Use this structural shape:

```yaml
record:
  index:
  id:
  record_type: JR | JUR | FR | FUR
  title:
  recorded_at:
  event_at:
  source:
  episode:
  summary:
  relationships:

judgement:
  kind:
  trigger: user | agent
  activity: user | agent
  statement:
  basis:
  scope:
  rationale:
  revisit_triggers:

failure:
  failure_ids:
  trigger:
  detected_at:
  expectation:
  observed:
  impact:
    level: none | low | medium | high | unknown
    description:
    affected_scope:
  prevention_loci:
  classification_data:

violation:
  statement:

investigation:
  status:
  findings:
  causal_status: observed | inferred | hypothesized | unknown
  evidence:
  limitations:

corrective_actions:
  - rule:
    description:
    target:
    status: recommended | accepted | implemented | rejected
    validation:

update:
  subject_record_id:
  kind:
  effect:
  assessment: not_a_violation | concern | violation
```

Replace the detailed execution telemetry inventory with this optional, material-only group:

```yaml
execution_context:
  summary:
  references:
```

Do not make `recorded_by`, `actors`, `context`, `evidence`, `limitations`, or `execution_context` universal required groups. Record them only when material. Retain availability states as shared vocabulary for material information that is unavailable, unknown, not collected, unsafe to retain, or not applicable.

## 4. Revise the record standards

### 4.1 Judgement records

Update `new/episodes/judgement-record.md` to:

- Preserve JR and JUR qualification, the JUR status matrix, required Episode Investigations, immutability, and lineage.
- Use the compact `judgement` and `update` groups.
- Remove first-class requirements for `settled_at`, `completion_boundary`, `authority`, `direction`, alternatives, tradeoffs, and outcome.
- Allow that information only when material, within `basis`, `scope`, `rationale`, or optional context.
- Replace templates with concise YAML blocks that map exactly to the revised schema.
- Require a JUR to record only material information introduced by the update.

### 4.2 Failure records

Update `new/episodes/failure-record.md` to:

- Put expectation, observed behavior, impact, classification data, and prevention loci in `failure`.
- Reduce `violation` to a concise statement.
- Use `investigation` only when one is performed. It is required for FR and FUR and for concern or violation JURs.
- Remove corrective-action `owner`.
- Require an FUR to record only changed material, plus `update.subject_record_id`, `kind`, and `effect`.
- Replace templates with concise YAML blocks that map exactly to the revised schema.

## 5. Align the failure catalog and skills

Update `new/episodes/failures.md` only to make its data contract explicit:

- Failure record-data fields belong in `failure.classification_data`.
- Failure investigation-data fields belong in named entries in `investigation.findings`.
- `failure.prevention_loci` holds the current analysis value.
- Preserve the five definitions, their triggers, and their exclusions.
- Do not add procedure, telemetry, templates, or the old large catalog.

Update both staged skills to:

- Refer only to the revised field names and the delta-only update rule.
- Explain that YAML is an illustrative schema and template format, not a required record serialization.
- Preserve classification, investigation, immutability, safe-retention, and storage rules.
- Ensure the intended record directory exists before a record is written, if that is the adopted directory policy.

Keep the current `agents/openai.yaml` files. Their JR/JUR and FR/FUR descriptions are accurate.

## 6. Superseded split-package activation plan

Do not create this split active structure. It is retained only as historical design context:

```text
.agents/gov/policy/execution/episodes/
  episode.md
  schema.md
  judgement-record.md
  failure-record.md
  failures.md

.agents/skills/judgement-record/
  SKILL.md
  agents/openai.yaml

.agents/skills/failure-record/
  SKILL.md
  agents/openai.yaml

.agents/records/judgements/
.agents/records/failures/
```

The active structure is instead defined by `03episode-skill.md`: one `.agents/skills/episode/` package with root `SKILL.md`, `purpose.md`, `agents/openai.yaml`, `src/`, and `tests/`. Preserve the staged files rather than moving or deleting them.

## 7. Verification before adoption

Verify all of the following:

- Each YAML example is syntactically valid and matches the documented field rules.
- No active file uses MJR, JFR, `episode-record`, required frontmatter, or the detailed telemetry inventory.
- Each field named by a failure definition has a defined storage location.
- JUR and FUR templates are delta-only.
- A user-triggered, user-activity JUR is not a violation and requires no Episode Investigation.
- A user-triggered, agent-activity JUR is a concern and requires an Episode Investigation.
- Any update to an agent-triggered judgement is a violation and requires an Episode Investigation.
- Every FR and FUR is a violation and requires an Episode Investigation.
- Completed FRs meet the adopted corrective-action rule.
- The active `episode` skill writes to the intended record directories.
- The active standards remain harness-agnostic and retain only material, available information.
