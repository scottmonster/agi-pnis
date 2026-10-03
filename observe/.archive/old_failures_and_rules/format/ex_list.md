# Code Design Concepts Examples

Code Design Concepts - a named, reusable idea for understanding, structuring, evaluating, or improving software design, including patterns, refactorings, techniques, and recognized design problems such as code smells and anti-patterns.

## Examples

1.1.1 **Guard Clauses** _(Refactoring; also known as: replace nested conditional with guard clauses)_ - Handle exceptional or invalid cases at the start, leaving the normal path flat. It makes the dominant path visible and reduces nesting. _Related:_ Early Exit.

1.2.10 **Finite-State Machine (FSM)** _(Pattern)_ - Represent legal states and transitions explicitly, rather than letting them emerge from dispersed flags and conditionals. It makes state-dependent behavior and invalid transitions inspectable. _Related:_ State, Repeated Type Conditional.

2.1.11 **Split Phase** _(Refactoring)_ - Separate processing that performs different conceptual jobs into distinct stages. It makes each stage's inputs, outputs, and reasoning model clearer.

3.1.4 **Replace Primitive with Object** _(Refactoring; also known as: replace data value with object; replace type code with class)_ - Represent a domain value with a small type rather than a raw primitive. It gives validation, formatting, and rules a single explicit home. _Related:_ Primitive Obsession, Value Object.

3.2.4 **Data Mapper** _(Pattern)_ - Keep mapping between domain objects and storage representations in a separate layer. It can keep persistence details out of domain code, at the cost of another abstraction. _Related:_ Active Record.

4.1.16 **Dependency Injection** _(Pattern)_ - Supply a collaborator from outside the object, commonly through its constructor, rather than creating or locating it internally. Dependencies become visible in the contract and independently configurable. _Related:_ Service Locator.

4.2.6 **Adapter** _(Pattern)_ - Wrap an incompatible interface in one expected by clients. It isolates foreign or legacy API differences.

4.2.18 **Observer** _(Pattern)_ - Let dependents subscribe to state changes from a subject. It decouples publishers and listeners, while making event order and lifetime important.

1.3.7 **Structured Concurrency** _(Pattern)_ - Scope concurrent work so child tasks complete or are cancelled before their parent scope finishes. It keeps lifetimes, cancellation, and error propagation visible instead of leaving detached work. _Related:_ Futures/Promises.

5.2.4 **Shotgun Surgery** _(Code smell)_ - One conceptual change requires many small edits across locations. Knowledge of one rule is scattered and omissions become likely. _Related:_ Move Function.


