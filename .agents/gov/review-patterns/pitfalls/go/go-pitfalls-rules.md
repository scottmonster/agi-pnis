# Go Pitfalls Rules

## Concurrency, Context, and Synchronization

### Memory model and data races
1.1.1 **Synchronize all shared mutable state** - Concurrent access to shared mutable state MUST use channels, mutexes, atomics, or another documented synchronization mechanism that establishes the required happens-before relationships.

### Goroutine lifecycle
1.2.1 **Make every goroutine's lifetime explicit** - Every goroutine MUST have a defined termination condition and MUST be able to exit when its work completes, is canceled, or is no longer needed.

### Synchronization semantics
1.3.1 **Goroutine termination is not synchronization** - Code MUST NOT rely on goroutine termination alone to make writes visible to other goroutines; completion and visibility MUST be synchronized explicitly.

### Concurrency cancellation
1.4.1 **Cancel pipelines when downstream stops early** - Concurrent pipelines MUST propagate cancellation or otherwise unblock upstream stages when downstream consumers stop before consuming all produced values.

### Concurrency backpressure
1.5.1 **Bound concurrency instead of spawning without limit** - When work cardinality can grow without a safe intrinsic bound, code MUST impose an explicit concurrency limit instead of spawning an unbounded number of goroutines.

### Goroutine accounting
1.6.1 **Prefer `WaitGroup.Go` or perform `Add` before launching** - Ordinary goroutine accounting SHOULD use `WaitGroup.Go`; when `WaitGroup.Add` is used manually, the required `Add` MUST occur before the goroutine is launched.

### Context lifecycle
1.7.1 **Always call returned context cancellation functions** - Every `CancelFunc` returned by `context.WithCancel`, `context.WithTimeout`, or `context.WithDeadline` MUST be called when the derived context is no longer needed.

### Context propagation
1.8.1 **Propagate request contexts end to end** - Request-scoped operations MUST propagate the incoming `context.Context` through downstream calls instead of replacing it with `context.Background()` or another unrelated context.

### Channel semantics
1.9.1 **Remember that nil channels block forever** - Code MUST NOT send to or receive from a nil channel unless indefinite blocking or deliberate disabling of a `select` case is intended.

### Channel lifecycle
1.10.1 **Close channels only when no future send is possible** - A channel MUST be closed only when all possible future sends have been excluded, and code MUST NOT close an already closed or nil channel.

### Panic containment
1.11.1 **Recovery cannot cross goroutine boundaries** - Any panic that must be recovered MUST be recovered by a deferred function in the same goroutine in which the panic occurs.

### Loop variable semantics
1.12.1 **Treat loop capture rules as version and declaration sensitive** - Code MUST account for the module's loop-variable semantics and MUST NOT capture or take the address of a reused loop variable when later iterations can change the observed value.

### Map concurrency
1.13.1 **Synchronize concurrent map access** - An ordinary map MUST NOT be concurrently written while another goroutine reads or writes it unless access is synchronized.

### Slice ownership
1.14.1 **Treat slices as shared views, not independent values** - Code MUST treat copied or subsliced slices as potentially sharing a backing array and MUST copy elements when independent ownership is required.

### Slice mutation
1.15.1 **Always use the returned slice after length-changing operations** - The return value of `append` and slice operations that may change length, capacity, or backing storage MUST be used as the resulting slice.

### Synchronization object identity
1.16.1 **Do not copy synchronization objects after first use** - Synchronization types documented as non-copyable, including mutexes, wait groups, `sync.Once`, `sync.Cond`, `sync.Map`, pools, and atomic wrapper types, MUST NOT be copied after first use.

## Types, Values, and Error Semantics

### Interface representation
2.1.1 **A typed nil inside an interface is not a nil interface** - Code MUST NOT return a typed nil value inside an interface when callers are intended to observe a nil interface value.

### Interface comparability
2.2.1 **Interface equality can panic** - Code MUST NOT compare interface values with `==` or `!=` unless their possible dynamic values are known to be comparable.

### Error identity
2.3.1 **Use wrapper-aware error inspection** - Wrapped error identity and type checks MUST use `errors.Is` and an appropriate wrapper-aware type inspection API such as `errors.As` or `errors.AsType`, rather than direct equality or a one-level type assertion.

### Error API design
2.4.1 **Treat `%w` as an API commitment** - `%w` SHOULD be used only when callers are intended to depend on the wrapped error's identity or type; implementation-detail errors SHOULD be formatted without wrapping.

### I/O error contracts
2.5.1 **Never wrap `io.EOF`** - An `io.Reader` signaling end of input MUST return `io.EOF` itself rather than a wrapped form of `io.EOF`.

### Error handling
2.6.1 **Do not silently discard meaningful errors** - Errors that can represent a meaningful failure MUST be handled, propagated, or deliberately documented as ignorable rather than silently assigned to `_`.

### Reader semantics
2.7.1 **Process bytes before handling a simultaneous read error** - When an `io.Reader` returns both `n > 0` and a non-nil error, code MUST process the returned bytes before handling the error.

### Memory and input limits
2.8.1 **Bound reads from untrusted or potentially large streams** - Code MUST NOT use unbounded whole-stream reads such as `io.ReadAll` on attacker-controlled or potentially large input unless a safe input-size bound is established.

## HTTP and Database Operations

### HTTP connection lifecycle
3.1.1 **Close HTTP response bodies and consume when reuse matters** - A successful `http.Client.Do` response body MUST be closed, and when HTTP/1.x connection reuse is required and safely bounded, the body SHOULD be consumed to EOF before closing.

### Network lifecycle
3.2.1 **Put deadlines on outbound HTTP work** - Outbound HTTP operations that are required to complete within bounded time MUST use a request deadline, context cancellation, `Client.Timeout`, or equivalent transport deadlines.

### HTTP resource limits
3.3.1 **Configure exposed HTTP servers against slow clients and large bodies** - HTTP servers exposed to untrusted clients SHOULD configure appropriate read, header, write, and idle limits and MUST bound request bodies where excessive body size could exhaust resources.

### Database security
3.4.1 **Parameterize SQL instead of formatting SQL text** - Untrusted or variable data MUST be passed to SQL operations as parameters and MUST NOT be interpolated into SQL text through formatting or concatenation.

### Database result lifecycle
3.5.1 **Close SQL rows and check `Rows.Err`** - Every successfully obtained `*sql.Rows` MUST be closed and iteration MUST be followed by a check of `Rows.Err()`.

### Database transaction integrity
3.6.1 **Use `sql.Tx`, not raw transaction statements** - Transactions managed through `database/sql` MUST use `sql.Tx` APIs and MUST NOT mix raw `BEGIN` or `COMMIT` statements or unrelated `sql.DB` operations into the transaction.

## Security and Trust Boundaries

### TLS authentication
4.1.1 **Do not disable TLS verification with `InsecureSkipVerify`** - `tls.Config.InsecureSkipVerify` MUST NOT be enabled unless equivalent certificate and hostname verification is implemented through the documented custom verification hooks.

### Cryptographic randomness
4.2.1 **Use `crypto/rand` for security-sensitive randomness** - Security-sensitive random values MUST be generated with `crypto/rand`, not `math/rand` or `math/rand/v2`.

### Output escaping
4.3.1 **Use `html/template` for HTML output** - Untrusted data rendered into HTML MUST use `html/template`, and untrusted strings MUST NOT be converted to trusted template content types that bypass escaping.

### Filesystem traversal security
4.4.1 **Use `os.Root` for untrusted paths inside a trusted directory** - When untrusted path input must remain within a trusted directory, code SHOULD use `os.Root`, `os.OpenInRoot`, or an equivalently traversal-resistant mechanism rather than a check-then-open path validation sequence.

### Archive extraction security
4.5.1 **Treat archive entry paths and links as hostile** - Archive extraction MUST ensure every created path and followed link remains within the intended extraction root.

### Reverse proxy security
4.6.1 **Use `ReverseProxy.Rewrite`, not `Director`, for security-sensitive proxies** - Security-sensitive `httputil.ReverseProxy` implementations MUST use `Rewrite` rather than the deprecated `Director` hook and MUST construct trusted forwarding headers deliberately.

### Cookie isolation
4.7.1 **Configure a public suffix list for production cookie jars** - Production cookie jars spanning multiple registrable domains MUST use an appropriate `PublicSuffixList` rather than a nil public-suffix configuration.

### Module privacy
4.8.1 **Configure private module paths before fetching them** - Private module path patterns MUST be configured with `GOPRIVATE` and any necessary related settings before fetching when disclosure to public module infrastructure is unacceptable.

### Dependency integrity
4.9.1 **Preserve public module checksum verification** - Public module checksum verification MUST NOT be disabled globally merely to support private modules; exemptions SHOULD be limited to the required private module patterns.

### Unsafe memory lifetime
4.10.1 **Do not store Go pointers in `uintptr`** - Go pointers MUST NOT be retained in `uintptr` values across operations except within conversion patterns explicitly permitted by the `unsafe` contract.

### Go and C memory interoperability
4.11.1 **Follow cgo pointer retention rules** - C code MUST NOT retain ordinary Go pointers beyond a cgo call unless the referenced memory is pinned or represented through a documented mechanism that permits retention.

## Deterministic Cleanup and Termination

### Garbage collection and external resources
5.1.1 **Close deterministic resources explicitly** - Resources whose release or finalization is required for correctness MUST be closed or released explicitly and MUST NOT rely on finalizers, weak references, or GC-triggered cleanup.

### Process termination
5.2.1 **Remember that `os.Exit` and `log.Fatal` skip defers** - Code that requires deferred cleanup MUST NOT terminate through `os.Exit` or `log.Fatal` before that cleanup has been performed.

## Synchronization, Channels, and Time

### Synchronization algorithms
6.1.1 **Do not implement double-checked locking with ordinary loads** - Shared one-time initialization MUST NOT use unsynchronized double-checked locking with ordinary reads and writes; it SHOULD use `sync.Once` or another correct synchronization mechanism.

### Synchronization visibility
6.2.1 **Do not busy-wait on an ordinary shared variable** - A goroutine MUST NOT wait for another goroutine by repeatedly reading an unsynchronized ordinary variable; synchronization or atomic operations MUST be used.

### One-time initialization
6.3.1 **Know `sync.Once` failure semantics** - Code using a `sync.Once` MUST NOT recursively invoke that same `Once` and MUST NOT rely on its function being retried after a panic.

### Read-write locking
6.4.1 **Do not upgrade or recursively acquire `RWMutex` read locks** - Code MUST NOT attempt to upgrade an `RWMutex` read lock to a write lock or downgrade a write lock to a read lock, and SHOULD NOT recursively acquire read locks.

### Temporary object reuse
6.5.1 **Do not use `sync.Pool` as durable storage** - `sync.Pool` MUST be used only for disposable reusable values whose removal at any time does not affect correctness.

### Concurrent collections
6.6.1 **Prefer an ordinary map plus locking unless `sync.Map` fits its specialized cases** - An ordinary typed map protected by synchronization SHOULD be preferred over `sync.Map` unless the access pattern materially matches `sync.Map`'s specialized use cases.

### Condition synchronization
6.7.1 **Wait on `sync.Cond` in a loop** - Calls to `sync.Cond.Wait` MUST be enclosed in a loop that rechecks the application condition after each wakeup.

### Atomic synchronization
6.8.1 **Prefer higher-level synchronization to hand-written atomics** - Shared-state synchronization SHOULD use channels, mutexes, or other higher-level synchronization primitives unless a hand-written atomic algorithm is specifically justified.

### Atomic alignment
6.9.1 **Prefer typed 64-bit atomics on 32-bit targets** - Code that may run on 32-bit targets SHOULD use typed 64-bit atomic wrappers rather than primitive 64-bit atomic operations unless required alignment is otherwise guaranteed.

### Atomic dynamic values
6.10.1 **Do not change the concrete type stored in `atomic.Value`** - After the first store to an `atomic.Value`, every subsequent stored value MUST have the same concrete type and MUST NOT be nil.

### Channel happens-before relationships
6.11.1 **Channel buffering changes synchronization semantics** - Changing a channel's capacity MUST be treated as a synchronization-semantic change, and correctness MUST NOT depend on happens-before relationships the selected capacity does not guarantee.

### Select semantics
6.12.1 **`select` does not implement case priority** - Code MUST NOT rely on textual `select` case order to prioritize among multiple ready cases.

### Nonblocking concurrency
6.13.1 **Avoid accidental busy loops with `select default`** - A `select` with a `default` case SHOULD NOT be placed in an unrestricted loop unless active nonblocking polling is intentional and appropriately controlled.

### Channel receive semantics
6.14.1 **Use comma-ok when a closed channel's zero value is ambiguous** - Channel receives MUST use the comma-ok form when the element type's zero value must be distinguished from a closed and drained channel.

### Timer lifecycle
6.15.1 **Stopping a ticker does not close its channel** - Code MUST NOT rely on `Ticker.Stop` to close the ticker channel or terminate a goroutine ranging over that channel.

### Timer delivery semantics
6.16.1 **Tickers may drop ticks** - Code MUST NOT use received ticker events as a guaranteed count of elapsed intervals.

### Version-dependent timer behavior
6.17.1 **Stop repeating pre-Go-1.23 timer GC advice unconditionally** - Under Go 1.23+ timer semantics, timers and tickers MUST NOT be stopped solely to make unreachable timer objects garbage-collectable; `Stop` SHOULD be used when future events must be prevented.

### Timer channel semantics
6.18.1 **Do not inspect `len(timer.C)` to detect a ready timer** - Timer readiness MUST NOT be determined from `len(timer.C)`; a nonblocking `select` SHOULD be used when readiness must be tested.

### OS signal delivery
6.19.1 **Buffer `signal.Notify` channels appropriately** - Channels passed to `signal.Notify` SHOULD have sufficient buffering for signals that must not be missed, and signal registrations SHOULD be stopped when no longer needed.

## Collections, Text, and Resource I/O

### Time units
7.1.1 **Multiply numeric durations by their unit** - Numeric values converted to `time.Duration` MUST be combined with an explicit time unit unless the value is already defined in nanoseconds.

### Time representation
7.2.1 **Compare instants with `Time.Equal`, not usually `==`** - When comparing whether two `time.Time` values represent the same instant, code MUST use `Time.Equal`; `==` SHOULD be reserved for cases where representation-level equality is intentionally required.

### Calendar semantics
7.3.1 **Do not use `time.Date` as strict calendar validation** - When out-of-range calendar input must be rejected, code MUST validate the fields explicitly and MUST NOT rely on `time.Date` to reject them.

### Time parsing
7.4.1 **Use `ParseInLocation` for location-dependent local times** - Zone-less input intended to represent local time in a known location SHOULD be parsed with `time.ParseInLocation`, and interchange formats SHOULD prefer numeric offsets over ambiguous zone abbreviations.

### Map zero values
7.5.1 **Initialize maps before writing** - A map MUST be initialized before any assignment to an element.

### Map lookup semantics
7.6.1 **Use comma-ok when a missing map key matters** - Map lookup MUST use the comma-ok form when a missing key must be distinguished from a stored zero value.

### Map iteration
7.7.1 **Never depend on map iteration order** - Code MUST NOT depend on Go map iteration order and MUST establish an explicit order when deterministic processing or output is required.

### Map mutation during iteration
7.8.1 **Do not rely on newly inserted map entries appearing during range** - Code MUST NOT rely on entries inserted into a map during iteration being visited by that iteration.

### Map value mutation
7.9.1 **Map elements are not addressable** - When a map value itself must be modified, code MUST read-modify-write the value or deliberately store pointer values instead of attempting to mutate an unaddressable map element in place.

### Collection copying
7.10.1 **`maps.Clone` is shallow** - Code MUST treat `maps.Clone` as a shallow copy and MUST explicitly deep-copy referenced nested data when independent ownership is required.

### Range semantics
7.11.1 **Range values are copies** - When ranging over a slice or array, code that intends to modify the original element MUST assign through the element index rather than modifying the range value variable.

### Range and pointer semantics
7.12.1 **A pointer to a range value is not a pointer to the collection element** - When the address of an actual slice or array element is required, code MUST take the address of the indexed element rather than the range value variable.

### Slice capacity control
7.13.1 **Limit slice capacity when append should not mutate adjacent data** - When a subslice must not allow `append` to overwrite adjacent elements in the original backing array, its capacity MUST be restricted or its elements MUST be copied.

### Memory retention
7.14.1 **Copy small retained sub-slices out of large buffers** - A small subslice that must outlive a much larger backing array SHOULD be copied into right-sized storage when retaining the full backing array would be materially wasteful.

### Collection copying
7.15.1 **`slices.Clone` is shallow** - Code MUST treat `slices.Clone` as a shallow element copy and MUST explicitly deep-copy referenced nested data when independent ownership is required.

### Strings and Unicode
7.16.1 **Distinguish bytes, runes, and user-perceived characters** - String-processing code MUST choose byte, rune, or grapheme semantics deliberately and MUST NOT treat `len`, byte indexing, or rune iteration as interchangeable character operations.

### String API semantics
7.17.1 **`strings.Trim` takes a cutset, not a substring** - Exact prefix or suffix removal MUST use `TrimPrefix` or `TrimSuffix`; `strings.Trim` MUST be used only when cutset semantics are intended.

### Buffer lifetime
7.18.1 **Copy borrowed buffers before retaining them** - Data returned through APIs that expose borrowed internal buffers MUST be copied before it is retained beyond the operation that guarantees the buffer's validity.

### Buffered input limits
7.19.1 **Do not assume `bufio.Scanner` handles arbitrarily large tokens** - Every `bufio.Scanner` loop MUST check `Scanner.Err`, and scanners whose tokens may exceed the configured limit MUST increase the buffer limit or use a different reader API.

### Buffered output lifecycle
7.20.1 **Flush buffered writers and handle the flush error** - Buffered output MUST be flushed before successful completion is reported, and any flush error that can represent write failure MUST be handled.

### Durable output
7.21.1 **Check final close errors when they can report write failure** - When `Close` can report finalization or delayed write failure, code MUST check the close error if no earlier error already determines the operation's result.

### Deferred cleanup scope
7.22.1 **Avoid resource-owning defers in large loops** - Code SHOULD NOT accumulate deferred resource releases across a potentially large loop; resources SHOULD be released per iteration when retaining them until function return could be material.

### File opening semantics
7.23.1 **Remember that `os.Create` truncates** - `os.Create` MUST NOT be used when existing file contents must be preserved.

## Language Semantics and Context APIs

### Temporary resource lifecycle
8.1.1 **Remove temporary files you create** - Temporary files and directories created by an operation SHOULD be removed when they are no longer needed unless deliberate retention is part of the contract.

### Hash API semantics
8.2.1 **`Hash.Sum` appends rather than hashes its argument** - Code MUST NOT pass source data to `Hash.Sum` expecting that data to be hashed; data MUST be written to the hash before obtaining the digest.

### Regular-expression error handling
8.3.1 **Use `regexp.Compile` for runtime patterns** - Runtime-supplied or otherwise fallible regular expressions MUST use `regexp.Compile`; `MustCompile` SHOULD be reserved for patterns whose invalidity is a programming error.

### Regular-expression substitution
8.4.1 **Use literal regexp replacement when `$` has no special meaning** - Replacement text that must be interpreted literally SHOULD use `ReplaceAllLiteralString` rather than `ReplaceAllString`.

### Type assertions
8.5.1 **Use comma-ok for uncertain type assertions** - A type assertion that can legitimately fail MUST use the comma-ok form rather than the panicking single-result form.

### Numeric conversions
8.6.1 **Validate narrowing numeric conversions** - Numeric values MUST be range-checked before a narrowing or signedness-changing conversion when truncation or representation wrapping would be invalid.

### Integer portability
8.7.1 **Do not use `int` as an external fixed-width representation** - Values whose serialized, protocol, persistent, or binary representation requires a fixed width MUST use an explicitly sized integer type rather than `int` or `uint`.

### Array semantics
8.8.1 **Remember arrays copy by value** - APIs SHOULD use slices rather than arrays for ordinary sequence passing unless copying the entire fixed-size array by value is intentional.

### Conversion panics
8.9.1 **Slice-to-array conversions have length preconditions** - A slice MUST have sufficient length before conversion to an array or pointer-to-array type unless that precondition is already guaranteed.

### Defer semantics
8.10.1 **Deferred-call arguments are evaluated immediately** - When a deferred action must observe a variable's later value, it MUST capture that variable through a closure rather than pass the current value as an ordinary deferred-call argument.

### Return semantics
8.11.1 **Deferred functions can modify named return values** - Deferred mutation of named return values SHOULD be used only when changing the final returned value is an intentional part of the function's contract.

### Variable scope
8.12.1 **Watch short declarations for accidental shadowing** - A short declaration SHOULD NOT redeclare an outer variable such as `err` when subsequent code is intended to read or modify that outer variable.

## HTTP, SQL, and JSON Contracts

### Context API design
9.1.1 **Do not store contexts in structs by default** - `context.Context` SHOULD be passed as the first parameter to operations that need it and SHOULD NOT be stored in long-lived structs unless the struct's lifetime intentionally matches the context semantics.

### Context API contract
9.2.1 **Never pass a nil context** - A nil `context.Context` MUST NOT be passed; `context.TODO()` SHOULD be used when no appropriate context is yet available.

### Context metadata
9.3.1 **Keep context values request-scoped and collision-resistant** - Context values MUST be limited to request-scoped data that crosses API boundaries, and context keys SHOULD use private comparable types rather than built-in strings.

### HTTP response semantics
9.4.1 **HTTP non-2xx responses are not `Do` errors** - HTTP application success MUST be determined from the response status or protocol semantics and MUST NOT be inferred solely from `Client.Do` returning a nil error.

### HTTP connection pooling
9.5.1 **Reuse HTTP clients and transports** - Long-lived code SHOULD reuse `http.Client` and `http.Transport` instances rather than creating new transports per request.

### HTTP timeout semantics
9.6.1 **`Client.Timeout` covers body reading too** - Code configuring `http.Client.Timeout` MUST account for the fact that the timeout covers the full request lifecycle, including response-body reading.

### HTTP handler lifetime
9.7.1 **Do not use `ResponseWriter` after the handler returns** - An `http.ResponseWriter` MUST NOT be used after its `ServeHTTP` call returns unless a documented API explicitly extends its lifetime.

### Socket deadlines
9.8.1 **Network deadlines persist until changed** - Code using `net.Conn` deadlines MUST treat them as persistent absolute deadlines and MUST reset them when implementing per-operation or idle-timeout semantics.

### Database connection management
9.9.1 **Treat `sql.DB` as a long-lived connection pool** - Applications SHOULD reuse a long-lived `*sql.DB` rather than opening and closing one per request, and SHOULD configure pool limits when resource constraints require them.

### Database error timing
9.10.1 **`QueryRow` defers its error until `Scan`** - Every `QueryRow` result MUST have the error from its subsequent `Scan` checked.

### Database buffer lifetime
9.11.1 **Do not retain `sql.RawBytes` across row advancement** - `sql.RawBytes` data MUST be copied before it is retained beyond the next row operation or closure of the rows.

### JSON schema validation
9.12.1 **Reject unknown JSON fields when the schema must be strict** - JSON decoding that requires a strict object schema MUST reject unknown fields, such as by using `Decoder.DisallowUnknownFields`.

### JSON framing
9.13.1 **Ensure a single JSON document has no trailing document** - When exactly one JSON document is expected, decoding MUST verify that no additional non-whitespace JSON value follows the first document.

### JSON numeric representation
9.14.1 **Avoid implicit `float64` JSON numbers when precision matters** - JSON numbers requiring integer or exact textual precision MUST be decoded into appropriate concrete numeric types or with `UseNumber` rather than through the default `any` to `float64` conversion.

### JSON failure semantics
9.15.1 **Treat a destination as partially modified after JSON failure** - When JSON decoding must update a destination atomically, code MUST decode into a temporary value and commit it only after successful decoding.

## API Design, Generics, and Iteration

### JSON destination reuse
10.1.1 **Clear reused maps before JSON decoding when stale keys are invalid** - A non-nil map reused as a JSON destination MUST be cleared or replaced before decoding when keys absent from the new input must not remain.

### JSON nullability
10.2.1 **Use pointer or nullable representations when JSON null must be distinguishable** - A JSON field MUST use a pointer or other nullable representation when missing, `null`, and the scalar zero value have distinct meanings.

### JSON field resolution
10.3.1 **Remember JSON struct field matching is case-insensitive** - JSON schemas consumed by `encoding/json` SHOULD NOT define semantically distinct fields that differ only by letter case.

### Interface API design
10.4.1 **Prefer consumer-defined interfaces and producer-returned concrete types** - Interfaces SHOULD be defined by the consuming package around the behavior it needs, and constructors SHOULD return concrete types unless an abstraction boundary specifically requires an interface.

### API compatibility
10.5.1 **Adding a method to a public interface is breaking** - A compatibility-preserving release MUST NOT add a required method to an exported interface that external code may implement; a new or secondary interface SHOULD be introduced instead.

### API evolution
10.6.1 **Function signatures are rigid compatibility surfaces** - A compatibility-preserving release MUST NOT change an exported function or method signature, including changes that preserve ordinary call syntax but alter its function type.

### Public value-type compatibility
10.7.1 **Do not accidentally destroy exported struct comparability** - A compatibility-preserving change MUST NOT make a previously comparable exported struct non-comparable when callers may rely on comparison or map-key use.

### API compatibility
10.8.1 **New configuration fields should preserve useful zero-value behavior** - New fields added to exported configuration structs SHOULD make their zero values preserve existing behavior unless a deliberate breaking change is intended.

### Method sets and interfaces
10.9.1 **Understand pointer versus value method sets** - Code MUST NOT assume `T` implements methods defined only on `*T`; interface assignments MUST use a value whose method set contains every required method.

### Interface API design
10.10.1 **Do not pass pointers to interfaces** - APIs SHOULD accept or return interface values directly rather than pointers to interfaces unless mutation of the interface variable itself is specifically required.

### Generics design
10.11.1 **Use an interface instead of a type parameter when only methods matter** - When an abstraction only needs to invoke methods and does not need to preserve or operate on concrete type identity, it SHOULD use an interface rather than a type parameter.

### Generic abstraction
10.12.1 **Do not introduce generics before repeated type-level need exists** - Generic abstractions SHOULD NOT be introduced unless the implementation materially benefits from operating over multiple types or preserving type relationships.

## Modules, Builds, and Test Tooling

### Generic comparability
11.1.1 **`comparable` does not guarantee panic-free equality for interface type arguments** - Generic code accepting interface types under a `comparable` constraint MUST NOT assume interface equality is panic-free and MUST avoid comparing dynamic values that may be non-comparable.

### Range-over-function iterators
11.2.1 **Iterator implementations must stop after `yield` returns false** - A range-over-function iterator MUST return and MUST NOT call `yield` again after `yield` returns false.

### Pull iterator lifecycle
11.3.1 **Call `stop` when abandoning `iter.Pull` early** - Code that abandons an `iter.Pull` iterator before natural exhaustion MUST call its returned `stop` function.

### Module graph semantics
11.4.1 **Do not rely on your module's `replace` directives propagating to consumers** - Published module behavior MUST NOT depend on `replace` or `exclude` directives that apply only in the developer's main module or workspace.

### Workspace reproducibility
11.5.1 **Test modules outside workspace influence when consumer behavior matters** - Modules intended for external consumption SHOULD be tested with workspace influence disabled, such as `GOWORK=off`, when verifying standalone consumer behavior.

### Dependency version selection
11.6.1 **Minimal Version Selection does not mean latest** - Dependency management MUST NOT assume Minimal Version Selection chooses the newest available release; upgrades and freshness checks SHOULD select versions explicitly.

### Language and runtime compatibility
11.7.1 **Treat the `go` directive as semantic configuration** - Changes to a module's `go` directive MUST be treated as semantic compatibility changes and SHOULD be accompanied by validation of language and runtime behavior affected by that version.

### Semantic import versioning
11.8.1 **Major versions v2+ belong in the module path** - Ordinary Go modules at major version v2 or higher MUST include the corresponding `/vN` suffix in the module and import path unless a documented semantic-import-versioning exception applies.

### Tool dependency management
11.9.1 **Use `tool` directives for project-pinned Go tools** - Projects targeting Go 1.24 or later SHOULD declare module-managed Go tool dependencies with `tool` directives rather than the legacy dummy-import `tools.go` pattern.

### Conditional compilation
11.10.1 **Remember build constraints can hide source files and dependencies** - Projects supporting multiple build tags, operating systems, or architectures SHOULD test every materially supported configuration rather than relying solely on the source set selected on the development machine.

### Module tidiness
11.11.1 **Do not hand-delete dependencies merely because the current platform does not import them** - Module requirements MUST NOT be removed solely because the current platform or build tags do not import them; dependency cleanup SHOULD be performed with `go mod tidy`.

### Dynamic race analysis
11.12.1 **A clean race-detector run is not proof of race freedom** - Concurrency-sensitive code SHOULD be exercised with the race detector, but a clean race-detector run MUST NOT be treated as proof that the program is race-free.

### Static analysis
11.13.1 **Run `go vet`, but do not treat silence as correctness proof** - Go code SHOULD be checked with `go vet`, but the absence of vet diagnostics MUST NOT be treated as proof of correctness.

### Fuzz testing
11.14.1 **Keep fuzz targets deterministic and isolated** - A fuzz target MUST produce behavior determined by its current input and MUST NOT depend on mutable state left by previous fuzz invocations.

### Test goroutine semantics
11.15.1 **Do not call `Fatal` from a helper goroutine** - `FailNow`, `Fatal`, `Fatalf`, `SkipNow`, and equivalent test-terminating methods MUST be called only from the goroutine running the test or benchmark.

### Test isolation
11.16.1 **Do not combine parallel tests with process-global environment or directory changes** - Tests that mutate process-global environment variables or the working directory MUST NOT run in parallel with tests that can observe the same process state.

### Concurrent test determinism
11.17.1 **Prefer `testing/synctest` to real sleeps for asynchronous timing tests** - Tests of asynchronous timing behavior SHOULD use `testing/synctest` or deterministic synchronization instead of real sleeps when the behavior can be expressed with those mechanisms.

### Benchmark correctness
11.18.1 **Prefer `B.Loop` for ordinary benchmarks on modern Go** - New ordinary benchmarks on Go versions supporting it SHOULD use `B.Loop` unless explicit lower-level control of the benchmark loop is required.

## Processes, Runtime, Networking, and Interoperability

### Process lifecycle
12.1.1 **Every successfully started subprocess must be waited for** - Every successful `exec.Cmd.Start` MUST be followed by `Wait`, unless an API that performs the wait internally is used instead.

### Subprocess pipes
12.2.1 **Consume command pipes before waiting** - Pipes obtained from `StdoutPipe` or `StderrPipe` MUST be consumed to completion before `Wait` closes them, and those pipe APIs MUST NOT be combined with `Run`.

### Executable lookup security
12.3.1 **Do not bypass `exec.ErrDot` casually** - Code MUST NOT bypass `exec.ErrDot` merely to restore implicit current-directory executable lookup; intended current-directory executables SHOULD be referenced explicitly.

### Cryptographic hashing
12.4.1 **Do not use MD5 or SHA-1 for cryptographic security** - MD5 and SHA-1 MUST NOT be used where cryptographic collision resistance or modern security properties are required.

### Side-channel resistance
12.5.1 **Use constant-time comparison for secret values when timing matters** - Secret values whose comparison timing could reveal information MUST be compared with an appropriate constant-time primitive.

### Reflection safety
12.6.1 **Guard reflection operations by validity and kind** - Reflection code MUST establish the required validity, kind, addressability, and settable properties before invoking operations that panic when those preconditions are not met.

### GC cleanup semantics
12.7.1 **Do not capture an `AddCleanup` target in its cleanup** - A cleanup registered for an object MUST NOT retain that object directly or indirectly through the cleanup closure or its arguments.

### Runtime scheduling
12.8.1 **Do not assume `GOMAXPROCS` equals host CPU count in containers** - Containerized code SHOULD NOT override `GOMAXPROCS` based solely on host CPU count and SHOULD account for the Go version's container-aware runtime behavior before overriding the default.

### Runtime memory control
12.9.1 **`GOMEMLIMIT` is not a process RSS limit** - Resource planning MUST NOT treat `GOMEMLIMIT` or `debug.SetMemoryLimit` as a hard cap on total process resident memory.

### Path portability
12.10.1 **Use `path`, not `filepath`, for slash-defined URL paths** - Slash-defined URL and protocol paths MUST use `path` or URL-specific APIs rather than `path/filepath`; `filepath` SHOULD be reserved for native filesystem paths.

### URL encoding
12.11.1 **Escape URL components according to their context** - URL components MUST be escaped with an API appropriate to their syntactic context, such as path-segment escaping for path data and query escaping for query values.

### Network address representation
12.12.1 **Prefer `net/netip` for value-like IP addresses in new APIs** - New APIs that need immutable, comparable, value-like IP addresses SHOULD use `netip.Addr` unless compatibility or another concrete requirement favors `net.IP`.

### Reproducibility and compatibility
12.13.1 **Do not assume standard-library output bytes remain implementation-stable** - Tests and protocols MUST NOT depend on exact standard-library output bytes unless the relevant API explicitly guarantees byte-for-byte stability.

### Mutable value copying
12.14.1 **Do not copy a nonzero `strings.Builder`** - A `strings.Builder` MUST NOT be copied after first use.

### Mutable value aliasing
12.15.1 **Avoid copying mutable structs with pointer receiver methods** - Mutable structs whose copies can share internal state, such as a nonzero `bytes.Buffer`, SHOULD NOT be copied after use unless the resulting aliasing is explicitly intended and safe.

### Error control flow
12.16.1 **Do not use panic for expected operational failures** - Expected operational failures such as invalid input, unavailable resources, or failed external operations MUST be returned as errors rather than represented with panic.

### Result API design
12.17.1 **Use out-of-band status instead of sentinel result values** - APIs SHOULD return an explicit status or error value rather than encode failure in an ordinary result value that can also be valid data.

### Network I/O semantics
12.18.1 **Process partial network writes before timeout errors** - When a network operation returns both `n > 0` and an error, code MUST account for the successfully transferred bytes before handling the error.

### cgo error handling
12.19.1 **Check primary C return values before `errno`** - cgo code MUST determine whether a C call failed from the call's documented primary return value before interpreting `errno`.

### cgo API boundaries
12.20.1 **Do not expose C types in public Go APIs** - Exported Go APIs SHOULD NOT expose cgo-generated C types and SHOULD translate boundary values into ordinary Go types.

### Atomic API design
12.21.1 **Prefer typed atomic wrappers over primitive operations where practical** - New code SHOULD prefer typed atomic wrappers such as `atomic.Int64`, `atomic.Bool`, or `atomic.Pointer[T]` over primitive atomic functions when they express the required operation.

### Concurrency API design
12.22.1 **Prefer synchronous APIs unless asynchronous behavior belongs in the abstraction** - APIs SHOULD perform work synchronously when callers can trivially add concurrency themselves, unless asynchronous execution is an inherent part of the abstraction.

### Extensible API configuration
12.23.1 **Functional options are not a universal rule** - APIs SHOULD choose functional options, configuration structs, or other configuration mechanisms according to their compatibility and usability requirements and SHOULD NOT adopt functional options solely as a universal style rule.

## Style, Testing, and Maintainability

### Mechanical source style
13.1.1 **Format Go code with `gofmt`** - Go source SHOULD be formatted with `gofmt` or a compatible formatter such as `goimports` rather than project-specific manual formatting.

### Error message style
13.2.1 **Keep error strings lowercase and composable** - Error strings SHOULD normally begin with lowercase text and SHOULD omit terminal punctuation unless grammar or a proper noun requires otherwise.

### Slice zero-value style
13.3.1 **Prefer the nil slice as the ordinary empty zero value** - Code SHOULD use a nil slice as the ordinary empty zero value unless a non-nil empty slice has distinct required semantics.

### Collection API semantics
13.4.1 **Do not design APIs that distinguish nil and empty slices without need** - APIs SHOULD treat nil and zero-length slices equivalently unless their distinction represents meaningful domain or serialization semantics.

### Package namespace clarity
13.5.1 **Avoid dot imports in normal code** - Production Go code SHOULD NOT use dot imports except where an exceptional package or test constraint provides a concrete justification.

### Package initialization
13.6.1 **Keep side-effect-only imports localized** - Blank imports used solely for package initialization side effects SHOULD be localized to entry points or tests that explicitly require those effects.

### Package naming
13.7.1 **Avoid unnecessary import renaming** - Imports SHOULD use their package's natural name unless an alias is required to resolve a collision or another concrete naming problem.

### Identifier naming
13.8.1 **Preserve conventional initialism capitalization** - Go identifiers SHOULD preserve conventional initialisms consistently, such as `ID`, `URL`, and `HTTP`.

### Parameter representation
13.9.1 **Avoid pointers merely to reduce value-copy size** - APIs SHOULD NOT use pointers to small immutable values merely to avoid copying unless pointer semantics, nilability, or measured performance requirements justify them.

### Allocation idioms
13.10.1 **Do not use `new` for slices and maps by habit** - Slices and maps SHOULD use their zero value or `make` rather than `new` unless a pointer to the container itself is specifically required.

### Source compatibility
13.11.1 **Avoid unkeyed literals for external struct types** - Struct literals for types defined in another package SHOULD use keyed fields rather than positional unkeyed values.

### Test robustness
13.12.1 **Prefer semantic error assertions in tests** - Tests SHOULD use `errors.Is`, `errors.As`, or equivalent semantic checks when error identity or type is the contract rather than asserting the entire error string.

### Test diagnostics
13.13.1 **Mark test helpers with `t.Helper`** - Reusable test functions that report failures on behalf of their callers SHOULD call `t.Helper()`.
13.13.2 **Prefer useful got/want test failures** - Comparison failures SHOULD report enough input, actual, and expected information to identify the failed comparison without requiring immediate reproduction.

### Test stability
13.14.1 **Avoid exact-byte tests for outputs whose representation is not contractual** - Tests SHOULD assert semantic output or documented properties rather than exact bytes when the output representation is not part of the API contract.

### Test comparison
13.15.1 **Prefer `cmp`-style semantic comparison over reflexive `reflect.DeepEqual` use in tests** - Tests SHOULD choose comparison semantics deliberately and SHOULD NOT use `reflect.DeepEqual` by default when its nil, aliasing, unexported-field, function, NaN, or cycle semantics do not match the intended equality.

### Value-type API style
13.16.1 **Do not copy `time.Time` through pointers without a semantic reason** - `time.Time` SHOULD be stored and passed by value unless pointer semantics are required for optionality, mutation, or another concrete API requirement.

### Stringer implementation
13.17.1 **Avoid recursive `String` formatting** - A `String` method MUST NOT format its receiver through a path that invokes the same `String` method recursively.

### Logging performance
13.18.1 **Avoid expensive log arguments when a `slog` record may be disabled** - Expensive values for potentially disabled `slog` records SHOULD be computed lazily or guarded by an enabled check rather than evaluated unconditionally.

### Filesystem traversal performance
13.19.1 **Prefer `WalkDir` over `Walk` when file metadata is unnecessary** - New filesystem traversal code SHOULD use `filepath.WalkDir` instead of `filepath.Walk` when `os.FileInfo` metadata is not required.

### Test style
13.20.1 **Avoid assertion mini-languages when ordinary Go comparisons are clearer** - Tests SHOULD prefer explicit Go comparisons and failure messages over assertion DSLs when the ordinary Go form is equally clear; assertion libraries MAY be used when they materially improve readability or diagnostics.

