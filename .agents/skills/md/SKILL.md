---
name: md
description: "Use when explicitly asked to create, revise, transform, or audit Markdown for materially faithful, scanable output."
disable-model-invocation: true
---

# my-md

Create, revise, transform, or audit Markdown.

## Rule Interaction

Applicable rules stack cumulatively.

The selected operation defines the authorized boundary.
For transform and revise, preservation governs recovered source meaning, retained literals, compatibility, and unresolved conflicts.
Content governs material meaning, authority, and usability.
Compression may reduce expression only within those constraints.
Format governs permitted structural and Markdown presentation changes.
Format uses the applicable content model established by the operation, content, and, when applicable, preservation rules. It does not establish or alter that model.

When rules address the same action, apply the more specific rule within its stated scope. Format does not authorize a change to material meaning, compatibility, or other preservation obligations.



## Content Rules and format

- Content Rules are used for every operation. Require `src/rules/content.md`
- For all operations Require `src/rules/format.md` **UNLESS** the user requests to preserve format and/or structure

## Choose operation

- **Create:** No source file. Create from the request and authoritative inputs. Require `src/operations/create.md`
- **Transform:** Source file, unless explicitly overridden. Redesign permitted scope while preserving material meaning and use. Require `src/operations/transform.md` and `src/rules/preservation.md`
- **Revise:** Use for a scoped change within an existing document, such as updating, correcting, adding, or removing specific content. Require `src/operations/revise.md` and `src/rules/preservation.md`
- **Audit:** Review an existing artifact without editing it. A source is optional. With a source, review preservation. Without one, review coverage of the request and authoritative inputs, internal consistency, and applicable rules. Require `src/operations/audit.md`

## Choose compression

Compression applies to create, revise, and transform. Audit does not use a compression level.
Compression modifies expression within the selected operation's authorized boundary. It does not change what is authorized, required, or preserved.

Select compression case-insensitively.

- No compression selector selects low compression.
- `low` or `lo` selects low compression.
- `high` or `hi` selects high compression.
- `compression`, `compress`, or `comp` alone selects high compression.
- `compression`, `compress`, or `comp` followed by whitespace, `=`, or `:`, then `low`, `lo`, `high`, or `hi`, selects that level.

Examples:

```text
my-md file.md
my-md low file.md
my-md lo file.md
my-md comp lo file.md
my-md compression:low file.md

my-md high file.md
my-md hi file.md
my-md comp file.md
my-md compress high file.md
my-md compression=hi file.md
```

- **low** Require `src/compression/low.md`
- **high** Require `src/compression/high.md`


## Perform action

1. Read every file required by the selected operation and applicable rules.
2. Complete the requested create, revise, transform, or audit operation.

## Delivery gate

Apply this gate after create, revise, or transform. Do not apply it when the selected operation is audit.

1. **Complete** the create, revise, or transform, then save its resulting artifact to a file. **Only after** the artifact is saved may the audit begin.
2. **Confirm** that the audit has a completed, saved artifact and the applicable baseline:
   - **Create:** The user request and supplied authoritative inputs establish the standalone baseline. A source artifact is not required.
   - **Revise:** The pre-revision artifact and authorized change request establish the baseline. Preserve the pre-revision content for the audit when the revision overwrites its source file.
   - **Transform:** The authoritative source and completed, saved derived artifact establish the comparison baseline.
3. **Verify** that steps 1 and 2 are complete before starting the audit.
4. You **MUST** use a subagent or subprocess to run the applicable audit in `src/operations/audit.md`, then correct every established failure within the authorized scope. If format was applied, the audit **MUST** review formatting and structure as well as the applicable content or preservation baseline.
5. You **MUST** use a subagent or subprocess to rerun the affected audit after correction to verify completion.
6. If the final audit still fails, tell the user which findings remain unresolved. Do not deliver a passing result while an established failure remains.
7. Output the complete result of the final audit run, including every finding, warning, and corrective-action update. Warnings do not block delivery unless the user requests otherwise.

An audit does not edit the source, target, or tests. Its only permitted rule-file edit is an eligible append to a `## Corrective Action` section, as defined by `src/operations/audit.md`.
