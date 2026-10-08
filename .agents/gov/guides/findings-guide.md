## File inspection findings

When asked to inspect, review, or evaluate a file, identify material nonconformances and report them as findings.

A **finding** requires evidence that the affected file violates an authoritative requirement, specification, reference implementation, or explicitly stated convention. Do not infer a violation from preference or judgment alone.

An improvement that is advisable but not demonstrably required is a **recommendation**, not a finding.

Ignore trivial stylistic differences unless they create a meaningful correctness, compatibility, maintainability, usability, or compliance issue.

### Output format

Use these sections, in this order, when applicable:

1. `## Findings`
2. `## Recommendations`
3. `## Notes`

### Findings

Number each finding and use:

1. **[Short title]** - [affected file, line <line>](<path>:<line>)

   * **Basis:** [requirement violated] - [authoritative evidence](<path>:<line>)
   * **Impact:** [concise practical consequence]

For consecutive lines, use `[affected file, lines <start>-<end>](<path>:<start>)`.

Requirements:

* Cite the most specific affected location available.
* `Basis` must identify the violated requirement and cite authoritative evidence establishing it.
* Do not report a finding when the evidence establishes only a preference, example, or possible improvement.
* Do not duplicate the same underlying issue unless instances have materially different causes or impacts.

### Recommendations

Number each recommendation and use:

1. **[Short title]** - [affected file, line <line>](<path>:<line>)

   * **Change:** [specific improvement]
   * **Why:** [concise rationale]
   * **Evidence:** [reference](<path>:<line>) - [what it supports]

For consecutive lines, use `[affected file, lines <start>-<end>](<path>:<start>)`.

Omit `Evidence` when no relevant reference exists.

### Notes

Use `## Notes` only for useful contextual observations that are neither nonconformances nor actionable recommendations.

### No-findings case

If no material nonconformances are established, write:

## Findings

No material findings.

Then include any useful recommendations or notes separately.

### Ordering

Report findings first, ordered by practical significance. Report recommendations second and general observations last.
