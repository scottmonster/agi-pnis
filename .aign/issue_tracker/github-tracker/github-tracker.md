# GitHub Tracker Compatibility Contract

This is the minimum tracker-facing contract used by the installed Matt Pocock skills in this configuration. A replacement does not need to emulate GitHub, the `gh` CLI, GitHub's database IDs, or GitHub's rendering; it `MUST` provide the behaviors below through whatever interface the repository's tracker guide documents.

## 1. Scope

### 1.1 Evidence used

This inventory is based on the configured `AGENTS.md` and `docs/agents/issue-tracker.md`, the installed `to-spec`, `to-tickets`, `triage`, `wayfinder`, `ask-matt`, `prototype`, and merge-conflict skills, and their supporting triage documents. The setup template and transcript confirm that the configured guide is the intended adapter for those skills.

### 1.2 Configuration boundary

The guide sets “PRs as a request surface” to `no`. Therefore, pull-request discovery, diffs, author-association filtering, and the shared GitHub issue/PR number space are not part of this configuration's minimum issue-tracker contract. They become relevant only if that flag is deliberately changed.

## 2. Required issue capabilities

### 2.1 Create and identify issues

A tracker `MUST` create and persist an issue with a title and a multi-line Markdown-capable description/body. Creation `MUST` return a stable tracker identifier and a durable reference or link so later issues, comments, map entries, and user input can refer to it.

The identifier need not be a GitHub-style number or have a separate database ID. It only needs to be usable to retrieve the issue and create relationships after the issue exists. `to-tickets` deliberately creates blockers before dependents so their identifiers can be recorded.

### 2.2 Retrieve a complete issue

A tracker `MUST` retrieve an issue from the identifier or durable reference supplied by the user or another issue. The result `MUST` expose at least its identifier, title, body, open/closed state, labels or equivalent classifications, author, creation/update dates, and complete ordered discussion.

`to-tickets` reads a referenced spec's full body and comments. `triage` reads body, comments, labels, author, and dates, and parses earlier triage notes. `wayfinder` loads a map, then fetches related or closed tickets on demand.

### 2.3 Update issue content

A tracker `MUST` update an existing issue's body after creation. This is required to maintain a wayfinder map's Notes, Decisions-so-far, Not-yet-specified, and Out-of-scope sections; to add textual relationship fallbacks; and to revise invalidated tickets.

The installed skills do not require arbitrary title editing. They require preserving titles as the human-facing names of maps and tickets.

### 2.4 List and select issues

A tracker `MUST` list issues and return machine-readable records containing at least identifier, title, body, labels, and comment text. It `MUST` support selecting open or closed issues and filtering by a label/equivalent classification. It `MUST` make it possible to identify issues with no triage classification.

Triage additionally needs creation ordering, or an equivalent oldest-first ordering, to show these three open buckets: untriaged, `needs-triage`, and `needs-info` whose reporter replied after the last triage notes. The last bucket requires ordered comments with author and timestamp data when the full issue is retrieved.

No installed skill requires full-text issue search, arbitrary sort modes, pagination behavior, milestones, projects, reactions, or saved queries.

### 2.5 Labels and triage roles

A tracker `MUST` add, remove, inspect, and filter by multiple classifications on an issue. Labels are the configured mechanism, but an equivalent tagged-state mechanism is sufficient.

The triage workflow requires exactly one category role, `bug` or `enhancement`, and exactly one state role. The configured state-role mapping is:

| State role | Required meaning |
| --- | --- |
| `needs-triage` | Awaiting maintainer evaluation |
| `needs-info` | Waiting for reporter information |
| `ready-for-agent` | Fully specified and available to an AFK agent |
| `ready-for-human` | Requires human implementation or judgment |
| `wontfix` | Will not be actioned |

The tracker `MUST` allow a state-role transition to replace a conflicting old state role. An unclassified issue normally moves to `needs-triage`; `needs-info` returns to `needs-triage` after a reporter reply; a maintainer `MAY` override the normal transition. `to-spec` and `to-tickets` apply `ready-for-agent` when they publish agent-ready work.

Wayfinder also classifies its records with `wayfinder:map` and one ticket type: `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling`, or `wayfinder:task`.

### 2.6 Comments and conversation history

A tracker `MUST` retrieve all comments in chronological order and post an append-only comment to an issue. A comment needs body text; full retrieval also needs author and date information for triage's reporter-activity test. The skills use comments for triage notes, an authoritative agent brief, rejection/closing explanations, a wayfinder resolution answer, and links to supporting artifacts.

Every triage-created comment or issue body begins with the required AI-triage disclaimer. This is a content convention, not a special tracker field.

The installed skills do not require editing or deleting comments, reactions, threaded replies, or comment attachments.

### 2.7 Lifecycle state

A tracker `MUST` expose whether an issue is open or closed, list by that state, and close an issue. Closing is used to reject a request as `wontfix`, resolve a wayfinder ticket after posting its answer, and remove an out-of-scope ticket from the wayfinding frontier.

The skills do not call for reopening issues. A replacement `MAY` provide it, but reopening is not required by this configuration.

### 2.8 Relationships, references, and dependencies

A tracker `MUST` let issue bodies and comments contain durable references/links to other tracker records and external context pointers. It `MUST` support these semantics:

- Parent/child grouping for a wayfinder map and its tickets, with a deterministic child order.
- A “blocked by” relationship from a ticket to one or more prerequisite tickets.
- Resolution of a referenced ticket so the agent can determine whether each blocker is closed.

Native sub-issue and blocking relationships are preferred because they are visible in the tracker UI, but they are not mandatory: both the skill and the configured GitHub guide explicitly permit body-based fallbacks such as `Part of #…` and `Blocked by: #…, #…`. An adapter using those fallbacks `MUST` still enumerate a map's children and evaluate each dependency's live open/closed state.

The GitHub guide's separate numeric database ID for the dependency API is an adapter detail, not a replacement requirement.

### 2.9 Claims and concurrency

A tracker `MUST` show whether an open wayfinder ticket is claimed and let the current developer claim it before work begins. The GitHub adapter uses assignment to the current user; any equivalent exclusive, inspectable claim is compatible.

Given a map, the tracker `MUST` support the frontier query: open child tickets, excluding claimed tickets and tickets with any open blocker, ordered deterministically so the first ticket can be selected. The guide uses map order. The skill assumes other sessions can modify the tracker concurrently, so a claim needs to persist before the agent starts work.

## 3. Required workflow semantics

### 3.1 Publishing specs and implementation tickets

`to-spec` publishes one issue containing the generated specification and marks it `ready-for-agent`. `to-tickets` publishes one issue per approved vertical slice, in dependency order, with a title, behavioral description, acceptance criteria, and references to blockers. If its source was an existing issue, each child ticket also records that parent reference. `to-tickets` does not close or modify the parent issue.

### 3.2 Triage

Triage uses the tracker as a request queue. It `MUST` distinguish untriaged requests from the five state roles, preserve the full prior discussion, and record the chosen outcome as labels/equivalent state plus a new comment where required. A `ready-for-agent` or `ready-for-human` outcome gets a structured brief comment; `needs-info` gets structured triage notes; `wontfix` gets an explanation before or while closing.

The rejected-enhancement knowledge base lives in `.out-of-scope/`, not in the tracker. The tracker need only allow the resulting comment to link to that local record and close the issue with `wontfix`.

### 3.3 Wayfinder

Wayfinder uses an issue as a mutable map and child issues as decision tickets. It creates the map first, creates currently knowable tickets, then wires dependencies in a second pass. A claimed ticket is resolved by posting the answer as a comment, closing it, and appending a one-line linked gist to the map's Decisions-so-far. Newly discovered tickets can then be created and wired; fog text is removed from the map once represented by tickets.

An out-of-scope existing ticket is closed and linked from the map's Out-of-scope section rather than treated as a resolved decision. The skill says invalidated tickets `MAY` be updated or deleted, but deletion is not a minimum capability because updating/closing supplies the required behavior.

## 4. Data-exchange requirements

The documented GitHub list command projects records to `number`, `title`, `body`, label names, and comment bodies as JSON. A replacement need not reproduce that exact JSON shape or use `jq`, but its documented integration `MUST` provide an equally reliable machine-readable listing for these fields and the state/label filters above.

For complete retrieval, the integration `MUST` also expose the discussion's author and timestamps, issue author, dates, and claim/assignee information. These fields support workflow decisions even though the example list projection omits some of them.

## 5. Deliberately excluded features

The installed skills do not rely on comment editing, issue reopening, title editing, full-text tracker search, priority fields, milestones, projects/boards, estimates, due dates, watchers, reactions, attachments/uploads, GitHub-specific IDs, or pull-request handling under this configuration. External artifacts are linked as normal context pointers; the tracker does not need asset storage.
