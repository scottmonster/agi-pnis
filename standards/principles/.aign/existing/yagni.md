something like
```md
### YAGNI - Build Only for Demonstrated Needs

Implement only the functionality, flexibility, abstraction, configuration, and infrastructure required by current, concrete requirements.

Do not add code primarily to support hypothetical future use cases, anticipated requirements, possible reuse, or unspecified extensibility.

Before adding something beyond the immediate requirement:

1. Identify the current requirement that needs it.
2. Confirm that the requirement is concrete rather than speculative.
3. Prefer the smallest implementation that satisfies that requirement.
4. Do not generalize an implementation solely because it might need to support additional cases later.
5. Do not add extension points, configuration options, interfaces, abstractions, or infrastructure without a present use for them.
6. Defer decisions that can be made safely later with better information.
7. Remove unused functionality and speculative scaffolding when discovered.
8. Do not use YAGNI to omit requirements that are necessary for correctness, security, reliability, compatibility, or other established constraints.

When additional capability is proposed, require a concrete current use case that cannot be adequately handled by the simpler implementation.
```

The core test I would use is:

> **What current requirement requires this to exist now?**

If the answer is primarily "we might need it later," YAGNI says not to build it yet.

The important distinction is **defer, not forbid**. YAGNI does not mean the feature or abstraction is bad. It means its cost should be paid when there is enough evidence to justify it.
