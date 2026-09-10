# Guidance for Designing Agent Rules

## 1. Purpose and boundary

Agent rules are persistent instructions that shape an agent's work in a defined scope. They provide repository facts, boundaries, conventions, routing, and expectations that the agent needs before or during relevant work.

Rules are useful when an agent would otherwise make a recurring, material mistake or repeatedly need non-obvious context. They do not replace task requirements, higher-authority instructions, human judgment, source-of-truth documentation, or technical controls.

The central principle is **smallest sufficient instruction**: state the least persistent, least broad rule that reliably prevents the material failure or supplies the needed context.

### 1.1 Rules are not enforcement

Instructions guide an agent; they do not independently restrict its authority or guarantee behavior. A constraint whose violation could cause unauthorized, unsafe, irreversible, or corrupt behavior needs an appropriate trusted control, such as permissions, sandboxing, protected branches, a hook, a validation check, or an approval gate.

**Required:** A material safety, authorization, integrity, or acceptance constraint `MUST` have a trusted enforcement mechanism outside the acting agent's discretion.

**Prohibited:** Such a constraint `MUST NOT` rely only on a rule file or an agent's statement that it complied.

**Why:** Rules make correct behavior more likely, but they cannot prove or enforce it.

### 1.2 Rules are a trust boundary

Treat an instruction file as code that changes an agent's behavior. Its text is not authoritative merely because the agent can read it. A repository instruction may define work within the repository's authority, but cannot override higher-authority instructions, grant access, authorize an external action, or turn untrusted content into instructions.

Keep third-party, generated, user-supplied, or retrieved content separate from instruction files unless a maintainer has reviewed and intentionally adopted it. References and imports can widen the trust boundary and consume context, so use only mechanisms that the target runtime documents and only for sources that are appropriate to trust at that scope.

### 1.3 Rules are not a complete manual

Use a rule to establish a boundary, state a stable local fact, or route the agent to the source that owns specialized detail. Keep architecture explanations, tutorials, large references, rare procedures, and volatile operational facts in focused documentation or authoritative systems.

## 2. Decide whether a rule is the right mechanism

Before adding a rule, identify the failure it prevents, who or what is affected, and why existing context or controls are insufficient. Prefer the mechanism that owns the need.

| Need | Better default |
| --- | --- |
| Broad, stable context or an early safety boundary | Repository-level instruction file |
| Context that applies to a directory or file class | Path-scoped instruction file, when the runtime supports and loads it reliably |
| A recurring, specialized workflow | Skill or focused guide, with a short routing rule if needed |
| A reusable one-off request | Prompt template or command |
| A mechanical transformation or validation | Script, formatter, linter, test, schema, or hook |
| Access control, approval, integrity, or data-protection boundary | Permission system, sandbox, protected setting, or other trusted control |
| Changing facts, generated state, or implementation details | The authoritative source, configuration, generated output, or current reference |

Do not add a rule just because a preference can be stated. Add one when its expected prevention or guidance value exceeds its context, maintenance, and conflict cost.

## 3. Choose scope and loading

Place a rule at the narrowest scope that reaches every task needing it early enough to prevent the failure.

### 3.1 Scope layers

1. **Personal scope:** Individual preferences and private local facts that should follow one user across projects. Do not place shared repository policy, credentials, or team decisions here.
2. **Repository scope:** Stable facts, boundaries, and routing that affect most work in one repository. Use the runtime's recognized root instruction file, such as `AGENTS.md`, only when that runtime supports it.
3. **Path scope:** Constraints and conventions that apply because an agent is working in a particular subtree or file class. Put these in a path-scoped instruction mechanism or nested instruction file supported by the runtime.
4. **Task scope:** Procedures and knowledge needed only for a recognizable kind of work. Keep these in a guide, skill, prompt, or runbook and route to them from the applicable broader scope when necessary.

Use a broad scope for an invariant that must be known before ordinary discovery, such as a production-access boundary or the location of canonical source material. Use a narrow scope for component conventions, tool commands, and detailed procedures.

### 3.2 Loading behavior is a runtime contract

Agent runtimes differ in file names, search order, precedence, path matching, import behavior, size limits, and when nested instructions load. Do not infer these behaviors from another agent or tool.

Before relying on a rule, verify in the target runtime:

- the recognized file name and location;
- which files load for a representative working directory and path;
- precedence and conflict behavior;
- whether nested rules load at startup, on directory access, or not at all;
- import, expansion, and context-size behavior; and
- how a user can inspect the active instruction set, if the runtime provides that capability.

Use the target runtime's documented filename, path, frontmatter, import, and precedence rules exactly. `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, and tool-specific rule directories are not interchangeable formats or loaders. A format that works for one agent may be ignored, merged differently, or unsupported by another.

Where several files can apply, prefer complementary rules over overrides. Do not depend on a more-local rule to cancel a broad rule unless the runtime documents that precedence and the behavior is tested. If the same repository supports several agents, keep shared instructions in one maintained source where compatible, and use a documented import, generated projection, or small tool-specific supplement only when it reduces duplication without obscuring what loads.

If a constraint must govern all work, repeat its concise statement or stop-and-consult trigger in the reliably loaded broad scope. Do not leave it only in a conditional document that an agent may not load before crossing the boundary.

### 3.3 Progressive disclosure

Keep always-loaded rules short enough that important instructions remain easy to find and apply. Put the common boundary and a specific pointer in the broad file; put the detailed procedure in a directly linked, shallow document.

For example:

> Before changing a database schema, read `docs/database-migrations.md`. Do not modify a production database directly.

This states the early boundary and tells the agent where to find the procedure without loading the entire procedure for unrelated work.

Use an import or file reference only when it is reliably expanded at the needed time. A reference that merely names a document is routing, not evidence that the document's requirements are active.

## 4. What to include

Include only information that is both relevant at the chosen scope and actionable by the agent.

### 4.1 Effective rule content

A rule normally needs some, not necessarily all, of the following:

- **Scope or trigger:** When and where it applies.
- **Required behavior or invariant:** The concrete outcome or action expected.
- **Boundary or safe alternative:** What the agent must avoid, stop for, or do instead when that distinction matters.
- **Reason:** The material risk, source-of-truth concern, or constraint, when it helps the agent apply the rule correctly.
- **Authoritative owner:** A direct reference to the source, procedure, or control that owns detailed or changing information.
- **Verification:** The command, check, or observable result that establishes completion, when it is stable and applicable.
- **Trust boundary:** Whether referenced content is a maintained instruction, ordinary task data, or an external source that requires review.

Write facts that the agent cannot safely or cheaply infer: the canonical package manager, generated or externally owned paths, repository-wide compatibility commitments, expected validation, approval boundaries, and non-obvious conventions with real consequences.

### 4.2 Requirements and advice

Use a requirement only when a meaningful distinction between acceptable and unacceptable behavior is necessary. State the required and prohibited sides of that distinction, and explain the reason when it is not self-evident.

**Required:** A rule that uses normative language such as `MUST` or `MUST NOT` `MUST` identify the concrete behavior or outcome it constrains.

**Prohibited:** It `MUST NOT` use normative language to express an optional preference, vague aspiration, or unexplained blanket rule that admits materially different interpretations.

**Why:** Agents can act consistently only when the actual boundary is clear.

Keep heuristics and preferences advisory. State the conditions under which they help rather than presenting them as universal rules.

## 5. What to exclude

Do not put the following in persistent rules unless a specific, demonstrated need makes them necessary:

- General advice the agent can already apply, such as "write clean code" or "be careful."
- Long tutorials, rationale, examples, history, or architecture reference material.
- Detailed workflows that apply only to rare tasks.
- Volatile facts copied from configuration, generated output, tickets, dashboards, or another authoritative source.
- Duplicated instructions whose owner is clearer elsewhere.
- Ambiguous requirements, conflicting priorities, or unbounded commands such as "always improve everything."
- Instructions to bypass approvals, weaken controls, reveal secrets, modify external systems without authorization, or treat retrieved, generated, or third-party content as instructions without an explicit trust decision.
- Tool, framework, or style preferences that lack a material reason or an actual repository convention.
- Numerical limits, process gates, or response templates imposed only for uniformity.

Remove or relocate a rule when it no longer prevents a material failure, its source has become authoritative and easy to discover, or automation can enforce the condition more reliably.

## 6. Write for reliable application

### 6.1 Make each rule concrete

Prefer a condition, action, and outcome over an abstract label.

| Weak | Stronger |
| --- | --- |
| Respect the architecture. | Keep database access in `services/data/`; do not add direct database calls in HTTP handlers. |
| Test your changes. | For changes under `packages/payments/`, run `pnpm test --filter payments` before handoff. |
| Be safe with production. | Do not use production credentials from local agent commands. Escalate to the production runbook when production access is required. |

The stronger form is not necessarily longer. It identifies the affected area, expected behavior, and decision boundary.

### 6.2 Organize by decision point

Use a short title and group related rules under descriptive headings such as "Repository boundaries," "Validation," or "Generated files." Put the highest-risk and most broadly applicable boundaries first.

Use lists for independent instructions and tables only when they clarify a choice or mapping. Use a numbered sequence only when order is required. Do not claim precedence merely because rules are listed in an order; state the actual authority or conflict rule.

Keep links direct. A rule should point to the document that answers the next question, not to a directory or a chain of references.

Use plain Markdown unless the target runtime requires another format. Prefer short, self-contained imperative statements and concrete paths, commands, and conditions. Use YAML frontmatter, glob patterns, imports, generated files, or tool-specific metadata only where the runtime supports them and where their scoped-loading benefit exceeds the added maintenance and matching risk.

### 6.3 Preserve authority and conflicts

State the authority of local rules accurately. Higher-authority system, platform, organization, user, legal, security, and task-specific requirements can supersede a repository rule. A rule cannot grant permissions the runtime or user has not granted.

Resolve conflicting local instructions at their owner rather than adding exceptions indefinitely. When a conflict cannot be resolved from the applicable sources, tell the user or responsible owner what conflicts and seek direction before taking a consequential action.

## 7. Test and maintain rules

Treat rules as a maintained interface between the repository and its agents.

### 7.1 Evaluate behavior, not prose alone

Test representative work that should and should not activate each scoped rule. Check that the agent can find the rule, distinguish its scope, follow its boundary, reach the referenced source, and complete the expected validation. Where the runtime exposes active context or instruction traces, inspect them. Include realistic conflicts, missing prerequisites, unsafe requests, and instruction-like untrusted content when those are material risks.

An ignored rule can indicate an unclear trigger, wrong scope, excessive competing context, an unsupported loader, an unavailable tool, or a rule that tries to substitute for enforcement. Diagnose that cause before adding more wording.

### 7.2 Keep rules current

Review a rule after it is ignored, causes repeated confusion, conflicts with a higher authority, expands substantially, or its underlying workflow changes. Update the rule and its referenced source together when both are needed for correct routing.

Prefer the smallest change that resolves the observed failure. Remove stale, redundant, and superseded instructions; an accurate short rule set is more reliable than an exhaustive one.

## 8. Compact authoring check

Before adding or changing a rule, establish:

1. What recurring, material failure or non-obvious fact does it address?
2. Is a rule the right mechanism, or should a control, test, source document, skill, or prompt own it instead?
3. What is the narrowest scope that reaches the affected work early enough?
4. Does the target runtime actually load that scope with the required precedence?
5. Does the text state a concrete trigger, action or outcome, and any necessary boundary or safe alternative?
6. Does the rule or any import cross a trust boundary, and is that boundary intentional and reviewable?
7. Can the agent verify the result, and can a maintainer detect when the rule has become stale?

Do not add the rule until these answers justify its context and maintenance cost.
