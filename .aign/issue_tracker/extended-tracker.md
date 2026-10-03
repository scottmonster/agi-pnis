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
project_name-123 depends on project_name-100

project_name-123 is blocked until project_name-100 is complete.
project_name-100 blocks project_name-123.
```

Dependencies are a first-class relationship type, alongside parent/child, duplicate, and relates-to links.

### 1.4 Labels and tags

Labels and tags serve different purposes:

> **Labels classify work. Tags organize information.**

Labels are structured and project-defined. They classify tickets and can drive workflow or communicate a durable property, such as `bug`, `security`, `backend`, or `priority-high`.

Tags are free-form and cross-system. They organize tickets, documents, comments, projects, and repositories for discovery, grouping, and search without changing the project's formal label taxonomy.

For example:

```text
Ticket: project_name-123
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

Initial scope is CLI only.

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
- link_repository_to_project
- unlink_repository_from_project
- list_repositories

Backend connection
- check_connection

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

### 2.5 Authentication, authorization, and permissions

Authentication is opt-in and backend-specific. Authentication and backend-level authorization are backend responsibilities. The tracker CLI must not create its own accounts, passwords, login sessions, user database, or token system.

| Backend | Authentication and authorization |
| --- | --- |
| GitHub | Existing GitHub CLI, token, or other GitHub-supported authentication |
| YouTrack | Backend URL and token |
| SQLite | No authentication by default |
| Markdown | Filesystem permissions |
| PostgreSQL or another SQL service | Its connection and deployment credentials |

Configuration should reference credentials rather than store secrets directly:

```toml
[backend]
type = "youtrack"
url = "https://example.youtrack.cloud"
token_env = "YOUTRACK_TOKEN"
```

The tracker may apply an optional, separate operation-permission layer. It controls what the CLI or an agent may do, not who may connect to the backend:

```text
allow:
  - ticket.read
  - document.read

ask:
  - ticket.create
  - ticket.update

deny:
  - ticket.delete
```

The default backend must be configurable and should be local and authentication-free, such as SQLite or Markdown. SQLite is the better default when the full relational model is needed; Markdown remains useful for human-readable, Git-tracked storage.

### 2.6 Shared SQL backend

SQL is an implementation detail beneath the canonical tracker interface, not the tracker interface itself. A shared `SQLBackend` can support SQLite, PostgreSQL, and other compatible SQL databases through a dialect or driver rather than requiring separate, duplicate backend implementations.

```text
CLI
 |
Core domain model
 |
Backend interface
 |
+-- MarkdownBackend
+-- GitHubBackend
\-- SQLBackend
      |
    ORM, such as Drizzle
      |
   SQL database
```

### 2.7 Example mappings

One unified command:

```bash
track ticket create \
  --type task \
  --title "Implement authentication" \
  --project project_name
```

could become:

**GitHub**

```text
GitHub Issue
title: Implement authentication
label: type:task
repository: repo_name
```

**Markdown**

```text
projects/project_name/tickets/123-implement-authentication.md
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
track comment add project_name-123 "Blocked by authentication decision."
```

maps to:

- A GitHub issue comment.
- An appended Markdown comment record.
- A SQLite `comments` row.

## 3. Identity and storage

### 3.1 Canonical IDs

Do **not** expose backend IDs as the primary abstraction. Give every item a canonical ID, such as `project_name-123`.

For GitHub, the internal mapping might be:

```text
project_name-123
backend: github
external_id: 482
repository: repo_name
```

For Markdown, it might be:

```text
project_name-123
backend: markdown
external_id: tickets/123.md
```

Agents can then use `project_name-123` regardless of storage.

### 3.2 Generated identifiers

If the system needs generated, globally unique internal identifiers, prefer UUIDv7 unless a backend requires a different identifier scheme. UUIDv7 values are time-ordered, which improves index locality and insert behavior in databases while retaining global uniqueness.

Keep internal, human-facing, and backend identifiers separate:

```text
internal_id: UUIDv7
display_id:  project_name-123
backend_id:  482
```

The immutable internal ID allows display names and human-facing references to change without breaking relationships.

### 3.3 Local metadata layer

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

### 3.4 Backend versus storage

Initially, allow one **primary backend per project**:

```toml
[project]
name = "project_name"
backend = "sqlite"
```

Alternatively:

```toml
backend = "markdown"
```

or:

```toml
backend = "github"
```

Multiple repositories can point to the same project configuration:

```text
repo_name/
└── .tracker -> project_name
```

Each linked repository resolves to the same project even though repositories remain separate.

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

### 3.5 Stable CLI and agent interface

The CLI stays identical across backends:

```bash
track ticket create
track ticket show project_name-123
track ticket list
track ticket close project_name-123

track comment add project_name-123 "..."
track dependency add project_name-123 project_name-100
track dependency list project_name-123
track relation add project_name-123 depends-on project_name-100

track document create
track document show

track tag add project_name-123 authentication
track tag list project_name-123
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

### 3.6 CLI context resolution and naming

The tracker is a CLI tool. It must resolve project and repository context before requiring the user to repeat `--project` or `--repo` on every command.

Project-aware commands accept `--project` or `-p`; repository-aware commands accept `--repo` or `-r`.

> **Explicit arguments override detected context. Otherwise, when the CLI runs inside a linked repository, it resolves both the repository and its linked project automatically.**

The CLI always detects the current repository when it runs inside one, even before that repository is linked:

```text
repo = repo_name
project = null
```

Resolve context in this order:

| Context | Precedence |
| --- | --- |
| Project | 1. `--project` or `-p`; 2. the project linked to an explicit `--repo` or `-r`; 3. the project linked to the detected current repository; 4. none |
| Repository | 1. `--repo` or `-r`; 2. the detected current repository; 3. none |

When a command has an explicit repository, resolve its project from that repository rather than from the current working repository. An explicit project creates a project-wide scope unless the command also needs or receives a repository constraint. Require project or repository context only when it cannot be resolved safely.

For example, inside a linked repository:

```bash
track ticket list
```

is equivalent to:

```bash
track ticket list \
  --project project_name \
  --repo repo_name
```

Project-wide and explicit-repository scopes remain available:

```bash
track ticket list -p project_name
track ticket list -r repo_name
```

Repository linking uses the detected repository when available:

```bash
track link project_name
track ln --project project_name
track ln -p project_name
```

Outside a repository, callers can target one explicitly:

```bash
track link project_name --repo repo_name
track ln -p project_name -r repo_name
```

Project and repository names are opaque user-facing strings. The CLI must allow mixed case, spaces, punctuation, and other normal names, subject only to actual backend, filesystem, or shell limitations. It must not impose arbitrary capitalization or validation patterns. Immutable generated IDs keep renames from breaking relationships.

## 4. Summary

Keep **Ticket** as the fundamental work abstraction. `issue`, `task`, `feature`, `bug`, `epic`, `research`, and similar categories are types, not separate APIs. Keep **Label** as structured ticket classification and **Tag** as a generic cross-system organizational primitive.

This gives the tool one small abstraction that can sit in front of nearly any tracker.



------
------

# This still needs to be determined

It looks strong as a working design document. The core abstractions are now coherent:

* `Project`
* `Repository`
* `Ticket`
* `Document`
* `Comment`
* `Label`
* `Tag`
* `Relationship`
* `Permission`

The distinction between Tickets as the single work abstraction, Labels as structured work classification, and Tags as free-form cross-resource metadata is especially clean. 

I would keep it as-is for now, but there are a few things I would revisit before turning this into an implementation spec:

* **`state` versus open/closed state.** Ticket currently has both an "open/closed state" concept and `state`.  You should eventually decide whether:

  * open/closed is fundamental and `status` is separate, or
  * lifecycle state alone determines whether something is open/closed.

  I lean toward separate concepts: `open/closed` is lifecycle, while `status` is customizable workflow state.

* **Dependencies are probably just Relationships.** The model currently has both `relationships[]` and `dependencies[]`, and the backend contract has separate Relationships and Dependencies APIs.   Since `depends-on` is already a relationship type, I would likely make dependency operations convenient aliases/queries over Relationships rather than a second underlying subsystem.

* **Comments should probably be universally attachable from the beginning.** You already have `resource_type` + `resource_id`, which naturally supports this.  So instead of saying comments attach to tickets/documents and "potentially" other resources later, the conceptual rule could simply become: comments can attach to any commentable resource.

* **Canonical IDs need one more distinction.** Your UUIDv7/internal ID idea is good.  But `project_name-123` probably should not be considered canonical if project names can contain arbitrary spaces/punctuation and can be renamed. I would think of:

  ```text
  internal ID    UUIDv7, immutable
  reference      human-friendly, stable
  backend ID     backend-specific
  display name   freely renameable
  ```

  We do not need to solve the human-friendly reference format yet.

* **The local metadata layer may be premature.** The document currently says remote backends will "probably need" `.tracker/index.sqlite`.  That might become true, but I would keep it as an implementation option rather than a design requirement until we discover metadata that genuinely cannot live in the selected backend.

One small wording/concept issue: the diagram says **"API / CLI"**, while the design explicitly says the initial scope is CLI only.  I would conceptualize the layers as:

```text
CLI
 |
Core
 |
Backend interface
 |
Adapters
```

Overall, I think you are at the right level now. The main thing I would **not** do yet is start specifying schemas, exact commands, configuration formats, or ORM structure much further. The domain model and backend boundary should settle first.
