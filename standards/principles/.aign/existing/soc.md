```md
### Separation of Concerns - Separate Distinct Responsibilities

Organize code so that distinct responsibilities, domains, and reasons for change are kept separate when combining them would increase coupling or make the system harder to understand, test, or modify.

Do not separate concerns mechanically or create additional layers solely because responsibilities can be named differently.

1. Identify the distinct responsibilities involved.
2. Keep concerns separate when they have different purposes, dependencies, policies, or reasons to change.
3. Group behavior that belongs to the same concern, even when it contains multiple operations.
4. Prefer clear boundaries between domains, infrastructure, presentation, persistence, and external integrations when those boundaries are materially useful.
5. Avoid allowing one concern to depend on the internal details of another.
6. Share data across boundaries through the smallest clear interface needed.
7. Do not create layers, services, modules, or adapters unless the separation reduces more complexity or coupling than it introduces.
8. Allow simple implementations to remain together when separating them would only add indirection without improving clarity or changeability.

When deciding whether to separate code, consider whether the parts are expected to change independently for different reasons.
```

The core test I would use is:

> **Do these responsibilities have meaningfully different reasons to change?**

If yes, separation is usually justified.

If not, splitting them may just create unnecessary structure.
