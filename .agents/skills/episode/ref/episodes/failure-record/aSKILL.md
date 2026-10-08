---
name: failure-record
description: Create or update a material Failure Record (FR) or Failure Update Record (FUR) using the failure catalog and episode standards.
disable-model-invocation: true
---

# Failure Record

Use this skill when a failure signal, report, or review establishes a material failure, or when later material information changes an existing FR or FUR.

## 1. Read and match the standards

Before creating a record, read these files in order:

1. `../../gov/policy/execution/episodes/failures.md`
2. `../../gov/policy/execution/episodes/episode.md`
3. `../../gov/policy/execution/episodes/schema.md`
4. `../../gov/policy/execution/episodes/failure-record.md`

Match the detected failure to a definition in `failures.md`. Retain its Trigger, Exclusions, Record data, and Investigation data as the failure-specific data contract. Use the YAML blocks as data dictionary and template notation only; they do not require YAML serialization or frontmatter.

If no definition matches, do not invent a failure ID. Collect the available common information and obtain direction before creating a classified FR or FUR.

## 2. Determine the record type

- Create an FR for a detected failure that is not a material update to an existing FR or FUR.
- Create an FUR for later material information that changes, corrects, supplements, or identifies an error in the immediately preceding FR or FUR.
- Treat every FR and FUR as a material Violation.
- An FUR records only its material delta. It inherits unchanged failure classification and other failure information through `update.subject_record_id`.

## 3. Investigate the failure

Perform an Episode Investigation for every FR and FUR. Establish expected and observed behavior, relevant context and impact, available explanations, and prevention loci.

Place matched definition Record data in `failure.classification_data`. Place matched definition Investigation data in named entries in `investigation.findings`. Record the current prevention loci in `failure.prevention_loci`.

A Violation record or chain is complete only when it includes or inherits at least one recommended Corrective Action established through the Episode Investigation.

## 4. Create the record

- Use the applicable template in `../../gov/policy/execution/episodes/failure-record.md`.
- Create `.agents/records/failures/` if it does not exist, then write `.agents/records/failures/<record-id>.md`. Do not overwrite a record.
- Record only material, available information. Preserve material limitations using the availability vocabulary in `schema.md`; do not invent information.
- Keep observed facts, inference, assumptions, hypotheses, and unknowns distinct. Safely summarize or reference sensitive or voluminous evidence.
- Create immutable records. An FUR's `update.subject_record_id` identifies the immediately preceding FR or FUR and its lineage reaches an FR.
- Include `failure.failure_ids` in an FUR only when classification changes. Otherwise inherit it through the update chain.
