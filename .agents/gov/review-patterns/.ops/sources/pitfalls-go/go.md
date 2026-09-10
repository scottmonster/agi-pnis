#### User said:

Research as comprehensively as practical for Go-specific pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms, especially cases where experienced Go developers recommend "do this instead of that."

The goal is to identify as many distinct, materially useful Go practices as possible, not just the most popular or obvious examples.

Research across the full Go language, type system, runtime behavior, standard library, concurrency model, memory behavior where relevant, tooling, module/package behavior, standard development practices, and ecosystem conventions that broadly affect Go development.

Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.

Actively look for unexpected or less obvious classes of issues that may not fit common Go best-practice lists.

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
- Impact - High, Medium, or Low based on how materially the issue can affect correctness, reliability, maintainability, security, performance, resource usage, concurrency safety, or development outcomes.
- Consensus - High, Medium, or Low based on how broadly the recommendation is supported by authoritative sources and experienced Go practitioners.
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

- official Go documentation
- the Go specification
- Effective Go
- Go blog and official Go team guidance
- Go release notes and proposals
- standard library documentation
- Go tooling documentation
- guidance from Go maintainers and contributors
- established engineering documentation
- respected Go experts and practitioners
- technically rigorous articles and discussions

Do not treat popularity, repetition, lint warnings, or search ranking alone as evidence of correctness or consensus. Investigate the underlying technical reason for each recommendation.

Evaluate Impact and Consensus independently. A finding may have high impact but low consensus, or low impact but high consensus.

Include disputed practices when they are materially relevant, but assign an appropriate Consensus rating and accurately describe the disagreement rather than presenting one side as settled guidance.

Avoid duplicate findings that describe the same underlying issue. Merge substantially equivalent recommendations while preserving genuinely different cases, conditions, or failure modes.

Focus on guidance specific to Go, including language semantics, interfaces, generics, error handling, concurrency, goroutines, channels, synchronization, context propagation, resource management, memory allocation, slices, maps, pointers, packages, modules, APIs, testing, and tooling when those topics emerge from the research.

Do not treat those examples as a predetermined taxonomy or checklist. They are illustrative only. Discovery should remain open-ended and evidence-driven.

Do not fill the results with generic programming advice unless Go introduces a distinct consideration.

Do not stop after finding a conventional "Go best practices" or "Effective Go" list. Treat commonly repeated guidance as a starting point to investigate, not as automatically correct or complete.

Use iterative discovery to identify additional terminology, failure modes, recommendations, and sources from the findings themselves.

Continue researching until further searching is producing primarily duplicates, minor stylistic preferences, weakly supported claims, or findings with little practical significance.

-----
#### Assistant said:

I’ll use the Go specification, official Go documentation, standard-library docs, Go blog, release notes, proposals, and Go-maintained guidance as the evidence base. I’ll also check version-sensitive hazards so obsolete pre-Go-1.22 advice is not presented as current without qualification.

-----
#### Assistant said:

The first pass confirms the current stable line is Go 1.26, with Go 1.26.6 released August 13, 2026; Go 1.27 is still marked draft as of today. That matters because several classic Go pitfalls have changed semantics in recent releases, especially loop variables and timers.

-----
#### Assistant said:

A second pattern is emerging beyond the usual beginner lists: many high-risk Go bugs are lifecycle bugs rather than syntax mistakes. Context cancellation, goroutine termination, response bodies, SQL rows, timers, and synchronization objects all have contracts that are easy to violate while still compiling cleanly.

-----
#### Assistant said:

Baseline: this is current to **Go 1.26.6**, released August 13, 2026. I treated Go 1.27 material as draft rather than current behavior. citeturn388082view0turn388082view1

## 1. High Impact

**Name:** Synchronize all shared mutable state  
**Category:** Memory model and data races  
**Impact:** High  
**Consensus:** High  
**Description:** Do not read and write shared memory concurrently without synchronization. Use channels, mutexes, atomics, or another documented happens-before relationship.  
**Why:** A data race makes program behavior unreliable, and races on multiword values such as interfaces, slices, and pointers can produce internally inconsistent values.  
**Source URL:** https://go.dev/ref/mem citeturn539047view1

**Name:** Make every goroutine's lifetime explicit  
**Category:** Goroutine lifecycle  
**Impact:** High  
**Consensus:** High  
**Description:** Every goroutine should have a clear condition under which it exits. Avoid goroutines that can remain indefinitely blocked after their work is no longer needed.  
**Why:** The garbage collector does not terminate unreachable blocked goroutines. Leaks retain memory and resources and can leave concurrent access continuing unexpectedly.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Goroutine termination is not synchronization  
**Category:** Synchronization semantics  
**Impact:** High  
**Consensus:** High  
**Description:** Do not start a goroutine, let it write shared state, and assume its eventual termination makes those writes visible. Synchronize completion explicitly.  
**Why:** The Go memory model states that goroutine exit does not establish a happens-before relationship.  
**Source URL:** https://go.dev/ref/mem citeturn539047view1

**Name:** Cancel pipelines when downstream stops early  
**Category:** Concurrency cancellation  
**Impact:** High  
**Consensus:** High  
**Description:** Pipeline stages must stop sending when downstream consumers return early. Propagate cancellation rather than leaving upstream goroutines blocked on sends.  
**Why:** Otherwise upstream goroutines can leak permanently while retaining data and other resources.  
**Source URL:** https://go.dev/blog/pipelines citeturn547724search30

**Name:** Bound concurrency instead of spawning without limit  
**Category:** Concurrency backpressure  
**Impact:** High  
**Consensus:** High  
**Description:** Put an explicit limit on simultaneously active work when the input size can grow. Worker pools or `errgroup.SetLimit` are preferable to one unrestricted goroutine per item.  
**Why:** Goroutines are cheap, not free. Unbounded creation can exhaust memory, descriptors, downstream services, or scheduling capacity.  
**Source URL:** https://pkg.go.dev/golang.org/x/sync/errgroup citeturn819137search0

**Name:** Prefer `WaitGroup.Go` or perform `Add` before launching  
**Category:** Goroutine accounting  
**Impact:** High  
**Consensus:** High  
**Description:** On current Go, prefer `WaitGroup.Go` for ordinary goroutine accounting. When manually using `Add`, increment before starting the goroutine rather than from inside it.  
**Why:** Calling `Wait` before a goroutine has performed its `Add` can let `Wait` return prematurely.  
**Source URL:** https://pkg.go.dev/sync citeturn539047view3

**Name:** Always call returned context cancellation functions  
**Category:** Context lifecycle  
**Impact:** High  
**Consensus:** High  
**Description:** When `WithCancel`, `WithTimeout`, or `WithDeadline` returns a `CancelFunc`, arrange to call it, normally with `defer cancel()`.  
**Why:** Failing to cancel retains the child context and associated timers and descendants until the parent eventually terminates.  
**Source URL:** https://pkg.go.dev/context citeturn539047view2

**Name:** Propagate request contexts end to end  
**Category:** Context propagation  
**Impact:** High  
**Consensus:** High  
**Description:** Pass the incoming context through database, RPC, HTTP, and other request-scoped calls. Do not replace it with `context.Background()` in the middle of the call chain.  
**Why:** Replacing the context loses cancellation, deadlines, tracing, credentials, and other request lifecycle information.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Remember that nil channels block forever  
**Category:** Channel semantics  
**Impact:** High  
**Consensus:** High  
**Description:** Sending to or receiving from a nil channel blocks forever. Deliberately use nil channels only when disabling a `select` case is intended.  
**Why:** An accidentally nil channel can silently deadlock a goroutine or whole program instead of producing a useful failure.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Close channels only when no future send is possible  
**Category:** Channel lifecycle  
**Impact:** High  
**Consensus:** High  
**Description:** Coordinate channel closure with all producers. Sending on a closed channel panics, as does closing an already closed channel; closing a nil channel also panics.  
**Why:** Closing is part of the communication protocol, not general cleanup that can safely be attempted from arbitrary goroutines.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Recovery cannot cross goroutine boundaries  
**Category:** Panic containment  
**Impact:** High  
**Consensus:** High  
**Description:** A panic must be recovered by a deferred function running in the same goroutine. A parent or supervisor goroutine cannot recover another goroutine's panic.  
**Why:** An unrecovered panic reaching the top of any goroutine terminates the program.  
**Source URL:** https://go.dev/blog/defer-panic-and-recover citeturn547724search0

**Name:** Treat loop capture rules as version and declaration sensitive  
**Category:** Loop variable semantics  
**Impact:** High  
**Consensus:** High  
**Description:** Go 1.22+ gives variables declared by a range clause with `:=` a new variable per iteration. Older language versions retain the old capture behavior, and current loops assigning into predeclared variables with `=` still reuse those variables.  
**Why:** Closures or goroutines can otherwise observe a later iteration's value instead of the intended one.  
**Source URL:** https://go.dev/blog/loopvar-preview citeturn351811search24

**Name:** Synchronize concurrent map access  
**Category:** Map concurrency  
**Impact:** High  
**Consensus:** High  
**Description:** Do not concurrently modify an ordinary map while another goroutine reads or modifies it. Protect it with synchronization or use an appropriate specialized structure.  
**Why:** Ordinary maps are not a concurrent data structure, and unsynchronized access is a data race.  
**Source URL:** https://go.dev/ref/mem citeturn539047view1

**Name:** Treat slices as shared views, not independent values  
**Category:** Slice ownership  
**Impact:** High  
**Consensus:** High  
**Description:** Copying a slice copies its descriptor, not its elements. Sub-slices commonly share the same backing array, and `append` can modify data visible through another slice when capacity permits.  
**Why:** Unclear ownership causes surprising mutation and, under concurrency, data races. Copy elements when independent ownership is required.  
**Source URL:** https://go.dev/blog/slices-intro citeturn225909search3

**Name:** Always use the returned slice after length-changing operations  
**Category:** Slice mutation  
**Impact:** High  
**Consensus:** High  
**Description:** Assign the result of `append`, `slices.Delete`, `slices.Compact`, `slices.Insert`, `slices.Replace`, and similar functions back to the slice you intend to continue using.  
**Why:** These operations may return a new slice header or backing array. Ignoring the result can lose data or leave the caller using the wrong length.  
**Source URL:** https://go.dev/blog/generic-slice-functions citeturn298508search32

**Name:** Do not copy synchronization objects after first use  
**Category:** Synchronization object identity  
**Impact:** High  
**Consensus:** High  
**Description:** `Mutex`, `RWMutex`, `WaitGroup`, `Once`, `Pool`, `Cond`, `sync.Map`, atomic wrapper types, and other documented no-copy synchronization objects must not be copied after use.  
**Why:** Copies can contain synchronization state referring to different object identities and destroy the intended locking or coordination guarantees.  
**Source URL:** https://pkg.go.dev/sync citeturn539047view3

**Name:** A typed nil inside an interface is not a nil interface  
**Category:** Interface representation  
**Impact:** High  
**Consensus:** High  
**Description:** An interface containing a typed nil pointer is non-nil because its dynamic type is present. Avoid returning typed nil pointers as `error` or other interfaces when you intend to return nil.  
**Why:** Checks such as `err != nil` can unexpectedly succeed even though the underlying pointer is nil.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Interface equality can panic  
**Category:** Interface comparability  
**Impact:** High  
**Consensus:** High  
**Description:** Do not assume every pair of interface values can safely be compared with `==`. Comparison panics when the dynamic value is not comparable, such as a slice or map.  
**Why:** The interface type itself is comparable, but runtime comparability depends on the contained dynamic type.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Use wrapper-aware error inspection  
**Category:** Error identity  
**Impact:** High  
**Consensus:** High  
**Description:** Use `errors.Is` for sentinel identity and `errors.AsType` in Go 1.26+ where appropriate for wrapped error types, rather than direct equality or one-level type assertions.  
**Why:** Error wrapping creates chains and trees that direct comparison or assertion cannot traverse.  
**Source URL:** https://pkg.go.dev/errors citeturn637086search5turn637086search2

**Name:** Treat `%w` as an API commitment  
**Category:** Error API design  
**Impact:** High  
**Consensus:** High  
**Description:** Wrap an underlying error with `%w` only when callers should be able to depend on that error identity or type. Use `%v` when the underlying implementation detail should remain hidden.  
**Why:** Once callers use `errors.Is` or `errors.As`, changing the wrapped error can become a compatibility break.  
**Source URL:** https://go.dev/blog/go1.13-errors citeturn527980search0

**Name:** Never wrap `io.EOF`  
**Category:** I/O error contracts  
**Impact:** High  
**Consensus:** High  
**Description:** Readers that signal end of input should return `io.EOF` itself rather than a wrapped form.  
**Why:** The `io.Reader` contract explicitly relies on EOF semantics, and callers are allowed to depend on the sentinel directly.  
**Source URL:** https://pkg.go.dev/io citeturn637086search30

**Name:** Do not silently discard meaningful errors  
**Category:** Error handling  
**Impact:** High  
**Consensus:** High  
**Description:** Handle, propagate, or deliberately document ignored errors rather than routinely assigning them to `_`.  
**Why:** Go APIs frequently use the error result to report partial writes, flush failures, rollback conditions, malformed input, and cleanup failures that are otherwise invisible.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Process bytes before handling a simultaneous read error  
**Category:** Reader semantics  
**Impact:** High  
**Consensus:** High  
**Description:** An `io.Reader` may return both `n > 0` and a non-nil error. Process the `n` bytes before acting on the error.  
**Why:** Treating any error as meaning no data was returned can silently drop the final bytes of a stream.  
**Source URL:** https://pkg.go.dev/io citeturn462839search1

**Name:** Bound reads from untrusted or potentially large streams  
**Category:** Memory and input limits  
**Impact:** High  
**Consensus:** High  
**Description:** Do not use `io.ReadAll` on an unbounded attacker-controlled or arbitrarily large source. Apply an appropriate limit or stream the content.  
**Why:** `ReadAll` continues allocating until EOF and can turn input size into memory exhaustion.  
**Source URL:** https://pkg.go.dev/io citeturn462839search1

**Name:** Close HTTP response bodies and consume when reuse matters  
**Category:** HTTP connection lifecycle  
**Impact:** High  
**Consensus:** High  
**Description:** When `Client.Do` succeeds, close `resp.Body`. For HTTP/1.x connection reuse, also read the body to EOF when appropriate and safely bounded.  
**Why:** Failing to close bodies leaks resources; abandoning them before EOF can prevent persistent connection reuse.  
**Source URL:** https://pkg.go.dev/net/http citeturn892821view0

**Name:** Put deadlines on outbound HTTP work  
**Category:** Network lifecycle  
**Impact:** High  
**Consensus:** High  
**Description:** Use request contexts, `Client.Timeout`, or appropriately configured transport deadlines for calls that must not wait indefinitely.  
**Why:** The zero `http.Client.Timeout` means no overall timeout, so a stalled dependency can hold goroutines and resources indefinitely.  
**Source URL:** https://pkg.go.dev/net/http citeturn892821view0

**Name:** Configure exposed HTTP servers against slow clients and large bodies  
**Category:** HTTP resource limits  
**Impact:** High  
**Consensus:** High  
**Description:** Set server read/header/write/idle limits appropriate to the deployment and apply `http.MaxBytesReader` before accepting potentially large request bodies.  
**Why:** Default zero timeouts and unbounded bodies can let slow or malicious clients consume server resources for excessive periods.  
**Source URL:** https://pkg.go.dev/net/http citeturn863731search2

**Name:** Parameterize SQL instead of formatting SQL text  
**Category:** Database security  
**Impact:** High  
**Consensus:** High  
**Description:** Pass values as query parameters rather than using `fmt.Sprintf` or string concatenation to construct SQL containing data.  
**Why:** Parameterization prevents data from becoming executable SQL syntax and avoids SQL injection.  
**Source URL:** https://go.dev/doc/database/sql-injection citeturn462839search2

**Name:** Close SQL rows and check `Rows.Err`  
**Category:** Database result lifecycle  
**Impact:** High  
**Consensus:** High  
**Description:** Close `*sql.Rows`, normally with `defer`, and after the iteration loop check `rows.Err()`.  
**Why:** Iteration can stop because of an error that is not returned by `Next` directly, and unclosed rows can retain a pooled connection.  
**Source URL:** https://pkg.go.dev/database/sql citeturn452460view0

**Name:** Use `sql.Tx`, not raw transaction statements  
**Category:** Database transaction integrity  
**Impact:** High  
**Consensus:** High  
**Description:** Use `DB.BeginTx`/`Tx` methods and perform transaction operations through the `Tx`. Do not issue raw `BEGIN`/`COMMIT`, and do not mix `DB` calls into the transaction.  
**Why:** `database/sql` manages a connection pool, so unrelated calls can run on different connections or introduce deadlocks and inconsistent transaction behavior.  
**Source URL:** https://go.dev/doc/database/execute-transactions citeturn139297search3

**Name:** Do not disable TLS verification with `InsecureSkipVerify`  
**Category:** TLS authentication  
**Impact:** High  
**Consensus:** High  
**Description:** Leave certificate and hostname verification enabled unless you are implementing equivalent verification through the documented custom verification hooks.  
**Why:** Plain `InsecureSkipVerify: true` allows man-in-the-middle attacks.  
**Source URL:** https://pkg.go.dev/crypto/tls citeturn254252search0

**Name:** Use `crypto/rand` for security-sensitive randomness  
**Category:** Cryptographic randomness  
**Impact:** High  
**Consensus:** High  
**Description:** Generate keys, tokens, nonces, session identifiers, and other secrets with `crypto/rand`, not `math/rand` or `math/rand/v2`.  
**Why:** The math random packages explicitly are not intended for security-sensitive randomness.  
**Source URL:** https://pkg.go.dev/math/rand/v2 citeturn667682search3

**Name:** Use `html/template` for HTML output  
**Category:** Output escaping  
**Impact:** High  
**Consensus:** High  
**Description:** Render untrusted data into HTML with `html/template`, not `text/template`, and do not convert untrusted strings to trusted `template.HTML`, `template.JS`, or related safe-content types.  
**Why:** `html/template` performs context-sensitive escaping; trusted wrapper types intentionally bypass that protection.  
**Source URL:** https://pkg.go.dev/html/template citeturn254252search2

**Name:** Use `os.Root` for untrusted paths inside a trusted directory  
**Category:** Filesystem traversal security  
**Impact:** High  
**Consensus:** High  
**Description:** When an external filename must remain below a fixed directory, prefer `os.Root` or `os.OpenInRoot` to validating a joined path and opening it later.  
**Why:** Lexical checks and `EvalSymlinks` followed by `Open` can be vulnerable to symlink and time-of-check/time-of-use races.  
**Source URL:** https://go.dev/blog/osroot citeturn863731search3

**Name:** Treat archive entry paths and links as hostile  
**Category:** Archive extraction security  
**Impact:** High  
**Consensus:** High  
**Description:** Do not assume a tar or zip reader makes extracted paths safe. Ensure every extraction remains inside its output root, ideally using `os.Root`.  
**Why:** Archive entries can use `..`, absolute paths, or symlink sequences to escape an extraction directory. Current insecure-path checking in archive packages is not a universal default guarantee.  
**Source URL:** https://go.dev/blog/osroot citeturn863731search3

**Name:** Use `ReverseProxy.Rewrite`, not `Director`, for security-sensitive proxies  
**Category:** Reverse proxy security  
**Impact:** High  
**Consensus:** High  
**Description:** `httputil.ReverseProxy.Director` is deprecated and explicitly documented as insecure. Use `Rewrite` and reconstruct trusted forwarding headers deliberately.  
**Why:** A malicious client can exploit hop-by-hop header removal or preserved `X-Forwarded-*` values to remove proxy-added headers or spoof forwarding information.  
**Source URL:** https://pkg.go.dev/net/http/httputil citeturn863731search0

**Name:** Configure a public suffix list for production cookie jars  
**Category:** Cookie isolation  
**Impact:** High  
**Consensus:** High  
**Description:** Do not use a nil `cookiejar.Options.PublicSuffixList` for a multi-domain production client. Use an appropriate public suffix implementation.  
**Why:** The standard-library documentation explicitly calls nil insecure because one site may otherwise set cookies for another registrable domain.  
**Source URL:** https://pkg.go.dev/net/http/cookiejar citeturn863731search1

**Name:** Configure private module paths before fetching them  
**Category:** Module privacy  
**Impact:** High  
**Consensus:** High  
**Description:** Configure `GOPRIVATE` and, where needed, `GONOPROXY` or `GONOSUMDB` for private module path patterns.  
**Why:** Without appropriate configuration, private module paths may be sent to the public module proxy or checksum database.  
**Source URL:** https://go.dev/ref/mod citeturn276756search0

**Name:** Preserve public module checksum verification  
**Category:** Dependency integrity  
**Impact:** High  
**Consensus:** High  
**Description:** Do not globally disable the checksum database merely to make private modules work. Exempt only the required private path patterns.  
**Why:** The checksum database authenticates previously unknown public module content and helps detect inconsistent or modified downloads.  
**Source URL:** https://go.dev/ref/mod citeturn276756search0

**Name:** Do not store Go pointers in `uintptr`  
**Category:** Unsafe memory lifetime  
**Impact:** High  
**Consensus:** High  
**Description:** Treat `uintptr` as an integer, not a GC-visible pointer. Follow only the conversion patterns explicitly permitted by `unsafe`.  
**Why:** A `uintptr` neither keeps an object alive nor participates in pointer relocation, so saving an address in one can create dangling or invalid pointers.  
**Source URL:** https://pkg.go.dev/unsafe citeturn298508search2

**Name:** Follow cgo pointer retention rules  
**Category:** Go and C memory interoperability  
**Impact:** High  
**Consensus:** High  
**Description:** C code must not retain ordinary Go pointers after a cgo call unless the referenced memory is pinned under the documented rules. Use `runtime.Pinner` or `runtime/cgo.Handle` where appropriate.  
**Why:** The garbage collector needs accurate knowledge of Go pointer ownership and lifetime. Violating the rules can corrupt memory or trigger runtime failures.  
**Source URL:** https://pkg.go.dev/cmd/cgo citeturn793239search2

**Name:** Close deterministic resources explicitly  
**Category:** Garbage collection and external resources  
**Impact:** High  
**Consensus:** High  
**Description:** Do not rely on finalizers, `runtime.AddCleanup`, or weak references to close files, flush buffers, commit data, unlock resources, or perform other required cleanup.  
**Why:** GC-triggered cleanup is nondeterministic and may never run before program exit.  
**Source URL:** https://go.dev/blog/cleanups-and-weak citeturn298508search1

**Name:** Remember that `os.Exit` and `log.Fatal` skip defers  
**Category:** Process termination  
**Impact:** High  
**Consensus:** High  
**Description:** Do not use `os.Exit` or `log.Fatal` from code that depends on deferred cleanup. Return an error to an outer level that can perform cleanup before exiting.  
**Why:** `os.Exit` terminates immediately without running deferred functions, and `log.Fatal` ultimately calls `os.Exit`.  
**Source URL:** https://pkg.go.dev/os citeturn933611search0

## 2. Medium Impact

**Name:** Do not implement double-checked locking with ordinary loads  
**Category:** Synchronization algorithms  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `sync.Once`, `OnceValue`, or proper synchronization instead of checking a shared initialization flag before acquiring a lock.  
**Why:** The memory model explicitly identifies unsynchronized double-checked locking as incorrect.  
**Source URL:** https://go.dev/ref/mem citeturn539047view1

**Name:** Do not busy-wait on an ordinary shared variable  
**Category:** Synchronization visibility  
**Impact:** Medium  
**Consensus:** High  
**Description:** A loop that repeatedly reads an unsynchronized variable waiting for another goroutine to change it is not valid synchronization. Use a channel, mutex, condition, or atomic operation.  
**Why:** The memory model does not guarantee that the waiting goroutine will observe the write.  
**Source URL:** https://go.dev/ref/mem citeturn539047view1

**Name:** Know `sync.Once` failure semantics  
**Category:** One-time initialization  
**Impact:** Medium  
**Consensus:** High  
**Description:** Do not recursively call the same `Once.Do`, and remember that if the function panics, that `Once` is still considered finished.  
**Why:** Recursive use deadlocks and a panic does not cause the initializer to be retried later.  
**Source URL:** https://pkg.go.dev/sync citeturn539047view3

**Name:** Do not upgrade or recursively acquire `RWMutex` read locks  
**Category:** Read-write locking  
**Impact:** Medium  
**Consensus:** High  
**Description:** `RWMutex` cannot be upgraded from read to write or downgraded from write to read. Recursive read locking is unsafe when a writer may be pending.  
**Why:** Writers block new readers, so upgrade and recursive patterns can deadlock.  
**Source URL:** https://pkg.go.dev/sync citeturn539047view3

**Name:** Do not use `sync.Pool` as durable storage  
**Category:** Temporary object reuse  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `sync.Pool` only for temporary reusable objects whose disappearance is harmless.  
**Why:** The runtime may remove pooled objects at any time, and `Get` is allowed to behave as though the pool were empty.  
**Source URL:** https://pkg.go.dev/sync citeturn539047view3

**Name:** Prefer an ordinary map plus locking unless `sync.Map` fits its specialized cases  
**Category:** Concurrent collections  
**Impact:** Medium  
**Consensus:** High  
**Description:** Do not treat `sync.Map` as the default concurrent-map replacement. Most code is clearer and maintains stronger invariants with a typed map protected by a mutex.  
**Why:** `sync.Map` is optimized for specific access patterns and its `Range` is not a consistent snapshot.  
**Source URL:** https://pkg.go.dev/sync citeturn539047view3

**Name:** Wait on `sync.Cond` in a loop  
**Category:** Condition synchronization  
**Impact:** Medium  
**Consensus:** High  
**Description:** Recheck the condition after every `Cond.Wait`, normally with `for !condition { c.Wait() }`.  
**Why:** Waking means the goroutine may contend for the lock again; it does not establish that the application-level condition remains true when execution resumes.  
**Source URL:** https://pkg.go.dev/sync citeturn539047view3

**Name:** Prefer higher-level synchronization to hand-written atomics  
**Category:** Atomic synchronization  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use channels, mutexes, or other `sync` facilities unless an atomic algorithm is genuinely needed.  
**Why:** The atomic package is deliberately low level, and correct compound invariants are much harder to express and review with individual atomic operations.  
**Source URL:** https://pkg.go.dev/sync/atomic citeturn298508search0

**Name:** Prefer typed 64-bit atomics on 32-bit targets  
**Category:** Atomic alignment  
**Impact:** Medium  
**Consensus:** High  
**Description:** Prefer `atomic.Int64` and `atomic.Uint64` over primitive 64-bit atomic functions when portability to 32-bit platforms matters.  
**Why:** Primitive 64-bit atomic operations require caller-managed 64-bit alignment on several 32-bit architectures; the typed wrappers are automatically aligned.  
**Source URL:** https://pkg.go.dev/sync/atomic citeturn298508search0

**Name:** Do not change the concrete type stored in `atomic.Value`  
**Category:** Atomic dynamic values  
**Impact:** Medium  
**Consensus:** High  
**Description:** After the first store, all values placed in an `atomic.Value` must have the same concrete type, and storing nil is invalid.  
**Why:** Inconsistent types or nil stores panic.  
**Source URL:** https://pkg.go.dev/sync/atomic citeturn298508search0

**Name:** Channel buffering changes synchronization semantics  
**Category:** Channel happens-before relationships  
**Impact:** Medium  
**Consensus:** High  
**Description:** Do not assume buffered and unbuffered channels establish identical ordering. Design synchronization according to the memory model, not intuition about sends.  
**Why:** The happens-before guarantees differ according to channel capacity.  
**Source URL:** https://go.dev/ref/mem citeturn539047view1

**Name:** `select` does not implement case priority  
**Category:** Select semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** When multiple communication cases are ready, `select` chooses among them pseudo-randomly rather than selecting the first case.  
**Why:** Code that depends on textual case order for priority has incorrect scheduling assumptions.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Avoid accidental busy loops with `select default`  
**Category:** Nonblocking concurrency  
**Impact:** Medium  
**Consensus:** High  
**Description:** A `default` case makes `select` nonblocking. Do not put such a `select` in an unrestricted loop unless active polling is intentional and controlled.  
**Why:** It can consume an entire CPU while waiting for work that a blocking operation could await efficiently.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Use comma-ok when a closed channel's zero value is ambiguous  
**Category:** Channel receive semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `v, ok := <-ch` when the element type's zero value is meaningful and you need to distinguish it from closure.  
**Why:** Receiving from a closed and drained channel returns the element type's zero value immediately.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Stopping a ticker does not close its channel  
**Category:** Timer lifecycle  
**Impact:** Medium  
**Consensus:** High  
**Description:** Do not expect `range ticker.C` to terminate merely because another goroutine calls `ticker.Stop()`. Provide a separate cancellation signal.  
**Why:** `Ticker.Stop` deliberately leaves the channel open.  
**Source URL:** https://pkg.go.dev/time citeturn204522view0

**Name:** Tickers may drop ticks  
**Category:** Timer delivery semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Do not use ticker receives as a guaranteed count of elapsed periods.  
**Why:** A ticker may adjust its interval or drop ticks when a receiver is slow.  
**Source URL:** https://pkg.go.dev/time citeturn204522view0

**Name:** Stop repeating pre-Go-1.23 timer GC advice unconditionally  
**Category:** Version-dependent timer behavior  
**Impact:** Medium  
**Consensus:** High  
**Description:** For Go 1.23+ semantics, unreachable timers and tickers can be garbage collected even when unstopped. Stop them when you need to prevent future events, not merely because old advice said GC requires it.  
**Why:** The implementation contract changed in Go 1.23.  
**Source URL:** https://go.dev/wiki/Go123Timer citeturn153775search0

**Name:** Do not inspect `len(timer.C)` to detect a ready timer  
**Category:** Timer channel semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use a nonblocking `select` rather than testing timer-channel length.  
**Why:** Under Go 1.23 timer semantics timer channels are synchronous and report capacity and length zero.  
**Source URL:** https://go.dev/wiki/Go123Timer citeturn153775search0

**Name:** Buffer `signal.Notify` channels appropriately  
**Category:** OS signal delivery  
**Impact:** Medium  
**Consensus:** High  
**Description:** Provide enough buffering for signals you cannot afford to miss and unregister notifications when they are no longer needed. For `NotifyContext`, call its returned stop function.  
**Why:** Signal delivery through `Notify` uses a nonblocking send.  
**Source URL:** https://pkg.go.dev/os/signal citeturn634020view0

**Name:** Multiply numeric durations by their unit  
**Category:** Time units  
**Impact:** Medium  
**Consensus:** High  
**Description:** Write `time.Duration(n) * time.Second` or another explicit unit instead of converting a unitless integer and assuming seconds or milliseconds.  
**Why:** `time.Duration` is an `int64` count of nanoseconds.  
**Source URL:** https://pkg.go.dev/time citeturn446676view2

**Name:** Compare instants with `Time.Equal`, not usually `==`  
**Category:** Time representation  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `t.Equal(u)` for instant equality. Normalize deliberately before using `time.Time` as a map or database key.  
**Why:** `==` also compares the `Location` representation and monotonic clock reading.  
**Source URL:** https://pkg.go.dev/time citeturn204522view0

**Name:** Do not use `time.Date` as strict calendar validation  
**Category:** Calendar semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Validate calendar fields separately when invalid input should be rejected. `time.Date` normalizes out-of-range components such as October 32, and DST gaps or repetitions are inherently ambiguous.  
**Why:** Normalization can transform invalid user data into a different valid date without reporting an error.  
**Source URL:** https://pkg.go.dev/time citeturn204522view0

**Name:** Use `ParseInLocation` for location-dependent local times  
**Category:** Time parsing  
**Impact:** Medium  
**Consensus:** High  
**Description:** When input without an offset is intended to represent time in a known location, use `time.ParseInLocation`. Prefer numeric offsets over ambiguous zone abbreviations in interchange formats.  
**Why:** `time.Parse` interprets zone-less input as UTC and can create fabricated locations for unknown abbreviations.  
**Source URL:** https://pkg.go.dev/time citeturn446676view0

**Name:** Initialize maps before writing  
**Category:** Map zero values  
**Impact:** Medium  
**Consensus:** High  
**Description:** Reading a nil map is valid, but writing to one panics. Allocate it with `make` or a literal before the first write.  
**Why:** Nil maps are intentionally read-only empty maps until initialized.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Use comma-ok when a missing map key matters  
**Category:** Map lookup semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `v, ok := m[k]` whenever a stored zero value must be distinguished from a missing key.  
**Why:** A missing lookup returns the value type's zero value.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Never depend on map iteration order  
**Category:** Map iteration  
**Impact:** Medium  
**Consensus:** High  
**Description:** Sort keys or otherwise establish an order when deterministic output or processing is required.  
**Why:** Map iteration order is explicitly unspecified and may differ between iterations.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Do not rely on newly inserted map entries appearing during range  
**Category:** Map mutation during iteration  
**Impact:** Medium  
**Consensus:** High  
**Description:** If a map is modified during iteration, do not rely on new entries being visited. Deletions of not-yet-reached entries prevent those entries from being produced.  
**Why:** The specification deliberately leaves visitation of newly inserted entries unspecified.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Map elements are not addressable  
**Category:** Map value mutation  
**Impact:** Medium  
**Consensus:** High  
**Description:** You cannot directly assign through a struct field of `m[k]`. Read, modify, and assign the entire value back, or store pointers when pointer semantics are actually desired.  
**Why:** Map implementations may move entries, so map element values are not addressable variables.  
**Source URL:** https://go.dev/ref/spec citeturn542796search1

**Name:** `maps.Clone` is shallow  
**Category:** Collection copying  
**Impact:** Medium  
**Consensus:** High  
**Description:** `maps.Clone` creates an independent map structure but copies keys and values using assignment. Nested slices, maps, pointers, and other reference-bearing values remain shared.  
**Why:** Treating it as a deep clone can preserve unexpected aliases.  
**Source URL:** https://pkg.go.dev/maps citeturn123648search1

**Name:** Range values are copies  
**Category:** Range semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** When ranging over a slice or array, modifying the value variable does not modify the original element. Use the index when the element itself must change.  
**Why:** Iteration assigns each element value to the range variable.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** A pointer to a range value is not a pointer to the collection element  
**Category:** Range and pointer semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Even with Go 1.22's per-iteration variables, `&v` where `v` is a range value points to that iteration variable, not to `slice[i]`.  
**Why:** This fixes the old shared-variable capture bug but does not turn the copied range value into the original element.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Limit slice capacity when append should not mutate adjacent data  
**Category:** Slice capacity control  
**Impact:** Medium  
**Consensus:** High  
**Description:** When passing a sub-slice whose caller must not overwrite following elements by appending, copy it or restrict capacity with a full slice expression such as `s[:len(s):len(s)]` or `slices.Clip`.  
**Why:** `append` may otherwise reuse the original backing array beyond the visible sub-slice length.  
**Source URL:** https://pkg.go.dev/slices citeturn123648search2

**Name:** Copy small retained sub-slices out of large buffers  
**Category:** Memory retention  
**Impact:** Medium  
**Consensus:** High  
**Description:** If a tiny slice must outlive a large backing array, copy the needed elements into a right-sized allocation.  
**Why:** A small live slice keeps its entire backing array reachable and can retain unexpectedly large amounts of memory.  
**Source URL:** https://go.dev/blog/slices-intro citeturn225909search3

**Name:** `slices.Clone` is shallow  
**Category:** Collection copying  
**Impact:** Medium  
**Consensus:** High  
**Description:** `slices.Clone` separates the outer backing array but copies elements by assignment. Elements containing pointers, maps, slices, or other references still alias their original targets.  
**Why:** It is not a recursive ownership boundary.  
**Source URL:** https://pkg.go.dev/slices citeturn123648search2

**Name:** Distinguish bytes, runes, and user-perceived characters  
**Category:** Strings and Unicode  
**Impact:** Medium  
**Consensus:** High  
**Description:** `len(s)` and `s[i]` operate on bytes; range decodes UTF-8 runes and reports byte indexes. A rune still need not correspond to one grapheme visible to a user.  
**Why:** Byte indexing can split UTF-8 sequences and character-count assumptions can produce corrupt or incorrect text processing.  
**Source URL:** https://go.dev/blog/strings citeturn962274search2

**Name:** `strings.Trim` takes a cutset, not a substring  
**Category:** String API semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `TrimPrefix` or `TrimSuffix` when removing an exact prefix or suffix. `Trim` removes any leading and trailing rune contained in its cutset argument.  
**Why:** Confusing the APIs can remove more characters than intended.  
**Source URL:** https://pkg.go.dev/strings citeturn912241search12

**Name:** Copy borrowed buffers before retaining them  
**Category:** Buffer lifetime  
**Impact:** Medium  
**Consensus:** High  
**Description:** Data returned by APIs such as `Scanner.Bytes`, `bufio.Reader.Peek`, `ReadSlice`, or `bytes.Buffer.Bytes` may alias internal mutable storage. Copy it if it must survive subsequent reads or mutations.  
**Why:** Later operations can overwrite or mutate the same memory.  
**Source URL:** https://pkg.go.dev/bufio citeturn933611search1

**Name:** Do not assume `bufio.Scanner` handles arbitrarily large tokens  
**Category:** Buffered input limits  
**Impact:** Medium  
**Consensus:** High  
**Description:** Check `Scanner.Err`, and configure `Scanner.Buffer` or use a `bufio.Reader` when tokens can exceed Scanner's configured maximum.  
**Why:** Scanner stops on oversized tokens rather than transparently allocating without bound.  
**Source URL:** https://pkg.go.dev/bufio citeturn933611search1

**Name:** Flush buffered writers and handle the flush error  
**Category:** Buffered output lifecycle  
**Impact:** Medium  
**Consensus:** High  
**Description:** Explicitly flush `bufio.Writer` and similar buffered encoders before the underlying destination is considered successfully written.  
**Why:** Data may still be only in memory, and the flush itself can be where an underlying write error first appears.  
**Source URL:** https://pkg.go.dev/bufio citeturn728207search3

**Name:** Check final close errors when they can report write failure  
**Category:** Durable output  
**Impact:** Medium  
**Consensus:** High  
**Description:** For output resources whose `Close` finalizes or flushes content, do not automatically discard the close error when no earlier error occurred.  
**Why:** Filesystems, compressors, archive writers, and similar abstractions may report delayed write or finalization failures only at close.  
**Source URL:** https://pkg.go.dev/os citeturn547724search3

**Name:** Avoid resource-owning defers in large loops  
**Category:** Deferred cleanup scope  
**Impact:** Medium  
**Consensus:** High  
**Description:** A `defer` runs when the surrounding function returns, not when a loop iteration ends. Put an iteration in a helper function or close explicitly when resources need to be released each iteration.  
**Why:** Repeated defers can retain many files, locks, buffers, or other resources until the entire function exits.  
**Source URL:** https://go.dev/blog/defer-panic-and-recover citeturn547724search0

**Name:** Remember that `os.Create` truncates  
**Category:** File opening semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Do not use `os.Create` when existing contents must be preserved. Select `os.OpenFile` flags that express the desired append, create, exclusive, or truncate behavior.  
**Why:** `os.Create` opens for writing and truncates an existing file.  
**Source URL:** https://pkg.go.dev/os citeturn933611search0

**Name:** Remove temporary files you create  
**Category:** Temporary resource lifecycle  
**Impact:** Medium  
**Consensus:** High  
**Description:** `os.CreateTemp` and `os.MkdirTemp` create resources but do not automatically remove them when the process no longer needs them.  
**Why:** Long-running processes and repeated operations can otherwise accumulate files or expose stale sensitive material.  
**Source URL:** https://pkg.go.dev/os citeturn933611search0

**Name:** `Hash.Sum` appends rather than hashes its argument  
**Category:** Hash API semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** After writing input into a `hash.Hash`, use `h.Sum(nil)` or append the digest intentionally. Do not pass source data to `Sum` expecting it to be hashed.  
**Why:** `Sum(b)` appends the current digest to `b`; it neither resets nor hashes `b`.  
**Source URL:** https://pkg.go.dev/hash citeturn728207search2

**Name:** Use `regexp.Compile` for runtime patterns  
**Category:** Regular-expression error handling  
**Impact:** Medium  
**Consensus:** High  
**Description:** Reserve `regexp.MustCompile` for patterns that are effectively program constants and should make initialization fail if invalid. Use `Compile` for user or runtime input.  
**Why:** `MustCompile` panics on a malformed expression.  
**Source URL:** https://pkg.go.dev/regexp citeturn303566search3

**Name:** Use literal regexp replacement when `$` has no special meaning  
**Category:** Regular-expression substitution  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `ReplaceAllLiteralString` when the replacement text is literal. `ReplaceAllString` interprets `$name` and `$1` forms as capture expansion.  
**Why:** User-supplied or ordinary text containing dollar syntax can otherwise be transformed unexpectedly.  
**Source URL:** https://pkg.go.dev/regexp citeturn912241search5

**Name:** Use comma-ok for uncertain type assertions  
**Category:** Type assertions  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `v, ok := x.(T)` when failure is a normal possibility. Reserve one-result assertions for invariants whose violation genuinely warrants a panic.  
**Why:** A failed one-result assertion causes a runtime panic.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Validate narrowing numeric conversions  
**Category:** Numeric conversions  
**Impact:** Medium  
**Consensus:** High  
**Description:** Check ranges before converting untrusted or unconstrained numeric values to narrower integer types or between signed and unsigned representations.  
**Why:** Go conversions do not report overflow; they produce the value defined by truncation and representation rules.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Do not use `int` as an external fixed-width representation  
**Category:** Integer portability  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use fixed-width integer types when a value's binary width is part of a file format, protocol, hash, or persistent representation.  
**Why:** `int` and `uint` are implementation-width types, not portable fixed-width storage formats.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Remember arrays copy by value  
**Category:** Array semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Passing or assigning an array copies the entire array. Prefer slices for ordinary sequence APIs unless value-array semantics are specifically wanted.  
**Why:** Confusing arrays with slices can introduce large copies and mutations that do not affect the expected object.  
**Source URL:** https://go.dev/doc/effective_go citeturn850594search0

**Name:** Slice-to-array conversions have length preconditions  
**Category:** Conversion panics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Check slice length before converting a slice to an array or pointer-to-array type unless sufficient length is already guaranteed.  
**Why:** The conversion panics when the slice is too short.  
**Source URL:** https://go.dev/ref/spec citeturn850594search1

**Name:** Deferred-call arguments are evaluated immediately  
**Category:** Defer semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** If a deferred action should observe a later variable value, capture it deliberately in a closure rather than passing the value as a normal argument to `defer`.  
**Why:** Arguments and receivers are evaluated when the `defer` statement executes.  
**Source URL:** https://go.dev/blog/defer-panic-and-recover citeturn547724search0

**Name:** Deferred functions can modify named return values  
**Category:** Return semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Be cautious when combining named result variables with defers. A deferred closure can read or change those result values after the return statement has set them.  
**Why:** This is deliberate language behavior and can make final returned values differ from those apparently supplied at `return`.  
**Source URL:** https://go.dev/blog/defer-panic-and-recover citeturn547724search0

**Name:** Watch short declarations for accidental shadowing  
**Category:** Variable scope  
**Impact:** Medium  
**Consensus:** High  
**Description:** Be especially careful with `:=` inside nested blocks when names such as `err` already exist. Use assignment when the outer variable is intended.  
**Why:** A new inner variable can silently hide the outer one and cause the function to inspect or return the wrong value.  
**Source URL:** https://pkg.go.dev/golang.org/x/tools/go/analysis/passes/shadow citeturn858415search1

**Name:** Do not store contexts in structs by default  
**Category:** Context API design  
**Impact:** Medium  
**Consensus:** High  
**Description:** Pass `context.Context` as the first parameter to operations that need it instead of putting it into a long-lived struct.  
**Why:** Per-operation contexts carry lifetimes and deadlines that usually should not become coupled to an object's lifetime.  
**Source URL:** https://go.dev/blog/context-and-structs citeturn188131search2

**Name:** Never pass a nil context  
**Category:** Context API contract  
**Impact:** Medium  
**Consensus:** High  
**Description:** Pass `context.TODO()` when no proper context has yet been chosen rather than passing nil.  
**Why:** Context-consuming APIs are designed around non-nil contexts, and nil can produce panics or inconsistent handling.  
**Source URL:** https://pkg.go.dev/context citeturn539047view2

**Name:** Keep context values request-scoped and collision-resistant  
**Category:** Context metadata  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use context values only for request-scoped data crossing API boundaries, not as an optional-parameter bag. Define private comparable key types rather than raw strings.  
**Why:** This keeps dependencies explicit and prevents key collisions between packages.  
**Source URL:** https://pkg.go.dev/context citeturn539047view2

**Name:** HTTP non-2xx responses are not `Do` errors  
**Category:** HTTP response semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Inspect `resp.StatusCode`; do not interpret `err == nil` as application-level success.  
**Why:** `Client.Do` returns responses such as 404 and 500 normally when the HTTP exchange itself succeeded.  
**Source URL:** https://pkg.go.dev/net/http citeturn892821view0

**Name:** Reuse HTTP clients and transports  
**Category:** HTTP connection pooling  
**Impact:** Medium  
**Consensus:** High  
**Description:** Keep reusable `http.Client` and `Transport` instances rather than constructing a fresh transport for every request.  
**Why:** Transports maintain persistent connection pools and are designed for concurrent reuse.  
**Source URL:** https://pkg.go.dev/net/http citeturn448404search1

**Name:** `Client.Timeout` covers body reading too  
**Category:** HTTP timeout semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Set `Client.Timeout` with awareness that it spans connection setup, redirects, and reading the response body, not merely waiting for headers.  
**Why:** A timeout can interrupt body consumption after `Do` itself has already returned.  
**Source URL:** https://pkg.go.dev/net/http citeturn892821view0

**Name:** Do not use `ResponseWriter` after the handler returns  
**Category:** HTTP handler lifetime  
**Impact:** Medium  
**Consensus:** High  
**Description:** Complete response-writing operations before `ServeHTTP` returns unless using an API with an explicit alternative lifecycle.  
**Why:** The standard `ResponseWriter` is not valid for use after the handler has returned.  
**Source URL:** https://pkg.go.dev/net/http citeturn892821view1

**Name:** Network deadlines persist until changed  
**Category:** Socket deadlines  
**Impact:** Medium  
**Consensus:** High  
**Description:** `Conn.SetDeadline` sets an absolute deadline applying to future and pending I/O until replaced. Refresh it after successful operations when implementing an idle timeout.  
**Why:** It is not automatically a timeout for only the next read or write.  
**Source URL:** https://pkg.go.dev/net citeturn448404search0

**Name:** Treat `sql.DB` as a long-lived connection pool  
**Category:** Database connection management  
**Impact:** Medium  
**Consensus:** High  
**Description:** Open a `*sql.DB` for reuse rather than opening and closing one per request. Configure pool limits when resource constraints require them.  
**Why:** `sql.DB` represents a concurrency-safe pool, not a single database connection.  
**Source URL:** https://pkg.go.dev/database/sql citeturn452460view0

**Name:** `QueryRow` defers its error until `Scan`  
**Category:** Database error timing  
**Impact:** Medium  
**Consensus:** High  
**Description:** Always check the error returned by `QueryRow(...).Scan(...)`; do not expect `QueryRow` itself to report query errors.  
**Why:** `QueryRow` stores the error and reports it through `Scan`.  
**Source URL:** https://pkg.go.dev/database/sql citeturn452460view0

**Name:** Do not retain `sql.RawBytes` across row advancement  
**Category:** Database buffer lifetime  
**Impact:** Medium  
**Consensus:** High  
**Description:** Copy `RawBytes` if data must survive the next `Rows.Next`, `Scan`, or close operation.  
**Why:** `RawBytes` references driver-owned memory valid only until the next database operation on those rows.  
**Source URL:** https://pkg.go.dev/database/sql citeturn452460view0

**Name:** Reject unknown JSON fields when the schema must be strict  
**Category:** JSON schema validation  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `Decoder.DisallowUnknownFields` when unexpected object fields should cause failure rather than being silently ignored.  
**Why:** `encoding/json` ignores unknown struct fields by default.  
**Source URL:** https://pkg.go.dev/encoding/json citeturn462839search0

**Name:** Ensure a single JSON document has no trailing document  
**Category:** JSON framing  
**Impact:** Medium  
**Consensus:** High  
**Description:** When using `Decoder.Decode` for a single payload, verify that the next decode reaches EOF, or use `json.Unmarshal` on bounded input.  
**Why:** One successful `Decode` does not by itself prove that the input ended after that JSON value.  
**Source URL:** https://go.dev/blog/jsonv2-exp citeturn929550search0

**Name:** Avoid implicit `float64` JSON numbers when precision matters  
**Category:** JSON numeric representation  
**Impact:** Medium  
**Consensus:** High  
**Description:** Decode into concrete numeric fields or use `Decoder.UseNumber` when arbitrary JSON numbers must retain their textual or integer precision.  
**Why:** Numbers decoded into `any` become `float64` by default.  
**Source URL:** https://pkg.go.dev/encoding/json citeturn929550search1

**Name:** Treat a destination as partially modified after JSON failure  
**Category:** JSON failure semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Do not assume an `Unmarshal` error means the destination was left untouched. Prefer decoding into a temporary value when atomic update semantics are needed.  
**Why:** `encoding/json` may populate earlier fields before encountering and reporting an error.  
**Source URL:** https://pkg.go.dev/encoding/json citeturn713318search3

**Name:** Clear reused maps before JSON decoding when stale keys are invalid  
**Category:** JSON destination reuse  
**Impact:** Medium  
**Consensus:** High  
**Description:** Decode into a new map, or clear an existing map first, when keys omitted by the new JSON document should disappear.  
**Why:** Unmarshaling into a non-nil map reuses it and leaves existing unmatched entries intact.  
**Source URL:** https://pkg.go.dev/encoding/json citeturn929550search1

**Name:** Use pointer or nullable representations when JSON null must be distinguishable  
**Category:** JSON nullability  
**Impact:** Medium  
**Consensus:** High  
**Description:** Do not decode into an ordinary scalar when `null`, missing, and the scalar zero value have different meanings.  
**Why:** JSON `null` has no effect when unmarshaled into many non-pointer scalar destinations.  
**Source URL:** https://pkg.go.dev/encoding/json citeturn929550search1

**Name:** Remember JSON struct field matching is case-insensitive  
**Category:** JSON field resolution  
**Impact:** Medium  
**Consensus:** High  
**Description:** Avoid designing externally exposed schemas whose fields differ only by case, and do not assume Go's decoder requires exact-case matching.  
**Why:** `encoding/json` performs case-insensitive matching when an exact field-name match is unavailable.  
**Source URL:** https://pkg.go.dev/encoding/json citeturn462839search0

**Name:** Prefer consumer-defined interfaces and producer-returned concrete types  
**Category:** Interface API design  
**Impact:** Medium  
**Consensus:** High  
**Description:** Define small interfaces where behavior is consumed, and generally let constructors return concrete implementation types rather than speculative producer-side interfaces.  
**Why:** Consumers can describe exactly what they need while producers retain freedom to add methods without breaking an exported interface.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view1

**Name:** Adding a method to a public interface is breaking  
**Category:** API compatibility  
**Impact:** Medium  
**Consensus:** High  
**Description:** Add a new interface or feature-detect a secondary interface rather than casually adding a method to an exported interface implemented by users.  
**Why:** Every existing external implementation immediately stops satisfying the expanded interface.  
**Source URL:** https://go.dev/blog/module-compatibility citeturn188131search0

**Name:** Function signatures are rigid compatibility surfaces  
**Category:** API evolution  
**Impact:** Medium  
**Consensus:** High  
**Description:** Prefer adding another function or method over changing an existing exported function signature, even when a change such as adding a variadic parameter appears source-compatible at call sites.  
**Why:** Existing code may use the function as a first-class function value whose type must match exactly.  
**Source URL:** https://go.dev/blog/module-compatibility citeturn263061view0

**Name:** Do not accidentally destroy exported struct comparability  
**Category:** Public value-type compatibility  
**Impact:** Medium  
**Consensus:** High  
**Description:** Before adding a slice, map, function, or other non-comparable field to an exported value struct, consider whether callers may compare the struct or use it as a map key.  
**Why:** Such an addition can make previously valid client code stop compiling.  
**Source URL:** https://go.dev/blog/module-compatibility citeturn912241search31

**Name:** New configuration fields should preserve useful zero-value behavior  
**Category:** API compatibility  
**Impact:** Medium  
**Consensus:** High  
**Description:** When extending an exported configuration struct, design new fields so their zero values normally preserve prior behavior unless a deliberate breaking change is being made.  
**Why:** Existing users construct the struct without knowing about newly added fields.  
**Source URL:** https://go.dev/blog/module-compatibility citeturn263061view0

**Name:** Understand pointer versus value method sets  
**Category:** Method sets and interfaces  
**Impact:** Medium  
**Consensus:** High  
**Description:** A method defined only on `*T` does not make `T` satisfy an interface requiring that method, although `*T` also has methods defined on `T`.  
**Why:** Choosing receiver type changes interface satisfaction and therefore API usability.  
**Source URL:** https://go.dev/ref/spec citeturn539047view0

**Name:** Do not pass pointers to interfaces  
**Category:** Interface API design  
**Impact:** Medium  
**Consensus:** High  
**Description:** Accept or return the interface value itself rather than `*SomeInterface` except for rare cases where the interface variable itself must be mutated.  
**Why:** Interfaces already contain references to dynamic type and value; adding a pointer usually adds indirection without useful semantics.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn174509view0

**Name:** Use an interface instead of a type parameter when only methods matter  
**Category:** Generics design  
**Impact:** Medium  
**Consensus:** High  
**Description:** If generic code only invokes methods defined by the constraint and gains nothing from retaining the concrete type, a normal interface parameter is usually simpler.  
**Why:** Type parameters are most valuable when an algorithm must preserve or operate on a family of concrete types.  
**Source URL:** https://go.dev/blog/when-generics citeturn181276search0

**Name:** Do not introduce generics before repeated type-level need exists  
**Category:** Generic abstraction  
**Impact:** Medium  
**Consensus:** Medium  
**Description:** Prefer ordinary functions or interfaces until the same algorithm genuinely needs to operate over multiple types or type-preserving containers.  
**Why:** Type parameters, constraints, and generic APIs add design surface that may not buy anything for a single concrete use case.  
**Source URL:** https://go.dev/blog/when-generics citeturn181276search0

**Name:** `comparable` does not guarantee panic-free equality for interface type arguments  
**Category:** Generic comparability  
**Impact:** Medium  
**Consensus:** High  
**Description:** Since Go 1.20, interface types such as `any` may satisfy `comparable`; equality can still panic when the dynamic value placed in that interface is itself non-comparable.  
**Why:** Go deliberately relaxed static constraint satisfaction in this case while retaining the runtime interface-comparison rule.  
**Source URL:** https://go.dev/blog/comparable citeturn912241search0

**Name:** Iterator implementations must stop after `yield` returns false  
**Category:** Range-over-function iterators  
**Impact:** Medium  
**Consensus:** High  
**Description:** A push iterator must return when its `yield` callback returns false rather than continuing to call it.  
**Why:** False means the range consumer terminated early; continuing violates the iterator protocol and can trigger runtime failures.  
**Source URL:** https://pkg.go.dev/iter citeturn351811search3

**Name:** Call `stop` when abandoning `iter.Pull` early  
**Category:** Pull iterator lifecycle  
**Impact:** Medium  
**Consensus:** High  
**Description:** When a pull iterator has not naturally reached its end, arrange `defer stop()` or otherwise call `stop` before abandoning it.  
**Why:** `stop` allows the underlying iterator to finish and release any resources or goroutine it is using.  
**Source URL:** https://pkg.go.dev/iter citeturn351811search3

**Name:** Do not rely on your module's `replace` directives propagating to consumers  
**Category:** Module graph semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** Test published modules without depending on replacements defined only by the developing main module or workspace.  
**Why:** `replace` and `exclude` directives apply to the main module/workspace and are ignored when that module is consumed as a dependency.  
**Source URL:** https://go.dev/ref/mod citeturn276756search0

**Name:** Test modules outside workspace influence when consumer behavior matters  
**Category:** Workspace reproducibility  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `GOWORK=off` when verifying that an individual module works using only its own `go.mod`, especially before publishing.  
**Why:** An automatically discovered parent `go.work` can replace modules or select versions that downstream consumers will not see.  
**Source URL:** https://go.dev/ref/mod citeturn347580search1

**Name:** Minimal Version Selection does not mean latest  
**Category:** Dependency version selection  
**Impact:** Medium  
**Consensus:** High  
**Description:** Do not assume a build automatically selects the newest released dependency. Inspect and upgrade dependencies deliberately.  
**Why:** MVS chooses the highest version required by the module graph, not the newest version available upstream.  
**Source URL:** https://go.dev/ref/mod citeturn625380search0

**Name:** Treat the `go` directive as semantic configuration  
**Category:** Language and runtime compatibility  
**Impact:** Medium  
**Consensus:** High  
**Description:** Update the module's `go` version deliberately rather than treating it as cosmetic metadata.  
**Why:** It controls the minimum language/toolchain version and can select compatibility behavior for changes such as loop variables, timers, `panic(nil)`, and runtime defaults.  
**Source URL:** https://go.dev/doc/godebug citeturn912241search19

**Name:** Major versions v2+ belong in the module path  
**Category:** Semantic import versioning  
**Impact:** Medium  
**Consensus:** High  
**Description:** A module reaching v2 or higher must normally include `/v2`, `/v3`, and so on in its module and import paths.  
**Why:** Go uses the import path to make incompatible major versions distinct packages.  
**Source URL:** https://go.dev/ref/mod citeturn347580search2

**Name:** Use `tool` directives for project-pinned Go tools  
**Category:** Tool dependency management  
**Impact:** Medium  
**Consensus:** High  
**Description:** On Go 1.24+, declare project tools with `tool` and manage them through the module rather than relying on the old dummy-import `tools.go` workaround.  
**Why:** Tool dependencies then participate directly in the module graph, version selection, replacements, and reproducibility.  
**Source URL:** https://go.dev/doc/modules/managing-dependencies citeturn276756search1

**Name:** Remember build constraints can hide source files and dependencies  
**Category:** Conditional compilation  
**Impact:** Medium  
**Consensus:** High  
**Description:** Test relevant GOOS, GOARCH, and build-tag combinations rather than assuming the source set used on one development machine represents every build.  
**Why:** Filename suffixes and `//go:build` expressions change which files and declarations exist.  
**Source URL:** https://pkg.go.dev/cmd/go citeturn634020view2

**Name:** Do not hand-delete dependencies merely because the current platform does not import them  
**Category:** Module tidiness  
**Impact:** Medium  
**Consensus:** High  
**Description:** Let `go mod tidy` determine module requirements across supported build configurations.  
**Why:** Tidy considers packages across build tags and platforms more broadly than a single local build.  
**Source URL:** https://go.dev/ref/mod citeturn276756search0

**Name:** A clean race-detector run is not proof of race freedom  
**Category:** Dynamic race analysis  
**Impact:** Medium  
**Consensus:** High  
**Description:** Run `go test -race` and realistic race-enabled workloads, but continue reasoning about synchronization even when no race is reported.  
**Why:** The race detector only detects races that actually execute during the observed run.  
**Source URL:** https://go.dev/doc/articles/race_detector citeturn858415search3

**Name:** Run `go vet`, but do not treat silence as correctness proof  
**Category:** Static analysis  
**Impact:** Medium  
**Consensus:** High  
**Description:** Include vet in normal validation while understanding that its checks are deliberately heuristic and incomplete.  
**Why:** Vet catches classes such as copied locks, lost cancellation, bad format strings, and invalid `errors.As` use, but it neither proves correctness nor guarantees every warning is a real bug.  
**Source URL:** https://pkg.go.dev/cmd/vet citeturn188131search1

**Name:** Keep fuzz targets deterministic and isolated  
**Category:** Fuzz testing  
**Impact:** Medium  
**Consensus:** High  
**Description:** Fuzz functions should execute quickly and deterministically for a given input and should not depend on state left by previous invocations.  
**Why:** The fuzz engine may run inputs in parallel and in nondeterministic order.  
**Source URL:** https://go.dev/doc/security/fuzz/ citeturn858415search0

**Name:** Do not call `Fatal` from a helper goroutine  
**Category:** Test goroutine semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** `T.FailNow`, `T.Fatal`, `T.Fatalf`, `SkipNow`, and related termination methods must run in the goroutine executing the test, not an arbitrary spawned goroutine.  
**Why:** `FailNow` terminates only the calling goroutine, producing incorrect test control flow when invoked elsewhere.  
**Source URL:** https://pkg.go.dev/testing citeturn576964search3

**Name:** Do not combine parallel tests with process-global environment or directory changes  
**Category:** Test isolation  
**Impact:** Medium  
**Consensus:** High  
**Description:** Tests using `T.Setenv` or `T.Chdir` cannot safely run in parallel with tests sharing the process state.  
**Why:** Environment variables and the working directory are process-global resources.  
**Source URL:** https://pkg.go.dev/testing citeturn576964search3

**Name:** Prefer `testing/synctest` to real sleeps for asynchronous timing tests  
**Category:** Concurrent test determinism  
**Impact:** Medium  
**Consensus:** High  
**Description:** Where applicable, use `testing/synctest` rather than long `time.Sleep` calls to coordinate concurrent behavior in tests.  
**Why:** Real time makes tests slow and vulnerable to scheduler timing and machine-load flakiness.  
**Source URL:** https://pkg.go.dev/testing/synctest citeturn709068search4

**Name:** Prefer `B.Loop` for ordinary benchmarks on modern Go  
**Category:** Benchmark correctness  
**Impact:** Medium  
**Consensus:** High  
**Description:** For new benchmarks, use `for b.Loop() { ... }` unless lower-level benchmark control is required.  
**Why:** `B.Loop` handles setup timing and compiler-optimization concerns more robustly than manually arranging `b.N` loops.  
**Source URL:** https://pkg.go.dev/testing citeturn576964search3

**Name:** Every successfully started subprocess must be waited for  
**Category:** Process lifecycle  
**Impact:** Medium  
**Consensus:** High  
**Description:** After a successful `cmd.Start`, call `cmd.Wait`. Prefer `Run` when no asynchronous interaction is needed.  
**Why:** `Wait` releases process-associated resources and completes pipe bookkeeping.  
**Source URL:** https://pkg.go.dev/os/exec citeturn713318search2

**Name:** Consume command pipes before waiting  
**Category:** Subprocess pipes  
**Impact:** Medium  
**Consensus:** High  
**Description:** With `StdoutPipe` or `StderrPipe`, read the pipe to completion before calling `Wait`; do not call `Run` while separately trying to consume those pipe APIs.  
**Why:** `Wait` closes the pipes after the command exits, and incorrect ordering can lose data or deadlock.  
**Source URL:** https://pkg.go.dev/os/exec citeturn713318search2

**Name:** Do not bypass `exec.ErrDot` casually  
**Category:** Executable lookup security  
**Impact:** Medium  
**Consensus:** High  
**Description:** When execution from the current directory is intentional, name it explicitly with `./program` rather than weakening the protection against implicit current-directory lookup.  
**Why:** Go deliberately rejects executables found through an implicit `.` in `PATH` to avoid running attacker-controlled local files unexpectedly.  
**Source URL:** https://pkg.go.dev/os/exec citeturn630650search1

**Name:** Do not use MD5 or SHA-1 for cryptographic security  
**Category:** Cryptographic hashing  
**Impact:** Medium  
**Consensus:** High  
**Description:** Reserve MD5 and SHA-1 for non-security compatibility uses where collision resistance is irrelevant. Use modern cryptographic hashes for security properties.  
**Why:** Their standard-library documentation explicitly states they are cryptographically broken.  
**Source URL:** https://pkg.go.dev/crypto/sha1 citeturn281414search1

**Name:** Use constant-time comparison for secret values when timing matters  
**Category:** Side-channel resistance  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use appropriate `crypto/subtle` operations for authentication tags and other secret comparisons whose timing could expose information.  
**Why:** Ordinary short-circuit comparisons may reveal where two values first differ.  
**Source URL:** https://pkg.go.dev/crypto/subtle citeturn254252search1

**Name:** Guard reflection operations by validity and kind  
**Category:** Reflection safety  
**Impact:** Medium  
**Consensus:** High  
**Description:** Before calling kind-specific `reflect.Value` methods, establish that the value is valid and has the required kind and mutability properties.  
**Why:** Many reflection operations panic rather than return errors when applied to invalid values or inappropriate kinds.  
**Source URL:** https://pkg.go.dev/reflect citeturn123648search3

**Name:** Do not capture an `AddCleanup` target in its cleanup  
**Category:** GC cleanup semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** A cleanup function must not retain the object it is attached to, directly through a closure or indirectly through its cleanup argument.  
**Why:** Keeping the target reachable prevents the cleanup from ever becoming eligible to run.  
**Source URL:** https://go.dev/blog/cleanups-and-weak citeturn298508search1

**Name:** Do not assume `GOMAXPROCS` equals host CPU count in containers  
**Category:** Runtime scheduling  
**Impact:** Medium  
**Consensus:** High  
**Description:** On current Go, understand the container-aware default rather than hard-coding host CPU assumptions or overriding it reflexively. Also account for the module's Go version when relying on newer default behavior.  
**Why:** Excessive parallelism relative to a CPU quota can cause throttling and poor tail latency.  
**Source URL:** https://go.dev/blog/container-aware-gomaxprocs citeturn709068search1

**Name:** `GOMEMLIMIT` is not a process RSS limit  
**Category:** Runtime memory control  
**Impact:** Medium  
**Consensus:** High  
**Description:** Treat `GOMEMLIMIT` or `debug.SetMemoryLimit` as a soft runtime-managed memory target, not a hard cap on total process memory.  
**Why:** It excludes several memory classes, and setting it unrealistically low can make the runtime spend nearly all its time collecting.  
**Source URL:** https://pkg.go.dev/runtime/debug citeturn709068search2

**Name:** Use `path`, not `filepath`, for slash-defined URL paths  
**Category:** Path portability  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use `path/filepath` for native filesystem paths and `path` or URL APIs for slash-separated URL paths.  
**Why:** `filepath` deliberately uses operating-system-specific path separators and semantics.  
**Source URL:** https://pkg.go.dev/path/filepath citeturn313524search0

**Name:** Escape URL components according to their context  
**Category:** URL encoding  
**Impact:** Medium  
**Consensus:** High  
**Description:** Use path-segment escaping for path components and query escaping for query values rather than applying one generic escaping rule everywhere.  
**Why:** URL path and query syntax have different escaping semantics.  
**Source URL:** https://pkg.go.dev/net/url citeturn313524search3

**Name:** Prefer `net/netip` for value-like IP addresses in new APIs  
**Category:** Network address representation  
**Impact:** Medium  
**Consensus:** Medium  
**Description:** When compatibility constraints do not require `net.IP`, consider `netip.Addr` for application-level IP storage and comparison.  
**Why:** `Addr` is immutable, comparable, usable as a map key, and smaller than slice-based `net.IP`.  
**Source URL:** https://pkg.go.dev/net/netip citeturn912241search10

**Name:** Do not assume standard-library output bytes remain implementation-stable  
**Category:** Reproducibility and compatibility  
**Impact:** Medium  
**Consensus:** High  
**Description:** Tests and protocols should depend on documented semantic output, not exact bytes from compressors, unstable sorts, or other implementations unless byte stability is explicitly promised.  
**Why:** Go's compatibility policy permits implementation improvements that preserve API semantics while changing serialized or ordering details.  
**Source URL:** https://go.dev/blog/compat citeturn188131search3

**Name:** Do not copy a nonzero `strings.Builder`  
**Category:** Mutable value copying  
**Impact:** Medium  
**Consensus:** High  
**Description:** Pass a `strings.Builder` by pointer or keep it local rather than copying it after it has been used.  
**Why:** The type explicitly must not be copied after first use.  
**Source URL:** https://pkg.go.dev/strings citeturn728207search1

**Name:** Avoid copying mutable structs with pointer receiver methods  
**Category:** Mutable value aliasing  
**Impact:** Medium  
**Consensus:** High  
**Description:** Do not casually copy types such as `bytes.Buffer` whose internal slices or other state can alias after copying.  
**Why:** Two apparent values may then mutate shared internal data, while synchronization state in other types can become outright invalid.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view3

**Name:** Do not use panic for expected operational failures  
**Category:** Error control flow  
**Impact:** Medium  
**Consensus:** High  
**Description:** Return errors for ordinary invalid input, unavailable resources, failed network calls, and other expected failure paths. Reserve panic for violated invariants or exceptional internal conditions.  
**Why:** Go APIs are designed around explicit error handling, while panic unwinds an entire goroutine unless deliberately contained.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Use out-of-band status instead of sentinel result values  
**Category:** Result API design  
**Impact:** Medium  
**Consensus:** High  
**Description:** Prefer `(value, ok)` or `(value, error)` over values such as `-1`, `""`, or nil when those values can also be legitimate results.  
**Why:** Multiple returns let the type system prevent callers from accidentally treating failure markers as valid data.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Process partial network writes before timeout errors  
**Category:** Network I/O semantics  
**Impact:** Medium  
**Consensus:** High  
**Description:** When an I/O method returns both `n > 0` and an error, account for the successfully transferred portion before handling the error.  
**Why:** Network operations may make partial progress before a deadline or other failure.  
**Source URL:** https://pkg.go.dev/net citeturn448404search0

**Name:** Check primary C return values before `errno`  
**Category:** cgo error handling  
**Impact:** Medium  
**Consensus:** High  
**Description:** When using cgo's two-result form that captures `errno`, determine whether the C call failed according to its documented return value before interpreting `errno`.  
**Why:** `errno` may be nonzero after a successful C call.  
**Source URL:** https://pkg.go.dev/cmd/cgo citeturn793239search2

**Name:** Do not expose C types in public Go APIs  
**Category:** cgo API boundaries  
**Impact:** Medium  
**Consensus:** High  
**Description:** Translate C values into ordinary Go types before exposing them across package boundaries.  
**Why:** cgo C types are generated per package and do not form a stable, portable Go API between packages.  
**Source URL:** https://pkg.go.dev/cmd/cgo citeturn793239search2

**Name:** Prefer typed atomic wrappers over primitive operations where practical  
**Category:** Atomic API design  
**Impact:** Medium  
**Consensus:** Medium  
**Description:** `atomic.Bool`, `Int64`, `Pointer[T]`, and related wrappers often make atomic intent and alignment clearer than free functions on raw addresses.  
**Why:** They reduce pointer manipulation, encode the atomic nature in the field type, and handle 64-bit alignment requirements.  
**Source URL:** https://pkg.go.dev/sync/atomic citeturn298508search0

**Name:** Prefer synchronous APIs unless asynchronous behavior belongs in the abstraction  
**Category:** Concurrency API design  
**Impact:** Medium  
**Consensus:** Medium  
**Description:** Prefer functions that finish their work before returning when callers can trivially add concurrency themselves.  
**Why:** Localizing goroutines makes lifetimes, cancellation, errors, and tests easier to reason about; removing concurrency from an inherently asynchronous API is much harder for callers.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view3

**Name:** Functional options are not a universal rule  
**Category:** Extensible API configuration  
**Impact:** Medium  
**Consensus:** Medium  
**Description:** Choose configuration structs, functional options, or another pattern according to the API's compatibility and usability needs rather than treating functional options as mandatory Go style.  
**Why:** Go's own compatibility guidance describes tradeoffs and legitimate uses for more than one extensible configuration design.  
**Source URL:** https://go.dev/blog/module-compatibility citeturn263061view0

## 3. Low Impact

**Name:** Format Go code with `gofmt`  
**Category:** Mechanical source style  
**Impact:** Low  
**Consensus:** High  
**Description:** Use `gofmt`, or `goimports` when import management is also desired, instead of maintaining a project-specific formatting style.  
**Why:** Standard formatting removes mechanical style arguments and makes Go source visually consistent across projects.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Keep error strings lowercase and composable  
**Category:** Error message style  
**Impact:** Low  
**Consensus:** High  
**Description:** Normally start error strings with lowercase text and omit terminal punctuation unless a proper noun or other grammatical requirement dictates otherwise.  
**Why:** Errors are frequently wrapped or printed after surrounding context, so sentence-style capitalization and punctuation compose poorly.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Prefer the nil slice as the ordinary empty zero value  
**Category:** Slice zero-value style  
**Impact:** Low  
**Consensus:** High  
**Description:** Prefer `var s []T` over `s := []T{}` when there is no semantic need for a non-nil empty slice. Preserve the distinction only where protocols such as JSON require it.  
**Why:** Nil slices already support ordinary append, len, cap, and range operations without special initialization.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Do not design APIs that distinguish nil and empty slices without need  
**Category:** Collection API semantics  
**Impact:** Low  
**Consensus:** High  
**Description:** Treat nil and zero-length slices equivalently unless the distinction represents real domain information.  
**Why:** Requiring callers to preserve an otherwise irrelevant representation detail creates subtle compatibility and testing problems.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Avoid dot imports in normal code  
**Category:** Package namespace clarity  
**Impact:** Low  
**Consensus:** High  
**Description:** Import packages normally and qualify their exported names. Reserve dot imports for exceptional test dependency situations where package cycles make them useful.  
**Why:** Dot imports make it unclear which package supplied an identifier.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Keep side-effect-only imports localized  
**Category:** Package initialization  
**Impact:** Low  
**Consensus:** High  
**Description:** Blank imports used solely for initialization side effects should generally live in `main` packages or tests that explicitly require them.  
**Why:** Hidden package-level effects make dependencies and initialization behavior less obvious to importing packages.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Avoid unnecessary import renaming  
**Category:** Package naming  
**Impact:** Low  
**Consensus:** High  
**Description:** Use a package's natural name unless a collision or similar concrete reason requires an alias.  
**Why:** Arbitrary aliases force readers to learn local names for otherwise familiar packages.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view2

**Name:** Preserve conventional initialism capitalization  
**Category:** Identifier naming  
**Impact:** Low  
**Consensus:** High  
**Description:** Write conventional initialisms consistently, such as `URL`, `HTTP`, and `ID`, rather than forms such as `Url`, `Http`, and `Id`.  
**Why:** This is the established Go naming convention and makes APIs consistent with the standard library.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view1

**Name:** Avoid pointers merely to reduce value-copy size  
**Category:** Parameter representation  
**Impact:** Low  
**Consensus:** High  
**Description:** Pass small immutable values such as strings and interface values directly unless pointer semantics are actually required.  
**Why:** A pointer changes aliasing, nilability, escape analysis, and API semantics rather than simply serving as a cheaper copy.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn174509view0

**Name:** Do not use `new` for slices and maps by habit  
**Category:** Allocation idioms  
**Impact:** Low  
**Consensus:** High  
**Description:** Use a zero slice or `make` for slices and maps rather than creating pointers such as `new([]T)` or `new(map[K]V)` without a specific pointer requirement.  
**Why:** The pointer generally adds indirection while the zero values or `make` already provide the intended container semantics.  
**Source URL:** https://go.dev/doc/effective_go citeturn454285search2

**Name:** Avoid unkeyed literals for external struct types  
**Category:** Source compatibility  
**Impact:** Low  
**Consensus:** High  
**Description:** Initialize structs from other packages with field names rather than positional literals.  
**Why:** Adding a field to an exported struct can otherwise break every positional literal even when existing field semantics did not change.  
**Source URL:** https://go.dev/blog/compat citeturn188131search3

**Name:** Prefer semantic error assertions in tests  
**Category:** Test robustness  
**Impact:** Low  
**Consensus:** High  
**Description:** When the error's identity or type is the contract, test with `errors.Is` or `errors.As` rather than comparing the entire error string.  
**Why:** Contextual wording may legitimately change while the semantic error contract remains identical.  
**Source URL:** https://go.dev/wiki/TestComments citeturn140926view0

**Name:** Mark test helpers with `t.Helper`  
**Category:** Test diagnostics  
**Impact:** Low  
**Consensus:** High  
**Description:** Call `t.Helper()` in reusable functions that report test failures on behalf of their caller.  
**Why:** Failure locations then point to the meaningful caller instead of an internal helper implementation.  
**Source URL:** https://go.dev/wiki/TestComments citeturn140926view0

**Name:** Prefer useful got/want test failures  
**Category:** Test diagnostics  
**Impact:** Low  
**Consensus:** High  
**Description:** Report the input, actual value, and expected value when a comparison fails.  
**Why:** A test failure should contain enough information to diagnose the difference without immediately reproducing it under a debugger.  
**Source URL:** https://go.dev/wiki/CodeReviewComments citeturn474924view3

**Name:** Avoid exact-byte tests for outputs whose representation is not contractual  
**Category:** Test stability  
**Impact:** Low  
**Consensus:** High  
**Description:** Compare decoded meaning or promised properties instead of exact serialized bytes when the encoding API does not promise canonical output.  
**Why:** Implementation changes can alter valid output without changing behavior.  
**Source URL:** https://go.dev/wiki/TestComments citeturn140926view0

**Name:** Prefer `cmp`-style semantic comparison over reflexive `reflect.DeepEqual` use in tests  
**Category:** Test comparison  
**Impact:** Low  
**Consensus:** Medium  
**Description:** Choose comparison behavior deliberately rather than using `reflect.DeepEqual` for every structured test value.  
**Why:** `DeepEqual` has specialized semantics for nil versus empty slices, unexported fields, functions, NaNs, cycles, and aliased maps or slices that may not match the test's intended equality.  
**Source URL:** https://pkg.go.dev/reflect citeturn123648search3

**Name:** Do not copy `time.Time` through pointers without a semantic reason  
**Category:** Value-type API style  
**Impact:** Low  
**Consensus:** High  
**Description:** Store and pass ordinary `time.Time` values directly rather than using `*time.Time` merely because the type is a struct. Use a pointer only when optionality or mutation semantics require one.  
**Why:** The package explicitly documents `Time` as a value type intended to be stored and passed by value.  
**Source URL:** https://pkg.go.dev/time citeturn204522view0

**Name:** Avoid recursive `String` formatting  
**Category:** Stringer implementation  
**Impact:** Low  
**Consensus:** High  
**Description:** Inside a `String` method, do not format the receiver in a way that invokes the same `String` method again. Convert to a representation that does not implement the method when needed.  
**Why:** Formatting the receiver recursively can cause unbounded recursion.  
**Source URL:** https://go.dev/doc/effective_go citeturn454285search2

**Name:** Avoid expensive log arguments when a `slog` record may be disabled  
**Category:** Logging performance  
**Impact:** Low  
**Consensus:** High  
**Description:** Delay expensive computation or use lazy `LogValuer` behavior when constructing structured logging values that may be filtered out.  
**Why:** Ordinary function arguments are evaluated before the logging call can decide whether the record is enabled.  
**Source URL:** https://go.dev/src/log/slog/doc.go citeturn454285search10

**Name:** Prefer `WalkDir` over `Walk` when file metadata is unnecessary  
**Category:** Filesystem traversal performance  
**Impact:** Low  
**Consensus:** High  
**Description:** For new recursive filesystem traversal, use `filepath.WalkDir` when its `DirEntry` API provides everything needed.  
**Why:** It avoids requiring an `os.FileInfo` lookup for every visited path.  
**Source URL:** https://pkg.go.dev/path/filepath citeturn313524search0

**Name:** Avoid assertion mini-languages when ordinary Go comparisons are clearer  
**Category:** Test style  
**Impact:** Low  
**Consensus:** Low  
**Description:** Go-maintained testing guidance generally favors explicit comparisons and useful failure messages over large assertion DSLs, although third-party assertion libraries remain widely used and many teams reasonably prefer them.  
**Why:** Explicit Go keeps control flow and failure behavior visible, but this is principally a readability tradeoff rather than a correctness rule.  
**Source URL:** https://go.dev/wiki/TestComments citeturn140926view0

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

I’ll preserve the findings one-to-one and keep each rule no broader than its source finding, including version-sensitive and conditional cases.

-----
#### Assistant said:

Name: Synchronize all shared mutable state  
Rule: Concurrent access to shared mutable state MUST use channels, mutexes, atomics, or another documented synchronization mechanism that establishes the required happens-before relationships.

Name: Make every goroutine's lifetime explicit  
Rule: Every goroutine MUST have a defined termination condition and MUST be able to exit when its work completes, is canceled, or is no longer needed.

Name: Goroutine termination is not synchronization  
Rule: Code MUST NOT rely on goroutine termination alone to make writes visible to other goroutines; completion and visibility MUST be synchronized explicitly.

Name: Cancel pipelines when downstream stops early  
Rule: Concurrent pipelines MUST propagate cancellation or otherwise unblock upstream stages when downstream consumers stop before consuming all produced values.

Name: Bound concurrency instead of spawning without limit  
Rule: When work cardinality can grow without a safe intrinsic bound, code MUST impose an explicit concurrency limit instead of spawning an unbounded number of goroutines.

Name: Prefer `WaitGroup.Go` or perform `Add` before launching  
Rule: Ordinary goroutine accounting SHOULD use `WaitGroup.Go`; when `WaitGroup.Add` is used manually, the required `Add` MUST occur before the goroutine is launched.

Name: Always call returned context cancellation functions  
Rule: Every `CancelFunc` returned by `context.WithCancel`, `context.WithTimeout`, or `context.WithDeadline` MUST be called when the derived context is no longer needed.

Name: Propagate request contexts end to end  
Rule: Request-scoped operations MUST propagate the incoming `context.Context` through downstream calls instead of replacing it with `context.Background()` or another unrelated context.

Name: Remember that nil channels block forever  
Rule: Code MUST NOT send to or receive from a nil channel unless indefinite blocking or deliberate disabling of a `select` case is intended.

Name: Close channels only when no future send is possible  
Rule: A channel MUST be closed only when all possible future sends have been excluded, and code MUST NOT close an already closed or nil channel.

Name: Recovery cannot cross goroutine boundaries  
Rule: Any panic that must be recovered MUST be recovered by a deferred function in the same goroutine in which the panic occurs.

Name: Treat loop capture rules as version and declaration sensitive  
Rule: Code MUST account for the module's loop-variable semantics and MUST NOT capture or take the address of a reused loop variable when later iterations can change the observed value.

Name: Synchronize concurrent map access  
Rule: An ordinary map MUST NOT be concurrently written while another goroutine reads or writes it unless access is synchronized.

Name: Treat slices as shared views, not independent values  
Rule: Code MUST treat copied or subsliced slices as potentially sharing a backing array and MUST copy elements when independent ownership is required.

Name: Always use the returned slice after length-changing operations  
Rule: The return value of `append` and slice operations that may change length, capacity, or backing storage MUST be used as the resulting slice.

Name: Do not copy synchronization objects after first use  
Rule: Synchronization types documented as non-copyable, including mutexes, wait groups, `sync.Once`, `sync.Cond`, `sync.Map`, pools, and atomic wrapper types, MUST NOT be copied after first use.

Name: A typed nil inside an interface is not a nil interface  
Rule: Code MUST NOT return a typed nil value inside an interface when callers are intended to observe a nil interface value.

Name: Interface equality can panic  
Rule: Code MUST NOT compare interface values with `==` or `!=` unless their possible dynamic values are known to be comparable.

Name: Use wrapper-aware error inspection  
Rule: Wrapped error identity and type checks MUST use `errors.Is` and an appropriate wrapper-aware type inspection API such as `errors.As` or `errors.AsType`, rather than direct equality or a one-level type assertion.

Name: Treat `%w` as an API commitment  
Rule: `%w` SHOULD be used only when callers are intended to depend on the wrapped error's identity or type; implementation-detail errors SHOULD be formatted without wrapping.

Name: Never wrap `io.EOF`  
Rule: An `io.Reader` signaling end of input MUST return `io.EOF` itself rather than a wrapped form of `io.EOF`.

Name: Do not silently discard meaningful errors  
Rule: Errors that can represent a meaningful failure MUST be handled, propagated, or deliberately documented as ignorable rather than silently assigned to `_`.

Name: Process bytes before handling a simultaneous read error  
Rule: When an `io.Reader` returns both `n > 0` and a non-nil error, code MUST process the returned bytes before handling the error.

Name: Bound reads from untrusted or potentially large streams  
Rule: Code MUST NOT use unbounded whole-stream reads such as `io.ReadAll` on attacker-controlled or potentially large input unless a safe input-size bound is established.

Name: Close HTTP response bodies and consume when reuse matters  
Rule: A successful `http.Client.Do` response body MUST be closed, and when HTTP/1.x connection reuse is required and safely bounded, the body SHOULD be consumed to EOF before closing.

Name: Put deadlines on outbound HTTP work  
Rule: Outbound HTTP operations that are required to complete within bounded time MUST use a request deadline, context cancellation, `Client.Timeout`, or equivalent transport deadlines.

Name: Configure exposed HTTP servers against slow clients and large bodies  
Rule: HTTP servers exposed to untrusted clients SHOULD configure appropriate read, header, write, and idle limits and MUST bound request bodies where excessive body size could exhaust resources.

Name: Parameterize SQL instead of formatting SQL text  
Rule: Untrusted or variable data MUST be passed to SQL operations as parameters and MUST NOT be interpolated into SQL text through formatting or concatenation.

Name: Close SQL rows and check `Rows.Err`  
Rule: Every successfully obtained `*sql.Rows` MUST be closed and iteration MUST be followed by a check of `Rows.Err()`.

Name: Use `sql.Tx`, not raw transaction statements  
Rule: Transactions managed through `database/sql` MUST use `sql.Tx` APIs and MUST NOT mix raw `BEGIN` or `COMMIT` statements or unrelated `sql.DB` operations into the transaction.

Name: Do not disable TLS verification with `InsecureSkipVerify`  
Rule: `tls.Config.InsecureSkipVerify` MUST NOT be enabled unless equivalent certificate and hostname verification is implemented through the documented custom verification hooks.

Name: Use `crypto/rand` for security-sensitive randomness  
Rule: Security-sensitive random values MUST be generated with `crypto/rand`, not `math/rand` or `math/rand/v2`.

Name: Use `html/template` for HTML output  
Rule: Untrusted data rendered into HTML MUST use `html/template`, and untrusted strings MUST NOT be converted to trusted template content types that bypass escaping.

Name: Use `os.Root` for untrusted paths inside a trusted directory  
Rule: When untrusted path input must remain within a trusted directory, code SHOULD use `os.Root`, `os.OpenInRoot`, or an equivalently traversal-resistant mechanism rather than a check-then-open path validation sequence.

Name: Treat archive entry paths and links as hostile  
Rule: Archive extraction MUST ensure every created path and followed link remains within the intended extraction root.

Name: Use `ReverseProxy.Rewrite`, not `Director`, for security-sensitive proxies  
Rule: Security-sensitive `httputil.ReverseProxy` implementations MUST use `Rewrite` rather than the deprecated `Director` hook and MUST construct trusted forwarding headers deliberately.

Name: Configure a public suffix list for production cookie jars  
Rule: Production cookie jars spanning multiple registrable domains MUST use an appropriate `PublicSuffixList` rather than a nil public-suffix configuration.

Name: Configure private module paths before fetching them  
Rule: Private module path patterns MUST be configured with `GOPRIVATE` and any necessary related settings before fetching when disclosure to public module infrastructure is unacceptable.

Name: Preserve public module checksum verification  
Rule: Public module checksum verification MUST NOT be disabled globally merely to support private modules; exemptions SHOULD be limited to the required private module patterns.

Name: Do not store Go pointers in `uintptr`  
Rule: Go pointers MUST NOT be retained in `uintptr` values across operations except within conversion patterns explicitly permitted by the `unsafe` contract.

Name: Follow cgo pointer retention rules  
Rule: C code MUST NOT retain ordinary Go pointers beyond a cgo call unless the referenced memory is pinned or represented through a documented mechanism that permits retention.

Name: Close deterministic resources explicitly  
Rule: Resources whose release or finalization is required for correctness MUST be closed or released explicitly and MUST NOT rely on finalizers, weak references, or GC-triggered cleanup.

Name: Remember that `os.Exit` and `log.Fatal` skip defers  
Rule: Code that requires deferred cleanup MUST NOT terminate through `os.Exit` or `log.Fatal` before that cleanup has been performed.

Name: Do not implement double-checked locking with ordinary loads  
Rule: Shared one-time initialization MUST NOT use unsynchronized double-checked locking with ordinary reads and writes; it SHOULD use `sync.Once` or another correct synchronization mechanism.

Name: Do not busy-wait on an ordinary shared variable  
Rule: A goroutine MUST NOT wait for another goroutine by repeatedly reading an unsynchronized ordinary variable; synchronization or atomic operations MUST be used.

Name: Know `sync.Once` failure semantics  
Rule: Code using a `sync.Once` MUST NOT recursively invoke that same `Once` and MUST NOT rely on its function being retried after a panic.

Name: Do not upgrade or recursively acquire `RWMutex` read locks  
Rule: Code MUST NOT attempt to upgrade an `RWMutex` read lock to a write lock or downgrade a write lock to a read lock, and SHOULD NOT recursively acquire read locks.

Name: Do not use `sync.Pool` as durable storage  
Rule: `sync.Pool` MUST be used only for disposable reusable values whose removal at any time does not affect correctness.

Name: Prefer an ordinary map plus locking unless `sync.Map` fits its specialized cases  
Rule: An ordinary typed map protected by synchronization SHOULD be preferred over `sync.Map` unless the access pattern materially matches `sync.Map`'s specialized use cases.

Name: Wait on `sync.Cond` in a loop  
Rule: Calls to `sync.Cond.Wait` MUST be enclosed in a loop that rechecks the application condition after each wakeup.

Name: Prefer higher-level synchronization to hand-written atomics  
Rule: Shared-state synchronization SHOULD use channels, mutexes, or other higher-level synchronization primitives unless a hand-written atomic algorithm is specifically justified.

Name: Prefer typed 64-bit atomics on 32-bit targets  
Rule: Code that may run on 32-bit targets SHOULD use typed 64-bit atomic wrappers rather than primitive 64-bit atomic operations unless required alignment is otherwise guaranteed.

Name: Do not change the concrete type stored in `atomic.Value`  
Rule: After the first store to an `atomic.Value`, every subsequent stored value MUST have the same concrete type and MUST NOT be nil.

Name: Channel buffering changes synchronization semantics  
Rule: Changing a channel's capacity MUST be treated as a synchronization-semantic change, and correctness MUST NOT depend on happens-before relationships the selected capacity does not guarantee.

Name: `select` does not implement case priority  
Rule: Code MUST NOT rely on textual `select` case order to prioritize among multiple ready cases.

Name: Avoid accidental busy loops with `select default`  
Rule: A `select` with a `default` case SHOULD NOT be placed in an unrestricted loop unless active nonblocking polling is intentional and appropriately controlled.

Name: Use comma-ok when a closed channel's zero value is ambiguous  
Rule: Channel receives MUST use the comma-ok form when the element type's zero value must be distinguished from a closed and drained channel.

Name: Stopping a ticker does not close its channel  
Rule: Code MUST NOT rely on `Ticker.Stop` to close the ticker channel or terminate a goroutine ranging over that channel.

Name: Tickers may drop ticks  
Rule: Code MUST NOT use received ticker events as a guaranteed count of elapsed intervals.

Name: Stop repeating pre-Go-1.23 timer GC advice unconditionally  
Rule: Under Go 1.23+ timer semantics, timers and tickers MUST NOT be stopped solely to make unreachable timer objects garbage-collectable; `Stop` SHOULD be used when future events must be prevented.

Name: Do not inspect `len(timer.C)` to detect a ready timer  
Rule: Timer readiness MUST NOT be determined from `len(timer.C)`; a nonblocking `select` SHOULD be used when readiness must be tested.

Name: Buffer `signal.Notify` channels appropriately  
Rule: Channels passed to `signal.Notify` SHOULD have sufficient buffering for signals that must not be missed, and signal registrations SHOULD be stopped when no longer needed.

Name: Multiply numeric durations by their unit  
Rule: Numeric values converted to `time.Duration` MUST be combined with an explicit time unit unless the value is already defined in nanoseconds.

Name: Compare instants with `Time.Equal`, not usually `==`  
Rule: When comparing whether two `time.Time` values represent the same instant, code MUST use `Time.Equal`; `==` SHOULD be reserved for cases where representation-level equality is intentionally required.

Name: Do not use `time.Date` as strict calendar validation  
Rule: When out-of-range calendar input must be rejected, code MUST validate the fields explicitly and MUST NOT rely on `time.Date` to reject them.

Name: Use `ParseInLocation` for location-dependent local times  
Rule: Zone-less input intended to represent local time in a known location SHOULD be parsed with `time.ParseInLocation`, and interchange formats SHOULD prefer numeric offsets over ambiguous zone abbreviations.

Name: Initialize maps before writing  
Rule: A map MUST be initialized before any assignment to an element.

Name: Use comma-ok when a missing map key matters  
Rule: Map lookup MUST use the comma-ok form when a missing key must be distinguished from a stored zero value.

Name: Never depend on map iteration order  
Rule: Code MUST NOT depend on Go map iteration order and MUST establish an explicit order when deterministic processing or output is required.

Name: Do not rely on newly inserted map entries appearing during range  
Rule: Code MUST NOT rely on entries inserted into a map during iteration being visited by that iteration.

Name: Map elements are not addressable  
Rule: When a map value itself must be modified, code MUST read-modify-write the value or deliberately store pointer values instead of attempting to mutate an unaddressable map element in place.

Name: `maps.Clone` is shallow  
Rule: Code MUST treat `maps.Clone` as a shallow copy and MUST explicitly deep-copy referenced nested data when independent ownership is required.

Name: Range values are copies  
Rule: When ranging over a slice or array, code that intends to modify the original element MUST assign through the element index rather than modifying the range value variable.

Name: A pointer to a range value is not a pointer to the collection element  
Rule: When the address of an actual slice or array element is required, code MUST take the address of the indexed element rather than the range value variable.

Name: Limit slice capacity when append should not mutate adjacent data  
Rule: When a subslice must not allow `append` to overwrite adjacent elements in the original backing array, its capacity MUST be restricted or its elements MUST be copied.

Name: Copy small retained sub-slices out of large buffers  
Rule: A small subslice that must outlive a much larger backing array SHOULD be copied into right-sized storage when retaining the full backing array would be materially wasteful.

Name: `slices.Clone` is shallow  
Rule: Code MUST treat `slices.Clone` as a shallow element copy and MUST explicitly deep-copy referenced nested data when independent ownership is required.

Name: Distinguish bytes, runes, and user-perceived characters  
Rule: String-processing code MUST choose byte, rune, or grapheme semantics deliberately and MUST NOT treat `len`, byte indexing, or rune iteration as interchangeable character operations.

Name: `strings.Trim` takes a cutset, not a substring  
Rule: Exact prefix or suffix removal MUST use `TrimPrefix` or `TrimSuffix`; `strings.Trim` MUST be used only when cutset semantics are intended.

Name: Copy borrowed buffers before retaining them  
Rule: Data returned through APIs that expose borrowed internal buffers MUST be copied before it is retained beyond the operation that guarantees the buffer's validity.

Name: Do not assume `bufio.Scanner` handles arbitrarily large tokens  
Rule: Every `bufio.Scanner` loop MUST check `Scanner.Err`, and scanners whose tokens may exceed the configured limit MUST increase the buffer limit or use a different reader API.

Name: Flush buffered writers and handle the flush error  
Rule: Buffered output MUST be flushed before successful completion is reported, and any flush error that can represent write failure MUST be handled.

Name: Check final close errors when they can report write failure  
Rule: When `Close` can report finalization or delayed write failure, code MUST check the close error if no earlier error already determines the operation's result.

Name: Avoid resource-owning defers in large loops  
Rule: Code SHOULD NOT accumulate deferred resource releases across a potentially large loop; resources SHOULD be released per iteration when retaining them until function return could be material.

Name: Remember that `os.Create` truncates  
Rule: `os.Create` MUST NOT be used when existing file contents must be preserved.

Name: Remove temporary files you create  
Rule: Temporary files and directories created by an operation SHOULD be removed when they are no longer needed unless deliberate retention is part of the contract.

Name: `Hash.Sum` appends rather than hashes its argument  
Rule: Code MUST NOT pass source data to `Hash.Sum` expecting that data to be hashed; data MUST be written to the hash before obtaining the digest.

Name: Use `regexp.Compile` for runtime patterns  
Rule: Runtime-supplied or otherwise fallible regular expressions MUST use `regexp.Compile`; `MustCompile` SHOULD be reserved for patterns whose invalidity is a programming error.

Name: Use literal regexp replacement when `$` has no special meaning  
Rule: Replacement text that must be interpreted literally SHOULD use `ReplaceAllLiteralString` rather than `ReplaceAllString`.

Name: Use comma-ok for uncertain type assertions  
Rule: A type assertion that can legitimately fail MUST use the comma-ok form rather than the panicking single-result form.

Name: Validate narrowing numeric conversions  
Rule: Numeric values MUST be range-checked before a narrowing or signedness-changing conversion when truncation or representation wrapping would be invalid.

Name: Do not use `int` as an external fixed-width representation  
Rule: Values whose serialized, protocol, persistent, or binary representation requires a fixed width MUST use an explicitly sized integer type rather than `int` or `uint`.

Name: Remember arrays copy by value  
Rule: APIs SHOULD use slices rather than arrays for ordinary sequence passing unless copying the entire fixed-size array by value is intentional.

Name: Slice-to-array conversions have length preconditions  
Rule: A slice MUST have sufficient length before conversion to an array or pointer-to-array type unless that precondition is already guaranteed.

Name: Deferred-call arguments are evaluated immediately  
Rule: When a deferred action must observe a variable's later value, it MUST capture that variable through a closure rather than pass the current value as an ordinary deferred-call argument.

Name: Deferred functions can modify named return values  
Rule: Deferred mutation of named return values SHOULD be used only when changing the final returned value is an intentional part of the function's contract.

Name: Watch short declarations for accidental shadowing  
Rule: A short declaration SHOULD NOT redeclare an outer variable such as `err` when subsequent code is intended to read or modify that outer variable.

Name: Do not store contexts in structs by default  
Rule: `context.Context` SHOULD be passed as the first parameter to operations that need it and SHOULD NOT be stored in long-lived structs unless the struct's lifetime intentionally matches the context semantics.

Name: Never pass a nil context  
Rule: A nil `context.Context` MUST NOT be passed; `context.TODO()` SHOULD be used when no appropriate context is yet available.

Name: Keep context values request-scoped and collision-resistant  
Rule: Context values MUST be limited to request-scoped data that crosses API boundaries, and context keys SHOULD use private comparable types rather than built-in strings.

Name: HTTP non-2xx responses are not `Do` errors  
Rule: HTTP application success MUST be determined from the response status or protocol semantics and MUST NOT be inferred solely from `Client.Do` returning a nil error.

Name: Reuse HTTP clients and transports  
Rule: Long-lived code SHOULD reuse `http.Client` and `http.Transport` instances rather than creating new transports per request.

Name: `Client.Timeout` covers body reading too  
Rule: Code configuring `http.Client.Timeout` MUST account for the fact that the timeout covers the full request lifecycle, including response-body reading.

Name: Do not use `ResponseWriter` after the handler returns  
Rule: An `http.ResponseWriter` MUST NOT be used after its `ServeHTTP` call returns unless a documented API explicitly extends its lifetime.

Name: Network deadlines persist until changed  
Rule: Code using `net.Conn` deadlines MUST treat them as persistent absolute deadlines and MUST reset them when implementing per-operation or idle-timeout semantics.

Name: Treat `sql.DB` as a long-lived connection pool  
Rule: Applications SHOULD reuse a long-lived `*sql.DB` rather than opening and closing one per request, and SHOULD configure pool limits when resource constraints require them.

Name: `QueryRow` defers its error until `Scan`  
Rule: Every `QueryRow` result MUST have the error from its subsequent `Scan` checked.

Name: Do not retain `sql.RawBytes` across row advancement  
Rule: `sql.RawBytes` data MUST be copied before it is retained beyond the next row operation or closure of the rows.

Name: Reject unknown JSON fields when the schema must be strict  
Rule: JSON decoding that requires a strict object schema MUST reject unknown fields, such as by using `Decoder.DisallowUnknownFields`.

Name: Ensure a single JSON document has no trailing document  
Rule: When exactly one JSON document is expected, decoding MUST verify that no additional non-whitespace JSON value follows the first document.

Name: Avoid implicit `float64` JSON numbers when precision matters  
Rule: JSON numbers requiring integer or exact textual precision MUST be decoded into appropriate concrete numeric types or with `UseNumber` rather than through the default `any` to `float64` conversion.

Name: Treat a destination as partially modified after JSON failure  
Rule: When JSON decoding must update a destination atomically, code MUST decode into a temporary value and commit it only after successful decoding.

Name: Clear reused maps before JSON decoding when stale keys are invalid  
Rule: A non-nil map reused as a JSON destination MUST be cleared or replaced before decoding when keys absent from the new input must not remain.

Name: Use pointer or nullable representations when JSON null must be distinguishable  
Rule: A JSON field MUST use a pointer or other nullable representation when missing, `null`, and the scalar zero value have distinct meanings.

Name: Remember JSON struct field matching is case-insensitive  
Rule: JSON schemas consumed by `encoding/json` SHOULD NOT define semantically distinct fields that differ only by letter case.

Name: Prefer consumer-defined interfaces and producer-returned concrete types  
Rule: Interfaces SHOULD be defined by the consuming package around the behavior it needs, and constructors SHOULD return concrete types unless an abstraction boundary specifically requires an interface.

Name: Adding a method to a public interface is breaking  
Rule: A compatibility-preserving release MUST NOT add a required method to an exported interface that external code may implement; a new or secondary interface SHOULD be introduced instead.

Name: Function signatures are rigid compatibility surfaces  
Rule: A compatibility-preserving release MUST NOT change an exported function or method signature, including changes that preserve ordinary call syntax but alter its function type.

Name: Do not accidentally destroy exported struct comparability  
Rule: A compatibility-preserving change MUST NOT make a previously comparable exported struct non-comparable when callers may rely on comparison or map-key use.

Name: New configuration fields should preserve useful zero-value behavior  
Rule: New fields added to exported configuration structs SHOULD make their zero values preserve existing behavior unless a deliberate breaking change is intended.

Name: Understand pointer versus value method sets  
Rule: Code MUST NOT assume `T` implements methods defined only on `*T`; interface assignments MUST use a value whose method set contains every required method.

Name: Do not pass pointers to interfaces  
Rule: APIs SHOULD accept or return interface values directly rather than pointers to interfaces unless mutation of the interface variable itself is specifically required.

Name: Use an interface instead of a type parameter when only methods matter  
Rule: When an abstraction only needs to invoke methods and does not need to preserve or operate on concrete type identity, it SHOULD use an interface rather than a type parameter.

Name: Do not introduce generics before repeated type-level need exists  
Rule: Generic abstractions SHOULD NOT be introduced unless the implementation materially benefits from operating over multiple types or preserving type relationships.

Name: `comparable` does not guarantee panic-free equality for interface type arguments  
Rule: Generic code accepting interface types under a `comparable` constraint MUST NOT assume interface equality is panic-free and MUST avoid comparing dynamic values that may be non-comparable.

Name: Iterator implementations must stop after `yield` returns false  
Rule: A range-over-function iterator MUST return and MUST NOT call `yield` again after `yield` returns false.

Name: Call `stop` when abandoning `iter.Pull` early  
Rule: Code that abandons an `iter.Pull` iterator before natural exhaustion MUST call its returned `stop` function.

Name: Do not rely on your module's `replace` directives propagating to consumers  
Rule: Published module behavior MUST NOT depend on `replace` or `exclude` directives that apply only in the developer's main module or workspace.

Name: Test modules outside workspace influence when consumer behavior matters  
Rule: Modules intended for external consumption SHOULD be tested with workspace influence disabled, such as `GOWORK=off`, when verifying standalone consumer behavior.

Name: Minimal Version Selection does not mean latest  
Rule: Dependency management MUST NOT assume Minimal Version Selection chooses the newest available release; upgrades and freshness checks SHOULD select versions explicitly.

Name: Treat the `go` directive as semantic configuration  
Rule: Changes to a module's `go` directive MUST be treated as semantic compatibility changes and SHOULD be accompanied by validation of language and runtime behavior affected by that version.

Name: Major versions v2+ belong in the module path  
Rule: Ordinary Go modules at major version v2 or higher MUST include the corresponding `/vN` suffix in the module and import path unless a documented semantic-import-versioning exception applies.

Name: Use `tool` directives for project-pinned Go tools  
Rule: Projects targeting Go 1.24 or later SHOULD declare module-managed Go tool dependencies with `tool` directives rather than the legacy dummy-import `tools.go` pattern.

Name: Remember build constraints can hide source files and dependencies  
Rule: Projects supporting multiple build tags, operating systems, or architectures SHOULD test every materially supported configuration rather than relying solely on the source set selected on the development machine.

Name: Do not hand-delete dependencies merely because the current platform does not import them  
Rule: Module requirements MUST NOT be removed solely because the current platform or build tags do not import them; dependency cleanup SHOULD be performed with `go mod tidy`.

Name: A clean race-detector run is not proof of race freedom  
Rule: Concurrency-sensitive code SHOULD be exercised with the race detector, but a clean race-detector run MUST NOT be treated as proof that the program is race-free.

Name: Run `go vet`, but do not treat silence as correctness proof  
Rule: Go code SHOULD be checked with `go vet`, but the absence of vet diagnostics MUST NOT be treated as proof of correctness.

Name: Keep fuzz targets deterministic and isolated  
Rule: A fuzz target MUST produce behavior determined by its current input and MUST NOT depend on mutable state left by previous fuzz invocations.

Name: Do not call `Fatal` from a helper goroutine  
Rule: `FailNow`, `Fatal`, `Fatalf`, `SkipNow`, and equivalent test-terminating methods MUST be called only from the goroutine running the test or benchmark.

Name: Do not combine parallel tests with process-global environment or directory changes  
Rule: Tests that mutate process-global environment variables or the working directory MUST NOT run in parallel with tests that can observe the same process state.

Name: Prefer `testing/synctest` to real sleeps for asynchronous timing tests  
Rule: Tests of asynchronous timing behavior SHOULD use `testing/synctest` or deterministic synchronization instead of real sleeps when the behavior can be expressed with those mechanisms.

Name: Prefer `B.Loop` for ordinary benchmarks on modern Go  
Rule: New ordinary benchmarks on Go versions supporting it SHOULD use `B.Loop` unless explicit lower-level control of the benchmark loop is required.

Name: Every successfully started subprocess must be waited for  
Rule: Every successful `exec.Cmd.Start` MUST be followed by `Wait`, unless an API that performs the wait internally is used instead.

Name: Consume command pipes before waiting  
Rule: Pipes obtained from `StdoutPipe` or `StderrPipe` MUST be consumed to completion before `Wait` closes them, and those pipe APIs MUST NOT be combined with `Run`.

Name: Do not bypass `exec.ErrDot` casually  
Rule: Code MUST NOT bypass `exec.ErrDot` merely to restore implicit current-directory executable lookup; intended current-directory executables SHOULD be referenced explicitly.

Name: Do not use MD5 or SHA-1 for cryptographic security  
Rule: MD5 and SHA-1 MUST NOT be used where cryptographic collision resistance or modern security properties are required.

Name: Use constant-time comparison for secret values when timing matters  
Rule: Secret values whose comparison timing could reveal information MUST be compared with an appropriate constant-time primitive.

Name: Guard reflection operations by validity and kind  
Rule: Reflection code MUST establish the required validity, kind, addressability, and settable properties before invoking operations that panic when those preconditions are not met.

Name: Do not capture an `AddCleanup` target in its cleanup  
Rule: A cleanup registered for an object MUST NOT retain that object directly or indirectly through the cleanup closure or its arguments.

Name: Do not assume `GOMAXPROCS` equals host CPU count in containers  
Rule: Containerized code SHOULD NOT override `GOMAXPROCS` based solely on host CPU count and SHOULD account for the Go version's container-aware runtime behavior before overriding the default.

Name: `GOMEMLIMIT` is not a process RSS limit  
Rule: Resource planning MUST NOT treat `GOMEMLIMIT` or `debug.SetMemoryLimit` as a hard cap on total process resident memory.

Name: Use `path`, not `filepath`, for slash-defined URL paths  
Rule: Slash-defined URL and protocol paths MUST use `path` or URL-specific APIs rather than `path/filepath`; `filepath` SHOULD be reserved for native filesystem paths.

Name: Escape URL components according to their context  
Rule: URL components MUST be escaped with an API appropriate to their syntactic context, such as path-segment escaping for path data and query escaping for query values.

Name: Prefer `net/netip` for value-like IP addresses in new APIs  
Rule: New APIs that need immutable, comparable, value-like IP addresses SHOULD use `netip.Addr` unless compatibility or another concrete requirement favors `net.IP`.

Name: Do not assume standard-library output bytes remain implementation-stable  
Rule: Tests and protocols MUST NOT depend on exact standard-library output bytes unless the relevant API explicitly guarantees byte-for-byte stability.

Name: Do not copy a nonzero `strings.Builder`  
Rule: A `strings.Builder` MUST NOT be copied after first use.

Name: Avoid copying mutable structs with pointer receiver methods  
Rule: Mutable structs whose copies can share internal state, such as a nonzero `bytes.Buffer`, SHOULD NOT be copied after use unless the resulting aliasing is explicitly intended and safe.

Name: Do not use panic for expected operational failures  
Rule: Expected operational failures such as invalid input, unavailable resources, or failed external operations MUST be returned as errors rather than represented with panic.

Name: Use out-of-band status instead of sentinel result values  
Rule: APIs SHOULD return an explicit status or error value rather than encode failure in an ordinary result value that can also be valid data.

Name: Process partial network writes before timeout errors  
Rule: When a network operation returns both `n > 0` and an error, code MUST account for the successfully transferred bytes before handling the error.

Name: Check primary C return values before `errno`  
Rule: cgo code MUST determine whether a C call failed from the call's documented primary return value before interpreting `errno`.

Name: Do not expose C types in public Go APIs  
Rule: Exported Go APIs SHOULD NOT expose cgo-generated C types and SHOULD translate boundary values into ordinary Go types.

Name: Prefer typed atomic wrappers over primitive operations where practical  
Rule: New code SHOULD prefer typed atomic wrappers such as `atomic.Int64`, `atomic.Bool`, or `atomic.Pointer[T]` over primitive atomic functions when they express the required operation.

Name: Prefer synchronous APIs unless asynchronous behavior belongs in the abstraction  
Rule: APIs SHOULD perform work synchronously when callers can trivially add concurrency themselves, unless asynchronous execution is an inherent part of the abstraction.

Name: Functional options are not a universal rule  
Rule: APIs SHOULD choose functional options, configuration structs, or other configuration mechanisms according to their compatibility and usability requirements and SHOULD NOT adopt functional options solely as a universal style rule.

Name: Format Go code with `gofmt`  
Rule: Go source SHOULD be formatted with `gofmt` or a compatible formatter such as `goimports` rather than project-specific manual formatting.

Name: Keep error strings lowercase and composable  
Rule: Error strings SHOULD normally begin with lowercase text and SHOULD omit terminal punctuation unless grammar or a proper noun requires otherwise.

Name: Prefer the nil slice as the ordinary empty zero value  
Rule: Code SHOULD use a nil slice as the ordinary empty zero value unless a non-nil empty slice has distinct required semantics.

Name: Do not design APIs that distinguish nil and empty slices without need  
Rule: APIs SHOULD treat nil and zero-length slices equivalently unless their distinction represents meaningful domain or serialization semantics.

Name: Avoid dot imports in normal code  
Rule: Production Go code SHOULD NOT use dot imports except where an exceptional package or test constraint provides a concrete justification.

Name: Keep side-effect-only imports localized  
Rule: Blank imports used solely for package initialization side effects SHOULD be localized to entry points or tests that explicitly require those effects.

Name: Avoid unnecessary import renaming  
Rule: Imports SHOULD use their package's natural name unless an alias is required to resolve a collision or another concrete naming problem.

Name: Preserve conventional initialism capitalization  
Rule: Go identifiers SHOULD preserve conventional initialisms consistently, such as `ID`, `URL`, and `HTTP`.

Name: Avoid pointers merely to reduce value-copy size  
Rule: APIs SHOULD NOT use pointers to small immutable values merely to avoid copying unless pointer semantics, nilability, or measured performance requirements justify them.

Name: Do not use `new` for slices and maps by habit  
Rule: Slices and maps SHOULD use their zero value or `make` rather than `new` unless a pointer to the container itself is specifically required.

Name: Avoid unkeyed literals for external struct types  
Rule: Struct literals for types defined in another package SHOULD use keyed fields rather than positional unkeyed values.

Name: Prefer semantic error assertions in tests  
Rule: Tests SHOULD use `errors.Is`, `errors.As`, or equivalent semantic checks when error identity or type is the contract rather than asserting the entire error string.

Name: Mark test helpers with `t.Helper`  
Rule: Reusable test functions that report failures on behalf of their callers SHOULD call `t.Helper()`.

Name: Prefer useful got/want test failures  
Rule: Comparison failures SHOULD report enough input, actual, and expected information to identify the failed comparison without requiring immediate reproduction.

Name: Avoid exact-byte tests for outputs whose representation is not contractual  
Rule: Tests SHOULD assert semantic output or documented properties rather than exact bytes when the output representation is not part of the API contract.

Name: Prefer `cmp`-style semantic comparison over reflexive `reflect.DeepEqual` use in tests  
Rule: Tests SHOULD choose comparison semantics deliberately and SHOULD NOT use `reflect.DeepEqual` by default when its nil, aliasing, unexported-field, function, NaN, or cycle semantics do not match the intended equality.

Name: Do not copy `time.Time` through pointers without a semantic reason  
Rule: `time.Time` SHOULD be stored and passed by value unless pointer semantics are required for optionality, mutation, or another concrete API requirement.

Name: Avoid recursive `String` formatting  
Rule: A `String` method MUST NOT format its receiver through a path that invokes the same `String` method recursively.

Name: Avoid expensive log arguments when a `slog` record may be disabled  
Rule: Expensive values for potentially disabled `slog` records SHOULD be computed lazily or guarded by an enabled check rather than evaluated unconditionally.

Name: Prefer `WalkDir` over `Walk` when file metadata is unnecessary  
Rule: New filesystem traversal code SHOULD use `filepath.WalkDir` instead of `filepath.Walk` when `os.FileInfo` metadata is not required.

Name: Avoid assertion mini-languages when ordinary Go comparisons are clearer  
Rule: Tests SHOULD prefer explicit Go comparisons and failure messages over assertion DSLs when the ordinary Go form is equally clear; assertion libraries MAY be used when they materially improve readability or diagnostics.
