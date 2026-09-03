Something like:

```md
### KISS - Prefer the Simplest Adequate Solution

Choose the simplest implementation that correctly satisfies the current requirements and constraints.

Simplicity means minimizing the concepts, abstractions, dependencies, indirection, configuration, state, control flow, and special cases required to understand and maintain the solution.

When multiple approaches adequately solve the problem:

1. Prefer direct code over additional abstraction.
2. Prefer fewer layers, components, dependencies, and moving parts.
3. Prefer explicit behavior over hidden, implicit, or highly dynamic behavior.
4. Prefer existing language, platform, or project capabilities over introducing new machinery.
5. Prefer straightforward control flow and data structures over generalized frameworks or patterns.
6. Introduce abstraction or indirection only when it removes greater complexity than it adds.
7. Do not add flexibility, configurability, extensibility, or infrastructure without a current requirement that justifies it.
8. Do not simplify by removing behavior, correctness, necessary validation, or required constraints.

Evaluate complexity across the whole affected system, not just the local implementation. A locally shorter solution is not simpler if it shifts substantial complexity elsewhere.

When a more complex solution is proposed, require a concrete reason the simpler adequate solution is insufficient.
```

The core decision test I would use is:

> **What is the simplest solution that fully satisfies what is required now?**

And for proposed complexity:

> **What current requirement makes this additional complexity necessary?**

If there is no concrete answer, the complexity should generally not be added.

I would also explicitly distinguish **simple** from **short**. A 10-line clever implementation can be substantially more complex than 20 lines of obvious code. KISS should optimize for the amount of mental and structural complexity required to understand and maintain the system, not merely line count.
