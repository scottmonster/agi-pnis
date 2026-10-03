# Extended Tracker Design

## 1. Canonical tracker model

### 1.1 Core recommendation

Issues, tickets, and tasks should not be three separate first-class systems unless they have genuinely different behavior.

A cleaner model is:

- **Project**
  - Top-level container.
  - Can link multiple repositories.
  - Contains tickets, documents, labels, tags, permissions, and other project resources.
- **Repositories**
  - Zero or more repositories associated with a project.
  - Tickets and documents can optionally reference one or more repositories.
- **Tickets**
  - One underlying record type for anything representing work.
  - Has an ID, title, description, type, open/closed state, status, assignee or claim, labels, relationships, dependency links, and comments.
  - Supports dependency tracking so work can identify items it depends on and items that are blocked by it.
  - `type` can distinguish an issue, task, epic, feature, bug, research item, or decision.
  - Types can be added or removed without changing the underlying system.
- **Documents**
  - Documents associated with a project.
  - Hierarchical when needed.
  - Supports comments and revision history.
  - Can link to tickets and repositories.
- **Comments**
  - A generic commenting capability, rather than separate implementations.
  - Can attach to tickets, documents, and potentially projects or other resources later.
  - Include an author, timestamp, and immutable history.
- **Labels**
  - Structured, project-defined classification for tickets.
  - Can have a defined meaning, color, description, and workflow significance.
  - Examples include `bug`, `security`, `backend`, and `priority-high`.
  - Do not encode workflow semantics into labels when dedicated fields exist.
- **Tags**
  - Free-form organizational metadata for discovery, grouping, and search.
  - Can attach to tickets, documents, comments, projects, and repositories.
  - Users can create tags without changing the formal project taxonomy.
- **Permissions**
  - Opt-in.
  - Project, repository, or resource permissions as needed.
  - When disabled, keep the system simple rather than requiring ACL configuration everywhere.

The key decision is:

> **A ticket and a task are not separate entities. A task is a type of ticket.**

An issue would probably also be a ticket type. There is one meaningful alternative: if an issue is an incoming request or problem and a task is work derived from that request, retaining the distinction as types is useful.

For example:

- `Issue: Authentication occasionally fails`
- `Task: Add token refresh retry`
- `Task: Add authentication telemetry`

They still use the same underlying record model.

### 1.2 Conceptual structure

```
Project
├── Repositories
├── Tickets
│   ├── Issue
│   ├── Task
│   ├── Feature
│   ├── Bug
│   ├── Epic
│   └── ...
├── Documents
├── Labels
├── Tags
└── Permissions
```

The primary relationships are:

- Tickets ↔ comments
- Documents ↔ comments
- Tickets ↔ tickets
- Tickets ↔ documents
- Tickets ↔ repositories
- Documents ↔ repositories
- Tags ↔ tickets, documents, comments, projects, and repositories

This is substantially cleaner than separate issue, ticket, and task subsystems. The distinction belongs primarily in **type and relationships**, not storage or behavior.

### 1.3 Dependency tracking

Tickets must support directional dependency links. A dependency link identifies a prerequisite ticket and enables views such as blocked work, unblocked work, and a ticket’s dependency chain.

```text
AGIPNIS-123 depends on AGIPNIS-100

AGIPNIS-123 is blocked until AGIPNIS-100 is complete.
AGIPNIS-100 blocks AGIPNIS-123.
```

Dependencies are a first-class relationship type, alongside parent/child, duplicate, and relates-to links.

### 1.4 Labels and tags

Labels and tags serve different purposes:

> **Labels classify work. Tags organize information.**

Labels are structured and project-defined. They classify tickets and can drive workflow or communicate a durable property, such as `bug`, `security`, `backend`, or `priority-high`.

Tags are free-form and cross-system. They organize tickets, documents, comments, projects, and repositories for discovery, grouping, and search without changing the project's formal label taxonomy.

For example:

```text
Ticket: AGIPNIS-123
Labels:
  - bug
  - backend

Tags:
  - authentication
  - oauth
  - customer-acme
  - investigation-2026
```

```text
Document: Authentication Architecture

Tags:
  - authentication
  - oauth
  - architecture
```

```bash
track search --tag authentication
```

This search returns the ticket, document, relevant comments, and any other resource carrying the `authentication` tag.

## 2. Unified multi-backend tracker

### 2.1 Design premise

The user asked how a tool supporting GitHub tracking, local Markdown, and local SQLite could work as a unified tracker with multiple backends.

Design it as one **canonical tracker model** with pluggable backend adapters.

> The tool defines what a Project, Ticket, Document, Comment, Label, Tag, Repository, and Relationship mean. Each backend only translates those concepts into the storage or API it supports.

```
                    Unified Tracker
                         API / CLI
                            |
            +---------------+---------------+
            |               |               |
        Projects          Tickets       Documents
            |               |               |
       Repositories      Comments         Comments
                            |
              Relationships / Labels / Tags
                            |
                     Backend Interface
                            |
         +------------------+------------------+
         |                  |                  |
      GitHub             Markdown            SQLite
      adapter             adapter             adapter
```

### 2.2 Core model

```text
Project
- id
- name
- repositories[]
- tags[]

Repository
- id
- url/path
- project_id
- tags[]

Ticket
- id
- project_id
- type
- title
- body
- state
- assignee
- labels[]
- tags[]
- relationships[]
- dependencies[]

Document
- id
- project_id
- title
- body
- parent_id?
- tags[]

Comment
- id
- resource_type
- resource_id
- author
- body
- created_at
- tags[]

Label
- id
- project_id
- name
- color
- description
- workflow_significance

Tag
- name

TagAssignment
- tag
- resource_type
- resource_id

Relationship
- source
- target
- type
  - parent/child
  - depends-on
  - duplicate
  - relates-to
```

### 2.3 Backend contract

Conceptually, `TrackerBackend` supports:

```text
Projects
- create_project
- get_project
- list_projects

Repositories
- attach_repository
- list_repositories

Tickets
- create_ticket
- get_ticket
- update_ticket
- list_tickets
- close_ticket
- reopen_ticket

Comments
- list_comments
- add_comment

Relationships
- add_relationship
- remove_relationship
- list_relationships

Dependencies
- add_dependency
- remove_dependency
- list_dependencies

Documents
- create_document
- get_document
- update_document
- list_documents

Labels
- create_label
- assign_label
- remove_label

Tags
- add_tag
- remove_tag
- list_tags
- search_by_tag
```

### 2.4 Backend capabilities

Capabilities must be explicit because **not every backend can support everything natively**.

| Backend | Capabilities |
| --- | --- |
| GitHub | ✓ Tickets, comments, labels, assignees, open/close, remote concurrency; ✓ relationships and dependency tracking, partially native or emulated; △ tags, projects across repositories, and documents |
| Markdown | ✓ Tickets, comments, labels, tags, open/close, relationships, dependency tracking, documents, and multiple repositories; △ concurrency and permissions |
| SQLite | ✓ Essentially everything: arbitrary projects, multiple repositories, documents, relationships, dependency tracking, labels, tags, custom fields, and permissions |

The common abstraction must not become:

> “Everything must behave exactly like GitHub.”

Instead, report the adapter’s native and emulated capabilities:

```text
tracker capabilities github

tickets      yes
comments     yes
documents    emulated
dependencies emulated
labels       native
tags         emulated
permissions  native
multi_repo   emulated
```

The adapter then decides how concepts map.

### 2.5 Example mappings

One unified command:

```bash
track ticket create \
  --type task \
  --title "Implement authentication" \
  --project AGIPNIS
```

could become:

**GitHub**

```text
GitHub Issue
title: Implement authentication
label: type:task
repository: agi-pnis/gov
```

**Markdown**

```text
projects/AGIPNIS/tickets/123-implement-authentication.md
```

**SQLite**

```text
tickets row
id = 123
type = task
title = Implement authentication
```

Likewise:

```bash
track comment add AGIPNIS-123 "Blocked by authentication decision."
```

maps to:

- A GitHub issue comment.
- An appended Markdown comment record.
- A SQLite `comments` row.

## 3. Identity and storage

### 3.1 Canonical IDs

Do **not** expose backend IDs as the primary abstraction. Give every item a canonical ID, such as `AGIPNIS-123`.

For GitHub, the internal mapping might be:

```text
AGIPNIS-123
backend: github
external_id: 482
repository: scott/gov
```

For Markdown, it might be:

```text
AGIPNIS-123
backend: markdown
external_id: tickets/123.md
```

Agents can then use `AGIPNIS-123` regardless of storage.

### 3.2 Local metadata layer

Even for remote backends, the tool will probably need a small local metadata layer unless all metadata is encoded in GitHub.

```text
.tracker/
├── config.toml
└── index.sqlite
```

`index.sqlite` contains mappings for:

- Canonical ID → backend → backend ID.
- Project → repositories.
- Backend capabilities.

### 3.3 Backend versus storage

Initially, allow one **primary backend per project**:

```toml
[project]
id = "AGIPNIS"
backend = "github"
```

Alternatively:

```toml
backend = "markdown"
```

or:

```toml
backend = "sqlite"
```

Multiple repositories can point to the same project configuration:

```text
gov/
└── .tracker -> AGIPNIS

skills/
└── .tracker -> AGIPNIS

agents/
└── .tracker -> AGIPNIS
```

All three resolve to the same project even though the repositories are separate.

Later, hybrid storage could be supported:

```text
Tickets    -> GitHub
Documents  -> Markdown
Metadata   -> SQLite
```

Do **not** start there; it increases synchronization and identity complexity dramatically.

Start with one project-selected backend:

```text
Unified model
      |
Backend interface
      |
+-----+------+------+
|            |      |
GitHub    Markdown SQLite
```

### 3.4 Stable CLI and agent interface

The CLI stays identical across backends:

```bash
track ticket create
track ticket show AGIPNIS-123
track ticket list
track ticket close AGIPNIS-123

track comment add AGIPNIS-123 "..."
track dependency add AGIPNIS-123 AGIPNIS-100
track dependency list AGIPNIS-123
track relation add AGIPNIS-123 depends-on AGIPNIS-100

track document create
track document show

track tag add AGIPNIS-123 authentication
track tag list AGIPNIS-123
track search --tag authentication

track project repos
```

Agent skills therefore only need to understand the tracker CLI, not GitHub, Markdown, SQLite, or YouTrack.

```text
Matt skill
   |
   v
track CLI
   |
   v
canonical tracker contract
   |
   +-> GitHub
   +-> Markdown
   +-> SQLite
   +-> YouTrack someday
```

## 4. Summary

Keep **Ticket** as the fundamental work abstraction. `issue`, `task`, `feature`, `bug`, `epic`, `research`, and similar categories are types, not separate APIs. Keep **Label** as structured ticket classification and **Tag** as a generic cross-system organizational primitive.

This gives the tool one small abstraction that can sit in front of nearly any tracker.
