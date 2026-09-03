# Audit

Audit an existing artifact without editing it.

Use a comparison audit when an authoritative source and a derived artifact are available.
Use a standalone audit when only the artifact is available, such as after create.

## Establish the boundary

Identify the artifact under review, its intended consumer, relevant user request, authoritative inputs, and applicable rules.

For a comparison audit, identify the authoritative source, derived artifact, and any authorized changes.
The source establishes the preservation baseline.

For a standalone audit, the user request and supplied authoritative inputs establish the baseline.
Do not claim that source preservation was assessed when no source is available.
The absence of a source is a scope fact, not a warning.

State an assumption, exclusion, or missing input when it limits what the audit can establish.

Use repository-relative file paths and one-based line numbers for evidence whenever the evidence is in a file.
Do not invent a line number for a user request, chat input, or unavailable file.

## Review

Read `../rules/content.md` for every audit.
For a comparison audit, also read `../rules/preservation.md`.
Read `../rules/format.md` when format is applicable under the request.

Check only the established boundary.

- In a comparison audit, check material meaning, force, authority, scope, conditions, exceptions, dependencies, uncertainty, retrieval needs, verification, and compatibility-sensitive literals.
- In a standalone audit, check coverage of the established baseline, unsupported invention, internal consistency, material clarity, and usable access to required information.
- When format applies, check Markdown structure and formatting against the applicable format rules.

Assess meaning and use, not wording, order, token count, or source presentation alone.
A different representation may pass when it preserves required meaning and access.

## Findings

Use only these finding levels:

- **Failure:** An established violation of the comparison or standalone baseline, a compatibility-sensitive literal, an explicit user requirement, or a format rule that uses `MUST` or `MUST NOT`. A format defect that changes material meaning, required access, or Markdown validity is also a failure.
- **Warning:** An uncertainty that prevents a complete assessment, or a non-required format, organization, or readability improvement. A warning does not establish a violation.

`format: strict` promotes applicable format warnings to failures.
Without `format: strict`, do not fail an artifact solely for a stylistic preference or an arguable presentation choice.

Do not create a finding for an equivalent representation, a justified non-material omission, or a preference that lacks an applicable requirement.
Do not use categories such as critical, major, minor, or inconclusive.
Order findings by practical impact rather than assigning another severity level.

## Corrective actions

After establishing the audit outcome, add a corrective-action pattern only when a finding reveals a reusable mistake pattern that needs special attention in future work.
This is the sole edit an audit may make.
Do not edit the reviewed artifact, source, or governing rules.

Append the pattern to the `## Corrective Action` section in the file that owns the underlying issue:

- `../rules/content.md` for standalone coverage, unsupported invention, clarity, authority, or usable-content issues.
- `../rules/preservation.md` for source-to-derived changes to meaning, force, scope, conditions, exceptions, literals, or compatibility.
- `../rules/format.md` for Markdown structure, presentation, or retrieval issues.

Append a failure pattern under `### Failures` only for an established failure.
Append a warning pattern under `### Warnings` only when the warning identifies a reusable future risk.
Do not add a pattern for a preference, an isolated wording choice, or unavailable evidence.

Write one concise, document-independent bullet that identifies the kind of content or structure and the mistake to avoid.
Remove document names, paths, API names, dates, incidental literals, and other details that do not help recognize the pattern in future work.
Do not turn the entry into a restatement of a governing rule.

Before appending, read the destination list.
If an existing item already covers the same pattern, do not add another item.
Add at most one pattern to each destination file during one audit.
When adding the first item under a heading, replace `No known failure patterns.` or `No known warning patterns.` with that item.

## Report

Report directly in the response. Do not create a report file unless the user asks.

Start with:

```markdown
**Outcome:** PASS, PASS WITH WARNINGS, or FAIL
**Scope:** Comparison or standalone
**Reviewed:** <source and derived artifacts, or artifact>
**Format review:** Applied, not applied, or strict
**Corrective action:** None, or `path/to/rule.md:line`
```

- Use `PASS` when there are no failures or warnings.
- Use `PASS WITH WARNINGS` when there are warnings and no failures.
- Use `FAIL` when one or more failures are established.

For each finding, state the level, affected location, baseline evidence, practical impact, and smallest correction.

Use this evidence structure:

```markdown
**Artifact:** `path/to/artifact.md:line` or Absent from `path/to/artifact.md`
**Baseline:** `path/to/source.md:line` or User request, no file line available
**Rule:** `path/to/rule.md:line` when a rule establishes the finding
```

For comparison findings, cite both the source line and the derived artifact line, or state that the source unit is absent from the derived artifact.
For standalone findings, cite the artifact line and every available authoritative-input line.
For a format finding, cite the artifact line and the applicable format-rule line.
When adding a corrective-action pattern, report the destination file and line number.

If there are no findings, write:

```markdown
## Findings

No findings.
```

Do not edit any artifact as part of an audit except for an eligible corrective-action append.
