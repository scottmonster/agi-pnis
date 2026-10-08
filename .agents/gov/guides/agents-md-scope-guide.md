# AGENTS.md Boundary Guide

This guide helps decide what belongs in `AGENTS.md` and what should live in narrower documentation.

The central principle is **smallest sufficient scope**: place guidance at the narrowest scope that reliably reaches every task that needs it. `AGENTS.md` should contain context an agent needs broadly or early enough to work safely and correctly. Specialized procedures and domain details should load only when the relevant work occurs.

The aim is not a complete repository manual. It is a small, reliable set of boundaries and entry points that prevents common, material mistakes.

## The decision

Ask these questions:

1. **How broadly does this information apply?**
2. **How early must an agent know it?**
3. **Could omitting it cause an unsafe action, an incorrect result, or a material repository mistake?**
4. **Does the agent need the detail itself, or only a clear trigger that points to the authoritative detail?**

Put information in a repository-level `AGENTS.md` when it applies broadly, or when an agent must know it before task-specific discovery to avoid unsafe or incorrect behavior.

Put information in a nested `AGENTS.md` when it should automatically govern most work in one directory tree.

Put information in a specialized guide when it matters only for a particular task, procedure, or domain and can be consulted after the agent recognizes that context.

Do not use a numerical score. A single strong safety or correctness reason can justify broad placement even when an instruction is rarely exercised.

## Choose the narrowest effective location

| Information | Suitable location | Reason |
| --- | --- | --- |
| Repository purpose, unusual environment facts, safety and authorization boundaries, and conventions that affect most work | Root `AGENTS.md` | An agent needs them before ordinary work. |
| Rules that apply only below one component or package | `AGENTS.md` in that directory | It reaches agents working there without burdening other tasks. |
| A required procedure for a recognizable operation | The procedure's authoritative document, with a trigger and link in the applicable `AGENTS.md` | The trigger is needed early; the details are not. |
| Architecture, domain concepts, task workflows, troubleshooting, examples, and rationale | Targeted documentation | An agent should consult these only when the task calls for them. |
| Exact behavior, supported options, generated state, or machine-enforced formatting | Source code, configuration, generated output, or automated checks | Duplicating a changing or enforceable source creates drift and consumes attention. |

The directory structure can provide useful scope, but agent implementations do not all load nested instruction files in the same way. Verify the runtime's instruction-discovery behavior before relying on a nested `AGENTS.md` for a safety-critical or required rule. If the rule must govern all work, keep its concise statement in the root file.

## What belongs in repository-level `AGENTS.md`

### Environmental facts

Include non-obvious facts that affect broad classes of work, such as:

- the canonical package manager, build system, or working-directory assumption;
- generated, vendored, mirrored, incomplete, experimental, externally owned, or read-only material;
- the authoritative location for schemas, configuration, or other critical sources of truth; and
- environment constraints that materially change what commands or tools are safe to use.

Do not copy full setup or onboarding procedures unless nearly every task requires them.

### Repository-wide boundaries

Include boundaries agents should not have to discover by accident, such as:

- files or systems that must not be modified;
- security, privacy, credential, production-access, authorization, or preservation restrictions;
- compatibility guarantees that apply throughout the repository;
- destructive operations that require special handling; and
- repository-wide rules for generated artifacts or external dependencies.

Prefer the invariant and safe alternative over a long implementation recipe.

### Broad validation expectations

Include build, test, lint, formatting, or review expectations when they apply across the repository and the correct path is not safely obvious. Move component-specific commands to the component's scope.

### Routing instructions

Use `AGENTS.md` to tell agents when narrower guidance becomes relevant:

- before authentication changes, read the authentication security guide;
- before changing a database schema, follow the migration guide;
- before creating, modifying, or reviewing a skill, read and apply the relevant skill standards; or
- work under a service is governed by that service's nested `AGENTS.md`.

A routing instruction should name a meaningful trigger and the document that governs the work. Avoid vague directions such as "read the docs" or an undifferentiated list of references.

For example:

> Before changing database schemas, read `docs/database-migrations.md`. Never modify a production database directly.

The shared file carries the trigger and safety boundary; the migration guide carries the procedure.

## What usually belongs elsewhere

Prefer narrower documentation for:

- subsystem architecture and design rationale;
- language- or framework-specific conventions;
- deployment, release, migration, and incident-response procedures;
- detailed testing strategies for one component;
- API, protocol, or data-model reference material;
- debugging and troubleshooting playbooks;
- long tutorials, examples, and historical context; and
- rare or role-specific operational procedures.

If specialized material contains a safety-critical invariant, repeat only the minimum invariant or stop-and-consult trigger in the applicable `AGENTS.md`.

Do not duplicate detailed rules in `AGENTS.md`. Keep the detailed source authoritative elsewhere. When a rule changes, update its source and the short trigger together. Remove the trigger when its omission no longer creates a material risk or when an automated control makes it redundant.

## Nested `AGENTS.md` versus a specialized guide

Use a nested `AGENTS.md` when **location determines applicability**. Package-specific build commands, service-wide architectural boundaries, and conventions shared by an entire subtree fit here.

Use a specialized guide when **the kind of work determines applicability**. Release procedures, database migrations, security reviews, incident response, and performance investigations usually fit here.

A repository can use all three layers:

- root `AGENTS.md`: shared invariants, environmental facts, and routing;
- nested `AGENTS.md`: subtree-wide instructions; and
- specialized guides: task- or domain-specific procedures and reference material.

## Safety-critical information

A specialized document is not sufficient when an agent could cross a dangerous boundary before realizing the document is relevant.

**Required:** A safety or correctness constraint that must govern an agent before task-specific discovery `MUST` appear in the applicable `AGENTS.md` scope, either as the constraint itself or as an explicit stop-and-consult rule.

**Prohibited:** Such a constraint `MUST NOT` exist only in conditional documentation when an agent could reasonably perform the unsafe or invalid action before knowing to consult it.

**Why:** Conditional documentation can guide work only after the agent recognizes the condition. Early guardrails protect the discovery process itself.

## Warning signs and maintenance

`AGENTS.md` probably has **too much** when it contains long procedures for rare tasks, many sections that apply to only one service or language, duplicated reference material, frequently changing implementation details, or repeated phrases such as "only when working on...".

Move that material to a narrower scope and preserve only any needed invariant or routing trigger.

`AGENTS.md` may have **too little** when agents repeatedly make the same repository-wide assumption, use the wrong canonical toolchain, edit generated or non-authoritative files, discover safety boundaries only after beginning work, or fail to consult existing specialized guidance because no trigger points them there.

Add the smallest durable instruction that would prevent the recurring failure.

Review an entry after it causes repeated confusion, is ignored, becomes stale, or expands substantially. Prefer correcting or removing a misleading instruction over adding another rule to qualify it. A shorter file with accurate boundaries is more useful than a comprehensive file with mixed scopes.

## Examples

| Information | Preferred location | Why |
| --- | --- | --- |
| Use `pnpm`; do not create npm or Yarn lockfiles anywhere in the repository. | Root `AGENTS.md` | Repository-wide environmental invariant. |
| Run `make test-payments` for changes under `services/payments/`. | `services/payments/AGENTS.md` | Automatically applies to one subtree. |
| Exact steps for rotating production signing keys. | Security runbook | Specialized high-risk procedure; broad guidance should carry only the necessary guardrail or trigger. |
| Never use production credentials from agent-run local commands. | Root `AGENTS.md` | Must be known before tool use. |
| Resolver conventions for one GraphQL service. | Nested `AGENTS.md` or service guide | Irrelevant to most repository work. |
| Rationale for choosing the event-bus architecture. | Architecture documentation | Reference context, not a universal operating instruction. |
| Before changing a database schema, follow the migration guide. | Applicable `AGENTS.md`; procedure in migration guide | The trigger must be visible earlier than the procedure. |
| Full release checklist. | Release guide | Task-specific procedure. |


## Default rule

When uncertain, do not ask whether the information is "important." Ask **how broadly and how early it must influence agent behavior**.

Put it in `AGENTS.md` when broad or early influence is necessary for safe and correct work. Otherwise, keep it in the narrowest documentation that owns the subject and make `AGENTS.md` responsible only for routing agents there when needed.
