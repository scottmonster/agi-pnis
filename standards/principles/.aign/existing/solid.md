```md
### SOLID - Apply Design Principles Where They Reduce Change Cost

Use SOLID principles to improve cohesion, substitutability, interface clarity, and dependency boundaries when they materially simplify maintenance and change.

Do not apply SOLID mechanically or introduce additional classes, interfaces, abstractions, or dependency layers solely to satisfy the principles.

1. **Single Responsibility** - Give a module, class, or component one coherent responsibility and one primary reason to change.
2. **Open/Closed** - Prefer extending stable behavior without modifying unrelated existing code, but do not create extension mechanisms before they are needed.
3. **Liskov Substitution** - Subtypes and implementations must preserve the behavioral expectations of the abstractions they replace.
4. **Interface Segregation** - Keep interfaces focused so consumers depend only on capabilities they actually use.
5. **Dependency Inversion** - Separate high-level policy from volatile implementation details when doing so creates a useful boundary.

Before introducing a SOLID-driven abstraction:

1. Identify the concrete maintenance, coupling, substitution, or change problem it solves.
2. Confirm that the abstraction represents a meaningful boundary rather than an anticipated future need.
3. Prefer the smallest design that resolves the problem.
4. Avoid interfaces with only one implementation unless the interface serves a current architectural, testing, or dependency-boundary purpose.
5. Avoid splitting cohesive behavior merely to make components smaller.
6. Do not add factories, dependency injection, inheritance hierarchies, or wrapper layers unless they reduce more complexity than they introduce.

When SOLID conflicts with KISS, YAGNI, or demonstrated simplicity, do not apply it mechanically. Prefer the simpler design unless the additional structure solves a concrete current problem.
```

The core test I would use is:

> **What specific change, coupling, or maintenance problem does this SOLID structure solve?**

If the answer is just "this is more SOLID," that is not enough justification.

I would especially avoid treating SOLID as a requirement to create interfaces, dependency injection, or extra classes everywhere. The principles are better used as **design diagnostics** than as structural quotas.
