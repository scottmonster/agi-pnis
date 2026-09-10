# Python Pitfalls Rules

## Language Semantics and Object State

### Function state and object lifetime
1.1.1 **Mutable default arguments** - Functions `MUST NOT` use a mutable default argument when a fresh object is intended for each call; they `MUST` create the mutable object per call using `None` or another sentinel default.

### Runtime validation
1.2.1 **Assertions for required runtime checks** - `assert` `MUST NOT` be used for validation, authorization, security, or other checks required for runtime correctness; required checks `MUST` use explicit control flow and exceptions.

### Exception handling
1.3.1 **Bare or overly broad exception handling** - Exception handlers `SHOULD` catch the narrowest exception types they can meaningfully handle and `MUST NOT` use bare `except:` unless interception of `BaseException` subclasses is intentionally required.

### Exception control flow
1.4.1 **Control flow in `finally` suppressing exceptions** - A `finally` block `MUST NOT` use `return`, `break`, or `continue` in a way that discards an active exception.

### Resource lifecycle
1.5.1 **Non-deterministic resource cleanup** - Files, sockets, locks, database resources, and other resources requiring prompt deterministic release `MUST` be managed with context managers or explicit cleanup rather than relying on garbage collection or `__del__`.

### Hashing and equality
1.6.1 **Mutable hash keys** - An object used as a dict key or set member `MUST NOT` allow equality-relevant state to change in a way that changes its hash while it remains in the collection.


## Security and Trust Boundaries

### Serialization security
2.1.1 **Unpickling untrusted data** - Untrusted or unauthenticated data `MUST NOT` be deserialized with `pickle`.
2.1.2 **Opening untrusted `shelve` databases** - A `shelve` database from an untrusted source `MUST NOT` be opened.
2.1.3 **Unmarshalling untrusted data** - `marshal` `MUST NOT` be used to deserialize untrusted data or as a general-purpose persistent serialization format.

### Dynamic execution security
2.2.1 **`eval()` and `exec()` on untrusted input** - Untrusted input `MUST NOT` be passed to `eval()` or `exec()`.

### Parser resource safety
2.3.1 **Treating `ast.literal_eval()` as safe for hostile input** - Hostile or unbounded input `MUST NOT` be passed to `ast.literal_eval()` unless appropriate resource limits or equivalent denial-of-service controls are in place.

### Process security
2.4.1 **Shell injection through `subprocess`** - `subprocess` calls `SHOULD` use `shell=False` with arguments passed as a sequence, and `shell=True` `MUST NOT` interpolate untrusted data without correct shell quoting.

### Process I/O
2.5.1 **Waiting on subprocesses with unread pipes** - Code `MUST NOT` call `Popen.wait()` while a child can block on undrained `stdout=PIPE` or `stderr=PIPE`; it `MUST` drain those pipes, normally with `communicate()`.

### Process concurrency
2.6.1 **`preexec_fn` in threaded programs** - `Popen(preexec_fn=...)` `MUST NOT` be used in a process containing multiple threads.

### Process security
2.7.1 **Incomplete privilege dropping with `subprocess`** - When a POSIX child process must drop supplementary group privileges, `Popen` `MUST` explicitly set `extra_groups=()` or the intended replacement group set rather than relying on `user=` alone.

### Cryptographic randomness
2.8.1 **`random` for secrets** - Security-sensitive random values `MUST` use `secrets` or another cryptographically secure generator and `MUST NOT` use the default `random` module.

### Password security
2.9.1 **General-purpose hashes for passwords** - Passwords `MUST NOT` be stored using a direct fast general-purpose hash and `MUST` use an appropriate salted password-derivation mechanism.

### Cryptographic comparison
2.10.1 **Ordinary equality for secret digests** - Secret-dependent digests such as HMAC values `MUST` be compared with `hmac.compare_digest()` or `secrets.compare_digest()` rather than ordinary equality.

### Filesystem security
2.11.1 **Insecure temporary filenames with `mktemp()`** - Security-sensitive temporary files `MUST NOT` be created with `tempfile.mktemp()` and `MUST` use an atomic temporary-file or temporary-directory API.

### Archive extraction security
2.12.1 **Blind extraction of untrusted tar archives** - Untrusted tar archives `MUST NOT` be blindly extracted; extraction `MUST` use appropriate filters and validate destination and resource constraints required by the trust boundary.

### Parser security
2.13.1 **Assuming standard XML parsers are hardened against hostile documents** - Attacker-controlled XML `MUST NOT` be processed with a standard XML parser unless the selected parser and configuration address the applicable documented XML attacks.

### URL security
2.14.1 **Attacker-controlled second argument to `urljoin()`** - Attacker-controlled input `MUST NOT` be passed directly as the second argument to `urljoin()` when the result is required to remain under the base URL.
2.14.2 **Treating `urlparse()` as URL validation** - Parsed URL components `MUST` be explicitly validated before being used for security-sensitive decisions; successful `urlparse()` or `urlsplit()` parsing `MUST NOT` be treated as validation.

### Database security
2.15.1 **SQL construction with Python string formatting** - SQL data values `MUST` be passed through the database driver's parameter-binding mechanism and `MUST NOT` be interpolated with f-strings, concatenation, `%`, or `.format()`.

### Database concurrency
2.16.1 **Unsynchronized shared SQLite connections** - If an SQLite connection is shared across threads with `check_same_thread=False`, writes through that connection `MUST` be explicitly serialized.

### Filesystem security
2.17.1 **Permission pre-checks with `os.access()`** - Code `SHOULD NOT` use `os.access()` as a precondition before a filesystem operation when it can instead attempt the operation directly and handle failure.
2.17.2 **Using `commonprefix()` for path containment** - `os.path.commonprefix()` `MUST NOT` be used to enforce filesystem path containment; containment checks `MUST` use path-aware canonicalization and component-aware comparison.

### Archive extraction security
2.18.1 **Assuming `zipfile.Path` prevents path traversal** - Untrusted paths obtained through `zipfile.Path` `MUST` be validated before filesystem extraction or writes because `zipfile.Path` itself does not provide path-traversal protection.

### Packaging security
2.19.1 **Private package discovery with `--extra-index-url`** - `pip --extra-index-url` `MUST NOT` be relied upon to securely resolve uniquely named private packages alongside a public index.
2.19.2 **Assuming ordinary pip installs provide strong supply-chain integrity** - Environments requiring strong installation integrity `MUST` pin dependencies and verify hashes, and environments that cannot permit arbitrary source-build execution `MUST` restrict installation to trusted binary distributions.

### Transport security
2.20.1 **TLS contexts without certificate and hostname verification** - TLS clients that require peer authentication `MUST` enable certificate and hostname verification and `SHOULD` use `ssl.create_default_context()` or `PROTOCOL_TLS_CLIENT`.

### Network service security
2.21.1 **`http.server` in production** - `http.server` `MUST NOT` be used as a production HTTP server.

### Thread concurrency
2.22.1 **Treating compound shared-state operations as atomic** - Shared read-modify-write sequences and multi-operation invariants `MUST` use explicit synchronization rather than relying on the atomicity of individual built-in operations.


## Concurrency and Process Lifecycle

### Runtime concurrency model
3.1.1 **Relying on the GIL for thread safety** - Code correctness `MUST NOT` depend on the CPython GIL implicitly serializing access to shared mutable state.

### Thread lifecycle
3.2.1 **Daemon threads for work requiring cleanup** - Essential persistent, transactional, or cleanup-dependent work `MUST NOT` exist only in daemon threads and `MUST` have an explicit shutdown and completion mechanism.

### Process concurrency
3.3.1 **Forking a multithreaded process** - Python programs `SHOULD NOT` call `os.fork()` from a multithreaded process unless the post-fork constraints are explicitly understood and satisfied.

### Process startup
3.4.1 **Missing multiprocessing main guard** - Code that creates multiprocessing workers under spawn or forkserver `MUST` protect the process-creating entry point with `if __name__ == "__main__":`.

### Process serialization
3.5.1 **Non-importable multiprocessing targets** - Multiprocessing targets and arguments used with spawn or forkserver `MUST` be picklable, and worker callables `MUST` be defined in an importable context.

### Process lifecycle
3.6.1 **Force-terminating processes that hold shared resources** - A process `MUST NOT` be force-terminated while it may hold queues, pipes, locks, semaphores, or other shared resources when corruption or unreleased state would be unacceptable.

### Process IPC
3.7.1 **Joining a multiprocessing producer before draining its queue** - A process that has produced buffered multiprocessing queue data `MUST NOT` be joined before the data is drained when its feeder thread may still be flushing the queue.

### Executor concurrency
3.8.1 **Executor tasks waiting on the same exhausted executor** - A task running in a bounded executor `MUST NOT` synchronously wait for work that can execute only in the same executor when all workers can become occupied by such waiting tasks.

### Asyncio scheduling
3.9.1 **Blocking the asyncio event loop** - Asyncio event-loop code `MUST NOT` perform materially blocking synchronous I/O or CPU-bound work directly when doing so would prevent other tasks from progressing.

### Asyncio execution
3.10.1 **Calling a coroutine without awaiting or scheduling it** - Every coroutine object intended to execute `MUST` be awaited or explicitly scheduled.

### Asyncio cancellation
3.11.1 **Swallowing `CancelledError`** - Code that catches `asyncio.CancelledError` `SHOULD` re-raise it after cleanup unless cancellation is intentionally and completely suppressed.

### Asyncio task lifecycle
3.12.1 **Losing references to background asyncio tasks** - Independently scheduled asyncio tasks `MUST` retain a strong reference until completion unless their lifecycle is managed by a structure such as `TaskGroup`.

### Asyncio thread interaction
3.13.1 **Calling non-thread-safe asyncio APIs from worker threads** - Code running outside the event-loop thread `MUST` use thread-safe asyncio entry points such as `call_soon_threadsafe()` or `run_coroutine_threadsafe()` rather than directly invoking non-thread-safe loop operations.

### Context-local state
3.14.1 **`threading.local()` for asyncio-local state** - Logical context that must remain isolated between asyncio tasks `MUST` use `ContextVar` or an equivalent task-aware mechanism rather than `threading.local()`.

### Signal handling
3.15.1 **Lock acquisition inside signal handlers** - Python signal handlers `MUST NOT` acquire ordinary synchronization locks that can already be held by interrupted code.

### Process termination
3.16.1 **Using `os._exit()` as an ordinary exit mechanism** - Normal Python termination `MUST` use `sys.exit()` or normal control flow; `os._exit()` `SHOULD` be reserved for specialized cases such as post-fork child termination where cleanup must be bypassed.

### Thread termination
3.17.1 **Assuming `sys.exit()` from a worker thread exits the process** - Worker threads `MUST NOT` use `sys.exit()` as a process-wide shutdown mechanism.

### Type hint runtime boundary
3.18.1 **Treating type annotations as runtime validation** - Runtime input or state validation `MUST NOT` rely solely on type annotations because ordinary annotations are not enforced by Python at runtime.


## Type System Boundaries

### Type hint runtime boundary
4.1.1 **Treating `typing.cast()` as a runtime cast** - `typing.cast()` `MUST NOT` be used as runtime validation or conversion because it returns the value unchanged.

### Static type safety
4.2.1 **Unnecessary use of `Any`** - `Any` `SHOULD` be used only when bypassing static type checking is intentional; checked alternatives such as `object`, protocols, unions, or generics `SHOULD` be used when their constraints can be expressed.

### Environment isolation
4.3.1 **Installing project dependencies into the system Python** - Project-specific third-party dependencies `SHOULD` be installed in an isolated environment and `MUST NOT` override an externally managed system Python except through an explicitly chosen supported mechanism.


## Environment and Packaging Foundations

### Build isolation
5.1.1 **Undeclared build dependencies** - A Python project `MUST` declare its build backend and required build-time dependencies in `[build-system]` rather than depending on packages incidentally present in the developer environment.

### Packaging supply chain
5.2.1 **Assuming an import name identifies the package to install** - An unknown import name `MUST NOT` be automatically used as a package-installation name without verifying the intended distribution package.

### Iterator cardinality
5.3.1 **Silent truncation with `zip()`** - When all zipped iterables are required to have equal length, code `MUST` use `zip(..., strict=True)` or perform an equivalent explicit length check.


## Collections, Iteration, and Expressions

### Object aliasing
6.1.1 **Assignment does not copy objects** - When independently mutable state is required, code `MUST` explicitly create or copy the object rather than relying on assignment to duplicate it.

### Object copying
6.2.1 **Assuming a shallow copy duplicates nested state** - A shallow copy `MUST NOT` be used when nested mutable objects are required to be independent unless those nested objects are separately copied or reconstructed.

### Class state
6.3.1 **Mutable class variables used as per-instance state** - Mutable state intended to be unique to each instance `MUST` be initialized per instance rather than stored in a shared class variable.

### Container aliasing
6.4.1 **Nested mutable sequences created with repetition** - Sequence repetition `MUST NOT` be used to create nested mutable elements that are intended to be independent.

### Dataclass state
6.5.1 **Mutable dataclass defaults** - Mutable dataclass fields intended to be unique per instance `MUST` use `field(default_factory=...)` or another per-instance factory.

### Closures and name binding
6.6.1 **Late-bound closures in loops** - A closure created in a loop `MUST` explicitly bind the current loop value when each closure is intended to retain a different iteration value.

### Name binding and scope
6.7.1 **Assignment unexpectedly making a variable local** - A function that must assign to an enclosing or global binding `MUST` declare the appropriate `nonlocal` or `global` scope or avoid assigning to that name locally.

### Augmented assignment semantics
6.8.1 **Augmented assignment can mutate before failing** - Code `MUST NOT` use augmented assignment through an immutable container element when the contained object's in-place operation can mutate state before reassignment fails.

### Mapping construction
6.9.1 **Mutable values with `dict.fromkeys()`** - `dict.fromkeys()` `MUST NOT` be given a shared mutable value when each key requires independent mutable state.

### Mapping semantics
6.10.1 **`defaultdict.get()` bypasses the factory** - Code that intends a missing `defaultdict` key to invoke `default_factory` `MUST` use indexing rather than `get()`.

### Mapping iteration
6.11.1 **Mutating a dict while iterating it** - Code `MUST NOT` add or remove dictionary entries while directly iterating that dictionary or its dynamic views; it `MUST` iterate a snapshot or otherwise separate traversal from structural mutation.
6.11.2 **Treating dictionary views as snapshots** - Code requiring a fixed snapshot of dictionary keys, values, or items `MUST` materialize the view rather than retaining the dynamic view object.

### Iterator grouping
6.12.1 **`groupby()` without grouping consecutive equal keys** - `itertools.groupby()` `MUST` be used only when records with the same grouping key are consecutive, with sorting or equivalent ordering performed first when global grouping is intended.

### Iterator lifetime
6.13.1 **Saving `groupby()` group iterators for later** - A subgroup returned by `itertools.groupby()` `MUST` be materialized before advancing the parent iterator if the subgroup is needed afterward.

### Iterator buffering
6.14.1 **Unbounded buffering with `itertools.tee()`** - `itertools.tee()` `SHOULD NOT` be used when duplicated iterators may advance far apart enough to cause unacceptable hidden buffering.

### Generator control flow
6.15.1 **Raising `StopIteration` inside generators** - Generator code `MUST` terminate with `return` or normal exhaustion and `MUST NOT` deliberately raise `StopIteration` to end iteration.

### Comprehension scope
6.16.1 **Assignment-expression targets leaking from comprehensions** - An assignment expression inside a comprehension `SHOULD NOT` target a containing-scope name whose existing binding must remain unchanged.

### Pattern matching semantics
6.17.1 **Bare names in structural pattern matching** - A bare identifier `MUST NOT` be used in a `case` pattern when the intent is to compare against an existing constant; a literal or qualified value pattern `MUST` be used instead.

### Identity and equality
6.18.1 **`is` for value equality** - Value equality `MUST` use `==` or `!=`, while `is` and `is not` `MUST` be reserved for identity checks.

### Numeric type relationships
6.19.1 **Boolean and numeric keys colliding** - Values such as `True`, `1`, and `1.0` `MUST NOT` be used as distinct dict or set keys when the application requires them to represent different keys.

### Boolean expression semantics
6.20.1 **Assuming `and` and `or` return booleans** - Code `MUST NOT` use `value or default` or equivalent truth-value selection when legitimate falsey values must be preserved as distinct from missing values.

### Floating-point semantics
6.21.1 **Exact equality for computed floating-point values** - Computed floating-point values that represent approximate quantities `SHOULD` be compared using a domain-appropriate tolerance rather than exact equality.


## Numerics and Time

### Floating-point comparison
7.1.1 **`math.isclose()` against zero without `abs_tol`** - A tolerance-based comparison against zero with `math.isclose()` `MUST` provide a meaningful nonzero `abs_tol` when nonzero values near zero are intended to count as close.

### Decimal arithmetic
7.2.1 **Constructing exact decimals from binary floats** - Decimal quantities that originate as exact decimal values `SHOULD` construct `Decimal` from an exact representation such as a string rather than from a binary float.

### Duration semantics
7.3.1 **Using `timedelta.seconds` for total duration** - Code requiring the total duration in seconds `MUST` use `timedelta.total_seconds()` rather than the `.seconds` component.

### Datetime semantics
7.4.1 **Naive UTC datetimes** - New code representing UTC `SHOULD` use timezone-aware datetimes rather than naive UTC values produced by APIs such as `utcnow()` or `utcfromtimestamp()`.
7.4.2 **Calling `timestamp()` on naive UTC** - A naive datetime representing UTC `MUST` be assigned the correct UTC timezone before `.timestamp()` is used.

### Clock semantics
7.5.1 **Wall-clock time for elapsed durations** - Elapsed-time measurements and deadlines `MUST` use a monotonic clock such as `time.monotonic()` or `time.perf_counter()` rather than `time.time()`.

### Text encoding
7.6.1 **Implicit text-file encoding** - Code reading or writing a text format with a defined encoding `SHOULD` specify that encoding explicitly rather than relying on the platform or interpreter default.


## Text, Data Formats, and Standard Collections

### Text encoding
8.1.1 **Silently ignoring encoding errors** - `errors="ignore"` `SHOULD NOT` be used for text decoding or encoding unless silent irreversible loss of invalid data is explicitly acceptable.

### CSV I/O
8.2.1 **Opening CSV files without `newline=""`** - Text files passed to `csv.reader` or `csv.writer` `MUST` be opened with `newline=""`.

### CSV data fidelity
8.3.1 **Serializing `None` through `csv.writer`** - When CSV output must preserve the distinction between `None` and an empty string, nullable values `MUST` be explicitly encoded before being passed to `csv.writer`.

### JSON framing
8.4.1 **Repeated `json.dump()` calls as one JSON document** - Multiple independent `json.dump()` results `MUST NOT` be concatenated and treated as one JSON document; an explicit framing mechanism or enclosing JSON structure `MUST` be used.

### JSON interoperability
8.5.1 **Non-standard NaN and Infinity in JSON** - JSON output required to conform strictly to the JSON specification `MUST` disable non-standard `NaN` and infinity values, such as with `allow_nan=False`.

### JSON data fidelity
8.6.1 **Duplicate JSON object names** - When duplicate JSON object member names are invalid for an input contract, decoding `MUST` use a mechanism that detects and rejects or explicitly handles duplicates.
8.6.2 **Assuming JSON preserves non-string dict keys** - Non-string mapping keys `MUST` be encoded explicitly when their original types must survive a JSON round trip.

### String API semantics
8.7.1 **Using `strip()` to remove a literal prefix or suffix** - Literal string prefixes and suffixes `MUST` be removed with `removeprefix()` or `removesuffix()` rather than `strip()`, `lstrip()`, or `rstrip()` with the literal as their character argument.

### Regular-expression literals
8.8.1 **Regular expressions without raw strings** - Regular-expression literals containing backslashes `SHOULD` use raw string literals unless ordinary Python string escaping is intentionally required.

### Regular-expression matching
8.9.1 **Confusing `re.match()`, `search()`, and `fullmatch()`** - Regular-expression code `MUST` use `search()` for anywhere matching, `match()` for start-position matching, and `fullmatch()` when the entire string must satisfy the pattern.

### Priority queues
8.10.1 **Heap entries without a tie-breaker** - Heap entries with potentially equal priorities `MUST` include a comparable tie-breaker when the remaining entry fields are not guaranteed to be mutually orderable.

### Command-line parsing
8.11.1 **`argparse` with `type=bool`** - Boolean command-line arguments `MUST NOT` use `argparse` with `type=bool`; they `MUST` use an appropriate boolean action or explicit text parser.

### Collection semantics
8.12.1 **`deque.extendleft()` reversing input order** - Code using `deque.extendleft()` `MUST` account for its reversal of input order and `MUST` reverse the input first when original order must be preserved.
8.12.2 **Treating `Counter` as a strictly positive multiset** - When a `Counter` is required to represent only positive multiplicities, zero and negative counts `MUST` be removed or normalized before that invariant is relied upon.

### Caching semantics
8.13.1 **Caching generators, coroutines, or side-effectful functions** - `functools.cache` and `lru_cache` `MUST NOT` be applied when each call must produce a fresh generator or coroutine, repeat side effects, or obtain fresh external state.

### Cache lifetime
8.14.1 **`lru_cache` on instance methods retaining instances** - Instance methods on large or short-lived object populations `SHOULD NOT` use long-lived `lru_cache` caching unless retaining referenced instances in the cache is acceptable.

### Cache concurrency
8.15.1 **Assuming `cached_property` computes exactly once under concurrency** - A `cached_property` whose getter must execute at most once `MUST` provide explicit synchronization rather than relying on `cached_property` itself.
8.15.2 **Assuming `lru_cache` suppresses duplicate concurrent calls** - Code requiring single-flight execution `MUST NOT` rely on `lru_cache` to prevent concurrent duplicate calls.

### Import namespace management
8.16.1 **Wildcard imports** - `from module import *` `SHOULD NOT` be used except in deliberately controlled namespace-export scenarios.


## Imports and Module Execution

### Import initialization
9.1.1 **`from module import name` in circular imports** - Circular import relationships `SHOULD` be refactored, and code `SHOULD NOT` use `from module import name` when the imported module may still be partially initialized.

### Import caching
9.2.1 **Reloading modules after `from ... import ...`** - Code requiring reloadable bindings `MUST NOT` assume `importlib.reload()` updates names previously imported with `from module import name`; it `MUST` use module-qualified access or explicitly rebind those names.

### Module execution
9.3.1 **Assuming imports are passive declarations** - Module import-time code `SHOULD` avoid unnecessary externally visible side effects and `MUST NOT` rely on ordinary repeated imports to re-execute initialization.

### Concurrency performance
9.4.1 **Threads as the default solution for CPU-bound Python code** - On GIL-enabled CPython, ordinary threads `SHOULD NOT` be chosen solely to obtain parallel speedup for CPU-bound Python bytecode.


## Concurrency, Runtime State, and Warnings

### Structured concurrency
10.1.1 **Assuming `asyncio.gather()` cancels siblings on first failure** - Code that requires sibling tasks to be cancelled when one child fails `MUST` use `TaskGroup` or another mechanism that explicitly provides that behavior rather than relying on default `asyncio.gather()` semantics.

### Warning-state concurrency
10.2.1 **Concurrent use of `warnings.catch_warnings()` without context-aware warnings** - When `sys.flags.context_aware_warnings` is false, concurrent uses of `warnings.catch_warnings()` `MUST` be serialized or otherwise prevented from overlapping.

### Locale state
10.3.1 **Changing process locale in concurrent code** - Concurrent code `SHOULD NOT` mutate the process-wide locale with `locale.setlocale()` during normal operation.

### Environment portability
10.4.1 **Moving or copying virtual environments** - Virtual environments `MUST` be recreated after relocation rather than treated as portable directories that can be moved or copied intact.


## Packaging and Distribution Practices

### Package layout
11.1.1 **Flat-layout imports hiding packaging errors** - Projects for which working-tree imports could hide installation or packaging defects `SHOULD` use a `src/` layout or another mechanism that ensures tests exercise the installed package.

### Packaging verification
11.2.1 **Testing only editable installs** - Distributable projects `SHOULD` test at least one normal built-and-installed distribution in addition to any editable-install workflow.

### Packaging workflow
11.3.1 **Direct `setup.py` commands** - Modern Python projects `SHOULD NOT` invoke `setup.py` commands such as `install`, `develop`, or `sdist` directly and `SHOULD` use standards-based build and installation frontends.

### Dependency specification
11.4.1 **Treating requirements files as project dependency metadata** - A distributable project's runtime dependencies `MUST` be declared in project metadata, while requirements files `SHOULD` be used for concrete environment or deployment dependency sets.

### Dependency reproducibility
11.5.1 **Treating `pip freeze` as a lockfile solver** - `pip freeze` output `MUST NOT` be treated as evidence that dependencies were independently solved or as a lockfile with stronger guarantees than the captured environment state.

### Static type variance
11.6.1 **Assuming mutable generic containers are covariant** - Mutable generic containers such as `list[Derived]` `MUST NOT` be treated as compatible with `list[Base]`; a covariant read-only abstraction `SHOULD` be used when mutation is not required.


## Static Typing and Annotation Introspection

### Runtime structural typing
12.1.1 **Treating `@runtime_checkable Protocol` as runtime type validation** - A `@runtime_checkable Protocol` check `MUST NOT` be treated as validation of complete method signatures, annotations, or static type contracts.

### Type hint runtime boundary
12.2.1 **Treating `TypedDict` as a runtime record type** - `TypedDict` `MUST NOT` be relied upon to validate keys or values at runtime.

### Annotation introspection
12.3.1 **Reading annotations directly from `__annotations__`** - Runtime annotation introspection `SHOULD` use the supported annotation or inspection APIs rather than directly interpreting `__annotations__`.

### Annotation introspection security
12.4.1 **Evaluating string annotations unnecessarily** - Runtime code `SHOULD NOT` evaluate string annotations unless actual evaluated annotation values are required.

### Test mocking
12.5.1 **Patching where an object is defined rather than looked up** - `unittest.mock.patch` `MUST` target the namespace where the code under test looks up the object.


## Testing, Compatibility, and Logging

### Test mocking
13.1.1 **Unconstrained mocks masking API mistakes** - Mocks representing a real API `SHOULD` use `spec`, `spec_set`, or `autospec` when nonexistent attributes or invalid call signatures should cause the test to fail.
13.1.2 **Inspecting mutated mock arguments after the call** - Tests that must verify a mutable argument's state at call time `MUST` snapshot that argument at call time rather than relying on the mock's retained reference.

### Compatibility testing
13.2.1 **Ignoring deprecation warnings in test suites** - Development and test configurations `SHOULD` surface relevant deprecation warnings that are hidden by Python's default warning filters.

### Logging ownership
13.3.1 **Libraries configuring the root logger** - Library code `MUST NOT` configure the root logger or install application logging handlers as an import side effect and `SHOULD` log through a named library logger.

### Logging performance
13.4.1 **Eager string formatting in disabled logging calls** - Logging calls whose message construction is materially expensive `SHOULD` pass the format string and arguments separately rather than eagerly constructing the formatted message.

### Object finalization
13.5.1 **Relying on `__del__` for important behavior** - `__del__` `SHOULD NOT` be responsible for correctness-critical cleanup, lock acquisition, or deterministic resource release.


## Object Model and Protocols

### Object finalization
14.1.1 **`weakref.finalize()` callback retaining its object** - A `weakref.finalize()` callback `MUST NOT` directly or indirectly hold a strong reference to the object it is intended to finalize.

### Class layout
14.2.1 **Treating `__slots__` as a transparent memory optimization** - `__slots__` `SHOULD NOT` be introduced as a transparent optimization unless its effects on inheritance, weak references, instance dictionaries, defaults, and object layout are acceptable.

### Enumeration modeling
14.3.1 **Using `IntEnum` when integer interoperability is unnecessary** - New APIs `SHOULD` use `Enum` or `Flag` instead of `IntEnum` when compatibility with integer APIs is not required.

### Operator protocol
14.4.1 **Returning `False` instead of `NotImplemented` for unsupported comparisons** - Custom rich-comparison and numeric methods `MUST` return `NotImplemented` when the operand type is unsupported rather than returning a result that prevents Python's reflected or fallback operation.

### Method resolution
14.5.1 **Non-cooperative superclass calls in multiple inheritance** - A hierarchy designed for cooperative multiple inheritance `MUST` use compatible method signatures and cooperative `super()` calls throughout the participating classes.

### Filesystem portability
14.6.1 **Assuming `getctime()` means creation time everywhere** - `os.path.getctime()` `MUST NOT` be interpreted as a portable file-creation timestamp.


## Filesystem and Performance

### Path construction
15.1.1 **Absolute components resetting `os.path.join()`** - Path components expected to remain relative to a trusted base `MUST` be validated as relative before being passed to `os.path.join()` or an equivalent path join.

### Path canonicalization
15.2.1 **Lexical parent walking without resolving symlinks** - When filesystem ancestry must reflect resolved symlink targets, code `SHOULD` resolve the path before performing lexical parent traversal.

### Filesystem metadata
15.3.1 **Assuming `shutil.copy*` creates a full filesystem clone** - Code requiring specific ownership, ACL, extended-attribute, alternate-stream, or other filesystem metadata preservation `MUST` explicitly preserve or verify that metadata rather than assuming `shutil.copy*` does so.

### Stream buffering
15.4.1 **Reading immediately after `copyfileobj()` without flushing** - A destination written with `shutil.copyfileobj()` `MUST` be flushed or closed before code immediately reads or otherwise depends on the completed buffered output.

### Sequence performance
15.5.1 **Repeated immutable-string concatenation in loops** - Code constructing a string from many pieces `SHOULD` use `str.join()` or an appropriate buffer instead of repeatedly growing an immutable string in a loop.

### Singleton identity
15.6.1 **Comparing with `None` using equality** - Comparisons with `None` `SHOULD` use `is None` or `is not None` rather than equality operators.


## Language Idioms and Runtime Protocols

### Runtime type inspection
16.1.1 **Exact type checks instead of `isinstance()`** - Runtime type checks `SHOULD` use `isinstance()` rather than exact `type(...) is ...` comparisons when valid subclasses are intended to satisfy the check.

### Truth-value idioms
16.2.1 **Comparing sequence length with zero** - Container emptiness checks `SHOULD` use Python truth-value testing rather than comparing `len(container)` with zero.
16.2.2 **Comparing booleans to `True` or `False`** - Boolean conditions `SHOULD` use direct truth-value tests rather than equality comparisons with `True` or `False` unless literal boolean identity is semantically required.

### String idioms
16.3.1 **Prefix and suffix tests through slicing** - String prefix and suffix checks `SHOULD` use `startswith()` and `endswith()` rather than manual slicing.

### Function definition idioms
16.4.1 **Assigning a lambda to a name** - A callable that requires a durable descriptive name `SHOULD` be defined with `def` rather than assigned from a `lambda`.

### Conditional expressions
16.5.1 **Legacy `and/or` conditional expressions** - Conditional value selection `SHOULD` use the conditional expression form and `SHOULD NOT` use the historical `condition and a or b` pattern.

### Tuple syntax
16.6.1 **Forgetting the comma in a one-element tuple** - A one-element tuple `MUST` include a trailing comma.

### Class encapsulation
16.7.1 **Treating double-underscore attributes as private security boundaries** - Double-leading-underscore name mangling `MUST NOT` be relied upon as a security or access-control boundary.

### Collection ordering
16.8.1 **Depending on set iteration order** - Code whose contract requires deterministic set traversal `MUST` explicitly impose an order rather than relying on set iteration order.

### Mapping views
16.9.1 **Comparing `dict.values()` views for content equality** - Code requiring content equality of dictionary values `MUST NOT` rely on equality comparison between `dict.values()` views and `MUST` compare an appropriate materialized or normalized representation.

### Object identity
16.10.1 **Persisting or interpreting `id()` as a permanent object identifier** - `id()` values `MUST NOT` be persisted or used as durable or globally unique object identifiers beyond the lifetime of the referenced object.

### Hash behavior
16.11.1 **Persisting built-in string hashes** - Built-in `hash()` values for strings or bytes `MUST NOT` be persisted when a stable cross-process digest or identifier is required.

### Mutable API conventions
16.12.1 **Chaining mutating methods that return `None`** - In-place mutating methods documented to return `None` `MUST` be treated as mutation statements and `MUST NOT` be chained or consumed as though they return the modified object.

### Iteration idioms
16.13.1 **Manual index loops over sequences** - Sequence iteration `SHOULD` use direct iteration or `enumerate()` rather than `range(len(sequence))` when explicit numeric indexing is not independently required.

### Object construction protocol
16.14.1 **Returning a value from `__init__()`** - `__init__()` `MUST` return `None` and `MUST NOT` return an alternate constructed value.

### Method resolution
16.15.1 **Zero-argument `super()` inside nested functions** - A nested function or generator `MUST NOT` rely on zero-argument `super()` to infer the intended method context; it `MUST` use an explicit form or move the call to the appropriate method scope.
16.15.2 **Subscripting a `super` object** - Code `MUST NOT` use `super()[key]` to invoke inherited subscription behavior and `MUST` call the relevant special method explicitly, such as `super().__getitem__(key)`.

### Runtime introspection
16.16.1 **Directly modifying module `__dict__`** - Code `SHOULD` use normal attribute assignment or supported APIs rather than directly mutating a module's `__dict__` unless low-level symbol-table manipulation is intentionally required.

### Context manager lifecycle
16.17.1 **One-shot generator context-manager instances** - A context-manager instance created by a generator-based `@contextmanager` function `MUST NOT` be entered more than once; a new instance `MUST` be created for each use.

### Type hint runtime boundary
16.18.1 **Assuming `final` is runtime enforcement** - `@final` `MUST NOT` be relied upon to prevent subclassing or overriding at runtime.
16.18.2 **Assuming `NewType` constructs a runtime wrapper object** - `NewType` `MUST NOT` be relied upon for runtime wrapping, conversion, or validation.

### Type hint semantics
16.19.1 **Assuming `@override` changes runtime dispatch** - `@override` `MUST NOT` be relied upon to alter or enforce runtime method dispatch.

### Error-handling style
16.20.1 **Using EAFP as an unconditional rule** - Code `SHOULD` use EAFP where pre-checks would race with or unnecessarily duplicate the operation, but `SHOULD NOT` replace clear race-free precondition checks solely to conform to EAFP.
