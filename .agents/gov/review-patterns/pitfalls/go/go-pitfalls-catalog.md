# Go Pitfalls Catalog
_Entry format: <index> **<canonical name>** _(impact: [high|medium|low]; consensus: [high|medium|low])_ - <concise definition>._

## Concurrency, Context, and Synchronization

### Memory model and data races
1.1.1 **Synchronize all shared mutable state** _(impact: high; consensus: high)_ - Do not read and write shared memory concurrently without synchronization. Use channels, mutexes, atomics, or another documented happens-before relationship.

### Goroutine lifecycle
1.2.1 **Make every goroutine's lifetime explicit** _(impact: high; consensus: high)_ - Every goroutine should have a clear condition under which it exits. Avoid goroutines that can remain indefinitely blocked after their work is no longer needed.

### Synchronization semantics
1.3.1 **Goroutine termination is not synchronization** _(impact: high; consensus: high)_ - Do not start a goroutine, let it write shared state, and assume its eventual termination makes those writes visible. Synchronize completion explicitly.

### Concurrency cancellation
1.4.1 **Cancel pipelines when downstream stops early** _(impact: high; consensus: high)_ - Pipeline stages must stop sending when downstream consumers return early. Propagate cancellation rather than leaving upstream goroutines blocked on sends.

### Concurrency backpressure
1.5.1 **Bound concurrency instead of spawning without limit** _(impact: high; consensus: high)_ - Put an explicit limit on simultaneously active work when the input size can grow. Worker pools or `errgroup.SetLimit` are preferable to one unrestricted goroutine per item.

### Goroutine accounting
1.6.1 **Prefer `WaitGroup.Go` or perform `Add` before launching** _(impact: high; consensus: high)_ - On current Go, prefer `WaitGroup.Go` for ordinary goroutine accounting. When manually using `Add`, increment before starting the goroutine rather than from inside it.

### Context lifecycle
1.7.1 **Always call returned context cancellation functions** _(impact: high; consensus: high)_ - When `WithCancel`, `WithTimeout`, or `WithDeadline` returns a `CancelFunc`, arrange to call it, normally with `defer cancel()`.

### Context propagation
1.8.1 **Propagate request contexts end to end** _(impact: high; consensus: high)_ - Pass the incoming context through database, RPC, HTTP, and other request-scoped calls. Do not replace it with `context.Background()` in the middle of the call chain.

### Channel semantics
1.9.1 **Remember that nil channels block forever** _(impact: high; consensus: high)_ - Sending to or receiving from a nil channel blocks forever. Deliberately use nil channels only when disabling a `select` case is intended.

### Channel lifecycle
1.10.1 **Close channels only when no future send is possible** _(impact: high; consensus: high)_ - Coordinate channel closure with all producers. Sending on a closed channel panics, as does closing an already closed channel; closing a nil channel also panics.

### Panic containment
1.11.1 **Recovery cannot cross goroutine boundaries** _(impact: high; consensus: high)_ - A panic must be recovered by a deferred function running in the same goroutine. A parent or supervisor goroutine cannot recover another goroutine's panic.

### Loop variable semantics
1.12.1 **Treat loop capture rules as version and declaration sensitive** _(impact: high; consensus: high)_ - Go 1.22+ gives variables declared by a range clause with `:=` a new variable per iteration. Older language versions retain the old capture behavior, and current loops assigning into predeclared variables with `=` still reuse those variables.

### Map concurrency
1.13.1 **Synchronize concurrent map access** _(impact: high; consensus: high)_ - Do not concurrently modify an ordinary map while another goroutine reads or modifies it. Protect it with synchronization or use an appropriate specialized structure.

### Slice ownership
1.14.1 **Treat slices as shared views, not independent values** _(impact: high; consensus: high)_ - Copying a slice copies its descriptor, not its elements. Sub-slices commonly share the same backing array, and `append` can modify data visible through another slice when capacity permits.

### Slice mutation
1.15.1 **Always use the returned slice after length-changing operations** _(impact: high; consensus: high)_ - Assign the result of `append`, `slices.Delete`, `slices.Compact`, `slices.Insert`, `slices.Replace`, and similar functions back to the slice you intend to continue using.

### Synchronization object identity
1.16.1 **Do not copy synchronization objects after first use** _(impact: high; consensus: high)_ - `Mutex`, `RWMutex`, `WaitGroup`, `Once`, `Pool`, `Cond`, `sync.Map`, atomic wrapper types, and other documented no-copy synchronization objects must not be copied after use.

## Types, Values, and Error Semantics

### Interface representation
2.1.1 **A typed nil inside an interface is not a nil interface** _(impact: high; consensus: high)_ - An interface containing a typed nil pointer is non-nil because its dynamic type is present. Avoid returning typed nil pointers as `error` or other interfaces when you intend to return nil.

### Interface comparability
2.2.1 **Interface equality can panic** _(impact: high; consensus: high)_ - Do not assume every pair of interface values can safely be compared with `==`. Comparison panics when the dynamic value is not comparable, such as a slice or map.

### Error identity
2.3.1 **Use wrapper-aware error inspection** _(impact: high; consensus: high)_ - Use `errors.Is` for sentinel identity and `errors.AsType` in Go 1.26+ where appropriate for wrapped error types, rather than direct equality or one-level type assertions.

### Error API design
2.4.1 **Treat `%w` as an API commitment** _(impact: high; consensus: high)_ - Wrap an underlying error with `%w` only when callers should be able to depend on that error identity or type. Use `%v` when the underlying implementation detail should remain hidden.

### I/O error contracts
2.5.1 **Never wrap `io.EOF`** _(impact: high; consensus: high)_ - Readers that signal end of input should return `io.EOF` itself rather than a wrapped form.

### Error handling
2.6.1 **Do not silently discard meaningful errors** _(impact: high; consensus: high)_ - Handle, propagate, or deliberately document ignored errors rather than routinely assigning them to `_`.

### Reader semantics
2.7.1 **Process bytes before handling a simultaneous read error** _(impact: high; consensus: high)_ - An `io.Reader` may return both `n > 0` and a non-nil error. Process the `n` bytes before acting on the error.

### Memory and input limits
2.8.1 **Bound reads from untrusted or potentially large streams** _(impact: high; consensus: high)_ - Do not use `io.ReadAll` on an unbounded attacker-controlled or arbitrarily large source. Apply an appropriate limit or stream the content.

## HTTP and Database Operations

### HTTP connection lifecycle
3.1.1 **Close HTTP response bodies and consume when reuse matters** _(impact: high; consensus: high)_ - When `Client.Do` succeeds, close `resp.Body`. For HTTP/1.x connection reuse, also read the body to EOF when appropriate and safely bounded.

### Network lifecycle
3.2.1 **Put deadlines on outbound HTTP work** _(impact: high; consensus: high)_ - Use request contexts, `Client.Timeout`, or appropriately configured transport deadlines for calls that must not wait indefinitely.

### HTTP resource limits
3.3.1 **Configure exposed HTTP servers against slow clients and large bodies** _(impact: high; consensus: high)_ - Set server read/header/write/idle limits appropriate to the deployment and apply `http.MaxBytesReader` before accepting potentially large request bodies.

### Database security
3.4.1 **Parameterize SQL instead of formatting SQL text** _(impact: high; consensus: high)_ - Pass values as query parameters rather than using `fmt.Sprintf` or string concatenation to construct SQL containing data.

### Database result lifecycle
3.5.1 **Close SQL rows and check `Rows.Err`** _(impact: high; consensus: high)_ - Close `*sql.Rows`, normally with `defer`, and after the iteration loop check `rows.Err()`.

### Database transaction integrity
3.6.1 **Use `sql.Tx`, not raw transaction statements** _(impact: high; consensus: high)_ - Use `DB.BeginTx`/`Tx` methods and perform transaction operations through the `Tx`. Do not issue raw `BEGIN`/`COMMIT`, and do not mix `DB` calls into the transaction.

## Security and Trust Boundaries

### TLS authentication
4.1.1 **Do not disable TLS verification with `InsecureSkipVerify`** _(impact: high; consensus: high)_ - Leave certificate and hostname verification enabled unless you are implementing equivalent verification through the documented custom verification hooks.

### Cryptographic randomness
4.2.1 **Use `crypto/rand` for security-sensitive randomness** _(impact: high; consensus: high)_ - Generate keys, tokens, nonces, session identifiers, and other secrets with `crypto/rand`, not `math/rand` or `math/rand/v2`.

### Output escaping
4.3.1 **Use `html/template` for HTML output** _(impact: high; consensus: high)_ - Render untrusted data into HTML with `html/template`, not `text/template`, and do not convert untrusted strings to trusted `template.HTML`, `template.JS`, or related safe-content types.

### Filesystem traversal security
4.4.1 **Use `os.Root` for untrusted paths inside a trusted directory** _(impact: high; consensus: high)_ - When an external filename must remain below a fixed directory, prefer `os.Root` or `os.OpenInRoot` to validating a joined path and opening it later.

### Archive extraction security
4.5.1 **Treat archive entry paths and links as hostile** _(impact: high; consensus: high)_ - Do not assume a tar or zip reader makes extracted paths safe. Ensure every extraction remains inside its output root, ideally using `os.Root`.

### Reverse proxy security
4.6.1 **Use `ReverseProxy.Rewrite`, not `Director`, for security-sensitive proxies** _(impact: high; consensus: high)_ - `httputil.ReverseProxy.Director` is deprecated and explicitly documented as insecure. Use `Rewrite` and reconstruct trusted forwarding headers deliberately.

### Cookie isolation
4.7.1 **Configure a public suffix list for production cookie jars** _(impact: high; consensus: high)_ - Do not use a nil `cookiejar.Options.PublicSuffixList` for a multi-domain production client. Use an appropriate public suffix implementation.

### Module privacy
4.8.1 **Configure private module paths before fetching them** _(impact: high; consensus: high)_ - Configure `GOPRIVATE` and, where needed, `GONOPROXY` or `GONOSUMDB` for private module path patterns.

### Dependency integrity
4.9.1 **Preserve public module checksum verification** _(impact: high; consensus: high)_ - Do not globally disable the checksum database merely to make private modules work. Exempt only the required private path patterns.

### Unsafe memory lifetime
4.10.1 **Do not store Go pointers in `uintptr`** _(impact: high; consensus: high)_ - Treat `uintptr` as an integer, not a GC-visible pointer. Follow only the conversion patterns explicitly permitted by `unsafe`.

### Go and C memory interoperability
4.11.1 **Follow cgo pointer retention rules** _(impact: high; consensus: high)_ - C code must not retain ordinary Go pointers after a cgo call unless the referenced memory is pinned under the documented rules. Use `runtime.Pinner` or `runtime/cgo.Handle` where appropriate.

## Deterministic Cleanup and Termination

### Garbage collection and external resources
5.1.1 **Close deterministic resources explicitly** _(impact: high; consensus: high)_ - Do not rely on finalizers, `runtime.AddCleanup`, or weak references to close files, flush buffers, commit data, unlock resources, or perform other required cleanup.

### Process termination
5.2.1 **Remember that `os.Exit` and `log.Fatal` skip defers** _(impact: high; consensus: high)_ - Do not use `os.Exit` or `log.Fatal` from code that depends on deferred cleanup. Return an error to an outer level that can perform cleanup before exiting.

## Synchronization, Channels, and Time

### Synchronization algorithms
6.1.1 **Do not implement double-checked locking with ordinary loads** _(impact: medium; consensus: high)_ - Use `sync.Once`, `OnceValue`, or proper synchronization instead of checking a shared initialization flag before acquiring a lock.

### Synchronization visibility
6.2.1 **Do not busy-wait on an ordinary shared variable** _(impact: medium; consensus: high)_ - A loop that repeatedly reads an unsynchronized variable waiting for another goroutine to change it is not valid synchronization. Use a channel, mutex, condition, or atomic operation.

### One-time initialization
6.3.1 **Know `sync.Once` failure semantics** _(impact: medium; consensus: high)_ - Do not recursively call the same `Once.Do`, and remember that if the function panics, that `Once` is still considered finished.

### Read-write locking
6.4.1 **Do not upgrade or recursively acquire `RWMutex` read locks** _(impact: medium; consensus: high)_ - `RWMutex` cannot be upgraded from read to write or downgraded from write to read. Recursive read locking is unsafe when a writer may be pending.

### Temporary object reuse
6.5.1 **Do not use `sync.Pool` as durable storage** _(impact: medium; consensus: high)_ - Use `sync.Pool` only for temporary reusable objects whose disappearance is harmless.

### Concurrent collections
6.6.1 **Prefer an ordinary map plus locking unless `sync.Map` fits its specialized cases** _(impact: medium; consensus: high)_ - Do not treat `sync.Map` as the default concurrent-map replacement. Most code is clearer and maintains stronger invariants with a typed map protected by a mutex.

### Condition synchronization
6.7.1 **Wait on `sync.Cond` in a loop** _(impact: medium; consensus: high)_ - Recheck the condition after every `Cond.Wait`, normally with `for !condition { c.Wait() }`.

### Atomic synchronization
6.8.1 **Prefer higher-level synchronization to hand-written atomics** _(impact: medium; consensus: high)_ - Use channels, mutexes, or other `sync` facilities unless an atomic algorithm is genuinely needed.

### Atomic alignment
6.9.1 **Prefer typed 64-bit atomics on 32-bit targets** _(impact: medium; consensus: high)_ - Prefer `atomic.Int64` and `atomic.Uint64` over primitive 64-bit atomic functions when portability to 32-bit platforms matters.

### Atomic dynamic values
6.10.1 **Do not change the concrete type stored in `atomic.Value`** _(impact: medium; consensus: high)_ - After the first store, all values placed in an `atomic.Value` must have the same concrete type, and storing nil is invalid.

### Channel happens-before relationships
6.11.1 **Channel buffering changes synchronization semantics** _(impact: medium; consensus: high)_ - Do not assume buffered and unbuffered channels establish identical ordering. Design synchronization according to the memory model, not intuition about sends.

### Select semantics
6.12.1 **`select` does not implement case priority** _(impact: medium; consensus: high)_ - When multiple communication cases are ready, `select` chooses among them pseudo-randomly rather than selecting the first case.

### Nonblocking concurrency
6.13.1 **Avoid accidental busy loops with `select default`** _(impact: medium; consensus: high)_ - A `default` case makes `select` nonblocking. Do not put such a `select` in an unrestricted loop unless active polling is intentional and controlled.

### Channel receive semantics
6.14.1 **Use comma-ok when a closed channel's zero value is ambiguous** _(impact: medium; consensus: high)_ - Use `v, ok := <-ch` when the element type's zero value is meaningful and you need to distinguish it from closure.

### Timer lifecycle
6.15.1 **Stopping a ticker does not close its channel** _(impact: medium; consensus: high)_ - Do not expect `range ticker.C` to terminate merely because another goroutine calls `ticker.Stop()`. Provide a separate cancellation signal.

### Timer delivery semantics
6.16.1 **Tickers may drop ticks** _(impact: medium; consensus: high)_ - Do not use ticker receives as a guaranteed count of elapsed periods.

### Version-dependent timer behavior
6.17.1 **Stop repeating pre-Go-1.23 timer GC advice unconditionally** _(impact: medium; consensus: high)_ - For Go 1.23+ semantics, unreachable timers and tickers can be garbage collected even when unstopped. Stop them when you need to prevent future events, not merely because old advice said GC requires it.

### Timer channel semantics
6.18.1 **Do not inspect `len(timer.C)` to detect a ready timer** _(impact: medium; consensus: high)_ - Use a nonblocking `select` rather than testing timer-channel length.

### OS signal delivery
6.19.1 **Buffer `signal.Notify` channels appropriately** _(impact: medium; consensus: high)_ - Provide enough buffering for signals you cannot afford to miss and unregister notifications when they are no longer needed. For `NotifyContext`, call its returned stop function.

## Collections, Text, and Resource I/O

### Time units
7.1.1 **Multiply numeric durations by their unit** _(impact: medium; consensus: high)_ - Write `time.Duration(n) * time.Second` or another explicit unit instead of converting a unitless integer and assuming seconds or milliseconds.

### Time representation
7.2.1 **Compare instants with `Time.Equal`, not usually `==`** _(impact: medium; consensus: high)_ - Use `t.Equal(u)` for instant equality. Normalize deliberately before using `time.Time` as a map or database key.

### Calendar semantics
7.3.1 **Do not use `time.Date` as strict calendar validation** _(impact: medium; consensus: high)_ - Validate calendar fields separately when invalid input should be rejected. `time.Date` normalizes out-of-range components such as October 32, and DST gaps or repetitions are inherently ambiguous.

### Time parsing
7.4.1 **Use `ParseInLocation` for location-dependent local times** _(impact: medium; consensus: high)_ - When input without an offset is intended to represent time in a known location, use `time.ParseInLocation`. Prefer numeric offsets over ambiguous zone abbreviations in interchange formats.

### Map zero values
7.5.1 **Initialize maps before writing** _(impact: medium; consensus: high)_ - Reading a nil map is valid, but writing to one panics. Allocate it with `make` or a literal before the first write.

### Map lookup semantics
7.6.1 **Use comma-ok when a missing map key matters** _(impact: medium; consensus: high)_ - Use `v, ok := m[k]` whenever a stored zero value must be distinguished from a missing key.

### Map iteration
7.7.1 **Never depend on map iteration order** _(impact: medium; consensus: high)_ - Sort keys or otherwise establish an order when deterministic output or processing is required.

### Map mutation during iteration
7.8.1 **Do not rely on newly inserted map entries appearing during range** _(impact: medium; consensus: high)_ - If a map is modified during iteration, do not rely on new entries being visited. Deletions of not-yet-reached entries prevent those entries from being produced.

### Map value mutation
7.9.1 **Map elements are not addressable** _(impact: medium; consensus: high)_ - You cannot directly assign through a struct field of `m[k]`. Read, modify, and assign the entire value back, or store pointers when pointer semantics are actually desired.

### Collection copying
7.10.1 **`maps.Clone` is shallow** _(impact: medium; consensus: high)_ - `maps.Clone` creates an independent map structure but copies keys and values using assignment. Nested slices, maps, pointers, and other reference-bearing values remain shared.

### Range semantics
7.11.1 **Range values are copies** _(impact: medium; consensus: high)_ - When ranging over a slice or array, modifying the value variable does not modify the original element. Use the index when the element itself must change.

### Range and pointer semantics
7.12.1 **A pointer to a range value is not a pointer to the collection element** _(impact: medium; consensus: high)_ - Even with Go 1.22's per-iteration variables, `&v` where `v` is a range value points to that iteration variable, not to `slice[i]`.

### Slice capacity control
7.13.1 **Limit slice capacity when append should not mutate adjacent data** _(impact: medium; consensus: high)_ - When passing a sub-slice whose caller must not overwrite following elements by appending, copy it or restrict capacity with a full slice expression such as `s[:len(s):len(s)]` or `slices.Clip`.

### Memory retention
7.14.1 **Copy small retained sub-slices out of large buffers** _(impact: medium; consensus: high)_ - If a tiny slice must outlive a large backing array, copy the needed elements into a right-sized allocation.

### Collection copying
7.15.1 **`slices.Clone` is shallow** _(impact: medium; consensus: high)_ - `slices.Clone` separates the outer backing array but copies elements by assignment. Elements containing pointers, maps, slices, or other references still alias their original targets.

### Strings and Unicode
7.16.1 **Distinguish bytes, runes, and user-perceived characters** _(impact: medium; consensus: high)_ - `len(s)` and `s[i]` operate on bytes; range decodes UTF-8 runes and reports byte indexes. A rune still need not correspond to one grapheme visible to a user.

### String API semantics
7.17.1 **`strings.Trim` takes a cutset, not a substring** _(impact: medium; consensus: high)_ - Use `TrimPrefix` or `TrimSuffix` when removing an exact prefix or suffix. `Trim` removes any leading and trailing rune contained in its cutset argument.

### Buffer lifetime
7.18.1 **Copy borrowed buffers before retaining them** _(impact: medium; consensus: high)_ - Data returned by APIs such as `Scanner.Bytes`, `bufio.Reader.Peek`, `ReadSlice`, or `bytes.Buffer.Bytes` may alias internal mutable storage. Copy it if it must survive subsequent reads or mutations.

### Buffered input limits
7.19.1 **Do not assume `bufio.Scanner` handles arbitrarily large tokens** _(impact: medium; consensus: high)_ - Check `Scanner.Err`, and configure `Scanner.Buffer` or use a `bufio.Reader` when tokens can exceed Scanner's configured maximum.

### Buffered output lifecycle
7.20.1 **Flush buffered writers and handle the flush error** _(impact: medium; consensus: high)_ - Explicitly flush `bufio.Writer` and similar buffered encoders before the underlying destination is considered successfully written.

### Durable output
7.21.1 **Check final close errors when they can report write failure** _(impact: medium; consensus: high)_ - For output resources whose `Close` finalizes or flushes content, do not automatically discard the close error when no earlier error occurred.

### Deferred cleanup scope
7.22.1 **Avoid resource-owning defers in large loops** _(impact: medium; consensus: high)_ - A `defer` runs when the surrounding function returns, not when a loop iteration ends. Put an iteration in a helper function or close explicitly when resources need to be released each iteration.

### File opening semantics
7.23.1 **Remember that `os.Create` truncates** _(impact: medium; consensus: high)_ - Do not use `os.Create` when existing contents must be preserved. Select `os.OpenFile` flags that express the desired append, create, exclusive, or truncate behavior.

## Language Semantics and Context APIs

### Temporary resource lifecycle
8.1.1 **Remove temporary files you create** _(impact: medium; consensus: high)_ - `os.CreateTemp` and `os.MkdirTemp` create resources but do not automatically remove them when the process no longer needs them.

### Hash API semantics
8.2.1 **`Hash.Sum` appends rather than hashes its argument** _(impact: medium; consensus: high)_ - After writing input into a `hash.Hash`, use `h.Sum(nil)` or append the digest intentionally. Do not pass source data to `Sum` expecting it to be hashed.

### Regular-expression error handling
8.3.1 **Use `regexp.Compile` for runtime patterns** _(impact: medium; consensus: high)_ - Reserve `regexp.MustCompile` for patterns that are effectively program constants and should make initialization fail if invalid. Use `Compile` for user or runtime input.

### Regular-expression substitution
8.4.1 **Use literal regexp replacement when `$` has no special meaning** _(impact: medium; consensus: high)_ - Use `ReplaceAllLiteralString` when the replacement text is literal. `ReplaceAllString` interprets `$name` and `$1` forms as capture expansion.

### Type assertions
8.5.1 **Use comma-ok for uncertain type assertions** _(impact: medium; consensus: high)_ - Use `v, ok := x.(T)` when failure is a normal possibility. Reserve one-result assertions for invariants whose violation genuinely warrants a panic.

### Numeric conversions
8.6.1 **Validate narrowing numeric conversions** _(impact: medium; consensus: high)_ - Check ranges before converting untrusted or unconstrained numeric values to narrower integer types or between signed and unsigned representations.

### Integer portability
8.7.1 **Do not use `int` as an external fixed-width representation** _(impact: medium; consensus: high)_ - Use fixed-width integer types when a value's binary width is part of a file format, protocol, hash, or persistent representation.

### Array semantics
8.8.1 **Remember arrays copy by value** _(impact: medium; consensus: high)_ - Passing or assigning an array copies the entire array. Prefer slices for ordinary sequence APIs unless value-array semantics are specifically wanted.

### Conversion panics
8.9.1 **Slice-to-array conversions have length preconditions** _(impact: medium; consensus: high)_ - Check slice length before converting a slice to an array or pointer-to-array type unless sufficient length is already guaranteed.

### Defer semantics
8.10.1 **Deferred-call arguments are evaluated immediately** _(impact: medium; consensus: high)_ - If a deferred action should observe a later variable value, capture it deliberately in a closure rather than passing the value as a normal argument to `defer`.

### Return semantics
8.11.1 **Deferred functions can modify named return values** _(impact: medium; consensus: high)_ - Be cautious when combining named result variables with defers. A deferred closure can read or change those result values after the return statement has set them.

### Variable scope
8.12.1 **Watch short declarations for accidental shadowing** _(impact: medium; consensus: high)_ - Be especially careful with `:=` inside nested blocks when names such as `err` already exist. Use assignment when the outer variable is intended.

## HTTP, SQL, and JSON Contracts

### Context API design
9.1.1 **Do not store contexts in structs by default** _(impact: medium; consensus: high)_ - Pass `context.Context` as the first parameter to operations that need it instead of putting it into a long-lived struct.

### Context API contract
9.2.1 **Never pass a nil context** _(impact: medium; consensus: high)_ - Pass `context.TODO()` when no proper context has yet been chosen rather than passing nil.

### Context metadata
9.3.1 **Keep context values request-scoped and collision-resistant** _(impact: medium; consensus: high)_ - Use context values only for request-scoped data crossing API boundaries, not as an optional-parameter bag. Define private comparable key types rather than raw strings.

### HTTP response semantics
9.4.1 **HTTP non-2xx responses are not `Do` errors** _(impact: medium; consensus: high)_ - Inspect `resp.StatusCode`; do not interpret `err == nil` as application-level success.

### HTTP connection pooling
9.5.1 **Reuse HTTP clients and transports** _(impact: medium; consensus: high)_ - Keep reusable `http.Client` and `Transport` instances rather than constructing a fresh transport for every request.

### HTTP timeout semantics
9.6.1 **`Client.Timeout` covers body reading too** _(impact: medium; consensus: high)_ - Set `Client.Timeout` with awareness that it spans connection setup, redirects, and reading the response body, not merely waiting for headers.

### HTTP handler lifetime
9.7.1 **Do not use `ResponseWriter` after the handler returns** _(impact: medium; consensus: high)_ - Complete response-writing operations before `ServeHTTP` returns unless using an API with an explicit alternative lifecycle.

### Socket deadlines
9.8.1 **Network deadlines persist until changed** _(impact: medium; consensus: high)_ - `Conn.SetDeadline` sets an absolute deadline applying to future and pending I/O until replaced. Refresh it after successful operations when implementing an idle timeout.

### Database connection management
9.9.1 **Treat `sql.DB` as a long-lived connection pool** _(impact: medium; consensus: high)_ - Open a `*sql.DB` for reuse rather than opening and closing one per request. Configure pool limits when resource constraints require them.

### Database error timing
9.10.1 **`QueryRow` defers its error until `Scan`** _(impact: medium; consensus: high)_ - Always check the error returned by `QueryRow(...).Scan(...)`; do not expect `QueryRow` itself to report query errors.

### Database buffer lifetime
9.11.1 **Do not retain `sql.RawBytes` across row advancement** _(impact: medium; consensus: high)_ - Copy `RawBytes` if data must survive the next `Rows.Next`, `Scan`, or close operation.

### JSON schema validation
9.12.1 **Reject unknown JSON fields when the schema must be strict** _(impact: medium; consensus: high)_ - Use `Decoder.DisallowUnknownFields` when unexpected object fields should cause failure rather than being silently ignored.

### JSON framing
9.13.1 **Ensure a single JSON document has no trailing document** _(impact: medium; consensus: high)_ - When using `Decoder.Decode` for a single payload, verify that the next decode reaches EOF, or use `json.Unmarshal` on bounded input.

### JSON numeric representation
9.14.1 **Avoid implicit `float64` JSON numbers when precision matters** _(impact: medium; consensus: high)_ - Decode into concrete numeric fields or use `Decoder.UseNumber` when arbitrary JSON numbers must retain their textual or integer precision.

### JSON failure semantics
9.15.1 **Treat a destination as partially modified after JSON failure** _(impact: medium; consensus: high)_ - Do not assume an `Unmarshal` error means the destination was left untouched. Prefer decoding into a temporary value when atomic update semantics are needed.

## API Design, Generics, and Iteration

### JSON destination reuse
10.1.1 **Clear reused maps before JSON decoding when stale keys are invalid** _(impact: medium; consensus: high)_ - Decode into a new map, or clear an existing map first, when keys omitted by the new JSON document should disappear.

### JSON nullability
10.2.1 **Use pointer or nullable representations when JSON null must be distinguishable** _(impact: medium; consensus: high)_ - Do not decode into an ordinary scalar when `null`, missing, and the scalar zero value have different meanings.

### JSON field resolution
10.3.1 **Remember JSON struct field matching is case-insensitive** _(impact: medium; consensus: high)_ - Avoid designing externally exposed schemas whose fields differ only by case, and do not assume Go's decoder requires exact-case matching.

### Interface API design
10.4.1 **Prefer consumer-defined interfaces and producer-returned concrete types** _(impact: medium; consensus: high)_ - Define small interfaces where behavior is consumed, and generally let constructors return concrete implementation types rather than speculative producer-side interfaces.

### API compatibility
10.5.1 **Adding a method to a public interface is breaking** _(impact: medium; consensus: high)_ - Add a new interface or feature-detect a secondary interface rather than casually adding a method to an exported interface implemented by users.

### API evolution
10.6.1 **Function signatures are rigid compatibility surfaces** _(impact: medium; consensus: high)_ - Prefer adding another function or method over changing an existing exported function signature, even when a change such as adding a variadic parameter appears source-compatible at call sites.

### Public value-type compatibility
10.7.1 **Do not accidentally destroy exported struct comparability** _(impact: medium; consensus: high)_ - Before adding a slice, map, function, or other non-comparable field to an exported value struct, consider whether callers may compare the struct or use it as a map key.

### API compatibility
10.8.1 **New configuration fields should preserve useful zero-value behavior** _(impact: medium; consensus: high)_ - When extending an exported configuration struct, design new fields so their zero values normally preserve prior behavior unless a deliberate breaking change is being made.

### Method sets and interfaces
10.9.1 **Understand pointer versus value method sets** _(impact: medium; consensus: high)_ - A method defined only on `*T` does not make `T` satisfy an interface requiring that method, although `*T` also has methods defined on `T`.

### Interface API design
10.10.1 **Do not pass pointers to interfaces** _(impact: medium; consensus: high)_ - Accept or return the interface value itself rather than `*SomeInterface` except for rare cases where the interface variable itself must be mutated.

### Generics design
10.11.1 **Use an interface instead of a type parameter when only methods matter** _(impact: medium; consensus: high)_ - If generic code only invokes methods defined by the constraint and gains nothing from retaining the concrete type, a normal interface parameter is usually simpler.

### Generic abstraction
10.12.1 **Do not introduce generics before repeated type-level need exists** _(impact: medium; consensus: medium)_ - Prefer ordinary functions or interfaces until the same algorithm genuinely needs to operate over multiple types or type-preserving containers.

## Modules, Builds, and Test Tooling

### Generic comparability
11.1.1 **`comparable` does not guarantee panic-free equality for interface type arguments** _(impact: medium; consensus: high)_ - Since Go 1.20, interface types such as `any` may satisfy `comparable`; equality can still panic when the dynamic value placed in that interface is itself non-comparable.

### Range-over-function iterators
11.2.1 **Iterator implementations must stop after `yield` returns false** _(impact: medium; consensus: high)_ - A push iterator must return when its `yield` callback returns false rather than continuing to call it.

### Pull iterator lifecycle
11.3.1 **Call `stop` when abandoning `iter.Pull` early** _(impact: medium; consensus: high)_ - When a pull iterator has not naturally reached its end, arrange `defer stop()` or otherwise call `stop` before abandoning it.

### Module graph semantics
11.4.1 **Do not rely on your module's `replace` directives propagating to consumers** _(impact: medium; consensus: high)_ - Test published modules without depending on replacements defined only by the developing main module or workspace.

### Workspace reproducibility
11.5.1 **Test modules outside workspace influence when consumer behavior matters** _(impact: medium; consensus: high)_ - Use `GOWORK=off` when verifying that an individual module works using only its own `go.mod`, especially before publishing.

### Dependency version selection
11.6.1 **Minimal Version Selection does not mean latest** _(impact: medium; consensus: high)_ - Do not assume a build automatically selects the newest released dependency. Inspect and upgrade dependencies deliberately.

### Language and runtime compatibility
11.7.1 **Treat the `go` directive as semantic configuration** _(impact: medium; consensus: high)_ - Update the module's `go` version deliberately rather than treating it as cosmetic metadata.

### Semantic import versioning
11.8.1 **Major versions v2+ belong in the module path** _(impact: medium; consensus: high)_ - A module reaching v2 or higher must normally include `/v2`, `/v3`, and so on in its module and import paths.

### Tool dependency management
11.9.1 **Use `tool` directives for project-pinned Go tools** _(impact: medium; consensus: high)_ - On Go 1.24+, declare project tools with `tool` and manage them through the module rather than relying on the old dummy-import `tools.go` workaround.

### Conditional compilation
11.10.1 **Remember build constraints can hide source files and dependencies** _(impact: medium; consensus: high)_ - Test relevant GOOS, GOARCH, and build-tag combinations rather than assuming the source set used on one development machine represents every build.

### Module tidiness
11.11.1 **Do not hand-delete dependencies merely because the current platform does not import them** _(impact: medium; consensus: high)_ - Let `go mod tidy` determine module requirements across supported build configurations.

### Dynamic race analysis
11.12.1 **A clean race-detector run is not proof of race freedom** _(impact: medium; consensus: high)_ - Run `go test -race` and realistic race-enabled workloads, but continue reasoning about synchronization even when no race is reported.

### Static analysis
11.13.1 **Run `go vet`, but do not treat silence as correctness proof** _(impact: medium; consensus: high)_ - Include vet in normal validation while understanding that its checks are deliberately heuristic and incomplete.

### Fuzz testing
11.14.1 **Keep fuzz targets deterministic and isolated** _(impact: medium; consensus: high)_ - Fuzz functions should execute quickly and deterministically for a given input and should not depend on state left by previous invocations.

### Test goroutine semantics
11.15.1 **Do not call `Fatal` from a helper goroutine** _(impact: medium; consensus: high)_ - `T.FailNow`, `T.Fatal`, `T.Fatalf`, `SkipNow`, and related termination methods must run in the goroutine executing the test, not an arbitrary spawned goroutine.

### Test isolation
11.16.1 **Do not combine parallel tests with process-global environment or directory changes** _(impact: medium; consensus: high)_ - Tests using `T.Setenv` or `T.Chdir` cannot safely run in parallel with tests sharing the process state.

### Concurrent test determinism
11.17.1 **Prefer `testing/synctest` to real sleeps for asynchronous timing tests** _(impact: medium; consensus: high)_ - Where applicable, use `testing/synctest` rather than long `time.Sleep` calls to coordinate concurrent behavior in tests.

### Benchmark correctness
11.18.1 **Prefer `B.Loop` for ordinary benchmarks on modern Go** _(impact: medium; consensus: high)_ - For new benchmarks, use `for b.Loop() { ... }` unless lower-level benchmark control is required.

## Processes, Runtime, Networking, and Interoperability

### Process lifecycle
12.1.1 **Every successfully started subprocess must be waited for** _(impact: medium; consensus: high)_ - After a successful `cmd.Start`, call `cmd.Wait`. Prefer `Run` when no asynchronous interaction is needed.

### Subprocess pipes
12.2.1 **Consume command pipes before waiting** _(impact: medium; consensus: high)_ - With `StdoutPipe` or `StderrPipe`, read the pipe to completion before calling `Wait`; do not call `Run` while separately trying to consume those pipe APIs.

### Executable lookup security
12.3.1 **Do not bypass `exec.ErrDot` casually** _(impact: medium; consensus: high)_ - When execution from the current directory is intentional, name it explicitly with `./program` rather than weakening the protection against implicit current-directory lookup.

### Cryptographic hashing
12.4.1 **Do not use MD5 or SHA-1 for cryptographic security** _(impact: medium; consensus: high)_ - Reserve MD5 and SHA-1 for non-security compatibility uses where collision resistance is irrelevant. Use modern cryptographic hashes for security properties.

### Side-channel resistance
12.5.1 **Use constant-time comparison for secret values when timing matters** _(impact: medium; consensus: high)_ - Use appropriate `crypto/subtle` operations for authentication tags and other secret comparisons whose timing could expose information.

### Reflection safety
12.6.1 **Guard reflection operations by validity and kind** _(impact: medium; consensus: high)_ - Before calling kind-specific `reflect.Value` methods, establish that the value is valid and has the required kind and mutability properties.

### GC cleanup semantics
12.7.1 **Do not capture an `AddCleanup` target in its cleanup** _(impact: medium; consensus: high)_ - A cleanup function must not retain the object it is attached to, directly through a closure or indirectly through its cleanup argument.

### Runtime scheduling
12.8.1 **Do not assume `GOMAXPROCS` equals host CPU count in containers** _(impact: medium; consensus: high)_ - On current Go, understand the container-aware default rather than hard-coding host CPU assumptions or overriding it reflexively. Also account for the module's Go version when relying on newer default behavior.

### Runtime memory control
12.9.1 **`GOMEMLIMIT` is not a process RSS limit** _(impact: medium; consensus: high)_ - Treat `GOMEMLIMIT` or `debug.SetMemoryLimit` as a soft runtime-managed memory target, not a hard cap on total process memory.

### Path portability
12.10.1 **Use `path`, not `filepath`, for slash-defined URL paths** _(impact: medium; consensus: high)_ - Use `path/filepath` for native filesystem paths and `path` or URL APIs for slash-separated URL paths.

### URL encoding
12.11.1 **Escape URL components according to their context** _(impact: medium; consensus: high)_ - Use path-segment escaping for path components and query escaping for query values rather than applying one generic escaping rule everywhere.

### Network address representation
12.12.1 **Prefer `net/netip` for value-like IP addresses in new APIs** _(impact: medium; consensus: medium)_ - When compatibility constraints do not require `net.IP`, consider `netip.Addr` for application-level IP storage and comparison.

### Reproducibility and compatibility
12.13.1 **Do not assume standard-library output bytes remain implementation-stable** _(impact: medium; consensus: high)_ - Tests and protocols should depend on documented semantic output, not exact bytes from compressors, unstable sorts, or other implementations unless byte stability is explicitly promised.

### Mutable value copying
12.14.1 **Do not copy a nonzero `strings.Builder`** _(impact: medium; consensus: high)_ - Pass a `strings.Builder` by pointer or keep it local rather than copying it after it has been used.

### Mutable value aliasing
12.15.1 **Avoid copying mutable structs with pointer receiver methods** _(impact: medium; consensus: high)_ - Do not casually copy types such as `bytes.Buffer` whose internal slices or other state can alias after copying.

### Error control flow
12.16.1 **Do not use panic for expected operational failures** _(impact: medium; consensus: high)_ - Return errors for ordinary invalid input, unavailable resources, failed network calls, and other expected failure paths. Reserve panic for violated invariants or exceptional internal conditions.

### Result API design
12.17.1 **Use out-of-band status instead of sentinel result values** _(impact: medium; consensus: high)_ - Prefer `(value, ok)` or `(value, error)` over values such as `-1`, `""`, or nil when those values can also be legitimate results.

### Network I/O semantics
12.18.1 **Process partial network writes before timeout errors** _(impact: medium; consensus: high)_ - When an I/O method returns both `n > 0` and an error, account for the successfully transferred portion before handling the error.

### cgo error handling
12.19.1 **Check primary C return values before `errno`** _(impact: medium; consensus: high)_ - When using cgo's two-result form that captures `errno`, determine whether the C call failed according to its documented return value before interpreting `errno`.

### cgo API boundaries
12.20.1 **Do not expose C types in public Go APIs** _(impact: medium; consensus: high)_ - Translate C values into ordinary Go types before exposing them across package boundaries.

### Atomic API design
12.21.1 **Prefer typed atomic wrappers over primitive operations where practical** _(impact: medium; consensus: medium)_ - `atomic.Bool`, `Int64`, `Pointer[T]`, and related wrappers often make atomic intent and alignment clearer than free functions on raw addresses.

### Concurrency API design
12.22.1 **Prefer synchronous APIs unless asynchronous behavior belongs in the abstraction** _(impact: medium; consensus: medium)_ - Prefer functions that finish their work before returning when callers can trivially add concurrency themselves.

### Extensible API configuration
12.23.1 **Functional options are not a universal rule** _(impact: medium; consensus: medium)_ - Choose configuration structs, functional options, or another pattern according to the API's compatibility and usability needs rather than treating functional options as mandatory Go style.

## Style, Testing, and Maintainability

### Mechanical source style
13.1.1 **Format Go code with `gofmt`** _(impact: low; consensus: high)_ - Use `gofmt`, or `goimports` when import management is also desired, instead of maintaining a project-specific formatting style.

### Error message style
13.2.1 **Keep error strings lowercase and composable** _(impact: low; consensus: high)_ - Normally start error strings with lowercase text and omit terminal punctuation unless a proper noun or other grammatical requirement dictates otherwise.

### Slice zero-value style
13.3.1 **Prefer the nil slice as the ordinary empty zero value** _(impact: low; consensus: high)_ - Prefer `var s []T` over `s := []T{}` when there is no semantic need for a non-nil empty slice. Preserve the distinction only where protocols such as JSON require it.

### Collection API semantics
13.4.1 **Do not design APIs that distinguish nil and empty slices without need** _(impact: low; consensus: high)_ - Treat nil and zero-length slices equivalently unless the distinction represents real domain information.

### Package namespace clarity
13.5.1 **Avoid dot imports in normal code** _(impact: low; consensus: high)_ - Import packages normally and qualify their exported names. Reserve dot imports for exceptional test dependency situations where package cycles make them useful.

### Package initialization
13.6.1 **Keep side-effect-only imports localized** _(impact: low; consensus: high)_ - Blank imports used solely for initialization side effects should generally live in `main` packages or tests that explicitly require them.

### Package naming
13.7.1 **Avoid unnecessary import renaming** _(impact: low; consensus: high)_ - Use a package's natural name unless a collision or similar concrete reason requires an alias.

### Identifier naming
13.8.1 **Preserve conventional initialism capitalization** _(impact: low; consensus: high)_ - Write conventional initialisms consistently, such as `URL`, `HTTP`, and `ID`, rather than forms such as `Url`, `Http`, and `Id`.

### Parameter representation
13.9.1 **Avoid pointers merely to reduce value-copy size** _(impact: low; consensus: high)_ - Pass small immutable values such as strings and interface values directly unless pointer semantics are actually required.

### Allocation idioms
13.10.1 **Do not use `new` for slices and maps by habit** _(impact: low; consensus: high)_ - Use a zero slice or `make` for slices and maps rather than creating pointers such as `new([]T)` or `new(map[K]V)` without a specific pointer requirement.

### Source compatibility
13.11.1 **Avoid unkeyed literals for external struct types** _(impact: low; consensus: high)_ - Initialize structs from other packages with field names rather than positional literals.

### Test robustness
13.12.1 **Prefer semantic error assertions in tests** _(impact: low; consensus: high)_ - When the error's identity or type is the contract, test with `errors.Is` or `errors.As` rather than comparing the entire error string.

### Test diagnostics
13.13.1 **Mark test helpers with `t.Helper`** _(impact: low; consensus: high)_ - Call `t.Helper()` in reusable functions that report test failures on behalf of their caller.
13.13.2 **Prefer useful got/want test failures** _(impact: low; consensus: high)_ - Report the input, actual value, and expected value when a comparison fails.

### Test stability
13.14.1 **Avoid exact-byte tests for outputs whose representation is not contractual** _(impact: low; consensus: high)_ - Compare decoded meaning or promised properties instead of exact serialized bytes when the encoding API does not promise canonical output.

### Test comparison
13.15.1 **Prefer `cmp`-style semantic comparison over reflexive `reflect.DeepEqual` use in tests** _(impact: low; consensus: medium)_ - Choose comparison behavior deliberately rather than using `reflect.DeepEqual` for every structured test value.

### Value-type API style
13.16.1 **Do not copy `time.Time` through pointers without a semantic reason** _(impact: low; consensus: high)_ - Store and pass ordinary `time.Time` values directly rather than using `*time.Time` merely because the type is a struct. Use a pointer only when optionality or mutation semantics require one.

### Stringer implementation
13.17.1 **Avoid recursive `String` formatting** _(impact: low; consensus: high)_ - Inside a `String` method, do not format the receiver in a way that invokes the same `String` method again. Convert to a representation that does not implement the method when needed.

### Logging performance
13.18.1 **Avoid expensive log arguments when a `slog` record may be disabled** _(impact: low; consensus: high)_ - Delay expensive computation or use lazy `LogValuer` behavior when constructing structured logging values that may be filtered out.

### Filesystem traversal performance
13.19.1 **Prefer `WalkDir` over `Walk` when file metadata is unnecessary** _(impact: low; consensus: high)_ - For new recursive filesystem traversal, use `filepath.WalkDir` when its `DirEntry` API provides everything needed.

### Test style
13.20.1 **Avoid assertion mini-languages when ordinary Go comparisons are clearer** _(impact: low; consensus: low)_ - Go-maintained testing guidance generally favors explicit comparisons and useful failure messages over large assertion DSLs, although third-party assertion libraries remain widely used and many teams reasonably prefer them.
