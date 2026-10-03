# Episode Skill Migration Plan

## 1. Objective

Replace the planned split episode-policy deployment with one automatically selected, narrowly scoped skill named `episode`.

The skill owns its operational workflow and active episode standards. It records material judgement and failure episodes through JR, JUR, FR, and FUR records.

This plan conforms to `.agents/gov/sop/skill-creation.md`.

## Implementation status

The single `.agents/skills/episode/` package is implemented. Its five active standards carry the approved staged design plus the adopted filename-index and corrective-action-rule refinements. Existing staged and historical files remain in place. The failure-record directory now contains indexed immutable records.

## 2. Active structure

Create this active package:

```text
.agents/skills/episode/
├── agents/
│   └── openai.yaml
├── src/
│   ├── episode.md
│   ├── schema.md
│   ├── judgement-record.md
│   ├── failure-record.md
│   └── failures.md
├── tests/
│   └── validate_templates.py
├── purpose.md
└── SKILL.md
```

Keep durable record output outside the skill:

```text
.agents/records/judgements/
.agents/records/failures/
```

Do not put record output under the skill directory. It is governed operational history, not instructions, reference material, or internal runtime state.

Do not create `.agents/gov/policy/execution/episodes/`, `.agents/skills/judgement-record/`, or `.agents/skills/failure-record/`.

## 3. Architecture decisions

- `episode` is the only episode-record entry point. It supersedes the earlier rule that there is no `episode/SKILL.md`.
- The root `SKILL.md` routes judgement work and failure work. Do not create nested child `SKILL.md` files.
- The five active standards belong in `src/`. They are required runtime instructions, so they do not belong in `ref/`.
- Do not create `ref/` unless later work needs non-skill-owned source material that is not required during normal skill execution.
- Create `tests/` because YAML template and routing invariants need deterministic validation.
- Create record directories when the skill first writes a record. Do not retain empty record directories in the repository.
- Do not use `.agents/state/episode` unless the skill later needs internal temporary state. Durable JR, JUR, FR, and FUR files are not internal skill state.

## 4. Required package files

### 4.1 `purpose.md`

Write this before or alongside `SKILL.md`. It must explain:

- The skill records material judgement and failure episodes.
- It replaces the overgrown earlier episode system.
- It benefits users, agents, reviewers, and later improvement analysis.
- It creates immutable JR, JUR, FR, and FUR records.
- It is harness-agnostic.
- It does not treat routine work, tool logs, private reasoning, or generated records as policy.

Keep it a plain-language recreation record, not a maintenance specification or change-control contract.

### 4.2 `SKILL.md`

Use short frontmatter that permits automatic selection:

```yaml
---
name: episode
description: Use when a decision will guide later work, new information significantly changes that decision, or a confirmed problem needs a durable record. Do not use for ordinary work, active discussion, tentative analysis, implementation, routine checks, execution logs, or unconfirmed concerns.
disable-model-invocation: false
---
```

The body must:

- Route material judgement work to `src/judgement-record.md`.
- Route detected failure work to `src/failures.md`, then `src/failure-record.md`.
- Apply `src/episode.md` and `src/schema.md` to both routes.
- Determine JR versus JUR, or FR versus FUR.
- Apply the JUR status matrix.
- Perform an Episode Investigation for every Concern and Violation.
- Preserve immutable immediate-parent lineage.
- Create the applicable record directory before writing a record.
- Use skill-root-relative paths such as `src/schema.md`.
- State that YAML blocks are structural notation, not a required record serialization format.

Keep detailed policy in `src/`; do not duplicate it in the root skill.

### 4.3 `agents/openai.yaml`

Create metadata that is consistent with `SKILL.md`:

```yaml
interface:
  display_name: "Episode"
  short_description: "Record consequential decisions and confirmed problems"
  default_prompt: "Use $episode when a decision will guide later work or a confirmed problem needs a durable record."
policy:
  allow_implicit_invocation: true
```

Automatic selection matches `disable-model-invocation: false`. The description supplies a narrow, plain-language boundary so ordinary work and unconfirmed concerns do not trigger the skill.

### 4.4 `src/`

Move the approved staged standards into `src/`:

- `observe/new/episodes/episode.md` to `src/episode.md`
- `observe/new/episodes/schema.md` to `src/schema.md`
- `observe/new/episodes/judgement-record.md` to `src/judgement-record.md`
- `observe/new/episodes/failure-record.md` to `src/failure-record.md`
- `observe/new/episodes/failures.md` to `src/failures.md`

Update internal links and instructions to use skill-root-relative paths. The active source exists only in `src/`; staged material is not a competing active policy source.

### 4.5 `tests/validate_templates.py`

Add deterministic validation that:

- Parses every YAML block in the five source standards.
- Verifies all linked `src/` files exist.
- Verifies the JUR template includes every changeable judgement field.
- Verifies the FUR template includes every changeable failure, investigation, violation, and corrective-action field.
- Verifies failure-definition Record data maps to `failure.classification_data`.
- Verifies failure-definition Investigation data maps to `investigation.findings`.
- Verifies the root skill contains both routing paths and the two record destinations.

## 5. Record handling

The skill writes only to these paths:

- `.agents/records/judgements/` for JR and JUR.
- `.agents/records/failures/` for FR and FUR.

Before writing, create the required directory if it does not exist. Do not overwrite an existing record.

Name a new JR or FR `<root-index>-<record-type>-<slug>.md`, using the next unused three-digit root index. Name a JUR or FUR `<root-index>.<update-index>-<record-type>-<slug>.md`, using the originating root index and next unused two-digit update index. Store the same value in `record.index` for new records. Existing immutable records may be indexed only through their filenames.

Every new Corrective Action requires a generic, reusable `rule` as well as the specific `description`. The rule excludes paths, dates, record IDs, and incidental episode details.

The record rules remain unchanged:

- JR and JUR updates trace through the immediately preceding record to a JR.
- FR and FUR updates trace through the immediately preceding record to an FR.
- User-triggered, user-activity JURs are not Violations and need no Episode Investigation.
- User-triggered, agent-activity JURs are Concerns and require an Episode Investigation.
- Any update to an agent-triggered judgement is a Violation and requires an Episode Investigation.
- FRs and FURs are always Violations and require an Episode Investigation.

## 6. Documentation changes

Before activation, update `target.md` and `02finalize.md` to:

- Replace the two-skill and separate-policy-path design with this single `episode` package.
- Mark the earlier no-`episode/SKILL.md` rule as superseded.
- Keep `00status.md` and `01status.md` unchanged as historical status records.
- Keep `observe/new/episodes/` as staging or archive material only.

## 7. Validation and adoption

Before adoption:

- Run `tests/validate_templates.py`.
- Run the skill-creation structural validator against `.agents/skills/episode/`.
- Confirm the frontmatter and `agents/openai.yaml` are consistent and permit automatic invocation only within the stated boundary.
- Confirm `purpose.md` accurately describes the skill.
- Test the four JUR status paths and FR/FUR creation and update paths.
- Confirm no active policy exists under `.agents/gov/policy/execution/episodes/`.
- Confirm no active `judgement-record` or `failure-record` skill exists.
- Confirm no active document uses MJR, JFR, `episode-record`, required frontmatter, or detailed telemetry fields.
- Confirm active skill behavior is portable and does not depend on a particular agent runtime.
- Search for stale paths and update active callers only.

The generic skill-creation validator does not recognize the project-required `disable-model-invocation` frontmatter field. Retain that field because `.agents/gov/sop/skill-creation.md` requires it, and use `tests/validate_templates.py` to verify the project-specific frontmatter and metadata rules.

----


Yes. Name the single entry point `episode`.

To achieve this, replace the planned multi-directory policy deployment with one compliant skill package:

```text
.agents/skills/episode/
├── agents/
│   └── openai.yaml
├── src/
│   ├── episode.md
│   ├── schema.md
│   ├── judgement-record.md
│   ├── failure-record.md
│   └── failures.md
├── tests/
│   └── validate_templates.py
├── purpose.md
└── SKILL.md
```

Keep durable records separate:

```text
.agents/records/judgements/
.agents/records/failures/
```

Do not place records under the skill package. They are governed outputs, not skill instructions or runtime state.

The work required is:

1. Adopt the single-skill architecture

- Update `target.md` and `02finalize.md` to replace the two active skills and `.agents/gov/policy/execution/episodes/` with `.agents/skills/episode/`.
- Explicitly supersede the earlier “no `episode/SKILL.md`” rule.
- Preserve `00status.md` and `01status.md` as history.
- Keep `observe/new/episodes/` as staging or archive material only, not a competing active policy source.

2. Create the compliant `episode` skill structure

- Create `purpose.md` before or alongside `SKILL.md`.
- Put the five active standards in `src/`, not `ref/`.
- Do not create nested child `SKILL.md` files. JR/JUR and FR/FUR become two routes within the one root skill.
- Add `tests/` because the YAML schema and routing rules have meaningful, testable invariants.

This uses `src/` because the project SOP reserves `ref/` for non-skill-owned material that is not needed at runtime. The active standards are required runtime instructions.

3. Write `purpose.md`

Document:

- The skill records material judgement and failure episodes.
- It replaces the overgrown earlier episode system.
- It serves users, agents, reviewers, and later improvement analysis.
- It produces immutable JR, JUR, FR, and FUR records.
- It is harness-agnostic.
- It does not treat routine work, tool logs, private reasoning, or generated records as skill policy.

4. Build the root `SKILL.md`

Make it the only operational entry point.

Its frontmatter should be short and permit automatic selection:

```yaml
---
name: episode
description: Use when a decision will guide later work, new information significantly changes that decision, or a confirmed problem needs a durable record. Do not use for ordinary work, active discussion, tentative analysis, implementation, routine checks, execution logs, or unconfirmed concerns.
disable-model-invocation: false
---
```

Its body should:

- Route judgement work to `src/judgement-record.md`.
- Route failure work to `src/failures.md`, then `src/failure-record.md`.
- Always apply `src/episode.md` and `src/schema.md`.
- Determine JR versus JUR, or FR versus FUR.
- Apply the JUR status matrix.
- Require investigations for concerns and Violations.
- Preserve immutable immediate-parent lineage.
- Create the appropriate record directory before writing.
- Use root-relative paths such as `src/schema.md`.
- State that YAML blocks are structural notation, not required record serialization.

5. Create matching OpenAI metadata

Create `agents/openai.yaml` with metadata matching the root skill:

```yaml
interface:
  display_name: "Episode"
  short_description: "Record consequential decisions and confirmed problems"
  default_prompt: "Use $episode when a decision will guide later work or a confirmed problem needs a durable record."
policy:
  allow_implicit_invocation: true
```

This intentionally overrides the project SOP’s explicit-only default. The narrow plain-language description keeps the metadata aligned with `SKILL.md` and prevents routine activation.

6. Move the active standards into `src/`

Move the approved staged content, not the two old skill entry points:

- `observe/new/episodes/episode.md` to `src/episode.md`
- `schema.md` to `src/schema.md`
- `judgement-record.md` to `src/judgement-record.md`
- `failure-record.md` to `src/failure-record.md`
- `failures.md` to `src/failures.md`

Update all links and instructions to use skill-root-relative paths. Do not activate `.agents/gov/policy/execution/episodes/`, `.agents/skills/judgement-record/`, or `.agents/skills/failure-record/`.

7. Preserve the record-output boundary

The root skill writes only to:

- `.agents/records/judgements/` for JR and JUR
- `.agents/records/failures/` for FR and FUR

The skill creates those directories on first use. Do not use `.agents/state/episode` unless the skill later needs temporary internal state. The records themselves are durable domain output, not runtime state.

8. Add focused validation

`tests/validate_templates.py` should:

- Parse every YAML block in the five source standards.
- Verify all linked `src/` files exist.
- Verify the JUR template includes every changeable judgement field.
- Verify the FUR template includes every changeable failure, investigation, violation, and corrective-action field.
- Verify failure-definition record data maps to `failure.classification_data`.
- Verify failure-definition investigation data maps to `investigation.findings`.
- Verify the skill contains both routing paths and the two record destinations.

Also run the skill creator’s structural validator against `.agents/skills/episode/` and manually test these cases:

- User updates user-triggered judgement, no investigation.
- Agent updates user-triggered judgement, concern and investigation.
- Any update to agent-triggered judgement, violation and investigation.
- New failure, FR and corrective action.
- Failure update that changes classification, impact, investigation, or validation without copying unchanged data.

9. Final migration audit

Before adoption:

- Confirm only `.agents/skills/episode/` is the active episode skill.
- Confirm no active policy remains under `.agents/gov/policy/execution/episodes/`.
- Confirm no active `judgement-record` or `failure-record` skills remain.
- Confirm no active document uses MJR, JFR, `episode-record`, required frontmatter, or detailed telemetry fields.
- Confirm the skill remains portable and does not depend on a particular agent runtime.
- Search for stale paths and update active callers only.

A directory-based skill package can contain its own bundled files, which supports this co-located design. [Official OpenAI documentation](https://developers.openai.com/api/reference/python/resources/skills/methods/create)
