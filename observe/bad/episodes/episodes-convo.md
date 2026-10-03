**Status: Historical conversation; non-authoritative.**

This transcript preserves prior discussion and may use superseded terminology. The current failure-record standard is `failure-record.md`; the current failure taxonomy is `failure-catalog.md`.

## User

well lets pause for a second. and discuss this.
we have:
/home/scott/Documents/agi-pnis/gov-lab/observe/judgement_record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/evidence_standard.md


Which is great for judgements but it doesn't catch all of the failures we have defined in:
/home/scott/Documents/agi-pnis/gov-lab/observe/large_list.md
/home/scott/Documents/agi-pnis/gov-lab/observe/failure_modes.md
/home/scott/Documents/agi-pnis/gov-lab/observe/failure_index.md


if we want to truly expand thenn we need to set a way to do that to unify everything. 

right now the concept is just kind of all over the place. but we need to pause for a second to determine how to expand while staying harness agnostic. we need to make heavy use of detecting and reporting **when available**

what do you think the best way is to unify the idea of reporting judgement and failures? ... i guess a judgement is also a type of failure... idk. what are your thoughts?

## Assistant

Yes: the unifying concept should be a **material work episode**, not a judgment and not a failure.

A judgment is not a type of failure. It is an exercise of discretion that can be sound, unsound, later disproved, or never implicated in the outcome. Treating every judgment as a failure would lose the successful and well-calibrated examples you need to compare human and agent judgment.

Likewise, many failures do not result from a material judgment: a missing tool capability, a stale dependency, a context-window limit, a broken evaluator, or an external outage.

## 1. A unified model

```text
Material work episode
  ├─ intended outcome and constraints
  ├─ available evidence and execution context
  ├─ observed outcome and evaluation
  ├─ zero or more failure/deviation classifications
  ├─ zero or more material judgments
  └─ later follow-up, review, remediation, or outcome evidence
```

The records fit this model as distinct layers:

| Layer | Role |
| --- | --- |
| `judgement_record.md` | Governing, settled material discretion: authority, scope, rationale, and direction. |
| `evidence_standard.md` | Available evidence surrounding the episode: context, artifacts, execution, outcome, evaluation, and later analysis. |
| `failure_modes.md` | Harness-agnostic analytical lenses for understanding what may have failed. |
| `failure_index.md` | Compressed coding-agent prevention taxonomy. |
| `large_list.md` | Detailed coding-pattern catalogue and evidence basis. |

The last three are classification vocabularies. They should not become record types by themselves.

## 2. The important expansion

The evidence standard should eventually become an **episode evidence standard**, rather than only a judgment-evidence extension.

It should allow a material episode to exist with:

- No failure and no MJR.
- A material failure but no MJR.
- One or more MJR/JFR links when a material judgment was involved.
- Available evidence only, without requiring traces, tool logs, task contracts, or any particular harness.

That is how you remain harness-agnostic. The standard specifies what evidence means and how it relates; it does not prescribe how a harness must emit it.

## 3. “When available” needs an explicit meaning

For each kind of evidence—task reference, effective context, tool result, test, user feedback, evaluator, agent runtime, replay result—the episode should be able to say:

- linked and available;
- unavailable;
- not collected;
- unsafe or restricted to retain; or
- not applicable.

This makes absence informative without inventing evidence or forcing full tracking.

## 4. The key decision boundary

Create an episode-level record only when preserving it can materially improve later review, learning, or future direction—for example:

- a meaningful deviation or safety concern;
- a recurring or novel limitation;
- disagreement between agent and human judgment;
- a material success that establishes a useful comparison case;
- an episode that leads to a judgment, remediation, or explicit guidance.

Routine tool errors, ordinary failed tests, and complete execution traces remain outside the durable record unless they are material evidence for one of those episodes.

## 5. The next design task

Before changing files, define the smallest possible **material episode record**: its qualification threshold, identity, links to evidence, outcome assessment, optional failure classifications, and optional MJR/JFR relationships.

That is the bridge that unifies judgment and failure evidence without turning the system into a harness-specific run tracker.

## User

Well I also thijnk we have too many documents. part of the unification should be consolidating this. into less files so that it isn't so difficult to keep track of

## Assistant

I agree. Five separate documents is too many entrypoints for one concept.

I would consolidate to three documents, not one:

1. **Material Judgment Records**  
   Keep `judgement_record.md` as the specialized standard for settled, governing judgment. It is already coherent and should not be diluted by routine episode or failure material.

2. **Material Episode Evidence Standard**  
   Evolve `evidence_standard.md` into the unifying operational standard. It defines the material episode, available evidence, outcome assessment, optional failure classification, and optional links to MJR/JFR records.

   This becomes the answer to: “What do we preserve about a meaningful episode, whether it succeeded, failed, or involved judgment?”

3. **Failure Catalogue**  
   Merge these into one document:

   - `failure_modes.md`
   - `failure_index.md`
   - `large_list.md`

   Its structure should be:

   ```text
   Failure Catalogue
     1. Cross-harness analytical modes
        - judgment, context, planning, verification, environment, measurement, etc.
     2. Prevention loci
        - agent-level, tool-level, shared, task/external, unresolved
     3. Detailed coding-agent patterns
        - the current evidence-labelled large list
   ```

The compressed index should become the headings and navigation within the catalogue, not a separate file. The cross-harness modes should become a short analytical section near the beginning, not a separate file. The detailed patterns and evidence labels remain the substantial reference section.

That gives you a simple architecture:

```text
How to record an episode:
  Material Episode Evidence Standard
  └─ links to Material Judgment Records when judgment is material

How to classify a failure:
  Failure Catalogue
```

I would not merge the judgment standard into the episode-evidence standard yet. It has its own mature qualification, authority, immutability, and precedent model. Keeping it separate preserves an important distinction while reducing the overall system from five documents to three.

## User

well since we are also recording more than just judgements shouldn't "Material Judgment Records" become "Material Episode Records"?

## Assistant

Yes—the umbrella should become **Material Episode Records**.

But I would keep a **Material Judgment Record** as a specialized record type within that broader standard.

```text
Material Episode Record
  ├─ judgment episode
  ├─ deviation or failure episode
  ├─ outcome or review episode
  └─ material success/comparison episode
```

Every material episode can preserve, when available:

- The work, scope, intended outcome, and constraints.
- Relevant actors, agent context, and evidence.
- Observed outcome and evaluation.
- Failure-mode and catalogue classifications, if there was a deviation.
- Links to later review or remediation.

A **judgment episode** adds the things only judgment requires:

- What discretion was required.
- Who had authority.
- What was settled.
- Scope, precedent, direction, and rationale.

So the central distinction becomes:

> Every MJR is a Material Episode Record, but not every Material Episode Record is an MJR.

This lets you preserve significant failures that involve no governing judgment, while retaining the rigor of the existing judgment model for decisions that do govern future work.

I would not make “failure” the umbrella. Material successful episodes and correctly handled uncertainty are needed to understand agent limitations and alignment. “Material episode” holds judgment, success, failure, review, and learning without treating any of them as the default.












