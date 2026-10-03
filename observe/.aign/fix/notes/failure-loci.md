# Prevention Loci

## 1. Definition

Prevention loci identify where a preventive change may be possible. They are not fault assignments or root-cause findings. A failure may have more than one locus.

## 2. Defined loci

- `agent_level` — Improve agent instructions, skills, routing, checkpoints, review triggers, or capability.
- `tool_level` — Repair or constrain tool behavior; add guardrails, validation, feedback, or observability.
- `shared_agent_and_tool` — Combine tool-enforced checks with agent guidance, interface improvements, and verification loops.
- `task_or_external` — Clarify or defer an underspecified task, obtain unavailable authority, repair an external dependency, or document a limitation outside a credible agent or tool prevention change.
- `unresolved` — Retain uncertainty, seek further evidence, and avoid unsupported remediation claims.

## 3. Boundary

`user_level` is not a defined prevention locus. User-provided ambiguity or missing authority is represented by `task_or_external`; the user is an actor or authority, not a prevention locus.
