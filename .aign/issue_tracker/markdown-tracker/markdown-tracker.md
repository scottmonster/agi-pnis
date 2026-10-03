# Local Markdown Tracker Compatibility Contract

This is the minimum tracker-facing contract demonstrated by the Markdown configuration of the installed Matt Pocock skills. A replacement does not need to use `.scratch/`, files, headings, or Markdown; it `MUST` preserve the equivalent behaviors and make them clear in the repository's tracker guide.

## 1. Scope

### 1.1 Evidence used

This inventory is based on the configured `AGENTS.md` and `docs/agents/issue-tracker.md`, the installed `to-spec`, `to-tickets`, `triage`, `wayfinder`, `ask-matt`, `prototype`, and merge-conflict skills, and their supporting triage documents. The skills are the same as in the GitHub configuration; the tracker guide changes how their required semantics are represented.

### 1.2 What the file layout does not require

The configured implementation stores one feature's spec and tickets in a directory and uses one Markdown file per ticket. Those paths, file names, headings, and `NN` filename prefixes are implementation conventions, not requirements for a replacement. Their functional purpose is individual addressability, grouping, ordered selection, mutable content, and relationship/state storage.

## 2. Required record capabilities

### 2.1 Create, identify, and retrieve records

A tracker `MUST` create and persist individually addressable specs, implementation tickets, and wayfinder tickets. Each record `MUST` have a stable identifier or durable reference, a title/name, and a multi-line body. It `MUST` be retrievable when a user supplies that reference, path, or identifier.

The Markdown guide uses a feature directory, `spec.md`, and ticket numbers beginning at `01`. A replacement only needs to preserve the semantic equivalent: group a feature's spec and tickets, give each ticket an unambiguous reference, and allow tickets to be created in dependency order.

### 2.2 Read and update content

A tracker `MUST` read a record's complete body and discussion and update its stored content. `to-tickets` needs the full body and comments of a referenced spec/issue; `triage` needs the body, prior notes, labels/equivalent state, author, and dates; `wayfinder` updates a map's destination, notes, decisions, fog, and scope sections.

The exact `Status:`, `Type:`, `Blocked by:`, `## Comments`, and `## Answer` lines/headings are not required. The replacement `MUST` store or expose the same information so the documented adapter can inspect and change it.

### 2.3 List and select records

A tracker `MUST` list records within the relevant feature or wayfinder effort and inspect their identifier, title, body, state, classifications, claims, dependencies, and discussion. It `MUST` support the selections used by the skills:

- Open versus resolved/closed records.
- Records with no triage state, `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, or `wontfix`.
- A map's child tickets, in a deterministic order.
- The wayfinder frontier: open, unblocked, unclaimed child tickets, with the first in that order selected.

The local convention orders map tickets by their numeric prefix. A replacement `MAY` use any stable ordering. No installed skill requires full-text search, saved queries, pagination, or arbitrary sorting.

### 2.4 Classifications and state

A tracker `MUST` represent and change the five triage state roles, using these meanings:

| State role | Required meaning |
| --- | --- |
| `needs-triage` | Awaiting maintainer evaluation |
| `needs-info` | Waiting for reporter information |
| `ready-for-agent` | Fully specified and available to an AFK agent |
| `ready-for-human` | Requires human implementation or judgment |
| `wontfix` | Will not be actioned |

Triage also requires exactly one category, `bug` or `enhancement`, and exactly one triage state role. An unclassified record normally moves to `needs-triage`; `needs-info` returns to `needs-triage` after a reporter reply; a maintainer `MAY` override the normal transition. `to-spec` and `to-tickets` publish agent-ready work as `ready-for-agent`.

Wayfinder requires a ticket type of `research`, `prototype`, `grilling`, or `task`, plus an execution condition equivalent to unclaimed, claimed, or resolved. The Markdown guide overloads a `Status:` line for triage values in ordinary tickets and `claimed`/`resolved` in wayfinding. A replacement `MAY` use separate fields; it only needs to preserve both distinctions without losing either meaning.

### 2.5 Discussion and comments

A tracker `MUST` preserve an ordered append-only discussion for each issue/ticket and allow a new comment or answer to be recorded. Triage uses it for AI-disclaimed triage notes, agent briefs, and closing explanations. Wayfinder uses it for the ticket's resolution answer. Prototype work `MAY` add a context pointer to its implementation issue.

The local guide models discussion as text appended under `## Comments`, and resolution as `## Answer`. It does not require a separate comment object or comment editing. However, the installed triage skill needs commenter identity and time information to identify reporter activity after its last triage notes. A replacement that supports `/triage` `MUST` preserve enough author and timestamp information to make that determination, even though the local file convention does not prescribe its syntax.

The skills do not require editing or deleting comments, threaded replies, reactions, or attachments.

### 2.6 Resolution and reopening

A tracker `MUST` mark a record resolved/closed and allow the state to be listed and inspected. Triage closes `wontfix` requests after recording an explanation. Wayfinder resolves a ticket only after recording its answer and closes an out-of-scope ticket so it cannot remain on the frontier.

The skills do not require reopening a resolved record.

## 3. Required relationships and wayfinding

### 3.1 References and dependencies

A tracker `MUST` allow durable references between records and links to external context. A ticket needs to express the tickets that block it, and the agent needs to retrieve each blocker to decide whether it is resolved.

The Markdown form is a `Blocked by: NN, NN` line. A replacement `MAY` use native dependency links, fields, or another documented representation. The required semantic is unchanged: a ticket is unblocked only when every listed blocker is resolved.

### 3.2 Map and child tickets

A tracker `MUST` group a wayfinder map with its child tickets. The map is mutable low-resolution context containing destination, notes, decisions-so-far, fog, and scope. A ticket is the sole detailed record for one decision question. The map's decision list stores a short gist and a durable link to each resolved ticket; it does not duplicate the answer.

The local layout uses `map.md` plus ticket files in an `issues/` directory. A replacement `MAY` use a parent/child relation, a group key, or another queryable association. It `MUST` enumerate that map's children independently of the map body.

### 3.3 Claim and concurrent work

A tracker `MUST` let a session persist a claim before it begins wayfinder work and let other sessions observe that claim. The Markdown guide records `Status: claimed`; a replacement `MAY` use assignment, a lock, or another visible claim field.

The map workflow assumes multiple sessions can edit concurrently. Therefore, the frontier query `MUST` exclude claimed tickets and tickets with an open blocker. Once a ticket is claimed, resolution records the answer, changes it to resolved/closed, and appends the linked gist to the map.

## 4. Required workflow semantics

### 4.1 Specs and implementation tickets

`to-spec` publishes a single specification record. `to-tickets` creates one record per approved vertical slice, with its title, behavioral description, acceptance criteria, `ready-for-agent` state, and blocking references. It creates blockers first and does not close or modify a parent source issue.

### 4.2 Triage

Triage uses the records as a request queue. It needs an oldest-first view of unclassified records, `needs-triage` records, and `needs-info` records with reporter activity after the last triage notes. It then writes the chosen state and any required brief, notes, or closing explanation.

The rejected-enhancement knowledge base is local `.out-of-scope/` content rather than a tracker feature. The tracker only needs to support a comment/reference to that record and closure with `wontfix`.

### 4.3 Wayfinder

Wayfinder creates a map, creates the currently clear decision tickets, then records dependency edges after ticket identifiers exist. It works one claimed frontier ticket at a time, except parallel research tickets. Resolution adds an answer to that ticket, marks it resolved, and updates the map's Decisions-so-far. Newly clarified fog becomes new tickets; an existing ticket beyond the destination is closed and linked from Out of scope.

The skill says an invalidated ticket `MAY` be updated or deleted. Deletion is not a minimum capability because updating and closing a ticket preserves the required workflow behavior.

## 5. Deliberately excluded features

The installed skills do not require the `.scratch/` directory, a Markdown parser, fixed headings, fixed filename syntax, GitHub-compatible issue numbers, native dependency UI, comment editing, reopening, title editing, full-text tracker search, priority fields, milestones, projects/boards, estimates, due dates, watchers, reactions, or attachment storage. External artifacts are carried by normal context links.
