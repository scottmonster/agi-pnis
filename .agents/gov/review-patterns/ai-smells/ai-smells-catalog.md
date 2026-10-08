# AI Coding Smells Catalog

_Entry format: <index> **<canonical name>** _(evidence: [e|a|se|e/a|e/se|a/se])_ - <concise definition>._

## 1. Intent, specification, and scope failures

1.1 **Misinterpreting the requirement** _(evidence: e)_ - Implements a plausible neighboring problem instead of what was actually requested.
1.2 **Partially satisfying the requirement** _(evidence: e)_ - Gets the central case right while silently omitting secondary requirements.
1.3 **Prompt-biased implementation** _(evidence: e)_ - Overfits wording, examples, variable names, or incidental details in the prompt instead of the underlying requirement.
1.4 **Non-prompted behavior** _(evidence: e)_ - Adds behavior, validation, transformation, fallback logic, or policy the user never requested.
1.5 **Scope creep** _(evidence: a/se)_ - Fixes unrelated bugs, performs opportunistic cleanup, or implements adjacent features in the same change.
1.6 **Solving at the wrong abstraction level** _(evidence: se)_ - Re-architects a subsystem when a local conditional or data change would solve the task.
1.7 **Ignoring explicit constraints** _(evidence: e/a)_ - Violates required APIs, languages, dependencies, compatibility bounds, file boundaries, or requested implementation style.
1.8 **Failing to resolve material ambiguity** _(evidence: a)_ - Makes a consequential assumption when repository inspection or a clarification was needed.
1.9 **Persisting after correction** _(evidence: a)_ - Continues an incorrect interpretation even after the user supplies corrective information.
1.10 **Premature success claims** _(evidence: a)_ - Reports the task as complete even though the requested behavior remains broken.

## 2. Repository and context-grounding failures

2.1 **Insufficient repository exploration** _(evidence: a)_ - Starts editing before locating the relevant implementation, callers, tests, and conventions.
2.2 **Correct change in the wrong file** _(evidence: a)_ - Understands the logic but modifies a duplicate, obsolete, generated, or otherwise incorrect location.
2.3 **Hallucinated local symbol** _(evidence: e)_ - Invents a function, class, module, field, constant, command, or variable that does not exist.
2.4 **Wrong attribute/member** _(evidence: e)_ - Uses a plausible but nonexistent property or method on a real object.
2.5 **Wrong existing symbol name** _(evidence: e)_ - Calls something close to the real project function but not the actual function.
2.6 **Public API hallucination** _(evidence: e)_ - Invents a method, parameter, option, endpoint, return type, or library feature.
2.7 **API misuse** _(evidence: e)_ - The API exists but arguments, preconditions, lifecycle, or exception semantics are wrong.
2.8 **Deprecated/similar-but-wrong API selection** _(evidence: e)_ - Uses an older or superficially similar API inappropriate to the actual environment.
2.9 **Environment conflict** _(evidence: e)_ - Assumes a different language, framework, compiler, runtime, OS, driver, or tool version.
2.10 **Project dependency conflict** _(evidence: e)_ - Relies on a dependency, import, object, module, or initialization path unavailable in the actual project.
2.11 **Configuration-schema conflict** _(evidence: e)_ - Invents config keys, flags, environment variables, or values the project does not understand.
2.12 **Data-schema conflict** _(evidence: e)_ - Assumes nonexistent columns, JSON properties, fields, types, encodings, or data formats.
2.13 **Asset/resource conflict** _(evidence: e)_ - Assumes files, templates, migrations, fixtures, static assets, certificates, or other resources that do not exist.
2.14 **Connection/infrastructure conflict** _(evidence: e)_ - Assumes services, ports, queues, databases, credentials, URLs, or deployment topology not present.
2.15 **Ignoring local conventions** _(evidence: e/a)_ - Misses repository-specific helpers, framework patterns, naming, error semantics, directory placement, or test conventions.
2.16 **Ignoring architectural invariants** _(evidence: e/a)_ - Produces locally reasonable code that conflicts with relationships elsewhere in the system.
2.17 **Incomplete call-graph propagation** _(evidence: e/a)_ - Changes a signature or contract without updating all consumers.
2.18 **Cross-module semantic inconsistency** _(evidence: e/a)_ - Different modules end up implementing incompatible interpretations of the same concept.

## 3. Speculative architecture and needless abstraction

3.1 **Config flags / env vars nobody requested** _(evidence: se)_ - `enable_x_v2`, `legacy_mode`, `use_new_parser` with only one real code path.
3.2 **Speculative configuration surface** _(evidence: se)_ - Settings object exposes numerous knobs that no current caller uses.
3.3 **Optional parameters never passed** _(evidence: se)_ - Function signatures advertise retries, modes, loggers, strategies, or toggles that all callers leave at defaults.
3.4 **Generic helper with one caller** _(evidence: se)_ - Extracts a parameterized mini-framework from code that has one concrete use.
3.5 **Premature interface/protocol** _(evidence: se)_ - Defines `FooRepository` plus exactly one `SqlFooRepository` without a genuine substitution boundary.
3.6 **Trivial factory class** _(evidence: se)_ - `UserFactory.create(x)` merely calls `User(x)`.
3.7 **Trivial builder** _(evidence: se)_ - Introduces a builder for a small object whose constructor is already readable.
3.8 **Plugin/registry scaffolding for two known cases** _(evidence: se)_ - Registry, base interface, dynamic lookup, and subclasses replace a straightforward branch.
3.9 **Strategy pattern for a tiny closed set** _(evidence: se)_ - Multiple strategy classes encode two simple algorithms unlikely to vary independently.
3.10 **Command/visitor/state pattern without corresponding complexity** _(evidence: se)_ - Pattern ceremony exceeds the problem being represented.
3.11 **DI container in a small application** _(evidence: se)_ - Framework-driven dependency wiring replaces three or four explicit constructor calls.
3.12 **Service locator / global dependency registry** _(evidence: se)_ - Introduces indirection while making dependency relationships less visible.
3.13 **Thin “swappability” wrapper** _(evidence: se)_ - Pass-through wrapper exists solely because a database, HTTP client, SDK, or library might theoretically be replaced someday.
3.14 **Excessive layering** _(evidence: e/se)_ - Controller → Service → Manager → Repository → Adapter where most layers only forward arguments.
3.15 **Repository abstraction over trivial persistence** _(evidence: se)_ - Adds repository interfaces/mappers around a framework already providing a sufficient persistence abstraction.
3.16 **Generic manager/coordinator objects** _(evidence: se)_ - Responsibilities migrate into vague `Manager`, `Handler`, `Processor`, or `Coordinator` classes instead of meaningful domain boundaries.
3.17 **Event bus for direct interactions** _(evidence: se)_ - Publisher/subscriber infrastructure replaces a normal function call with no actual decoupling requirement.
3.18 **Mediator for a tiny object graph** _(evidence: se)_ - Adds a mediation layer where dependencies are already simple and explicit.
3.19 **Speculative hooks/callbacks** _(evidence: se)_ - Extension points exist with zero external consumers.
3.20 **Abstract lifecycle framework** _(evidence: se)_ - Defines overridable startup/shutdown/pre/post hooks when one concrete lifecycle exists.
3.21 **Speculative async wrapper** _(evidence: se)_ - Converts a synchronous low-volume flow to async without a concurrency need.
3.22 **Speculative batching** _(evidence: se)_ - Implements batch APIs when calls occur individually and load does not justify aggregation.
3.23 **Speculative queue/worker architecture** _(evidence: se)_ - Adds queues and background workers to work that is cheap and synchronous.
3.24 **Speculative caching** _(evidence: se)_ - Introduces invalidation, TTLs, and cache keys without demonstrated latency or load pressure.
3.25 **Premature concurrency/parallelism** _(evidence: se)_ - Threads, tasks, pools, locks, or worker processes appear before serial execution is a bottleneck.
3.26 **Premature microservice boundary** _(evidence: se)_ - Splits a local concern into an independently deployed service without operational justification.
3.27 **CQRS/event sourcing for ordinary CRUD** _(evidence: se)_ - Introduces command models, event stores, projections, and reconciliation without corresponding domain requirements.
3.28 **Distributed-systems machinery for a local workflow** _(evidence: se)_ - Sagas, distributed locks, leases, consensus-like coordination, or idempotency infrastructure precede any distributed need.
3.29 **Premature optimization** _(evidence: se)_ - Replaces clear code with clever data structures, vectorization, memoization, pooling, or hand-tuned algorithms without evidence of a bottleneck.
3.30 **“Future-proof” indirection** _(evidence: se)_ - Adds layers whose only justification is that requirements might change.
3.31 **Over-generalized types/generics** _(evidence: se)_ - Type parameters and extensible schemas support possibilities no caller needs.
3.32 **Parameter/options objects for tiny APIs** _(evidence: se)_ - A simple two-argument operation becomes an extensible configuration protocol.
3.33 **Generic serialization/mapping layer** _(evidence: se)_ - Adds conversion abstractions over one stable representation.
3.34 **Home-grown framework inside the application** _(evidence: se)_ - Builds routers, validators, event systems, ORM-like layers, or component frameworks already provided by the platform.

## 4. Reimplementing existing capabilities and dependency mistakes

4.1 **Reimplementing the standard library** _(evidence: se)_ - Custom retry, parsing, filesystem, URL, enum, record, date, collection, or serialization code duplicates mature standard functionality.
4.2 **Reimplementing a native framework feature** _(evidence: se)_ - Hand-written middleware, routing, validation, migration, authentication, scheduling, or caching replaces a built-in facility.
4.3 **Imperative validation instead of declarative constraints** _(evidence: se)_ - Application code manually enforces what a schema, database constraint, type system, or framework rule can guarantee.
4.4 **Application-level integrity enforcement instead of database integrity** _(evidence: se)_ - Race-prone “check then insert” logic replaces unique/foreign-key/check constraints.
4.5 **Custom retry/circuit-breaker/rate-limiter where infrastructure already supplies it** _(evidence: se)_ - Recreates resilience controls that the platform, gateway, or service mesh can apply more consistently.
4.6 **Custom enum/result/record abstractions where the language provides them** _(evidence: se)_ - Replaces a built-in language construct with a local equivalent that adds maintenance without capability.
4.7 **New dependency for a few obvious lines** _(evidence: se)_ - Adds package, update surface, and supply-chain risk for trivial functionality.
4.8 **Dependency to avoid understanding a small problem** _(evidence: se)_ - Imports a heavyweight package for a simple transformation or algorithm.

## 5. Structural bloat and maintainability failures

5.1 **Long method / procedural monolith** _(evidence: e)_ - Large amounts of reasoning are compressed into one function.
5.2 **God class** _(evidence: e)_ - One class accumulates routing, business logic, persistence, validation, formatting, and coordination.
5.3 **Too many branches** _(evidence: e)_ - Large switch/if trees accumulate instead of clearer responsibility boundaries.
5.4 **High coupling / unstable dependencies** _(evidence: e)_ - Modules know too much about one another's internals.
5.5 **Scattered functionality** _(evidence: e)_ - A single concern is fragmented across unrelated locations.
5.6 **“Modular mirage.”** _(evidence: e)_ - Many files/classes give the appearance of modularity while remaining tightly coupled semantically.
5.7 **Excessive fragmentation** _(evidence: e)_ - Straightforward logic is split across tiny classes/functions/files that must all be followed to understand one operation.
5.8 **Code duplication** _(evidence: e)_ - Similar implementations appear repeatedly instead of maintaining one authoritative representation.
5.9 **Repeated inline integration logic** _(evidence: e)_ - External/API interactions are rewritten multiple times once genuine duplication exists.
5.10 **`utils.py` / `common.py` junk drawer** _(evidence: se)_ - Unrelated operations accumulate in catch-all modules.
5.11 **Unnecessary conditional blocks** _(evidence: e)_ - Conditions exist where a direct return/expression would suffice.
5.12 **Unnecessary `else`** _(evidence: e)_ - Adds indentation after a branch that already returns, throws, or breaks.
5.13 **Deeply nested control flow** _(evidence: se)_ - Layers of guards and conditionals make the actual path difficult to see.
5.14 **Boolean-parameter branching** _(evidence: se)_ - One function contains multiple behaviors selected by growing sets of flags.
5.15 **Poor cohesion** _(evidence: se)_ - A module or class contains responsibilities that change for unrelated reasons.
5.16 **Misplaced responsibilities** _(evidence: se)_ - Behavior lives far from the data/domain concept it governs.
5.17 **Comment duplication** _(evidence: e)_ - Generated comments repeat themselves across closely related blocks.
5.18 **Explanatory wallpaper** _(evidence: se)_ - Comments restate obvious syntax instead of documenting invariants, constraints, or rationale.
5.19 **Confusing or inconsistent naming** _(evidence: e)_ - Names shadow built-ins, drift between concepts, or fail to follow local conventions.
5.20 **Dense “clever” expressions** _(evidence: e)_ - Nested comprehensions/chains/lambdas trade readability for compactness.

## 6. Functional correctness and robustness failures

6.1 **Completely wrong logic** _(evidence: e)_ - The implementation computes or changes the wrong result for the intended task rather than merely mishandling an edge case.
6.2 **Partially wrong logic** _(evidence: e)_ - Works for many inputs but violates part of the specification.
6.3 **Wrong method/function input** _(evidence: e)_ - Incorrect parameter value, type, order, unit, or semantic meaning.
6.4 **Missing edge/corner case** _(evidence: e)_ - Empty values, boundaries, duplicate values, negative cases, zero, null, overflow, or unusual ordering break the implementation.
6.5 **Syntax/parse error** _(evidence: e)_ - Source text is not valid in the target language and cannot be parsed.
6.6 **Compile/type-check failure** _(evidence: e)_ - The source parses but violates compile-time or static type rules.
6.7 **Undefined variable/function/member** _(evidence: e)_ - References a name or member that has not been declared, imported, or made available in scope.
6.8 **Uninitialized variable/state** _(evidence: e)_ - Reads or depends on a value before it has been assigned a valid initial state.
6.9 **Incompatible type use** _(evidence: e)_ - Passes, assigns, compares, or operates on a value where its type or representation is not accepted.
6.10 **Incorrect input parsing** _(evidence: e)_ - Assumes the wrong delimiter, encoding, shape, order, or representation.
6.11 **Incomplete generation** _(evidence: e)_ - Function/class/file ends before the requested behavior exists.
6.12 **Empty or constant implementation** _(evidence: e)_ - Stub technically exists but performs no meaningful requested computation.
6.13 **Placeholder implementation masquerading as completion** _(evidence: se)_ - `TODO`, `pass`, dummy result, mock data, or hardcoded “temporary” response remains in production path.
6.14 **Missing validation/precondition** _(evidence: e)_ - Calls APIs or operates on values without checking conditions necessary for correctness.
6.15 **Missing error handling** _(evidence: e)_ - Expected operational failures escape incorrectly.
6.16 **Broad exception swallowing** _(evidence: se)_ - `except Exception: pass`, generic catch-and-continue, or returning fake success.
6.17 **Fake fallback/default** _(evidence: se)_ - Converts a real error into `None`, `0`, `[]`, or another plausible value that hides failure.
6.18 **Try/catch wrapper that changes nothing** _(evidence: se)_ - Catches an exception solely to rethrow it unchanged or destroy traceback context.
6.19 **Exception translation without semantic value** _(evidence: se)_ - Introduces layers of custom error types that convey no additional information.
6.20 **Incorrect retry semantics** _(evidence: se)_ - Retries non-idempotent operations or retries errors that should fail immediately.
6.21 **Missing resource cleanup** _(evidence: se)_ - Files, sockets, transactions, processes, locks, streams, or temporary resources leak.
6.22 **Missing timeout/cancellation** _(evidence: se)_ - Network/subprocess/async work can wait indefinitely.
6.23 **Transaction-boundary error** _(evidence: se)_ - Multi-step state changes can become partially committed.
6.24 **Race condition / atomicity assumption** _(evidence: se)_ - Assumes separate reads and writes occur as one indivisible operation when concurrent execution can interleave them.
6.25 **State-machine violation** _(evidence: se)_ - Allows impossible transitions or bypasses required lifecycle stages.
6.26 **Order-dependent behavior** _(evidence: se)_ - Correctness accidentally depends on iteration, import, registration, startup, or test order.
6.27 **Numeric/runtime failures** _(evidence: e)_ - Overflow, out-of-bounds access, division by zero, invalid values, recursion failure, or analogous runtime faults.

## 7. Performance and resource inefficiency

7.1 **Suboptimal time complexity** _(evidence: e)_ - Runtime grows faster than necessary for input size, often because of avoidable repeated scans or nested work.
7.2 **Suboptimal memory complexity** _(evidence: e)_ - Retains more data than necessary, causing memory use to grow unnecessarily with the input.
7.3 **Redundant computation** _(evidence: e)_ - Repeats an expensive operation instead of retaining the result locally.
7.4 **Unnecessary computation** _(evidence: e)_ - Performs work irrelevant to the output.
7.5 **Unnecessary conversions/copies** _(evidence: e)_ - Repeatedly transforms or duplicates data when the original representation or a single conversion would suffice.
7.6 **Inefficient loop bounds** _(evidence: e)_ - Iterates farther or more often than the required result demands.
7.7 **Missing early termination** _(evidence: e)_ - Continues processing after a decisive result, error, or match is already known.
7.8 **Repeated database/network calls inside loops** _(evidence: se)_ - Performs one remote operation per iteration instead of batching, prefetching, or reusing a result where appropriate.
7.9 **N+1 query/API behavior** _(evidence: se)_ - Fetches a collection once, then makes an additional query or request for each item in that collection.
7.10 **Unbounded cache, collection, queue, or buffer** _(evidence: se)_ - Lets retained data grow without an eviction, size, age, or back-pressure limit.
7.11 **Reads entire datasets/files when streaming would naturally fit the actual use case** _(evidence: se)_ - Materializes all input even though it can be processed incrementally, increasing latency and peak memory.
7.12 **Busy waiting/polling where blocking or event-based primitives already exist** _(evidence: se)_ - Repeatedly checks for a condition instead of waiting for notification or a bounded blocking operation.
7.13 **Performance “fix” with no measurement** _(evidence: se)_ - Complexity increases without a benchmark demonstrating improvement.

## 8. Dependency, package, build, and environment failures

8.1 **Hallucinated package/dependency** _(evidence: e)_ - Recommends or imports a package that does not exist.
8.2 **Missing import/include** _(evidence: e)_ - Uses an external symbol without bringing its defining module, header, or package into the build.
8.3 **Undeclared runtime dependency** _(evidence: e)_ - Requires a library or service at execution time without declaring it in the project’s dependency metadata.
8.4 **Hidden dependency** _(evidence: e)_ - Code works only because something happens to be globally installed or supplied transitively.
8.5 **Non-reproducible dependency environment** _(evidence: e)_ - Builds or runs only with an undocumented, machine-specific set of package versions or tools.
8.6 **Outdated dependency** _(evidence: e)_ - Pins or selects an old version that lacks required fixes, support, or compatibility.
8.7 **Deprecated dependency** _(evidence: e)_ - Uses a package or feature its maintainer has marked for replacement or end of support.
8.8 **Incompatible dependency versions** _(evidence: e)_ - Selects versions whose requirements or APIs cannot work together.
8.9 **Mixed-version API assumptions** _(evidence: e)_ - Writes code as though features from different releases coexist in one installed version.
8.10 **Wildcard dependency versions** _(evidence: e)_ - `*`, `+`, `latest`, or similarly unstable selection where reproducibility matters.
8.11 **Needless dependency bloat** _(evidence: se)_ - Adds packages whose small benefit does not justify their maintenance, update, and supply-chain cost.
8.12 **Duplicate dependency declarations** _(evidence: e)_ - Declares the same package more than once, potentially with conflicting versions or scopes.
8.13 **Hardcoded build paths/URLs** _(evidence: e)_ - Embeds machine-, network-, or environment-specific locations that fail outside the author’s setup.
8.14 **Hardcoded credentials in build/config files** _(evidence: e)_ - Stores a password, token, or other secret in tracked build or configuration material.
8.15 **Overly complex build logic** _(evidence: e)_ - Uses intricate scripts, conditionals, or custom steps where a simpler declarative build would be clearer and more reliable.
8.16 **Platform-specific build/shell assumption presented as portable** _(evidence: se)_ - Relies on an OS, shell, filesystem, or tool behavior that other supported environments do not share.
8.17 **Needless lockfile/build-file churn** _(evidence: se)_ - Alters unrelated resolved versions or build metadata, obscuring the intended change and increasing merge risk.
8.18 **Installation commands unrelated to the task** _(evidence: se)_ - Installs packages or tools that the requested change neither needs nor uses.
8.19 **Toolchain upgrade as a side effect of an unrelated feature/fix** _(evidence: se)_ - Changes compiler, runtime, or build-tool versions without a requirement that justifies the compatibility risk.
8.20 **Changing dependency managers/build systems unnecessarily** _(evidence: se)_ - Replaces package or build tooling when the existing system can support the requested work.

## 9. Testing and verification failures

9.1 **No test for newly changed behavior** _(evidence: a/se)_ - Changes externally observable behavior without a test that would detect its regression.
9.2 **Happy-path-only tests** _(evidence: a)_ - Exercises only expected inputs and outcomes, omitting invalid, boundary, error, and interaction cases.
9.3 **Weak assertions** _(evidence: a)_ - Test executes code but does not meaningfully verify the result.
9.4 **Tautological test** _(evidence: se)_ - Reimplements the production algorithm and compares it with itself.
9.5 **Testing implementation details instead of behavior** _(evidence: se)_ - Asserts private calls, structure, or incidental sequencing rather than the result a consumer can observe.
9.6 **Over-mocking** _(evidence: se)_ - Mocks away the integration or behavior the test is supposed to establish.
9.7 **Brittle snapshot/golden tests** _(evidence: se)_ - Large snapshots are updated mechanically rather than inspected semantically.
9.8 **Updating expected output merely to make a failing test green** _(evidence: a)_ - Changes the oracle to match a defective implementation without evidence that the requirement changed.
9.9 **Disabling/skipping a failing test instead of fixing the implementation** _(evidence: a)_ - Removes the signal of a regression while leaving the defective behavior in place.
9.10 **Loosening an assertion to make the suite pass** _(evidence: a)_ - Reduces what a test verifies solely to accommodate an incorrect result.
9.11 **Editing the evaluation harness** _(evidence: a)_ - Alters test runner, fixtures, setup, or scoring mechanics to avoid a failure rather than satisfy the system contract.
9.12 **Deleting tests** _(evidence: a)_ - Removes coverage that exposes a defect or contract instead of resolving the underlying incompatibility.
9.13 **Hardcoding visible test cases** _(evidence: a)_ - Special-cases known test inputs rather than implementing the general rule they represent.
9.14 **Memorizing public inputs/outputs instead of implementing the required behavior** _(evidence: a)_ - Returns known benchmark answers without deriving them from the intended algorithm or contract.
9.15 **Feature-isolation overfitting** _(evidence: a)_ - Individual features work in tests but fail when composed together.
9.16 **Visible-test overfitting** _(evidence: a)_ - Passes exposed validation while failing held-out behavior.
9.17 **Running only the new/targeted test** _(evidence: a)_ - Never checks the existing regression suite.
9.18 **Failure to reproduce the bug before fixing it** _(evidence: se)_ - Changes code without a reliable demonstration of the reported failure, leaving cause and effectiveness uncertain.
9.19 **No regression test for the original failure** _(evidence: a/se)_ - Fixes a defect without adding or preserving an automated check that fails on the old behavior.
9.20 **Test placement/framework mismatch** _(evidence: a)_ - Adds tests in the wrong directory, runner, fixture style, or convention.
9.21 **Testing mocks instead of externally observable outcomes** _(evidence: se)_ - Verifies that test doubles received expected calls while failing to establish the user-visible behavior.
9.22 **Excessive test infrastructure** _(evidence: se)_ - Builds factories, DSLs, and helper frameworks for a handful of straightforward tests.

## 10. Security and privacy failures

10.1 **Hardcoded secret/password/token/API key** _(evidence: e)_ - Places a credential directly in code where it can be disclosed through source access, builds, logs, or artifacts.
10.2 **Secret embedded in source, config, build, test, or example files** _(evidence: e)_ - Includes sensitive credentials in material likely to be committed, copied, or deployed beyond its intended boundary.
10.3 **Missing authentication** _(evidence: e)_ - Permits use of a protected function or resource without establishing the caller’s identity.
10.4 **Missing or incorrect authorization** _(evidence: e)_ - Authenticates a caller but fails to enforce whether that caller may perform the requested action.
10.5 **Object/resource access without ownership checking** _(evidence: e)_ - Uses a caller-controlled identifier to access an object without confirming the caller is entitled to that specific object.
10.6 **SQL injection** _(evidence: e)_ - Concatenates untrusted input into a database query so it can alter the query’s meaning or data access.
10.7 **Shell/command injection** _(evidence: e)_ - Incorporates untrusted data into an operating-system command so an attacker can execute unintended arguments or commands.
10.8 **Template/log/other injection** _(evidence: e)_ - Lets untrusted data alter a template, log record, interpreter input, or downstream format instead of treating it as data.
10.9 **Cross-site scripting / unsafe HTML rendering** _(evidence: e)_ - Renders untrusted content as active HTML or script in a user’s browser.
10.10 **Path traversal / unsafe filesystem paths** _(evidence: e)_ - Accepts a path that can escape an intended directory or reach files outside the allowed location.
10.11 **Unsafe deserialization or dynamic evaluation** _(evidence: e)_ - Reconstructs objects or evaluates code-like input from untrusted data, enabling unintended behavior or code execution.
10.12 **Untrusted URL/SSRF-style network access** _(evidence: e)_ - Lets untrusted input choose server-side request targets, potentially reaching internal or protected services.
10.13 **Weak or inappropriate cryptography** _(evidence: e)_ - Uses obsolete, misconfigured, homemade, or unsuitable algorithms, modes, keys, or key management for the protection required.
10.14 **Predictable randomness where security requires unpredictability** _(evidence: e)_ - Uses a guessable random source for secrets, tokens, nonces, or other security-sensitive values.
10.15 **Insecure transport/TLS assumptions** _(evidence: e)_ - Sends sensitive traffic without proper encryption or accepts invalid certificates, protocols, or hostname checks.
10.16 **Unsafe permission/file defaults** _(evidence: e)_ - Creates files, directories, or resources with access rights broader than their sensitivity permits.
10.17 **Secrets or personal data written to logs** _(evidence: e)_ - Records credentials, tokens, identifiers, or sensitive payloads in logs accessible beyond the original request path.
10.18 **Missing security-relevant input validation** _(evidence: e)_ - Fails to constrain untrusted values before they reach a security-sensitive operation or trust boundary.
10.19 **Package hallucination creating supply-chain exposure** _(evidence: e)_ - Names a nonexistent package that an attacker can publish and have downstream users install.
10.20 **Failure to notice existing vulnerable code while answering a nearby programming question** _(evidence: e)_ - Makes a local change while overlooking an evident adjacent vulnerability that the change touches or preserves.
10.21 **Security check placed only in UI/client code** _(evidence: se)_ - Relies on a bypassable client-side control instead of enforcing the rule at the trusted server-side boundary.
10.22 **Fail-open behavior on authorization/configuration errors** _(evidence: se)_ - Grants access or proceeds with an unsafe default when a required security decision cannot be made.

## 11. Change hygiene and integration failures

11.1 **Giant unrelated diff** _(evidence: a/se)_ - Changes far more files or behavior than the request requires, making correctness and review harder.
11.2 **Refactor and behavior change mixed together unnecessarily** _(evidence: se)_ - Combines structural cleanup with a semantic change so reviewers cannot readily isolate the behavior under review.
11.3 **Broad formatting churn** _(evidence: se)_ - Rewrites whitespace, line wrapping, or style across unrelated code, hiding material changes in noise.
11.4 **Broad renaming churn** _(evidence: se)_ - Renames unrelated identifiers or concepts in a focused change, increasing review and merge burden.
11.5 **File moves mixed into an unrelated fix** _(evidence: se)_ - Relocates files while changing behavior, complicating history, review, and conflict resolution without need.
11.6 **Duplicating functionality that already exists elsewhere in the repository** _(evidence: e/se)_ - Adds a second implementation rather than locating, reusing, or extending the existing authoritative behavior.
11.7 **Partial refactor** _(evidence: se)_ - New abstraction is introduced but the old path remains active.
11.8 **Two sources of truth** _(evidence: se)_ - Old and new configuration, mapping, or state representations coexist.
11.9 **Partial migration** _(evidence: a/se)_ - Some callers/data paths use the new contract and others silently remain old.
11.10 **Backward-compatibility break not requested by the change** _(evidence: se)_ - Changes existing callers’ behavior, data, or configuration despite no requirement to do so.
11.11 **Public API/schema break without migration or versioning** _(evidence: se)_ - Removes or changes a published contract without a compatible transition path for consumers or stored data.
11.12 **Generated/vendor code edited instead of its source** _(evidence: se)_ - Modifies derived or third-party files that will be overwritten or cannot be maintained through the owning source.
11.13 **Build artifacts/cache/generated output accidentally committed** _(evidence: se)_ - Adds machine-derived files that do not belong in version control and create noisy, stale, or platform-specific changes.
11.14 **Dead code left after experimentation** _(evidence: e/se)_ - Leaves unreachable, unused, superseded, or permanently disabled code after the final approach is known.
11.15 **Debug prints/logging left behind** _(evidence: se)_ - Leaves temporary diagnostic output that adds noise, leaks data, or changes operational behavior.
11.16 **Temporary feature flags/TODOs become permanent** _(evidence: se)_ - Leaves provisional controls or deferred work without ownership, expiry, or a plan to resolve them.
11.17 **Feature implemented in one duplicated code path but not the others** _(evidence: se)_ - Updates only one equivalent implementation, causing behavior to vary by entry point or environment.
11.18 **New behavior disagrees with an existing compatibility layer or adapter** _(evidence: se)_ - Introduces a contract that conflicts with the translation or legacy behavior at a system boundary.

## 12. Documentation, comments, configuration, and operability failures

12.1 **Comments that describe code incorrectly** _(evidence: e/se)_ - Documentation adjacent to code states behavior, constraints, or ownership that no longer matches the implementation.
12.2 **Comments/docs that promise behavior not implemented** _(evidence: e/se)_ - Public or internal documentation advertises an API, guarantee, or workflow the system does not provide.
12.3 **README/example/config documentation not updated after a contract change** _(evidence: se)_ - Leaves users with stale instructions, examples, or configuration details after behavior changes.
12.4 **Example code uses a different API from production code** _(evidence: se)_ - Demonstrates calls, names, or semantics that diverge from the currently supported interface.
12.5 **Fabricated documentation references, flags, configuration keys, or commands** _(evidence: se)_ - Documents plausible but nonexistent resources that send users toward failed setup or operation.
12.6 **Excessive generated documentation for trivial internals** _(evidence: se)_ - Adds verbose reference material for obvious private details, obscuring the small amount of guidance readers need.
12.7 **Logging every step instead of logging operationally meaningful events** _(evidence: se)_ - Emits routine internal activity rather than decision, error, audit, or lifecycle events useful for operating the system.
12.8 **No observability where failures are genuinely operational and otherwise invisible** _(evidence: se)_ - Omits the logs, metrics, traces, or health signals needed to detect and diagnose production failures.
12.9 **High-cardinality/unbounded logging or metrics** _(evidence: se)_ - Uses unbounded values such as user IDs, URLs, or request bodies as metric dimensions or log fields, increasing cost and reducing query usefulness.
12.10 **Logs expose secrets or sensitive payloads** _(evidence: se)_ - Records credentials or personal/confidential data in operational telemetry without a justified protected path.
12.11 **Process-global mutable state introduced for convenience** _(evidence: se)_ - Stores changing application state globally, making lifecycle, isolation, concurrency, and tests harder to reason about.
12.12 **Startup/import-time side effects** _(evidence: se)_ - Performs I/O, mutation, registration, network access, or other work merely by loading a module or starting a process.
12.13 **Destructive migration/deployment behavior without rollback strategy** _(evidence: se)_ - Irreversibly changes data or infrastructure without a tested recovery path if the deployment fails.
12.14 **Environment-specific constants disguised as universal defaults** _(evidence: se)_ - Bakes one environment’s hostnames, paths, limits, or credentials assumptions into defaults used elsewhere.

## 13. Coding-agent workflow and interaction failures

13.1 **Editing before understanding** _(evidence: a)_ - Begins patches before gathering enough repository evidence.
13.2 **Search/exploration underreach** _(evidence: a)_ - Fails to inspect the files or definitions that contain the decisive information.
13.3 **Search/exploration overreach** _(evidence: a)_ - Burns large amounts of time/tokens browsing irrelevant portions of the repository.
13.4 **Tool-use thrashing** _(evidence: a)_ - Repeats searches, builds, installs, or shell commands without gaining new information.
13.5 **Irrelevant command execution** _(evidence: a)_ - Runs installs or shell operations when the task calls for a simple code/document edit.
13.6 **Repeating a failed approach** _(evidence: a)_ - Error evidence changes but the strategy does not.
13.7 **Failing to read actual error output** _(evidence: a)_ - Ignores the diagnostic details that identify the failed command, location, cause, or next investigation step.
13.8 **Fixing the symptom instead of tracing the failing path** _(evidence: a)_ - Suppresses a visible failure without locating and correcting the condition that produces it.
13.9 **Trusting its generated plan over contradictory repository evidence** _(evidence: a)_ - Continues following an initial hypothesis after source, configuration, tests, or errors show it is false.
13.10 **Wrong-file persistence** _(evidence: a)_ - Keeps modifying an incorrect location rather than re-localizing the problem.
13.11 **Ignoring user corrections** _(evidence: a)_ - Fails to incorporate direct feedback that changes the task’s intended behavior, scope, or constraints.
13.12 **Failing to ask a clarification when ambiguity materially changes the implementation** _(evidence: a)_ - Guesses among consequential interpretations when repository evidence cannot safely resolve them.
13.13 **Excessive autonomy without checkpoints** _(evidence: a)_ - Makes a long sequence of consequential changes without verifying direction, evidence, or user intent along the way.
13.14 **Large speculative patch before the first verification step** _(evidence: a)_ - Accumulates many unvalidated changes based on assumptions rather than testing the smallest plausible approach.
13.15 **Declaring success without executing appropriate verification** _(evidence: a)_ - Reports completion without tests, inspection, or other evidence proportionate to the claimed behavior.
13.16 **Treating “tests pass” as equivalent to “requirement satisfied.”** _(evidence: a)_ - Equates a limited test result with full compliance despite possible missing requirements, coverage, or integration checks.
13.17 **Reward hacking** _(evidence: a)_ - Optimizes the measurable proxy rather than the user's actual goal.
13.18 **Destructive workaround** _(evidence: a)_ - Deletes, disables, bypasses, or hardcodes around the mechanism exposing the failure.
13.19 **Leaving the working tree dirty with unrelated experiments or generated artifacts** _(evidence: a)_ - Retains exploratory edits or generated files that are not part of the delivered solution.
13.20 **Failing to revert abandoned approaches** _(evidence: a)_ - Leaves superseded patches, flags, helpers, or configuration after changing course.
13.21 **Excessive token/tool expenditure for the size of the resulting useful change** _(evidence: a)_ - Uses disproportionate exploration, command execution, or generated output for a simple task without producing corresponding evidence or value.
13.22 **Silent uncertainty** _(evidence: a)_ - Makes consequential assumptions without signaling that evidence is missing.
13.23 **False verification narrative** _(evidence: a)_ - Says something was tested, fixed, or confirmed when the observable result does not establish it.
13.24 **“One more abstraction” repair loop** _(evidence: a)_ - Responds to failure by layering another wrapper/helper/configuration mechanism over the original bad design instead of simplifying it.

## 14. The central meta-failures

14.1 **Adding before understanding** _(evidence: a)_ - New code, abstractions, dependencies, and configuration appear before the existing solution space is inspected.
14.2 **Generalizing before duplication** _(evidence: a)_ - An abstraction appears before two genuine, stable examples demonstrate what should be abstracted.
14.3 **Optimizing before measuring** _(evidence: a)_ - Performance machinery precedes evidence of a performance problem.
14.4 **Configuring before variability exists** _(evidence: a)_ - Flags/options exist before there are real alternative behaviors.
14.5 **Distributing before scale requires it** _(evidence: a)_ - Async, queues, workers, microservices, caches, and coordination precede actual load or operational constraints.
14.6 **Wrapping before a boundary exists** _(evidence: a)_ - Interfaces/adapters are introduced around components with no current substitution, isolation, or ownership requirement.
14.7 **Depending before checking the platform** _(evidence: a)_ - New code/package is introduced before checking whether stdlib, framework, database, type system, or infrastructure already provides the feature.
14.8 **Coding before grounding** _(evidence: a)_ - The model starts implementation before understanding repository-specific facts.
14.9 **Passing tests before satisfying intent** _(evidence: a)_ - The model optimizes the observable test surface instead of the full specification.
14.10 **Generating before verifying** _(evidence: a)_ - Plausibility is mistaken for correctness.
14.11 **Completing before integrating** _(evidence: a)_ - A local implementation is declared finished without checking callers, tests, schemas, docs, dependencies, and compatibility.
14.12 **Expanding instead of simplifying** _(evidence: a)_ - When uncertainty appears, the model adds options, abstractions, fallbacks, or layers instead of reducing the solution to what is actually known to be necessary.
