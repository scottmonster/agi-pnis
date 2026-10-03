# Failure-Prevention Rules for AI Code Changes

## 1. Application

### 1.1 Priority

Rules are ordered from most impactful to least impactful. Apply higher rules first when rules conflict. A rule does not authorize work outside the request or override an established requirement, security control, compatibility constraint, or repository instruction.

### 1.2 Evidence

Each rule addresses one or more failures in [failures_complete.md](failures_complete.md). Use repository facts, observable behavior, and appropriate verification as evidence. Do not treat a plausible implementation, a passing narrow test, or an agent assertion as sufficient evidence by itself.

## 2. Rules

### 2.1 Preserve intent, constraints, and authority

Implement the actual requested outcome and every established constraint. Do not substitute a neighboring problem, infer unrequested policy, continue after corrective feedback, or claim completion before the outcome is established. When a consequential ambiguity cannot be resolved from authoritative repository evidence, state it and obtain direction before making the decision.

### 2.2 Protect security, privacy, and irreversible effects first

Before code accepts untrusted input, accesses protected data, invokes commands, loads resources, calls external services, changes persistent state, or performs a destructive action, identify the trust boundary and enforce the required validation, authorization, least privilege, and safe failure behavior. Code `MUST NOT` hard-code or expose secrets or sensitive data, grant access when a security check fails, or turn a security failure into apparent success.

### 2.3 Ground changes in the actual repository

Locate the behavior's owner, public contract, callers, tests, configuration, dependencies, schemas, generated sources, and local conventions before changing a material behavior. Read actual definitions and tool output. Do not invent symbols, APIs, packages, files, configuration, infrastructure, data fields, or environment assumptions.

### 2.4 State the present need before adding capability

For every material addition, name the current requirement, constraint, caller, incident, measured limit, policy, or existing burden that requires it. Do not add behavior, validation, fallback, configuration, extension points, compatibility paths, or operational machinery solely for a hypothetical future.

### 2.5 Choose the smallest adequate whole-system solution

Prefer direct, readable control flow and the cheapest existing repository, language, framework, schema, database, or infrastructure capability that meets the present need. Do not reimplement a platform feature or add a dependency, layer, service, asynchronous flow, cache, queue, worker, or optimization without a concrete reason the simpler option is insufficient.

### 2.6 Generalize only demonstrated commonality

Keep concrete cases separate until they have a stable shared responsibility, vocabulary, and reason to change, or until a current contract or invariant requires one authoritative representation. Do not introduce generic helpers, options objects, interfaces, factories, registries, patterns, wrappers, or type parameters around one stable use or a tiny closed set.

### 2.7 Keep responsibilities cohesive and dependencies visible

Place behavior with the domain concept and owner that govern it. Create a boundary only when distinct policy, dependency, lifecycle, failure mode, ownership, or independently changing responsibility makes the boundary easier to understand, verify, or contain. Avoid pass-through layers, global service locators, vague manager classes, circular reach-through access, fragmented workflows, and junk-drawer utilities.

### 2.8 Change the smallest complete surface

Make the focused change that satisfies the requirement, then update every affected contract, caller, schema, documentation, configuration, compatibility path, and test. Do not mix an unrelated refactor, cleanup, dependency change, formatting churn, file move, or toolchain upgrade into the change unless it is necessary to deliver the requested behavior safely.

### 2.9 Implement complete and explicit behavior

Cover normal, boundary, invalid, empty, duplicate, ordering, and state-transition cases that the contract makes meaningful. Do not leave a stub, placeholder, hard-coded temporary result, missing import, undefined state, or partial implementation on a production path. Use names, types, and parsing rules that match the actual contract and local conventions.

### 2.10 Make failure behavior deliberate

Handle a failure at the lowest layer that can take a correct, meaningful action; otherwise preserve context and propagate it. Do not swallow exceptions, return plausible fake defaults, destroy diagnostic context, or translate errors without semantic value. Retry only transient failures when the operation is safe to retry, with defined limits, timeout, cancellation, and idempotency behavior.

### 2.11 Preserve state, resource, and ordering invariants

Make transaction boundaries, cleanup, ownership checks, atomicity, resource lifetimes, and state transitions explicit where the behavior depends on them. Do not assume operation, import, startup, registration, or test order is harmless. Bound work, buffers, caches, queues, and waits when an unbounded form can create a present operational failure.

### 2.12 Use dependencies and environments deliberately

Confirm that a package exists, is maintained, is compatible with the project, and is declared reproducibly before adding it. Prefer the existing dependency and build conventions. Do not rely on global or transitive installation, wildcard versions where reproducibility matters, hard-coded environment-specific paths or URLs, fabricated install commands, or credentials in source or build configuration.

### 2.13 Measure before trading clarity for performance or distribution

Use the simplest implementation that meets the established limit. Before adding complex algorithms, parallelism, caching, batching, streaming, background processing, or distributed coordination, identify the actual workload, bottleneck, correctness constraint, and measurement or operational evidence that justifies it. Avoid repeated remote calls in loops and N+1 behavior when the current workload makes them materially harmful.

### 2.14 Write tests that can disprove the change

Add or update the narrowest durable tests needed to establish changed behavior, important edge cases, regressions, and meaningful failure paths. Assert externally observable outcomes and contracts, not merely implementation details or mocked interactions. Do not weaken, skip, delete, or rewrite tests, expected output, or evaluation harnesses simply to make a failure disappear.

### 2.15 Verify the full affected contract

Run the narrowest reliable validation first, then the broader checks required by the affected contract, boundary, or repository instructions. Verify compilation or type checking when applicable, relevant existing regressions, integration points, and user-visible behavior. Treat passing tests as evidence, not as proof that the requirement is satisfied.

### 2.16 Use observability to make operational failures actionable

Record meaningful outcomes, failures, latency, state transitions, and boundary interactions when they must be diagnosed or operated. Log an unexpected terminal failure once at an appropriate boundary, with safe, useful context. Do not emit secrets, sensitive payloads, high-cardinality data, unbounded telemetry, duplicate propagated errors, or step-by-step noise with no operational use.

### 2.17 Keep documentation and examples contract-accurate

Update documentation, examples, comments, configuration descriptions, and migration instructions when the behavior or public contract changes. Remove or correct material stale guidance. Comments should explain non-obvious constraints, invariants, decisions, or rationale, not restate syntax or promise behavior the code does not provide.

### 2.18 Maintain one authoritative representation

Reuse existing behavior and keep each rule, configuration value, mapping, invariant, and compatibility contract in one clearly owned source of truth. Remove obsolete paths, debug output, temporary flags, experiments, and generated artifacts when the change makes them unnecessary. Do not leave a partial migration, duplicated feature path, or dead code that preserves conflicting behavior.

### 2.19 Learn from contradictory evidence

When a command, test, error, review, or user correction contradicts the current approach, stop and re-evaluate the failing path and repository facts. Do not repeat an unchanged failed attempt, patch only its visible symptom, persist in the wrong file, or add another abstraction to conceal the misunderstanding.

### 2.20 Keep exploration and execution proportionate

Inspect enough to make the next decision safely, then act. Avoid tool, search, build, installation, or planning loops that do not add decision-relevant information. Keep working state clean, preserve unrelated user changes, revert abandoned experiments, and report verification and material uncertainty accurately.

### 2.21 Prefer clarity over clever compression

Use direct names and control flow that reveal the important decision, state change, I/O, transaction, retry, and failure path. Extract a cohesive operation when it reduces reasoning, but do not split straightforward code into navigational fragments. Avoid unnecessary branches, return-followed `else` blocks, dense expressions, duplicated comments, and explanations that obscure rather than clarify.
