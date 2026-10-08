# Testing Strategy Decision

## 1. Decision

Use testing to protect important behavior and system boundaries without attempting to test every piece of code.

This strategy applies the Engineering Principles Framework: add or retain tests when their confidence benefit justifies their maintenance cost.

The goal is **meaningful confidence at proportionate test and maintenance cost**, not maximum test count or coverage percentage.

## 2. Testing approach

- **Unit test important application logic** such as calculations, parsing, transformations, validation, state transitions, permission decisions, algorithms, and meaningful edge cases.
- **Integration test important boundaries** such as databases, filesystems, external APIs, authentication, serialization, and framework integration. Test realistic failure modes when they matter, including timeouts, malformed responses, permissions, retries, and serialization compatibility.
- **Use end-to-end tests sparingly** for a small number of critical user workflows that need verification across the complete system.
- **Add regression tests for bugs with meaningful recurrence risk or blast radius.** A production data-loss or authorization bug normally warrants a regression test; a one-off low-impact defect may not.

## 3. What not to test by default

Do not create dedicated tests merely because code exists.

Generally avoid tests for:

- trivial getters, setters, assignments, and wrappers;
- behavior already guaranteed by the language or framework;
- private implementation structure that is not itself a contract;
- exact internal call sequences unless that interaction is important behavior;
- every possible branch or combination simply to increase coverage;
- mocks that assert incidental calls or private sequencing; prefer a real implementation or a fake that honors the contract, unless the interaction itself is important behavior.

## 4. Selection rule

Add an automated test when a current requirement, constraint, stable contract, or demonstrated regression risk makes a plausible failure materially harmful or hard to detect, and the test can detect it reliably at reasonable maintenance cost.

Tests are especially strong candidates for authorization, data migrations, money or irreversible state changes, concurrency or idempotency, security rules, and externally consumed API contracts.

Do not add a test when it would mostly duplicate the implementation, protect trivial behavior, or provide little additional confidence.

Selected tests should be deterministic, isolated, readable, named for the behavior they establish, and runnable through an obvious validation command.

## 5. Test level

Choose the narrowest reliable test that provides meaningful confidence in the behavior being protected:

```text
Important isolated logic
    -> Unit test

Important interaction with a real system boundary
    -> Integration test

Critical complete workflow
    -> End-to-end test

Trivial or low-risk implementation
    -> No dedicated test
```

Testing level is determined primarily by **behavior and dependency boundaries**, not by the code hierarchy. A function does not automatically require a unit test, and a feature does not automatically require every type of test.

## 6. Coverage

Code coverage is a diagnostic tool, not a target.

Use it to identify potentially important behavior that lacks tests, but do not pursue arbitrary thresholds such as 90% or 100% when additional tests would provide little practical confidence.

## 7. Guiding principle

> Test high-risk business rules and their meaningful edge cases, integration boundaries selectively, and complete workflows sparingly. Prefer a small number of durable, high-value tests over a large suite of implementation-sensitive tests.
