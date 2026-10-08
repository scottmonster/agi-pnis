# JavaScript Pitfalls Rules

## 1. Language foundations and control flow

### Execution semantics

1.1.1 **Use strict mode or ES modules instead of sloppy mode** - Execute JavaScript under strict semantics through ES modules or `"use strict"` unless intentional sloppy behavior is a compatibility requirement.

### Binding and scope

1.2.1 **Never rely on assignment to undeclared variables** - Assign only to declared bindings or explicit object properties.
1.2.2 **Prefer block-scoped bindings over var for local state** - Use `const` by default and `let` for reassignment; reserve `var` for intentional function scope.

### Equality semantics

1.3.1 **Prefer strict equality when coercion is not intentional** - Use strict equality unless coercive equality is explicitly intended.

### Coercion and defaults

1.4.1 **Use nullish coalescing for nullish defaults** - Use `??` when zero, false, and empty strings must remain valid inputs.

### Numeric coercion

1.5.1 **Prefer Number.isNaN over global isNaN** - Test actual `NaN` values with `Number.isNaN()`.
1.5.2 **Prefer Number.isFinite over global isFinite** - Test actual finite number values with `Number.isFinite()`.

### Primitive wrappers

1.6.1 **Do not construct Boolean wrapper objects** - Use Boolean primitives rather than `new Boolean()`.

### Type inspection

1.7.1 **Remember that typeof null is "object"** - Exclude null whenever an object type check must reject it.

### Temporal dead zone

1.8.1 **typeof is not universally safe before declaration** - Do not use `typeof` to probe a lexical binding that could be in its temporal dead zone.

### Default-value semantics

1.9.1 **Default parameters and destructuring defaults do not replace null** - Handle null explicitly when defaults must cover both null and undefined.

### Binding semantics

1.10.1 **const does not make objects immutable** - Control object mutation separately from binding reassignment.

### Function invocation

1.11.1 **Remember that this is determined by invocation** - Call receiver-dependent functions with the intended receiver.
1.11.2 **Use arrow functions only when lexical this is desired** - Use arrows only where lexical `this` and their other semantic limits match the API.
1.11.3 **Bind or wrap methods when passing them as callbacks** - Bind or wrap receiver-dependent methods before passing them as callbacks.

### Control flow

1.12.1 **Do not return, throw, break, or continue from finally** - Do not override a pending completion in `finally` unless replacement is explicitly intended.
1.12.2 **Avoid accidental switch fallthrough** - End switch cases explicitly unless a marked fallthrough is required.
1.12.3 **Avoid accidental assignment in conditions** - Avoid condition assignments unless clearly intentional.

### Automatic semicolon insertion

1.13.1 **Keep return and throw values on the same line** - Begin return and throw expressions on the same line as their keyword.
1.13.2 **Choose an ASI-safe semicolon policy** - Follow a statement-boundary convention that prevents ASI continuation hazards.

### Operator semantics

1.14.1 **Do not mix ?? with && or || without explicit grouping** - Parenthesize mixed nullish and logical operators.

### Optional chaining

1.15.1 **Optional chaining only short-circuits a continuous chain** - Do not group away optional-chain protection before a required access.
1.15.2 **Optional call does not prove a property is callable** - Check or guarantee callability when an optional property can be non-function.

### Arrow-function syntax

1.16.1 **Parenthesize object literals returned implicitly from arrow functions** - Parenthesize implicit object-literal returns.

## 2. Objects, classes, and keyed collections

### Class field semantics

2.1.1 **Class fields do not behave exactly like constructor assignments** - Verify inherited accessor behavior before changing constructor assignments to fields.

### Class initialization

2.2.1 **Call super before using this in derived constructors** - Call `super()` before using `this` in a derived constructor.
2.2.2 **Class static initialization order is observable** - Do not read later static fields as initialized.

### Class encapsulation

2.3.1 **Private fields are lexically private, not conventionally protected** - Do not access superclass private fields from subclass code.

### Accessors

2.4.1 **Make getters return a value on every intended path** - Return the intended value on each reachable getter path.

### Constructor semantics

2.5.1 **Avoid explicit constructor return values** - Avoid constructor returns unless intentional object replacement is required.

### Object security

2.6.1 **Defend dynamic property writes against prototype pollution** - Validate untrusted dynamic keys and paths against prototype mutation.

### Property ownership

2.7.1 **Use Object.hasOwn for own-property tests** - Use `Object.hasOwn()` for own-property checks.

### Property-key semantics

2.8.1 **Plain-object keys are strings or symbols** - Use Map for arbitrary object-identity keys.

### Property enumeration

2.9.1 **Know what Object.keys omits** - Choose enumeration APIs according to the properties required.

### Property descriptors

2.10.1 **Object.defineProperty descriptor defaults are false** - Specify descriptor flags deliberately.
2.10.2 **Preserve descriptors explicitly when cloning accessor definitions** - Copy descriptors when accessor or flag definitions must survive cloning.

### Prototype semantics

2.11.1 **Avoid __proto__ mutation** - Do not mutate prototypes through `__proto__`.

### Object copying

2.12.1 **Object.assign invokes getters and setters and can partially mutate** - Do not rely on Object.assign as an atomic or accessor-free copy.
2.12.2 **Do not mistake shallow copying for independent object state** - Recreate nested references when independent state is required.

### Immutability

2.13.1 **Object.freeze is shallow** - Protect nested state separately when deep immutability is required.

### Metaprogramming

2.14.1 **Treat Proxy traps as semantic hooks, not transparent interception** - Respect proxy invariants and observable trap behavior.

### Runtime type identification

2.15.1 **Do not use instanceof for cross-realm Array detection** - Use `Array.isArray()` for possible cross-realm arrays.

### Keyed collections

2.16.1 **Use Map.has when undefined is a valid Map value** - Use `has()` to distinguish a missing key from an undefined value.
2.16.2 **Map object keys use identity, not structural equality** - Do not expect separately constructed objects to match Map keys.

### Memory ownership

2.17.1 **Use WeakMap for object-associated metadata that should not retain keys** - Use WeakMap where metadata must not retain its key.

### Property ordering

2.18.1 **Do not assume object properties enumerate purely in insertion order** - Account for integer-like key ordering.

### Reflection

2.19.1 **Use Reflect.ownKeys when every own key matters** - Use Reflect.ownKeys for complete own-key reflection.

### Collection equality

2.20.1 **Remember that Set uses SameValueZero equality** - Implement structural equality separately where required.

## 3. Arrays and iteration

### Array semantics and operations

3.1.1 **Do not use for...in as an array iterator** - Do not use for...in for array values or ordered indexes.
3.1.2 **Avoid accidental sparse arrays** - Avoid holes unless their semantics are intentional.
3.1.3 **Do not use delete to remove array elements** - Use a dense-array removal operation instead of delete.
3.1.4 **Beware the single-number Array constructor** - Avoid ambiguous single-number Array construction.
3.1.5 **Changing array length can delete data or create holes** - Treat length writes as structural mutations.
3.1.6 **Array.fill repeats object references** - Create a fresh object for each independent element.
3.1.7 **Supply a numeric comparator when sorting numbers** - Pass a numeric comparator when sorting numeric values.
3.1.8 **Remember that sort mutates the original array** - Copy before sort when the source array must remain unchanged.
3.1.9 **Write well-formed sort comparators** - Use a consistent comparator with sign-based ordering.
3.1.10 **Do not pass parseInt directly to map** - Wrap parseInt or specify its radix when mapping.
3.1.11 **Do not use map when you ignore its returned array** - Use a side-effect iteration form when the mapped array is unused.
3.1.12 **Give reduce an initial value when emptiness is possible** - Provide an initial accumulator if input may be empty.
3.1.13 **Avoid repeatedly copying a growing reduce accumulator** - Do not create avoidable quadratic copies in a reducer.
3.1.14 **Do not use forEach when you need early exit** - Use a loop or short-circuiting method for early exit.
3.1.15 **Avoid structural mutation during iterative array methods** - Do not structurally mutate an array during an iterative method unless required.
3.1.16 **Use includes when searching for NaN** - Use includes or SameValueZero equality to find NaN.
3.1.17 **Do not use async callbacks with Array.forEach when you need to wait** - Use awaitable iteration or promise composition when callback completion matters.
3.1.18 **for await...of adds asynchronous handling even for synchronous iterables** - Prefer for...of for synchronous iterables unless async behavior is needed.

## 4. Numeric representation and binary data

### Numbers, equality, and binary ownership

4.1.1 **Respect the safe integer range of Number** - Use an exact representation for integers outside the safe Number range.
4.1.2 **Do not parse exact large integers through JSON Number** - Serialize oversized exact JSON integers as strings or another exact representation.
4.1.3 **Do not use Math.random for security-sensitive randomness** - Use a cryptographically secure random API where unpredictability is required.
4.1.4 **Do not use bitwise operators as general numeric truncation** - Do not use bitwise truncation outside signed 32-bit values.
4.1.5 **Do not compare calculated floating-point values with naive exact equality** - Use a domain-appropriate tolerance for calculated floating-point values.
4.1.6 **Treat parseInt as a prefix parser, not strict numeric validation** - Reject trailing invalid characters with whole-string validation.
4.1.7 **Do not mix BigInt and Number arithmetic implicitly** - Convert Number and BigInt explicitly.
4.1.8 **Understand TypedArray numeric coercion** - Validate values against the typed array element semantics.
4.1.9 **Specify endianness explicitly with DataView** - Pass the binary format's byte order to DataView operations.
4.1.10 **Remember that transferring an ArrayBuffer detaches the original** - Do not access a transferred source buffer or its views.
4.1.11 **Synchronize SharedArrayBuffer access with Atomics** - Use Atomics or a defined synchronization protocol for coordinated shared access.
4.1.12 **Account for negative zero when it is semantically relevant** - Use SameValue semantics when negative zero matters.
4.1.13 **Know Math.round's negative-half behavior** - Do not assume Math.round matches a required negative rounding policy.

## 5. Text, Unicode, and regular expressions

### String encoding and regular-expression semantics

5.1.1 **Do not equate string length with user-perceived character count** - Use grapheme-aware logic where user-perceived character count is required.
5.1.2 **Normalize Unicode when canonical equivalence matters** - Normalize before comparison when canonical equivalence matters.
5.1.3 **Handle lone surrogates before URI encoding when necessary** - Handle malformed UTF-16 before URI encoding when it can occur.
5.1.4 **Treat user-provided replacement strings as replacement syntax** - Use a replacer function when user text must keep dollar sequences literal.
5.1.5 **Escape literal input before embedding it in a regular expression** - Escape external literal text before regex interpolation.
5.1.6 **Avoid catastrophic-backtracking regexes on untrusted input** - Avoid catastrophic patterns on untrusted or unbounded input.
5.1.7 **Do not reuse global or sticky regexes without accounting for lastIndex** - Reset or manage lastIndex between independent matches.
5.1.8 **Use Unicode-aware regex semantics for Unicode text** - Use Unicode-aware flags for Unicode text semantics.
5.1.9 **Prefer non-capturing regex groups when capture data is unnecessary** - Use non-capturing groups unless a capture is needed.

## 6. Dates, time zones, and internationalization

### Calendar semantics and locale behavior

6.1.1 **Avoid implementation-dependent Date parsing** - Use specified formats or explicit parsing for portable dates.
6.1.2 **Do not use local calendar arithmetic as elapsed-time arithmetic** - Use time-zone-aware duration logic for exact elapsed time.
6.1.3 **Remember that Date months are zero-based** - Treat numeric legacy Date months as zero-based.
6.1.4 **Account for Date setter overflow** - Account for overflow normalization in constrained calendar changes.
6.1.5 **Consider Temporal for complex date and time-zone logic** - Prefer Temporal where supported for complex date and time-zone semantics.
6.1.6 **Do not compare localized output to hardcoded strings** - Do not use localized presentation as stable machine data.
6.1.7 **Do not assume localeCompare returns only -1, 0, or 1** - Interpret localeCompare by sign.
6.1.8 **Reuse Intl formatter objects for repeated formatting** - Reuse a formatter for repeated equivalent formatting.

## 7. Errors, promises, and asynchronous scheduling

### Error and promise semantics

7.1.1 **Do not leave promises floating** - Await, return, or explicitly handle promises whose completion matters.
7.1.2 **Return promises from then callbacks** - Return required async work from then callbacks.
7.1.3 **Avoid async Promise executors** - Do not make Promise executors async.
7.1.4 **Promise races do not cancel losing operations** - Explicitly cancel losing operations that must stop.
7.1.5 **Throw Error objects rather than strings or primitive values** - Throw Error instances or appropriate subclasses.
7.1.6 **Preserve error causality when wrapping errors** - Preserve useful underlying errors through cause.
7.1.7 **Catch errors you can handle and rethrow unexpected ones** - Propagate unexpected errors instead of silently swallowing them.
7.1.8 **Choose Promise.all only when fail-fast semantics are appropriate** - Use a different combinator when every outcome must be observed.
7.1.9 **Distinguish Promise.any from Promise.race** - Choose first fulfillment or first settlement semantics deliberately.
7.1.10 **Run independent asynchronous operations concurrently when appropriate** - Start independent work concurrently where ordering does not require serialization.
7.1.11 **Promise.finally can replace the original failure** - Do not throw or reject from finally cleanup unless replacement is intended.
7.1.12 **Do not create unbounded recursive microtask chains** - Do not create microtask loops that can indefinitely starve the event loop.
7.1.13 **Keep APIs consistently synchronous or asynchronous** - Keep callback timing consistent across API paths.
7.1.14 **Promise executor return values are ignored** - Settle a Promise with resolve or reject.
7.1.15 **Remember that async functions always return promises** - Treat every async function result as a Promise.
7.1.16 **Avoid unnecessary await when scheduling order matters** - Avoid unnecessary await when its microtask boundary is material.

## 8. Modules, scripts, and runtime portability

### Module loading and host execution

8.1.1 **Avoid cyclic module dependencies that require early binding access** - Do not access imported cyclic bindings before initialization.
8.1.2 **Use top-level await deliberately** - Avoid critical dependency-path top-level await unless delay is intended.
8.1.3 **Imported bindings are read-only live bindings** - Do not reassign imports or treat them as snapshots.
8.1.4 **Use defer or modules instead of parser-blocking classic scripts when appropriate** - Use defer or modules where parser blocking is unnecessary.
8.1.5 **Use globalThis for portable access to the global object** - Use globalThis for cross-host global access.
8.1.6 **Avoid top-level var in classic browser scripts** - Do not declare top-level var unless global-property creation is desired.
8.1.7 **Avoid eval, Function constructors, and other string-to-code APIs** - Do not execute constructed JavaScript strings without an explicit unavoidable requirement.
8.1.8 **Avoid exporting a callable named then from dynamically imported modules** - Do not export a callable then from dynamically imported modules.
8.1.9 **Do not cache-bust dynamic imports indefinitely without considering memory** - Do not generate unbounded cache-busting dynamic import URLs.
8.1.10 **Browser bare module specifiers require resolution support** - Configure resolution support before using browser bare specifiers.

## 9. Cloning and JSON serialization

### Copying and serialization boundaries

9.1.1 **Use structuredClone rather than JSON round-tripping for general deep cloning** - Use structuredClone for general deep cloning of supported values.
9.1.2 **Know the limits of structured cloning** - Do not use structuredClone when unsupported values or semantics must survive.
9.1.3 **JSON.stringify silently transforms or removes some values** - Do not assume undefined, functions, or symbols round-trip through JSON.
9.1.4 **Map and Set do not serialize meaningfully with plain JSON.stringify** - Use an explicit representation when Map or Set contents must persist.
9.1.5 **BigInt is not supported by default JSON serialization** - Convert BigInt to a defined JSON representation first.

## 10. Fetch, URLs, CORS, and client storage

### HTTP, URL, and storage contracts

10.1.1 **Check Fetch HTTP status explicitly** - Check response status where unsuccessful HTTP responses are failures.
10.1.2 **Fetch request and response bodies are one-shot streams** - Clone before first body consumption only when a valid second read is required.
10.1.3 **Be careful cloning large streaming responses** - Avoid clone where uneven large-stream consumers could create unacceptable buffering.
10.1.4 **Do not set multipart Content-Type manually for FormData** - Let fetch set the multipart boundary for a FormData body.
10.1.5 **no-cors does not bypass CORS** - Do not use no-cors to obtain a readable cross-origin response.
10.1.6 **Treat cross-origin credential inclusion as a security decision** - Enable cross-origin credentials only within an intentional CORS and CSRF model.
10.1.7 **Use URL instead of hand-parsing URLs** - Use URL and URLSearchParams for URL construction and parsing.
10.1.8 **Preserve literal plus signs in URLSearchParams deliberately** - Construct parameter values without losing required literal plus signs.
10.1.9 **Distinguish encodeURI from encodeURIComponent** - Encode URI components with encodeURIComponent and complete URI syntax with encodeURI.
10.1.10 **Do not assume decodeURIComponent accepts arbitrary input** - Handle malformed external encodings and plus-sign semantics explicitly.
10.1.11 **Avoid heavy synchronous Web Storage work** - Avoid blocking storage operations on responsiveness-critical paths.
10.1.12 **Prefer Web Storage methods over property syntax** - Use the Web Storage method APIs.

## 11. DOM content, events, and platform capability

### DOM manipulation and event behavior

11.1.1 **Treat HTML string insertion as an injection sink** - Do not send untrusted data to HTML parsing sinks without an appropriate trusted sanitization boundary.
11.1.2 **Distinguish live and static DOM collections** - Account for collection liveness while mutating the DOM.
11.1.3 **Escape dynamic values used in CSS selectors** - Escape dynamic literal selector values.
11.1.4 **Distinguish event.target from event.currentTarget** - Use origin and listener targets according to their distinct event semantics.
11.1.5 **Do not call preventDefault from a passive listener** - Register non-passive where default cancellation is required.
11.1.6 **stopPropagation does not prevent the default action** - Call preventDefault to cancel default actions.
11.1.7 **Preserve listener identity when removing event listeners** - Reuse identity and capture settings when removing listeners.
11.1.8 **Repeated anonymous event listeners are distinct registrations** - Reuse a listener function where one registration is intended.
11.1.9 **dataset values are strings** - Parse dataset values and remove attributes explicitly.
11.1.10 **Boolean HTML attributes are controlled by presence** - Remove a Boolean attribute to represent false.
11.1.11 **Prefer feature detection to user-agent sniffing** - Detect the needed platform capability.
11.1.12 **Prefer textContent over innerText when rendered-text semantics are unnecessary** - Use textContent unless rendered-text semantics are required.

## 12. Rendering, timers, and resource lifetime

### Browser scheduling and deterministic cleanup

12.1.1 **Use requestAnimationFrame for JavaScript-driven animation** - Use requestAnimationFrame for JavaScript-driven visual updates.
12.1.2 **Base animation progress on the requestAnimationFrame timestamp** - Base animation progress on elapsed time.
12.1.3 **Do not treat timer delays as exact schedules** - Treat timer delays as minimum scheduling opportunities, not deadlines.
12.1.4 **Prefer recursive setTimeout when interval work may overrun** - Schedule the next run after current overrun-prone work completes.
12.1.5 **Use performance.now for elapsed-time measurement** - Use performance.now for monotonic browser elapsed timing.
12.1.6 **Do not rely on garbage collection for essential cleanup** - Close or dispose correctness-critical resources deterministically.
12.1.7 **Revoke object URLs when no longer needed** - Revoke application-owned object URLs at end of use.
12.1.8 **Use deterministic disposal for disposable resources when supported** - Use supported deterministic resource disposal.
