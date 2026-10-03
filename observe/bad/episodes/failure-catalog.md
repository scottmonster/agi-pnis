# Failure Catalog

**Status: Draft; non-authoritative pending adoption.**

## 1. Purpose and boundary

This document is the classification reference for failures in the Material Episode Record system.

It contains only the categorized detailed failure patterns and the evidence-label legend needed to interpret them. It does not define FR/FUR creation, reporting, investigation, prevention, corrective action, validation, updates, or storage; those rules are in `failure-record.md`.

A catalog classification describes an observed failure pattern or candidate prevention opportunity. It does not, by itself, establish a material FR, fault, root cause, responsibility, or a required corrective action.

## 2. Detailed coding-agent patterns

The following patterns retain the evidence-label model from the prior detailed catalogue. Pattern text provides a concise description where the reference catalogue supplied one; it does not imply a universal frequency claim.

### 2.1 Intent, specification, and scope failures

1. **[E] Misinterpreting the requirement:** Implements a plausible neighboring problem instead of what was actually requested.
2. **[E] Partially satisfying the requirement:** Gets the central case right while silently omitting secondary requirements.
3. **[E] Prompt-biased implementation:** Overfits wording, examples, variable names, or incidental details in the prompt instead of the underlying requirement.
4. **[E] Non-prompted behavior:** Adds behavior, validation, transformation, fallback logic, or policy the user never requested.
5. **[A/SE] Scope creep:** Fixes unrelated bugs, performs opportunistic cleanup, or implements adjacent features in the same change.
6. **[SE] Wrong abstraction level:** Re-architects a subsystem when a local conditional or data change would solve the task.
7. **[E/A] Ignoring explicit constraints:** Violates required APIs, languages, dependencies, compatibility bounds, file boundaries, or requested implementation style.
8. **[A] Failing to resolve material ambiguity:** Makes a consequential assumption when repository inspection or a clarification was needed.
9. **[A] Persisting after correction:** Continues an incorrect interpretation even after the user supplies corrective information.
10. **[A] Premature success claim:** Reports the task as complete even though the requested behavior remains broken.

### 2.2 Repository and context-grounding failures

11. **[A] Insufficient repository exploration.** Starts editing before locating the relevant implementation, callers, tests, and conventions.
12. **[A] Correct change in the wrong file.** Understands the logic but modifies a duplicate, obsolete, generated, or otherwise incorrect location.
13. **[E] Hallucinated local symbol.** Invents a function, class, module, field, constant, command, or variable that does not exist.
14. **[E] Wrong attribute or member.** Uses a plausible but nonexistent property or method on a real object.
15. **[E] Wrong existing symbol name.** Calls something close to the real project function but not the actual function.
16. **[E] Public API hallucination.** Invents a method, parameter, option, endpoint, return type, or library feature.
17. **[E] API misuse.** The API exists but arguments, preconditions, lifecycle, or exception semantics are wrong.
18. **[E] Deprecated or similar-but-wrong API selection.** Uses an older or superficially similar API inappropriate to the actual environment.
19. **[E] Environment conflict.** Assumes a different language, framework, compiler, runtime, OS, driver, or tool version.
20. **[E] Project dependency conflict.** Relies on a dependency, import, object, module, or initialization path unavailable in the actual project.
21. **[E] Configuration-schema conflict.** Invents config keys, flags, environment variables, or values the project does not understand.
22. **[E] Data-schema conflict.** Assumes nonexistent columns, JSON properties, fields, types, encodings, or data formats.
23. **[E] Asset or resource conflict.** Assumes files, templates, migrations, fixtures, static assets, certificates, or other resources that do not exist.
24. **[E] Connection or infrastructure conflict.** Assumes services, ports, queues, databases, credentials, URLs, or deployment topology not present.
25. **[E/A] Ignoring local conventions.** Misses repository-specific helpers, framework patterns, naming, error semantics, directory placement, or test conventions.
26. **[E/A] Ignoring architectural invariants.** Produces locally reasonable code that conflicts with relationships elsewhere in the system.
27. **[E/A] Incomplete call-graph propagation.** Changes a signature or contract without updating all consumers.
28. **[E/A] Cross-module semantic inconsistency.** Different modules end up implementing incompatible interpretations of the same concept.

### 2.3 Speculative architecture and needless abstraction

29. **[SE] Unrequested configuration flags or environment variables.** `enable_x_v2`, `legacy_mode`, `use_new_parser` with only one real code path.
30. **[SE] Speculative configuration surface.** Settings object exposes numerous knobs that no current caller uses.
31. **[SE] Optional parameters never passed.** Function signatures advertise retries, modes, loggers, strategies, or toggles that all callers leave at defaults.
32. **[SE] Generic helper with one caller.** Extracts a parameterized mini-framework from code that has one concrete use.
33. **[SE] Premature interface or protocol.** Defines `FooRepository` plus exactly one `SqlFooRepository` without a genuine substitution boundary.
34. **[SE] Trivial factory class.** `UserFactory.create(x)` merely calls `User(x)`.
35. **[SE] Trivial builder.** Introduces a builder for a small object whose constructor is already readable.
36. **[SE] Plugin or registry scaffolding for two known cases.** Registry, base interface, dynamic lookup, and subclasses replace a straightforward branch.
37. **[SE] Strategy pattern for a tiny closed set.** Multiple strategy classes encode two simple algorithms unlikely to vary independently.
38. **[SE] Command, visitor, or state pattern without corresponding complexity.** Pattern ceremony exceeds the problem being represented.
39. **[SE] DI container in a small application.** Framework-driven dependency wiring replaces three or four explicit constructor calls.
40. **[SE] Service locator or global dependency registry.** Introduces indirection while making dependency relationships less visible.
41. **[SE] Thin swappability wrapper.** Pass-through wrapper exists solely because a database, HTTP client, SDK, or library might theoretically be replaced someday.
42. **[E/SE] Excessive forwarding layers.** Controller → Service → Manager → Repository → Adapter where most layers only forward arguments.
43. **[SE] Repository abstraction over trivial persistence.** Adds repository interfaces/mappers around a framework already providing a sufficient persistence abstraction.
44. **[SE] Generic manager or coordinator objects.** Responsibilities migrate into vague `Manager`, `Handler`, `Processor`, or `Coordinator` classes instead of meaningful domain boundaries.
45. **[SE] Event bus for direct interactions.** Publisher/subscriber infrastructure replaces a normal function call with no actual decoupling requirement.
46. **[SE] Mediator for a tiny object graph.** Adds a mediation layer where dependencies are already simple and explicit.
47. **[SE] Speculative hooks or callbacks.** Extension points exist with zero external consumers.
48. **[SE] Abstract lifecycle framework.** Defines overridable startup/shutdown/pre/post hooks when one concrete lifecycle exists.
49. **[SE] Speculative async wrapper.** Converts a synchronous low-volume flow to async without a concurrency need.
50. **[SE] Speculative batching.** Implements batch APIs when calls occur individually and load does not justify aggregation.
51. **[SE] Speculative queue or worker architecture.** Adds queues and background workers to work that is cheap and synchronous.
52. **[SE] Speculative caching.** Introduces invalidation, TTLs, and cache keys without demonstrated latency or load pressure.
53. **[SE] Premature concurrency or parallelism.** Threads, tasks, pools, locks, or worker processes appear before serial execution is a bottleneck.
54. **[SE] Premature microservice boundary.** Splits a local concern into an independently deployed service without operational justification.
55. **[SE] CQRS or event sourcing for ordinary CRUD.** Introduces command models, event stores, projections, and reconciliation without corresponding domain requirements.
56. **[SE] Distributed-systems machinery for a local workflow.** Sagas, distributed locks, leases, consensus-like coordination, or idempotency infrastructure precede any distributed need.
57. **[SE] Premature optimization.** Replaces clear code with clever data structures, vectorization, memoization, pooling, or hand-tuned algorithms without evidence of a bottleneck.
58. **[SE] Future-proof indirection.** Adds layers whose only justification is that requirements might change.
59. **[SE] Over-generalized types or generics.** Type parameters and extensible schemas support possibilities no caller needs.
60. **[SE] Parameter or options objects for tiny APIs.** A simple two-argument operation becomes an extensible configuration protocol.
61. **[SE] Generic serialization or mapping layer.** Adds conversion abstractions over one stable representation.
62. **[SE] Home-grown application framework.** Builds routers, validators, event systems, ORM-like layers, or component frameworks already provided by the platform.

### 2.4 Reimplementation and dependency mistakes

63. **[SE] Reimplementing the standard library.** Custom retry, parsing, filesystem, URL, enum, record, date, collection, or serialization code duplicates mature standard functionality.
64. **[SE] Reimplementing a native framework feature.** Hand-written middleware, routing, validation, migration, authentication, scheduling, or caching replaces a built-in facility.
65. **[SE] Imperative validation instead of declarative constraints.** Application code manually enforces what a schema, database constraint, type system, or framework rule can guarantee.
66. **[SE] Application-level integrity enforcement instead of database integrity.** Race-prone “check then insert” logic replaces unique/foreign-key/check constraints.
67. **[SE] Custom retry, circuit-breaker, or rate limiter where infrastructure supplies it.** Recreates resilience controls that the platform, gateway, or service mesh can apply more consistently.
68. **[SE] Custom enum, result, or record abstraction where the language supplies it.** Replaces a built-in language construct with a local equivalent that adds maintenance without capability.
69. **[SE] New dependency for a few obvious lines.** Adds package, update surface, and supply-chain risk for trivial functionality.
70. **[SE] Dependency to avoid understanding a small problem.** Imports a heavyweight package for a simple transformation or algorithm.

### 2.5 Structural bloat and maintainability failures

71. **[E] Long method or procedural monolith.** Large amounts of reasoning are compressed into one function.
72. **[E] God class.** One class accumulates routing, business logic, persistence, validation, formatting, and coordination.
73. **[E] Too many branches.** Large switch/if trees accumulate instead of clearer responsibility boundaries.
74. **[E] High coupling or unstable dependencies.** Modules know too much about one another's internals.
75. **[E] Scattered functionality.** A single concern is fragmented across unrelated locations.
76. **[E] Modular mirage.** Many files/classes give the appearance of modularity while remaining tightly coupled semantically.
77. **[E] Excessive fragmentation.** Straightforward logic is split across tiny classes/functions/files that must all be followed to understand one operation.
78. **[E] Code duplication.** Similar implementations appear repeatedly instead of maintaining one authoritative representation.
79. **[E] Repeated inline integration logic.** External/API interactions are rewritten multiple times once genuine duplication exists.
80. **[SE] `utils.py` or `common.py` junk drawer.** Unrelated operations accumulate in catch-all modules.
81. **[E] Unnecessary conditional blocks.** Conditions exist where a direct return/expression would suffice.
82. **[E] Unnecessary `else`.** Adds indentation after a branch that already returns, throws, or breaks.
83. **[SE] Deeply nested control flow.** Layers of guards and conditionals make the actual path difficult to see.
84. **[SE] Boolean-parameter branching.** One function contains multiple behaviors selected by growing sets of flags.
85. **[SE] Poor cohesion.** A module or class contains responsibilities that change for unrelated reasons.
86. **[SE] Misplaced responsibilities.** Behavior lives far from the data/domain concept it governs.
87. **[E] Comment duplication.** Generated comments repeat themselves across closely related blocks.
88. **[SE] Explanatory wallpaper.** Comments restate obvious syntax instead of documenting invariants, constraints, or rationale.
89. **[E] Confusing or inconsistent naming.** Names shadow built-ins, drift between concepts, or fail to follow local conventions.
90. **[E] Dense clever expressions.** Nested comprehensions/chains/lambdas trade readability for compactness.

### 2.6 Functional correctness and robustness failures

91. **[E] Completely wrong logic.** The implementation computes or changes the wrong result for the intended task rather than merely mishandling an edge case.
92. **[E] Partially wrong logic.** Works for many inputs but violates part of the specification.
93. **[E] Wrong method or function input.** Incorrect parameter value, type, order, unit, or semantic meaning.
94. **[E] Missing edge or corner case.** Empty values, boundaries, duplicate values, negative cases, zero, null, overflow, or unusual ordering break the implementation.
95. **[E] Syntax or parse error.** Source text is not valid in the target language and cannot be parsed.
96. **[E] Compile or type-check failure.** The source parses but violates compile-time or static type rules.
97. **[E] Undefined variable, function, or member.** References a name or member that has not been declared, imported, or made available in scope.
98. **[E] Uninitialized variable or state.** Reads or depends on a value before it has been assigned a valid initial state.
99. **[E] Incompatible type use.** Passes, assigns, compares, or operates on a value where its type or representation is not accepted.
100. **[E] Incorrect input parsing.** Assumes the wrong delimiter, encoding, shape, order, or representation.
101. **[E] Incomplete generation.** Function/class/file ends before the requested behavior exists.
102. **[E] Empty or constant implementation.** Stub technically exists but performs no meaningful requested computation.
103. **[SE] Placeholder implementation masquerading as completion.** `TODO`, `pass`, dummy result, mock data, or hardcoded “temporary” response remains in production path.
104. **[E] Missing validation or precondition.** Calls APIs or operates on values without checking conditions necessary for correctness.
105. **[E] Missing error handling.** Expected operational failures escape incorrectly.
106. **[SE] Broad exception swallowing.** `except Exception: pass`, generic catch-and-continue, or returning fake success.
107. **[SE] Fake fallback or default.** Converts a real error into `None`, `0`, `[]`, or another plausible value that hides failure.
108. **[SE] Try/catch wrapper that changes nothing.** Catches an exception solely to rethrow it unchanged or destroy traceback context.
109. **[SE] Exception translation without semantic value.** Introduces layers of custom error types that convey no additional information.
110. **[SE] Incorrect retry semantics.** Retries non-idempotent operations or retries errors that should fail immediately.
111. **[SE] Missing resource cleanup.** Files, sockets, transactions, processes, locks, streams, or temporary resources leak.
112. **[SE] Missing timeout or cancellation.** Network/subprocess/async work can wait indefinitely.
113. **[SE] Transaction-boundary error.** Multi-step state changes can become partially committed.
114. **[SE] Race condition or atomicity assumption.** Assumes separate reads and writes occur as one indivisible operation when concurrent execution can interleave them.
115. **[SE] State-machine violation.** Allows impossible transitions or bypasses required lifecycle stages.
116. **[SE] Order-dependent behavior.** Correctness accidentally depends on iteration, import, registration, startup, or test order.
117. **[E] Numeric or runtime failure.** Overflow, out-of-bounds access, division by zero, invalid values, recursion failure, or analogous runtime faults.

### 2.7 Performance and resource inefficiency

118. **[E] Suboptimal time complexity.** Runtime grows faster than necessary for input size, often because of avoidable repeated scans or nested work.
119. **[E] Suboptimal memory complexity.** Retains more data than necessary, causing memory use to grow unnecessarily with the input.
120. **[E] Redundant computation.** Repeats an expensive operation instead of retaining the result locally.
121. **[E] Unnecessary computation.** Performs work irrelevant to the output.
122. **[E] Unnecessary conversions or copies.** Repeatedly transforms or duplicates data when the original representation or a single conversion would suffice.
123. **[E] Inefficient loop bounds.** Iterates farther or more often than the required result demands.
124. **[E] Missing early termination.** Continues processing after a decisive result, error, or match is already known.
125. **[SE] Repeated database or network calls inside loops.** Performs one remote operation per iteration instead of batching, prefetching, or reusing a result where appropriate.
126. **[SE] N+1 query or API behavior.** Fetches a collection once, then makes an additional query or request for each item in that collection.
127. **[SE] Unbounded cache, collection, queue, or buffer.** Lets retained data grow without an eviction, size, age, or back-pressure limit.
128. **[SE] Reads entire datasets or files when streaming fits.** Materializes all input even though it can be processed incrementally, increasing latency and peak memory.
129. **[SE] Busy waiting or polling where blocking/event-based primitives fit.** Repeatedly checks for a condition instead of waiting for notification or a bounded blocking operation.
130. **[SE] Performance fix with no measurement.** Complexity increases without a benchmark demonstrating improvement.

### 2.8 Dependency, package, build, and environment failures

131. **[E] Hallucinated package or dependency.** Recommends or imports a package that does not exist.
132. **[E] Missing import or include.** Uses an external symbol without bringing its defining module, header, or package into the build.
133. **[E] Undeclared runtime dependency.** Requires a library or service at execution time without declaring it in the project’s dependency metadata.
134. **[E] Hidden dependency.** Code works only because something happens to be globally installed or supplied transitively.
135. **[E] Non-reproducible dependency environment.** Builds or runs only with an undocumented, machine-specific set of package versions or tools.
136. **[E] Outdated dependency.** Pins or selects an old version that lacks required fixes, support, or compatibility.
137. **[E] Deprecated dependency.** Uses a package or feature its maintainer has marked for replacement or end of support.
138. **[E] Incompatible dependency versions.** Selects versions whose requirements or APIs cannot work together.
139. **[E] Mixed-version API assumptions.** Writes code as though features from different releases coexist in one installed version.
140. **[E] Wildcard dependency versions.** `*`, `+`, `latest`, or similarly unstable selection where reproducibility matters.
141. **[SE] Needless dependency bloat.** Adds packages whose small benefit does not justify their maintenance, update, and supply-chain cost.
142. **[E] Duplicate dependency declarations.** Declares the same package more than once, potentially with conflicting versions or scopes.
143. **[E] Hardcoded build paths or URLs.** Embeds machine-, network-, or environment-specific locations that fail outside the author’s setup.
144. **[E] Hardcoded credentials in build or configuration files.** Stores a password, token, or other secret in tracked build or configuration material.
145. **[E] Overly complex build logic.** Uses intricate scripts, conditionals, or custom steps where a simpler declarative build would be clearer and more reliable.
146. **[SE] Platform-specific build or shell assumption presented as portable.** Relies on an OS, shell, filesystem, or tool behavior that other supported environments do not share.
147. **[SE] Needless lockfile or build-file churn.** Alters unrelated resolved versions or build metadata, obscuring the intended change and increasing merge risk.
148. **[SE] Installation commands unrelated to the task.** Installs packages or tools that the requested change neither needs nor uses.
149. **[SE] Toolchain upgrade as an unrelated side effect.** Changes compiler, runtime, or build-tool versions without a requirement that justifies the compatibility risk.
150. **[SE] Changing dependency manager or build system unnecessarily.** Replaces package or build tooling when the existing system can support the requested work.

### 2.9 Testing and verification failures

151. **[SE/A] No test for newly changed behavior.** Changes externally observable behavior without a test that would detect its regression.
152. **[A] Happy-path-only tests.** Exercises only expected inputs and outcomes, omitting invalid, boundary, error, and interaction cases.
153. **[A] Weak assertions.** Test executes code but does not meaningfully verify the result.
154. **[SE] Tautological test.** Reimplements the production algorithm and compares it with itself.
155. **[SE] Testing implementation details instead of behavior.** Asserts private calls, structure, or incidental sequencing rather than the result a consumer can observe.
156. **[SE] Over-mocking.** Mocks away the integration or behavior the test is supposed to establish.
157. **[SE] Brittle snapshot or golden tests.** Large snapshots are updated mechanically rather than inspected semantically.
158. **[A] Updating expected output only to make a test green.** Changes the oracle to match a defective implementation without evidence that the requirement changed.
159. **[A] Disabling or skipping a failing test instead of fixing implementation.** Removes the signal of a regression while leaving the defective behavior in place.
160. **[A] Loosening an assertion to make the suite pass.** Reduces what a test verifies solely to accommodate an incorrect result.
161. **[A] Editing the evaluation harness.** Alters test runner, fixtures, setup, or scoring mechanics to avoid a failure rather than satisfy the system contract.
162. **[A] Deleting tests.** Removes coverage that exposes a defect or contract instead of resolving the underlying incompatibility.
163. **[A] Hardcoding visible test cases.** Special-cases known test inputs rather than implementing the general rule they represent.
164. **[A] Memorizing public inputs or outputs instead of implementing behavior.** Returns known benchmark answers without deriving them from the intended algorithm or contract.
165. **[A] Feature-isolation overfitting.** Individual features work in tests but fail when composed together.
166. **[A] Visible-test overfitting.** Passes exposed validation while failing held-out behavior.
167. **[A] Running only the new or targeted test.** Never checks the existing regression suite.
168. **[SE] Failure to reproduce the bug before fixing it.** Changes code without a reliable demonstration of the reported failure, leaving cause and effectiveness uncertain.
169. **[SE/A] No regression test for the original failure.** Fixes a defect without adding or preserving an automated check that fails on the old behavior.
170. **[A] Test placement or framework mismatch.** Adds tests in the wrong directory, runner, fixture style, or convention.
171. **[SE] Testing mocks instead of externally observable outcomes.** Verifies that test doubles received expected calls while failing to establish the user-visible behavior.
172. **[SE] Excessive test infrastructure.** Builds factories, DSLs, and helper frameworks for a handful of straightforward tests.

### 2.10 Security and privacy failures

173. **[E] Hardcoded secret, password, token, or API key.** Places a credential directly in code where it can be disclosed through source access, builds, logs, or artifacts.
174. **[E] Secret embedded in source, configuration, build, test, or example files.** Includes sensitive credentials in material likely to be committed, copied, or deployed beyond its intended boundary.
175. **[E] Missing authentication.** Permits use of a protected function or resource without establishing the caller’s identity.
176. **[E] Missing or incorrect authorization.** Authenticates a caller but fails to enforce whether that caller may perform the requested action.
177. **[E] Object or resource access without ownership checking.** Uses a caller-controlled identifier to access an object without confirming the caller is entitled to that specific object.
178. **[E] SQL injection.** Concatenates untrusted input into a database query so it can alter the query’s meaning or data access.
179. **[E] Shell or command injection.** Incorporates untrusted data into an operating-system command so an attacker can execute unintended arguments or commands.
180. **[E] Template, log, or other injection.** Lets untrusted data alter a template, log record, interpreter input, or downstream format instead of treating it as data.
181. **[E] Cross-site scripting or unsafe HTML rendering.** Renders untrusted content as active HTML or script in a user’s browser.
182. **[E] Path traversal or unsafe filesystem paths.** Accepts a path that can escape an intended directory or reach files outside the allowed location.
183. **[E] Unsafe deserialization or dynamic evaluation.** Reconstructs objects or evaluates code-like input from untrusted data, enabling unintended behavior or code execution.
184. **[E] Untrusted URL or SSRF-style network access.** Lets untrusted input choose server-side request targets, potentially reaching internal or protected services.
185. **[E] Weak or inappropriate cryptography.** Uses obsolete, misconfigured, homemade, or unsuitable algorithms, modes, keys, or key management for the protection required.
186. **[E] Predictable randomness where security requires unpredictability.** Uses a guessable random source for secrets, tokens, nonces, or other security-sensitive values.
187. **[E] Insecure transport or TLS assumptions.** Sends sensitive traffic without proper encryption or accepts invalid certificates, protocols, or hostname checks.
188. **[E] Unsafe permission or file defaults.** Creates files, directories, or resources with access rights broader than their sensitivity permits.
189. **[E] Secrets or personal data written to logs.** Records credentials, tokens, identifiers, or sensitive payloads in logs accessible beyond the original request path.
190. **[E] Missing security-relevant input validation.** Fails to constrain untrusted values before they reach a security-sensitive operation or trust boundary.
191. **[E] Package hallucination creating supply-chain exposure.** Names a nonexistent package that an attacker can publish and have downstream users install.
192. **[E] Failure to notice existing vulnerable code while addressing a nearby task.** Makes a local change while overlooking an evident adjacent vulnerability that the change touches or preserves.
193. **[SE] Security check only in UI or client code.** Relies on a bypassable client-side control instead of enforcing the rule at the trusted server-side boundary.
194. **[SE] Fail-open authorization or configuration behavior.** Grants access or proceeds with an unsafe default when a required security decision cannot be made.

### 2.11 Change hygiene and integration failures

195. **[A/SE] Giant unrelated diff.** Changes far more files or behavior than the request requires, making correctness and review harder.
196. **[SE] Unnecessary mixing of refactor and behavior change.** Combines structural cleanup with a semantic change so reviewers cannot readily isolate the behavior under review.
197. **[SE] Broad formatting churn.** Rewrites whitespace, line wrapping, or style across unrelated code, hiding material changes in noise.
198. **[SE] Broad renaming churn.** Renames unrelated identifiers or concepts in a focused change, increasing review and merge burden.
199. **[SE] File moves mixed into an unrelated fix.** Relocates files while changing behavior, complicating history, review, and conflict resolution without need.
200. **[E/SE] Duplicating functionality already in the repository.** Adds a second implementation rather than locating, reusing, or extending the existing authoritative behavior.
201. **[SE] Partial refactor.** New abstraction is introduced but the old path remains active.
202. **[SE] Two sources of truth.** Old and new configuration, mapping, or state representations coexist.
203. **[A/SE] Partial migration.** Some callers/data paths use the new contract and others silently remain old.
204. **[SE] Backward-compatibility break not requested by the change.** Changes existing callers’ behavior, data, or configuration despite no requirement to do so.
205. **[SE] Public API or schema break without migration or versioning.** Removes or changes a published contract without a compatible transition path for consumers or stored data.
206. **[SE] Generated or vendor code edited instead of its source.** Modifies derived or third-party files that will be overwritten or cannot be maintained through the owning source.
207. **[SE] Build artifacts, cache, or generated output accidentally committed.** Adds machine-derived files that do not belong in version control and create noisy, stale, or platform-specific changes.
208. **[E/SE] Dead code left after experimentation.** Leaves unreachable, unused, superseded, or permanently disabled code after the final approach is known.
209. **[SE] Debug prints or logging left behind.** Leaves temporary diagnostic output that adds noise, leaks data, or changes operational behavior.
210. **[SE] Temporary feature flags or TODOs become permanent.** Leaves provisional controls or deferred work without ownership, expiry, or a plan to resolve them.
211. **[SE] Feature implemented in one duplicated code path but not others.** Updates only one equivalent implementation, causing behavior to vary by entry point or environment.
212. **[SE] New behavior disagrees with a compatibility layer or adapter.** Introduces a contract that conflicts with the translation or legacy behavior at a system boundary.

### 2.12 Documentation, comments, configuration, and operability failures

213. **[E/SE] Comments that describe code incorrectly.** Documentation adjacent to code states behavior, constraints, or ownership that no longer matches the implementation.
214. **[E/SE] Comments or documentation promising unimplemented behavior.** Public or internal documentation advertises an API, guarantee, or workflow the system does not provide.
215. **[SE] README, example, or configuration documentation not updated after a contract change.** Leaves users with stale instructions, examples, or configuration details after behavior changes.
216. **[SE] Example code uses a different API from production code.** Demonstrates calls, names, or semantics that diverge from the currently supported interface.
217. **[SE] Fabricated documentation reference, flag, configuration key, or command.** Documents plausible but nonexistent resources that send users toward failed setup or operation.
218. **[SE] Excessive generated documentation for trivial internals.** Adds verbose reference material for obvious private details, obscuring the small amount of guidance readers need.
219. **[SE] Logging every step rather than operationally meaningful events.** Emits routine internal activity rather than decision, error, audit, or lifecycle events useful for operating the system.
220. **[SE] No observability where operational failure would otherwise be invisible.** Omits the logs, metrics, traces, or health signals needed to detect and diagnose production failures.
221. **[SE] High-cardinality or unbounded logging or metrics.** Uses unbounded values such as user IDs, URLs, or request bodies as metric dimensions or log fields, increasing cost and reducing query usefulness.
222. **[SE] Logs expose secrets or sensitive payloads.** Records credentials or personal/confidential data in operational telemetry without a justified protected path.
223. **[SE] Process-global mutable state introduced for convenience.** Stores changing application state globally, making lifecycle, isolation, concurrency, and tests harder to reason about.
224. **[SE] Startup or import-time side effects.** Performs I/O, mutation, registration, network access, or other work merely by loading a module or starting a process.
225. **[SE] Destructive migration or deployment without rollback strategy.** Irreversibly changes data or infrastructure without a tested recovery path if the deployment fails.
226. **[SE] Environment-specific constants disguised as universal defaults.** Bakes one environment’s hostnames, paths, limits, or credentials assumptions into defaults used elsewhere.

### 2.13 Coding-agent workflow and interaction failures

227. **[A] Editing before understanding.** Begins patches before gathering enough repository evidence.
228. **[A] Search or exploration underreach.** Fails to inspect the files or definitions that contain the decisive information.
229. **[A] Search or exploration overreach.** Burns large amounts of time/tokens browsing irrelevant portions of the repository.
230. **[A] Tool-use thrashing.** Repeats searches, builds, installs, or shell commands without gaining new information.
231. **[A] Irrelevant command execution.** Runs installs or shell operations when the task calls for a simple code/document edit.
232. **[A] Repeating a failed approach.** Error evidence changes but the strategy does not.
233. **[A] Failing to read actual error output.** Ignores the diagnostic details that identify the failed command, location, cause, or next investigation step.
234. **[A] Fixing the symptom instead of tracing the failing path.** Suppresses a visible failure without locating and correcting the condition that produces it.
235. **[A] Trusting generated plan over contradictory repository evidence.** Continues following an initial hypothesis after source, configuration, tests, or errors show it is false.
236. **[A] Wrong-file persistence.** Keeps modifying an incorrect location rather than re-localizing the problem.
237. **[A] Ignoring user corrections.** Fails to incorporate direct feedback that changes the task’s intended behavior, scope, or constraints.
238. **[A] Failing to ask for clarification when ambiguity materially changes implementation.** Guesses among consequential interpretations when repository evidence cannot safely resolve them.
239. **[A] Excessive autonomy without checkpoints.** Makes a long sequence of consequential changes without verifying direction, evidence, or user intent along the way.
240. **[A] Large speculative patch before first verification.** Accumulates many unvalidated changes based on assumptions rather than testing the smallest plausible approach.
241. **[A] Declaring success without appropriate verification.** Reports completion without tests, inspection, or other evidence proportionate to the claimed behavior.
242. **[A] Treating passing tests as equivalent to satisfying the requirement.** Equates a limited test result with full compliance despite possible missing requirements, coverage, or integration checks.
243. **[A] Reward hacking.** Optimizes the measurable proxy rather than the user's actual goal.
244. **[A] Destructive workaround.** Deletes, disables, bypasses, or hardcodes around the mechanism exposing the failure.
245. **[A] Leaving the working tree dirty with unrelated experiments or generated artifacts.** Retains exploratory edits or generated files that are not part of the delivered solution.
246. **[A] Failing to revert abandoned approaches.** Leaves superseded patches, flags, helpers, or configuration after changing course.
247. **[A] Excessive token or tool expenditure for useful change size.** Uses disproportionate exploration, command execution, or generated output for a simple task without producing corresponding evidence or value.
248. **[A] Silent uncertainty.** Makes consequential assumptions without signaling that evidence is missing.
249. **[A] False verification narrative.** Says something was tested, fixed, or confirmed when the observable result does not establish it.
250. **[A] One-more-abstraction repair loop.** Responds to failure by layering another wrapper/helper/configuration mechanism over the original bad design instead of simplifying it.

### 2.14 Central meta-failures

251. **Adding before understanding.** New code, abstractions, dependencies, and configuration appear before the existing solution space is inspected.
252. **Generalizing before duplication.** An abstraction appears before two genuine, stable examples demonstrate what should be abstracted.
253. **Optimizing before measuring.** Performance machinery precedes evidence of a performance problem.
254. **Configuring before variability exists.** Flags/options exist before there are real alternative behaviors.
255. **Distributing before scale requires it.** Async, queues, workers, microservices, caches, and coordination precede actual load or operational constraints.
256. **Wrapping before a boundary exists.** Interfaces/adapters are introduced around components with no current substitution, isolation, or ownership requirement.
257. **Depending before checking the platform.** New code/package is introduced before checking whether stdlib, framework, database, type system, or infrastructure already provides the feature.
258. **Coding before grounding.** The model starts implementation before understanding repository-specific facts.
259. **Passing tests before satisfying intent.** The model optimizes the observable test surface instead of the full specification.
260. **Generating before verifying.** Plausibility is mistaken for correctness.
261. **Completing before integrating.** A local implementation is declared finished without checking callers, tests, schemas, docs, dependencies, and compatibility.
262. **Expanding instead of simplifying.** When uncertainty appears, the model adds options, abstractions, fallbacks, or layers instead of reducing the solution to what is actually known to be necessary.

## 3. Evidence labels and limits

- **[E] Empirically observed:** the failure or a close equivalent appears directly in studies of LLM-generated code.
- **[A] Agent-observed:** the pattern is documented in repository-level coding-agent benchmarks or real coding-agent sessions.
- **[SE] Software-engineering smell:** an established engineering failure mode included because it fits broader observed AI-code tendencies toward bloat, unnecessary layering, or poor maintainability, without adequate evidence that this exact subtype is disproportionately common in AI code.
- **[E/SE]** means the broader family has direct AI evidence and the formulation is also a conventional engineering smell.
- **Combined labels** identify more than one basis, such as `[E/A]` or `[A/SE]`.

The labels describe the support basis inherited from the prior research-oriented catalogue. They do not establish that every pattern is more frequent in AI code than in human-written code, nor do they establish a universal frequency ranking. Some supporting studies may be preprints, use selected models or benchmarks, or rely partly on static-analysis heuristics. Use this catalog as a review checklist and classification reference, not as a general causal or prevalence claim.
