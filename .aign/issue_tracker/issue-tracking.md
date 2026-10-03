# Tracking Work

* **Issues**

  * Create and persist issues.
  * Each issue has a stable identifier, title, body, and open/closed state.
  * Retrieve an issue by identifier or reference.
  * Update an issue's body.
  * List issues in a deterministic order.

* **Classification**

  * Assign and change classifications equivalent to:

    * `bug`
    * `enhancement`
    * `needs-triage`
    * `needs-info`
    * `ready-for-agent`
    * `ready-for-human`
    * `wontfix`
  * List/filter issues by classification and open/closed state.

* **Comments**

  * Retrieve the complete ordered comment history.
  * Post comments.
  * Comments expose author and timestamp information.

* **Relationships**

  * Reference one issue from another.
  * Group related issues, including a parent/map and its child tickets.
  * Represent `blocked by` dependencies.
  * Determine whether dependencies are resolved.

* **Claims**

  * Mark a ticket as claimed before work begins.
  * Determine whether another session has already claimed it.

* **Selection**

  * Determine which tickets are currently actionable:

    * open
    * unclaimed
    * all blockers resolved
  * Select them in a deterministic order.

* **Lifecycle**

  * Close/resolve issues.
  * Preserve resolved issues so they can still be retrieved and referenced.

