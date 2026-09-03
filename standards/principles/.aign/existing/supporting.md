### Single Responsibility

```md
### Single Responsibility - Keep Responsibilities Cohesive

Give each module, class, component, or function one coherent responsibility and one primary reason to change.

Do not interpret "single responsibility" as requiring every unit to perform only one small operation.

1. Group behavior that contributes to the same responsibility.
2. Separate behavior when it serves a materially different purpose or changes for a different reason.
3. Prefer cohesive units over large components that coordinate unrelated concerns.
4. Avoid splitting closely related behavior merely to reduce file, class, or function size.
5. Do not create additional services, classes, modules, or wrappers unless the separation creates a meaningful boundary.
6. Keep orchestration together when its responsibility is coordinating a specific workflow.
7. Refactor when a unit repeatedly changes for unrelated reasons or requires knowledge from unrelated domains.

When considering a split, identify the distinct responsibility and reason for change that justify the new boundary.
```

Core test:

> **Would these parts normally change for different reasons?**

If yes, separation is probably justified. If they change together as part of one coherent responsibility, keep them together.

---

### Principle of Least Astonishment

```md
### Principle of Least Astonishment - Make Behavior Predictable

Design code, APIs, interfaces, configuration, and behavior so that they match reasonable expectations established by their names, context, conventions, and surrounding system.

Avoid surprising behavior even when it is technically valid or locally convenient.

1. Make names accurately describe behavior and effects.
2. Follow established project, language, and platform conventions unless there is a concrete reason not to.
3. Keep similar operations consistent in naming, inputs, outputs, errors, and side effects.
4. Avoid hidden side effects, implicit mutations, unexpected global state changes, or surprising control flow.
5. Make destructive, expensive, or irreversible behavior explicit.
6. Prefer conventional defaults over unusual behavior requiring special knowledge.
7. Do not overload familiar concepts with substantially different semantics.
8. When unavoidable behavior may surprise a reasonable caller, make it explicit through the interface, naming, or documentation.

When choosing between equally adequate behaviors, prefer the one a reasonable user or maintainer is more likely to predict correctly.
```

Core test:

> **Would a reasonable caller correctly predict what this does without inspecting its implementation?**

If not, either change the behavior or make the difference explicit.

---

### Law of Demeter

```md
### Law of Demeter - Limit Knowledge of Other Components

Keep components dependent on the public behavior they need rather than the internal structure of other components.

Avoid reaching through one object or component to manipulate the internals of another.

1. Interact primarily with direct collaborators.
2. Prefer asking a component to perform an operation over navigating through its internal object graph to perform it externally.
3. Avoid code that depends on long chains of internal relationships.
4. Keep internal representation changes from unnecessarily propagating to callers.
5. Expose focused operations when they represent meaningful behavior.
6. Do not create forwarding methods, wrappers, or abstraction layers solely to eliminate every chained access.
7. Allow straightforward traversal of transparent data structures when no meaningful encapsulation boundary exists.
8. Apply the rule where it reduces coupling, not as a mechanical restriction on property access.

Refactor when callers repeatedly require knowledge of another component's internal organization in order to perform normal operations.
```

Core test:

> **Does this code depend on what another component does, or on how that component is internally organized?**

Depend on behavior where practical. Do not mechanically hide ordinary data access behind meaningless wrappers.

---

### Fail Fast

```md
### Fail Fast - Detect Invalid States Near Their Source

Detect and report invalid inputs, violated assumptions, unsupported states, and unrecoverable conditions as early as practical and as close as possible to where they originate.

Do not allow invalid state to propagate when the system cannot meaningfully recover from it.

1. Validate important external inputs at system and trust boundaries.
2. Check required preconditions before performing dependent work.
3. Reject invalid or impossible states before they can produce secondary failures.
4. Produce errors that identify the actual violated condition rather than allowing unrelated failures later.
5. Avoid silently substituting defaults, ignoring failures, or continuing with corrupted state unless that behavior is explicitly required.
6. Validate once at the appropriate boundary rather than defensively repeating the same checks throughout trusted internal code.
7. Do not fail early when graceful degradation, retries, recovery, or partial operation is an established requirement.
8. Distinguish expected recoverable conditions from programmer errors and invalid system states.

When an invalid condition cannot be handled meaningfully at the current boundary, surface it immediately rather than allowing execution to continue.
```

Core test:

> **Can anything useful or correct happen after this condition has been detected?**

If not, stop there and report the actual problem.

Of these four, **Single Responsibility** and **Law of Demeter** need the strongest anti-overengineering caveats because applying either mechanically can easily create unnecessary files, wrappers, interfaces, and indirection.
