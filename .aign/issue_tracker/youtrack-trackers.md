Derived from the YouTrack design, I would reduce the required issue-tracker contract to this:

* **Issues**

  * Create and persist issues.
  * Stable readable ID.
  * Summary/title and description/body.
  * Retrieve an issue and its current fields, comments, and links.
  * List/search issues.

* **Types**

  * Support classifications equivalent to:

    * Bug
    * Feature
    * Task
    * Epic

* **Lifecycle state**

  * Support states equivalent to:

    * Submitted
    * Open
    * In Progress
    * To be discussed
    * Fixed
    * Won't fix
    * Duplicate
  * Change and query issue state.

* **Comments**

  * Retrieve the complete ordered comment history.
  * Add comments.
  * Preserve comments as durable history rather than rewriting prior decisions.

* **Ownership / claims**

  * Assign an issue to a worker.
  * Determine whether an issue is assigned.
  * Assignment acts as the concurrency claim.

* **Relationships**

  * Parent/child relationships.
  * Blocking dependencies.
  * Duplicate relationships.
  * Non-blocking related relationships.
  * Retrieve an issue's relationships and the current state of referenced issues.

* **Work selection**

  * Determine the actionable frontier:

    * `Open`
    * unassigned
    * no unresolved blockers
  * Select work in a deterministic order when multiple issues qualify.

* **Resolution**

  * Mark completed work resolved.
  * Mark rejected work as rejected with an explanation.
  * Preserve resolved issues so they remain retrievable and referenceable.

That is essentially the tracker interface the skills need:

**create, retrieve, list/search, classify, transition, comment, assign, relate, inspect dependencies, select actionable work, and resolve issues.**

The Master Spec Article functionality is separate from this core issue-tracker contract.
