# Episode Record Data Schema

## 1. Purpose

This lightweight data dictionary describes information a JR, JUR, FR, or FUR can carry. The YAML blocks show field structure only. A record may use Markdown sections, lists, or YAML; it does not require YAML frontmatter or another serialized format.

Include only materially applicable information. When material information is unavailable, unknown, not collected, unsafe to retain, or not applicable, state that limitation rather than inventing a value.

## 2. Shared representations

```yaml
availability:
  status: available | unknown | not_collected | unsafe_to_retain | not_applicable
  limitation: # concise explanation when material

reference:
  kind: task | conversation | file | commit | test | issue | URL | record | other
  location:
  revision: # when the reference can change
  summary:

relationship:
  type: updates | supersedes | corrects | caused | relates_to | implements | validates | other
  target_id:
  note:
```

An optional field or group may use `availability`. Prefer safe references and concise summaries to sensitive or voluminous material.

## 3. Record groups

### 3.1 Common record information

```yaml
record:
  id:
  record_type: JR | JUR | FR | FUR
  title:
  recorded_at:
  event_at: # when different from recorded_at or material
  source:
  episode:
  summary:
  relationships:
```

`recorded_by`, actors, context, evidence, limitations, and execution context are not universal groups. Add them beside the group they qualify only when material.

### 3.2 Judgement information

```yaml
judgement:
  kind: decision | interpretation | assumption | tradeoff | conflict_resolution | scope_boundary | exception | other
  trigger: user | agent
  activity: user | agent
  statement:
  basis:
  scope:
  rationale:
  revisit_triggers:
```

For a JR, `trigger` and `activity` describe the recorded judgement. For a JUR, they describe the material update. A user-triggered JR is always user-activity.

```yaml
update: # JUR or FUR only
  subject_record_id: # immediately preceding record
  kind: correction | supplement | changed_information | investigation | containment | corrective_action | validation | recurrence | outcome | other
  effect:
  assessment: not_a_violation | concern | violation # JUR only
```

Following a JUR's `subject_record_id` reaches a JR. Following an FUR's reaches an FR.

### 3.3 Failure information

```yaml
failure: # FR, or changed fields in an FUR
  failure_ids: # stable IDs from failures.md; FUR only when classification changes
  trigger: # signal or event that detected the failure
  detected_at:
  expectation:
  observed:
  impact:
    level: none | low | medium | high | unknown
    description:
    affected_scope:
  prevention_loci:
  classification_data:

violation: # when applicable
  statement:
```

`failure.trigger` is distinct from a JR or JUR user-or-agent trigger. A FUR inherits unchanged classification and failure information through `update.subject_record_id`.

### 3.4 Investigation and corrective action

```yaml
investigation: # only when performed
  status: not_started | in_progress | completed | deferred
  findings: # named findings, including failure-specific investigation data
  causal_status: observed | inferred | hypothesized | unknown
  evidence: # references or concise summaries when material
  limitations:

corrective_actions: # required to complete a Violation record or chain
  - description:
    target:
    status: recommended | accepted | implemented | rejected
    validation: # when performed
```

For an FR or FUR, record the current prevention loci in `failure.prevention_loci`. For a JUR investigation, use `investigation.findings.prevention_loci`.

A Violation may be recorded before its recommended Corrective Action is known. It is complete only when it includes or inherits at least one recommended Corrective Action established through its Episode Investigation.

### 3.5 Optional execution context

```yaml
execution_context: # only when material
  summary:
  references:
```

Use execution context only when technical, instructional, environmental, model, tool, or runtime information materially explains the episode, result, or limitation. Do not retain a telemetry inventory or raw logs by default.
