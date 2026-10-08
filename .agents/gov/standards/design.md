# Designing Codebases for Human and AI Coding-Agent Change

## Purpose and design target

Design codebases so people and AI coding agents can find, understand, change, and verify behavior safely.
This guidance covers repository organization, module boundaries, code structure, dependencies, tests, documentation, and agent-facing affordances.
When a recommendation adds material complexity, apply the Engineering Principles Framework's justification test.
The right design still depends on the product, language, deployment model, security, reliability, performance, and team.

Design for a **contained change**: an ordinary change should be understandable, implementable, and verifiable within one coherent repository area, its explicit contracts, and its immediate dependencies.

```text
requirement -> obvious capability or module -> published contract and entry point
            -> focused implementation and nearby tests -> deterministic validation command
```

This target unifies maintainability, readability, discoverability, separation of responsibilities, local reasoning, and testability.
It also reduces irrelevant retrieval, hidden relationships, edit dispersion, and uncertain verification for agents.

Contained change is a diagnostic model, not a score or a demand to minimize every count.

- **Discovery locality**
  - Question: Can domain terms find the behavior?
  - Healthy outcome: One obvious capability, entry point, and rule owner.
- **Reasoning locality**
  - Question: What code and dependencies must a reader understand to predict the change's effect?
  - Healthy outcome: The module, its contract, and a comprehensible neighborhood.
- **Edit locality**
  - Question: How widely must implementation change?
  - Healthy outcome: Edits stay with the owner and genuinely affected contracts.
- **Verification locality**
  - Question: How broadly must validation run?
  - Healthy outcome: Focused, reliable checks run before broader checks.

Use the model to investigate recurring change pain.
A change spanning related files can still be contained; a one-file change can be unsafe when it silently affects many consumers.
The problem is unnecessary discovery, reasoning, editing, or verification beyond the behavior's natural boundary.

## Evidence and use

Information hiding, deliberate modular decomposition, controlled coupling, understandable names, and executable verification are established software-engineering principles whose implementation depends on context.
Evidence specific to coding agents is newer and narrower: repository benchmarks show that retrieval, cross-file context, environment interaction, and tests affect performance, not that one universal AI-friendly architecture exists.
Treat the agent guidance below as practical inferences to validate locally, unless a statement identifies direct evidence.

## Contain behavior and dependencies

### Ownership and boundaries

Each meaningful business behavior should have one clear owner for its authoritative policy, invariant, and decision.
Other layers may enforce, project, or validate that policy, but should not redefine it.
For example, a client may give prompt feedback and a database may protect integrity while one application or domain module owns the policy.

Give every module one coherent responsibility: a domain capability, policy, protocol, integration, storage decision, or another body of knowledge that can change independently.
Hide decisions behind behavior instead of grouping only sequential processing steps.
Before creating or revising a boundary, ask:

- What rule, data, policy, or invariant has one natural owner?
- Which implementation details can callers avoid knowing?
- What changes together for a meaningful reason, and can a small contract contain it?
- Does the boundary remove more reasoning than it adds in navigation, indirection, and coordination?
- Is its immediate dependency neighborhood comprehensible?

High cohesion means that a module's parts serve its stated purpose together.
Low coupling means that callers depend on the contract, not data representation, internal types, call order, global state, or implementation details.
Inspect these properties; do not optimize them mechanically.

### Organization, distribution, and shared code

Organize first by capability, then by technical role when that role clarifies a real responsibility.
Keep a capability's public contract, rules, adapters, tests, and focused documentation close together.

```text
src/
  billing/
    api/             # contract used by other modules
    domain/          # rules, types, and invariants
    application/     # use cases and transaction boundaries
    adapters/        # persistence and external providers
    tests/
    README.md
  identity/
  catalog/
  platform/          # deliberately shared infrastructure
app/
  composition-root/
```

This is a property, not a required directory layout: small programs may need fewer levels, and products may need product or deployable-unit boundaries above capabilities.
Capability-first organization can reduce change scattering caused by strict layer-only trees, but this is an engineering inference, not a universal empirical law.

Prefer a modular monolith for internal boundaries: cohesive modules with real visibility and import boundaries retain local calls, transactions, debugging, and refactoring.
Add a service or process boundary only for a concrete operational need, such as independent deployment, scaling, trust isolation, fault isolation, or organizational ownership.
Distribution adds APIs, partial failure, compatibility, deployment, observability, and data-consistency work, so it usually increases whole-system reasoning.

Keep dependencies small, understandable, and directional.
Policy and domain code should depend on stable contracts.
Technology-specific adapters should depend on those contracts.
The composition root should assemble the application.

```text
policy -> port or contract <- adapter
                         ^
                 composition root wires both
```

Avoid cycles, peer imports of internals, and direct access to another capability's tables, files, caches, or framework objects.
Enforce important boundaries with language visibility, package rules, import checks, or build rules; checked constraints last longer than diagrams or convention alone.

Give `shared`, `common`, `core`, `helpers`, and `utils` an owner, clear inclusion rule, and small public surface.
Extract shared code only for the same stable concept, invariant, or contract across every consumer.
Similar syntax is insufficient; modest duplication can cost less than a premature shared abstraction that couples unrelated futures.

## Design for local reasoning

Expose the smallest stable, behavior-focused interface callers need.
Make material inputs, outputs, errors, side effects, ordering, ownership, and consistency guarantees explicit.
Use types, schemas, and boundary validation to reject incomplete or illegal states early.
Do not casually expose ORM entities, mutable internal collections, framework requests, provider-specific errors, or unstructured maps across a module boundary.
Use domain values and named concepts where vocabulary is stable.

At a call site, make important decisions, state changes, I/O, transactions, retries, and failures visible.
Separate deterministic rules from effectful orchestration when that improves understanding or testing.
Construct dependencies at an obvious composition point or pass them explicitly.
Avoid mutable globals, ambient context, import-time initialization, service locators, reflection, convention-only registration, implicit writes, and broad event buses unless their capability justifies lost traceability.
When necessary, provide an explicit registration point, typed contract, named owner, and reliable producer-consumer trace.

Use abstractions only when they compress reasoning for callers and stay inspectable for maintainers.
For example, `invoice.total()` can hide tax, discounts, rounding, and currency rules behind one meaningful contract.
A factory, strategy, registry, and decorator chain that a caller must reconstruct may add abstraction without reducing reasoning.
A narrow public surface should still have direct files, explicit calls, conventional imports, and visible construction.
Do not mistake runtime invisibility for encapsulation.

Create a function, class, or file when it names a stable responsibility, protects an invariant, removes meaningful duplication, or creates a useful test seam.
Keep code together when extraction would make a one-use wrapper or navigation chain.
Do not optimize file, function, class, or abstraction counts independently.
No universal line limit reliably measures clarity.
Judge a unit by whether a reader can summarize its purpose, inputs, outputs, effects, and exceptional behavior without reconstructing unrelated detail.
A cohesive 500-line module can be clearer than many small files connected through indirection.
Meaningful intermediate values and decomposed conditions can clarify hard code; meaningless extraction can do the reverse.

Use one precise, searchable domain term consistently in directories, public APIs, types, functions, tests, configuration, logs, and documentation.
Name distinctions such as command versus query, item versus collection, optional versus required, and domain concept versus technical mechanism.
Avoid catch-all names such as `Manager`, `Handler`, `Processor`, `Helper`, `Util`, `Common`, and `Data` when a specific name exists.
Naming and complexity affect comprehension, but research prescribes no universal naming style or size threshold.

Start with concrete behavior.
Generalize only when multiple clients share a stable rule, invariant, or contract, or coordinated changes show that an abstraction has a real owner.
Keep meaningful variation explicit in strategy implementations or call sites.
Be wary of interface-per-class, speculative flags, deep inheritance, generic application frameworks, and factories around one trivial implementation.
Prefer composition to inheritance unless a deliberate, stable subtype contract exists.

## Make repositories navigable and verifiable

Keep the directory tree only as deep as discoverability, ownership, and local reasoning require.
A new contributor should be able to use a capability's user-facing term to find its entry point and contract, trace implementation and tests, and locate a validation command without unwritten knowledge.
Keep the repository root an entry point: its README should state what the system does, build and validation steps, major components, and deeper links.
Add a short local README only where a non-obvious subsystem needs orientation that code cannot provide.

Separate generated and vendored code, build output, migrations, experiments, and maintained application code.
Mark derived files, identify their source, and document regeneration.
For each rule or contract, choose an authoritative representation.
Documentation should route readers to the authoritative code, schema, test, or decision record instead of duplicating details that drift.

Maintain concise, versioned documentation for:

- Module purpose, public contracts, owner, and permitted dependencies.
- Setup, build, type-check, test, and release commands.
- External contracts and compatibility guarantees.
- Non-obvious architectural decisions, their trigger, and their reconsideration condition.
- Domain terms, invariants, security boundaries, and operational constraints that code cannot express adequately.

Treat documentation as maintained code.
Update and review it with the change.
Retire it when superseded.
Short documentation near a boundary is generally more useful than a detached long manual.

Use fast tests for pure rules, edge cases, and invariants.
Add integration or contract tests at persistence, messaging, and external-service boundaries.
Maintain a smaller end-to-end set for critical workflows and deployment wiring.
Tests should be deterministic, isolated, readable, and named for the behavior they establish.
Prefer real implementations or contract-honoring fakes to mocks that assert incidental calls or private sequencing.

From a clean checkout, document runnable commands for formatting, static analysis, type checking, focused tests, relevant integration tests, and a production-like build.
Keep fast feedback fast; reserve expensive checks for CI or an explicit broader command.
Isolate clocks, randomness, network access, credentials, and external-service dependencies.
Coverage can reveal untested paths, but it is not evidence that behavior is correct.
Use it as a signal, not a goal.

Automate formatting, linting, typing, dependency, security, API or schema compatibility, and architecture-boundary checks when their value justifies their maintenance cost.
Keep changes small and behaviorally coherent.
Describe the affected contract and validation in review to reduce architectural erosion.

## Apply patterns conditionally

- **Capability or domain slices**
  - Use when a capability owns cohesive rules, data, and workflows.
  - Do not duplicate cross-cutting invariants.
- **Ports and adapters**
  - Use when a technology or protocol is volatile, external, or needs a substitutable test boundary.
  - Define a small port from the policy consumer's needs.
- **Functional core with imperative shell**
  - Use when important rules can be deterministic transformations.
  - Do not force artificial purity on a stateful workflow.
- **Explicit composition root**
  - Use when construction and configuration need a visible owner.
  - Keep wiring separate from domain rules.
- **Modular monolith**
  - Use when one deployable needs strong internal boundaries.
  - Enforce visibility and dependencies.
- **Architecture decision record**
  - Use when a material trade-off would otherwise be rediscovered.
  - Keep it short and mark it superseded when needed.

## Add agent affordances with evidence limits

Repository tasks require models to retrieve cross-file context, coordinate edits, execute tools, and use environmental feedback; they are not single-file completion.
One benchmark setting found that static dependency information improved repository-level completion, and graph-guided localization research supports the narrow claim that import, call, inheritance, and containment data can help find relevant code.
Tests and tools are necessary feedback channels, but weak tests can accept behaviorally wrong patches.
Agent evaluation should use representative tasks, stable environments, and checks that probe required behavior rather than incidental implementation detail.

Apply the preceding human-oriented guidance, then:

- Keep a short `AGENTS.md`-style instruction file with setup, validation, architecture orientation, non-obvious constraints, and generated-code warnings.
- Scope specialized instructions to the relevant directory rather than putting an encyclopedia in every task context.
- Use explicit imports, typed contracts, schemas, stable identifiers, and conventional exports so people and tools can recover relationships.
- Keep behavior searchable through consistent domain vocabulary in code, tests, operational signals, and documentation.
- Give each capability focused tests and an obvious selection command.
- Keep configuration, dependency composition, request registration, and job registration in few visible entry points.
- Preserve intent in focused commits, clear change descriptions, and decision records when code does not expose the trade-off.

Repository-instruction mechanisms are product-specific.
Official documentation establishes supported behavior, not that a particular instruction-file design generally improves agents.

Treat these as hypotheses to test in the target repository:

- Enforced module boundaries reduce agent context use and incorrect cross-module edits.
- Consistent vocabulary and machine-recoverable dependencies improve retrieval and localization.
- Behavior-focused local tests make agent changes more correct and less brittle.
- Compact repository maps and generated dependency views improve orientation when they index source rather than replace it.

Measure these hypotheses with representative maintenance tasks.
Useful signals include:

- Time to find the change surface.
- Files and modules inspected or changed.
- Focused-test success.
- Review rework.
- Escaped defects.
- Human effort.

Do not substitute benchmark scores or token counts for production correctness.

## Avoid these defaults unless a justified exception applies

- Layer-only top-level trees that scatter a capability across broad technical directories.
- God modules, manager classes, shared mutable state, and universal data models for unrelated domains.
- Cycles, low-level back-references to policy, and reach-through access to module internals.
- Premature general frameworks, one-method wrappers, deep inheritance, and generic eventing used only to avoid direct calls.
- Runtime magic, stringly typed dispatch, convention-only registration, and implicit configuration that hide reachable behavior.
- Optimizing for small files, functions, or many abstractions instead of coherent reasoning units.
- Multiple sources of truth, including stale documentation and copied validation.
- Tests tied to implementation details, flaky environment-dependent tests, and validation that cannot run from a clean checkout.
- Service decomposition without a concrete operational or organizational need.

These are defaults, not bans.
An exception should have a current trigger, named owner, visible constraints, and a verification path.

## Adopt and review

Improve in this order:

1. Make the repository build, test, lint, type-check, and run from a clean checkout with documented commands.
2. Map top-level capabilities, behavioral owners, entry points, and permitted dependencies; separate generated and obsolete artifacts.
3. Find high-churn, high-defect, or hard-to-test areas; assess their four localities, then add a small contract and test seam around the main source of change.
4. Break cycles, replace reach-through access with owned contracts, and give cross-cutting rules a deliberate owner.
5. Simplify confusing public names, configuration paths, and control-flow entry points; automate important conventions.
6. Add architecture checks and decision records only when repeated erosion or a material trade-off justifies their cost.

For each material change, ask:

1. What behavior, constraint, or observed burden requires it?
2. Which module owns the authoritative behavior, rule, and data? Do other layers derive from rather than redefine it?
3. Is it discoverable from domain vocabulary, and is the module's immediate dependency neighborhood comprehensible?
4. Do names, types, configuration, documentation, and tests use the same domain concept?
5. What reliable clean-checkout check would fail if the intended behavior broke?
6. Are edits concentrated in the owner and genuinely affected contracts rather than unrelated modules?
7. Does it add a dependency, abstraction, state, or deployment boundary, and does the reasoning it compresses justify that cost?
8. Can focused validation establish behavior before broader checks, and can a new human or agent find that command without unwritten knowledge?
