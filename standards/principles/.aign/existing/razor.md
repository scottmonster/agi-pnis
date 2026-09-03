```md
### Occam's Razor - Prefer the Design with Fewer Necessary Assumptions

When multiple designs adequately satisfy the same requirements, prefer the one that depends on fewer assumptions, mechanisms, concepts, dependencies, states, and special cases.

Do not add complexity unless it provides a concrete benefit required by the problem.

1. Compare designs against the same requirements and constraints.
2. Prefer the design with fewer independent concepts and moving parts.
3. Prefer solutions that require fewer assumptions about future behavior, usage, environment, or change.
4. Prefer existing mechanisms over introducing new ones when they are equally adequate.
5. Avoid speculative layers, generalized frameworks, fallback paths, and special cases that are not currently required.
6. Do not preserve complexity merely because it provides more theoretical flexibility or elegance.
7. Do not choose a simpler-looking design if it hides or transfers greater complexity elsewhere.
8. Accept additional complexity when it materially improves correctness, security, reliability, maintainability, performance, or another established requirement.

When choosing the more complex design, identify the specific requirement or benefit that justifies each material addition.
```

The core test I would use is:

> **What necessary assumption or capability does the more complex design provide that the simpler adequate design does not?**

If there is no meaningful answer, prefer the simpler design.

The distinction from KISS is subtle: **KISS asks whether the solution is unnecessarily complex. Occam's Razor helps choose between multiple adequate solutions by preferring the one that requires fewer assumptions and mechanisms.**
