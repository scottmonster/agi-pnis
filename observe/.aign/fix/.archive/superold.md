## 2.1 Controllable
*(Directly preventable through instructions and structure)*
- **Misinterpretation of instructions**: Understands the request incorrectly.
- **Ignored requirements**: Fails to follow explicit instructions or constraints.
- **Constraint violation**: Breaks defined rules, limits, or specifications.
- **Formatting violations**: Output does not follow required structure or style.
- **Under-specification handling failure**: Cannot proceed with vague or missing details.
- **Over-complication**: Introduces unnecessary complexity.
- **Redundant implementation**: Rewrites existing logic instead of reusing it.
- **Invalid assumptions**: Proceeds based on incorrect or unsupported assumptions.
- **Incomplete implementation**: Leaves TODOs, stubs, or missing logic.
- **Repetition / redundant actions**: Repeats the same steps unnecessarily.

## 2.2 Influenceable
*(Improved with instructions, but not guaranteed)*
- **Failed task**: Unable to complete the objective or solve the problem.
- **Partial completion**: Only part of the required work is finished.
- **Incorrect output**: Produces results that do not match expectations.
- **Confusion / ambiguity**: Unable to determine the correct next step.
- **Hallucination**: Uses non-existent APIs, libraries, or facts.
- **Context drift**: Deviates from the original goal or task scope.
- **Inconsistent behavior**: Produces conflicting results for similar inputs.
- **Non-deterministic output**: Same input yields different results.
- **Logic errors**: Code is syntactically valid but functionally wrong.
- **Syntax errors**: Code fails to parse or compile.
- **Runtime errors**: Code crashes or throws exceptions during execution.
- **Regression**: Breaks functionality that previously worked.
- **Overfitting to examples**: Tailors solution too narrowly to sample inputs.
- **Tool misuse**: Uses tools incorrectly or inappropriately.
- **Tool failure handling error**: Fails to recover from tool errors.
- **Infinite loop / non-termination**: Repeats indefinitely without completion.
- **Premature termination**: Stops execution before completing the task.
- **Stalled / no progress**: Gets stuck without advancing the solution.
- **False positive validation**: Incorrectly reports success when failing.
- **False negative validation**: Incorrectly reports failure when correct.

## 2.3 Uncontrollable
*(Requires system, environment, or architectural changes)*
- **Context window overflow**: Loses earlier information due to token limits.
- **Timeout**: Exceeds allowed execution or response time.
- **Resource exhaustion**: Exceeds CPU, memory, storage, or token limits.
- **Dependency failure**: Uses missing or incompatible dependencies.
- **Dependency hell**: Introduces conflicting or incompatible package versions.
- **Environment mismatch**: Assumes incorrect runtime or system conditions.
- **Broken environment**: Corrupts or misconfigures the execution environment.
- **File system corruption**: Deletes, overwrites, or misplaces files incorrectly.
- **State loss**: Forgets prior context, decisions, or inputs.
- **Unauthorized action**: Performs actions outside allowed scope.
- **Security violation**: Introduces vulnerabilities.
- **Data leakage**: Exposes sensitive or private information.
- **Validation failure**: Fails checks or tests meant to verify correctness.