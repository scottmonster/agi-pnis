# AI Coding Smells Rules

## 1. Intent, specification, and scope failures

1.1 **Misinterpreting the requirement** - Verify the requested behavior, scope, and constraints before implementation when nearby interpretations are plausible, protecting the intended outcome.
1.2 **Partially satisfying the requirement** - Verify the requested behavior, scope, and constraints before implementation when nearby interpretations are plausible, protecting the intended outcome.
1.3 **Prompt-biased implementation** - Verify the requested behavior, scope, and constraints before implementation when nearby interpretations are plausible, protecting the intended outcome.
1.4 **Non-prompted behavior** - Verify the requested behavior, scope, and constraints before implementation when nearby interpretations are plausible, protecting the intended outcome.
1.5 **Scope creep** - Verify the requested behavior, scope, and constraints before implementation when nearby interpretations are plausible, protecting the intended outcome.
1.6 **Solving at the wrong abstraction level** - Verify the requested behavior, scope, and constraints before implementation when nearby interpretations are plausible, protecting the intended outcome.
1.7 **Ignoring explicit constraints** - Verify the requested behavior, scope, and constraints before implementation when nearby interpretations are plausible, protecting the intended outcome.
1.8 **Failing to resolve material ambiguity** - Verify the requested behavior, scope, and constraints before implementation when nearby interpretations are plausible, protecting the intended outcome.
1.9 **Persisting after correction** - Verify the requested behavior, scope, and constraints before implementation when nearby interpretations are plausible, protecting the intended outcome.
1.10 **Premature success claims** - Verify the requested behavior, scope, and constraints before implementation when nearby interpretations are plausible, protecting the intended outcome.

## 2. Repository and context-grounding failures

2.1 **Insufficient repository exploration** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.2 **Correct change in the wrong file** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.3 **Hallucinated local symbol** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.4 **Wrong attribute/member** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.5 **Wrong existing symbol name** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.6 **Public API hallucination** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.7 **API misuse** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.8 **Deprecated/similar-but-wrong API selection** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.9 **Environment conflict** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.10 **Project dependency conflict** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.11 **Configuration-schema conflict** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.12 **Data-schema conflict** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.13 **Asset/resource conflict** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.14 **Connection/infrastructure conflict** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.15 **Ignoring local conventions** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.16 **Ignoring architectural invariants** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.17 **Incomplete call-graph propagation** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.
2.18 **Cross-module semantic inconsistency** - Inspect the relevant repository code, contracts, dependencies, and conventions before changing code when project facts determine the solution, protecting compatibility.

## 3. Speculative architecture and needless abstraction

3.1 **Config flags / env vars nobody requested** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.2 **Speculative configuration surface** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.3 **Optional parameters never passed** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.4 **Generic helper with one caller** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.5 **Premature interface/protocol** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.6 **Trivial factory class** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.7 **Trivial builder** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.8 **Plugin/registry scaffolding for two known cases** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.9 **Strategy pattern for a tiny closed set** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.10 **Command/visitor/state pattern without corresponding complexity** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.11 **DI container in a small application** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.12 **Service locator / global dependency registry** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.13 **Thin “swappability” wrapper** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.14 **Excessive layering** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.15 **Repository abstraction over trivial persistence** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.16 **Generic manager/coordinator objects** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.17 **Event bus for direct interactions** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.18 **Mediator for a tiny object graph** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.19 **Speculative hooks/callbacks** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.20 **Abstract lifecycle framework** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.21 **Speculative async wrapper** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.22 **Speculative batching** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.23 **Speculative queue/worker architecture** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.24 **Speculative caching** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.25 **Premature concurrency/parallelism** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.26 **Premature microservice boundary** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.27 **CQRS/event sourcing for ordinary CRUD** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.28 **Distributed-systems machinery for a local workflow** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.29 **Premature optimization** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.30 **“Future-proof” indirection** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.31 **Over-generalized types/generics** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.32 **Parameter/options objects for tiny APIs** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.33 **Generic serialization/mapping layer** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.
3.34 **Home-grown framework inside the application** - Do not add this abstraction or machinery unless current callers, a concrete boundary, or measured need justifies it, protecting simplicity and maintainability.

## 4. Reimplementing existing capabilities and dependency mistakes

4.1 **Reimplementing the standard library** - Prefer the existing platform capability, and add or rebuild only after its limits are established, protecting maintenance and supply-chain costs.
4.2 **Reimplementing a native framework feature** - Prefer the existing platform capability, and add or rebuild only after its limits are established, protecting maintenance and supply-chain costs.
4.3 **Imperative validation instead of declarative constraints** - Prefer the existing platform capability, and add or rebuild only after its limits are established, protecting maintenance and supply-chain costs.
4.4 **Application-level integrity enforcement instead of database integrity** - Prefer the existing platform capability, and add or rebuild only after its limits are established, protecting maintenance and supply-chain costs.
4.5 **Custom retry/circuit-breaker/rate-limiter where infrastructure already supplies it** - Prefer the existing platform capability, and add or rebuild only after its limits are established, protecting maintenance and supply-chain costs.
4.6 **Custom enum/result/record abstractions where the language provides them** - Prefer the existing platform capability, and add or rebuild only after its limits are established, protecting maintenance and supply-chain costs.
4.7 **New dependency for a few obvious lines** - Prefer the existing platform capability, and add or rebuild only after its limits are established, protecting maintenance and supply-chain costs.
4.8 **Dependency to avoid understanding a small problem** - Prefer the existing platform capability, and add or rebuild only after its limits are established, protecting maintenance and supply-chain costs.

## 5. Structural bloat and maintainability failures

5.1 **Long method / procedural monolith** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.2 **God class** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.3 **Too many branches** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.4 **High coupling / unstable dependencies** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.5 **Scattered functionality** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.6 **“Modular mirage.”** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.7 **Excessive fragmentation** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.8 **Code duplication** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.9 **Repeated inline integration logic** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.10 **`utils.py` / `common.py` junk drawer** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.11 **Unnecessary conditional blocks** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.12 **Unnecessary `else`** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.13 **Deeply nested control flow** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.14 **Boolean-parameter branching** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.15 **Poor cohesion** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.16 **Misplaced responsibilities** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.17 **Comment duplication** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.18 **Explanatory wallpaper** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.19 **Confusing or inconsistent naming** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.
5.20 **Dense “clever” expressions** - Keep responsibilities and control flow clear when this structural risk appears, protecting maintainability and reviewability.

## 6. Functional correctness and robustness failures

6.1 **Completely wrong logic** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.2 **Partially wrong logic** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.3 **Wrong method/function input** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.4 **Missing edge/corner case** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.5 **Syntax/parse error** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.6 **Compile/type-check failure** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.7 **Undefined variable/function/member** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.8 **Uninitialized variable/state** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.9 **Incompatible type use** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.10 **Incorrect input parsing** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.11 **Incomplete generation** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.12 **Empty or constant implementation** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.13 **Placeholder implementation masquerading as completion** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.14 **Missing validation/precondition** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.15 **Missing error handling** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.16 **Broad exception swallowing** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.17 **Fake fallback/default** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.18 **Try/catch wrapper that changes nothing** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.19 **Exception translation without semantic value** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.20 **Incorrect retry semantics** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.21 **Missing resource cleanup** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.22 **Missing timeout/cancellation** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.23 **Transaction-boundary error** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.24 **Race condition / atomicity assumption** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.25 **State-machine violation** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.26 **Order-dependent behavior** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.
6.27 **Numeric/runtime failures** - Trace inputs, states, errors, and boundaries before relying on this behavior, protecting correct and robust results.

## 7. Performance and resource inefficiency

7.1 **Suboptimal time complexity** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.2 **Suboptimal memory complexity** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.3 **Redundant computation** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.4 **Unnecessary computation** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.5 **Unnecessary conversions/copies** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.6 **Inefficient loop bounds** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.7 **Missing early termination** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.8 **Repeated database/network calls inside loops** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.9 **N+1 query/API behavior** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.10 **Unbounded cache, collection, queue, or buffer** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.11 **Reads entire datasets/files when streaming would naturally fit the actual use case** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.12 **Busy waiting/polling where blocking or event-based primitives already exist** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.
7.13 **Performance “fix” with no measurement** - Measure the actual workload and resource use before accepting this cost or optimization, protecting efficient operation.

## 8. Dependency, package, build, and environment failures

8.1 **Hallucinated package/dependency** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.2 **Missing import/include** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.3 **Undeclared runtime dependency** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.4 **Hidden dependency** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.5 **Non-reproducible dependency environment** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.6 **Outdated dependency** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.7 **Deprecated dependency** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.8 **Incompatible dependency versions** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.9 **Mixed-version API assumptions** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.10 **Wildcard dependency versions** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.11 **Needless dependency bloat** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.12 **Duplicate dependency declarations** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.13 **Hardcoded build paths/URLs** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.14 **Hardcoded credentials in build/config files** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.15 **Overly complex build logic** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.16 **Platform-specific build/shell assumption presented as portable** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.17 **Needless lockfile/build-file churn** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.18 **Installation commands unrelated to the task** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.19 **Toolchain upgrade as a side effect of an unrelated feature/fix** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.
8.20 **Changing dependency managers/build systems unnecessarily** - Verify declared packages, versions, build configuration, and supported environments when this dependency risk applies, protecting reproducible builds.

## 9. Testing and verification failures

9.1 **No test for newly changed behavior** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.2 **Happy-path-only tests** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.3 **Weak assertions** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.4 **Tautological test** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.5 **Testing implementation details instead of behavior** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.6 **Over-mocking** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.7 **Brittle snapshot/golden tests** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.8 **Updating expected output merely to make a failing test green** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.9 **Disabling/skipping a failing test instead of fixing the implementation** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.10 **Loosening an assertion to make the suite pass** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.11 **Editing the evaluation harness** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.12 **Deleting tests** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.13 **Hardcoding visible test cases** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.14 **Memorizing public inputs/outputs instead of implementing the required behavior** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.15 **Feature-isolation overfitting** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.16 **Visible-test overfitting** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.17 **Running only the new/targeted test** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.18 **Failure to reproduce the bug before fixing it** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.19 **No regression test for the original failure** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.20 **Test placement/framework mismatch** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.21 **Testing mocks instead of externally observable outcomes** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.
9.22 **Excessive test infrastructure** - Use a behavior-focused test at the appropriate scope when this verification risk applies, protecting regressions from reaching users.

## 10. Security and privacy failures

10.1 **Hardcoded secret/password/token/API key** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.2 **Secret embedded in source, config, build, test, or example files** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.3 **Missing authentication** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.4 **Missing or incorrect authorization** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.5 **Object/resource access without ownership checking** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.6 **SQL injection** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.7 **Shell/command injection** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.8 **Template/log/other injection** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.9 **Cross-site scripting / unsafe HTML rendering** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.10 **Path traversal / unsafe filesystem paths** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.11 **Unsafe deserialization or dynamic evaluation** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.12 **Untrusted URL/SSRF-style network access** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.13 **Weak or inappropriate cryptography** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.14 **Predictable randomness where security requires unpredictability** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.15 **Insecure transport/TLS assumptions** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.16 **Unsafe permission/file defaults** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.17 **Secrets or personal data written to logs** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.18 **Missing security-relevant input validation** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.19 **Package hallucination creating supply-chain exposure** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.20 **Failure to notice existing vulnerable code while answering a nearby programming question** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.21 **Security check placed only in UI/client code** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.
10.22 **Fail-open behavior on authorization/configuration errors** - Enforce the relevant security control at the trusted boundary when untrusted data or protected resources are involved, protecting confidentiality, integrity, and access.

## 11. Change hygiene and integration failures

11.1 **Giant unrelated diff** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.2 **Refactor and behavior change mixed together unnecessarily** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.3 **Broad formatting churn** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.4 **Broad renaming churn** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.5 **File moves mixed into an unrelated fix** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.6 **Duplicating functionality that already exists elsewhere in the repository** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.7 **Partial refactor** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.8 **Two sources of truth** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.9 **Partial migration** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.10 **Backward-compatibility break not requested by the change** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.11 **Public API/schema break without migration or versioning** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.12 **Generated/vendor code edited instead of its source** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.13 **Build artifacts/cache/generated output accidentally committed** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.14 **Dead code left after experimentation** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.15 **Debug prints/logging left behind** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.16 **Temporary feature flags/TODOs become permanent** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.17 **Feature implemented in one duplicated code path but not the others** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.
11.18 **New behavior disagrees with an existing compatibility layer or adapter** - Keep this change focused and integrate every affected path when the risk is present, protecting reviewability and compatibility.

## 12. Documentation, comments, configuration, and operability failures

12.1 **Comments that describe code incorrectly** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.2 **Comments/docs that promise behavior not implemented** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.3 **README/example/config documentation not updated after a contract change** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.4 **Example code uses a different API from production code** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.5 **Fabricated documentation references, flags, configuration keys, or commands** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.6 **Excessive generated documentation for trivial internals** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.7 **Logging every step instead of logging operationally meaningful events** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.8 **No observability where failures are genuinely operational and otherwise invisible** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.9 **High-cardinality/unbounded logging or metrics** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.10 **Logs expose secrets or sensitive payloads** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.11 **Process-global mutable state introduced for convenience** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.12 **Startup/import-time side effects** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.13 **Destructive migration/deployment behavior without rollback strategy** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.
12.14 **Environment-specific constants disguised as universal defaults** - Keep documentation, configuration, and operational behavior aligned with the implementation when this risk applies, protecting safe use and diagnosis.

## 13. Coding-agent workflow and interaction failures

13.1 **Editing before understanding** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.2 **Search/exploration underreach** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.3 **Search/exploration overreach** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.4 **Tool-use thrashing** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.5 **Irrelevant command execution** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.6 **Repeating a failed approach** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.7 **Failing to read actual error output** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.8 **Fixing the symptom instead of tracing the failing path** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.9 **Trusting its generated plan over contradictory repository evidence** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.10 **Wrong-file persistence** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.11 **Ignoring user corrections** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.12 **Failing to ask a clarification when ambiguity materially changes the implementation** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.13 **Excessive autonomy without checkpoints** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.14 **Large speculative patch before the first verification step** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.15 **Declaring success without executing appropriate verification** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.16 **Treating “tests pass” as equivalent to “requirement satisfied.”** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.17 **Reward hacking** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.18 **Destructive workaround** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.19 **Leaving the working tree dirty with unrelated experiments or generated artifacts** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.20 **Failing to revert abandoned approaches** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.21 **Excessive token/tool expenditure for the size of the resulting useful change** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.22 **Silent uncertainty** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.23 **False verification narrative** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.
13.24 **“One more abstraction” repair loop** - Use repository evidence, small verification steps, and clarification when needed before proceeding, protecting the user’s actual goal.

## 14. The central meta-failures

14.1 **Adding before understanding** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.2 **Generalizing before duplication** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.3 **Optimizing before measuring** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.4 **Configuring before variability exists** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.5 **Distributing before scale requires it** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.6 **Wrapping before a boundary exists** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.7 **Depending before checking the platform** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.8 **Coding before grounding** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.9 **Passing tests before satisfying intent** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.10 **Generating before verifying** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.11 **Completing before integrating** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
14.12 **Expanding instead of simplifying** - Delay this action until concrete evidence establishes the need, protecting the solution from speculative complexity.
