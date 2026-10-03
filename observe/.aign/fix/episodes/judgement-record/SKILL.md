---
name: judgement-record
description: Create immutable Material Judgment Records and Judgment Follow-up Records for completed material judgments and their later material outcomes. Use at a task completion boundary, when work materially affects a published judgment, or when retrospectively capturing a completed judgment. Do not use for active discussion, routine work, execution logs, or tentative analysis.
---

# Judgment Record

## 1. Read the governing policy

Read `ref/docs/policy/execution/judgement_record.md` before deciding whether to create a record. Apply its current schema, templates, completion boundary, evidence rules, and index convention.

Do not read, create, or modify files under this skill's `ref/` directory. It is synchronization-owned.

## 2. Decide whether to create a record

Create no record while a judgment remains in active discussion. Keep evolving reasoning in the task, issue, pull request, or conversation.

After a completion boundary, apply this order:

1. Determine whether later work materially concerns a published MJR or JFR.
2. Create a JFR when the later event is material implementation, validation, outcome, error, correction, or review evidence and does not change the governing judgment.
3. Create a successor MJR when the governing judgment changes. Link it to the earlier MJR with the policy-defined relationship.
4. Otherwise, create a new MJR only when the judgment is settled, discretionary, governing, material, and has reached the policy-defined completion boundary.
5. Create no record when none of these conditions hold.

Do not create an MJR merely because an agent or person stated a possible direction during discussion. Do not create a JFR for routine work or an immaterial event.

## 3. Create an MJR

Create one MJR for one coherent completed judgment. Use the policy template and complete the required frontmatter and body sections.

Record the desired outcome and success criteria, the judgment required, governing basis, settled judgment, direction, and rationale. Distinguish explicit requirements, established direction, observed facts, evidence-supported inferences, assumptions, and uncertainty.

Record safe references to the task, repository state, agent run, instructions, tools, and execution evidence when applicable. Attribute authority and contributions accurately. Do not infer approval from silence or present an agent proposal as a user judgment.

Publish the MJR as final and add it to the canonical index. After publication, `MUST NOT` edit it.

## 4. Create a JFR

Create one JFR for one material later event. Link it to the affected MJR and, when relevant, the directly affected JFR.

For a validation, outcome, or error JFR, record the expected outcome, observed outcome, difference, impact, and evaluation basis. Record material success as well as failure.

Separate observed facts from inferences, causal hypotheses, and unknowns. Do not claim a root cause unless the available evidence establishes it. Publish the JFR as final, add it to the canonical index, and do not edit it afterward.

## 5. Preserve history

Never update a published MJR or JFR to reflect later knowledge, a correction, implementation, validation, or review. Create the appropriate linked JFR instead.

When a later judgment supersedes, narrows, expands, or creates an exception to an earlier judgment, create a new MJR. Do not alter the older MJR's status, rationale, or relationships.

## 6. Capture retrospectively

When asked to capture an earlier judgment, inspect the relevant task, conversation, and artifacts. Create a record only if the judgment was completed and meets the policy threshold. Preserve gaps in the history as uncertainty. Do not invent a person's rationale, alternatives, authority, or outcome.

## 7. Check before finalizing

Confirm that the record type is correct, the completion boundary is real, the record is material, the evidence supports its claims, and the canonical index contains the new record. If the record is not justified, do not create it.
