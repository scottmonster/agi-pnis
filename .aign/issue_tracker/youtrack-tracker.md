* **Records**

  * Create and persist individually addressable records.
  * Support work issues plus:

    * `JR` - Judgment Record
    * `JUR` - Judgment Update Record
    * `FR` - Failure Record
    * `FUR` - Failure Update Record
  * Each record has:

    * stable ID
    * type
    * title/summary
    * body
    * lifecycle state
    * creation/update metadata

* **Stable identity**

  * Every record has a permanent canonical ID.
  * Tracker/backend IDs and physical locations may differ from the canonical ID.
  * Records remain retrievable and referencable after closure or migration.
  * Support lookup by canonical ID.

* **State**

  * Support explicit lifecycle states equivalent to:

    * submitted/untriaged
    * ready/open
    * claimed/in progress
    * needs discussion/information
    * resolved
    * rejected
    * duplicate
  * Allow filtering/querying by state.

* **Classification**

  * Support record classifications/types.
  * Work records need distinctions such as bug, feature, task, and epic.
  * Material episode records need JR, JUR, FR, and FUR.
  * Failure records must additionally support the classifications defined by `failure_catalogue.md`.

* **Comments and history**

  * Retrieve the complete ordered history of comments.
  * Append comments with author and timestamp.
  * Preserve the original record rather than silently rewriting historical meaning.
  * Record substantive changes, corrections, decisions, and outcomes as durable history.

* **Updates**

  * A `JUR` must reference the `JR` it updates.
  * A `FUR` must reference the `FR` it updates.
  * Updates are first-class records, not merely comments.
  * A record may have multiple ordered updates over time.

* **Relationships**

  * Support durable typed relationships between records.
  * At minimum:

    * parent/child
    * depends on
    * duplicate of
    * relates to
    * updates
  * Determine the current state of referenced records.
  * Allow relationships to work across ordinary issues, JR/JUR, and FR/FUR records.

* **Evidence references**

  * Records must be able to reference:

    * other records
    * tasks/issues
    * repositories
    * artifacts
    * tests/results
    * external evidence
  * The tracker does not need to store all evidence itself.

* **Query and discovery**

  * List/search records by:

    * ID
    * type
    * state
    * classification
    * project/repository/scope
    * related record
  * Enumerate children and updates of a record.
  * Preserve deterministic ordering where workflows depend on it.

* **Claims and concurrency**

  * Claim a work record before acting on it.
  * Determine whether another worker/session has already claimed it.
  * Identify actionable work as open, unclaimed, and free of unresolved blockers.

* **Resolution**

  * Resolve/close records while preserving their content, history, evidence, and relationships.
  * Rejected and duplicate records remain discoverable.
  * Later events do not overwrite the original record. They produce comments or, for material episode changes, JUR/FUR records.

* **Migration**

  * Migration between tracker implementations must preserve:

    * canonical IDs
    * record types
    * record content
    * lifecycle state
    * comments/history
    * relationships
    * classifications
    * evidence references
    * JR/JUR and FR/FUR lineage
