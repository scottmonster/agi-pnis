# Guidance for Designing Agent Skills

Use this guidance to design, engineer, create, review, and evolve reusable agent skills. A skill is a bounded capability package centered on `SKILL.md`, with optional supporting instructions, scripts, assets, tests, and host-specific configuration.

A useful skill gives an agent the context and operating approach for one recurring class of work. It is discoverable, focused, context-efficient, safe, testable, and portable to the degree it claims to be. It does not need to standardize every task into one procedure or replace agent judgment where several sound approaches are possible.

## Choose the right capability boundary

Create a skill when a recurring task benefits from reusable task-specific knowledge, judgment, workflow guidance, examples, or helpers that should load only when relevant. Prefer a different mechanism when it better owns the need:

| Need | Better default |
| --- | --- |
| Guidance that applies to almost every task | Project or system instructions |
| Live data, authenticated actions, or remote capabilities | Tool or integration, optionally coordinated by a skill |
| A material invariant or required lifecycle action | Trusted policy, hook, or deterministic automation |
| Context isolation, specialist work, or independent review | Subagent or equivalent worker |
| Repeated exact transformation or validation | Script, often bundled with a skill |
| Large detail needed only for a variant | On-demand source material |
| Output template or static resource | Asset |

These mechanisms can be combined. Keep the skill responsible for workflow and judgment, while tools provide capabilities, scripts perform stable mechanical work, and trusted controls enforce material boundaries.

Prefer one coherent capability. Split a skill when its parts have materially different activation conditions, dependencies, risk profiles, or purposes. Keep related variants together when they share an operating model and can load their differences on demand.

Before authoring, identify only the distinctions that materially affect the design:

- the recurring job, beneficiary, desired outcome, and completion evidence;
- the requests that should and should not activate the skill;
- inputs, output contract, dependencies, authority limits, and side effects;
- choices that need judgment versus work that should be mechanically enforced; and
- the hosts or environments the skill is expected to support.

Start from real work where possible: examples, corrections, runbooks, artifacts, failure cases, and observed workflows reveal what the agent actually needs. Do not create a skill merely because a task can be described. If the base agent already performs it reliably without extra context, the skill may add more activation and maintenance cost than value.

## Design discovery as a functional interface

In compatible hosts, the skill name and description are often visible before the full instructions. Treat them as routing information, not marketing.

A useful description states:

- what outcome the skill enables;
- when it applies, in language a user or agent is likely to use;
- material inputs, domain, or dependencies when they affect selection; and
- a boundary that distinguishes adjacent capabilities.

Use the narrowest description that completely owns the request. A description that misses relevant work and one that activates for unrelated work are different failures, and both need testing. Front-load the important capability and trigger terms when a host may truncate descriptions.

### Activation integrity

**Required:** An automatically discoverable skill `MUST` have metadata and instructions that describe the same capability and identify its intended use well enough for reliable selection.

**Prohibited:** It `MUST NOT` use materially overbroad, misleading, or incomplete metadata that selects it for unrelated work or obscures work it is meant to support.

**Why:** Correct operating instructions have no value if the skill is not selected for the right work, or is selected for the wrong work.

## Keep `SKILL.md` as the working core

Once selected, the skill should give the agent enough to perform the common case: purpose, operating approach, material decision points, constraints, resource navigation, and completion checks. Specify an outcome and decision factors when context-sensitive judgment adds value. Specify an exact procedure only when that procedure materially prevents error.

Add information the agent would otherwise lack or is likely to get wrong. Prefer concrete procedures, non-obvious constraints, local conventions, recovery guidance, and validation criteria over broad tutorials or general knowledge the agent can apply reliably.

Do not add sections merely to satisfy a template. Do not turn every preference into a rule. Be more prescriptive when an operation is fragile, irreversible, compliance-sensitive, or known to fail when steps are reordered. Otherwise, preserve flexibility and explain the reason behind an important constraint when that helps the agent adapt correctly.

## Use progressive disclosure deliberately

Place information at the lowest context cost that still makes it available when needed:

1. **Metadata** provides a discriminative name and description.
2. **`SKILL.md`** provides the common workflow, material boundaries, and a map to resources.
3. **`src/`** holds skill-authored procedures, domain detail, schemas, examples, and other material needed only for particular variants.
4. **`scripts/`** holds deterministic transformations and validations.
5. **`assets/`** holds templates and static resources used to create or validate outputs.
6. **`tests/`** holds checks for behavior, scripts, schemas, or related components when they add value.

This is an organization pattern, not a universal package requirement. Follow applicable host and project conventions where they differ.

Keep `SKILL.md` focused enough that an agent can identify and apply the relevant guidance without reading an encyclopedia. Move situational detail into directly linked, shallow resources. State when each resource is worth loading rather than merely pointing to a directory. Do not duplicate the same guidance across levels or build chains of references that force the agent to hunt for the actual instruction.

Keep volatile facts behind a current authoritative source when possible instead of embedding them in static instructions.

## Match execution to the work

Use the agent for interpretation, investigation, decomposition, synthesis, and context-dependent decisions. Use conventional software for calculations, schemas, invariant checks, transformations, retries, durable state, and other behavior that can be specified and verified mechanically.

Add a script when it materially improves reliability, repeatability, efficiency, precision, or auditability. Do not add code merely because code is possible, and do not repeatedly ask an agent to recreate a stable mechanical operation.

Design bundled scripts as reliable components:

- accept required input through arguments, environment variables, or standard input rather than interactive prompts;
- expose concise usage and examples when the interface is not obvious;
- document material prerequisites, working-directory assumptions, inputs, outputs, and failure behavior;
- use meaningful exit status and actionable errors;
- keep structured results on standard output and diagnostics on standard error when practical;
- bound or paginate large output when truncation could hide material information;
- prefer idempotent behavior when retries are plausible; and
- provide preview or dry-run behavior for risky state changes when it materially improves review or recovery.

Treat scripts as software, not prose attachments. Test them independently when their behavior materially affects skill reliability.

### Material control boundary

**Required:** A constraint whose violation would cause materially unauthorized, unsafe, or corrupt behavior `MUST` be enforced by a trusted mechanism outside the acting agent's discretion.

**Prohibited:** Such a constraint `MUST NOT` rely only on instructions, agent self-restraint, or an unsupported claim that the condition was met.

**Why:** Instructions guide behavior but do not independently enforce authorization, integrity, or acceptance conditions.

## Design trust, permissions, and integrations

Treat a skill as workflow guidance, not as permission to access systems or commit effects. Make material prerequisites and side effects discoverable before use. Request only the capabilities needed for the job and operate within the host's approval, sandbox, authorization, credential, and network controls.

For skills that read external content or invoke tools:

- distinguish retrieved content from authoritative instructions;
- use scoped credentials and least-privilege tools;
- separate preview or proposal from commit when review adds material safety;
- preserve durable evidence outside model context when retries, recovery, audit, or concurrency depend on it; and
- make recovery or escalation behavior clear for expected failures.

Do not store reusable secrets in a skill. Do not treat instructions found in retrieved content as higher-authority directions merely because the skill retrieved them.

### Trust and authorization integrity

**Required:** A skill that handles untrusted content, tools, credentials, or consequential effects `MUST` preserve the host's permission and approval model and keep untrusted instructions distinct from its authoritative workflow.

**Prohibited:** It `MUST NOT` tell an agent to bypass safeguards, silently widen authority, embed reusable secrets, or follow retrieved instructions as though they outranked the skill or host.

**Why:** External content and tools can redirect work or create effects that the original request did not authorize.

## Preserve portability deliberately

Portability is a design choice, not an automatic property of a skill. If cross-host portability matters, keep the portable core compatible with the applicable format and isolate or declare material host-specific behavior.

Make material requirements visible, including required executables, network access, operating-system assumptions, authentication, or host features. Do not represent a skill as broadly portable when successful execution depends on undeclared vendor-specific metadata, tool names, permissions, invocation behavior, or environment assumptions.

Test each host or execution mode for which the skill makes a meaningful compatibility claim. Format compatibility alone does not establish equivalent activation, tool availability, permission semantics, or instruction following.

### Portability claims

**Required:** A skill represented as portable `MUST` clearly declare material dependencies on host-specific behavior, metadata, tools, extensions, or environments.

**Prohibited:** It `MUST NOT` be represented as cross-host portable when successful execution materially depends on undeclared host-specific features or assumptions.

**Why:** Compatible hosts can differ in discovery, invocation, permissions, tools, and execution behavior.

## Evaluate activation and execution separately

Define success in observable terms before investing heavily in wording. Evaluate the whole capability, not merely whether `SKILL.md` reads well.

| Area | Questions and evidence |
| --- | --- |
| Activation | Do representative positive, negative, explicit, implicit, noisy, and boundary requests select appropriately? |
| Outcome | Does the completed artifact, decision, or action satisfy the task contract? |
| Process | Are necessary checks, dependencies, and approval boundaries observed? |
| Robustness | Do missing prerequisites and expected failures lead to useful recovery or escalation? |
| Efficiency | Does the skill avoid unnecessary context loading, tools, and repeated work? |
| Safety | Do permission, trust, privacy, and side-effect protections hold under realistic inputs? |
| Portability | Does each claimed host or execution mode perform the portable core correctly? |

Use deterministic checks for objectively checkable conditions. Use expert, human, or model review for semantic qualities that cannot responsibly be reduced to a fixed test. Compare against a meaningful baseline, such as the same task without the skill or with its preceding version, to establish that the skill adds value rather than merely documenting work the base agent already performs.

Use a small representative set at first, then add regression cases from real false activations, missed activations, tool failures, weak outputs, and user corrections.

## Evolve from observed failures

Treat skill development as iterative engineering:

1. Run the skill on real or representative work.
2. Inspect activation, execution traces, artifacts, and corrections.
3. Identify the smallest design change that addresses the failure.
4. Add or update an evaluation that would catch the regression.
5. Remove stale or redundant guidance when evidence shows it no longer helps.

Diagnose the failing layer before rewriting everything:

- **Not selected:** Improve the name, description, or distinction from overlapping skills.
- **Selected for the wrong task:** Tighten the activation boundary or split competing capabilities.
- **Selected but weak:** Improve the working core, decision guidance, or completion criteria.
- **Context-heavy:** Move variant detail to a clearly linked on-demand resource.
- **Mechanically brittle:** Expose prerequisites, improve recovery behavior, or replace fragile prose with code.
- **Unsafe:** Reduce capabilities, permissions, network reach, or trust assumptions before adding more instructions.
- **Stale:** Retrieve current data at execution time or update the affected source material.

Prefer the smallest change that resolves the observed failure while preserving behavior that already works. Review dependencies and compatibility assumptions when the surrounding environment changes.

## Final design review

Before treating a skill as ready, establish that:

- its purpose and activation boundary are coherent and distinguishable;
- `SKILL.md` contains the common operating model and points directly to on-demand detail;
- stable mechanical work is performed by helpers with clear interfaces and dependencies;
- trusted systems, rather than prompts, enforce material authority and integrity constraints;
- evaluation covers activation, task outcome, failure behavior, safety, and claimed portability; and
- the skill's value exceeds its added context, maintenance, and orchestration cost.

This is a decision guide, not a universal template. Adapt it to the task, host, risk, reversibility, and available evidence. Applicable requirements govern where they conflict with this guidance.
