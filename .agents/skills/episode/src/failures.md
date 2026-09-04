# Failure Catalog

Each heading's slug is its stable `failure_id`.

Match a definition by its Trigger and apply its Exclusions. Put its Record data in `failure.classification_data`. Put its Investigation data in named entries in `investigation.findings`. Shared expectation, observed behavior, impact, prevention loci, and Corrective Actions belong in the record standard, not in a definition.

## incorrect-rule-application - Incorrect Rule Application

**Trigger**

A materially applicable rule, requirement, or constraint was applied incorrectly, and the application materially affected the result.

**Exclusions**

- The rule was ambiguous and the record shows a reasonable interpretation.
- The departure was immaterial.
- The issue is only an unverified concern.

**Record data**

- `applicable_rule`

**Investigation data**

- `contributing_factors`

## unsupported-material-assumption - Unsupported Material Assumption

**Trigger**

A material result, judgement, or action relied on an assumption that lacked required support or was later shown to be false.

**Exclusions**

- The assumption was explicitly identified as uncertain and the work was appropriately bounded by that uncertainty.
- The assumption did not materially affect the result.
- The available evidence reasonably supported the assumption when it was used.

**Record data**

- `assumption`
- `basis_used`
- `missing_or_contrary_support`

**Investigation data**

- `assumption_origin`
- `available_evidence`
- `contributing_factors`

## unverified-completion-claim - Unverified Completion Claim

**Trigger**

Work was represented as complete, correct, or validated without evidence sufficient for the stated result, and that representation materially affected subsequent action or reliance.

**Exclusions**

- The claim was explicitly provisional or limited to completed subwork.
- Appropriate verification evidence existed but was not initially linked to the claim.
- The missing verification did not materially affect reliance or outcome.

**Record data**

- `completion_claim`
- `expected_verification`
- `verification_available`

**Investigation data**

- `claim_origin`
- `verification_gap`
- `contributing_factors`

## material-instruction-noncompliance - Material Instruction Noncompliance

**Trigger**

A material applicable instruction, constraint, or approved direction was not followed, and the departure materially affected the work or its result.

**Exclusions**

- The instruction was superseded, inapplicable, or impossible to follow, and that condition was identified and handled appropriately.
- The departure was authorized by an actor with authority to change the direction.
- The departure was immaterial.

**Record data**

- `applicable_instruction`

**Investigation data**

- `instruction_context`
- `contributing_factors`

## material-evidence-omission - Material Evidence Omission

**Trigger**

Material available evidence was omitted, ignored, or misrepresented in a judgement, review, or action, and the omission materially affected the result.

**Exclusions**

- The evidence was unavailable, unsafe to retain, or reasonably undiscoverable at the relevant time.
- The evidence was considered but did not materially affect the result.
- The issue is only a difference of interpretation rather than an omission or misrepresentation.

**Record data**

- `omitted_or_misrepresented_evidence`
- `evidence_relevance`
- `affected_judgement_or_action`

**Investigation data**

- `evidence_availability`
- `omission_mechanism`
- `contributing_factors`
