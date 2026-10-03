A **Violation** is an action, omission, condition, or materially incorrect assumption that departs from an applicable requirement, constraint, or expected behavior, warrants correction or other response, and **requires at least one recommended corrective action** in the record.

An **Episode Investigation** is a bounded, evidence-based inquiry into a detected episode that establishes the expected and observed behavior, relevant context and impact, available explanations, and prevention loci.

A **Corrective Action** is an action taken in response to a violation to correct the departure, repair or limit its effects, restore the required state, or reduce the likelihood of recurrence.

A **Concern** is an action, omission, condition, or material change that does not constitute a violation but departs from, alters, or calls into question an expected state or prior judgement sufficiently to warrant attention, review, or other proportionate response.



# Judgement Records

## JR — Judgement Record

**Purpose:** Preserves a qualifying material judgement, whether later shown to be sound or unsound.

**Rules**

* **NOT A VIOLATION**
* Immutable: cannot be updated or deleted; later material changes require a **JUR**.
* **Records:** TBD

### User-Triggered JR

Created when the user explicitly requests that a material judgement be recorded.

* **ALWAYS user-activity**
* **MUST NEVER** be recorded as agent-activity

### Agent-Triggered JR

Created when the agent determines that an interaction establishes or requires a material judgement.

* **User-activity:** user answers questions, completes structured input, or makes a decision/judgement that establishes a material judgement.
* **Agent-activity:** agent answers questions, completes structured input, or makes a decision/judgement that requires a material judgement.

**Trigger/activity constraint:**
A **user-triggered JR** is always **user-activity**. An **agent-triggered JR** may arise from either **user-activity** or **agent-activity**.

---

## JUR — Judgement Update Record

**Purpose:** Records later material information that changes, corrects, supplements, or identifies an error in an existing JR/JUR.

**Rules**

* Must link to the preceding **JR/JUR** and ultimately trace back to a **JR**.
* Immutable: further material changes require another **JUR**.
* **Not created for:** implementation or successful validation that does not materially change the judgement.
* **Records:** TBD

### Status

| Previous Record     | Current Activity   | Status              |
| ------------------- | ------------------ | ------------------- |
| **User-triggered**  | **User-activity**  | **NOT A VIOLATION** |
| **User-triggered**  | **Agent-activity** | **CONCERN**         |
| **Agent-triggered** | **Any activity**   | **VIOLATION**       |

### Interpretation

* **NOT A VIOLATION:** the user materially updates a user-originated judgement.
* **CONCERN:** the agent materially updates a user-originated judgement.
* **VIOLATION:** an agent-triggered judgement requires material correction or update, regardless of whether the later information comes from the user or agent.

---

# Failure Records

**Failures are ALWAYS MATERIAL.**

## FR — Failure Record

**Purpose:** Records an actual detected failure.

**Status:** **ALWAYS A VIOLATION**, regardless of trigger or activity source.

**Rules**

* Immutable: cannot be updated or deleted; later material changes require a **FUR**.
* **Records:** TBD

---

## FUR — Failure Update Record

**Purpose:** Records later material information that changes, corrects, supplements, or identifies an error in an existing FR/FUR.

**Rules**

* **ALWAYS A VIOLATION**, regardless of trigger or activity source.
* Must link to the preceding **FR/FUR** and ultimately trace back to an **FR**.
* Immutable: further material changes require another **FUR**.
* **Records:** TBD




IF THE ABOVE INTENT/MEANING DOES NOT MATCH THE BELOW INTENT/MEANING NOTIFY USER!!!

---

## Judgement Record (JR)

**Purpose:** Preserves a qualifying material judgement, whether later shown to be sound or unsound.

**Rules applying to all JRs:**

* **IS NOT** a violation.
* **CAN NOT** be updated or deleted directly. Any later material change requires a **JUR**.
* Records:

  * TBD

### User-Triggered JR

Created when:

**User-Activity**
* The user explicitly asks for a record to be made for a material judgement.

**User-Triggered** JR is **ALWAYS** recorded as user-activity
**User-Triggered** `MUST NEVER` be recorded as agent-activity 

### Agent-Triggered JR

Created when the agent determines that an interaction establishes or requires a material judgement, including but not limited to:

**User-Activity**
* The user answers questions that the agent believes establish a user material judgement.
* The user completes a worksheet, questionnaire, or similar process that the agent believes establishes a user material judgement.
* The user makes a decision that the agent believes establishes a user material judgement.
* The user makes a judgement that the agent believes establishes a user material judgement.

**Agent-Activity**
* The agent answers questions that require material judgement.
* The agent completes a worksheet, questionnaire, or similar process that requires material judgement.
* The agent makes a decision that requires material judgement.
* The agent makes a judgement that requires material judgement.

---

## Judgement Update Record (JUR)

**Purpose:** Records later material information about an existing JR or JUR.

**Relationship rules:**

* A JUR **ALWAYS** links to an existing JR and/or previous JUR.
* Every JUR must ultimately trace back to a JR.
* A JR or JUR **CAN NOT** be updated or deleted directly. Further material changes require another JUR.

**Created when:**

* Later material information changes, corrects, supplements, or identifies an error in an existing JR/JUR.

**Not created when:**

* The information merely implements the judgement.
* The information successfully validates the existing judgement without materially changing it.

**Records:**

* TBD

#### User-Triggered JUR

Violation status depends on the trigger of the **immediately preceding JR/JUR**:

* Previous record was **user-triggered** → **IS NOT** a violation.
* Previous record was **agent-triggered** → **IS A VIOLATION**.

#### Agent-Triggered JUR

Violation status depends on the trigger of the **immediately preceding JR/JUR**:

* Previous record was **user-triggered** AND previous record was **user-activity** AND current record is **user-activity** → **NOT A VIOLATION**.
* Previous record was **user-triggered** AND previous record was **user-activity** AND current record is **agent-activity** → **CONCERN**.
* Previous record was **agent-triggered** AND previous record was **user-activity** AND current record is **user-activity** → **IS A VIOLATION**.
* Previous record was **agent-triggered** AND previous record was **user-activity** AND current record is **agent-activity** → **IS A VIOLATION**.
* Previous record was **agent-triggered** AND previous record was **agent-activity** AND current record is **user-activity** → **IS A VIOLATION**.
* Previous record was **agent-triggered** AND previous record was **agent-activity** AND current record is **agent-activity** → **IS A VIOLATION**.

Yes — with one important refinement.

Under the matrix you’ve defined, **the severity is primarily determined by what kind of record is being corrected/updated**, not simply by who performs the update.

So:

* If the **previous record was agent-triggered**, any material JUR against it is a **VIOLATION**. That includes the agent correcting itself, the user correcting it, or new user information revealing that the agent-triggered judgement was wrong.
* If the **previous record was user-triggered + user-activity**:

  * new **user-activity** updating it → **NOT A VIOLATION**
  * new **agent-activity** updating/correcting it → **CONCERN**

So your interpretation is right if by “updating user” you mean:

> **The agent is materially updating a judgement that originated explicitly from the user.**

That would be a **CONCERN**, not a violation.

The conceptual hierarchy becomes:

**NOT A VIOLATION**
User revises or updates their own explicitly triggered judgement.

**CONCERN**
Agent materially revises or corrects a judgement that the user explicitly established.

**VIOLATION**
A material revision/correction is required for a judgement that the **agent caused to be recorded as a material judgement**, regardless of whether the later corrective information comes from the user or agent.

That distinction is actually quite clean: **agent intervention into a user-owned judgement = concern; correction of an agent-originated judgement = violation.**

---

# Failure Records

**Failures are ALWAYS MATERIAL.**

## FR — Failure Record

**Purpose:** Records an actual detected failure.

**Status:** **ALWAYS A VIOLATION**, regardless of trigger or activity source.

**Rules**

* Immutable: cannot be updated or deleted; later material changes require a **FUR**.
* **Records:** TBD

---

## FUR — Failure Update Record

**Purpose:** Records later material information that changes, corrects, supplements, or identifies an error in an existing FR/FUR.

**Rules**

* **ALWAYS A VIOLATION**, regardless of trigger or activity source.
* Must link to the preceding **FR/FUR** and ultimately trace back to an **FR**.
* Immutable: further material changes require another **FUR**.
* **Records:** TBD
