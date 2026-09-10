#### User said:

Research as comprehensively as practical for Python-specific pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms, especially cases where experienced Python developers recommend "do this instead of that."

The goal is to identify as many distinct, materially useful Python practices as possible, not just the most popular or obvious examples.

Research across the full Python language, runtime behavior, standard library, packaging and environment behavior where materially relevant, standard development practices, and ecosystem conventions that broadly affect Python development.

Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.

Actively look for unexpected or less obvious classes of issues that may not fit common Python best-practice lists.

For every finding, provide exactly:

Name:
Category:
Impact:
Consensus:
Description:
Why:
Source URL:

Use the fields as follows:

- Name - concise name for the pattern, pitfall, or recommendation.
- Category - a technical category derived from the findings during research. Do not force findings into a predefined category set.
- Impact - High, Medium, or Low based on how materially the issue can affect correctness, reliability, maintainability, security, performance, or development outcomes.
- Consensus - High, Medium, or Low based on how broadly the recommendation is supported by authoritative sources and experienced Python practitioners.
- Description - explain the issue or recommendation, including the problematic approach and preferred alternative where applicable.
- Why - explain why the preferred approach matters and what problems it prevents or improves.
- Source URL - provide the strongest relevant source supporting the finding.

Organize the final results into:

1. High Impact
2. Medium Impact
3. Low Impact

Within each impact level, order findings from highest to lowest consensus.

Research broadly across authoritative and high-quality sources. Prefer primary and authoritative sources when they adequately support a finding, while also using high-quality practitioner sources where they provide material guidance not covered by primary documentation.

Potential source types include:

- official Python documentation
- Python language and standard library documentation
- Python Enhancement Proposals (PEPs)
- Python developer and core contributor documentation
- guidance from Python core developers and maintainers
- established engineering documentation
- respected Python experts and practitioners
- technically rigorous articles and discussions

Do not treat popularity, repetition, or search ranking alone as evidence of correctness or consensus.

Evaluate Impact and Consensus independently. A finding may have high impact but low consensus, or low impact but high consensus.

Include disputed practices when they are materially relevant, but assign an appropriate Consensus rating and accurately describe the disagreement rather than presenting one side as settled guidance.

Avoid duplicate findings that describe the same underlying issue. Merge substantially equivalent recommendations while preserving genuinely different cases, conditions, or failure modes.

Focus on guidance specific to Python, including the language itself, runtime behavior, standard library, and broadly applicable Python development practices. Do not fill the results with framework-specific or library-specific advice unless it exposes an underlying Python behavior or practice that remains materially relevant outside that framework or library.

Do not fill the results with generic programming advice unless Python introduces a distinct consideration.

Do not stop after finding a conventional "top Python best practices" list. Use iterative discovery to identify additional terminology, failure modes, recommendations, and sources from the findings themselves.

Continue researching until further searching is producing primarily duplicates, minor stylistic preferences, weakly supported claims, or findings with little practical significance.

-----
#### Assistant said:

I’ll treat this as a discovery-first survey rather than starting from a fixed checklist. I’ll prioritize Python docs, PEPs, packaging guidance, and core-maintainer material, then use practitioner sources mainly to fill gaps or document genuinely disputed practices.

-----
#### Assistant said:

The first pass is already surfacing several distinct clusters beyond ordinary style advice: object lifetime and finalization, iterator consumption, import execution/caching, exception suppression, concurrency assumptions, serialization/security, and packaging isolation. I’ll keep these as discovered categories rather than treating them as the boundaries of the search.

-----
#### Assistant said:

The official FAQ also confirms several easy-to-miss semantics worth treating as separate findings, not just variants of "mutability": augmented assignment can mutate before a later assignment fails, `id()` values may be reused after object death, method caches can retain instances, and module reload does not update names imported with `from module import name`.

-----
#### Assistant said:

The categories below were derived after discovery rather than used to constrain the search. I prioritized current Python documentation, PEPs, PyPA specifications, and pip documentation, and stopped when further searching was primarily producing duplicates, narrow edge cases, or stylistic preferences with little practical consequence.

#### 1. High Impact

Name: Mutable default arguments  
Category: Function state and object lifetime  
Impact: High  
Consensus: High  
Description: Do not use mutable objects such as `[]` or `{}` as function defaults when a fresh object is intended. Defaults are evaluated once when the function is defined. Prefer `None` or another sentinel and create the object inside the function.  
Why: Mutations persist across calls and can cause hidden cross-call state and data contamination.  
Source URL: https://docs.python.org/3/faq/programming.html citeturn796887view0

Name: Assertions for required runtime checks  
Category: Runtime validation  
Impact: High  
Consensus: High  
Description: Do not use `assert` for input validation, authorization, security checks, or other behavior required for correctness. Use explicit condition checks and raise an appropriate exception.  
Why: Python removes `assert` statements when optimization is enabled with `-O`, so required checks can disappear entirely.  
Source URL: https://docs.python.org/3/reference/simple_stmts.html#the-assert-statement citeturn269000search1

Name: Bare or overly broad exception handling  
Category: Exception handling  
Impact: High  
Consensus: High  
Description: Catch the narrowest exception types that the code can meaningfully handle. Avoid bare `except:` except for exceptional cases where `BaseException` subclasses such as `KeyboardInterrupt` and `SystemExit` truly need handling.  
Why: Broad handlers can hide programming errors and unintentionally intercept process termination and user interrupts.  
Source URL: https://peps.python.org/pep-0008/#programming-recommendations citeturn998230search0

Name: Control flow in `finally` suppressing exceptions  
Category: Exception control flow  
Impact: High  
Consensus: High  
Description: Avoid `return`, `break`, or `continue` that exits a `finally` block while an exception is active. Python 3.14 warns about such constructs.  
Why: The pending exception is discarded, potentially converting a real failure into an apparently successful result.  
Source URL: https://docs.python.org/3/reference/compound_stmts.html#the-try-statement citeturn573059search1

Name: Non-deterministic resource cleanup  
Category: Resource lifecycle  
Impact: High  
Consensus: High  
Description: Use context managers or explicit `close()` operations for files, sockets, locks, database resources, and similar objects rather than relying on garbage collection or `__del__`.  
Why: Finalization timing and ordering are not reliable enough to guarantee prompt release of externally important resources.  
Source URL: https://docs.python.org/3/faq/programming.html citeturn886327view4

Name: Mutable hash keys  
Category: Hashing and equality  
Impact: High  
Consensus: High  
Description: Objects whose equality-relevant state can change should normally not be hashable. In particular, do not implement a hash that changes while the object is stored in a dict or set.  
Why: Changing a key's hash can leave it in the wrong hash bucket, breaking lookup and collection invariants.  
Source URL: https://docs.python.org/3/reference/datamodel.html#object.__hash__ citeturn121154search17

Name: Unpickling untrusted data  
Category: Serialization security  
Impact: High  
Consensus: High  
Description: Never load untrusted or unauthenticated data with `pickle`. Use a non-executable serialization format when the input crosses a trust boundary.  
Why: Pickle deserialization can execute arbitrary code.  
Source URL: https://docs.python.org/3/library/pickle.html citeturn960629search2

Name: Opening untrusted `shelve` databases  
Category: Serialization security  
Impact: High  
Consensus: High  
Description: Do not open a `shelve` database obtained from an untrusted source.  
Why: `shelve` is backed by `pickle`, so opening malicious data can execute arbitrary code.  
Source URL: https://docs.python.org/3/library/shelve.html citeturn676425search7

Name: Unmarshalling untrusted data  
Category: Serialization security  
Impact: High  
Consensus: High  
Description: Do not use `marshal` as a general-purpose or untrusted serialization format.  
Why: The format is not secure against malicious data and is version-dependent, especially for serialized code objects.  
Source URL: https://docs.python.org/3/library/marshal.html citeturn632505search0

Name: `eval()` and `exec()` on untrusted input  
Category: Dynamic execution security  
Impact: High  
Consensus: High  
Description: Never pass untrusted strings or code objects to `eval()` or `exec()`. Prefer parsing, explicit dispatch, or purpose-specific data formats.  
Why: Both functions execute arbitrary Python code and directly create code-execution vulnerabilities when fed attacker-controlled input.  
Source URL: https://docs.python.org/3/library/functions.html#eval citeturn676425search23

Name: Treating `ast.literal_eval()` as safe for hostile input  
Category: Parser resource safety  
Impact: High  
Consensus: High  
Description: `ast.literal_eval()` avoids arbitrary code execution but should still not be used indiscriminately on hostile input without resource controls.  
Why: Relatively small inputs can cause excessive CPU, memory, or C-stack consumption and potentially crash the process.  
Source URL: https://docs.python.org/3/library/ast.html#ast.literal_eval citeturn676425search15

Name: Shell injection through `subprocess`  
Category: Process security  
Impact: High  
Consensus: High  
Description: Prefer `subprocess` with `shell=False` and pass arguments as a sequence. Use `shell=True` only when shell behavior is actually required and carefully quote untrusted data.  
Why: Explicit shell execution interprets shell metacharacters and can turn untrusted arguments into commands.  
Source URL: https://docs.python.org/3/library/subprocess.html#security-considerations citeturn169544search9

Name: Waiting on subprocesses with unread pipes  
Category: Process I/O  
Impact: High  
Consensus: High  
Description: Do not call `Popen.wait()` while a child may fill `stdout=PIPE` or `stderr=PIPE`. Use `communicate()` or otherwise continuously drain the pipes.  
Why: The child can block on a full OS pipe while the parent waits for the child, producing a deadlock.  
Source URL: https://docs.python.org/3/library/subprocess.html#subprocess.Popen.wait citeturn169544search9

Name: `preexec_fn` in threaded programs  
Category: Process concurrency  
Impact: High  
Consensus: High  
Description: Do not use `Popen(preexec_fn=...)` in a process containing threads. Prefer dedicated `Popen` parameters such as `env`, `start_new_session`, and `process_group`.  
Why: The child can deadlock before `exec()` because only the forking thread survives while inherited synchronization state may remain locked.  
Source URL: https://docs.python.org/3/library/subprocess.html#subprocess.Popen citeturn676425search4

Name: Incomplete privilege dropping with `subprocess`  
Category: Process security  
Impact: High  
Consensus: High  
Description: On POSIX, do not assume `Popen(user=...)` alone removes supplementary groups. When dropping privileges requires it, explicitly set `extra_groups=()`.  
Why: A child can otherwise retain supplementary group memberships and therefore privileges the programmer intended to remove.  
Source URL: https://docs.python.org/3/library/subprocess.html#subprocess.Popen citeturn169544search9

Name: `random` for secrets  
Category: Cryptographic randomness  
Impact: High  
Consensus: High  
Description: Use `secrets`, not the default `random` module, for authentication tokens, password-reset URLs, passwords, or other security-sensitive randomness.  
Why: `random` is designed for simulation and modeling, not cryptographic unpredictability.  
Source URL: https://docs.python.org/3/library/secrets.html citeturn127432search3

Name: General-purpose hashes for passwords  
Category: Password security  
Impact: High  
Consensus: High  
Description: Do not store passwords using a direct fast hash such as `sha256(password)`. Use a password-oriented, salted, deliberately expensive derivation mechanism.  
Why: Fast general-purpose hashes make brute-force password attacks dramatically cheaper.  
Source URL: https://docs.python.org/3/library/hashlib.html#key-derivation citeturn127432search2

Name: Ordinary equality for secret digests  
Category: Cryptographic comparison  
Impact: High  
Consensus: High  
Description: When verifying an externally supplied HMAC or similar secret-dependent digest, use `hmac.compare_digest()` or `secrets.compare_digest()` rather than `==`.  
Why: Ordinary equality can expose timing information about secret-dependent comparisons.  
Source URL: https://docs.python.org/3/library/hmac.html#hmac.compare_digest citeturn127432search1

Name: Insecure temporary filenames with `mktemp()`  
Category: Filesystem security  
Impact: High  
Consensus: High  
Description: Do not use `tempfile.mktemp()` to create security-sensitive temporary files. Use `TemporaryFile`, `NamedTemporaryFile`, `mkstemp`, or `TemporaryDirectory`.  
Why: Separating name selection from file creation creates a race in which another process can claim or manipulate the path.  
Source URL: https://docs.python.org/3/library/tempfile.html citeturn960629search0

Name: Blind extraction of untrusted tar archives  
Category: Archive extraction security  
Impact: High  
Consensus: High  
Description: Do not blindly extract untrusted tar archives. Use appropriate extraction filters, inspect archive contents, constrain destination handling, and apply resource limits as necessary.  
Why: Even the safer `data` filter does not eliminate every attack, including denial-of-service and filesystem abuse scenarios.  
Source URL: https://docs.python.org/3/library/tarfile.html#extraction-filters citeturn209590search1

Name: Assuming standard XML parsers are hardened against hostile documents  
Category: Parser security  
Impact: High  
Consensus: High  
Description: Consult the documented XML vulnerabilities before processing attacker-controlled XML and use a hardened approach appropriate to the threat model.  
Why: Several standard XML facilities have exposure to maliciously constructed documents and resource-exhaustion attacks.  
Source URL: https://docs.python.org/3/library/xml.html#xml-vulnerabilities citeturn632505search40

Name: Attacker-controlled second argument to `urljoin()`  
Category: URL security  
Impact: High  
Consensus: High  
Description: Do not use `urljoin(base, attacker_value)` and assume the result remains under `base`. Validate or constrain the second value first.  
Why: An absolute URL can replace the original scheme and host entirely.  
Source URL: https://docs.python.org/3/library/urllib.parse.html#urllib.parse.urljoin citeturn209590search2

Name: Treating `urlparse()` as URL validation  
Category: URL security  
Impact: High  
Consensus: High  
Description: Treat `urlparse()` and `urlsplit()` as parsers rather than validators. Perform explicit scheme, hostname, port, and other policy checks before using parsed values for security decisions.  
Why: The parsing APIs intentionally accept inputs that may not satisfy application-specific validity or trust requirements.  
Source URL: https://docs.python.org/3/library/urllib.parse.html#url-parsing-security citeturn209590search2

Name: SQL construction with Python string formatting  
Category: Database security  
Impact: High  
Consensus: High  
Description: Pass SQL values through database parameter placeholders rather than f-strings, concatenation, `%`, or `.format()`.  
Why: Separating query syntax from values prevents SQL injection and handles escaping correctly.  
Source URL: https://docs.python.org/3/library/sqlite3.html#how-to-use-placeholders-to-bind-values-in-sql-queries citeturn209590search3

Name: Unsynchronized shared SQLite connections  
Category: Database concurrency  
Impact: High  
Consensus: High  
Description: If SQLite's `check_same_thread=False` is used, serialize writes yourself rather than treating the connection as automatically safe for unrestricted concurrent access.  
Why: Concurrent writes through the same connection can otherwise cause incorrect behavior or data corruption.  
Source URL: https://docs.python.org/3/library/sqlite3.html citeturn209590search3

Name: Permission pre-checks with `os.access()`  
Category: Filesystem security  
Impact: High  
Consensus: High  
Description: Do not normally check access with `os.access()` and then separately open the file. Attempt the operation and handle failure instead.  
Why: The filesystem can change between the check and use, creating a TOCTOU race and potentially a security vulnerability.  
Source URL: https://docs.python.org/3/library/os.html#os.access citeturn970147search24

Name: Using `commonprefix()` for path containment  
Category: Filesystem security  
Impact: High  
Consensus: High  
Description: Do not use `os.path.commonprefix()` to decide whether one filesystem path is contained by another. Use path-aware canonicalization and `commonpath()` or equivalent containment logic.  
Why: `commonprefix()` compares characters rather than path components and can return syntactically invalid or security-misleading prefixes.  
Source URL: https://docs.python.org/3/library/os.path.html#os.path.commonprefix citeturn981679search18

Name: Assuming `zipfile.Path` prevents path traversal  
Category: Archive extraction security  
Impact: High  
Consensus: High  
Description: When using `zipfile.Path` on untrusted archives, validate filenames and destination paths yourself.  
Why: Unlike `ZipFile.extract()` and `extractall()`, `zipfile.Path` does not sanitize filenames to prevent path traversal.  
Source URL: https://docs.python.org/3/library/zipfile.html#path-objects citeturn135790search5

Name: Private package discovery with `--extra-index-url`  
Category: Packaging security  
Impact: High  
Consensus: High  
Description: Do not rely on `pip --extra-index-url` to securely combine a private package repository with a public index for uniquely named private packages.  
Why: pip explicitly warns that this is unsafe because a public package with the same name can win resolution, enabling dependency confusion.  
Source URL: https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-extra-index-url citeturn559356search0

Name: Assuming ordinary pip installs provide strong supply-chain integrity  
Category: Packaging security  
Impact: High  
Consensus: High  
Description: For environments requiring strong repeatability and integrity, pin dependencies and use pip hash checking; where the threat model requires avoiding arbitrary build execution, restrict installation to trusted binary distributions.  
Why: Ordinary installs trust repository content and source distributions can execute build code during installation.  
Source URL: https://pip.pypa.io/en/stable/topics/secure-installs/ citeturn559356search3

Name: TLS contexts without certificate and hostname verification  
Category: Transport security  
Impact: High  
Consensus: High  
Description: For ordinary TLS clients, prefer `ssl.create_default_context()` or `PROTOCOL_TLS_CLIENT` rather than manually constructing a context that leaves certificate or hostname verification disabled.  
Why: A manually constructed context does not necessarily authenticate the peer, allowing man-in-the-middle attacks.  
Source URL: https://docs.python.org/3/library/ssl.html#best-defaults citeturn127432search0

Name: `http.server` in production  
Category: Network service security  
Impact: High  
Consensus: High  
Description: Do not use `http.server` as a production HTTP server.  
Why: The Python documentation explicitly states that it implements only basic security checks and is not recommended for production.  
Source URL: https://docs.python.org/3/library/http.server.html citeturn676425search21

Name: Treating compound shared-state operations as atomic  
Category: Thread concurrency  
Impact: High  
Consensus: High  
Description: Use synchronization for shared invariants and read-modify-write sequences instead of assuming that individual list or dict operations make a larger operation atomic.  
Why: Multiple accesses, iteration, and compound operations can interleave even when individual implementation operations are protected.  
Source URL: https://docs.python.org/3/glossary.html#term-thread-safe citeturn397960search31

Name: Relying on the GIL for thread safety  
Category: Runtime concurrency model  
Impact: High  
Consensus: High  
Description: Do not design correctness around the assumption that CPython's GIL implicitly serializes shared mutable state. Use explicit synchronization or ownership boundaries.  
Why: The assumption is already insufficient for compound operations and is incompatible with supported free-threaded CPython builds.  
Source URL: https://docs.python.org/3/howto/free-threading-python.html citeturn397960search3

Name: Daemon threads for work requiring cleanup  
Category: Thread lifecycle  
Impact: High  
Consensus: High  
Description: Do not put essential cleanup, transactional, or persistent work exclusively in daemon threads. Prefer non-daemon threads with an explicit shutdown signal and join.  
Why: Daemon threads are abruptly stopped when Python shuts down and may not release files, transactions, or other resources properly.  
Source URL: https://docs.python.org/3/library/threading.html citeturn169544search0

Name: Forking a multithreaded process  
Category: Process concurrency  
Impact: High  
Consensus: High  
Description: Avoid `os.fork()` from a multithreaded Python process and do not assume the historical `fork` multiprocessing behavior is safe.  
Why: Locks and runtime state inherited from vanished threads can leave the child permanently inconsistent or deadlocked.  
Source URL: https://docs.python.org/3/library/os.html#os.fork citeturn676425search10

Name: Missing multiprocessing main guard  
Category: Process startup  
Impact: High  
Consensus: High  
Description: Protect process-creating entry points with `if __name__ == "__main__":`, particularly when spawn or forkserver is used.  
Why: Child interpreters import the main module, so unguarded process creation can recursively create processes or fail during bootstrap.  
Source URL: https://docs.python.org/3/library/multiprocessing.html#the-spawn-and-forkserver-start-methods citeturn625110search1

Name: Non-importable multiprocessing targets  
Category: Process serialization  
Impact: High  
Consensus: High  
Description: With spawn and forkserver, use picklable arguments and ordinarily define worker functions at importable module scope rather than relying on lambdas, REPL definitions, or local functions.  
Why: Child processes must reconstruct serialized callables and objects in a separate interpreter.  
Source URL: https://docs.python.org/3/library/multiprocessing.html citeturn625110search1

Name: Force-terminating processes that hold shared resources  
Category: Process lifecycle  
Impact: High  
Consensus: High  
Description: Prefer cooperative process shutdown when a worker uses queues, pipes, locks, semaphores, or other shared state. Reserve `terminate()` for cases where those resources are not at risk.  
Why: Forced termination can corrupt IPC resources and leave locks permanently held.  
Source URL: https://docs.python.org/3/library/multiprocessing.html citeturn169544search2

Name: Joining a multiprocessing producer before draining its queue  
Category: Process IPC  
Impact: High  
Consensus: High  
Description: Ensure queued data is consumed before joining a process that has written substantial data to a multiprocessing queue.  
Why: The producer may wait for its feeder thread to flush the queue while the parent waits for the producer, creating a deadlock.  
Source URL: https://docs.python.org/3/library/multiprocessing.html#programming-guidelines citeturn169544search2

Name: Executor tasks waiting on the same exhausted executor  
Category: Executor concurrency  
Impact: High  
Consensus: High  
Description: Do not have work running in a bounded executor synchronously wait for other work that can only run in that same exhausted executor.  
Why: All workers can become occupied by tasks waiting for work for which no worker remains available.  
Source URL: https://docs.python.org/3/library/concurrent.futures.html citeturn397960search0

Name: Blocking the asyncio event loop  
Category: Asyncio scheduling  
Impact: High  
Consensus: High  
Description: Do not perform long blocking I/O or CPU-bound synchronous work directly inside event-loop callbacks and coroutines. Use asynchronous APIs, `to_thread()` for appropriate blocking I/O, or process/interpreter execution for CPU-heavy work.  
Why: One blocking call prevents unrelated coroutines and callbacks from making progress.  
Source URL: https://docs.python.org/3/library/asyncio-dev.html citeturn676425search20

Name: Calling a coroutine without awaiting or scheduling it  
Category: Asyncio execution  
Impact: High  
Consensus: High  
Description: Await coroutine objects or explicitly schedule them as tasks. Merely calling an `async def` function does not execute its body.  
Why: The intended operation never runs and Python may only report the mistake later as a `RuntimeWarning`.  
Source URL: https://docs.python.org/3/library/asyncio-dev.html citeturn676425search20

Name: Swallowing `CancelledError`  
Category: Asyncio cancellation  
Impact: High  
Consensus: High  
Description: If cleanup code catches `asyncio.CancelledError`, normally re-raise it when cleanup finishes unless cancellation is intentionally and completely suppressed.  
Why: Structured-concurrency components such as `TaskGroup` and timeout machinery use cancellation internally and can misbehave when it is swallowed.  
Source URL: https://docs.python.org/3/library/asyncio-task.html#task-cancellation citeturn676425search19

Name: Losing references to background asyncio tasks  
Category: Asyncio task lifecycle  
Impact: High  
Consensus: High  
Description: Keep strong references to independently scheduled tasks, or preferably use `TaskGroup` when tasks belong to one operation.  
Why: The event loop keeps only weak references to tasks, so an otherwise unreferenced task can disappear before completion.  
Source URL: https://docs.python.org/3/library/asyncio-task.html#creating-tasks citeturn625110search0

Name: Calling non-thread-safe asyncio APIs from worker threads  
Category: Asyncio thread interaction  
Impact: High  
Consensus: High  
Description: From another OS thread, use `loop.call_soon_threadsafe()` or `asyncio.run_coroutine_threadsafe()` rather than ordinary event-loop methods.  
Why: Most asyncio objects are not thread-safe.  
Source URL: https://docs.python.org/3/library/asyncio-dev.html#concurrency-and-multithreading citeturn397960search7

Name: `threading.local()` for asyncio-local state  
Category: Context-local state  
Impact: High  
Consensus: High  
Description: Use `ContextVar` for logical context that must remain isolated across concurrent asynchronous tasks rather than storing such state in `threading.local()`.  
Why: Multiple asyncio tasks can share one OS thread, causing thread-local state to bleed between otherwise independent tasks.  
Source URL: https://docs.python.org/3/library/contextvars.html citeturn169544search1

Name: Lock acquisition inside signal handlers  
Category: Signal handling  
Impact: High  
Consensus: High  
Description: Do not use ordinary synchronization locks from Python signal handlers. Also remember that Python signal handlers execute in the main Python thread.  
Why: Signal arrival can interrupt code while the same lock is held, causing unexpected deadlocks.  
Source URL: https://docs.python.org/3/library/signal.html citeturn169544search6

Name: Using `os._exit()` as an ordinary exit mechanism  
Category: Process termination  
Impact: High  
Consensus: High  
Description: Use `sys.exit()` for normal Python termination. Reserve `os._exit()` primarily for specialized post-fork child-process situations.  
Why: `_exit()` bypasses normal cleanup handlers and does not flush standard I/O buffers.  
Source URL: https://docs.python.org/3/library/os.html#os._exit citeturn578000search5

Name: Assuming `sys.exit()` from a worker thread exits the process  
Category: Thread termination  
Impact: High  
Consensus: High  
Description: Do not use `sys.exit()` in a worker thread as a process-wide shutdown mechanism. Coordinate shutdown with the main thread instead.  
Why: `sys.exit()` raises `SystemExit`; outside the main thread it normally terminates only that thread.  
Source URL: https://docs.python.org/3/library/sys.html#sys.exit citeturn578000search1

Name: Treating type annotations as runtime validation  
Category: Type hint runtime boundary  
Impact: High  
Consensus: High  
Description: Do not assume annotated function arguments or assignments are runtime checked merely because type hints are present. Add explicit validation where runtime guarantees are required.  
Why: Python does not enforce ordinary annotations at runtime.  
Source URL: https://docs.python.org/3/library/typing.html citeturn470972search20

Name: Treating `typing.cast()` as a runtime cast  
Category: Type hint runtime boundary  
Impact: High  
Consensus: High  
Description: Use `cast()` only to communicate information to a static type checker, not to validate or convert runtime values.  
Why: `typing.cast()` returns its value unchanged and performs no runtime check.  
Source URL: https://docs.python.org/3/library/typing.html#typing.cast citeturn470972search0

Name: Unnecessary use of `Any`  
Category: Static type safety  
Impact: High  
Consensus: High  
Description: Use `Any` deliberately when type checking truly must be bypassed. Prefer `object`, protocols, unions, generics, or `unknown`-style narrowing patterns when operations should remain checked.  
Why: `Any` effectively disables static checking for operations flowing through it and can spread loss of type safety.  
Source URL: https://docs.python.org/3/library/typing.html#the-any-type citeturn470972search3

Name: Installing project dependencies into the system Python  
Category: Environment isolation  
Impact: High  
Consensus: High  
Description: Use virtual environments for project-specific third-party dependencies and respect externally managed Python installations rather than routinely forcing pip modifications into the system interpreter.  
Why: System and project dependency ownership can otherwise conflict and break either the application or OS-managed Python software.  
Source URL: https://packaging.python.org/en/latest/specifications/externally-managed-environments/ citeturn761990search2

Name: Undeclared build dependencies  
Category: Build isolation  
Impact: High  
Consensus: High  
Description: Declare the build backend and all required build-time dependencies in `[build-system]` rather than depending on packages that happen to exist in the developer's environment.  
Why: Modern build frontends create isolated build environments, so undeclared dependencies make builds fail or become environment-dependent.  
Source URL: https://packaging.python.org/en/latest/guides/writing-pyproject-toml/#declaring-the-build-backend citeturn761990search8

Name: Assuming an import name identifies the package to install  
Category: Packaging supply chain  
Impact: High  
Consensus: High  
Description: Do not automatically derive `pip install <name>` from an unknown `import <name>`. Verify the intended distribution package.  
Why: Distribution names and import-package names are separate namespaces, so blindly installing the import name can install an unrelated or malicious package.  
Source URL: https://packaging.python.org/en/latest/discussions/distribution-package-vs-import-package/ citeturn761990search3

Name: Silent truncation with `zip()`  
Category: Iterator cardinality  
Impact: High  
Consensus: High  
Description: When corresponding iterables are required to have the same length, use `zip(..., strict=True)` instead of ordinary `zip()`.  
Why: Default `zip()` silently stops at the shortest iterable, potentially discarding data and hiding upstream bugs.  
Source URL: https://docs.python.org/3/library/functions.html#zip citeturn730570search2

#### 2. Medium Impact

Name: Assignment does not copy objects  
Category: Object aliasing  
Impact: Medium  
Consensus: High  
Description: Remember that `b = a` creates another reference to the same object. Explicitly copy when independent mutable state is required.  
Why: Mutation through either reference is visible through the other.  
Source URL: https://docs.python.org/3/tutorial/classes.html#a-word-about-names-and-objects citeturn970147search0

Name: Assuming a shallow copy duplicates nested state  
Category: Object copying  
Impact: Medium  
Consensus: High  
Description: Use a shallow copy only when sharing nested objects is acceptable. Consider deliberate reconstruction or `deepcopy()` when nested independence is required.  
Why: A shallow copy creates a new outer container but retains references to nested objects.  
Source URL: https://docs.python.org/3/library/copy.html citeturn176086search1

Name: Mutable class variables used as per-instance state  
Category: Class state  
Impact: Medium  
Consensus: High  
Description: Put mutable data intended to belong to each instance on `self` during initialization rather than defining one mutable object as a class variable.  
Why: A class-level list or dict is shared by all instances.  
Source URL: https://docs.python.org/3/tutorial/classes.html#class-and-instance-variables citeturn970147search0

Name: Nested mutable sequences created with repetition  
Category: Container aliasing  
Impact: Medium  
Consensus: High  
Description: Do not create independent nested mutable containers with expressions such as `[[None] * width] * height`. Use a comprehension that constructs each inner object separately.  
Why: Sequence repetition repeats references, so every row can refer to the same inner list.  
Source URL: https://docs.python.org/3/faq/programming.html citeturn905463view4

Name: Mutable dataclass defaults  
Category: Dataclass state  
Impact: Medium  
Consensus: High  
Description: For per-instance mutable dataclass fields, use `field(default_factory=list)` or another factory rather than a shared mutable default.  
Why: Each instance should receive a distinct object, and modern dataclasses reject many unhashable mutable defaults specifically to prevent this class of error.  
Source URL: https://docs.python.org/3/library/dataclasses.html citeturn717372search0

Name: Late-bound closures in loops  
Category: Closures and name binding  
Impact: Medium  
Consensus: High  
Description: When callbacks created in a loop should capture the current loop value, bind it explicitly, such as through a default parameter or helper scope.  
Why: Closures capture the variable, not its value at function creation time, so callbacks can all observe the loop's final value.  
Source URL: https://docs.python.org/3/faq/programming.html citeturn573059search15

Name: Assignment unexpectedly making a variable local  
Category: Name binding and scope  
Impact: Medium  
Consensus: High  
Description: Remember that assigning to a name anywhere in a function normally makes it local throughout that function unless declared `global` or `nonlocal`.  
Why: A read appearing before the assignment can therefore raise `UnboundLocalError` even when a global with the same name exists.  
Source URL: https://docs.python.org/3/reference/executionmodel.html#resolution-of-names citeturn905463view1

Name: Augmented assignment can mutate before failing  
Category: Augmented assignment semantics  
Impact: Medium  
Consensus: High  
Description: Be cautious with expressions such as `tuple_obj[index] += mutable_value`. Separate mutation and assignment when the target is immutable or behavior matters.  
Why: The in-place operation can mutate the contained object before Python later fails while assigning the result back into the immutable container.  
Source URL: https://docs.python.org/3/faq/programming.html citeturn886327view2

Name: Mutable values with `dict.fromkeys()`  
Category: Mapping construction  
Impact: Medium  
Consensus: High  
Description: Do not use `dict.fromkeys(keys, mutable_object)` when each key needs independent mutable state. Use a comprehension.  
Why: Every key receives a reference to the exact same value object.  
Source URL: https://docs.python.org/3/library/stdtypes.html#dict.fromkeys citeturn893333search0

Name: `defaultdict.get()` bypasses the factory  
Category: Mapping semantics  
Impact: Medium  
Consensus: High  
Description: Do not expect `defaultdict.get(key)` to create a missing entry. Use indexing when invoking the factory is intended.  
Why: `get()` behaves like normal `dict.get()` and does not call `__missing__()` or `default_factory`.  
Source URL: https://docs.python.org/3/library/collections.html#collections.defaultdict citeturn534360search1

Name: Mutating a dict while iterating it  
Category: Mapping iteration  
Impact: Medium  
Consensus: High  
Description: Do not add or remove dictionary entries while directly iterating the dictionary or its dynamic views. Iterate a copy or construct the desired result separately.  
Why: Mutation can raise `RuntimeError` or produce skipped or inconsistent traversal behavior.  
Source URL: https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects citeturn893333search0

Name: Treating dictionary views as snapshots  
Category: Mapping iteration  
Impact: Medium  
Consensus: High  
Description: Materialize `list(d.keys())`, `list(d.items())`, or similar when a snapshot is required rather than storing a view and assuming it is frozen.  
Why: Dict views are dynamic and reflect subsequent changes to the dictionary.  
Source URL: https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects citeturn893333search0

Name: `groupby()` without grouping consecutive equal keys  
Category: Iterator grouping  
Impact: Medium  
Consensus: High  
Description: Use `itertools.groupby()` only when equal-key elements are already consecutive, commonly by sorting first when global grouping is intended.  
Why: `groupby()` splits groups whenever the key changes and does not aggregate matching values found later.  
Source URL: https://docs.python.org/3/library/itertools.html#itertools.groupby citeturn730570search3

Name: Saving `groupby()` group iterators for later  
Category: Iterator lifetime  
Impact: Medium  
Consensus: High  
Description: Materialize a `groupby()` subgroup if it must survive advancing the outer iterator.  
Why: Each subgroup shares the underlying iterable with the parent `groupby()` object and becomes unavailable as iteration moves forward.  
Source URL: https://docs.python.org/3/library/itertools.html#itertools.groupby citeturn730570search3

Name: Unbounded buffering with `itertools.tee()`  
Category: Iterator buffering  
Impact: Medium  
Consensus: High  
Description: Do not assume `tee()` duplicates an iterator for free. If one branch may advance far ahead of another, materializing the data may be more appropriate.  
Why: `tee()` must retain unseen elements and can accumulate substantial hidden storage; it is also not thread-safe.  
Source URL: https://docs.python.org/3/library/itertools.html#itertools.tee citeturn730570search0

Name: Raising `StopIteration` inside generators  
Category: Generator control flow  
Impact: Medium  
Consensus: High  
Description: End a generator with `return` rather than deliberately raising `StopIteration` from generator code.  
Why: An escaping `StopIteration` is transformed into `RuntimeError`.  
Source URL: https://peps.python.org/pep-0479/ citeturn349230search0

Name: Assignment-expression targets leaking from comprehensions  
Category: Comprehension scope  
Impact: Medium  
Consensus: High  
Description: Do not assume a walrus target inside a comprehension is scoped like the comprehension's loop variable. Choose names with the containing-scope binding in mind.  
Why: Assignment-expression targets in comprehensions bind in the containing scope.  
Source URL: https://docs.python.org/3/reference/expressions.html#assignment-expressions citeturn395327search0

Name: Bare names in structural pattern matching  
Category: Pattern matching semantics  
Impact: Medium  
Consensus: High  
Description: In `case` patterns, do not write a bare identifier when intending to compare against an existing constant. Use a literal or qualified value pattern.  
Why: A bare name is a capture pattern that matches and binds rather than comparing equality.  
Source URL: https://docs.python.org/3/reference/compound_stmts.html#patterns citeturn349230search1

Name: `is` for value equality  
Category: Identity and equality  
Impact: Medium  
Consensus: High  
Description: Use `==` for value equality and reserve `is` for identity checks such as `x is None`.  
Why: Object identity is not value equality, and apparent success with interned literals is an implementation artifact that should not be relied upon.  
Source URL: https://peps.python.org/pep-0008/#programming-recommendations citeturn176086search5

Name: Boolean and numeric keys colliding  
Category: Numeric type relationships  
Impact: Medium  
Consensus: High  
Description: Do not use values such as `True`, `1`, and `1.0` as supposedly distinct dict or set keys when their semantic distinction matters.  
Why: They compare equal and have compatible hashes, so they represent the same key in hashed collections.  
Source URL: https://docs.python.org/3/library/stdtypes.html#boolean-type-bool citeturn930743search2

Name: Assuming `and` and `or` return booleans  
Category: Boolean expression semantics  
Impact: Medium  
Consensus: High  
Description: Remember that `and` and `or` return one of their operands. Avoid `value or default` when valid falsey values such as `0`, `""`, or `[]` must be preserved.  
Why: Truth-value selection can silently replace legitimate data rather than merely producing `True` or `False`.  
Source URL: https://docs.python.org/3/library/stdtypes.html#boolean-operations-and-or-not citeturn349230search2

Name: Exact equality for computed floating-point values  
Category: Floating-point semantics  
Impact: Medium  
Consensus: High  
Description: When values are mathematically approximate, compare computed floats using a tolerance appropriate to the domain, commonly `math.isclose()`, rather than expecting exact decimal equality.  
Why: Most decimal fractions cannot be represented exactly in binary floating point.  
Source URL: https://docs.python.org/3/tutorial/floatingpoint.html citeturn930743search0

Name: `math.isclose()` against zero without `abs_tol`  
Category: Floating-point comparison  
Impact: Medium  
Consensus: High  
Description: When checking whether a value is sufficiently close to zero, provide a meaningful nonzero `abs_tol` rather than relying only on relative tolerance.  
Why: Relative comparison to zero cannot establish a useful nonzero acceptance band.  
Source URL: https://docs.python.org/3/library/math.html#math.isclose citeturn686110search3

Name: Constructing exact decimals from binary floats  
Category: Decimal arithmetic  
Impact: Medium  
Consensus: High  
Description: When the intended value is a decimal literal such as money, construct `Decimal` from a string or other exact decimal representation rather than an already rounded binary float.  
Why: `Decimal(float_value)` preserves the exact binary-float value, including its approximation error.  
Source URL: https://docs.python.org/3/library/decimal.html citeturn415060search0

Name: Using `timedelta.seconds` for total duration  
Category: Duration semantics  
Impact: Medium  
Consensus: High  
Description: Use `timedelta.total_seconds()` when the total elapsed seconds are required rather than the `.seconds` component.  
Why: `.seconds` excludes whole days; the documentation explicitly calls confusing the two a common bug.  
Source URL: https://docs.python.org/3/library/datetime.html#datetime.timedelta.seconds citeturn578000search8

Name: Naive UTC datetimes  
Category: Datetime semantics  
Impact: Medium  
Consensus: High  
Description: Prefer timezone-aware UTC values such as `datetime.now(UTC)` and `datetime.fromtimestamp(ts, UTC)` rather than `utcnow()` or `utcfromtimestamp()`.  
Why: Naive UTC objects can be accidentally interpreted as local time, and the naive UTC constructors are deprecated.  
Source URL: https://docs.python.org/3/library/datetime.html citeturn686110search0

Name: Calling `timestamp()` on naive UTC  
Category: Datetime semantics  
Impact: Medium  
Consensus: High  
Description: Attach or retain the correct timezone before converting a datetime to a timestamp rather than passing a naive UTC value to `.timestamp()`.  
Why: Python treats a naive datetime as local time for this conversion.  
Source URL: https://docs.python.org/3/library/datetime.html#datetime.datetime.timestamp citeturn686110search0

Name: Wall-clock time for elapsed durations  
Category: Clock semantics  
Impact: Medium  
Consensus: High  
Description: Measure elapsed time and deadlines using `time.monotonic()` or `time.perf_counter()` rather than subtracting `time.time()` values.  
Why: System wall time can be adjusted forwards or backwards, while monotonic clocks are specifically designed not to run backwards.  
Source URL: https://docs.python.org/3/library/time.html#time.monotonic citeturn534360search0

Name: Implicit text-file encoding  
Category: Text encoding  
Impact: Medium  
Consensus: High  
Description: Specify the encoding for files whose format has a defined encoding, typically UTF-8, instead of relying on the interpreter or platform default.  
Why: Default encodings vary by Python configuration, version, and platform, making behavior non-portable.  
Source URL: https://docs.python.org/3/library/io.html#text-encoding citeturn331744search1

Name: Silently ignoring encoding errors  
Category: Text encoding  
Impact: Medium  
Consensus: High  
Description: Avoid `errors="ignore"` unless deliberate irreversible data loss is acceptable. Prefer strict handling or an error strategy such as `surrogateescape` when round-tripping arbitrary bytes is required.  
Why: Ignoring errors silently removes data and can make corruption difficult to detect.  
Source URL: https://docs.python.org/3/library/codecs.html#error-handlers citeturn331744search3

Name: Opening CSV files without `newline=""`  
Category: CSV I/O  
Impact: Medium  
Consensus: High  
Description: Open files passed to `csv.reader` or `csv.writer` with `newline=""`.  
Why: Otherwise embedded newlines may be interpreted incorrectly and some platforms can produce extra carriage returns when writing.  
Source URL: https://docs.python.org/3/library/csv.html citeturn981679search6

Name: Serializing `None` through `csv.writer`  
Category: CSV data fidelity  
Impact: Medium  
Consensus: High  
Description: Do not rely on the CSV writer to preserve the distinction between `None` and an empty string. Encode nullable values explicitly when round-trip fidelity matters.  
Why: `csv.writer` writes `None` as an empty string, which is not reversible.  
Source URL: https://docs.python.org/3/library/csv.html#csv.writer citeturn981679search32

Name: Repeated `json.dump()` calls as one JSON document  
Category: JSON framing  
Impact: Medium  
Consensus: High  
Description: Do not append multiple independent `json.dump()` outputs to one stream and expect the result to be a valid single JSON document. Use an explicit framing format or outer collection.  
Why: JSON is not a framed protocol.  
Source URL: https://docs.python.org/3/library/json.html citeturn981679search1

Name: Non-standard NaN and Infinity in JSON  
Category: JSON interoperability  
Impact: Medium  
Consensus: High  
Description: Use `allow_nan=False` when output must conform strictly to the JSON specification.  
Why: Python's default encoder permits `NaN`, `Infinity`, and `-Infinity`, which are not standard JSON numeric values.  
Source URL: https://docs.python.org/3/library/json.html citeturn981679search2

Name: Duplicate JSON object names  
Category: JSON data fidelity  
Impact: Medium  
Consensus: High  
Description: Do not assume the default JSON decoder rejects duplicate object member names. Use `object_pairs_hook` or external validation when duplicates must be detected.  
Why: By default, repeated names are accepted and the last value wins.  
Source URL: https://docs.python.org/3/library/json.html#standard-compliance-and-interoperability citeturn981679search14

Name: Assuming JSON preserves non-string dict keys  
Category: JSON data fidelity  
Impact: Medium  
Consensus: High  
Description: Encode non-string mapping keys explicitly if their types must survive a JSON round trip.  
Why: JSON object keys are strings, so Python mappings with numeric or other keys do not round-trip identically.  
Source URL: https://docs.python.org/3/library/json.html citeturn981679search11

Name: Using `strip()` to remove a literal prefix or suffix  
Category: String API semantics  
Impact: Medium  
Consensus: High  
Description: Use `removeprefix()` or `removesuffix()` for literal affixes rather than `lstrip()`, `rstrip()`, or `strip(chars)`.  
Why: The `chars` argument is interpreted as a set of characters to remove repeatedly, not as one literal substring.  
Source URL: https://docs.python.org/3/library/stdtypes.html#str.strip citeturn644552search0

Name: Regular expressions without raw strings  
Category: Regular-expression literals  
Impact: Medium  
Consensus: High  
Description: Prefer raw string literals such as `r"\d+\."` for regular-expression patterns containing backslashes.  
Why: Otherwise Python string escaping and regex escaping interact, making patterns harder to read and potentially producing invalid-escape warnings or errors.  
Source URL: https://docs.python.org/3/library/re.html#raw-string-notation citeturn644552search1

Name: Confusing `re.match()`, `search()`, and `fullmatch()`  
Category: Regular-expression matching  
Impact: Medium  
Consensus: High  
Description: Use `search()` for a match anywhere, `match()` for a match beginning at position zero, and `fullmatch()` when the entire string must satisfy the pattern.  
Why: Choosing the wrong API can accept or reject inputs based on unintended anchoring semantics.  
Source URL: https://docs.python.org/3/library/re.html#search-vs-match citeturn644552search2

Name: Heap entries without a tie-breaker  
Category: Priority queues  
Impact: Medium  
Consensus: High  
Description: When heap entries contain `(priority, task)` and equal priorities are possible, add a unique monotonic counter or comparable wrapper unless tasks themselves are safely orderable.  
Why: Equal priorities cause Python to compare the second tuple elements, potentially raising `TypeError` or imposing unintended ordering.  
Source URL: https://docs.python.org/3/library/heapq.html#priority-queue-implementation-notes citeturn893333search3

Name: `argparse` with `type=bool`  
Category: Command-line parsing  
Impact: Medium  
Consensus: High  
Description: Do not parse boolean command-line options using `type=bool`. Use actions such as `store_true`, `store_false`, `BooleanOptionalAction`, or an explicit text parser.  
Why: `bool("False")` is true because any non-empty string is truthy, so the intuitive CLI interpretation is wrong.  
Source URL: https://docs.python.org/3/library/argparse.html#type citeturn534360search5

Name: `deque.extendleft()` reversing input order  
Category: Collection semantics  
Impact: Medium  
Consensus: High  
Description: Account for reversal when using `extendleft()`, or reverse the input first when preserving its order is required.  
Why: `extendleft()` repeatedly performs left appends, so the iterable appears in reverse order.  
Source URL: https://docs.python.org/3/library/collections.html#collections.deque.extendleft citeturn551538search2

Name: Treating `Counter` as a strictly positive multiset  
Category: Collection semantics  
Impact: Medium  
Consensus: High  
Description: Remember that `Counter` can retain zero and negative counts and that setting a count to zero does not remove the key. Delete entries or normalize when positive-only semantics are required.  
Why: Iteration, equality, `elements()`, and mathematical operations treat zero and negative counts in ways that differ from an ordinary bag abstraction.  
Source URL: https://docs.python.org/3/library/collections.html#collections.Counter citeturn551538search2

Name: Caching generators, coroutines, or side-effectful functions  
Category: Caching semantics  
Impact: Medium  
Consensus: High  
Description: Use `lru_cache` and `cache` for reusable computed values, not calls whose identity, side effects, freshness, generator iteration state, or coroutine execution matters.  
Why: The cache stores and returns the same result object instead of re-running the computation.  
Source URL: https://docs.python.org/3/library/functools.html#functools.lru_cache citeturn717372search19

Name: `lru_cache` on instance methods retaining instances  
Category: Cache lifetime  
Impact: Medium  
Consensus: High  
Description: Be cautious caching instance methods on large or short-lived object populations. Bound method calls include `self` in the cache key.  
Why: Cached entries can hold strong references to instances until eviction or cache clearing.  
Source URL: https://docs.python.org/3/faq/programming.html citeturn886327view5

Name: Assuming `cached_property` computes exactly once under concurrency  
Category: Cache concurrency  
Impact: Medium  
Consensus: High  
Description: If duplicate execution would be unsafe, explicitly synchronize a `cached_property` computation rather than relying on the descriptor to provide once-only execution.  
Why: Multiple threads can race and run the getter more than once.  
Source URL: https://docs.python.org/3/library/functools.html#functools.cached_property citeturn717372search1

Name: Assuming `lru_cache` suppresses duplicate concurrent calls  
Category: Cache concurrency  
Impact: Medium  
Consensus: High  
Description: Do not use `lru_cache` itself as a single-flight mechanism when duplicate concurrent execution is unacceptable.  
Why: Two callers can both enter the underlying function before the first result has been cached.  
Source URL: https://docs.python.org/3/library/functools.html#functools.lru_cache citeturn717372search1

Name: Wildcard imports  
Category: Import namespace management  
Impact: Medium  
Consensus: High  
Description: Avoid `from module import *` outside narrowly controlled uses. Import explicit names or the module itself.  
Why: Wildcard imports obscure name origins and can silently overwrite existing bindings.  
Source URL: https://docs.python.org/3/tutorial/modules.html#importing-from-a-package citeturn952050search23

Name: `from module import name` in circular imports  
Category: Import initialization  
Impact: Medium  
Consensus: High  
Description: Avoid circular imports where partially initialized modules must satisfy `from module import name`. Refactor dependencies or, where appropriate, import the module and defer attribute access.  
Why: The requested name may not yet have been defined when the circular import reaches it.  
Source URL: https://docs.python.org/3/faq/programming.html#imports citeturn952050search2

Name: Reloading modules after `from ... import ...`  
Category: Import caching  
Impact: Medium  
Consensus: High  
Description: Do not expect `importlib.reload(module)` to update names previously copied into another namespace with `from module import name`. Use module-qualified references or re-execute the import.  
Why: Reload replaces attributes on the module object, not external bindings to the old objects.  
Source URL: https://docs.python.org/3/library/importlib.html#importlib.reload citeturn952050search12

Name: Assuming imports are passive declarations  
Category: Module execution  
Impact: Medium  
Consensus: High  
Description: Keep unavoidable import-time side effects controlled and remember that ordinary module top-level code executes on the first import in an interpreter.  
Why: Importing a module can execute arbitrary initialization, while later imports normally reuse the cached module instead of rerunning it.  
Source URL: https://docs.python.org/3/tutorial/modules.html citeturn952050search27

Name: Threads as the default solution for CPU-bound Python code  
Category: Concurrency performance  
Impact: Medium  
Consensus: High  
Description: On ordinary GIL-enabled CPython, prefer processes, subinterpreters where applicable, native code that releases the GIL, or another suitable strategy for parallel CPU-bound Python bytecode.  
Why: Regular Python threads do not normally execute CPU-bound Python bytecode in parallel under the GIL.  
Source URL: https://docs.python.org/3/library/threading.html#gil-and-performance-considerations citeturn397960search4

Name: Assuming `asyncio.gather()` cancels siblings on first failure  
Category: Structured concurrency  
Impact: Medium  
Consensus: High  
Description: Use `TaskGroup` when one child failure should cancel the remaining child tasks. Do not assume default `gather()` provides those failure semantics.  
Why: With default settings, `gather()` propagates the first exception but other awaitables may continue running.  
Source URL: https://docs.python.org/3/library/asyncio-task.html#running-tasks-concurrently citeturn158689search7

Name: Concurrent use of `warnings.catch_warnings()` without context-aware warnings  
Category: Warning-state concurrency  
Impact: Medium  
Consensus: High  
Description: In concurrent code, account for `sys.flags.context_aware_warnings`; without it, simultaneous `catch_warnings()` use is not concurrency-safe.  
Why: The traditional implementation temporarily modifies global warnings state.  
Source URL: https://docs.python.org/3/library/warnings.html#temporarily-suppressing-warnings citeturn676425search2

Name: Changing process locale in concurrent code  
Category: Locale state  
Impact: Medium  
Consensus: High  
Description: Avoid repeated `locale.setlocale()` changes in multithreaded code and prefer designs that do not mutate the process-wide locale during normal operation.  
Why: `setlocale()` is not thread-safe on most systems and locale is process-wide state.  
Source URL: https://docs.python.org/3/library/locale.html citeturn578000search10

Name: Moving or copying virtual environments  
Category: Environment portability  
Impact: Medium  
Consensus: High  
Description: Recreate virtual environments at their destination rather than treating an existing environment directory as portable.  
Why: Installed scripts contain absolute interpreter paths, making virtual environments inherently non-portable.  
Source URL: https://docs.python.org/3/library/venv.html#how-venvs-work citeturn105507search2

Name: Flat-layout imports hiding packaging errors  
Category: Package layout  
Impact: Medium  
Consensus: High  
Description: Consider `src/` layout when accidental imports directly from the working tree could hide missing package data, import configuration, or installation errors.  
Why: Flat layouts put the project directory on the import path and can test source files that differ from what users actually install.  
Source URL: https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/ citeturn761990search16

Name: Testing only editable installs  
Category: Packaging verification  
Impact: Medium  
Consensus: High  
Description: Do not rely solely on editable installation behavior when validating a distributable project. Also test a normal built and installed distribution.  
Why: Editable installs intentionally expose the source tree and can differ from ordinary installation behavior.  
Source URL: https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/ citeturn761990search13

Name: Direct `setup.py` commands  
Category: Packaging workflow  
Impact: Medium  
Consensus: High  
Description: Do not run commands such as `python setup.py install`, `develop`, or `sdist` as the normal modern workflow. Use standards-based frontends such as `pip` and `build`.  
Why: Direct invocation bypasses modern standardized build and installation behavior and is deprecated as a command interface.  
Source URL: https://packaging.python.org/en/latest/discussions/setup-py-deprecated/ citeturn554881search0

Name: Treating requirements files as project dependency metadata  
Category: Dependency specification  
Impact: Medium  
Consensus: High  
Description: Declare the dependencies needed by the distributable project in project metadata and use requirements-style files for describing particular environments or deployment sets.  
Why: The two mechanisms serve different purposes and conflating them harms package metadata and reproducibility.  
Source URL: https://packaging.python.org/en/latest/discussions/install-requires-vs-requirements/ citeturn554881search16

Name: Treating `pip freeze` as a lockfile solver  
Category: Dependency reproducibility  
Impact: Medium  
Consensus: High  
Description: Use `pip freeze` as a report of an environment's installed state, not as proof that a dependency set was independently solved or securely locked.  
Why: pip explicitly states that `freeze` does not compute a lockfile or solver result.  
Source URL: https://pip.pypa.io/en/stable/cli/pip_freeze/ citeturn559356search2

Name: Assuming mutable generic containers are covariant  
Category: Static type variance  
Impact: Medium  
Consensus: High  
Description: Do not treat `list[Derived]` as `list[Base]`. Use a read-only abstraction such as `Sequence[Base]` where covariance is actually safe.  
Why: Mutable collections are invariant because accepting a broader type would allow inserting values invalid for the original narrower list.  
Source URL: https://typing.python.org/en/latest/spec/generics.html citeturn381174search0

Name: Treating `@runtime_checkable Protocol` as runtime type validation  
Category: Runtime structural typing  
Impact: Medium  
Consensus: High  
Description: Use runtime-checkable protocols only for shallow structural presence checks, not validation of complete method signatures or annotated types.  
Why: Runtime protocol checks generally verify attribute existence rather than static typing contracts.  
Source URL: https://docs.python.org/3/library/typing.html#typing.runtime_checkable citeturn381174search1

Name: Treating `TypedDict` as a runtime record type  
Category: Type hint runtime boundary  
Impact: Medium  
Consensus: High  
Description: Do not expect `TypedDict` construction to validate keys or values at runtime. Add actual validation when external data must satisfy a schema.  
Why: A `TypedDict` value is an ordinary `dict` at runtime.  
Source URL: https://docs.python.org/3/library/typing.html#typing.TypedDict citeturn381174search1

Name: Reading annotations directly from `__annotations__`  
Category: Annotation introspection  
Impact: Medium  
Consensus: High  
Description: For runtime annotation introspection, use `annotationlib.get_annotations()` on Python 3.14+ or the supported `inspect` helper rather than manually interpreting `__annotations__`.  
Why: Annotation evaluation is lazy in modern Python and historical annotation behavior varies considerably across versions and object types.  
Source URL: https://docs.python.org/3/howto/annotations.html citeturn408469search17

Name: Evaluating string annotations unnecessarily  
Category: Annotation introspection security  
Impact: Medium  
Consensus: High  
Description: Avoid enabling annotation string evaluation unless actual Python values are required. Prefer string or forward-reference formats for introspection where possible.  
Why: Resolving stringized annotations can call `eval()` and can therefore execute expressions or raise arbitrary evaluation errors.  
Source URL: https://docs.python.org/3/library/inspect.html#inspect.get_annotations citeturn408469search3

Name: Patching where an object is defined rather than looked up  
Category: Test mocking  
Impact: Medium  
Consensus: High  
Description: With `unittest.mock.patch`, patch the name in the namespace where the code under test looks it up, not necessarily the module where the original object was defined.  
Why: Imports create bindings, and patching the original definition does not replace already-bound references elsewhere.  
Source URL: https://docs.python.org/3/library/unittest.mock.html#where-to-patch citeturn194709search0

Name: Unconstrained mocks masking API mistakes  
Category: Test mocking  
Impact: Medium  
Consensus: High  
Description: Use `spec`, `spec_set`, or `autospec` when a mock should accurately model a real API, and use `create=True` only deliberately.  
Why: An unconstrained mock can accept nonexistent attributes or incorrect call signatures and allow broken production code to pass tests.  
Source URL: https://docs.python.org/3/library/unittest.mock.html#autospeccing citeturn194709search0

Name: Inspecting mutated mock arguments after the call  
Category: Test mocking  
Impact: Medium  
Consensus: High  
Description: If a test must assert the state of mutable arguments at call time, copy them in a side effect or otherwise capture their original state.  
Why: Mock call records retain references, so later mutation changes what the recorded argument appears to contain.  
Source URL: https://docs.python.org/3/library/unittest.mock-examples.html#coping-with-mutable-arguments citeturn194709search1

Name: Ignoring deprecation warnings in test suites  
Category: Compatibility testing  
Impact: Medium  
Consensus: High  
Description: Configure development and test runs to surface relevant `DeprecationWarning` and other normally hidden warnings.  
Why: Several developer-facing warning categories are ignored by default, so compatibility problems may otherwise remain invisible until behavior is removed.  
Source URL: https://docs.python.org/3/library/warnings.html#updating-code-for-new-versions-of-dependencies citeturn194709search2

Name: Libraries configuring the root logger  
Category: Logging ownership  
Impact: Medium  
Consensus: High  
Description: Library code should log through named loggers, normally based on `__name__`, and should not configure the root logger or install application handlers behind the user's back.  
Why: Handler and output configuration belongs to the application, and library-side configuration interferes with downstream logging policy.  
Source URL: https://docs.python.org/3/howto/logging.html#configuring-logging-for-a-library citeturn408469search0

Name: Eager string formatting in disabled logging calls  
Category: Logging performance  
Impact: Medium  
Consensus: High  
Description: When formatting work is material, pass the format string and arguments separately, such as `logger.debug("value=%s", value)`, rather than eagerly constructing the final message.  
Why: Logging can defer interpolation until it knows the record will actually be emitted.  
Source URL: https://docs.python.org/3/library/logging.html citeturn194709search3

Name: Relying on `__del__` for important behavior  
Category: Object finalization  
Impact: Medium  
Consensus: High  
Description: Keep `__del__` minimal and avoid depending on it for correctness, lock acquisition, or deterministic resource release.  
Why: It can execute at unpredictable times or threads, exceptions are ignored, and interpreter shutdown imposes additional constraints.  
Source URL: https://docs.python.org/3/reference/datamodel.html#object.__del__ citeturn217551search2

Name: `weakref.finalize()` callback retaining its object  
Category: Object finalization  
Impact: Medium  
Consensus: High  
Description: Ensure a `weakref.finalize()` callback does not directly or indirectly retain the object being finalized, especially through a bound method.  
Why: The strong reference prevents the object from becoming collectible and therefore prevents the finalizer from running as intended.  
Source URL: https://docs.python.org/3/library/weakref.html#weakref.finalize citeturn217551search0

Name: Treating `__slots__` as a transparent memory optimization  
Category: Class layout  
Impact: Medium  
Consensus: High  
Description: Use `__slots__` only after accounting for inheritance, weak references, instance dictionaries, class defaults, and layout restrictions.  
Why: Slots materially change object layout and normal attribute behavior and have several inheritance and weak-reference caveats.  
Source URL: https://docs.python.org/3/reference/datamodel.html#object.__slots__ citeturn217551search1

Name: Using `IntEnum` when integer interoperability is unnecessary  
Category: Enumeration modeling  
Impact: Medium  
Consensus: High  
Description: Prefer `Enum` or `Flag` for new APIs unless compatibility with integer APIs is actually required.  
Why: `IntEnum` members compare like integers, allowing accidental equality with unrelated numeric values and enum types.  
Source URL: https://docs.python.org/3/library/enum.html citeturn148086search4

Name: Returning `False` instead of `NotImplemented` for unsupported comparisons  
Category: Operator protocol  
Impact: Medium  
Consensus: High  
Description: Custom rich comparison and numeric methods should return `NotImplemented` when the operand type is unsupported.  
Why: This gives Python a chance to invoke the reflected operation or other fallback protocol rather than incorrectly declaring the operation false.  
Source URL: https://docs.python.org/3/reference/datamodel.html#object.__lt__ citeturn121154search3

Name: Non-cooperative superclass calls in multiple inheritance  
Category: Method resolution  
Impact: Medium  
Consensus: High  
Description: In classes designed for cooperative multiple inheritance, use compatible method signatures and `super()` throughout the cooperating hierarchy rather than hard-coding a particular parent call.  
Why: `super()` follows Python's dynamic MRO and ensures each cooperating implementation is reached in the intended order.  
Source URL: https://docs.python.org/3/library/functions.html#super citeturn159039search1

Name: Assuming `getctime()` means creation time everywhere  
Category: Filesystem portability  
Impact: Medium  
Consensus: High  
Description: Do not treat `os.path.getctime()` as a portable file-creation timestamp.  
Why: On Unix it represents the last metadata change time, while on Windows it represents creation time.  
Source URL: https://docs.python.org/3/library/os.path.html citeturn135790search3

Name: Absolute components resetting `os.path.join()`  
Category: Path construction  
Impact: Medium  
Consensus: High  
Description: Validate path components when joining untrusted or assumed-relative values. Do not assume appending an absolute component keeps the preceding base path.  
Why: An absolute path component causes earlier path components to be discarded according to platform rules.  
Source URL: https://docs.python.org/3/library/os.path.html#os.path.join citeturn135790search3

Name: Lexical parent walking without resolving symlinks  
Category: Path canonicalization  
Impact: Medium  
Consensus: High  
Description: When traversing upward through an arbitrary filesystem path and symlink identity matters, resolve the path before performing lexical parent operations.  
Why: `..` and symlink relationships can make lexical ancestry differ from actual filesystem ancestry.  
Source URL: https://docs.python.org/3/library/pathlib.html citeturn408469search2

Name: Assuming `shutil.copy*` creates a full filesystem clone  
Category: Filesystem metadata  
Impact: Medium  
Consensus: High  
Description: Do not assume ordinary `shutil` copy operations preserve all ownership, ACL, resource-fork, alternate-stream, and extended metadata.  
Why: Metadata preservation varies by platform and the standard copy helpers intentionally do not reproduce every filesystem property.  
Source URL: https://docs.python.org/3/library/shutil.html citeturn135790search2

Name: Reading immediately after `copyfileobj()` without flushing  
Category: Stream buffering  
Impact: Medium  
Consensus: High  
Description: Flush or close the destination before immediately consuming data written through `shutil.copyfileobj()`.  
Why: The helper does not guarantee that buffered destination data has been flushed when it returns.  
Source URL: https://docs.python.org/3/library/shutil.html#shutil.copyfileobj citeturn135790search2

Name: Repeated immutable-string concatenation in loops  
Category: Sequence performance  
Impact: Medium  
Consensus: High  
Description: Prefer `str.join()` or an appropriate buffer when constructing a string from many pieces instead of repeatedly growing an immutable string.  
Why: Repeated immutable concatenation can require repeated copying and become quadratic.  
Source URL: https://docs.python.org/3/library/stdtypes.html#sequence-types-list-tuple-range citeturn893333search0

#### 3. Low Impact

Name: Comparing with `None` using equality  
Category: Singleton identity  
Impact: Low  
Consensus: High  
Description: Prefer `x is None` and `x is not None` rather than equality comparisons.  
Why: `None` is a singleton and identity avoids invoking user-defined equality behavior.  
Source URL: https://peps.python.org/pep-0008/#programming-recommendations citeturn263477search0

Name: Exact type checks instead of `isinstance()`  
Category: Runtime type inspection  
Impact: Low  
Consensus: High  
Description: Prefer `isinstance(obj, Type)` to `type(obj) is Type` when subclasses should satisfy the interface.  
Why: Exact type comparisons unnecessarily reject legitimate subclasses.  
Source URL: https://peps.python.org/pep-0008/#programming-recommendations citeturn263477search0

Name: Comparing sequence length with zero  
Category: Truth-value idioms  
Impact: Low  
Consensus: High  
Description: Prefer `if sequence:` or `if not sequence:` when testing emptiness rather than explicitly comparing `len(sequence)` with zero.  
Why: Truth-value testing is the standard Python container protocol and works across suitable container types.  
Source URL: https://peps.python.org/pep-0008/#programming-recommendations citeturn263477search0

Name: Comparing booleans to `True` or `False`  
Category: Truth-value idioms  
Impact: Low  
Consensus: High  
Description: Prefer direct truth-value tests when actual boolean identity is not specifically required rather than `x == True` or `x == False`.  
Why: Direct tests are clearer and work with Python's general truth-value protocol.  
Source URL: https://peps.python.org/pep-0008/#programming-recommendations citeturn263477search0

Name: Prefix and suffix tests through slicing  
Category: String idioms  
Impact: Low  
Consensus: High  
Description: Prefer `startswith()` and `endswith()` over manual slices when testing a prefix or suffix.  
Why: The dedicated methods communicate intent and avoid repeated literal-length bookkeeping.  
Source URL: https://peps.python.org/pep-0008/#programming-recommendations citeturn263477search0

Name: Assigning a lambda to a name  
Category: Function definition idioms  
Impact: Low  
Consensus: High  
Description: When a callable needs a durable name, prefer `def` over assigning a `lambda` expression.  
Why: `def` produces a naturally named function and clearer traceback and introspection output.  
Source URL: https://peps.python.org/pep-0008/#programming-recommendations citeturn263477search0

Name: Legacy `and/or` conditional expressions  
Category: Conditional expressions  
Impact: Low  
Consensus: High  
Description: Use `a if condition else b` rather than the historical `condition and a or b` idiom.  
Why: The old form returns the wrong branch when `a` is falsey.  
Source URL: https://docs.python.org/3/faq/programming.html citeturn905463view3

Name: Forgetting the comma in a one-element tuple  
Category: Tuple syntax  
Impact: Low  
Consensus: High  
Description: Write `(value,)` for a one-element tuple. Parentheses alone do not make a tuple.  
Why: The comma, not the parentheses, is what creates the tuple.  
Source URL: https://docs.python.org/3/library/stdtypes.html#tuple citeturn349230search2

Name: Treating double-underscore attributes as private security boundaries  
Category: Class encapsulation  
Impact: Low  
Consensus: High  
Description: Use double-leading-underscore name mangling primarily to avoid accidental subclass name collisions, not to enforce privacy.  
Why: Mangled names remain deliberately accessible and can still be read or modified externally.  
Source URL: https://docs.python.org/3/tutorial/classes.html#private-variables citeturn970147search0

Name: Depending on set iteration order  
Category: Collection ordering  
Impact: Low  
Consensus: High  
Description: Explicitly sort or otherwise impose order when deterministic set traversal is part of a contract.  
Why: Python does not guarantee a stable cross-run ordering for sets.  
Source URL: https://docs.python.org/3/library/stdtypes.html#set-types-set-frozenset citeturn893333search2

Name: Comparing `dict.values()` views for content equality  
Category: Mapping views  
Impact: Low  
Consensus: High  
Description: Convert or compare values using a representation appropriate to the desired semantics rather than relying on `d.values() == other.values()`.  
Why: Dictionary values views do not implement content-based equality and even a values view compared with itself using a distinct lookup behaves unexpectedly.  
Source URL: https://docs.python.org/3/library/stdtypes.html#dictionary-view-objects citeturn893333search0

Name: Persisting or interpreting `id()` as a permanent object identifier  
Category: Object identity  
Impact: Low  
Consensus: High  
Description: Use `id()` only for identity during an object's lifetime, not as a durable or globally unique identifier.  
Why: An ID value can be reused after the original object is destroyed.  
Source URL: https://docs.python.org/3/library/functions.html#id citeturn886327view4

Name: Persisting built-in string hashes  
Category: Hash behavior  
Impact: Low  
Consensus: High  
Description: Do not persist `hash(str_value)` or `hash(bytes_value)` when a stable cross-process digest is required. Use an explicit stable hash function instead.  
Why: Python salts string and byte hashes with process-specific randomness.  
Source URL: https://docs.python.org/3/reference/datamodel.html#object.__hash__ citeturn121154search0

Name: Chaining mutating methods that return `None`  
Category: Mutable API conventions  
Impact: Low  
Consensus: High  
Description: Do not assume in-place mutators such as `list.sort()` return the modified object. Perform the mutation separately.  
Why: Python's mutable collection APIs commonly return `None` specifically to distinguish mutation from value-producing operations.  
Source URL: https://docs.python.org/3/faq/programming.html citeturn796887view0

Name: Manual index loops over sequences  
Category: Iteration idioms  
Impact: Low  
Consensus: High  
Description: Prefer direct iteration or `enumerate(sequence)` over `for i in range(len(sequence))` when both the index and element are required.  
Why: `enumerate()` expresses the intended operation directly and avoids redundant indexing.  
Source URL: https://docs.python.org/3/library/functions.html#enumerate citeturn893333search1

Name: Returning a value from `__init__()`  
Category: Object construction protocol  
Impact: Low  
Consensus: High  
Description: `__init__()` must initialize the instance and return `None`; use `__new__()` or another construction mechanism when object creation itself must be customized.  
Why: Returning any non-`None` value from `__init__()` raises `TypeError`.  
Source URL: https://docs.python.org/3/reference/datamodel.html#object.__init__ citeturn121154search14

Name: Zero-argument `super()` inside nested functions  
Category: Method resolution  
Impact: Low  
Consensus: High  
Description: Do not expect zero-argument `super()` to infer the intended method arguments inside a nested function or generator expression. Use an explicit form or restructure the call.  
Why: Zero-argument `super()` relies on the immediately enclosing function's compiler-provided context.  
Source URL: https://docs.python.org/3/library/functions.html#super citeturn159039search1

Name: Subscripting a `super` object  
Category: Method resolution  
Impact: Low  
Consensus: High  
Description: Use explicit attribute lookup such as `super().__getitem__(key)` rather than `super()[key]`.  
Why: `super()` implements its special MRO lookup for explicit dotted attribute access, not implicit operator lookup.  
Source URL: https://docs.python.org/3/library/functions.html#super citeturn159039search1

Name: Directly modifying module `__dict__`  
Category: Runtime introspection  
Impact: Low  
Consensus: High  
Description: Prefer ordinary attribute assignment and supported APIs over direct mutation of a module's `__dict__` unless low-level introspection is intentionally required.  
Why: The built-in type documentation explicitly discourages modifying module symbol tables this way.  
Source URL: https://docs.python.org/3/library/stdtypes.html#modules citeturn676425search3

Name: One-shot generator context-manager instances  
Category: Context manager lifecycle  
Impact: Low  
Consensus: High  
Description: Do not attempt to enter the same context-manager object returned by `@contextmanager` repeatedly. Call the decorated function again to create a new instance.  
Why: Generator-backed context manager instances are one-shot.  
Source URL: https://docs.python.org/3/library/contextlib.html#contextlib.contextmanager citeturn148086search1

Name: Assuming `final` is runtime enforcement  
Category: Type hint runtime boundary  
Impact: Low  
Consensus: High  
Description: Treat `@final` primarily as a static type-checker contract rather than a runtime mechanism preventing inheritance or overriding.  
Why: Python itself does not enforce finality during ordinary class construction.  
Source URL: https://docs.python.org/3/library/typing.html#typing.final citeturn470972search2

Name: Assuming `NewType` constructs a runtime wrapper object  
Category: Type hint runtime boundary  
Impact: Low  
Consensus: High  
Description: Use `NewType` to create a static distinction, not for runtime validation or wrapping.  
Why: At runtime a `NewType` call returns its argument essentially unchanged.  
Source URL: https://docs.python.org/3/library/typing.html#newtype citeturn470972search15

Name: Assuming `@override` changes runtime dispatch  
Category: Type hint semantics  
Impact: Low  
Consensus: High  
Description: Use `@override` to let static checking detect misspelled or nonexistent base methods, not as a runtime override mechanism.  
Why: Python's normal method resolution already controls runtime overriding; the decorator primarily communicates intent to type checkers.  
Source URL: https://docs.python.org/3/library/typing.html#typing.override citeturn470972search2

Name: Using EAFP as an unconditional rule  
Category: Error-handling style  
Impact: Low  
Consensus: Medium  
Description: Python commonly favors EAFP, especially where a check-then-act sequence would introduce races, but do not mechanically replace every precondition check with exceptions. Choose based on API semantics, readability, cost, and concurrency requirements.  
Why: EAFP is a strong Python idiom, but LBYL remains appropriate when checking is part of the actual contract and does not race with the operation.  
Source URL: https://docs.python.org/3/glossary.html#term-EAFP citeturn970147search1

-----
#### User said:

Using the research findings, write **one single enforceable rule for each finding**.
 
The goal is to convert every identified pitfall, gotcha, footgun, anti-pattern, correctness hazard, or preferred idiom into a concise rule that can be given to an AI coding agent and used to prevent that specific issue.
 
For each finding:
 
 
- Produce exactly **one rule**.
 
- Preserve the intent and technical nuance of the finding.
 
- State the preferred behavior directly.
 
- Include the prohibited or discouraged behavior when necessary to make the rule unambiguous.
 
- Make the rule specific enough to be actionable and reviewable.
 
- Prefer objective, observable requirements over vague advice.
 
- Do not add rationale, explanation, examples, exceptions, or implementation guidance unless they are necessary to make the rule technically correct.
 
- Preserve material conditions or exceptions from the research. Do not turn conditional guidance into an unconditional prohibition.
 
- Do not make a rule stricter than the underlying evidence supports.
 
- Do not combine multiple independent findings into one rule.
 
- Do not split one finding into multiple rules.
 
- Do not invent new requirements that were not supported by the corresponding finding.
 
- Avoid generic wording such as "use best practices," "write clean code," "be careful," or "prefer idiomatic code."
 
- Write the rule so compliance can be determined from the code or relevant development context whenever practical.
 

 
Use normative language consistently:
 
 
- `MUST` for behavior required to avoid a well-supported correctness, safety, or reliability problem.
 
- `MUST NOT` for behavior that is prohibited under the applicable conditions.
 
- `SHOULD` / `SHOULD NOT` for strong preferences where legitimate exceptions exist.
 
- `MAY` only when expressing an explicitly permitted alternative is necessary.
 

 
Determine the strength of each rule from the underlying **Impact**, **Consensus**, evidence, and stated exceptions. Do not automatically convert every finding into `MUST` or `MUST NOT`.
 
For each finding, output exactly:
 `Name: Rule: ` 
`Name` must preserve the name of the original research finding so the rule can be traced back to it.
 
`Rule` must contain the single resulting rule.
 
Process **every finding** from the research. Do not omit findings merely because they are low impact, low consensus, conditional, or stylistic. Where the evidence does not justify a strict requirement, express the rule with appropriately weaker normative language.
 
Avoid duplicate rules. If separate research findings ultimately impose the same requirement, retain their traceability but do not broaden either rule beyond its original finding.

-----
#### Assistant said:

I’ll preserve every research finding one-for-one, keep the original names unchanged, and reduce each to a single reviewable normative rule without carrying over rationale or source material.

-----
#### Assistant said:

:::writing{variant="document" id="48327" title="Python Enforceable Rules"}
Name: Mutable default arguments  
Rule: Functions `MUST NOT` use a mutable default argument when a fresh object is intended for each call; they `MUST` create the mutable object per call using `None` or another sentinel default.

Name: Assertions for required runtime checks  
Rule: `assert` `MUST NOT` be used for validation, authorization, security, or other checks required for runtime correctness; required checks `MUST` use explicit control flow and exceptions.

Name: Bare or overly broad exception handling  
Rule: Exception handlers `SHOULD` catch the narrowest exception types they can meaningfully handle and `MUST NOT` use bare `except:` unless interception of `BaseException` subclasses is intentionally required.

Name: Control flow in `finally` suppressing exceptions  
Rule: A `finally` block `MUST NOT` use `return`, `break`, or `continue` in a way that discards an active exception.

Name: Non-deterministic resource cleanup  
Rule: Files, sockets, locks, database resources, and other resources requiring prompt deterministic release `MUST` be managed with context managers or explicit cleanup rather than relying on garbage collection or `__del__`.

Name: Mutable hash keys  
Rule: An object used as a dict key or set member `MUST NOT` allow equality-relevant state to change in a way that changes its hash while it remains in the collection.

Name: Unpickling untrusted data  
Rule: Untrusted or unauthenticated data `MUST NOT` be deserialized with `pickle`.

Name: Opening untrusted `shelve` databases  
Rule: A `shelve` database from an untrusted source `MUST NOT` be opened.

Name: Unmarshalling untrusted data  
Rule: `marshal` `MUST NOT` be used to deserialize untrusted data or as a general-purpose persistent serialization format.

Name: `eval()` and `exec()` on untrusted input  
Rule: Untrusted input `MUST NOT` be passed to `eval()` or `exec()`.

Name: Treating `ast.literal_eval()` as safe for hostile input  
Rule: Hostile or unbounded input `MUST NOT` be passed to `ast.literal_eval()` unless appropriate resource limits or equivalent denial-of-service controls are in place.

Name: Shell injection through `subprocess`  
Rule: `subprocess` calls `SHOULD` use `shell=False` with arguments passed as a sequence, and `shell=True` `MUST NOT` interpolate untrusted data without correct shell quoting.

Name: Waiting on subprocesses with unread pipes  
Rule: Code `MUST NOT` call `Popen.wait()` while a child can block on undrained `stdout=PIPE` or `stderr=PIPE`; it `MUST` drain those pipes, normally with `communicate()`.

Name: `preexec_fn` in threaded programs  
Rule: `Popen(preexec_fn=...)` `MUST NOT` be used in a process containing multiple threads.

Name: Incomplete privilege dropping with `subprocess`  
Rule: When a POSIX child process must drop supplementary group privileges, `Popen` `MUST` explicitly set `extra_groups=()` or the intended replacement group set rather than relying on `user=` alone.

Name: `random` for secrets  
Rule: Security-sensitive random values `MUST` use `secrets` or another cryptographically secure generator and `MUST NOT` use the default `random` module.

Name: General-purpose hashes for passwords  
Rule: Passwords `MUST NOT` be stored using a direct fast general-purpose hash and `MUST` use an appropriate salted password-derivation mechanism.

Name: Ordinary equality for secret digests  
Rule: Secret-dependent digests such as HMAC values `MUST` be compared with `hmac.compare_digest()` or `secrets.compare_digest()` rather than ordinary equality.

Name: Insecure temporary filenames with `mktemp()`  
Rule: Security-sensitive temporary files `MUST NOT` be created with `tempfile.mktemp()` and `MUST` use an atomic temporary-file or temporary-directory API.

Name: Blind extraction of untrusted tar archives  
Rule: Untrusted tar archives `MUST NOT` be blindly extracted; extraction `MUST` use appropriate filters and validate destination and resource constraints required by the trust boundary.

Name: Assuming standard XML parsers are hardened against hostile documents  
Rule: Attacker-controlled XML `MUST NOT` be processed with a standard XML parser unless the selected parser and configuration address the applicable documented XML attacks.

Name: Attacker-controlled second argument to `urljoin()`  
Rule: Attacker-controlled input `MUST NOT` be passed directly as the second argument to `urljoin()` when the result is required to remain under the base URL.

Name: Treating `urlparse()` as URL validation  
Rule: Parsed URL components `MUST` be explicitly validated before being used for security-sensitive decisions; successful `urlparse()` or `urlsplit()` parsing `MUST NOT` be treated as validation.

Name: SQL construction with Python string formatting  
Rule: SQL data values `MUST` be passed through the database driver's parameter-binding mechanism and `MUST NOT` be interpolated with f-strings, concatenation, `%`, or `.format()`.

Name: Unsynchronized shared SQLite connections  
Rule: If an SQLite connection is shared across threads with `check_same_thread=False`, writes through that connection `MUST` be explicitly serialized.

Name: Permission pre-checks with `os.access()`  
Rule: Code `SHOULD NOT` use `os.access()` as a precondition before a filesystem operation when it can instead attempt the operation directly and handle failure.

Name: Using `commonprefix()` for path containment  
Rule: `os.path.commonprefix()` `MUST NOT` be used to enforce filesystem path containment; containment checks `MUST` use path-aware canonicalization and component-aware comparison.

Name: Assuming `zipfile.Path` prevents path traversal  
Rule: Untrusted paths obtained through `zipfile.Path` `MUST` be validated before filesystem extraction or writes because `zipfile.Path` itself does not provide path-traversal protection.

Name: Private package discovery with `--extra-index-url`  
Rule: `pip --extra-index-url` `MUST NOT` be relied upon to securely resolve uniquely named private packages alongside a public index.

Name: Assuming ordinary pip installs provide strong supply-chain integrity  
Rule: Environments requiring strong installation integrity `MUST` pin dependencies and verify hashes, and environments that cannot permit arbitrary source-build execution `MUST` restrict installation to trusted binary distributions.

Name: TLS contexts without certificate and hostname verification  
Rule: TLS clients that require peer authentication `MUST` enable certificate and hostname verification and `SHOULD` use `ssl.create_default_context()` or `PROTOCOL_TLS_CLIENT`.

Name: `http.server` in production  
Rule: `http.server` `MUST NOT` be used as a production HTTP server.

Name: Treating compound shared-state operations as atomic  
Rule: Shared read-modify-write sequences and multi-operation invariants `MUST` use explicit synchronization rather than relying on the atomicity of individual built-in operations.

Name: Relying on the GIL for thread safety  
Rule: Code correctness `MUST NOT` depend on the CPython GIL implicitly serializing access to shared mutable state.

Name: Daemon threads for work requiring cleanup  
Rule: Essential persistent, transactional, or cleanup-dependent work `MUST NOT` exist only in daemon threads and `MUST` have an explicit shutdown and completion mechanism.

Name: Forking a multithreaded process  
Rule: Python programs `SHOULD NOT` call `os.fork()` from a multithreaded process unless the post-fork constraints are explicitly understood and satisfied.

Name: Missing multiprocessing main guard  
Rule: Code that creates multiprocessing workers under spawn or forkserver `MUST` protect the process-creating entry point with `if __name__ == "__main__":`.

Name: Non-importable multiprocessing targets  
Rule: Multiprocessing targets and arguments used with spawn or forkserver `MUST` be picklable, and worker callables `MUST` be defined in an importable context.

Name: Force-terminating processes that hold shared resources  
Rule: A process `MUST NOT` be force-terminated while it may hold queues, pipes, locks, semaphores, or other shared resources when corruption or unreleased state would be unacceptable.

Name: Joining a multiprocessing producer before draining its queue  
Rule: A process that has produced buffered multiprocessing queue data `MUST NOT` be joined before the data is drained when its feeder thread may still be flushing the queue.

Name: Executor tasks waiting on the same exhausted executor  
Rule: A task running in a bounded executor `MUST NOT` synchronously wait for work that can execute only in the same executor when all workers can become occupied by such waiting tasks.

Name: Blocking the asyncio event loop  
Rule: Asyncio event-loop code `MUST NOT` perform materially blocking synchronous I/O or CPU-bound work directly when doing so would prevent other tasks from progressing.

Name: Calling a coroutine without awaiting or scheduling it  
Rule: Every coroutine object intended to execute `MUST` be awaited or explicitly scheduled.

Name: Swallowing `CancelledError`  
Rule: Code that catches `asyncio.CancelledError` `SHOULD` re-raise it after cleanup unless cancellation is intentionally and completely suppressed.

Name: Losing references to background asyncio tasks  
Rule: Independently scheduled asyncio tasks `MUST` retain a strong reference until completion unless their lifecycle is managed by a structure such as `TaskGroup`.

Name: Calling non-thread-safe asyncio APIs from worker threads  
Rule: Code running outside the event-loop thread `MUST` use thread-safe asyncio entry points such as `call_soon_threadsafe()` or `run_coroutine_threadsafe()` rather than directly invoking non-thread-safe loop operations.

Name: `threading.local()` for asyncio-local state  
Rule: Logical context that must remain isolated between asyncio tasks `MUST` use `ContextVar` or an equivalent task-aware mechanism rather than `threading.local()`.

Name: Lock acquisition inside signal handlers  
Rule: Python signal handlers `MUST NOT` acquire ordinary synchronization locks that can already be held by interrupted code.

Name: Using `os._exit()` as an ordinary exit mechanism  
Rule: Normal Python termination `MUST` use `sys.exit()` or normal control flow; `os._exit()` `SHOULD` be reserved for specialized cases such as post-fork child termination where cleanup must be bypassed.

Name: Assuming `sys.exit()` from a worker thread exits the process  
Rule: Worker threads `MUST NOT` use `sys.exit()` as a process-wide shutdown mechanism.

Name: Treating type annotations as runtime validation  
Rule: Runtime input or state validation `MUST NOT` rely solely on type annotations because ordinary annotations are not enforced by Python at runtime.

Name: Treating `typing.cast()` as a runtime cast  
Rule: `typing.cast()` `MUST NOT` be used as runtime validation or conversion because it returns the value unchanged.

Name: Unnecessary use of `Any`  
Rule: `Any` `SHOULD` be used only when bypassing static type checking is intentional; checked alternatives such as `object`, protocols, unions, or generics `SHOULD` be used when their constraints can be expressed.

Name: Installing project dependencies into the system Python  
Rule: Project-specific third-party dependencies `SHOULD` be installed in an isolated environment and `MUST NOT` override an externally managed system Python except through an explicitly chosen supported mechanism.

Name: Undeclared build dependencies  
Rule: A Python project `MUST` declare its build backend and required build-time dependencies in `[build-system]` rather than depending on packages incidentally present in the developer environment.

Name: Assuming an import name identifies the package to install  
Rule: An unknown import name `MUST NOT` be automatically used as a package-installation name without verifying the intended distribution package.

Name: Silent truncation with `zip()`  
Rule: When all zipped iterables are required to have equal length, code `MUST` use `zip(..., strict=True)` or perform an equivalent explicit length check.

Name: Assignment does not copy objects  
Rule: When independently mutable state is required, code `MUST` explicitly create or copy the object rather than relying on assignment to duplicate it.

Name: Assuming a shallow copy duplicates nested state  
Rule: A shallow copy `MUST NOT` be used when nested mutable objects are required to be independent unless those nested objects are separately copied or reconstructed.

Name: Mutable class variables used as per-instance state  
Rule: Mutable state intended to be unique to each instance `MUST` be initialized per instance rather than stored in a shared class variable.

Name: Nested mutable sequences created with repetition  
Rule: Sequence repetition `MUST NOT` be used to create nested mutable elements that are intended to be independent.

Name: Mutable dataclass defaults  
Rule: Mutable dataclass fields intended to be unique per instance `MUST` use `field(default_factory=...)` or another per-instance factory.

Name: Late-bound closures in loops  
Rule: A closure created in a loop `MUST` explicitly bind the current loop value when each closure is intended to retain a different iteration value.

Name: Assignment unexpectedly making a variable local  
Rule: A function that must assign to an enclosing or global binding `MUST` declare the appropriate `nonlocal` or `global` scope or avoid assigning to that name locally.

Name: Augmented assignment can mutate before failing  
Rule: Code `MUST NOT` use augmented assignment through an immutable container element when the contained object's in-place operation can mutate state before reassignment fails.

Name: Mutable values with `dict.fromkeys()`  
Rule: `dict.fromkeys()` `MUST NOT` be given a shared mutable value when each key requires independent mutable state.

Name: `defaultdict.get()` bypasses the factory  
Rule: Code that intends a missing `defaultdict` key to invoke `default_factory` `MUST` use indexing rather than `get()`.

Name: Mutating a dict while iterating it  
Rule: Code `MUST NOT` add or remove dictionary entries while directly iterating that dictionary or its dynamic views; it `MUST` iterate a snapshot or otherwise separate traversal from structural mutation.

Name: Treating dictionary views as snapshots  
Rule: Code requiring a fixed snapshot of dictionary keys, values, or items `MUST` materialize the view rather than retaining the dynamic view object.

Name: `groupby()` without grouping consecutive equal keys  
Rule: `itertools.groupby()` `MUST` be used only when records with the same grouping key are consecutive, with sorting or equivalent ordering performed first when global grouping is intended.

Name: Saving `groupby()` group iterators for later  
Rule: A subgroup returned by `itertools.groupby()` `MUST` be materialized before advancing the parent iterator if the subgroup is needed afterward.

Name: Unbounded buffering with `itertools.tee()`  
Rule: `itertools.tee()` `SHOULD NOT` be used when duplicated iterators may advance far apart enough to cause unacceptable hidden buffering.

Name: Raising `StopIteration` inside generators  
Rule: Generator code `MUST` terminate with `return` or normal exhaustion and `MUST NOT` deliberately raise `StopIteration` to end iteration.

Name: Assignment-expression targets leaking from comprehensions  
Rule: An assignment expression inside a comprehension `SHOULD NOT` target a containing-scope name whose existing binding must remain unchanged.

Name: Bare names in structural pattern matching  
Rule: A bare identifier `MUST NOT` be used in a `case` pattern when the intent is to compare against an existing constant; a literal or qualified value pattern `MUST` be used instead.

Name: `is` for value equality  
Rule: Value equality `MUST` use `==` or `!=`, while `is` and `is not` `MUST` be reserved for identity checks.

Name: Boolean and numeric keys colliding  
Rule: Values such as `True`, `1`, and `1.0` `MUST NOT` be used as distinct dict or set keys when the application requires them to represent different keys.

Name: Assuming `and` and `or` return booleans  
Rule: Code `MUST NOT` use `value or default` or equivalent truth-value selection when legitimate falsey values must be preserved as distinct from missing values.

Name: Exact equality for computed floating-point values  
Rule: Computed floating-point values that represent approximate quantities `SHOULD` be compared using a domain-appropriate tolerance rather than exact equality.

Name: `math.isclose()` against zero without `abs_tol`  
Rule: A tolerance-based comparison against zero with `math.isclose()` `MUST` provide a meaningful nonzero `abs_tol` when nonzero values near zero are intended to count as close.

Name: Constructing exact decimals from binary floats  
Rule: Decimal quantities that originate as exact decimal values `SHOULD` construct `Decimal` from an exact representation such as a string rather than from a binary float.

Name: Using `timedelta.seconds` for total duration  
Rule: Code requiring the total duration in seconds `MUST` use `timedelta.total_seconds()` rather than the `.seconds` component.

Name: Naive UTC datetimes  
Rule: New code representing UTC `SHOULD` use timezone-aware datetimes rather than naive UTC values produced by APIs such as `utcnow()` or `utcfromtimestamp()`.

Name: Calling `timestamp()` on naive UTC  
Rule: A naive datetime representing UTC `MUST` be assigned the correct UTC timezone before `.timestamp()` is used.

Name: Wall-clock time for elapsed durations  
Rule: Elapsed-time measurements and deadlines `MUST` use a monotonic clock such as `time.monotonic()` or `time.perf_counter()` rather than `time.time()`.

Name: Implicit text-file encoding  
Rule: Code reading or writing a text format with a defined encoding `SHOULD` specify that encoding explicitly rather than relying on the platform or interpreter default.

Name: Silently ignoring encoding errors  
Rule: `errors="ignore"` `SHOULD NOT` be used for text decoding or encoding unless silent irreversible loss of invalid data is explicitly acceptable.

Name: Opening CSV files without `newline=""`  
Rule: Text files passed to `csv.reader` or `csv.writer` `MUST` be opened with `newline=""`.

Name: Serializing `None` through `csv.writer`  
Rule: When CSV output must preserve the distinction between `None` and an empty string, nullable values `MUST` be explicitly encoded before being passed to `csv.writer`.

Name: Repeated `json.dump()` calls as one JSON document  
Rule: Multiple independent `json.dump()` results `MUST NOT` be concatenated and treated as one JSON document; an explicit framing mechanism or enclosing JSON structure `MUST` be used.

Name: Non-standard NaN and Infinity in JSON  
Rule: JSON output required to conform strictly to the JSON specification `MUST` disable non-standard `NaN` and infinity values, such as with `allow_nan=False`.

Name: Duplicate JSON object names  
Rule: When duplicate JSON object member names are invalid for an input contract, decoding `MUST` use a mechanism that detects and rejects or explicitly handles duplicates.

Name: Assuming JSON preserves non-string dict keys  
Rule: Non-string mapping keys `MUST` be encoded explicitly when their original types must survive a JSON round trip.

Name: Using `strip()` to remove a literal prefix or suffix  
Rule: Literal string prefixes and suffixes `MUST` be removed with `removeprefix()` or `removesuffix()` rather than `strip()`, `lstrip()`, or `rstrip()` with the literal as their character argument.

Name: Regular expressions without raw strings  
Rule: Regular-expression literals containing backslashes `SHOULD` use raw string literals unless ordinary Python string escaping is intentionally required.

Name: Confusing `re.match()`, `search()`, and `fullmatch()`  
Rule: Regular-expression code `MUST` use `search()` for anywhere matching, `match()` for start-position matching, and `fullmatch()` when the entire string must satisfy the pattern.

Name: Heap entries without a tie-breaker  
Rule: Heap entries with potentially equal priorities `MUST` include a comparable tie-breaker when the remaining entry fields are not guaranteed to be mutually orderable.

Name: `argparse` with `type=bool`  
Rule: Boolean command-line arguments `MUST NOT` use `argparse` with `type=bool`; they `MUST` use an appropriate boolean action or explicit text parser.

Name: `deque.extendleft()` reversing input order  
Rule: Code using `deque.extendleft()` `MUST` account for its reversal of input order and `MUST` reverse the input first when original order must be preserved.

Name: Treating `Counter` as a strictly positive multiset  
Rule: When a `Counter` is required to represent only positive multiplicities, zero and negative counts `MUST` be removed or normalized before that invariant is relied upon.

Name: Caching generators, coroutines, or side-effectful functions  
Rule: `functools.cache` and `lru_cache` `MUST NOT` be applied when each call must produce a fresh generator or coroutine, repeat side effects, or obtain fresh external state.

Name: `lru_cache` on instance methods retaining instances  
Rule: Instance methods on large or short-lived object populations `SHOULD NOT` use long-lived `lru_cache` caching unless retaining referenced instances in the cache is acceptable.

Name: Assuming `cached_property` computes exactly once under concurrency  
Rule: A `cached_property` whose getter must execute at most once `MUST` provide explicit synchronization rather than relying on `cached_property` itself.

Name: Assuming `lru_cache` suppresses duplicate concurrent calls  
Rule: Code requiring single-flight execution `MUST NOT` rely on `lru_cache` to prevent concurrent duplicate calls.

Name: Wildcard imports  
Rule: `from module import *` `SHOULD NOT` be used except in deliberately controlled namespace-export scenarios.

Name: `from module import name` in circular imports  
Rule: Circular import relationships `SHOULD` be refactored, and code `SHOULD NOT` use `from module import name` when the imported module may still be partially initialized.

Name: Reloading modules after `from ... import ...`  
Rule: Code requiring reloadable bindings `MUST NOT` assume `importlib.reload()` updates names previously imported with `from module import name`; it `MUST` use module-qualified access or explicitly rebind those names.

Name: Assuming imports are passive declarations  
Rule: Module import-time code `SHOULD` avoid unnecessary externally visible side effects and `MUST NOT` rely on ordinary repeated imports to re-execute initialization.

Name: Threads as the default solution for CPU-bound Python code  
Rule: On GIL-enabled CPython, ordinary threads `SHOULD NOT` be chosen solely to obtain parallel speedup for CPU-bound Python bytecode.

Name: Assuming `asyncio.gather()` cancels siblings on first failure  
Rule: Code that requires sibling tasks to be cancelled when one child fails `MUST` use `TaskGroup` or another mechanism that explicitly provides that behavior rather than relying on default `asyncio.gather()` semantics.

Name: Concurrent use of `warnings.catch_warnings()` without context-aware warnings  
Rule: When `sys.flags.context_aware_warnings` is false, concurrent uses of `warnings.catch_warnings()` `MUST` be serialized or otherwise prevented from overlapping.

Name: Changing process locale in concurrent code  
Rule: Concurrent code `SHOULD NOT` mutate the process-wide locale with `locale.setlocale()` during normal operation.

Name: Moving or copying virtual environments  
Rule: Virtual environments `MUST` be recreated after relocation rather than treated as portable directories that can be moved or copied intact.

Name: Flat-layout imports hiding packaging errors  
Rule: Projects for which working-tree imports could hide installation or packaging defects `SHOULD` use a `src/` layout or another mechanism that ensures tests exercise the installed package.

Name: Testing only editable installs  
Rule: Distributable projects `SHOULD` test at least one normal built-and-installed distribution in addition to any editable-install workflow.

Name: Direct `setup.py` commands  
Rule: Modern Python projects `SHOULD NOT` invoke `setup.py` commands such as `install`, `develop`, or `sdist` directly and `SHOULD` use standards-based build and installation frontends.

Name: Treating requirements files as project dependency metadata  
Rule: A distributable project's runtime dependencies `MUST` be declared in project metadata, while requirements files `SHOULD` be used for concrete environment or deployment dependency sets.

Name: Treating `pip freeze` as a lockfile solver  
Rule: `pip freeze` output `MUST NOT` be treated as evidence that dependencies were independently solved or as a lockfile with stronger guarantees than the captured environment state.

Name: Assuming mutable generic containers are covariant  
Rule: Mutable generic containers such as `list[Derived]` `MUST NOT` be treated as compatible with `list[Base]`; a covariant read-only abstraction `SHOULD` be used when mutation is not required.

Name: Treating `@runtime_checkable Protocol` as runtime type validation  
Rule: A `@runtime_checkable Protocol` check `MUST NOT` be treated as validation of complete method signatures, annotations, or static type contracts.

Name: Treating `TypedDict` as a runtime record type  
Rule: `TypedDict` `MUST NOT` be relied upon to validate keys or values at runtime.

Name: Reading annotations directly from `__annotations__`  
Rule: Runtime annotation introspection `SHOULD` use the supported annotation or inspection APIs rather than directly interpreting `__annotations__`.

Name: Evaluating string annotations unnecessarily  
Rule: Runtime code `SHOULD NOT` evaluate string annotations unless actual evaluated annotation values are required.

Name: Patching where an object is defined rather than looked up  
Rule: `unittest.mock.patch` `MUST` target the namespace where the code under test looks up the object.

Name: Unconstrained mocks masking API mistakes  
Rule: Mocks representing a real API `SHOULD` use `spec`, `spec_set`, or `autospec` when nonexistent attributes or invalid call signatures should cause the test to fail.

Name: Inspecting mutated mock arguments after the call  
Rule: Tests that must verify a mutable argument's state at call time `MUST` snapshot that argument at call time rather than relying on the mock's retained reference.

Name: Ignoring deprecation warnings in test suites  
Rule: Development and test configurations `SHOULD` surface relevant deprecation warnings that are hidden by Python's default warning filters.

Name: Libraries configuring the root logger  
Rule: Library code `MUST NOT` configure the root logger or install application logging handlers as an import side effect and `SHOULD` log through a named library logger.

Name: Eager string formatting in disabled logging calls  
Rule: Logging calls whose message construction is materially expensive `SHOULD` pass the format string and arguments separately rather than eagerly constructing the formatted message.

Name: Relying on `__del__` for important behavior  
Rule: `__del__` `SHOULD NOT` be responsible for correctness-critical cleanup, lock acquisition, or deterministic resource release.

Name: `weakref.finalize()` callback retaining its object  
Rule: A `weakref.finalize()` callback `MUST NOT` directly or indirectly hold a strong reference to the object it is intended to finalize.

Name: Treating `__slots__` as a transparent memory optimization  
Rule: `__slots__` `SHOULD NOT` be introduced as a transparent optimization unless its effects on inheritance, weak references, instance dictionaries, defaults, and object layout are acceptable.

Name: Using `IntEnum` when integer interoperability is unnecessary  
Rule: New APIs `SHOULD` use `Enum` or `Flag` instead of `IntEnum` when compatibility with integer APIs is not required.

Name: Returning `False` instead of `NotImplemented` for unsupported comparisons  
Rule: Custom rich-comparison and numeric methods `MUST` return `NotImplemented` when the operand type is unsupported rather than returning a result that prevents Python's reflected or fallback operation.

Name: Non-cooperative superclass calls in multiple inheritance  
Rule: A hierarchy designed for cooperative multiple inheritance `MUST` use compatible method signatures and cooperative `super()` calls throughout the participating classes.

Name: Assuming `getctime()` means creation time everywhere  
Rule: `os.path.getctime()` `MUST NOT` be interpreted as a portable file-creation timestamp.

Name: Absolute components resetting `os.path.join()`  
Rule: Path components expected to remain relative to a trusted base `MUST` be validated as relative before being passed to `os.path.join()` or an equivalent path join.

Name: Lexical parent walking without resolving symlinks  
Rule: When filesystem ancestry must reflect resolved symlink targets, code `SHOULD` resolve the path before performing lexical parent traversal.

Name: Assuming `shutil.copy*` creates a full filesystem clone  
Rule: Code requiring specific ownership, ACL, extended-attribute, alternate-stream, or other filesystem metadata preservation `MUST` explicitly preserve or verify that metadata rather than assuming `shutil.copy*` does so.

Name: Reading immediately after `copyfileobj()` without flushing  
Rule: A destination written with `shutil.copyfileobj()` `MUST` be flushed or closed before code immediately reads or otherwise depends on the completed buffered output.

Name: Repeated immutable-string concatenation in loops  
Rule: Code constructing a string from many pieces `SHOULD` use `str.join()` or an appropriate buffer instead of repeatedly growing an immutable string in a loop.

Name: Comparing with `None` using equality  
Rule: Comparisons with `None` `SHOULD` use `is None` or `is not None` rather than equality operators.

Name: Exact type checks instead of `isinstance()`  
Rule: Runtime type checks `SHOULD` use `isinstance()` rather than exact `type(...) is ...` comparisons when valid subclasses are intended to satisfy the check.

Name: Comparing sequence length with zero  
Rule: Container emptiness checks `SHOULD` use Python truth-value testing rather than comparing `len(container)` with zero.

Name: Comparing booleans to `True` or `False`  
Rule: Boolean conditions `SHOULD` use direct truth-value tests rather than equality comparisons with `True` or `False` unless literal boolean identity is semantically required.

Name: Prefix and suffix tests through slicing  
Rule: String prefix and suffix checks `SHOULD` use `startswith()` and `endswith()` rather than manual slicing.

Name: Assigning a lambda to a name  
Rule: A callable that requires a durable descriptive name `SHOULD` be defined with `def` rather than assigned from a `lambda`.

Name: Legacy `and/or` conditional expressions  
Rule: Conditional value selection `SHOULD` use the conditional expression form and `SHOULD NOT` use the historical `condition and a or b` pattern.

Name: Forgetting the comma in a one-element tuple  
Rule: A one-element tuple `MUST` include a trailing comma.

Name: Treating double-underscore attributes as private security boundaries  
Rule: Double-leading-underscore name mangling `MUST NOT` be relied upon as a security or access-control boundary.

Name: Depending on set iteration order  
Rule: Code whose contract requires deterministic set traversal `MUST` explicitly impose an order rather than relying on set iteration order.

Name: Comparing `dict.values()` views for content equality  
Rule: Code requiring content equality of dictionary values `MUST NOT` rely on equality comparison between `dict.values()` views and `MUST` compare an appropriate materialized or normalized representation.

Name: Persisting or interpreting `id()` as a permanent object identifier  
Rule: `id()` values `MUST NOT` be persisted or used as durable or globally unique object identifiers beyond the lifetime of the referenced object.

Name: Persisting built-in string hashes  
Rule: Built-in `hash()` values for strings or bytes `MUST NOT` be persisted when a stable cross-process digest or identifier is required.

Name: Chaining mutating methods that return `None`  
Rule: In-place mutating methods documented to return `None` `MUST` be treated as mutation statements and `MUST NOT` be chained or consumed as though they return the modified object.

Name: Manual index loops over sequences  
Rule: Sequence iteration `SHOULD` use direct iteration or `enumerate()` rather than `range(len(sequence))` when explicit numeric indexing is not independently required.

Name: Returning a value from `__init__()`  
Rule: `__init__()` `MUST` return `None` and `MUST NOT` return an alternate constructed value.

Name: Zero-argument `super()` inside nested functions  
Rule: A nested function or generator `MUST NOT` rely on zero-argument `super()` to infer the intended method context; it `MUST` use an explicit form or move the call to the appropriate method scope.

Name: Subscripting a `super` object  
Rule: Code `MUST NOT` use `super()[key]` to invoke inherited subscription behavior and `MUST` call the relevant special method explicitly, such as `super().__getitem__(key)`.

Name: Directly modifying module `__dict__`  
Rule: Code `SHOULD` use normal attribute assignment or supported APIs rather than directly mutating a module's `__dict__` unless low-level symbol-table manipulation is intentionally required.

Name: One-shot generator context-manager instances  
Rule: A context-manager instance created by a generator-based `@contextmanager` function `MUST NOT` be entered more than once; a new instance `MUST` be created for each use.

Name: Assuming `final` is runtime enforcement  
Rule: `@final` `MUST NOT` be relied upon to prevent subclassing or overriding at runtime.

Name: Assuming `NewType` constructs a runtime wrapper object  
Rule: `NewType` `MUST NOT` be relied upon for runtime wrapping, conversion, or validation.

Name: Assuming `@override` changes runtime dispatch  
Rule: `@override` `MUST NOT` be relied upon to alter or enforce runtime method dispatch.

Name: Using EAFP as an unconditional rule  
Rule: Code `SHOULD` use EAFP where pre-checks would race with or unnecessarily duplicate the operation, but `SHOULD NOT` replace clear race-free precondition checks solely to conform to EAFP.
:::
