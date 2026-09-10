# JavaScript Pitfalls Catalog
_Entry format: <index> **<canonical name>** _(impact: [high|medium|low]; consensus: [high|medium|low])_ - <concise definition>._

## 1. Language foundations and control flow

### Execution semantics

1.1.1 **Use strict mode or ES modules instead of sloppy mode** _(impact: high; consensus: high)_ - Use ES modules or strict mode so historically silent mistakes become errors and legacy ambiguity is removed.

### Binding and scope

1.2.1 **Never rely on assignment to undeclared variables** _(impact: high; consensus: high)_ - Declare bindings deliberately because sloppy-mode undeclared assignment can create a global.
1.2.2 **Prefer block-scoped bindings over var for local state** _(impact: medium; consensus: high)_ - Prefer `const`, or `let` when reassignment is needed, unless intentional function-scoped `var` semantics are required.

### Equality semantics

1.3.1 **Prefer strict equality when coercion is not intentional** _(impact: medium; consensus: high)_ - Use `===` and `!==` unless coercive equality is expressly part of the intended behavior.

### Coercion and defaults

1.4.1 **Use nullish coalescing for nullish defaults** _(impact: medium; consensus: high)_ - Use `??`, not `||`, for defaults when `0`, `false`, or an empty string are valid values.

### Numeric coercion

1.5.1 **Prefer Number.isNaN over global isNaN** _(impact: medium; consensus: high)_ - Use `Number.isNaN()` to test actual `NaN` without coercing another value first.
1.5.2 **Prefer Number.isFinite over global isFinite** _(impact: medium; consensus: high)_ - Use `Number.isFinite()` to test actual finite numbers without coercion.

### Primitive wrappers

1.6.1 **Do not construct Boolean wrapper objects** _(impact: medium; consensus: high)_ - Use Boolean primitives, not `new Boolean()`, because wrapper objects are truthy even when they wrap false.

### Type inspection

1.7.1 **Remember that typeof null is "object"** _(impact: medium; consensus: high)_ - Exclude `null` when an object type test must reject nullish values.

### Temporal dead zone

1.8.1 **typeof is not universally safe before declaration** _(impact: medium; consensus: high)_ - Do not use `typeof` as an unconditional existence check for lexical bindings that may be in their temporal dead zone.

### Default-value semantics

1.9.1 **Default parameters and destructuring defaults do not replace null** _(impact: medium; consensus: high)_ - Handle `null` explicitly when a default must apply to both `undefined` and `null`.

### Binding semantics

1.10.1 **const does not make objects immutable** _(impact: medium; consensus: high)_ - A `const` binding prevents rebinding, not mutation of an object or array it references.

### Function invocation

1.11.1 **Remember that this is determined by invocation** _(impact: medium; consensus: high)_ - Invoke a function with its intended receiver because `this` depends on the call form, not definition location.
1.11.2 **Use arrow functions only when lexical this is desired** _(impact: medium; consensus: high)_ - Do not use an arrow where dynamic `this`, own `arguments`, or constructor behavior is required.
1.11.3 **Bind or wrap methods when passing them as callbacks** _(impact: medium; consensus: high)_ - Bind or wrap a method that uses `this` unless the receiving API provides the intended receiver.

### Control flow

1.12.1 **Do not return, throw, break, or continue from finally** _(impact: high; consensus: high)_ - Keep `finally` for cleanup so it does not silently replace a pending return, exception, or loop completion.
1.12.2 **Avoid accidental switch fallthrough** _(impact: medium; consensus: high)_ - Terminate each switch case unless documented fallthrough is intentional.
1.12.3 **Avoid accidental assignment in conditions** _(impact: medium; consensus: high)_ - Avoid assignment in a conditional unless it is intentional and syntactically unmistakable.

### Automatic semicolon insertion

1.13.1 **Keep return and throw values on the same line** _(impact: high; consensus: high)_ - Start a returned or thrown expression on the keyword line because line breaks can trigger ASI or a syntax error.
1.13.2 **Choose an ASI-safe semicolon policy** _(impact: low; consensus: high)_ - Use explicit semicolons or a consistent ASI-safe statement-boundary convention.

### Operator semantics

1.14.1 **Do not mix ?? with && or || without explicit grouping** _(impact: medium; consensus: high)_ - Parenthesize combinations of `??` with `&&` or `||` to make the intended grouping explicit.

### Optional chaining

1.15.1 **Optional chaining only short-circuits a continuous chain** _(impact: medium; consensus: high)_ - Keep every access requiring nullish protection in one optional chain because grouping ends short-circuiting.
1.15.2 **Optional call does not prove a property is callable** _(impact: medium; consensus: high)_ - Ensure an existing optional-call property is callable when a non-function value is possible.

### Arrow-function syntax

1.16.1 **Parenthesize object literals returned implicitly from arrow functions** _(impact: low; consensus: high)_ - Wrap an implicitly returned object literal in parentheses so it is not parsed as a block.

## 2. Objects, classes, and keyed collections

### Class field semantics

2.1.1 **Class fields do not behave exactly like constructor assignments** _(impact: medium; consensus: high)_ - Verify inherited setter and accessor behavior before replacing constructor assignments with class fields.

### Class initialization

2.2.1 **Call super before using this in derived constructors** _(impact: medium; consensus: high)_ - Call `super()` before accessing `this` in a derived constructor.
2.2.2 **Class static initialization order is observable** _(impact: low; consensus: high)_ - Respect declaration order when static initialization reads class fields.

### Class encapsulation

2.3.1 **Private fields are lexically private, not conventionally protected** _(impact: medium; consensus: high)_ - Do not expect a subclass to access a superclass private field.

### Accessors

2.4.1 **Make getters return a value on every intended path** _(impact: medium; consensus: high)_ - Return the intended value from every reachable getter path.

### Constructor semantics

2.5.1 **Avoid explicit constructor return values** _(impact: medium; consensus: high)_ - Rely on the implicit instance return unless replacement-object semantics are intended.

### Object security

2.6.1 **Defend dynamic property writes against prototype pollution** _(impact: high; consensus: high)_ - Validate untrusted property names and paths to prevent prototype traversal or mutation.

### Property ownership

2.7.1 **Use Object.hasOwn for own-property tests** _(impact: medium; consensus: high)_ - Use `Object.hasOwn()` when inherited properties must be excluded.

### Property-key semantics

2.8.1 **Plain-object keys are strings or symbols** _(impact: medium; consensus: high)_ - Use `Map` or another identity-preserving structure for arbitrary object keys.

### Property enumeration

2.9.1 **Know what Object.keys omits** _(impact: medium; consensus: high)_ - Use an enumeration API that includes the key kinds and property attributes your reflection requires.

### Property descriptors

2.10.1 **Object.defineProperty descriptor defaults are false** _(impact: medium; consensus: high)_ - Set descriptor flags explicitly because omitted flags default to false.
2.10.2 **Preserve descriptors explicitly when cloning accessor definitions** _(impact: low; consensus: high)_ - Copy property descriptors when definitions, rather than current values, must be preserved.

### Prototype semantics

2.11.1 **Avoid __proto__ mutation** _(impact: medium; consensus: high)_ - Do not use `__proto__` to change prototypes; use explicit prototype APIs only when required.

### Object copying

2.12.1 **Object.assign invokes getters and setters and can partially mutate** _(impact: medium; consensus: high)_ - Do not treat `Object.assign()` as a side-effect-free copy when accessors or failures are possible.
2.12.2 **Do not mistake shallow copying for independent object state** _(impact: high; consensus: high)_ - Clone or reconstruct nested references that need independent state.

### Immutability

2.13.1 **Object.freeze is shallow** _(impact: medium; consensus: high)_ - Do not treat `Object.freeze()` as recursively immutable.

### Metaprogramming

2.14.1 **Treat Proxy traps as semantic hooks, not transparent interception** _(impact: medium; consensus: high)_ - Design proxy traps as observable behavior, including invariants and receiver effects.

### Runtime type identification

2.15.1 **Do not use instanceof for cross-realm Array detection** _(impact: medium; consensus: high)_ - Use `Array.isArray()` when arrays can originate in another realm.

### Keyed collections

2.16.1 **Use Map.has when undefined is a valid Map value** _(impact: medium; consensus: high)_ - Use `Map.has()` rather than a retrieved value to distinguish absence from an undefined value.
2.16.2 **Map object keys use identity, not structural equality** _(impact: medium; consensus: high)_ - Treat object Map keys as identity keys and implement structural matching separately when needed.

### Memory ownership

2.17.1 **Use WeakMap for object-associated metadata that should not retain keys** _(impact: medium; consensus: high)_ - Use `WeakMap` for metadata that must not keep its object keys alive.

### Property ordering

2.18.1 **Do not assume object properties enumerate purely in insertion order** _(impact: low; consensus: high)_ - Do not rely on pure insertion order when integer-index-like property keys are possible.

### Reflection

2.19.1 **Use Reflect.ownKeys when every own key matters** _(impact: low; consensus: high)_ - Use `Reflect.ownKeys()` when every own string and symbol key matters.

### Collection equality

2.20.1 **Remember that Set uses SameValueZero equality** _(impact: low; consensus: high)_ - Account for SameValueZero and object identity semantics when using Set membership.

## 3. Arrays and iteration

### Array semantics and operations

3.1.1 **Do not use for...in as an array iterator** _(impact: medium; consensus: high)_ - Do not use `for...in` when array values or ordered indexes are needed.
3.1.2 **Avoid accidental sparse arrays** _(impact: medium; consensus: high)_ - Avoid holes unless their distinct iteration and serialization behavior is deliberate.
3.1.3 **Do not use delete to remove array elements** _(impact: medium; consensus: high)_ - Use `splice()` or another dense-array operation instead of `delete` for element removal.
3.1.4 **Beware the single-number Array constructor** _(impact: medium; consensus: high)_ - Avoid `Array(n)` when a one-element array may be intended.
3.1.5 **Changing array length can delete data or create holes** _(impact: medium; consensus: high)_ - Treat writes to `length` as structural changes that can truncate data or create holes.
3.1.6 **Array.fill repeats object references** _(impact: medium; consensus: high)_ - Create a distinct object per element when rows or nested state must not be shared.
3.1.7 **Supply a numeric comparator when sorting numbers** _(impact: medium; consensus: high)_ - Supply a numeric comparator because default sort compares string representations.
3.1.8 **Remember that sort mutates the original array** _(impact: medium; consensus: high)_ - Copy before sorting when the original array must remain unchanged.
3.1.9 **Write well-formed sort comparators** _(impact: medium; consensus: high)_ - Use a consistent comparator that returns ordering by sign.
3.1.10 **Do not pass parseInt directly to map** _(impact: medium; consensus: high)_ - Wrap `parseInt` or specify radix because `map` supplies the index as a second argument.
3.1.11 **Do not use map when you ignore its returned array** _(impact: medium; consensus: high)_ - Use `forEach`, a loop, or a transformation whose result is consumed.
3.1.12 **Give reduce an initial value when emptiness is possible** _(impact: medium; consensus: high)_ - Supply an initial accumulator whenever input may be empty.
3.1.13 **Avoid repeatedly copying a growing reduce accumulator** _(impact: medium; consensus: high)_ - Do not repeatedly copy a growing accumulator when that creates avoidable quadratic work.
3.1.14 **Do not use forEach when you need early exit** _(impact: medium; consensus: high)_ - Use a loop or a short-circuiting method when iteration must exit early.
3.1.15 **Avoid structural mutation during iterative array methods** _(impact: medium; consensus: high)_ - Do not structurally mutate an array while an iterative method traverses it unless those semantics are required.
3.1.16 **Use includes when searching for NaN** _(impact: medium; consensus: high)_ - Use `includes()` or another SameValueZero mechanism when membership must find `NaN`.
3.1.17 **Do not use async callbacks with Array.forEach when you need to wait** _(impact: high; consensus: high)_ - Use `for...of` with await or explicit promise composition because `forEach` does not await callbacks.
3.1.18 **for await...of adds asynchronous handling even for synchronous iterables** _(impact: low; consensus: high)_ - Use `for...of` for synchronous iterables unless async unwrapping or a unified async contract is needed.

## 4. Numeric representation and binary data

### Numbers, equality, and binary ownership

4.1.1 **Respect the safe integer range of Number** _(impact: high; consensus: high)_ - Use BigInt or strings when exact integers exceed JavaScript's safe Number range.
4.1.2 **Do not parse exact large integers through JSON Number** _(impact: high; consensus: high)_ - Preserve oversized JSON integers as an exact representation at the serialization boundary.
4.1.3 **Do not use Math.random for security-sensitive randomness** _(impact: high; consensus: high)_ - Use Web Crypto for secrets, security tokens, or identifiers requiring unpredictability.
4.1.4 **Do not use bitwise operators as general numeric truncation** _(impact: medium; consensus: high)_ - Do not use bitwise conversion when values may exceed signed 32-bit range.
4.1.5 **Do not compare calculated floating-point values with naive exact equality** _(impact: medium; consensus: high)_ - Compare calculated floating-point values with a domain-appropriate tolerance.
4.1.6 **Treat parseInt as a prefix parser, not strict numeric validation** _(impact: medium; consensus: high)_ - Do not use `parseInt` as whole-string validation when trailing invalid text must be rejected.
4.1.7 **Do not mix BigInt and Number arithmetic implicitly** _(impact: medium; consensus: high)_ - Convert explicitly between BigInt and Number while preserving needed precision.
4.1.8 **Understand TypedArray numeric coercion** _(impact: medium; consensus: high)_ - Account for the target typed array's range and coercion when writing values.
4.1.9 **Specify endianness explicitly with DataView** _(impact: medium; consensus: high)_ - Pass the byte order required by a defined binary format to DataView operations.
4.1.10 **Remember that transferring an ArrayBuffer detaches the original** _(impact: medium; consensus: high)_ - Do not use a transferred buffer or its views as though they remain attached.
4.1.11 **Synchronize SharedArrayBuffer access with Atomics** _(impact: high; consensus: high)_ - Use Atomics or another defined protocol for shared-memory coordination.
4.1.12 **Account for negative zero when it is semantically relevant** _(impact: low; consensus: high)_ - Use `Object.is()` when zero and negative zero must remain distinguishable.
4.1.13 **Know Math.round's negative-half behavior** _(impact: low; consensus: high)_ - Choose an explicit rounding rule when negative halfway values matter.

## 5. Text, Unicode, and regular expressions

### String encoding and regular-expression semantics

5.1.1 **Do not equate string length with user-perceived character count** _(impact: medium; consensus: high)_ - Do not use UTF-16 length or indexing as grapheme counting when user-perceived characters matter.
5.1.2 **Normalize Unicode when canonical equivalence matters** _(impact: medium; consensus: high)_ - Normalize strings before comparison when canonically equivalent Unicode forms must match.
5.1.3 **Handle lone surrogates before URI encoding when necessary** _(impact: medium; consensus: high)_ - Make malformed UTF-16 well formed or handle it before URI encoding when lone surrogates are possible.
5.1.4 **Treat user-provided replacement strings as replacement syntax** _(impact: medium; consensus: high)_ - Use a replacer function when user replacement text must keep dollar syntax literal.
5.1.5 **Escape literal input before embedding it in a regular expression** _(impact: high; consensus: high)_ - Escape external literal text before interpolating it into a constructed regular expression.
5.1.6 **Avoid catastrophic-backtracking regexes on untrusted input** _(impact: high; consensus: high)_ - Avoid ambiguous backtracking patterns on untrusted or unbounded input.
5.1.7 **Do not reuse global or sticky regexes without accounting for lastIndex** _(impact: medium; consensus: high)_ - Reset or account for `lastIndex` between independent global or sticky matches.
5.1.8 **Use Unicode-aware regex semantics for Unicode text** _(impact: medium; consensus: high)_ - Use Unicode-aware flags and properties when regexes operate on Unicode code points or properties.
5.1.9 **Prefer non-capturing regex groups when capture data is unnecessary** _(impact: low; consensus: high)_ - Use non-capturing groups for grouping that does not need capture data.

## 6. Dates, time zones, and internationalization

### Calendar semantics and locale behavior

6.1.1 **Avoid implementation-dependent Date parsing** _(impact: high; consensus: high)_ - Use specified ISO-compatible formats or explicit parsing rather than implementation-dependent date strings.
6.1.2 **Do not use local calendar arithmetic as elapsed-time arithmetic** _(impact: high; consensus: high)_ - Use UTC or time-zone-aware duration logic when exact elapsed time matters across DST transitions.
6.1.3 **Remember that Date months are zero-based** _(impact: medium; consensus: high)_ - Treat numeric legacy Date months as zero-based.
6.1.4 **Account for Date setter overflow** _(impact: medium; consensus: high)_ - Account for Date setter normalization when a calendar month or day is constrained.
6.1.5 **Consider Temporal for complex date and time-zone logic** _(impact: medium; consensus: medium)_ - Use Temporal where supported and suitable for complex calendar, duration, instant, or time-zone behavior.
6.1.6 **Do not compare localized output to hardcoded strings** _(impact: medium; consensus: high)_ - Do not treat localized presentation output as a stable machine-readable value.
6.1.7 **Do not assume localeCompare returns only -1, 0, or 1** _(impact: low; consensus: high)_ - Interpret localeCompare results by sign, not exact nonzero values.
6.1.8 **Reuse Intl formatter objects for repeated formatting** _(impact: low; consensus: high)_ - Reuse an Intl formatter for repeated formatting with identical locale and options.

## 7. Errors, promises, and asynchronous scheduling

### Error and promise semantics

7.1.1 **Do not leave promises floating** _(impact: high; consensus: high)_ - Await, return, or deliberately handle each promise whose completion or failure matters.
7.1.2 **Return promises from then callbacks** _(impact: high; consensus: high)_ - Return asynchronous work from a then callback when later chain steps depend on it.
7.1.3 **Avoid async Promise executors** _(impact: high; consensus: high)_ - Do not use an async Promise executor; usually return an async function result directly.
7.1.4 **Promise races do not cancel losing operations** _(impact: high; consensus: high)_ - Cancel losing work explicitly because Promise.race settlement does not stop it.
7.1.5 **Throw Error objects rather than strings or primitive values** _(impact: medium; consensus: high)_ - Throw Error instances or suitable subclasses for application failures.
7.1.6 **Preserve error causality when wrapping errors** _(impact: medium; consensus: high)_ - Preserve a materially useful original failure through `cause` when wrapping an error.
7.1.7 **Catch errors you can handle and rethrow unexpected ones** _(impact: medium; consensus: high)_ - Propagate failures a layer cannot meaningfully handle.
7.1.8 **Choose Promise.all only when fail-fast semantics are appropriate** _(impact: medium; consensus: high)_ - Use Promise.all only when fail-fast aggregate rejection matches the required outcome.
7.1.9 **Distinguish Promise.any from Promise.race** _(impact: medium; consensus: high)_ - Select Promise.any for first fulfillment and Promise.race for first settlement.
7.1.10 **Run independent asynchronous operations concurrently when appropriate** _(impact: medium; consensus: high)_ - Start independent async operations concurrently unless an ordering dependency exists.
7.1.11 **Promise.finally can replace the original failure** _(impact: medium; consensus: high)_ - Keep finally callbacks to cleanup unless replacing settlement is deliberate.
7.1.12 **Do not create unbounded recursive microtask chains** _(impact: medium; consensus: high)_ - Avoid self-perpetuating microtasks that starve tasks, rendering, timers, and input.
7.1.13 **Keep APIs consistently synchronous or asynchronous** _(impact: medium; consensus: high)_ - Do not invoke one callback synchronously on some paths and asynchronously on others.
7.1.14 **Promise executor return values are ignored** _(impact: low; consensus: high)_ - Settle a Promise through resolve or reject, not its executor return value.
7.1.15 **Remember that async functions always return promises** _(impact: low; consensus: high)_ - Treat an async function return as a Promise even when its body returns a non-Promise value.
7.1.16 **Avoid unnecessary await when scheduling order matters** _(impact: low; consensus: high)_ - Avoid an unnecessary await when its extra microtask boundary affects ordering or performance.

## 8. Modules, scripts, and runtime portability

### Module loading and host execution

8.1.1 **Avoid cyclic module dependencies that require early binding access** _(impact: high; consensus: high)_ - Do not access cyclic imported bindings before their initialization.
8.1.2 **Use top-level await deliberately** _(impact: medium; consensus: high)_ - Do not put top-level await on a critical dependency path unless delayed evaluation is intended.
8.1.3 **Imported bindings are read-only live bindings** _(impact: medium; consensus: high)_ - Treat imports as read-only live bindings, not copied local values.
8.1.4 **Use defer or modules instead of parser-blocking classic scripts when appropriate** _(impact: medium; consensus: high)_ - Use defer or modules when a classic script need not block HTML parsing at its location.
8.1.5 **Use globalThis for portable access to the global object** _(impact: medium; consensus: high)_ - Use globalThis for portable global-object access across hosts.
8.1.6 **Avoid top-level var in classic browser scripts** _(impact: medium; consensus: high)_ - Avoid top-level var in classic browser scripts unless a global property is intentional.
8.1.7 **Avoid eval, Function constructors, and other string-to-code APIs** _(impact: high; consensus: high)_ - Do not execute constructed code strings when ordinary functions or data can express the behavior.
8.1.8 **Avoid exporting a callable named then from dynamically imported modules** _(impact: low; consensus: high)_ - Do not export a callable named then from a module intended for dynamic import.
8.1.9 **Do not cache-bust dynamic imports indefinitely without considering memory** _(impact: low; consensus: high)_ - Do not create unbounded unique dynamic import URLs solely to bypass module caching.
8.1.10 **Browser bare module specifiers require resolution support** _(impact: low; consensus: high)_ - Use bare browser module specifiers only with an import map or supported resolver.

## 9. Cloning and JSON serialization

### Copying and serialization boundaries

9.1.1 **Use structuredClone rather than JSON round-tripping for general deep cloning** _(impact: medium; consensus: high)_ - Use structuredClone for general deep cloning of supported JavaScript data.
9.1.2 **Know the limits of structured cloning** _(impact: medium; consensus: high)_ - Do not use structuredClone when unsupported values or semantics such as functions, DOM nodes, descriptors, or accessors must survive.
9.1.3 **JSON.stringify silently transforms or removes some values** _(impact: medium; consensus: high)_ - Do not assume undefined, functions, or symbols round-trip through JSON.stringify.
9.1.4 **Map and Set do not serialize meaningfully with plain JSON.stringify** _(impact: medium; consensus: high)_ - Do not use plain JSON.stringify when Map or Set contents must be preserved.
9.1.5 **BigInt is not supported by default JSON serialization** _(impact: medium; consensus: high)_ - Convert BigInt to an explicit serializable representation before JSON.stringify.

## 10. Fetch, URLs, CORS, and client storage

### HTTP, URL, and storage contracts

10.1.1 **Check Fetch HTTP status explicitly** _(impact: high; consensus: high)_ - Check response.ok or status when HTTP failure is a failure for the operation.
10.1.2 **Fetch request and response bodies are one-shot streams** _(impact: medium; consensus: high)_ - Treat fetch bodies as one-shot streams and clone before first consumption only when a valid second read is needed.
10.1.3 **Be careful cloning large streaming responses** _(impact: medium; consensus: high)_ - Avoid cloning large streaming bodies with uneven consumers when unbounded buffering is unacceptable.
10.1.4 **Do not set multipart Content-Type manually for FormData** _(impact: medium; consensus: high)_ - Let fetch set multipart Content-Type and its boundary when FormData is the body.
10.1.5 **no-cors does not bypass CORS** _(impact: medium; consensus: high)_ - Do not use no-cors as a way to obtain a readable cross-origin response.
10.1.6 **Treat cross-origin credential inclusion as a security decision** _(impact: medium; consensus: high)_ - Enable cross-origin credentials only when required by the CORS and CSRF security model.
10.1.7 **Use URL instead of hand-parsing URLs** _(impact: medium; consensus: high)_ - Parse and construct URLs and query parameters with URL and URLSearchParams.
10.1.8 **Preserve literal plus signs in URLSearchParams deliberately** _(impact: medium; consensus: high)_ - Do not interpolate raw plus-containing values into URLSearchParams string input when plus must remain literal.
10.1.9 **Distinguish encodeURI from encodeURIComponent** _(impact: medium; consensus: high)_ - Use encodeURIComponent for components and reserve encodeURI for complete URIs with structural delimiters.
10.1.10 **Do not assume decodeURIComponent accepts arbitrary input** _(impact: medium; consensus: high)_ - Handle malformed encoding errors when decoding external input and do not treat plus as a decoded space.
10.1.11 **Avoid heavy synchronous Web Storage work** _(impact: medium; consensus: high)_ - Avoid large or frequent synchronous storage operations when they can block responsiveness.
10.1.12 **Prefer Web Storage methods over property syntax** _(impact: medium; consensus: high)_ - Use storage getItem, setItem, and removeItem methods rather than property syntax.

## 11. DOM content, events, and platform capability

### DOM manipulation and event behavior

11.1.1 **Treat HTML string insertion as an injection sink** _(impact: high; consensus: high)_ - Do not pass untrusted strings to HTML-parsing sinks; use text insertion or appropriate trusted sanitization.
11.1.2 **Distinguish live and static DOM collections** _(impact: medium; consensus: high)_ - Account for whether a DOM collection changes as the DOM is mutated.
11.1.3 **Escape dynamic values used in CSS selectors** _(impact: medium; consensus: high)_ - Correctly escape dynamic literal selector values, such as with CSS.escape.
11.1.4 **Distinguish event.target from event.currentTarget** _(impact: medium; consensus: high)_ - Use target for event origin and currentTarget for the registered listener target.
11.1.5 **Do not call preventDefault from a passive listener** _(impact: medium; consensus: high)_ - Register a non-passive listener when it must cancel default behavior.
11.1.6 **stopPropagation does not prevent the default action** _(impact: medium; consensus: high)_ - Use preventDefault, not stopPropagation, to cancel a browser default action.
11.1.7 **Preserve listener identity when removing event listeners** _(impact: medium; consensus: high)_ - Reuse listener identity and capture semantics when removing a listener, or use AbortSignal lifecycle management.
11.1.8 **Repeated anonymous event listeners are distinct registrations** _(impact: medium; consensus: high)_ - Do not repeatedly add newly created anonymous listeners when one reusable registration is intended.
11.1.9 **dataset values are strings** _(impact: medium; consensus: high)_ - Parse dataset values explicitly and remove a data attribute rather than assigning null.
11.1.10 **Boolean HTML attributes are controlled by presence** _(impact: medium; consensus: high)_ - Represent false by removing a Boolean HTML attribute, not by assigning the string false.
11.1.11 **Prefer feature detection to user-agent sniffing** _(impact: medium; consensus: high)_ - Test the required capability instead of inferring it from a user-agent string.
11.1.12 **Prefer textContent over innerText when rendered-text semantics are unnecessary** _(impact: low; consensus: high)_ - Use textContent when CSS-aware rendered-text behavior is not needed.

## 12. Rendering, timers, and resource lifetime

### Browser scheduling and deterministic cleanup

12.1.1 **Use requestAnimationFrame for JavaScript-driven animation** _(impact: medium; consensus: high)_ - Use requestAnimationFrame rather than fixed timer loops for JavaScript-driven visual animation.
12.1.2 **Base animation progress on the requestAnimationFrame timestamp** _(impact: medium; consensus: high)_ - Calculate animation progress from elapsed time or the supplied frame timestamp, not a fixed frame duration.
12.1.3 **Do not treat timer delays as exact schedules** _(impact: medium; consensus: high)_ - Do not treat timeout or interval delays as exact execution deadlines.
12.1.4 **Prefer recursive setTimeout when interval work may overrun** _(impact: medium; consensus: high)_ - Use completion-based scheduling when recurring work must finish before the next run starts.
12.1.5 **Use performance.now for elapsed-time measurement** _(impact: medium; consensus: high)_ - Use performance.now when browser elapsed-time measurement requires a monotonic clock.
12.1.6 **Do not rely on garbage collection for essential cleanup** _(impact: high; consensus: high)_ - Make correctness-critical cleanup deterministic rather than dependent on WeakRef or finalizer timing.
12.1.7 **Revoke object URLs when no longer needed** _(impact: medium; consensus: high)_ - Revoke application-owned object URLs when their lifetime ends.
12.1.8 **Use deterministic disposal for disposable resources when supported** _(impact: medium; consensus: medium)_ - Use scope-bound deterministic disposal when the runtime and resource support it.
