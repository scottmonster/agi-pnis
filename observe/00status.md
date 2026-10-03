## 1. Diagnosis

The rebuild should be a new, small standard—not a rewrite of the old system.

- [`observe/bad/episodes`](/home/scott/Documents/agi-pnis/gov-lab/observe/bad/episodes) is a 2,570-line protocol/schema/catalog system.
- [`observe/new`](/home/scott/Documents/agi-pnis/gov-lab/observe/new) already has the intended skeleton, but its three core standards and failure skill are empty.
- [`judgement_record.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/new/judgement_record.md) and the existing judgement skill are copies of the old MJR/JFR model. They conflict with the new JR/JUR model and should not be retained as active policy.
- The archive is useful only as a source for narrowly reusable content: immutability, evidence discipline, and skill metadata—not as a document to copy wholesale.
- [`exessive_recordables.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/znotes/exessive_recordables.md) expressly says it is non-authoritative. Do not rebuild the JSON schema or its giant field inventory.

## 2. Target structure

| File | Responsibility |
|---|---|
| `episode.md` | Shared definitions, materiality, investigation threshold, shared invariants |
| `judgement-record.md` | JR/JUR rules and complete Markdown record schema/templates |
| `judgement-record/SKILL.md` | Operational judgement workflow |
| `failure-record.md` | FR/FUR rules and complete Markdown record schema/templates |
| `failure-record/SKILL.md` | Operational failure workflow |
| `failures.md` | Extensible failure definitions: trigger, record data, investigation data |

The last file is missing from `observe/new`; it is required by [`format.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/znotes/format.md). Use `failures.md`, not the old `failure-catalog.md`.

## 3. Rebuild work

### 3.1 Create the shared standard

Write `episode.md` with only:

- Definitions of material episode, violation, concern, corrective action, and Episode Investigation.
- Shared requirements for evidence, uncertainty, safe retention, stable IDs, links, and immutability.
- The decision rule for when an investigation is required.
- The rule that failures are material violations and judgment updates receive the status defined by `judgement-record.md`.

It must not contain routing procedure, a generic skill, a JSON schema, harness-specific telemetry requirements, or a failure catalog.

### 3.2 Create the judgement standard

Write `judgement-record.md` from [`material.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/znotes/material.md):

- Define JR and JUR.
- Preserve the user-triggered/agent-triggered and user-activity/agent-activity distinction.
- Include the JUR status matrix: user correction of user-triggered judgment = not a violation; agent update of user-triggered judgment = concern; update of agent-triggered judgment = violation.
- Require immutable, linked update chains.
- Define the complete Markdown schema/templates requested by `judgement-complete.md`, with a small required core and optional “when available” evidence.

### 3.3 Create the failure standard and catalog

Write `failure-record.md` to define FR and FUR, their immutable update chain, common required data, and the always-violation rule.

Write `failures.md` as a compact catalog. Each definition should contain:

- Trigger
- Record data
- Investigation data

Do not migrate the old 246-item catalog unchanged. Start with a deliberately small, useful set or an extensible template; add failures only when they earn their place.

### 3.4 Make the design harness-agnostic

All record standards need a strict minimum record, plus optional data marked “when available.”

Require facts necessary to understand the episode; do not require provider-specific data such as model telemetry, token counts, run IDs, command logs, or tool inventories. Where useful, record:

- Available
- Unavailable
- Not collected
- Unsafe to retain
- Not applicable

This fulfills the intent in [`harness_agnostic.md`](/home/scott/Documents/agi-pnis/gov-lab/observe/znotes/harness_agnostic.md) without recreating the old schema’s complexity.

### 3.5 Replace both skills

- Rewrite `judgement-record/SKILL.md` to use JR/JUR, read `episode.md` and `judgement-record.md`, determine whether investigation is needed, and create the appropriate record.
- Write `failure-record/SKILL.md` to consult `failures.md` first, then apply `episode.md` and `failure-record.md`.
- Remove the copied MJR/JFR policy reference, synchronization manifest, and legacy skill assumptions unless there is an intentional external skill-packaging requirement.

### 3.6 Retire conflicting rebuild artifacts

Remove or archive these from `observe/new` rather than leaving two incompatible systems:

- `judgement_record.md`
- `judgement-record/purpose.md`
- `judgement-record/ref/`
- Existing legacy `judgement-record/SKILL.md` content

Keep `agents/openai.yaml` only if it is updated to describe JR/JUR accurately.

## 4. Follow-up integration

No active repository document currently links to the new location, so this rebuild can be self-contained initially.
