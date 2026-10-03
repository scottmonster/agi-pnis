#### User said:

---
# follow these instructions but do not reply to this section

we want this to be very generic and you are mixing diffferent things up
from now on instead of using:
gov as the repo name use repo_name --project AGIPNIS
AGIPNIS as the project name use project_name

--repo gov --project AGIPNIS
becomes
--repo repo_name --project project_name

we want this to be very generic and you are mixing diffferent things up

---
# you can reply to this

this is only a cli tool for now

we will need to know the project for a lot of the commands.
we will probably end up requiring for --project|-p <project name> for everything that has to do with the project.
we will probably end up requiring for --repo|-r <repo name> for everything that has to do with the repo.

however, since we want to design this to work seemlessly with repos, once a repo is linked to a project we can make this much easier by making the tool recognize when it is being run inside of a repo, get the name, and if it is already linked to a project, then we can set the project property and the repo property automatically that way we don't have to define it for every call... as a matter of fact now that im thinking about this. if we run inside of a repo, we should always set the repo property/variable internally. that way if we are in a repo and we want to link it to a projet we can just do something like:
I'm thinking all of these should work
whatever-tool link project_name
whatever-tool ln --project project_name
whatever-tool ln -p project_name

we also do not want to enforce a capitalization or punctuation requirement (except where there are actual limitations) we do not want to enforce arbitary limitations for no reason

-----
#### Assistant said:

Yes. I would make repository and project resolution part of the CLI's context system rather than forcing `--project` and `--repo` onto every command.

The clean rule is:

> Explicit arguments override detected context. Otherwise, when executed inside a linked repository, the CLI automatically resolves both the repository and its linked project.

That gives you three ways to establish context:

```text
1. Explicit project/repo arguments
2. Current repository
3. Repository -> linked project
```

For example, inside a linked repository:

```bash
whatever-tool ticket list
```

internally becomes equivalent to:

```bash
whatever-tool ticket list \
  --project project_name \
  --repo repo_name
```

You should probably always detect the current repository when inside one, even if it is not yet linked. Then the internal context could be:

```text
repo = repo_name
project = null
```

That enables exactly what you described:

```bash
whatever-tool link project_name
whatever-tool ln --project project_name
whatever-tool ln -p project_name
```

All three mean:

> Link the currently detected repository to `project_name`.

You could also support explicit repo targeting when outside that repository:

```bash
whatever-tool link project_name --repo repo_name
```

or:

```bash
whatever-tool ln -p project_name -r repo_name
```

### Context resolution

I would make the precedence deterministic:

```text
project:
1. --project / -p
2. project linked to explicitly supplied --repo / -r
3. project linked to detected current repository
4. none

repo:
1. --repo / -r
2. detected current repository
3. none
```

One important point: if `--repo repo_name` is explicitly supplied, I would resolve the project from **that repo**, not from the current working repository.

So this:

```bash
whatever-tool ticket list --repo repo_name
```

can infer its linked project.

Likewise:

```bash
whatever-tool ticket list --project project_name
```

means project-wide, with no repository constraint unless the command specifically needs one.

That gives you a useful distinction:

```bash
whatever-tool ticket list
```

Inside a linked repo:

```text
project = linked project
repo = current repo
```

Project-wide:

```bash
whatever-tool ticket list -p project_name
```

Explicit repo:

```bash
whatever-tool ticket list -r repo_name
```

which can infer:

```text
project = project linked to repo_name
repo = repo_name
```

### Naming

I agree about avoiding arbitrary restrictions.

I would treat project and repository names as opaque user-facing strings wherever possible:

```text
project_name
repo_name
```

Allow spaces, punctuation, mixed case, lowercase, uppercase, etc., subject only to actual backend/filesystem/CLI constraints.

So all of these could be valid:

```text
project_name
Project Name
my-project
project.alpha
project_01
```

The system should not impose something like:

```text
PROJECT_NAME
^[A-Z0-9_-]+$
```

just because traditional trackers often do.

Internally, you may eventually want an immutable generated ID separate from the display name:

```text
id:     01J...
name:   Project Name
```

That would let users rename projects without breaking relationships while still keeping the CLI human-friendly.

I think the broader principle should be:

> **Require context only when it cannot be resolved safely. Infer repository and project context from the current repository whenever possible, and allow explicit `--repo` and `--project` options to override that inference.**

-----
#### User said:

What would be the best way to handle authentication? 

I am thinking it should always be opt in. We can make the default backend either sqlite or markdown (configurable of course)

also since we are already talking about sqlite we could also just incorperate an ORM ... throw a little bit of Drizzle in there and then now we can use a lot of sql db on the back end.

I'm thinking we do not specifically handle auth. and we make the user responsible for it. either auth via git hub if that is their back end, or a username, url and api key... or whatever the chosen backend requires.

-----
#### Assistant said:

I think you are separating the concerns in the right place. I would make **authentication a backend responsibility**, not something the tracker invents.

The CLI should understand only:

- which backend is configured
- what connection/configuration that backend requires
- whether the backend is currently usable
- how to invoke the backend with those credentials

For example:

```text
GitHub
- authentication handled by GitHub/gh/token/etc.

YouTrack
- URL + token

SQLite
- no authentication by default

Markdown
- filesystem permissions only

PostgreSQL
- connection string / username / password / whatever the DB deployment requires
```

Your tool should not create its own accounts, passwords, login sessions, user database, JWT system, etc. unless you eventually add a feature that genuinely requires that.

I would distinguish three things:

```text
Authentication
Who can connect to the backend?
-> backend responsibility

Authorization
What is this user allowed to do?
-> normally backend responsibility

Tool permissions
What operations is the CLI/agent allowed to perform?
-> your optional permission system
```

That last distinction matters. Your opt-in permission system is not really authentication. It could say:

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

That can work even when the backend is local Markdown with no authentication whatsoever.

### Default backend

I agree with making the default local and authentication-free.

I would probably choose **SQLite as the default**, with Markdown available as an alternative.

SQLite gives you much more room for the model you are developing:

```text
projects
repositories
tickets
documents
comments
labels
tags
relationships
permissions
```

without forcing those concepts into a filesystem layout.

Markdown remains useful when the user explicitly wants human-readable, Git-tracked storage.

### ORM

Using an ORM also fits this architecture well, but I would put it **below the canonical tracker interface**, not make SQL itself your backend abstraction.

Something like:

```text
CLI
 |
Core domain model
 |
Backend interface
 |
+-- MarkdownBackend
+-- GitHubBackend
+-- SQLBackend
      |
    Drizzle
      |
   SQL database
```

Then SQLite, PostgreSQL, etc. can potentially share much of the same `SQLBackend` implementation.

I would avoid this:

```text
SQLiteBackend
PostgresBackend
MySQLBackend
```

if they all implement essentially the same relational model.

Prefer:

```text
SQLBackend
    |
    + dialect/driver
```

where practical.

### Credentials

I would also avoid becoming a credential manager.

Configuration should reference credentials, not necessarily contain secrets directly:

```toml
[backend]
type = "youtrack"
url = "https://example.youtrack.cloud"
token_env = "YOUTRACK_TOKEN"
```

or:

```toml
[backend]
type = "postgres"
connection_env = "TRACKER_DATABASE_URL"
```

For GitHub, you might simply delegate authentication entirely:

```text
backend = github
auth = existing GitHub CLI/session
```

That lets credential sources evolve without your application taking ownership of secret storage.

So I would make the principle:

> **The tracker owns the unified data and operations model. Backends own authentication and backend-level authorization. The tracker may optionally apply its own operation permissions on top.**

That keeps local Markdown/SQLite extremely simple while still allowing GitHub, YouTrack, PostgreSQL, and future backends to use whatever authentication mechanisms they naturally require.

-----
#### User said:

I also just want to note that i would want to make use of UUIDv7 IF we end up needing that

UUIDv7 was standardized in RFC 9562. Its main advantage for databases is that it is **time-ordered**, unlike UUIDv4.

That matters because random UUIDv4 values cause inserts to land all over a B-tree index:

```text
UUIDv4:
random
random
random
random
```

UUIDv7 puts a timestamp in the high-order bits, so newly generated IDs generally sort in creation order:

```text
UUIDv7:
time 1001 + randomness
time 1002 + randomness
time 1003 + randomness
```

That tends to give you:

* better index locality
* fewer B-tree page splits
* better insert performance
* sortable IDs
* globally unique IDs without a central sequence

It is often a strong choice for primary keys when you want UUIDs but also care about database index performance.

For a new SQLite/PostgreSQL design, I would generally prefer **UUIDv7 over UUIDv4** unless you specifically need completely random-looking ordering.

-----
#### Assistant said:

That fits the architecture well.

I would keep the rule simple:

> If the system needs generated globally unique identifiers, prefer UUIDv7 unless a backend imposes a different identifier scheme.

And still keep human-facing references separate where useful:

```text
internal_id: 0195...
display_id: project_name-123
backend_id: 4821
```

That gives you stable internal identity without forcing UUIDs into the CLI or user-facing workflow.
