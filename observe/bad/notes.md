





I am trying to build a durable, structured body of evidence about meaningful decisions made throughout my repositories, especially decisions involving agents. My goal is to preserve enough of each decision episode to understand not only what was decided, but what judgment was exercised, who exercised it, the context and constraints that shaped it, its rationale and scope, and how it relates to established project direction.

I want to use these records for documentation and review now, and eventually as a cross-project corpus for analyzing my decisions, agent decisions, and the degree to which agent judgment aligns with or diverges from mine. The accumulated evidence should also support deriving explicit guidance for future agents and, eventually, a workflow in which genuinely unresolved decisions can be surfaced to me and my answers preserved as durable decisions or guidance.

The records should retain enough original context and qualification to support later generalization and conceptual analysis without overstating local decisions as universal rules. In particular, distinctions between source-specific decisions, broader principles, authority, scope, conditions, exceptions, and related project direction need to remain recoverable. The result should be useful as structured decision-making evidence, not merely as an audit trail or collection of final outcomes.




**Status: Strictly non-authoritative reference material.**

This document is informational only. It creates no requirements, specifications, decisions, policies, obligations, approvals, interpretations, or binding guidance of any kind. Do not treat any part of it as controlling, implied, or actionable unless an authoritative source explicitly adopts the specific content at issue. In any conflict or ambiguity, authoritative sources control without exception.


read /home/scott/Documents/agi-pnis/gov-lab/observe/.archive/* for context

------

I am trying to build a durable, structured body of evidence about meaningful decisions made throughout my repositories, especially decisions involving agents. My goal is to preserve enough of each decision episode to understand not only what was decided, but what judgment was exercised, who exercised it, the context and constraints that shaped it, its rationale and scope, and how it relates to established project direction.

I want to use these records for documentation and review now, and eventually as a cross-project corpus for analyzing my decisions, agent decisions, and the degree to which agent judgment aligns with or diverges from mine. The accumulated evidence should also support deriving explicit guidance for future agents and, eventually, a workflow in which genuinely unresolved decisions can be surfaced to me and my answers preserved as durable decisions or guidance.

The records should retain enough original context and qualification to support later generalization and conceptual analysis without overstating local decisions as universal rules. In particular, distinctions between source-specific decisions, broader principles, authority, scope, conditions, exceptions, and related project direction need to remain recoverable. The result should be useful as structured decision-making evidence, not merely as an audit trail or collection of final outcomes.

i have: /home/scott/Documents/agi-pnis/gov-lab/.agents/gov/policy/execution/judgement_record.md

this is for judgements. and i think it is a good standard for judgements. i wanted judgements at the time, not a complete trackign and failure system. the reason i didn't want a full tracking and failure system is because i want to make sure this stays harness agnostic. i don't want it to be limited to working on just a single harness. 

Some of the old documents in /home/scott/Documents/agi-pnis/gov-lab/observe/.archive/* discuss creating a full tracking system, but I did not want a full tracking and failure system because I want this to remain harness-agnostic, rather than being limited to a single harness.

does that make sence? idk how to put what im trying to say into words.


Yes. that is true. now i want to develop a second standard that  acts as an extension of the judgement_record.md. the idea is that judgement_record.md can remain the judgement record standard and the new standard will incorperate everything else **when available**









- **Token Saturation**: (0–100%) Measure of window usage.
- **Noise Profile**: (1–5 scale) 1 = Clean/Low, 5 = Critical Noise.
- **Relevance Delta**: (1–5 scale) 1 = Hyper-Focused, 5 = Incoherent.
- **Action**: If **Relevance Delta** $>3$, the agent SHOULD perform context pruning (summarizing logs, removing irrelevant files) and indicate that it did so.




So now we have:
/home/scott/Documents/agi-pnis/gov-lab/observe/large_list.md
/home/scott/Documents/agi-pnis/gov-lab/observe/failure_modes.md
/home/scott/Documents/agi-pnis/gov-lab/observe/failure_index.md

do we need to update:
/home/scott/Documents/agi-pnis/gov-lab/observe/failure_modes.md

to point at one or both of those files

what is the next step?


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







So going back to:

I would consolidate to three documents, not one:
Material Judgment Records
Keep judgement_record.md as the specialized standard for settled, governing judgment. It is already coherent and should not be diluted by routine episode or failure material.

Material Episode Evidence Standard
Evolve evidence_standard.md into the unifying operational standard. It defines the material episode, available evidence, outcome assessment, optional failure classification, and optional links to MJR/JFR records.
This becomes the answer to: “What do we preserve about a meaningful episode, whether it succeeded, failed, or involved judgment?”

Failure Catalogue
Merge these into one document:
failure_modes.md
failure_index.md
large_list.md
Its structure should be:
Failure Catalogue
  1. Cross-harness analytical modes
     - judgment, context, planning, verification, environment, measurement, etc.
  2. Prevention loci
     - agent-level, tool-level, shared, task/external, unresolved
  3. Detailed coding-agent patterns
     - the current evidence-labelled large list

The compressed index should become the headings and navigation within the catalog, not a separate file. The cross-harness modes should become a short analytical section near the beginning, not a separate file. The detailed patterns and evidence labels remain the substantial reference section.
I'm thinking we have




we can make a note that `what data from the schema is required for recording and what data defines a complete report **"when available"**` will be established later. 


update /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episodes.md





make no changes. lets discuss:

just to be clear, we will be building this inside of: /home/scott/Documents/agi-pnis/gov-lab/observe/episodes
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode_record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/judgement_record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure_catalog.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode_record.schema.json

While keeping these for reference:
/home/scott/Documents/agi-pnis/gov-lab/observe/evidence_standard.md
/home/scott/Documents/agi-pnis/gov-lab/observe/failure_index.md
/home/scott/Documents/agi-pnis/gov-lab/observe/failure_modes.md
/home/scott/Documents/agi-pnis/gov-lab/observe/judgement_record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/large_list.md

we will clean these up later. do NOT remnove them. I will do it. we should not remove the reference files.

-----

10.2 Schema detail

I thought we determined this was going to come from the existing 
/home/scott/Documents/agi-pnis/gov-lab/observe/judgement_record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/evidence_standard.md



The actual schema (episodes/episode_record.schema.json) would include everything define in observe/judgement_record.md and observe/evidence_standard.md so that way everything is valid.

for what judgement_record.md and failure_catalog.md need for reporting, id imagine it is as much as possible. that way we are covered for future analyzation BUT since we can't guarantee that we will be able to get everything we **WANT** in every harness that is when we start making heavy use of **"when available"**

each failure in failure_catalog.md will define the minimum required (since we are trying to keep this harness agnostic for now, we should probably only _require_, failure name, and harness name) and then everything else in the schema is **"when available"** for now. we can go back and add harness specific rules later on once we actually have something working


i think the observe/judgement_record.md already names somethings. this is mostly things that we can retrieve from the model directly. I had something working a while back using a skill. just to be clear this is NOT what i want to do, im just inlcuding the skill so you can get an idea of what i was doing. i have saved it here `observe/judgement-record/SKILL.md` so you can get an idea of what i was doing. instead of doing it like this we will be using the schema defined in episodes/episode_record.schema.json


calrify this prompt
```
create 4 subagents 1 per file

/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/judgement-record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure-catalog.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json

give each one a file to complete along with the file that we have been working on for reference:
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episodes.md

provide clear insruction on the purpose of the file it is building, what should be included in that file, and where it can find that information
```

So i think as the last part we need to define what to do on a failure


make no changes lets discuss:

i think as part of this we should define a couple of other things

Violation - an action, omission, condition, or materially incorrect assumption that departs from an applicable requirement, constraint, or expected behavior and warrants correction or other response.
Corrective Action - an action taken in response to a violation to correct the departure, repair or limit its effects, restore the required state, or reduce the likelihood of recurrence.

1. making a JR is _NOT_ a violation
2. makeing a JUR _IS_ a violation. it means either one of three things happened:
  1. the user was not clear enough with their intentions or what they wanted
  2. the agent ignored what the user said
  3. the agent made a poor assumption
3. making a FR _IS_ a violation that means a failure occured
4. making a FUR is _NOT_ a violation


I was already working on the _WHAT_ to do when a violation occurs. Just to be clear, i do not want to pull this word for word, i just want you to see what I was thinking. 

Agent-level preventable failures, Tool-level preventable failures, etc. we will need to adapt this as needed. but the general idea is still the same.... what were we doing when the failure occured, what was expected to happen, get releveant information, attempt to establish a corrective action, record everything.

you can see my original idea here: 
/home/scott/Documents/agi-pnis/gov-lab/prevent_review/prevent_review.md

I want to establish what to do when a violation occurs so we can have a direct path towards immediate feedback. ideally we would be questioning the agent who made the violation but that wont always be an option. the agent might be gone by the time a violating JUR/FR is generated, the violation might have come from a tool.... in which case we should probably ask an agent to analyze what happened and determine a corrective action if possible, etc. we don't necessarily HAVE to put the suggested corrective action into place, but we want to establish and record it.

with all of that in mind we kind of touch base on this here:
/home/scott/Documents/agi-pnis/gov-lab/prevent_review/prevent_review.md
and
/home/scott/Documents/agi-pnis/gov-lab/observe/failure_modes.md

what do you think is the best way to do this?







Create four subagents and assign exactly one file to each:

1. /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.md
2. /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/judgement-record.md
3. /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure-catalog.md
4. /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json

Each subagent must use this existing file as its primary reference:

/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episodes.md

Give each subagent clear, file-specific instructions that state:

- The purpose of its assigned file within the episode-observation system.
- The information, fields, sections, examples, and constraints the file must include.
- Which details to derive from `episodes.md`.
- Which related files or repository conventions to inspect if `episodes.md` does not provide enough detail.
- That it should make only the changes necessary for its assigned file and preserve existing compatible content.
- Any reference file or files they may need

The files should work together as a coherent documentation and data-model set:

`episode-record.md`: Shared protocol and routing layer—what kind of episode this is, the universal concepts, response path, record relationships, evidence availability, and which specialist document to load.
`judgement-record.md`: Judgment specialization—whether something qualifies as a JR/JUR and how that record is created, corrected, updated, or superseded.
`failure-catalog.md`: Failure specialization—what each failure means, when it applies, how to investigate it, relevant evidence, prevention loci, corrective-action options, and validation.
`episode-record.schema.json`: Shared machine-valid structure—the record fields, types, references, availability states, relationships, and controlled values.

After all subagents finish, review their outputs for consistency: shared terminology, matching field names, valid schema-to-documentation alignment, and no contradictory requirements.





no changes. lets discuss

What do you think about adding these to the /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json

- provider
- model name
- thinking level
- **Token Saturation**: (0–100%) Measure of window usage.
- **Noise Profile**: (1–5 scale) 1 = Clean/Low, 5 = Critical Noise.
- **Relevance Delta**: (1–5 scale) 1 = Hyper-Focused, 5 = Incoherent.


i have a note to add these:
I think provider and model name are strong additions. They make later cross-harness analysis possible, especially when comparing judgment or failure patterns across model versions. They should be optional, availability-aware fields in agent_context, not universally required.
thinking level is useful, but I would frame it as an open, provider-reported reasoning configuration rather than a universal scale. Different harnesses expose “effort,” “thinking,” token budgets, or nothing at all.
Token Saturation is valuable for diagnosing context-window and long-horizon failures, but it needs a measurement basis: tokens used, known context capacity, and whether the percentage was directly reported or estimated. Otherwise a percentage can look more precise than it is.



- provider
- model name
- thinking level




## Review: changes required

1. High — Failure field names diverge from the primary reference.

   Evidence: [episodes.md](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episodes.md:204) specifies `failure_name` and `harness_name`. The new protocol requires `failure.primary_name` and `failure.harness_name` ([episode-record.md](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.md:240)); the schema implements only the nested names ([episode-record.schema.json](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json:451)).

   Choose one vocabulary, then update the primary reference or all four deliverables consistently.

2. High — The schema accepts records that cannot satisfy the specialist standards.

   Evidence: the schema requires only `id`, `record_type`, and `schema_version` ([schema](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json:7)). During review, Draft 2020-12 validation accepted each of these records:

   ```json
   {"id":"anything","record_type":"FR","schema_version":"1"}
   {"id":"anything","record_type":"JUR","schema_version":"1"}
   {"id":"anything","record_type":"FUR","schema_version":"1"}
   ```

   This conflicts with the stated FR minimum fields ([failure-catalog.md](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure-catalog.md:27)), JUR minimum fields and linked JR ([judgement-record.md](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/judgement-record.md:165)), and FUR linkage and event requirements ([failure-catalog.md](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure-catalog.md:580)).

   Add record-type conditionals for publishable records, or explicitly define this as a partial-draft schema and add a publishable-record profile.

3. Medium — FUR event type has no machine-readable representation.

   Evidence: the catalog requires each FUR to identify its later event type ([failure-catalog.md](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure-catalog.md:39)). The schema provides `judgment.update_kind` only for judgment updates ([schema](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json:273)) and no failure-update equivalent. The optional relationship vocabulary lacks an `investigates` value and represents unsupported cases through `other` ([schema](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json:527)).

   Add a controlled FUR event field, such as `failure.update_kind`, and require it for FURs.

4. Medium — Required JR information lacks dedicated canonical fields.

   Evidence: the judgment standard requires retention of options considered, revisit triggers, and consequences or accepted trade-offs ([judgement-record.md](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/judgement-record.md:94)). The `judgment` object defines only judgment kind, update kind, settlement, basis, direction, rationale, scope, and subject record ([schema](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json:265)). Generic `claims` can store prose but has no controlled representation for these concepts ([schema](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json:385)).

   Add fields or document the exact canonical encoding for each requirement.

5. Medium — Availability cannot describe a wholly unavailable source, episode, or authority object.

   Evidence: `informationItem` requires `availability` ([schema](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json:188)), but `source`, `episode`, and `authority` do not ([schema](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json:212)). The judgment standard requires an availability state for material unavailable items ([judgement-record.md](/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/judgement-record.md:101)).

   Permit an availability/limitation wrapper for these objects, or define the approved fallback representation.

6. Verified strengths

   The schema is valid Draft 2020-12 JSON Schema. The documents route JR/JUR and FR/FUR cases consistently, use a coherent common vocabulary, include all 262 detailed failure patterns without gaps, and use category inheritance to provide investigation, prevention, corrective-action, validation, and escalation guidance.



1. I agree. `failure_name` and `harness_name` are the currently stated primary-reference terms, so the nested vocabulary should not have changed without explicitly updating that reference.

2. I agree with the problem. Either distinguish draft-envelope validation from publishable-record validation, or add record-type conditional requirements for durable records.

3. I agree. FUR needs its own controlled event type; it should not have to reuse JR/JUR terminology or rely on generic relationships.

4. I agree. Those are material judgment concepts, so they need dedicated fields or one clearly defined canonical encoding rather than implied prose storage.

5. I agree. Availability and retention limitations need to apply to source, episode, and authority evidence too, not only generic information items.


---

## User

1. use failure.name = failure_name failure.harness = harness_name (the failure_name and harness_name from episode.md are colloquial)

2. i agree

3. i agree

4. i agree

5. i agree

what can we do to address these

## Assistant


---
---


okay since  we are building this out more and more

lets discuss
This is still not what i want. there is still too much information in the failure-catalog.md what we want it for failure-record.md to contain everything needed and for failure-catalog.md to contain only the failures.

Is there a reason we can not or should not do that?



I think we are doing this wrong. I think we need to 1 settle on a "shape" for our failure-catalog.md so that everythin is unified

make no changes. lets discuss. 
read /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/*

**NOTE:** there are reference and implementation files in that dir
**Reference File:** /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episodes-convo.md
**Reference File:** /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episodes.md
**Implementation File:** /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.md
**Implementation File:** /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json
**Implementation File:** /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/judgement-record.md
**Implementation File:** /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure-record.md
**Implementation File:** /home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure-catalog.md

nearly all of `9. Failure-analysis and response guidance` seems clunky to me. and im not sure if it is even doing what i want, if it is just formated poorly, or if i didn't think it through all the way at first.

The general idea is to:
- Reference Layer - define all of the violations, failures, etc i want to check for, define what those failures are, their name, category, description, etc. how they should be investigated, what should be recorded, etc... This is the complete system, fully defined, not compressed at all.
- Prevention Layer - from those failures i could derive a set of much smaller and compact rules to hopefully prevent the behavior. this would be Short, actionable guidance, rules
- Review layer - failure names, categories, and short applicability cues


the idea is that we dont overload the context while writing code, but instead use the prevention layer.
when we are reviewing code, we still don't want to overload the context, but we need enough name to look at something and go "oh this failure might apply here" and then go pull the needed information to determine if it ias a failure. if it is a failure, load episode.md
and then use progressive loading to load only what is needed at any particular time.

I started to concieve of this concept here:
/home/scott/Documents/agi-pnis/gov-lab/prevent_review/prevent_review.md

I want the system to handle expansion easily so that i can add additional rules/failures later
I started to build out a similar system but i was not doing it coherently.
you can see that here:
**NOTE:** this should just be used as reference so you can get an idea of what i mean: /home/scott/Documents/agi-pnis/gov-lab/observe/.archive/old_failures_and_rules/**

Now i decided to pause the old work and actually start building it out inside of:
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes

Im not sure if this model conforms well to the progressive context loading model. 

I have not started implementing the prevent or review layer because i don't have the reference layer to work off of. 
i was trying to make:
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/judgement-record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure-record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure-catalog.md
just be the "Reference Layer" but it should still respect the progressive context loading.

Now i think there is 3 main reasons i dont like the current state of the episodes implementation
1. I'm not sure it lives up to what I had in mind for progressive context loading.
2. I think we need a standardized way of defining failures. that way they can be added in the future easier
3. `9. Failure-analysis and response guidance` seems very clunky to me, but that might be because of points 1 and 2


What are your thoughts?

now i think part of the reason i don't like `9. Failure-analysis and response guidance` is because im not sure with what i originally had in mind. 



make no changes lets disucss:
what would need to happen to update:
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/episode-record.schema.json
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/failure-record.md
/home/scott/Documents/agi-pnis/gov-lab/observe/episodes/judgement-record.md

according to:
/home/scott/Documents/agi-pnis/gov-lab/observe/episode-fix.md

short 1 - 2 scentence per file.


---
---

### Todo later

I’d model both as availability-aware objects, so absent telemetry is not mistaken for a zero value.

```json
"reasoning_configuration": {
  "availability": "available",
  "provider_setting_name": "reasoning_effort",
  "provider_setting_value": "high",
  "source": "runtime_metadata",
  "reference": {
    "kind": "run_configuration",
    "location": "..."
  },
  "note": "Provider-reported configuration; no cross-provider equivalence assumed."
}
```

Recommended reasoning-configuration fields:

- `availability`: the shared availability state.
- `provider_setting_name`: the provider or harness name for the setting, such as `thinking_level`, `reasoning_effort`, or `deliberation_budget`.
- `provider_setting_value`: the reported value, kept as an open string.
- `source`: `runtime_metadata`, `run_configuration`, `agent_report`, `operator_report`, `inferred`, or `unknown`.
- `reference`: optional durable link to the configuration evidence.
- `note`: optional qualification, including that settings are not cross-provider equivalent.

```json
"context_window": {
  "availability": "available",
  "used_tokens": 86000,
  "capacity_tokens": 128000,
  "saturation_percent": 67.2,
  "window_scope": "provider_defined",
  "measurement_basis": "calculated_from_reported_counts",
  "observed_at": "2026-08-18T12:34:56Z",
  "limit_reached": false
}
```

Recommended context-window fields:

- `availability`: the shared availability state.
- `used_tokens`: known tokens occupying the relevant context window.
- `capacity_tokens`: known usable context capacity.
- `saturation_percent`: `used_tokens / capacity_tokens × 100`, or a directly reported value.
- `window_scope`: `input_context`, `combined_context_and_output_reservation`, `provider_defined`, or `unknown`.
- `measurement_basis`: `directly_reported`, `calculated_from_reported_counts`, `estimated`, `inferred`, or `unknown`.
- `observed_at`: when the measurement applied.
- `limit_reached`: whether a context limit actually interrupted or constrained work, when known.
- `reference` and `note`: optional evidence and qualification.

I would avoid requiring `saturation_percent` whenever token data exists: some providers reserve output capacity or calculate usage differently. The counts, scope, and measurement basis make the percentage interpretable.



