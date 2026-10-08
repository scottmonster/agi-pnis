# Failure Records

## 1. Scope and storage

A Failure Record (FR) records a detected failure. A Failure Update Record (FUR) records later material information that changes, corrects, supplements, or identifies an error in an FR or FUR.

FRs and FURs are always material Violations. Each is one Markdown file in `.agents/records/failures/`. An FR filename is `<root-index>-FR-<slug>.md`, such as `001-FR-incorrect-rule.md`. An FUR filename is `<root-index>.<update-index>-FUR-<slug>.md`, such as `001.00-FUR-correction.md`. Root indexes have three digits and update indexes have two digits. The skill creates that directory when needed. Records are immutable and their files are the canonical record.

`record.index` matches the filename prefix. An FUR uses the root index of its originating FR and the next unused update index for that lineage. `record.id` remains the stable relationship identifier.

Use [episode.md](episode.md) for shared requirements, [schema.md](schema.md) for the data dictionary, and [failures.md](failures.md) for failure classification.

## 2. Record rules

### 2.1 FR qualification

Create an FR for a detected failure that matches one or more definitions in `failures.md` and is not a material update to an existing FR or FUR.

An FR identifies the matched failure IDs, the detection trigger, expectation, observed behavior, impact, and concise Violation statement. Place the matched definition's Record data in `failure.classification_data`.

### 2.2 FUR qualification and lineage

Create an FUR when later material information changes an FR or FUR, including an investigation finding, containment, corrective action, validation, correction, recurrence, or outcome.

An FUR links to its immediately preceding FR or FUR with `update.subject_record_id`; its chain ultimately reaches an FR. It records only the material delta. It inherits unchanged failure classification, expectation, observed behavior, impact, and corrective actions from its predecessor. Include `failure.failure_ids` only when classification changes.

### 2.3 Investigation and corrective action

Every FR and FUR requires an Episode Investigation. Record matched definition Investigation data as named entries in `investigation.findings`.

Record the current prevention loci once in `failure.prevention_loci`. A completed Violation record or chain includes or inherits at least one recommended Corrective Action established through its Episode Investigation.

Distinguish observed information, inference, hypothesis, and unknown information. When material information is unavailable, state the limitation rather than inventing it.

## 3. Templates

The YAML blocks are concise Markdown templates, not required record serialization. Omit groups and fields that are not material. Add context, evidence, limitations, or execution context only where they materially qualify a group.

### 3.1 FR

```yaml
# FR: <title>
record:
  id: <stable ID>
  index: "<next three-digit root index>"
  record_type: FR
  title: <concise title>
  recorded_at: <time>
  event_at: <when material>
  source: <repository, project, or system>
  episode: <work reference>
  summary: <concise failure summary>

failure:
  failure_ids:
    - <matched failure ID>
  trigger: <signal or event that detected the failure>
  detected_at: <time>
  expectation: <what should have happened>
  observed: <what happened>
  impact:
    level: <none | low | medium | high | unknown>
    description: <effect>
    affected_scope: <affected work, system, or people>
  prevention_loci: <current prevention locations>
  classification_data:
    <matched record-data name>: <value>

violation:
  statement: <concise departure from expectation>

investigation:
  status: <in_progress | completed | deferred>
  findings:
    <matched investigation-data name>: <value>
  causal_status: <observed | inferred | hypothesized | unknown>

corrective_actions:
  - rule: <reusable instruction that prevents the pattern>
    description: <recommended action>
    target: <where it applies>
    status: recommended
```

### 3.2 FUR

```yaml
# FUR: <title>
record:
  id: <stable ID>
  index: "<originating root index>.<next two-digit update index>"
  record_type: FUR
  title: <concise title>
  recorded_at: <time>
  event_at: <when material>
  source: <repository, project, or system>
  episode: <work reference>
  summary: <concise update summary>
  relationships:
    - type: updates
      target_id: <immediately preceding FR or FUR>

update:
  subject_record_id: <immediately preceding FR or FUR>
  kind: <investigation | containment | corrective_action | validation | correction | recurrence | outcome | other>
  effect: <material change introduced by this record>

failure: # only changed fields
  failure_ids: <only when classification changes>
  trigger: <only when changed>
  detected_at: <only when changed>
  expectation: <only when changed>
  observed: <only when changed>
  impact:
    level: <only when changed>
    description: <only when changed>
    affected_scope: <only when changed>
  prevention_loci: <only when changed>
  classification_data:
    <changed matched record-data name>: <value>

violation: # only when changed
  statement: <only when changed>

investigation: # only changed findings or state
  status: <only when changed>
  findings:
    <changed matched investigation-data name>: <value>
  causal_status: <only when changed>
  evidence: <only when changed>
  limitations: <only when changed>

corrective_actions: # only changed or newly recommended actions
  - rule: <only when changed or newly established>
    description: <action>
    target: <only when changed>
    status: <recommended | accepted | implemented | rejected>
    validation: <only when changed or performed>
```
