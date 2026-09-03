```md
### Composition over Inheritance - Assemble Behavior from Focused Components

Prefer composing behavior from small, focused components or collaborators rather than using inheritance to reuse implementation or build deep type hierarchies.

Use inheritance when there is a genuine subtype relationship and derived types can safely preserve the behavioral contract of the base type.

1. Prefer delegation, composition, and explicit collaboration for sharing behavior.
2. Use inheritance for true "is-a" relationships, not merely to avoid duplicating code.
3. Keep inheritance hierarchies shallow and easy to reason about.
4. Avoid base classes that accumulate unrelated behavior for many subclasses.
5. Prefer components that can be combined independently over subclasses that inherit large amounts of behavior implicitly.
6. Do not introduce interfaces, wrappers, or component layers solely to avoid all inheritance.
7. Use inheritance when it is the simpler and more natural representation of the domain.
8. Refactor inheritance toward composition when subclasses require extensive overrides, special cases, or knowledge of base-class internals.

When choosing between inheritance and composition, prefer the approach that produces the clearest behavioral boundaries with the least coupling and indirection.
```

The core test I would use is:

> **Is this genuinely a subtype relationship, or am I using inheritance mainly to reuse behavior?**

If it is primarily reuse, composition is usually the better default.

The important caveat is not to turn "composition over inheritance" into "inheritance is forbidden." Simple, stable subtype hierarchies can still be the clearest design.
