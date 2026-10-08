# Python Pitfalls Catalog
_Entry format: <index> **<canonical name>** _(impact: [high|medium|low]; consensus: [high|medium|low])_ - <concise definition>._

## Language Semantics and Object State

### Function state and object lifetime
1.1.1 **Mutable default arguments** _(impact: high; consensus: high)_ - Do not use mutable objects such as `[]` or `{}` as function defaults when a fresh object is intended. Defaults are evaluated once when the function is defined. Prefer `None` or another sentinel and create the object inside the function.

### Runtime validation
1.2.1 **Assertions for required runtime checks** _(impact: high; consensus: high)_ - Do not use `assert` for input validation, authorization, security checks, or other behavior required for correctness. Use explicit condition checks and raise an appropriate exception.

### Exception handling
1.3.1 **Bare or overly broad exception handling** _(impact: high; consensus: high)_ - Catch the narrowest exception types that the code can meaningfully handle. Avoid bare `except:` except for exceptional cases where `BaseException` subclasses such as `KeyboardInterrupt` and `SystemExit` truly need handling.

### Exception control flow
1.4.1 **Control flow in `finally` suppressing exceptions** _(impact: high; consensus: high)_ - Avoid `return`, `break`, or `continue` that exits a `finally` block while an exception is active. Python 3.14 warns about such constructs.

### Resource lifecycle
1.5.1 **Non-deterministic resource cleanup** _(impact: high; consensus: high)_ - Use context managers or explicit `close()` operations for files, sockets, locks, database resources, and similar objects rather than relying on garbage collection or `__del__`.

### Hashing and equality
1.6.1 **Mutable hash keys** _(impact: high; consensus: high)_ - Objects whose equality-relevant state can change should normally not be hashable. In particular, do not implement a hash that changes while the object is stored in a dict or set.


## Security and Trust Boundaries

### Serialization security
2.1.1 **Unpickling untrusted data** _(impact: high; consensus: high)_ - Never load untrusted or unauthenticated data with `pickle`. Use a non-executable serialization format when the input crosses a trust boundary.
2.1.2 **Opening untrusted `shelve` databases** _(impact: high; consensus: high)_ - Do not open a `shelve` database obtained from an untrusted source.
2.1.3 **Unmarshalling untrusted data** _(impact: high; consensus: high)_ - Do not use `marshal` as a general-purpose or untrusted serialization format.

### Dynamic execution security
2.2.1 **`eval()` and `exec()` on untrusted input** _(impact: high; consensus: high)_ - Never pass untrusted strings or code objects to `eval()` or `exec()`. Prefer parsing, explicit dispatch, or purpose-specific data formats.

### Parser resource safety
2.3.1 **Treating `ast.literal_eval()` as safe for hostile input** _(impact: high; consensus: high)_ - `ast.literal_eval()` avoids arbitrary code execution but should still not be used indiscriminately on hostile input without resource controls.

### Process security
2.4.1 **Shell injection through `subprocess`** _(impact: high; consensus: high)_ - Prefer `subprocess` with `shell=False` and pass arguments as a sequence. Use `shell=True` only when shell behavior is actually required and carefully quote untrusted data.

### Process I/O
2.5.1 **Waiting on subprocesses with unread pipes** _(impact: high; consensus: high)_ - Do not call `Popen.wait()` while a child may fill `stdout=PIPE` or `stderr=PIPE`. Use `communicate()` or otherwise continuously drain the pipes.

### Process concurrency
2.6.1 **`preexec_fn` in threaded programs** _(impact: high; consensus: high)_ - Do not use `Popen(preexec_fn=...)` in a process containing threads. Prefer dedicated `Popen` parameters such as `env`, `start_new_session`, and `process_group`.

### Process security
2.7.1 **Incomplete privilege dropping with `subprocess`** _(impact: high; consensus: high)_ - On POSIX, do not assume `Popen(user=...)` alone removes supplementary groups. When dropping privileges requires it, explicitly set `extra_groups=()`.

### Cryptographic randomness
2.8.1 **`random` for secrets** _(impact: high; consensus: high)_ - Use `secrets`, not the default `random` module, for authentication tokens, password-reset URLs, passwords, or other security-sensitive randomness.

### Password security
2.9.1 **General-purpose hashes for passwords** _(impact: high; consensus: high)_ - Do not store passwords using a direct fast hash such as `sha256(password)`. Use a password-oriented, salted, deliberately expensive derivation mechanism.

### Cryptographic comparison
2.10.1 **Ordinary equality for secret digests** _(impact: high; consensus: high)_ - When verifying an externally supplied HMAC or similar secret-dependent digest, use `hmac.compare_digest()` or `secrets.compare_digest()` rather than `==`.

### Filesystem security
2.11.1 **Insecure temporary filenames with `mktemp()`** _(impact: high; consensus: high)_ - Do not use `tempfile.mktemp()` to create security-sensitive temporary files. Use `TemporaryFile`, `NamedTemporaryFile`, `mkstemp`, or `TemporaryDirectory`.

### Archive extraction security
2.12.1 **Blind extraction of untrusted tar archives** _(impact: high; consensus: high)_ - Do not blindly extract untrusted tar archives. Use appropriate extraction filters, inspect archive contents, constrain destination handling, and apply resource limits as necessary.

### Parser security
2.13.1 **Assuming standard XML parsers are hardened against hostile documents** _(impact: high; consensus: high)_ - Consult the documented XML vulnerabilities before processing attacker-controlled XML and use a hardened approach appropriate to the threat model.

### URL security
2.14.1 **Attacker-controlled second argument to `urljoin()`** _(impact: high; consensus: high)_ - Do not use `urljoin(base, attacker_value)` and assume the result remains under `base`. Validate or constrain the second value first.
2.14.2 **Treating `urlparse()` as URL validation** _(impact: high; consensus: high)_ - Treat `urlparse()` and `urlsplit()` as parsers rather than validators. Perform explicit scheme, hostname, port, and other policy checks before using parsed values for security decisions.

### Database security
2.15.1 **SQL construction with Python string formatting** _(impact: high; consensus: high)_ - Pass SQL values through database parameter placeholders rather than f-strings, concatenation, `%`, or `.format()`.

### Database concurrency
2.16.1 **Unsynchronized shared SQLite connections** _(impact: high; consensus: high)_ - If SQLite's `check_same_thread=False` is used, serialize writes yourself rather than treating the connection as automatically safe for unrestricted concurrent access.

### Filesystem security
2.17.1 **Permission pre-checks with `os.access()`** _(impact: high; consensus: high)_ - Do not normally check access with `os.access()` and then separately open the file. Attempt the operation and handle failure instead.
2.17.2 **Using `commonprefix()` for path containment** _(impact: high; consensus: high)_ - Do not use `os.path.commonprefix()` to decide whether one filesystem path is contained by another. Use path-aware canonicalization and `commonpath()` or equivalent containment logic.

### Archive extraction security
2.18.1 **Assuming `zipfile.Path` prevents path traversal** _(impact: high; consensus: high)_ - When using `zipfile.Path` on untrusted archives, validate filenames and destination paths yourself.

### Packaging security
2.19.1 **Private package discovery with `--extra-index-url`** _(impact: high; consensus: high)_ - Do not rely on `pip --extra-index-url` to securely combine a private package repository with a public index for uniquely named private packages.
2.19.2 **Assuming ordinary pip installs provide strong supply-chain integrity** _(impact: high; consensus: high)_ - For environments requiring strong repeatability and integrity, pin dependencies and use pip hash checking; where the threat model requires avoiding arbitrary build execution, restrict installation to trusted binary distributions.

### Transport security
2.20.1 **TLS contexts without certificate and hostname verification** _(impact: high; consensus: high)_ - For ordinary TLS clients, prefer `ssl.create_default_context()` or `PROTOCOL_TLS_CLIENT` rather than manually constructing a context that leaves certificate or hostname verification disabled.

### Network service security
2.21.1 **`http.server` in production** _(impact: high; consensus: high)_ - Do not use `http.server` as a production HTTP server.

### Thread concurrency
2.22.1 **Treating compound shared-state operations as atomic** _(impact: high; consensus: high)_ - Use synchronization for shared invariants and read-modify-write sequences instead of assuming that individual list or dict operations make a larger operation atomic.


## Concurrency and Process Lifecycle

### Runtime concurrency model
3.1.1 **Relying on the GIL for thread safety** _(impact: high; consensus: high)_ - Do not design correctness around the assumption that CPython's GIL implicitly serializes shared mutable state. Use explicit synchronization or ownership boundaries.

### Thread lifecycle
3.2.1 **Daemon threads for work requiring cleanup** _(impact: high; consensus: high)_ - Do not put essential cleanup, transactional, or persistent work exclusively in daemon threads. Prefer non-daemon threads with an explicit shutdown signal and join.

### Process concurrency
3.3.1 **Forking a multithreaded process** _(impact: high; consensus: high)_ - Avoid `os.fork()` from a multithreaded Python process and do not assume the historical `fork` multiprocessing behavior is safe.

### Process startup
3.4.1 **Missing multiprocessing main guard** _(impact: high; consensus: high)_ - Protect process-creating entry points with `if __name__ == "__main__":`, particularly when spawn or forkserver is used.

### Process serialization
3.5.1 **Non-importable multiprocessing targets** _(impact: high; consensus: high)_ - With spawn and forkserver, use picklable arguments and ordinarily define worker functions at importable module scope rather than relying on lambdas, REPL definitions, or local functions.

### Process lifecycle
3.6.1 **Force-terminating processes that hold shared resources** _(impact: high; consensus: high)_ - Prefer cooperative process shutdown when a worker uses queues, pipes, locks, semaphores, or other shared state. Reserve `terminate()` for cases where those resources are not at risk.

### Process IPC
3.7.1 **Joining a multiprocessing producer before draining its queue** _(impact: high; consensus: high)_ - Ensure queued data is consumed before joining a process that has written substantial data to a multiprocessing queue.

### Executor concurrency
3.8.1 **Executor tasks waiting on the same exhausted executor** _(impact: high; consensus: high)_ - Do not have work running in a bounded executor synchronously wait for other work that can only run in that same exhausted executor.

### Asyncio scheduling
3.9.1 **Blocking the asyncio event loop** _(impact: high; consensus: high)_ - Do not perform long blocking I/O or CPU-bound synchronous work directly inside event-loop callbacks and coroutines. Use asynchronous APIs, `to_thread()` for appropriate blocking I/O, or process/interpreter execution for CPU-heavy work.

### Asyncio execution
3.10.1 **Calling a coroutine without awaiting or scheduling it** _(impact: high; consensus: high)_ - Await coroutine objects or explicitly schedule them as tasks. Merely calling an `async def` function does not execute its body.

### Asyncio cancellation
3.11.1 **Swallowing `CancelledError`** _(impact: high; consensus: high)_ - If cleanup code catches `asyncio.CancelledError`, normally re-raise it when cleanup finishes unless cancellation is intentionally and completely suppressed.

### Asyncio task lifecycle
3.12.1 **Losing references to background asyncio tasks** _(impact: high; consensus: high)_ - Keep strong references to independently scheduled tasks, or preferably use `TaskGroup` when tasks belong to one operation.

### Asyncio thread interaction
3.13.1 **Calling non-thread-safe asyncio APIs from worker threads** _(impact: high; consensus: high)_ - From another OS thread, use `loop.call_soon_threadsafe()` or `asyncio.run_coroutine_threadsafe()` rather than ordinary event-loop methods.

### Context-local state
3.14.1 **`threading.local()` for asyncio-local state** _(impact: high; consensus: high)_ - Use `ContextVar` for logical context that must remain isolated across concurrent asynchronous tasks rather than storing such state in `threading.local()`.

### Signal handling
3.15.1 **Lock acquisition inside signal handlers** _(impact: high; consensus: high)_ - Do not use ordinary synchronization locks from Python signal handlers. Also remember that Python signal handlers execute in the main Python thread.

### Process termination
3.16.1 **Using `os._exit()` as an ordinary exit mechanism** _(impact: high; consensus: high)_ - Use `sys.exit()` for normal Python termination. Reserve `os._exit()` primarily for specialized post-fork child-process situations.

### Thread termination
3.17.1 **Assuming `sys.exit()` from a worker thread exits the process** _(impact: high; consensus: high)_ - Do not use `sys.exit()` in a worker thread as a process-wide shutdown mechanism. Coordinate shutdown with the main thread instead.

### Type hint runtime boundary
3.18.1 **Treating type annotations as runtime validation** _(impact: high; consensus: high)_ - Do not assume annotated function arguments or assignments are runtime checked merely because type hints are present. Add explicit validation where runtime guarantees are required.


## Type System Boundaries

### Type hint runtime boundary
4.1.1 **Treating `typing.cast()` as a runtime cast** _(impact: high; consensus: high)_ - Use `cast()` only to communicate information to a static type checker, not to validate or convert runtime values.

### Static type safety
4.2.1 **Unnecessary use of `Any`** _(impact: high; consensus: high)_ - Use `Any` deliberately when type checking truly must be bypassed. Prefer `object`, protocols, unions, generics, or `unknown`-style narrowing patterns when operations should remain checked.

### Environment isolation
4.3.1 **Installing project dependencies into the system Python** _(impact: high; consensus: high)_ - Use virtual environments for project-specific third-party dependencies and respect externally managed Python installations rather than routinely forcing pip modifications into the system interpreter.


## Environment and Packaging Foundations

### Build isolation
5.1.1 **Undeclared build dependencies** _(impact: high; consensus: high)_ - Declare the build backend and all required build-time dependencies in `[build-system]` rather than depending on packages that happen to exist in the developer's environment.

### Packaging supply chain
5.2.1 **Assuming an import name identifies the package to install** _(impact: high; consensus: high)_ - Do not automatically derive `pip install <name>` from an unknown `import <name>`. Verify the intended distribution package.

### Iterator cardinality
5.3.1 **Silent truncation with `zip()`** _(impact: high; consensus: high)_ - When corresponding iterables are required to have the same length, use `zip(..., strict=True)` instead of ordinary `zip()`.


## Collections, Iteration, and Expressions

### Object aliasing
6.1.1 **Assignment does not copy objects** _(impact: medium; consensus: high)_ - Remember that `b = a` creates another reference to the same object. Explicitly copy when independent mutable state is required.

### Object copying
6.2.1 **Assuming a shallow copy duplicates nested state** _(impact: medium; consensus: high)_ - Use a shallow copy only when sharing nested objects is acceptable. Consider deliberate reconstruction or `deepcopy()` when nested independence is required.

### Class state
6.3.1 **Mutable class variables used as per-instance state** _(impact: medium; consensus: high)_ - Put mutable data intended to belong to each instance on `self` during initialization rather than defining one mutable object as a class variable.

### Container aliasing
6.4.1 **Nested mutable sequences created with repetition** _(impact: medium; consensus: high)_ - Do not create independent nested mutable containers with expressions such as `[[None] * width] * height`. Use a comprehension that constructs each inner object separately.

### Dataclass state
6.5.1 **Mutable dataclass defaults** _(impact: medium; consensus: high)_ - For per-instance mutable dataclass fields, use `field(default_factory=list)` or another factory rather than a shared mutable default.

### Closures and name binding
6.6.1 **Late-bound closures in loops** _(impact: medium; consensus: high)_ - When callbacks created in a loop should capture the current loop value, bind it explicitly, such as through a default parameter or helper scope.

### Name binding and scope
6.7.1 **Assignment unexpectedly making a variable local** _(impact: medium; consensus: high)_ - Remember that assigning to a name anywhere in a function normally makes it local throughout that function unless declared `global` or `nonlocal`.

### Augmented assignment semantics
6.8.1 **Augmented assignment can mutate before failing** _(impact: medium; consensus: high)_ - Be cautious with expressions such as `tuple_obj[index] += mutable_value`. Separate mutation and assignment when the target is immutable or behavior matters.

### Mapping construction
6.9.1 **Mutable values with `dict.fromkeys()`** _(impact: medium; consensus: high)_ - Do not use `dict.fromkeys(keys, mutable_object)` when each key needs independent mutable state. Use a comprehension.

### Mapping semantics
6.10.1 **`defaultdict.get()` bypasses the factory** _(impact: medium; consensus: high)_ - Do not expect `defaultdict.get(key)` to create a missing entry. Use indexing when invoking the factory is intended.

### Mapping iteration
6.11.1 **Mutating a dict while iterating it** _(impact: medium; consensus: high)_ - Do not add or remove dictionary entries while directly iterating the dictionary or its dynamic views. Iterate a copy or construct the desired result separately.
6.11.2 **Treating dictionary views as snapshots** _(impact: medium; consensus: high)_ - Materialize `list(d.keys())`, `list(d.items())`, or similar when a snapshot is required rather than storing a view and assuming it is frozen.

### Iterator grouping
6.12.1 **`groupby()` without grouping consecutive equal keys** _(impact: medium; consensus: high)_ - Use `itertools.groupby()` only when equal-key elements are already consecutive, commonly by sorting first when global grouping is intended.

### Iterator lifetime
6.13.1 **Saving `groupby()` group iterators for later** _(impact: medium; consensus: high)_ - Materialize a `groupby()` subgroup if it must survive advancing the outer iterator.

### Iterator buffering
6.14.1 **Unbounded buffering with `itertools.tee()`** _(impact: medium; consensus: high)_ - Do not assume `tee()` duplicates an iterator for free. If one branch may advance far ahead of another, materializing the data may be more appropriate.

### Generator control flow
6.15.1 **Raising `StopIteration` inside generators** _(impact: medium; consensus: high)_ - End a generator with `return` rather than deliberately raising `StopIteration` from generator code.

### Comprehension scope
6.16.1 **Assignment-expression targets leaking from comprehensions** _(impact: medium; consensus: high)_ - Do not assume a walrus target inside a comprehension is scoped like the comprehension's loop variable. Choose names with the containing-scope binding in mind.

### Pattern matching semantics
6.17.1 **Bare names in structural pattern matching** _(impact: medium; consensus: high)_ - In `case` patterns, do not write a bare identifier when intending to compare against an existing constant. Use a literal or qualified value pattern.

### Identity and equality
6.18.1 **`is` for value equality** _(impact: medium; consensus: high)_ - Use `==` for value equality and reserve `is` for identity checks such as `x is None`.

### Numeric type relationships
6.19.1 **Boolean and numeric keys colliding** _(impact: medium; consensus: high)_ - Do not use values such as `True`, `1`, and `1.0` as supposedly distinct dict or set keys when their semantic distinction matters.

### Boolean expression semantics
6.20.1 **Assuming `and` and `or` return booleans** _(impact: medium; consensus: high)_ - Remember that `and` and `or` return one of their operands. Avoid `value or default` when valid falsey values such as `0`, `""`, or `[]` must be preserved.

### Floating-point semantics
6.21.1 **Exact equality for computed floating-point values** _(impact: medium; consensus: high)_ - When values are mathematically approximate, compare computed floats using a tolerance appropriate to the domain, commonly `math.isclose()`, rather than expecting exact decimal equality.


## Numerics and Time

### Floating-point comparison
7.1.1 **`math.isclose()` against zero without `abs_tol`** _(impact: medium; consensus: high)_ - When checking whether a value is sufficiently close to zero, provide a meaningful nonzero `abs_tol` rather than relying only on relative tolerance.

### Decimal arithmetic
7.2.1 **Constructing exact decimals from binary floats** _(impact: medium; consensus: high)_ - When the intended value is a decimal literal such as money, construct `Decimal` from a string or other exact decimal representation rather than an already rounded binary float.

### Duration semantics
7.3.1 **Using `timedelta.seconds` for total duration** _(impact: medium; consensus: high)_ - Use `timedelta.total_seconds()` when the total elapsed seconds are required rather than the `.seconds` component.

### Datetime semantics
7.4.1 **Naive UTC datetimes** _(impact: medium; consensus: high)_ - Prefer timezone-aware UTC values such as `datetime.now(UTC)` and `datetime.fromtimestamp(ts, UTC)` rather than `utcnow()` or `utcfromtimestamp()`.
7.4.2 **Calling `timestamp()` on naive UTC** _(impact: medium; consensus: high)_ - Attach or retain the correct timezone before converting a datetime to a timestamp rather than passing a naive UTC value to `.timestamp()`.

### Clock semantics
7.5.1 **Wall-clock time for elapsed durations** _(impact: medium; consensus: high)_ - Measure elapsed time and deadlines using `time.monotonic()` or `time.perf_counter()` rather than subtracting `time.time()` values.

### Text encoding
7.6.1 **Implicit text-file encoding** _(impact: medium; consensus: high)_ - Specify the encoding for files whose format has a defined encoding, typically UTF-8, instead of relying on the interpreter or platform default.


## Text, Data Formats, and Standard Collections

### Text encoding
8.1.1 **Silently ignoring encoding errors** _(impact: medium; consensus: high)_ - Avoid `errors="ignore"` unless deliberate irreversible data loss is acceptable. Prefer strict handling or an error strategy such as `surrogateescape` when round-tripping arbitrary bytes is required.

### CSV I/O
8.2.1 **Opening CSV files without `newline=""`** _(impact: medium; consensus: high)_ - Open files passed to `csv.reader` or `csv.writer` with `newline=""`.

### CSV data fidelity
8.3.1 **Serializing `None` through `csv.writer`** _(impact: medium; consensus: high)_ - Do not rely on the CSV writer to preserve the distinction between `None` and an empty string. Encode nullable values explicitly when round-trip fidelity matters.

### JSON framing
8.4.1 **Repeated `json.dump()` calls as one JSON document** _(impact: medium; consensus: high)_ - Do not append multiple independent `json.dump()` outputs to one stream and expect the result to be a valid single JSON document. Use an explicit framing format or outer collection.

### JSON interoperability
8.5.1 **Non-standard NaN and Infinity in JSON** _(impact: medium; consensus: high)_ - Use `allow_nan=False` when output must conform strictly to the JSON specification.

### JSON data fidelity
8.6.1 **Duplicate JSON object names** _(impact: medium; consensus: high)_ - Do not assume the default JSON decoder rejects duplicate object member names. Use `object_pairs_hook` or external validation when duplicates must be detected.
8.6.2 **Assuming JSON preserves non-string dict keys** _(impact: medium; consensus: high)_ - Encode non-string mapping keys explicitly if their types must survive a JSON round trip.

### String API semantics
8.7.1 **Using `strip()` to remove a literal prefix or suffix** _(impact: medium; consensus: high)_ - Use `removeprefix()` or `removesuffix()` for literal affixes rather than `lstrip()`, `rstrip()`, or `strip(chars)`.

### Regular-expression literals
8.8.1 **Regular expressions without raw strings** _(impact: medium; consensus: high)_ - Prefer raw string literals such as `r"\d+\."` for regular-expression patterns containing backslashes.

### Regular-expression matching
8.9.1 **Confusing `re.match()`, `search()`, and `fullmatch()`** _(impact: medium; consensus: high)_ - Use `search()` for a match anywhere, `match()` for a match beginning at position zero, and `fullmatch()` when the entire string must satisfy the pattern.

### Priority queues
8.10.1 **Heap entries without a tie-breaker** _(impact: medium; consensus: high)_ - When heap entries contain `(priority, task)` and equal priorities are possible, add a unique monotonic counter or comparable wrapper unless tasks themselves are safely orderable.

### Command-line parsing
8.11.1 **`argparse` with `type=bool`** _(impact: medium; consensus: high)_ - Do not parse boolean command-line options using `type=bool`. Use actions such as `store_true`, `store_false`, `BooleanOptionalAction`, or an explicit text parser.

### Collection semantics
8.12.1 **`deque.extendleft()` reversing input order** _(impact: medium; consensus: high)_ - Account for reversal when using `extendleft()`, or reverse the input first when preserving its order is required.
8.12.2 **Treating `Counter` as a strictly positive multiset** _(impact: medium; consensus: high)_ - Remember that `Counter` can retain zero and negative counts and that setting a count to zero does not remove the key. Delete entries or normalize when positive-only semantics are required.

### Caching semantics
8.13.1 **Caching generators, coroutines, or side-effectful functions** _(impact: medium; consensus: high)_ - Use `lru_cache` and `cache` for reusable computed values, not calls whose identity, side effects, freshness, generator iteration state, or coroutine execution matters.

### Cache lifetime
8.14.1 **`lru_cache` on instance methods retaining instances** _(impact: medium; consensus: high)_ - Be cautious caching instance methods on large or short-lived object populations. Bound method calls include `self` in the cache key.

### Cache concurrency
8.15.1 **Assuming `cached_property` computes exactly once under concurrency** _(impact: medium; consensus: high)_ - If duplicate execution would be unsafe, explicitly synchronize a `cached_property` computation rather than relying on the descriptor to provide once-only execution.
8.15.2 **Assuming `lru_cache` suppresses duplicate concurrent calls** _(impact: medium; consensus: high)_ - Do not use `lru_cache` itself as a single-flight mechanism when duplicate concurrent execution is unacceptable.

### Import namespace management
8.16.1 **Wildcard imports** _(impact: medium; consensus: high)_ - Avoid `from module import *` outside narrowly controlled uses. Import explicit names or the module itself.


## Imports and Module Execution

### Import initialization
9.1.1 **`from module import name` in circular imports** _(impact: medium; consensus: high)_ - Avoid circular imports where partially initialized modules must satisfy `from module import name`. Refactor dependencies or, where appropriate, import the module and defer attribute access.

### Import caching
9.2.1 **Reloading modules after `from ... import ...`** _(impact: medium; consensus: high)_ - Do not expect `importlib.reload(module)` to update names previously copied into another namespace with `from module import name`. Use module-qualified references or re-execute the import.

### Module execution
9.3.1 **Assuming imports are passive declarations** _(impact: medium; consensus: high)_ - Keep unavoidable import-time side effects controlled and remember that ordinary module top-level code executes on the first import in an interpreter.

### Concurrency performance
9.4.1 **Threads as the default solution for CPU-bound Python code** _(impact: medium; consensus: high)_ - On ordinary GIL-enabled CPython, prefer processes, subinterpreters where applicable, native code that releases the GIL, or another suitable strategy for parallel CPU-bound Python bytecode.


## Concurrency, Runtime State, and Warnings

### Structured concurrency
10.1.1 **Assuming `asyncio.gather()` cancels siblings on first failure** _(impact: medium; consensus: high)_ - Use `TaskGroup` when one child failure should cancel the remaining child tasks. Do not assume default `gather()` provides those failure semantics.

### Warning-state concurrency
10.2.1 **Concurrent use of `warnings.catch_warnings()` without context-aware warnings** _(impact: medium; consensus: high)_ - In concurrent code, account for `sys.flags.context_aware_warnings`; without it, simultaneous `catch_warnings()` use is not concurrency-safe.

### Locale state
10.3.1 **Changing process locale in concurrent code** _(impact: medium; consensus: high)_ - Avoid repeated `locale.setlocale()` changes in multithreaded code and prefer designs that do not mutate the process-wide locale during normal operation.

### Environment portability
10.4.1 **Moving or copying virtual environments** _(impact: medium; consensus: high)_ - Recreate virtual environments at their destination rather than treating an existing environment directory as portable.


## Packaging and Distribution Practices

### Package layout
11.1.1 **Flat-layout imports hiding packaging errors** _(impact: medium; consensus: high)_ - Consider `src/` layout when accidental imports directly from the working tree could hide missing package data, import configuration, or installation errors.

### Packaging verification
11.2.1 **Testing only editable installs** _(impact: medium; consensus: high)_ - Do not rely solely on editable installation behavior when validating a distributable project. Also test a normal built and installed distribution.

### Packaging workflow
11.3.1 **Direct `setup.py` commands** _(impact: medium; consensus: high)_ - Do not run commands such as `python setup.py install`, `develop`, or `sdist` as the normal modern workflow. Use standards-based frontends such as `pip` and `build`.

### Dependency specification
11.4.1 **Treating requirements files as project dependency metadata** _(impact: medium; consensus: high)_ - Declare the dependencies needed by the distributable project in project metadata and use requirements-style files for describing particular environments or deployment sets.

### Dependency reproducibility
11.5.1 **Treating `pip freeze` as a lockfile solver** _(impact: medium; consensus: high)_ - Use `pip freeze` as a report of an environment's installed state, not as proof that a dependency set was independently solved or securely locked.

### Static type variance
11.6.1 **Assuming mutable generic containers are covariant** _(impact: medium; consensus: high)_ - Do not treat `list[Derived]` as `list[Base]`. Use a read-only abstraction such as `Sequence[Base]` where covariance is actually safe.


## Static Typing and Annotation Introspection

### Runtime structural typing
12.1.1 **Treating `@runtime_checkable Protocol` as runtime type validation** _(impact: medium; consensus: high)_ - Use runtime-checkable protocols only for shallow structural presence checks, not validation of complete method signatures or annotated types.

### Type hint runtime boundary
12.2.1 **Treating `TypedDict` as a runtime record type** _(impact: medium; consensus: high)_ - Do not expect `TypedDict` construction to validate keys or values at runtime. Add actual validation when external data must satisfy a schema.

### Annotation introspection
12.3.1 **Reading annotations directly from `__annotations__`** _(impact: medium; consensus: high)_ - For runtime annotation introspection, use `annotationlib.get_annotations()` on Python 3.14+ or the supported `inspect` helper rather than manually interpreting `__annotations__`.

### Annotation introspection security
12.4.1 **Evaluating string annotations unnecessarily** _(impact: medium; consensus: high)_ - Avoid enabling annotation string evaluation unless actual Python values are required. Prefer string or forward-reference formats for introspection where possible.

### Test mocking
12.5.1 **Patching where an object is defined rather than looked up** _(impact: medium; consensus: high)_ - With `unittest.mock.patch`, patch the name in the namespace where the code under test looks it up, not necessarily the module where the original object was defined.


## Testing, Compatibility, and Logging

### Test mocking
13.1.1 **Unconstrained mocks masking API mistakes** _(impact: medium; consensus: high)_ - Use `spec`, `spec_set`, or `autospec` when a mock should accurately model a real API, and use `create=True` only deliberately.
13.1.2 **Inspecting mutated mock arguments after the call** _(impact: medium; consensus: high)_ - If a test must assert the state of mutable arguments at call time, copy them in a side effect or otherwise capture their original state.

### Compatibility testing
13.2.1 **Ignoring deprecation warnings in test suites** _(impact: medium; consensus: high)_ - Configure development and test runs to surface relevant `DeprecationWarning` and other normally hidden warnings.

### Logging ownership
13.3.1 **Libraries configuring the root logger** _(impact: medium; consensus: high)_ - Library code should log through named loggers, normally based on `__name__`, and should not configure the root logger or install application handlers behind the user's back.

### Logging performance
13.4.1 **Eager string formatting in disabled logging calls** _(impact: medium; consensus: high)_ - When formatting work is material, pass the format string and arguments separately, such as `logger.debug("value=%s", value)`, rather than eagerly constructing the final message.

### Object finalization
13.5.1 **Relying on `__del__` for important behavior** _(impact: medium; consensus: high)_ - Keep `__del__` minimal and avoid depending on it for correctness, lock acquisition, or deterministic resource release.


## Object Model and Protocols

### Object finalization
14.1.1 **`weakref.finalize()` callback retaining its object** _(impact: medium; consensus: high)_ - Ensure a `weakref.finalize()` callback does not directly or indirectly retain the object being finalized, especially through a bound method.

### Class layout
14.2.1 **Treating `__slots__` as a transparent memory optimization** _(impact: medium; consensus: high)_ - Use `__slots__` only after accounting for inheritance, weak references, instance dictionaries, class defaults, and layout restrictions.

### Enumeration modeling
14.3.1 **Using `IntEnum` when integer interoperability is unnecessary** _(impact: medium; consensus: high)_ - Prefer `Enum` or `Flag` for new APIs unless compatibility with integer APIs is actually required.

### Operator protocol
14.4.1 **Returning `False` instead of `NotImplemented` for unsupported comparisons** _(impact: medium; consensus: high)_ - Custom rich comparison and numeric methods should return `NotImplemented` when the operand type is unsupported.

### Method resolution
14.5.1 **Non-cooperative superclass calls in multiple inheritance** _(impact: medium; consensus: high)_ - In classes designed for cooperative multiple inheritance, use compatible method signatures and `super()` throughout the cooperating hierarchy rather than hard-coding a particular parent call.

### Filesystem portability
14.6.1 **Assuming `getctime()` means creation time everywhere** _(impact: medium; consensus: high)_ - Do not treat `os.path.getctime()` as a portable file-creation timestamp.


## Filesystem and Performance

### Path construction
15.1.1 **Absolute components resetting `os.path.join()`** _(impact: medium; consensus: high)_ - Validate path components when joining untrusted or assumed-relative values. Do not assume appending an absolute component keeps the preceding base path.

### Path canonicalization
15.2.1 **Lexical parent walking without resolving symlinks** _(impact: medium; consensus: high)_ - When traversing upward through an arbitrary filesystem path and symlink identity matters, resolve the path before performing lexical parent operations.

### Filesystem metadata
15.3.1 **Assuming `shutil.copy*` creates a full filesystem clone** _(impact: medium; consensus: high)_ - Do not assume ordinary `shutil` copy operations preserve all ownership, ACL, resource-fork, alternate-stream, and extended metadata.

### Stream buffering
15.4.1 **Reading immediately after `copyfileobj()` without flushing** _(impact: medium; consensus: high)_ - Flush or close the destination before immediately consuming data written through `shutil.copyfileobj()`.

### Sequence performance
15.5.1 **Repeated immutable-string concatenation in loops** _(impact: medium; consensus: high)_ - Prefer `str.join()` or an appropriate buffer when constructing a string from many pieces instead of repeatedly growing an immutable string.

### Singleton identity
15.6.1 **Comparing with `None` using equality** _(impact: low; consensus: high)_ - Prefer `x is None` and `x is not None` rather than equality comparisons.


## Language Idioms and Runtime Protocols

### Runtime type inspection
16.1.1 **Exact type checks instead of `isinstance()`** _(impact: low; consensus: high)_ - Prefer `isinstance(obj, Type)` to `type(obj) is Type` when subclasses should satisfy the interface.

### Truth-value idioms
16.2.1 **Comparing sequence length with zero** _(impact: low; consensus: high)_ - Prefer `if sequence:` or `if not sequence:` when testing emptiness rather than explicitly comparing `len(sequence)` with zero.
16.2.2 **Comparing booleans to `True` or `False`** _(impact: low; consensus: high)_ - Prefer direct truth-value tests when actual boolean identity is not specifically required rather than `x == True` or `x == False`.

### String idioms
16.3.1 **Prefix and suffix tests through slicing** _(impact: low; consensus: high)_ - Prefer `startswith()` and `endswith()` over manual slices when testing a prefix or suffix.

### Function definition idioms
16.4.1 **Assigning a lambda to a name** _(impact: low; consensus: high)_ - When a callable needs a durable name, prefer `def` over assigning a `lambda` expression.

### Conditional expressions
16.5.1 **Legacy `and/or` conditional expressions** _(impact: low; consensus: high)_ - Use `a if condition else b` rather than the historical `condition and a or b` idiom.

### Tuple syntax
16.6.1 **Forgetting the comma in a one-element tuple** _(impact: low; consensus: high)_ - Write `(value,)` for a one-element tuple. Parentheses alone do not make a tuple.

### Class encapsulation
16.7.1 **Treating double-underscore attributes as private security boundaries** _(impact: low; consensus: high)_ - Use double-leading-underscore name mangling primarily to avoid accidental subclass name collisions, not to enforce privacy.

### Collection ordering
16.8.1 **Depending on set iteration order** _(impact: low; consensus: high)_ - Explicitly sort or otherwise impose order when deterministic set traversal is part of a contract.

### Mapping views
16.9.1 **Comparing `dict.values()` views for content equality** _(impact: low; consensus: high)_ - Convert or compare values using a representation appropriate to the desired semantics rather than relying on `d.values() == other.values()`.

### Object identity
16.10.1 **Persisting or interpreting `id()` as a permanent object identifier** _(impact: low; consensus: high)_ - Use `id()` only for identity during an object's lifetime, not as a durable or globally unique identifier.

### Hash behavior
16.11.1 **Persisting built-in string hashes** _(impact: low; consensus: high)_ - Do not persist `hash(str_value)` or `hash(bytes_value)` when a stable cross-process digest is required. Use an explicit stable hash function instead.

### Mutable API conventions
16.12.1 **Chaining mutating methods that return `None`** _(impact: low; consensus: high)_ - Do not assume in-place mutators such as `list.sort()` return the modified object. Perform the mutation separately.

### Iteration idioms
16.13.1 **Manual index loops over sequences** _(impact: low; consensus: high)_ - Prefer direct iteration or `enumerate(sequence)` over `for i in range(len(sequence))` when both the index and element are required.

### Object construction protocol
16.14.1 **Returning a value from `__init__()`** _(impact: low; consensus: high)_ - `__init__()` must initialize the instance and return `None`; use `__new__()` or another construction mechanism when object creation itself must be customized.

### Method resolution
16.15.1 **Zero-argument `super()` inside nested functions** _(impact: low; consensus: high)_ - Do not expect zero-argument `super()` to infer the intended method arguments inside a nested function or generator expression. Use an explicit form or restructure the call.
16.15.2 **Subscripting a `super` object** _(impact: low; consensus: high)_ - Use explicit attribute lookup such as `super().__getitem__(key)` rather than `super()[key]`.

### Runtime introspection
16.16.1 **Directly modifying module `__dict__`** _(impact: low; consensus: high)_ - Prefer ordinary attribute assignment and supported APIs over direct mutation of a module's `__dict__` unless low-level introspection is intentionally required.

### Context manager lifecycle
16.17.1 **One-shot generator context-manager instances** _(impact: low; consensus: high)_ - Do not attempt to enter the same context-manager object returned by `@contextmanager` repeatedly. Call the decorated function again to create a new instance.

### Type hint runtime boundary
16.18.1 **Assuming `final` is runtime enforcement** _(impact: low; consensus: high)_ - Treat `@final` primarily as a static type-checker contract rather than a runtime mechanism preventing inheritance or overriding.
16.18.2 **Assuming `NewType` constructs a runtime wrapper object** _(impact: low; consensus: high)_ - Use `NewType` to create a static distinction, not for runtime validation or wrapping.

### Type hint semantics
16.19.1 **Assuming `@override` changes runtime dispatch** _(impact: low; consensus: high)_ - Use `@override` to let static checking detect misspelled or nonexistent base methods, not as a runtime override mechanism.

### Error-handling style
16.20.1 **Using EAFP as an unconditional rule** _(impact: low; consensus: medium)_ - Python commonly favors EAFP, especially where a check-then-act sequence would introduce races, but do not mechanically replace every precondition check with exceptions. Choose based on API semantics, readability, cost, and concurrency requirements.
