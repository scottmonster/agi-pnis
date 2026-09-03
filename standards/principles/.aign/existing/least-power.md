```md
### Principle of Least Power - Use the Least Powerful Sufficient Mechanism

Choose the least powerful language, abstraction, mechanism, representation, or tool that adequately satisfies the current requirements.

More powerful mechanisms usually permit more behavior, states, and complexity. Do not introduce that additional capability unless the problem requires it.

1. Prefer static data over executable logic when data is sufficient.
2. Prefer configuration over custom code when the configuration clearly expresses the required behavior.
3. Prefer simple data structures over richer object models when additional behavior is unnecessary.
4. Prefer direct functions and modules over frameworks, plugin systems, metaprogramming, or dynamic dispatch when simpler mechanisms suffice.
5. Prefer constrained interfaces and representations that make invalid or unintended behavior harder to express.
6. Use the language, dependency, protocol, or tool with the smallest capability set that adequately solves the problem.
7. Introduce more powerful mechanisms only when a concrete requirement cannot be handled adequately by the simpler alternative.
8. Do not choose a weaker mechanism when doing so materially harms correctness, clarity, maintainability, performance, security, or other established requirements.

When moving to a more powerful mechanism, identify the specific capability that requires it.
```

The core test I would use is:

> **What capability do we need that the simpler mechanism cannot provide?**

If there is no concrete answer, use the simpler mechanism.

This complements KISS but is slightly different: **KISS minimizes overall complexity; Least Power minimizes the expressive power and capability of the mechanism used.**
