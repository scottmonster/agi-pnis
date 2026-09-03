# Representative Audit Cases

Use these cases to forward-test the audit operation and delivery gate. Verify the stated outcome and finding level without requiring a specific report layout beyond the required context lines.

## Create delivery gate uses a standalone audit

### Request

Create a release checklist that requires a version number before publishing.

### Initial artifact

The saved checklist omits the version-number requirement.

### Expected result

Save the initial artifact before the audit begins.
Use a subagent or subprocess to run a standalone audit against the request and the saved artifact.
Correct the established failure, save the corrected artifact, and use a subagent or subprocess to rerun the standalone audit.
Return the complete final audit report.
Do not require a source artifact or report a warning merely because one does not exist.

## Transform delivery gate uses a comparison audit

### Source

All reports must be submitted Friday.

### Initial artifact

The saved transformed artifact says reports should be submitted Friday.

### Expected result

Use a subagent or subprocess to run a comparison audit against the source and saved artifact.
Correct the weakened requirement, save the corrected artifact, and use a subagent or subprocess to rerun the affected comparison audit.
Return the complete final audit report.

## Explicit audit has no delivery gate

### Request

Audit an existing artifact.

### Expected result

Run the requested audit but do not invoke another delivery-gate audit after it completes.

## Standalone audit has no source warning

### Request

Create a release checklist that requires a version number before publishing.

### Artifact

Every release-note entry must include a version number before publishing.

### Expected result

Return `PASS` with `Scope: standalone`.
State that source preservation was not assessed, but do not create a warning merely because no source exists.

## Standalone audit finds missing requested material

### Request

Create a release checklist that requires a version number and approval before publishing.

### Artifact

Every release-note entry must include a version number before publishing.

### Expected result

Return `FAIL` with a failure for the missing approval requirement.
The finding cites the artifact line and identifies the user request as `User request, no file line available`.
It gives the smallest correction.

## Comparison audit finds force and exception changes

### Source

All reports must be submitted Friday.
Contractors may submit Monday only when a Friday office closure prevents submission.

### Derived artifact

Reports should be submitted Friday.
Contractors may submit Monday.

### Expected result

Return `FAIL` with failures for weakened force and the lost exception condition.
Each finding cites the relevant source line and derived-artifact line.

## Equivalent representation passes

### Source

Every release-note entry must identify its version.
Do not publish a release note without a version number.

### Derived artifact

Include a version number in every release-note entry before publishing.

### Expected result

Return `PASS` when no scope, consumer, or compatibility requirement was omitted.

## Explicit format rule fails

### Artifact

| State | Action |
| --- | --- |
| Transient error | Retry |

### Expected result

When format review applies, return `FAIL` because the format rules require visually aligned Markdown table columns with `MUST`.
The finding cites the table line and the governing format-rule line, then gives the smallest correction.

## Optional format improvement warns

### Artifact

**Security rule:** Never publish `api_key`.

### Expected result

When format review applies without `format: strict`, return `PASS WITH WARNINGS`.
Warn that bold is being used as a heading substitute, but do not fail because this rule is not expressed as `MUST` or `MUST NOT` and material meaning remains clear.

## Strict format promotes the warning

### Artifact

**Security rule:** Never publish `api_key`.

### Expected result

With `format: strict`, return `FAIL` for the same formatting defect.

## Preservation failure adds a reusable pattern

### Source

The service may retry only after a transient error.

### Derived artifact

The service may retry after an error.

### Expected result

Return `FAIL` for the lost condition.
Append one reusable failure pattern to `src/rules/preservation.md` under `### Failures`, such as `A condition limiting a permitted action was omitted.`
Do not include the service name, error name, or any document-specific wording.
Report the added pattern's file and line number.

## Format warning adds a reusable pattern

### Artifact

**Security rule:** Never publish `api_key`.

### Expected result

Without `format: strict`, return `PASS WITH WARNINGS`.
Append one reusable warning pattern to `src/rules/format.md` under `### Warnings`, such as `Bold text was used as a heading substitute.`
Report the added pattern's file and line number.

## Existing pattern is not duplicated

### Existing corrective action

`src/rules/preservation.md` already lists `A condition limiting a permitted action was omitted.` under `### Failures`.

### Source and derived artifact

Use the source and derived artifact from the preservation-failure case.

### Expected result

Return `FAIL`, but do not add another corrective-action pattern.

## Unresolved evidence warns

### Source

The system must retain logs for 30 days.

### Derived artifact

The system retains logs according to policy.

### Additional context

The referenced policy is unavailable.

### Expected result

Return `PASS WITH WARNINGS` when the available evidence cannot establish whether the policy preserves the 30-day requirement.
Do not call the result a failure unless the available evidence establishes a violation.
