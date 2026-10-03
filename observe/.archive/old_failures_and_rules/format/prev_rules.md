# Prevention-Mode Code Design Rules

Use one cumulative level while implementing or modifying code. These are candidate task-scoped rules: retain a rule only when it prevents a demonstrated, recurring failure in the work it covers. Use `list_complete.md` as the diagnostic catalog for review rather than loading its full taxonomy as implementation guidance.

_minimal_

## 1. Implementation design

- When exceptional or invalid cases obscure the ordinary flow, handle them early so the normal path remains flat and visible.

- When replacing an algorithm or making a structural refactoring, preserve observable behavior.

_min-plus_

## 1. Implementation design

- When exceptional or invalid cases obscure the ordinary flow, handle them early so the normal path remains flat and visible.

- When replacing an algorithm or making a structural refactoring, preserve observable behavior.

- Introduce an abstraction, parameter, hook, or extension point only for a present burden, not an imagined future need.

_standard_

## 1. Implementation design

- When exceptional or invalid cases obscure the ordinary flow, handle them early so the normal path remains flat and visible.

- When replacing an algorithm or making a structural refactoring, preserve observable behavior.

- Introduce an abstraction, parameter, hook, or extension point only for a present burden, not an imagined future need.

- For predictable conditions, use a precheck instead of an exception as ordinary branching. Keep exceptions for truly exceptional failures.

- Separate a routine that reports information and changes state into a query and a command when callers need to reason about observation and mutation separately.

_standard-plus_

## 1. Implementation design

- When exceptional or invalid cases obscure the ordinary flow, handle them early so the normal path remains flat and visible.

- When replacing an algorithm or making a structural refactoring, preserve observable behavior.

- Introduce an abstraction, parameter, hook, or extension point only for a present burden, not an imagined future need.

- For predictable conditions, use a precheck instead of an exception as ordinary branching. Keep exceptions for truly exceptional failures.

- Separate a routine that reports information and changes state into a query and a command when callers need to reason about observation and mutation separately.

- Make a dependency explicit when obtaining it internally would hide a meaningful dependency from the function or object's contract.

- Give a domain concept its own type when it needs validation, formatting, or rules that raw primitives would scatter.

_strict_

## 1. Implementation design

- When exceptional or invalid cases obscure the ordinary flow, handle them early so the normal path remains flat and visible.

- When replacing an algorithm or making a structural refactoring, preserve observable behavior.

- Introduce an abstraction, parameter, hook, or extension point only for a present burden, not an imagined future need.

- For predictable conditions, use a precheck instead of an exception as ordinary branching. Keep exceptions for truly exceptional failures.

- Separate a routine that reports information and changes state into a query and a command when callers need to reason about observation and mutation separately.

- Make a dependency explicit when obtaining it internally would hide a meaningful dependency from the function or object's contract.

- Give a domain concept its own type when it needs validation, formatting, or rules that raw primitives would scatter.

- Route access to mutable data through a named access point when direct access would leak representation or obscure mutation sites.

- Use a null or special-case object only when its behavior is coherent; do not conceal a meaningful absence or failure.

- Put behavior with the data and invariants it principally uses. Do not make clients traverse internal object graphs when an operation at the boundary can hide the delegate.

- When behavior is repeatedly selected by type, state, or policy, make the variation explicit instead of distributing type or mode conditionals.
