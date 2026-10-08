#### User said:

Research as comprehensively as practical for vanilla JavaScript-specific pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms, especially cases where experienced JavaScript developers recommend "do this instead of that."

The goal is to identify as many distinct, materially useful JavaScript practices as possible, not just the most popular or obvious examples.

Research across the full JavaScript language, runtime behavior, built-in APIs, standard development practices, and ecosystem conventions that materially affect vanilla JavaScript.

Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.

Actively look for unexpected or less obvious classes of issues that may not fit common JavaScript best-practice lists.

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
- Consensus - High, Medium, or Low based on how broadly the recommendation is supported by authoritative sources and experienced JavaScript practitioners.
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

- ECMAScript specifications and proposals
- MDN Web Docs
- TC39 documentation and discussions
- browser and runtime documentation
- guidance from JavaScript engine, runtime, and standards contributors
- established engineering documentation
- respected JavaScript experts and practitioners
- technically rigorous articles and discussions

Do not treat popularity, repetition, or search ranking alone as evidence of correctness or consensus.

Evaluate Impact and Consensus independently. A finding may have high impact but low consensus, or low impact but high consensus.

Include disputed practices when they are materially relevant, but assign an appropriate Consensus rating and accurately describe the disagreement rather than presenting one side as settled guidance.

Avoid duplicate findings that describe the same underlying issue. Merge substantially equivalent recommendations while preserving genuinely different cases, conditions, or failure modes.

Focus on guidance specific to vanilla JavaScript, including the language itself and standard platform APIs. Do not fill the results with framework-specific, library-specific, build-tool-specific, or TypeScript-specific advice unless it exposes a JavaScript behavior that remains materially relevant without those tools.

Do not fill the results with generic programming advice unless JavaScript introduces a distinct consideration.

Do not stop after finding a conventional "top JavaScript best practices" list. Use iterative discovery to identify additional terminology, failure modes, recommendations, and sources from the findings themselves.

Continue researching until further searching is producing primarily duplicates, minor stylistic preferences, weakly supported claims, or findings with little practical significance.

-----
#### Assistant said:

I’ll use iterative discovery rather than a fixed category list, prioritize specifications and official documentation, then merge overlapping findings and rank impact separately from consensus. I’ll continue until new searches mostly produce duplicates or low-value stylistic rules.

-----
#### Assistant said:

The research is already surfacing several less-obvious classes beyond ordinary best-practice lists, including live versus static DOM collections, stateful regular expressions, JSON precision/serialization traps, prototype pollution, module-cycle TDZ failures, async iteration mistakes, and mutating versus copying built-ins. I’m expanding into object identity/realms, typed data, errors, proxies, DOM events, and coercion edge cases before deduplicating.

-----
#### Assistant said:

The catalog is now broad enough that repeated searches are mostly reinforcing known classes rather than revealing new major ones. The remaining high-value edge cases I’m checking are deterministic cleanup/GC, property ordering, localization contracts, one-shot streams, optional-chaining boundaries, and a few binary-data and module-cache behaviors.

-----
#### Assistant said:

Iterative discovery reached practical saturation: later searches were producing mostly duplicates, narrow variants, or low-value stylistic preferences. The categories below were assigned after discovery rather than used to constrain the search.

## 1. High Impact

Name: Use strict mode or ES modules instead of sloppy mode  
Category: Execution semantics  
Impact: High  
Consensus: High  
Description: Prefer ES modules, which are strict automatically, or `"use strict"` for classic scripts. Strict mode converts several silent mistakes into errors and removes historically problematic behavior.  
Why: It prevents classes of failures such as silent assignment errors, accidental globals, ambiguous `this`, and use of `with`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode citeturn665234search1

Name: Never rely on assignment to undeclared variables  
Category: Binding and scope  
Impact: High  
Consensus: High  
Description: Always declare bindings with `const`, `let`, or an intentional declaration rather than assigning to an unknown identifier. In sloppy scripts, undeclared assignment can create a global.  
Why: Accidental globals create hidden shared state, name collisions, memory retention, and behavior that changes under strict mode.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Grammar_and_types citeturn773294search18

Name: Avoid eval, Function constructors, and other string-to-code APIs  
Category: Dynamic code execution  
Impact: High  
Consensus: High  
Description: Do not construct executable JavaScript from strings when normal functions, data structures, parsing, or dispatch tables can express the behavior. `eval()` and `Function()` introduce dynamic code execution with unusual scope and security characteristics.  
Why: They create code-injection risk, interfere with static analysis and optimization, complicate CSP deployment, and make behavior substantially harder to reason about.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval citeturn796353search1

Name: Defend dynamic property writes against prototype pollution  
Category: Object security  
Impact: High  
Consensus: High  
Description: When property names come from external or untrusted data, validate allowed keys and reject dangerous names such as `__proto__`, `constructor`, and `prototype`. Consider `Map` or null-prototype objects where appropriate.  
Why: Attacker-controlled property paths can mutate prototypes and change behavior throughout an application.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/Security/Attacks/Prototype_pollution citeturn125825search2

Name: Treat HTML string insertion as an injection sink  
Category: DOM security  
Impact: High  
Consensus: High  
Description: Do not put untrusted strings into `innerHTML` or equivalent HTML-parsing sinks. Prefer `textContent` when inserting text, or use an appropriate sanitizer and Trusted Types for intentionally generated HTML.  
Why: HTML parsing can turn attacker-controlled data into executable markup and produce cross-site scripting vulnerabilities.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML citeturn661994search1

Name: Do not use Math.random for security-sensitive randomness  
Category: Cryptographic randomness  
Impact: High  
Consensus: High  
Description: Use Web Crypto facilities such as `crypto.getRandomValues()` or `crypto.randomUUID()` for tokens, secrets, identifiers requiring unpredictability, and other security-sensitive values.  
Why: `Math.random()` is explicitly not cryptographically secure and its output must not be treated as unpredictable against an attacker.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random citeturn233289search1

Name: Check Fetch HTTP status explicitly  
Category: Networking  
Impact: High  
Consensus: High  
Description: After `fetch()`, check `response.ok` or the status code when HTTP errors are failures for your application. Do not assume a rejected promise represents every unsuccessful HTTP request.  
Why: `fetch()` normally resolves for HTTP responses such as 404 or 500 and rejects primarily for network-level failures and related errors.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch citeturn233289search38

Name: Do not leave promises floating  
Category: Promise correctness  
Impact: High  
Consensus: High  
Description: Await, return, or deliberately handle each promise whose completion matters. In promise chains, do not start asynchronous work and then discard its promise unintentionally.  
Why: Floating promises cause race conditions, premature continuation, lost failures, and unhandled rejections.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises citeturn773294search35

Name: Return promises from then callbacks  
Category: Promise chaining  
Impact: High  
Consensus: High  
Description: When a `.then()` callback starts asynchronous work that the next step depends on, return that promise instead of starting it without returning it.  
Why: Returning the promise makes the chain wait for it and propagates its fulfillment or rejection correctly.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises citeturn773294search35

Name: Do not use async callbacks with Array.forEach when you need to wait  
Category: Asynchronous iteration  
Impact: High  
Consensus: High  
Description: `forEach()` does not await promises returned by its callback. Use `for...of` with `await` for sequential work or construct promises and use `Promise.all()` for concurrent work.  
Why: `await array.forEach(async ...)` completes before the asynchronous callbacks finish and can also make error handling misleading.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach citeturn798851search18

Name: Avoid async Promise executors  
Category: Promise construction  
Impact: High  
Consensus: High  
Description: Do not write `new Promise(async (resolve, reject) => ...)`. Prefer an ordinary executor or, usually, make the surrounding function `async` and return its result directly.  
Why: Errors thrown by an async executor are not handled by the `Promise` constructor in the intuitive way, and the pattern often indicates unnecessary promise wrapping.  
Source URL: https://eslint.org/docs/latest/rules/no-async-promise-executor citeturn665234search30

Name: Promise races do not cancel losing operations  
Category: Cancellation and concurrency  
Impact: High  
Consensus: High  
Description: Do not implement a timeout with `Promise.race()` and assume the losing network request or other operation stopped. Cancel the underlying operation explicitly, commonly with `AbortController`.  
Why: Promises have no general cancellation protocol, so losing work can continue consuming resources or causing side effects after the race has settled.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises citeturn773294search7

Name: Avoid cyclic module dependencies that require early binding access  
Category: Module evaluation  
Impact: High  
Consensus: High  
Description: JavaScript modules can be cyclic, but avoid designs in which one side reads the other's binding before it has been initialized. Refactor shared dependencies or defer the access when necessary.  
Why: Module imports are live bindings subject to initialization order and temporal dead zone behavior, so cycles can produce `ReferenceError` depending on evaluation order.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules citeturn472969view3

Name: Do not return, throw, break, or continue from finally  
Category: Control flow  
Impact: High  
Consensus: High  
Description: Avoid control-flow statements inside `finally` that override an earlier return, throw, break, or continue. Use `finally` for cleanup without replacing the pending completion.  
Why: A completion produced by `finally` can silently suppress the value or exception that caused the `finally` block to execute.  
Source URL: https://eslint.org/docs/latest/rules/no-unsafe-finally citeturn214547search12

Name: Keep return and throw values on the same line  
Category: Automatic semicolon insertion  
Impact: High  
Consensus: High  
Description: Write the expression for `return` or `throw` on the same line as the keyword. A newline immediately after `return` triggers automatic semicolon insertion, and a newline after `throw` is invalid.  
Why: Formatting that appears visually harmless can completely change control flow or produce a syntax error.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/return citeturn214547search2

Name: Respect the safe integer range of Number  
Category: Numeric representation  
Impact: High  
Consensus: High  
Description: Do not assume every integer representable by a decimal string can be represented exactly as a JavaScript `Number`. Validate with `Number.isSafeInteger()` or use `BigInt` or strings when exact large integers are required.  
Why: Beyond `Number.MAX_SAFE_INTEGER`, distinct integer values can collapse onto the same floating-point representation.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/isSafeInteger citeturn686639search13

Name: Do not parse exact large integers through JSON Number  
Category: JSON and numeric precision  
Impact: High  
Consensus: High  
Description: If JSON contains integer identifiers or quantities outside JavaScript's safe integer range, do not rely on a normal `JSON.parse()` number followed by a reviver to recover the original value. Preserve such values as strings or another exact representation at the serialization boundary.  
Why: Precision can already be lost while JSON numeric text is converted into a JavaScript `Number`, before a reviver can repair it.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON citeturn846264search18

Name: Escape literal input before embedding it in a regular expression  
Category: Regular-expression construction  
Impact: High  
Consensus: High  
Description: When externally supplied text should be matched literally inside a dynamically constructed regular expression, use `RegExp.escape()` where supported rather than hand-written escaping.  
Why: Regex metacharacters can alter the meaning of the pattern, and correct escaping has edge cases that simple replacement schemes commonly miss.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/escape citeturn682751search0

Name: Avoid catastrophic-backtracking regexes on untrusted input  
Category: Regular-expression performance and security  
Impact: High  
Consensus: High  
Description: Be cautious with ambiguous nested quantifiers, overlapping alternatives, and similar patterns when input size is attacker-controlled or otherwise unbounded. Test worst-case non-matches, not only successful examples.  
Why: Backtracking JavaScript regex engines can take exponential time for some patterns, enabling severe hangs or regular-expression denial of service.  
Source URL: https://v8.dev/blog/non-backtracking-regexp citeturn356618search0

Name: Synchronize SharedArrayBuffer access with Atomics  
Category: Shared-memory concurrency  
Impact: High  
Consensus: High  
Description: When multiple agents or workers coordinate through shared memory, use `Atomics` and an appropriate synchronization design instead of assuming ordinary reads and writes provide safe inter-thread coordination.  
Why: Shared memory introduces genuine data races and memory-ordering concerns that ordinary single-threaded JavaScript code does not have.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Atomics citeturn456575search0

Name: Do not rely on garbage collection for essential cleanup  
Category: Resource lifetime  
Impact: High  
Consensus: High  
Description: Never make correctness depend on `WeakRef` or `FinalizationRegistry` callbacks running promptly, or at all. Close or dispose important external resources deterministically.  
Why: Garbage collection timing is intentionally unspecified, and conforming implementations are not required to invoke finalization callbacks in every situation.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/FinalizationRegistry citeturn714703search0

Name: Avoid implementation-dependent Date parsing  
Category: Date parsing  
Impact: High  
Consensus: High  
Description: Do not feed arbitrary locale-style or otherwise non-standard date strings to `Date.parse()` and assume consistent interpretation. Prefer well-defined ISO-compatible formats or explicit parsing.  
Why: Formats outside the specification's required set may be parsed differently across implementations or fail altogether.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse citeturn596314search2

Name: Do not use local calendar arithmetic as elapsed-time arithmetic  
Category: Date and time-zone behavior  
Impact: High  
Consensus: High  
Description: When exact elapsed durations matter, do not assume adding a local day or manipulating local date fields always changes the timestamp by exactly 24 hours. Use UTC or time-zone-aware duration logic appropriate to the requirement.  
Why: Daylight-saving transitions can make a local calendar day shorter or longer than 24 hours.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/setDate citeturn596314search22

Name: Do not mistake shallow copying for independent object state  
Category: Object copying  
Impact: High  
Consensus: High  
Description: Object spread, array spread, `slice()`, `Object.assign()`, and similar operations copy only one level. Nested objects remain shared unless explicitly cloned or reconstructed.  
Why: Mutating a nested value through the "copy" can unexpectedly mutate the original object and violate isolation assumptions.  
Source URL: https://developer.mozilla.org/en-US/docs/Glossary/Shallow_copy citeturn151948search16

## 2. Medium Impact

Name: Prefer strict equality when coercion is not intentional  
Category: Equality semantics  
Impact: Medium  
Consensus: High  
Description: Prefer `===` and `!==` for ordinary comparisons. Use `==` only when its coercion behavior is deliberate, such as the compact `value == null` check for both `null` and `undefined`.  
Why: Abstract equality can convert operand types using rules that are easy to misread and can produce surprising matches.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Equality_comparisons_and_sameness citeturn853621search3

Name: Use nullish coalescing for nullish defaults  
Category: Coercion and defaults  
Impact: Medium  
Consensus: High  
Description: Use `value ?? fallback` when `0`, `false`, and `""` are valid values. Use `||` only when every falsy value should trigger the fallback.  
Why: `||` treats all falsy values as absent and can silently replace legitimate application data.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Nullish_coalescing citeturn423842search19

Name: Prefer Number.isNaN over global isNaN  
Category: Numeric coercion  
Impact: Medium  
Consensus: High  
Description: Use `Number.isNaN(value)` when asking whether a value is actually the numeric `NaN` value. The global `isNaN()` first coerces its argument to a number.  
Why: Coercion makes values such as non-numeric strings behave differently from a direct `NaN` test.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/isNaN citeturn423842search14

Name: Prefer Number.isFinite over global isFinite  
Category: Numeric coercion  
Impact: Medium  
Consensus: High  
Description: Use `Number.isFinite()` when only finite numeric values should pass. Global `isFinite()` converts non-number arguments first.  
Why: Inputs such as numeric strings can otherwise be accepted unintentionally.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/isFinite citeturn686639search14

Name: Do not construct Boolean wrapper objects  
Category: Primitive wrappers  
Impact: Medium  
Consensus: High  
Description: Use Boolean primitives and `Boolean(value)` when explicit conversion is needed. Avoid `new Boolean(value)`.  
Why: Every Boolean object is truthy, including `new Boolean(false)`, producing counterintuitive conditional behavior.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Boolean citeturn606879search0

Name: Remember that typeof null is "object"  
Category: Type inspection  
Impact: Medium  
Consensus: High  
Description: Do not use `typeof x === "object"` alone when `null` must be excluded. Add an explicit null check.  
Why: `typeof null` is the historical value `"object"`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/typeof citeturn661727search2

Name: typeof is not universally safe before declaration  
Category: Temporal dead zone  
Impact: Medium  
Consensus: High  
Description: `typeof undeclaredName` returns `"undefined"`, but applying `typeof` to a `let`, `const`, or class binding that is still in its temporal dead zone throws `ReferenceError`.  
Why: Code that treats `typeof` as an unconditional existence test can still fail when a lexical binding exists but is not initialized.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/typeof citeturn661727search2

Name: Default parameters and destructuring defaults do not replace null  
Category: Default-value semantics  
Impact: Medium  
Consensus: High  
Description: JavaScript parameter and destructuring defaults activate for `undefined`, not for `null`. Normalize null explicitly when null should also mean "missing."  
Why: Assuming defaults handle both nullish values can leave `null` flowing into code that expects the default.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Default_parameters citeturn509753search7

Name: const does not make objects immutable  
Category: Binding semantics  
Impact: Medium  
Consensus: High  
Description: `const` prevents reassignment of the binding but does not freeze the referenced array or object. Use immutability techniques separately when mutation must be prevented.  
Why: Treating `const` as deep immutability creates false assumptions about shared state.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/const citeturn228042search20

Name: Prefer block-scoped bindings over var for local state  
Category: Binding and scope  
Impact: Medium  
Consensus: High  
Description: Prefer `const` by default and `let` for reassigned local bindings. `var` is function-scoped rather than block-scoped and has different hoisting and global-script behavior.  
Why: Block scope reduces accidental leakage and classic loop/callback capture errors.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/let citeturn773294search13

Name: Remember that this is determined by invocation  
Category: Function invocation  
Impact: Medium  
Consensus: High  
Description: For ordinary functions, `this` generally depends on how the function is called, not where it was defined or which object originally stored it.  
Why: Passing or extracting a method can change its receiver and cause it to operate on the wrong object or on `undefined`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/this citeturn773294search0

Name: Use arrow functions only when lexical this is desired  
Category: Function invocation  
Impact: Medium  
Consensus: High  
Description: Arrow functions do not define their own `this`, `arguments`, or constructor behavior. Use an ordinary function when call-site `this` or construction is part of the contract.  
Why: An arrow used where a dynamic receiver is expected cannot be repaired with `call()`, `apply()`, or `bind()` in the normal way.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions citeturn228042search10

Name: Bind or wrap methods when passing them as callbacks  
Category: Function invocation  
Impact: Medium  
Consensus: High  
Description: If a method depends on `this`, do not pass the bare method reference unless the receiving API supplies the intended receiver. Bind it or use a wrapper.  
Why: The later callback invocation may not preserve the original object as `this`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/this citeturn773294search0

Name: Class fields do not behave exactly like constructor assignments  
Category: Class field semantics  
Impact: Medium  
Consensus: High  
Description: Public class fields are defined using field-definition semantics rather than ordinary assignment semantics. In particular, defining a derived field does not invoke an inherited setter the same way `this.x = value` does.  
Why: Refactoring constructor assignments into class fields can change behavior when inheritance or accessors are involved.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes/Public_class_fields citeturn228042search7

Name: Call super before using this in derived constructors  
Category: Class initialization  
Impact: Medium  
Consensus: High  
Description: A derived class constructor must call `super()` before accessing `this` and normally before returning.  
Why: The base constructor is responsible for initializing the instance used by the derived constructor.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Errors/Super_not_called citeturn228042search15

Name: Private fields are lexically private, not conventionally protected  
Category: Class encapsulation  
Impact: Medium  
Consensus: High  
Description: JavaScript `#private` fields can only be referenced from the class body that declares them. A subclass cannot directly access its parent's private fields.  
Why: Designing inheritance around direct private-field access leads to invalid code rather than protected-style access.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_classes citeturn228042search11

Name: Make getters return a value on every intended path  
Category: Accessors  
Impact: Medium  
Consensus: High  
Description: Treat a getter like a value-producing function and ensure relevant paths return the expected value rather than falling through unintentionally.  
Why: Falling through returns `undefined`, often hiding a control-flow mistake behind ordinary property access syntax.  
Source URL: https://eslint.org/docs/latest/rules/getter-return citeturn387561search41

Name: Avoid explicit constructor return values  
Category: Constructor semantics  
Impact: Medium  
Consensus: High  
Description: Constructors should normally initialize `this` and return implicitly. JavaScript has unusual rules under which returned objects can replace the constructed instance, especially in derived classes.  
Why: Explicit constructor returns make object identity and initialization substantially harder to reason about.  
Source URL: https://eslint.org/docs/latest/rules/no-constructor-return citeturn387561search40

Name: Do not use for...in as an array iterator  
Category: Property enumeration  
Impact: Medium  
Consensus: High  
Description: Use `for...of`, array methods, or indexed iteration for array values. `for...in` enumerates string property names and includes enumerable properties from the prototype chain.  
Why: Added properties, inheritance, and property-order semantics make it a poor substitute for array iteration.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...in citeturn714703search18

Name: Use Object.hasOwn for own-property tests  
Category: Property ownership  
Impact: Medium  
Consensus: High  
Description: Prefer `Object.hasOwn(obj, key)` when checking whether an object directly owns a property. Do not substitute `key in obj`, which also checks prototypes.  
Why: Prototype properties can otherwise be mistaken for data stored directly on the object.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/hasOwn citeturn151948search14

Name: Plain-object keys are strings or symbols  
Category: Property-key semantics  
Impact: Medium  
Consensus: High  
Description: Objects do not preserve arbitrary object identity as keys. Non-symbol property keys are converted to strings, so unrelated objects can collapse to the same property name. Use `Map` when arbitrary values are keys.  
Why: Object-to-string coercion can produce silent key collisions such as multiple objects mapping to `"[object Object]"`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Property_accessors citeturn125825search34

Name: Know what Object.keys omits  
Category: Property enumeration  
Impact: Medium  
Consensus: High  
Description: `Object.keys()` returns only own, enumerable, string-keyed properties. Use the appropriate reflection API if non-enumerable properties or symbols matter.  
Why: Treating it as a complete inventory of an object can silently omit relevant state.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/keys citeturn714703search1

Name: Object.defineProperty descriptor defaults are false  
Category: Property descriptors  
Impact: Medium  
Consensus: High  
Description: When creating a property with `Object.defineProperty()`, omitted descriptor flags such as `writable`, `enumerable`, and `configurable` default to `false`, unlike ordinary assignment-created properties.  
Why: A seemingly ordinary property can unexpectedly become hidden, read-only, or non-configurable.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty citeturn714703search42

Name: Avoid __proto__ mutation  
Category: Prototype semantics  
Impact: Medium  
Consensus: High  
Description: Do not use the deprecated `obj.__proto__` accessor for normal prototype management. Prefer explicit object creation or, when truly necessary, `Object.getPrototypeOf()` and `Object.setPrototypeOf()`.  
Why: Prototype mutation is easy to misuse, has security implications, and can interfere with engine optimization.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/proto citeturn509753search27

Name: Object.assign invokes getters and setters and can partially mutate  
Category: Object copying  
Impact: Medium  
Consensus: High  
Description: `Object.assign()` reads source properties through `[[Get]]`, writes target properties through `[[Set]]`, and mutates its target as it proceeds. If a later assignment throws, earlier changes remain.  
Why: It is not an atomic descriptor-copying operation and can trigger arbitrary accessor behavior.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/assign citeturn773294search3

Name: Object.freeze is shallow  
Category: Immutability  
Impact: Medium  
Consensus: High  
Description: `Object.freeze()` prevents changes to the object's own immediate properties, but referenced nested objects remain mutable unless frozen separately.  
Why: Assuming deep immutability can allow state changes through nested references despite a frozen outer object.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/freeze citeturn661727search1

Name: Do not use instanceof for cross-realm Array detection  
Category: Runtime type identification  
Impact: Medium  
Consensus: High  
Description: Use `Array.isArray(value)` rather than `value instanceof Array` when values can cross realms such as windows or frames.  
Why: Each realm has its own `Array` constructor and prototype, so a genuine array from another realm can fail the local `instanceof Array` test.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/isArray citeturn661727search0

Name: Treat Proxy traps as semantic hooks, not transparent interception  
Category: Metaprogramming  
Impact: Medium  
Consensus: High  
Description: Proxy traps must respect ECMAScript invariants, and forwarding through `Reflect` does not automatically make every trap harmless. Be especially careful about receiver handling and recursive proxy access.  
Why: Incorrect traps can throw unexpectedly, violate object invariants, or recurse indefinitely.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy citeturn168023search2

Name: Use Map.has when undefined is a valid Map value  
Category: Keyed collections  
Impact: Medium  
Consensus: High  
Description: `map.get(key)` returns `undefined` both when the key is absent and when it is explicitly mapped to `undefined`. Use `map.has(key)` when that distinction matters.  
Why: Testing only the result of `get()` can confuse missing entries with stored values.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map/get citeturn582868search1

Name: Map object keys use identity, not structural equality  
Category: Keyed collections  
Impact: Medium  
Consensus: High  
Description: Two separately created but structurally identical objects are different `Map` keys. Preserve the original object identity or use a canonical primitive key when structural identity is intended.  
Why: Reconstructing an equivalent object will not retrieve a value stored under another object reference.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map citeturn853621search6

Name: Avoid accidental sparse arrays  
Category: Array structure  
Impact: Medium  
Consensus: High  
Description: Distinguish an actual element whose value is `undefined` from a missing array slot. Avoid creating holes unless sparse-array semantics are intentional.  
Why: Different array operations treat holes differently, making seemingly equivalent iteration and transformation code behave inconsistently.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Indexed_collections citeturn853621search5

Name: Do not use delete to remove array elements  
Category: Array mutation  
Impact: Medium  
Consensus: High  
Description: Use `splice()` or an immutable reconstruction when removing an indexed array element. `delete array[i]` removes the property but leaves the length unchanged and creates a hole.  
Why: The resulting sparse array can behave unexpectedly in iteration and array methods.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/delete citeturn853621search8

Name: Beware the single-number Array constructor  
Category: Array construction  
Impact: Medium  
Consensus: High  
Description: `Array(5)` creates an array with length 5 and no actual elements, not `[5]`. Use `[5]` for one value or `Array.of(5)` when constructor-style creation is required.  
Why: The special one-number overload creates sparse-array behavior that is easy to mistake for initialized storage.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Array citeturn840648search4

Name: Changing array length can delete data or create holes  
Category: Array structure  
Impact: Medium  
Consensus: High  
Description: Assigning a smaller `length` deletes elements beyond the new length. Increasing it creates empty slots rather than initialized `undefined` elements.  
Why: Treating `length` as ordinary metadata can unexpectedly destroy values or create sparse arrays.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/length citeturn582868search0

Name: Array.fill repeats object references  
Category: Array initialization  
Impact: Medium  
Consensus: High  
Description: `Array(n).fill({})` stores the same object reference in every position. Use a factory pattern such as `Array.from({length: n}, () => ({}))` when distinct objects are required.  
Why: Mutating one supposedly independent element will mutate the object observed through every slot.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/fill citeturn840648search12

Name: Supply a numeric comparator when sorting numbers  
Category: Array sorting  
Impact: Medium  
Consensus: High  
Description: `array.sort()` without a comparator sorts values by their string representations rather than numerically. Use `(a, b) => a - b` or another intentional comparator for numeric order.  
Why: Values such as `10` and `2` otherwise sort lexicographically.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort citeturn840648search2

Name: Remember that sort mutates the original array  
Category: Array mutation  
Impact: Medium  
Consensus: High  
Description: `sort()` rearranges the array in place. Use `toSorted()` or an explicit copy when callers expect the original ordering to remain unchanged.  
Why: Hidden mutation can corrupt shared state or make later code observe a different order.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort citeturn840648search2

Name: Write well-formed sort comparators  
Category: Array sorting  
Impact: Medium  
Consensus: High  
Description: Comparators should obey consistent ordering rules including anti-symmetry and transitivity. Do not return only `0` and `1` for a normal ascending comparison.  
Why: Ill-formed comparators can produce implementation-dependent or inconsistent sort results.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort citeturn840648search2

Name: Do not pass parseInt directly to map  
Category: Callback signatures  
Impact: Medium  
Consensus: High  
Description: Use `array.map(x => parseInt(x, 10))` rather than `array.map(parseInt)`. `map` passes the element index as the callback's second argument, which `parseInt` interprets as its radix.  
Why: The signatures happen to fit syntactically but have incompatible meanings.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map citeturn582868search8

Name: Do not use map when you ignore its returned array  
Category: Collection transformation  
Impact: Medium  
Consensus: High  
Description: Use `map()` when transforming each element into a new array. If the return values are deliberately discarded, use a loop or `forEach()` as appropriate.  
Why: Ignoring the result allocates an unnecessary array and obscures that the real purpose is side effects.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map citeturn840648search14

Name: Give reduce an initial value when emptiness is possible  
Category: Array reduction  
Impact: Medium  
Consensus: High  
Description: Supply an explicit initial accumulator unless the input is guaranteed non-empty and the first element is intentionally the accumulator.  
Why: Calling `reduce()` without an initial value on an empty array throws `TypeError`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Errors/Reduce_of_empty_array_with_no_initial_value citeturn840648search0

Name: Avoid repeatedly copying a growing reduce accumulator  
Category: Algorithmic performance  
Impact: Medium  
Consensus: High  
Description: Be cautious with reducers that create a fresh object or array by spreading the entire accumulator on every iteration. Mutate a local accumulator or use a more suitable construction when immutability is not required at each intermediate step.  
Why: Repeatedly copying an ever-growing accumulator can turn a linear operation into quadratic work.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reduce citeturn840648search3

Name: Do not use forEach when you need early exit  
Category: Iteration control flow  
Impact: Medium  
Consensus: High  
Description: `forEach()` cannot be stopped with a normal `break`. Use `for...of`, `some()`, `every()`, `find()`, or another operation whose control semantics match the task.  
Why: Trying to force early-exit logic into `forEach()` complicates control flow and often produces incorrect assumptions.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach citeturn798851search18

Name: Avoid structural mutation during iterative array methods  
Category: Iteration semantics  
Impact: Medium  
Consensus: High  
Description: Do not casually add, remove, or reorder array elements while `some()`, `forEach()`, and similar methods are traversing the same array. Their iteration range and treatment of changed elements follow specific snapshot-like rules.  
Why: Mid-iteration mutation can cause elements to be skipped, revisited differently, or ignored.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/some citeturn582868search4

Name: Use includes when searching for NaN  
Category: Equality in collections  
Impact: Medium  
Consensus: High  
Description: `Array.prototype.includes()` uses SameValueZero equality and can find `NaN`; `indexOf()` cannot.  
Why: `NaN !== NaN`, so search operations based on strict equality cannot locate it.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/includes citeturn853621search2

Name: Do not use bitwise operators as general numeric truncation  
Category: Numeric representation  
Impact: Medium  
Consensus: High  
Description: Avoid tricks such as `x | 0` or `x << 0` when general JavaScript numbers are intended. Use `Math.trunc()` for truncation.  
Why: Most bitwise operations convert values to 32-bit integers, silently discarding higher bits.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Left_shift citeturn423842search13

Name: Do not compare calculated floating-point values with naive exact equality  
Category: Floating-point arithmetic  
Impact: Medium  
Consensus: High  
Description: When calculations can introduce rounding error, compare using a tolerance appropriate to the magnitude and domain rather than assuming exact decimal arithmetic.  
Why: JavaScript `Number` uses binary IEEE-754 floating point, so many decimal fractions cannot be represented exactly.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/EPSILON citeturn423842search1

Name: Treat parseInt as a prefix parser, not strict numeric validation  
Category: Numeric parsing  
Impact: Medium  
Consensus: High  
Description: Use `parseInt()` when parsing an integer prefix is actually intended, specify the radix when appropriate, and validate the whole string separately when strict syntax is required.  
Why: `parseInt()` can stop at the first invalid character and still return a number.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/parseInt citeturn423842search4

Name: Do not mix BigInt and Number arithmetic implicitly  
Category: Numeric representation  
Impact: Medium  
Consensus: High  
Description: Convert deliberately before combining `BigInt` and `Number` values, taking precision requirements into account. Most arithmetic operators do not implicitly combine them.  
Why: Mixed arithmetic generally throws instead of coercing automatically, while converting a large BigInt to Number can lose precision.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Errors/Cant_convert_BigInt_to_number citeturn686639search5

Name: Understand TypedArray numeric coercion  
Category: Binary data  
Impact: Medium  
Consensus: High  
Description: Typed arrays store values according to their fixed-width element type. Values may be truncated, wrapped, clamped, or rounded rather than preserved like ordinary JavaScript numbers.  
Why: Assigning arbitrary numbers to a typed array can silently produce different stored values.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/TypedArray citeturn994447search2

Name: Specify endianness explicitly with DataView  
Category: Binary data  
Impact: Medium  
Consensus: High  
Description: When reading or writing externally defined binary formats, use `DataView` and specify the expected byte order rather than relying on the platform's native typed-array representation.  
Why: Binary protocols define byte order independently of the host machine, and `DataView` defaults to big-endian when its little-endian argument is omitted.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView citeturn456575search5

Name: Remember that transferring an ArrayBuffer detaches the original  
Category: Binary data ownership  
Impact: Medium  
Consensus: High  
Description: After an `ArrayBuffer` is transferred, do not continue using the original buffer or its views as if they still own the memory.  
Why: Transfer moves ownership and leaves the original buffer detached.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer citeturn994447search5

Name: Do not equate string length with user-perceived character count  
Category: Unicode text  
Impact: Medium  
Consensus: High  
Description: JavaScript strings are sequences of UTF-16 code units. `length`, indexing, and some slicing operations therefore do not necessarily correspond to Unicode code points or grapheme clusters.  
Why: Characters outside the BMP and multi-code-point graphemes can be split incorrectly.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String citeturn567504search10

Name: Normalize Unicode when canonical equivalence matters  
Category: Unicode text  
Impact: Medium  
Consensus: High  
Description: Use `String.prototype.normalize()` when text from different sources must compare according to Unicode canonical equivalence rather than raw code-unit identity.  
Why: Visually identical strings can have different underlying Unicode sequences and compare unequal.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/normalize citeturn567504search7

Name: Handle lone surrogates before URI encoding when necessary  
Category: Unicode and encoding  
Impact: Medium  
Consensus: High  
Description: Be aware that `encodeURI()` and `encodeURIComponent()` can throw on lone UTF-16 surrogates. `String.prototype.toWellFormed()` can normalize malformed UTF-16 when that behavior is appropriate.  
Why: Arbitrary string data can otherwise turn URI construction into an unexpected exception path.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/toWellFormed citeturn567504search16

Name: Do not reuse global or sticky regexes without accounting for lastIndex  
Category: Regular-expression state  
Impact: Medium  
Consensus: High  
Description: Regexes with `g` or `y` are stateful through `lastIndex`. Repeated calls to `test()` or `exec()` on the same object can therefore produce different results for identical input.  
Why: Hidden mutable regex state is a common cause of alternating or apparently nondeterministic matches.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/test citeturn567504search12

Name: Use Unicode-aware regex semantics for Unicode text  
Category: Regular expressions and Unicode  
Impact: Medium  
Consensus: High  
Description: Use the `u` or, where appropriate, `v` flag when patterns are intended to operate on Unicode code points or Unicode properties rather than legacy UTF-16 behavior. Do not assume `\w` means every Unicode letter.  
Why: Legacy regex semantics can split surrogate pairs and use ASCII-oriented character classes that do not match international text as expected.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/unicode citeturn567504search5

Name: Remember that Date months are zero-based  
Category: Date API semantics  
Impact: Medium  
Consensus: High  
Description: Numeric month values in legacy `Date` constructors and methods such as `getMonth()` are zero-based.  
Why: Treating January as 1 rather than 0 creates classic off-by-one date bugs.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/getMonth citeturn596314search41

Name: Account for Date setter overflow  
Category: Date API semantics  
Impact: Medium  
Consensus: High  
Description: Methods such as `setMonth()` normalize out-of-range component values rather than simply replacing one calendar field independently.  
Why: Changing the month of a date near the end of a month can spill into a later month and produce unexpected calendar results.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/setMonth citeturn596314search32

Name: Consider Temporal for complex date and time-zone logic  
Category: Date and time modeling  
Impact: Medium  
Consensus: Medium  
Description: Where runtime support permits, consider Temporal rather than forcing complex calendar, duration, instant, and time-zone requirements through legacy `Date`.  
Why: Temporal exposes these concepts separately instead of overloading them onto one mutable, historically constrained API.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Temporal citeturn596314search8

Name: Do not compare localized output to hardcoded strings  
Category: Internationalization  
Impact: Medium  
Consensus: High  
Description: Treat `Intl` and `toLocaleString()` output as presentation text rather than a stable machine-readable format.  
Why: Specifications intentionally permit output variations between implementations even for the same locale.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Internationalization citeturn714703search19

Name: Throw Error objects rather than strings or primitive values  
Category: Error handling  
Impact: Medium  
Consensus: High  
Description: Throw `Error` instances or appropriate subclasses for operational failures instead of strings, numbers, or arbitrary primitives.  
Why: Error objects carry stack information, names, messages, causes, and type identity useful for debugging and selective handling.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Control_flow_and_error_handling citeturn168023search10

Name: Preserve error causality when wrapping errors  
Category: Error handling  
Impact: Medium  
Consensus: High  
Description: When converting a lower-level failure into a higher-level `Error`, preserve the original with the `cause` option when it provides useful diagnostic context.  
Why: Otherwise the original failure and stack context can be lost behind the wrapper.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error/Error citeturn168023search9

Name: Catch errors you can handle and rethrow unexpected ones  
Category: Error handling  
Impact: Medium  
Consensus: High  
Description: Avoid broad catch blocks that silently turn every exception into the same fallback. Handle expected failures and rethrow exceptions the layer cannot meaningfully resolve.  
Why: Swallowing unexpected programming errors makes failures invisible and complicates diagnosis.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/try...catch citeturn168023search7

Name: Choose Promise.all only when fail-fast semantics are appropriate  
Category: Promise composition  
Impact: Medium  
Consensus: High  
Description: Use `Promise.all()` when all operations must succeed and an early rejection should reject the aggregate. Use `Promise.allSettled()` when every outcome must be observed.  
Why: Using the wrong combinator can stop result processing at the first rejection or force unnecessary manual error wrapping.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all citeturn861492search3

Name: Distinguish Promise.any from Promise.race  
Category: Promise composition  
Impact: Medium  
Consensus: High  
Description: `Promise.race()` adopts the first settlement, whether fulfillment or rejection. `Promise.any()` waits for the first fulfillment and only rejects if all inputs reject.  
Why: They encode materially different failure policies despite both appearing to choose a "first" result.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/any citeturn773294search32

Name: Run independent asynchronous operations concurrently when appropriate  
Category: Asynchronous performance  
Impact: Medium  
Consensus: High  
Description: If operations are independent, start them before awaiting their combined result rather than serially awaiting each operation. `Promise.all()` is often appropriate.  
Why: Serial awaits add otherwise unnecessary wall-clock latency.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function citeturn713370view3

Name: Promise.finally can replace the original failure  
Category: Promise error propagation  
Impact: Medium  
Consensus: High  
Description: Use `.finally()` for cleanup that should normally preserve the prior outcome. If the callback throws or returns a rejected promise, that new failure becomes the chain's rejection.  
Why: Cleanup code can accidentally hide the error or successful value that originally settled the promise.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/finally citeturn861492search0

Name: Do not create unbounded recursive microtask chains  
Category: Event-loop scheduling  
Impact: Medium  
Consensus: High  
Description: Use `queueMicrotask()` and promise continuations carefully when callbacks can continually enqueue more microtasks. Yield to tasks when other event-loop work must make progress.  
Why: The microtask queue is drained before the next task, so continually adding microtasks can starve rendering, timers, and input processing.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/HTML_DOM_API/Microtask_guide citeturn356618search40

Name: Keep APIs consistently synchronous or asynchronous  
Category: Scheduling contracts  
Impact: Medium  
Consensus: High  
Description: Avoid APIs that invoke a callback synchronously on one path and asynchronously on another. Normalize their scheduling contract.  
Why: Mixed timing makes ordering dependent on internal branches and creates race-prone "Zalgo" behavior.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises citeturn713370view0

Name: Use top-level await deliberately  
Category: Module evaluation  
Impact: Medium  
Consensus: High  
Description: Top-level `await` is useful but causes modules that depend on the awaiting module to wait for its asynchronous evaluation. Avoid putting slow or unnecessary initialization on critical import paths.  
Why: A single module can delay evaluation of a wider portion of the module graph.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules citeturn472969view0

Name: Imported bindings are read-only live bindings  
Category: Module bindings  
Impact: Medium  
Consensus: High  
Description: An imported name reflects updates made by its exporting module but cannot be reassigned by the importing module. Do not think of named imports as copied local values.  
Why: Their live-binding behavior affects state sharing and cyclic-module evaluation.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import citeturn472969view2

Name: Use defer or modules instead of parser-blocking classic scripts when appropriate  
Category: Script loading  
Impact: Medium  
Consensus: High  
Description: Avoid unintentionally blocking HTML parsing with ordinary classic scripts. Use `defer` or `type="module"` when execution does not need to stop parsing at that exact point.  
Why: Parser-blocking scripts delay document construction and can degrade loading behavior.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/script citeturn247883search15

Name: Use globalThis for portable access to the global object  
Category: Runtime portability  
Impact: Medium  
Consensus: High  
Description: Prefer `globalThis` when code genuinely needs the global object across windows, workers, and other JavaScript hosts rather than assuming `window`, `self`, or `global`.  
Why: Host-specific global names do not exist in every JavaScript environment.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/globalThis citeturn773294search1

Name: Avoid top-level var in classic browser scripts  
Category: Global scope  
Impact: Medium  
Consensus: High  
Description: Top-level `var` declarations in classic scripts create properties on the global object. Prefer module scope or lexical declarations when globals are not intentional.  
Why: Global-object properties increase collision risk and have different configurability and deletion behavior from normal lexical bindings.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/var citeturn773294search4

Name: Use structuredClone rather than JSON round-tripping for general deep cloning  
Category: Serialization and cloning  
Impact: Medium  
Consensus: High  
Description: When the requirement is to clone supported JavaScript data rather than serialize JSON, prefer `structuredClone()` over `JSON.parse(JSON.stringify(value))`.  
Why: Structured cloning supports cycles and many data types that JSON either rejects, transforms, or silently drops.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Window/structuredClone citeturn846264search5

Name: Know the limits of structured cloning  
Category: Serialization and cloning  
Impact: Medium  
Consensus: High  
Description: Structured cloning is not a complete semantic copy of arbitrary JavaScript objects. Functions and DOM nodes cannot be cloned, property descriptors and accessors are not preserved, and some object-specific metadata is lost.  
Why: Cloning an object can therefore change how it behaves even if its basic data appears intact.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Structured_clone_algorithm citeturn846264search0

Name: JSON.stringify silently transforms or removes some values  
Category: JSON serialization  
Impact: Medium  
Consensus: High  
Description: Understand how `undefined`, functions, and symbols are handled by `JSON.stringify()`: object properties may be omitted while corresponding array positions become `null`.  
Why: JSON serialization is lossy for values outside the JSON data model.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify citeturn846264search1

Name: Map and Set do not serialize meaningfully with plain JSON.stringify  
Category: JSON serialization  
Impact: Medium  
Consensus: High  
Description: Do not expect ordinary `JSON.stringify()` to preserve the contents of `Map` and `Set`; provide explicit serialization when these structures cross a JSON boundary.  
Why: Their data is not represented as ordinary enumerable object properties, so the default result is generally `{}`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify citeturn846264search1

Name: BigInt is not supported by default JSON serialization  
Category: JSON serialization  
Impact: Medium  
Consensus: High  
Description: Define an explicit representation for BigInt values before JSON serialization, commonly a string or application-defined encoding.  
Why: `JSON.stringify()` throws when it encounters a BigInt without custom serialization behavior.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify citeturn846264search1

Name: Fetch request and response bodies are one-shot streams  
Category: Fetch and streams  
Impact: Medium  
Consensus: High  
Description: Do not expect to consume the same request or response body multiple times. Clone the request or response before consumption when genuine multiple reads are required.  
Why: Reading the body disturbs the stream and sets `bodyUsed`; subsequent consumption fails.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Response/clone citeturn714703search7

Name: Be careful cloning large streaming responses  
Category: Fetch and streams  
Impact: Medium  
Consensus: High  
Description: `Response.clone()` is useful for multiple consumers, but avoid allowing one branch to consume far more slowly than the other for large bodies.  
Why: Stream teeing can buffer unread data for the slower consumer without a fixed upper bound.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Response/clone citeturn846264search10

Name: Do not set multipart Content-Type manually for FormData  
Category: HTTP request construction  
Impact: Medium  
Consensus: High  
Description: When passing `FormData` directly to `fetch()`, let the browser generate the `Content-Type` header rather than setting `multipart/form-data` yourself.  
Why: The browser must include the generated multipart boundary in the header; manually setting the header can omit or mismatch it.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest_API/Using_FormData_Objects citeturn233289search0

Name: no-cors does not bypass CORS  
Category: Browser networking  
Impact: Medium  
Consensus: High  
Description: Do not use `mode: "no-cors"` as a way to gain normal script access to a cross-origin response. It produces an opaque response with heavily restricted visibility.  
Why: Opaque responses expose status `0`, no usable response headers, and no readable body to the calling JavaScript.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch citeturn233289search38

Name: Treat cross-origin credential inclusion as a security decision  
Category: Browser networking security  
Impact: Medium  
Consensus: High  
Description: Set Fetch `credentials` deliberately, particularly for cross-origin requests, and pair it with correct server-side CORS and CSRF protections.  
Why: Credentials change what authentication information and cookies are transmitted and can affect CSRF exposure.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch citeturn233289search18

Name: Use URL instead of hand-parsing URLs  
Category: URL handling  
Impact: Medium  
Consensus: High  
Description: Prefer the `URL` and `URLSearchParams` APIs to splitting, concatenating, or manually decoding URLs.  
Why: URL syntax includes escaping, relative resolution, origins, query semantics, fragments, and other cases that naive string manipulation commonly mishandles.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/URL_API citeturn194046search14

Name: Preserve literal plus signs in URLSearchParams deliberately  
Category: URL query encoding  
Impact: Medium  
Consensus: High  
Description: Do not interpolate raw encoded data containing `+` into a query string and then expect `new URLSearchParams(string)` to preserve it. Use parameter APIs such as `append()` or encode appropriately.  
Why: URL-encoded form semantics interpret `+` in parsed query strings as a space.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams citeturn682751search1

Name: Distinguish encodeURI from encodeURIComponent  
Category: URL encoding  
Impact: Medium  
Consensus: High  
Description: Use `encodeURI()` for an entire URI only when its structural delimiters should remain meaningful. Use `encodeURIComponent()` for an individual component such as a parameter value.  
Why: The two functions deliberately escape different character sets, and using the wrong one can let data characters become URL syntax.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURI citeturn682751search36

Name: Do not assume decodeURIComponent accepts arbitrary input  
Category: URL encoding  
Impact: Medium  
Consensus: High  
Description: Handle malformed percent-encoded input when decoding externally supplied strings and remember that `decodeURIComponent()` itself does not translate `+` into a space.  
Why: Invalid escape sequences can throw `URIError`, while form-style plus handling is a separate convention.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/decodeURIComponent citeturn194046search19

Name: Avoid heavy synchronous Web Storage work  
Category: Client-side storage  
Impact: Medium  
Consensus: High  
Description: Keep `localStorage` and `sessionStorage` operations small and infrequent when responsiveness matters. Use asynchronous storage mechanisms for larger workloads.  
Why: Web Storage operations are synchronous and therefore block JavaScript execution while they run.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API citeturn194046search2

Name: Prefer Web Storage methods over property syntax  
Category: Client-side storage  
Impact: Medium  
Consensus: High  
Description: Use `getItem()`, `setItem()`, `removeItem()`, and related APIs rather than treating the storage object as an arbitrary JavaScript object.  
Why: Property-style access can collide with built-in members and makes storage behavior less explicit.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API/Using_the_Web_Storage_API citeturn194046search6

Name: Distinguish live and static DOM collections  
Category: DOM collections  
Impact: Medium  
Consensus: High  
Description: Know whether a DOM query returns a collection that updates as the document changes. `querySelectorAll()` returns a static `NodeList`, while several older DOM collection APIs are live.  
Why: Mutating the DOM while traversing a live collection can change the collection underneath the iteration.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/NodeList citeturn661994search8

Name: Escape dynamic values used in CSS selectors  
Category: DOM querying  
Impact: Medium  
Consensus: High  
Description: When constructing a selector from an arbitrary ID or other literal CSS value, use `CSS.escape()` where needed rather than directly concatenating the string.  
Why: Valid HTML identifiers are not necessarily valid unescaped CSS selector fragments.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Element/querySelectorAll citeturn661994search6

Name: Distinguish event.target from event.currentTarget  
Category: DOM events  
Impact: Medium  
Consensus: High  
Description: Use `target` for the object where the event originated and `currentTarget` for the object whose listener is currently running.  
Why: Bubbling and capturing mean these values commonly differ, especially with event delegation.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Event/currentTarget citeturn682751search3

Name: Do not call preventDefault from a passive listener  
Category: DOM events  
Impact: Medium  
Consensus: High  
Description: If a listener must cancel the browser's default action, ensure it is not registered as passive.  
Why: `preventDefault()` from a passive listener has no effect.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener citeturn574369search0

Name: stopPropagation does not prevent the default action  
Category: DOM events  
Impact: Medium  
Consensus: High  
Description: Use `preventDefault()` for canceling a cancelable default browser action. Use `stopPropagation()` only when propagation itself should stop.  
Why: Stopping propagation does not cancel actions such as following a link or submitting a form.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Event/stopPropagation citeturn574369search12

Name: Preserve listener identity when removing event listeners  
Category: DOM event lifetime  
Impact: Medium  
Consensus: High  
Description: Keep a reference to listeners that will later be removed, and match the relevant capture option. Alternatively, manage listener lifetime with an `AbortSignal`.  
Why: A newly created function that happens to contain the same code is not the same listener object and will not remove the original registration.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/removeEventListener citeturn661994search2

Name: Repeated anonymous event listeners are distinct registrations  
Category: DOM event lifetime  
Impact: Medium  
Consensus: High  
Description: Do not repeatedly call `addEventListener()` with newly created anonymous functions when you intend them to represent one reusable listener.  
Why: Identical-looking anonymous functions are separate function objects and can accumulate listeners and retained state.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener citeturn574369search0

Name: dataset values are strings  
Category: DOM data attributes  
Impact: Medium  
Consensus: High  
Description: Treat `element.dataset` as a string-backed interface and parse values explicitly when numbers, booleans, nulls, or structured data are intended. Delete a property to remove the corresponding attribute.  
Why: Assignments are converted to strings, so assigning `null`, for example, produces the text `"null"`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset citeturn574369search2

Name: Boolean HTML attributes are controlled by presence  
Category: DOM attributes  
Impact: Medium  
Consensus: High  
Description: For Boolean attributes, remove the attribute to represent false rather than setting its string value to `"false"`.  
Why: Presence generally means true regardless of the textual attribute value.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Element/setAttribute citeturn574369search3

Name: Prefer feature detection to user-agent sniffing  
Category: Platform compatibility  
Impact: Medium  
Consensus: High  
Description: Detect the API or capability actually required rather than branching primarily on the browser's user-agent string.  
Why: User agents can be spoofed, change over time, and fail to correspond cleanly to feature availability.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Browser_detection_using_the_user_agent citeturn228042search21

Name: Use requestAnimationFrame for JavaScript-driven animation  
Category: Rendering and scheduling  
Impact: Medium  
Consensus: High  
Description: Prefer `requestAnimationFrame()` to fixed `setInterval()` loops for browser rendering and animation work.  
Why: It lets the browser align callbacks with repaint scheduling and pause them in many non-visible contexts.  
Source URL: https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Performance/JavaScript citeturn356618search2

Name: Base animation progress on the requestAnimationFrame timestamp  
Category: Rendering and scheduling  
Impact: Medium  
Consensus: High  
Description: Calculate animation movement from elapsed time instead of assuming every frame lasts 16.67 ms.  
Why: Displays commonly use refresh rates other than 60 Hz, and frame delivery can vary.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/window/requestAnimationFrame citeturn356618search9

Name: Do not treat timer delays as exact schedules  
Category: Timers  
Impact: Medium  
Consensus: High  
Description: Treat `setTimeout()` and `setInterval()` delays as minimum scheduling requests rather than real-time guarantees.  
Why: Event-loop load, throttling, nesting rules, and browser policies can cause callbacks to run later than requested.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Window/setTimeout citeturn194046search4

Name: Prefer recursive setTimeout when interval work may overrun  
Category: Timers  
Impact: Medium  
Consensus: High  
Description: When each iteration must finish before the next one starts, schedule the next `setTimeout()` after the current work completes instead of using a fixed `setInterval()`.  
Why: Interval callbacks can queue or overlap logically when execution takes longer than the requested period.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Window/setInterval citeturn356618search10

Name: Use performance.now for elapsed-time measurement  
Category: Timing measurement  
Impact: Medium  
Consensus: High  
Description: Prefer `performance.now()` for measuring elapsed durations in browser code instead of subtracting wall-clock `Date.now()` values.  
Why: `performance.now()` uses a monotonic clock and is not affected by system-clock corrections in the way wall-clock time can be.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Performance/now citeturn233289search5

Name: Revoke object URLs when no longer needed  
Category: Resource lifetime  
Impact: Medium  
Consensus: High  
Description: Call `URL.revokeObjectURL()` once a blob URL no longer needs to remain usable, particularly in long-lived applications.  
Why: Each live object URL keeps its underlying object available and can cause memory leaks.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/URI/Reference/Schemes/blob citeturn233289search4

Name: Use deterministic disposal for disposable resources when supported  
Category: Resource lifetime  
Impact: Medium  
Consensus: Medium  
Description: For objects supporting the explicit resource-management protocol, `using` and `await using` can tie cleanup to lexical scope. Use them when runtime support and the resource API make that contract appropriate.  
Why: Scope-bound disposal is deterministic and avoids depending on garbage collection for closing resources.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Resource_management citeturn714703search20

Name: Optional chaining only short-circuits a continuous chain  
Category: Optional chaining  
Impact: Medium  
Consensus: High  
Description: Keep optional access within the intended chain. Grouping an intermediate expression, such as `(obj?.a).b`, ends the short-circuit protection before `.b`.  
Why: Code that visually resembles an optional chain can still throw when an intermediate result is `undefined`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Optional_chaining citeturn682751search6

Name: Optional call does not prove a property is callable  
Category: Optional chaining  
Impact: Medium  
Consensus: High  
Description: `obj.method?.()` suppresses the call only when the property is nullish. It still throws if the property exists but is not a function.  
Why: Existence and callability are different conditions.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Optional_chaining citeturn682751search6

Name: Avoid accidental switch fallthrough  
Category: Control flow  
Impact: Medium  
Consensus: High  
Description: End a `case` with `break`, `return`, `throw`, or another explicit control transfer unless fallthrough is intentional and clear.  
Why: Unintended fallthrough executes later cases and can silently alter program state.  
Source URL: https://eslint.org/docs/latest/rules/no-fallthrough citeturn214547search13

Name: Avoid accidental assignment in conditions  
Category: Control flow  
Impact: Medium  
Consensus: High  
Description: Do not write `if (x = value)` when comparison is intended. If assignment in a condition is deliberate, make that intent syntactically obvious.  
Why: Assignment expressions return the assigned value, so the typo can execute valid but incorrect code.  
Source URL: https://eslint.org/docs/latest/rules/no-cond-assign citeturn214547search15

Name: Do not mix ?? with && or || without explicit grouping  
Category: Operator semantics  
Impact: Medium  
Consensus: High  
Description: Add parentheses when combining nullish coalescing with logical AND or OR. JavaScript intentionally rejects unparenthesized mixing of these operators.  
Why: Their different short-circuit semantics would otherwise make precedence and intent unusually ambiguous.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Errors/Cant_use_nullish_coalescing_unparenthesized citeturn682751search25

Name: Treat user-provided replacement strings as replacement syntax  
Category: String replacement  
Impact: Medium  
Consensus: High  
Description: If arbitrary text must be inserted literally through `String.prototype.replace()`, remember that replacement strings interpret tokens such as `$&`, `$1`, and `$<name>`. A replacer function can return literal text without applying these replacement patterns.  
Why: User or data strings containing dollar sequences can otherwise be transformed unexpectedly.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace citeturn773294search2

Name: Use WeakMap for object-associated metadata that should not retain keys  
Category: Memory ownership  
Impact: Medium  
Consensus: High  
Description: When metadata should live only as long as its object key, consider `WeakMap` rather than a normal `Map`.  
Why: `WeakMap` does not create a strong reference to its keys, avoiding a common source of unintended object retention.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap citeturn714703search45

## 3. Low Impact

Name: Do not assume object properties enumerate purely in insertion order  
Category: Property ordering  
Impact: Low  
Consensus: High  
Description: JavaScript has defined own-property ordering rules, but integer-index-like keys are ordered numerically ahead of ordinary string keys. Do not use a plain object when arbitrary insertion order is the actual data model.  
Why: Objects such as `{100: "a", 2: "b", 7: "c"}` enumerate those numeric keys as `2`, `7`, `100`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/keys citeturn714703search1

Name: Use Reflect.ownKeys when every own key matters  
Category: Reflection  
Impact: Low  
Consensus: High  
Description: When reflecting on all own properties, including non-enumerable names and symbols, use `Reflect.ownKeys()` rather than `Object.keys()`.  
Why: The narrower enumeration APIs intentionally omit categories of properties.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Reflect/ownKeys citeturn714703search24

Name: Preserve descriptors explicitly when cloning accessor definitions  
Category: Property descriptors  
Impact: Low  
Consensus: High  
Description: If the goal is to copy property definitions rather than current property values, use `Object.getOwnPropertyDescriptors()` with `Object.defineProperties()` instead of ordinary spread or assignment.  
Why: Value-copying reads getters and loses descriptor attributes and accessor definitions.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/getOwnPropertyDescriptors citeturn151948search22

Name: Do not assume localeCompare returns only -1, 0, or 1  
Category: Internationalization  
Impact: Low  
Consensus: High  
Description: Test `localeCompare()` results by sign, not by exact values such as `=== -1`. For repeated large sorts, use an `Intl.Collator`.  
Why: Implementations may return any negative or positive value, and a reusable collator can avoid repeated setup work.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/localeCompare citeturn714703search3

Name: Reuse Intl formatter objects for repeated formatting  
Category: Internationalization performance  
Impact: Low  
Consensus: High  
Description: When formatting many values with identical locale/options, construct the relevant `Intl` formatter once rather than repeatedly invoking convenience locale-formatting methods.  
Why: Repeated convenience calls may repeatedly search localization data and perform formatter setup.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Internationalization citeturn714703search19

Name: Account for negative zero when it is semantically relevant  
Category: Numeric edge cases  
Impact: Low  
Consensus: High  
Description: JavaScript numbers include both `0` and `-0`. Use `Object.is(value, -0)` when distinguishing them genuinely matters instead of ordinary equality.  
Why: `0 === -0` is true even though operations such as reciprocals can expose the distinction.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Equality_comparisons_and_sameness citeturn853621search3

Name: Know Math.round's negative-half behavior  
Category: Numeric edge cases  
Impact: Low  
Consensus: High  
Description: Do not assume `Math.round()` is equivalent to a language-independent "round away from zero" rule. Halfway cases are rounded toward positive infinity and can produce negative zero.  
Why: Financial, display, or domain-specific rounding rules may require an explicitly different algorithm.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/round citeturn423842search2

Name: Promise executor return values are ignored  
Category: Promise construction  
Impact: Low  
Consensus: High  
Description: Do not `return value` from a `new Promise()` executor expecting it to fulfill the promise. Use the provided `resolve` and `reject` functions.  
Why: The executor's own return value has no effect on the promise's settlement.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/Promise citeturn773294search38

Name: Remember that async functions always return promises  
Category: Async function semantics  
Impact: Low  
Consensus: High  
Description: Calling an `async` function always produces a promise, even when the function directly returns a non-promise value.  
Why: Callers must use asynchronous result handling rather than expecting an immediate ordinary return value.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function citeturn861492search1

Name: Avoid unnecessary await when scheduling order matters  
Category: Microtask scheduling  
Impact: Low  
Consensus: High  
Description: Do not add `await` merely for stylistic consistency when the value does not need asynchronous unwrapping. Each actual suspension adds another asynchronous continuation.  
Why: Extra microtasks can change interleaving and add small scheduling overhead.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await citeturn356618search41

Name: for await...of adds asynchronous handling even for synchronous iterables  
Category: Asynchronous iteration  
Impact: Low  
Consensus: High  
Description: Use ordinary `for...of` for synchronous iterables unless asynchronous unwrapping or a unified async interface is actually needed.  
Why: `for await...of` awaits each iteration and therefore adds asynchronous processing overhead.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for-await...of citeturn861492search16

Name: Avoid exporting a callable named then from dynamically imported modules  
Category: Dynamic imports  
Impact: Low  
Consensus: High  
Description: A module namespace returned by `import()` participates in promise resolution. Avoid exporting a function named `then` if that module will be dynamically imported.  
Why: The namespace can be treated as a thenable and produce surprising dynamic-import behavior.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import citeturn472969view1

Name: Do not cache-bust dynamic imports indefinitely without considering memory  
Category: Module caching  
Impact: Low  
Consensus: High  
Description: Avoid generating an unbounded sequence of unique dynamic-import URLs merely to force modules to re-execute.  
Why: Module namespace objects are cached, and current JavaScript provides no standard mechanism to manually evict them.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import citeturn472969view1

Name: Browser bare module specifiers require resolution support  
Category: Module resolution  
Impact: Low  
Consensus: High  
Description: In native browser modules, do not assume package-style specifiers such as `"foo"` resolve automatically. Use valid URLs or configure an import map.  
Why: Browsers do not inherently apply package-manager or Node-style resolution rules to bare specifiers.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules citeturn796353search0

Name: Prefer non-capturing regex groups when capture data is unnecessary  
Category: Regular-expression design  
Impact: Low  
Consensus: High  
Description: Use `(?:...)` for grouping required only for precedence or quantification, reserving capturing groups for values that will actually be consumed.  
Why: Unnecessary captures add result data and make capture numbering more fragile when patterns evolve.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Regular_expressions/Non-capturing_group citeturn682751search39

Name: Prefer textContent over innerText when rendered-text semantics are unnecessary  
Category: DOM text access  
Impact: Low  
Consensus: High  
Description: Use `textContent` when reading or assigning raw textual content and you do not need CSS-aware rendered-text behavior.  
Why: Reading `innerText` can trigger reflow because its result depends on layout and styling.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent citeturn574369search1

Name: Remember that Set uses SameValueZero equality  
Category: Collection equality  
Impact: Low  
Consensus: High  
Description: `Set` membership follows SameValueZero semantics rather than arbitrary structural equality. `NaN` compares equal to itself for membership, while distinct object instances remain distinct entries.  
Why: Set membership may therefore differ from assumptions based on `===` or deep-object equality.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set citeturn853621search9

Name: Class static initialization order is observable  
Category: Class initialization  
Impact: Low  
Consensus: High  
Description: Static fields and static initialization blocks execute in class declaration order. Do not read a later static field from an earlier initializer and assume it has already been initialized.  
Why: Reordering class elements can change initialization-time values and side effects.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes/Static_initialization_blocks citeturn228042search24

Name: Parenthesize object literals returned implicitly from arrow functions  
Category: Arrow-function syntax  
Impact: Low  
Consensus: High  
Description: Write `x => ({ value: x })`, not `x => { value: x }`, when an expression-bodied arrow should return an object literal.  
Why: An unparenthesized `{}` after the arrow is parsed as a function body, so the apparent object property becomes a labeled statement and the function returns `undefined`.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions citeturn228042search10

Name: Choose an ASI-safe semicolon policy  
Category: Automatic semicolon insertion  
Impact: Low  
Consensus: Medium  
Description: Whether a codebase writes explicit semicolons is largely a style choice, but code relying on automatic semicolon insertion must account for lines beginning with syntax such as `(` or `[` that can continue the previous expression.  
Why: A line break does not universally terminate a JavaScript statement, so certain formatting combinations can unexpectedly become calls, property accesses, or other expressions.  
Source URL: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Lexical_grammar citeturn214547search0

-----
#### User said:

Using the research findings, write one single enforceable rule for each finding.

The goal is to convert every identified pitfall, gotcha, footgun, anti-pattern, correctness hazard, or preferred idiom into a concise rule that can be given to an AI coding agent and used to prevent that specific issue.

For each finding:

- Produce exactly one rule.
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

- "MUST" for behavior required to avoid a well-supported correctness, safety, or reliability problem.
- "MUST NOT" for behavior that is prohibited under the applicable conditions.
- "SHOULD" / "SHOULD NOT" for strong preferences where legitimate exceptions exist.
- "MAY" only when expressing an explicitly permitted alternative is necessary.

Determine the strength of each rule from the underlying Impact, Consensus, evidence, and stated exceptions. Do not automatically convert every finding into "MUST" or "MUST NOT".

For each finding, output exactly:

Name:
Rule:

"Name" must preserve the name of the original research finding so the rule can be traced back to it.

"Rule" must contain the single resulting rule.

Process every finding from the research. Do not omit findings merely because they are low impact, low consensus, conditional, or stylistic. Where the evidence does not justify a strict requirement, express the rule with appropriately weaker normative language.

Avoid duplicate rules. If separate research findings ultimately impose the same requirement, retain their traceability but do not broaden either rule beyond its original finding.

-----
#### Assistant said:

I’ll preserve every finding name and convert only its corresponding guidance into one independently reviewable normative rule, keeping the original order so each rule remains traceable to the research.

-----
#### Assistant said:

Name: Use strict mode or ES modules instead of sloppy mode  
Rule: JavaScript code MUST execute under strict semantics, using ES modules or `"use strict"` for classic scripts, unless compatibility with intentional sloppy-mode behavior is an explicit requirement.

Name: Never rely on assignment to undeclared variables  
Rule: Assignments MUST target declared bindings or explicit object properties; code MUST NOT assign to undeclared identifiers.

Name: Avoid eval, Function constructors, and other string-to-code APIs  
Rule: Code MUST NOT execute dynamically constructed strings as JavaScript through `eval()`, `Function()`, or equivalent string-to-code APIs unless dynamic code execution is an explicit requirement that cannot reasonably be represented as data or ordinary functions.

Name: Defend dynamic property writes against prototype pollution  
Rule: Property names or paths derived from untrusted data MUST be validated to prevent prototype traversal or mutation, including dangerous keys such as `__proto__`, `constructor`, and `prototype`.

Name: Treat HTML string insertion as an injection sink  
Rule: Untrusted data MUST NOT be passed unsanitized to HTML-parsing sinks such as `innerHTML`; text-only insertion or an appropriate trusted sanitization mechanism MUST be used instead.

Name: Do not use Math.random for security-sensitive randomness  
Rule: `Math.random()` MUST NOT be used where unpredictability is a security requirement; a cryptographically secure randomness API MUST be used.

Name: Check Fetch HTTP status explicitly  
Rule: Code using `fetch()` MUST explicitly check `response.ok` or the HTTP status whenever unsuccessful HTTP responses are failures for the operation.

Name: Do not leave promises floating  
Rule: Every promise whose completion or failure matters MUST be awaited, returned, or explicitly handled and MUST NOT be unintentionally discarded.

Name: Return promises from then callbacks  
Rule: A `.then()` callback that starts asynchronous work required by subsequent chain steps MUST return that promise.

Name: Do not use async callbacks with Array.forEach when you need to wait  
Rule: `Array.prototype.forEach()` MUST NOT be used with async callbacks when the caller must wait for their completion; an awaitable iteration or promise-composition construct MUST be used instead.

Name: Avoid async Promise executors  
Rule: `Promise` constructors MUST NOT use `async` executor functions.

Name: Promise races do not cancel losing operations  
Rule: Code MUST NOT treat settlement of `Promise.race()` as cancellation; losing operations that must stop MUST be explicitly canceled through their underlying cancellation mechanism.

Name: Avoid cyclic module dependencies that require early binding access  
Rule: Cyclic ES module dependencies MUST NOT access imported bindings before those bindings are initialized.

Name: Do not return, throw, break, or continue from finally  
Rule: A `finally` block MUST NOT use `return`, `throw`, `break`, or `continue` to override a pending completion unless replacing that completion is explicitly intended.

Name: Keep return and throw values on the same line  
Rule: Expressions returned or thrown MUST begin on the same line as the corresponding `return` or `throw` keyword.

Name: Respect the safe integer range of Number  
Rule: Integer values that must remain exact MUST NOT be represented as `Number` outside JavaScript's safe integer range.

Name: Do not parse exact large integers through JSON Number  
Rule: JSON values that may contain integers outside JavaScript's safe integer range MUST use an exact representation such as strings rather than ordinary JSON numbers.

Name: Escape literal input before embedding it in a regular expression  
Rule: Text intended to be literal inside a dynamically constructed regular expression MUST be escaped with a correct regular-expression escaping mechanism before interpolation.

Name: Avoid catastrophic-backtracking regexes on untrusted input  
Rule: Regular expressions applied to untrusted or unbounded input MUST NOT use patterns with known catastrophic-backtracking behavior.

Name: Synchronize SharedArrayBuffer access with Atomics  
Rule: Concurrent `SharedArrayBuffer` access that requires synchronization MUST use `Atomics` or another defined synchronization protocol and MUST NOT rely on unsynchronized ordinary reads and writes.

Name: Do not rely on garbage collection for essential cleanup  
Rule: Correctness-critical resource cleanup MUST be deterministic and MUST NOT depend on garbage collection, `WeakRef`, or `FinalizationRegistry` callbacks.

Name: Avoid implementation-dependent Date parsing  
Rule: Date parsing that requires consistent interpretation MUST NOT rely on implementation-dependent or non-standard date-string formats.

Name: Do not use local calendar arithmetic as elapsed-time arithmetic  
Rule: Local calendar arithmetic MUST NOT be used to calculate exact elapsed durations when daylight-saving or time-zone transitions can affect the result.

Name: Do not mistake shallow copying for independent object state  
Rule: Shallow copies MUST NOT be treated as independent nested state; nested references requiring isolation MUST be cloned or reconstructed separately.

Name: Prefer strict equality when coercion is not intentional  
Rule: Comparisons SHOULD use `===` and `!==` unless JavaScript's coercive equality semantics are explicitly intended.

Name: Use nullish coalescing for nullish defaults  
Rule: Nullish defaults MUST use `??` rather than `||` when `0`, `false`, or `""` are valid values.

Name: Prefer Number.isNaN over global isNaN  
Rule: Tests for whether a value is actually `NaN` MUST use `Number.isNaN()` rather than the coercive global `isNaN()`.

Name: Prefer Number.isFinite over global isFinite  
Rule: Tests for whether a value is actually a finite number MUST use `Number.isFinite()` rather than the coercive global `isFinite()`.

Name: Do not construct Boolean wrapper objects  
Rule: Code MUST NOT construct Boolean wrapper objects with `new Boolean()`; Boolean primitives MUST be used instead.

Name: Remember that typeof null is "object"  
Rule: A `typeof value === "object"` check MUST explicitly exclude `null` whenever `null` is not a valid result.

Name: typeof is not universally safe before declaration  
Rule: `typeof` MUST NOT be treated as an unconditional pre-declaration existence check for `let`, `const`, or class bindings that may still be in their temporal dead zone.

Name: Default parameters and destructuring defaults do not replace null  
Rule: Defaults that must apply to both `undefined` and `null` MUST explicitly handle `null` rather than relying solely on parameter or destructuring defaults.

Name: const does not make objects immutable  
Rule: Code MUST NOT infer object or array immutability from a `const` binding; mutation MUST be controlled separately when immutability is required.

Name: Prefer block-scoped bindings over var for local state  
Rule: Local bindings SHOULD use `const` by default and `let` when reassignment is required; `var` SHOULD NOT be used unless function-scoped semantics are intentional.

Name: Remember that this is determined by invocation  
Rule: Functions that depend on `this` MUST be invoked with the intended receiver and MUST NOT assume `this` is determined by where the function was defined.

Name: Use arrow functions only when lexical this is desired  
Rule: Arrow functions MUST NOT be used where dynamic `this`, an own `arguments` binding, or constructor behavior is required.

Name: Bind or wrap methods when passing them as callbacks  
Rule: A method that depends on `this` MUST be bound or wrapped before being passed as a callback unless the receiving API guarantees the intended receiver.

Name: Class fields do not behave exactly like constructor assignments  
Rule: Constructor assignments MUST NOT be refactored into class fields without verifying that inherited setter or accessor behavior is not required.

Name: Call super before using this in derived constructors  
Rule: A derived class constructor MUST call `super()` before accessing `this`.

Name: Private fields are lexically private, not conventionally protected  
Rule: Subclass code MUST NOT directly access `#private` fields declared by a superclass.

Name: Make getters return a value on every intended path  
Rule: A getter MUST return the intended value on every reachable path where a value is expected.

Name: Avoid explicit constructor return values  
Rule: Constructors SHOULD rely on implicit instance return and SHOULD NOT explicitly return another value unless replacement-object semantics are intentional.

Name: Do not use for...in as an array iterator  
Rule: `for...in` MUST NOT be used to iterate array elements as array values or ordered indexes.

Name: Use Object.hasOwn for own-property tests  
Rule: Own-property checks SHOULD use `Object.hasOwn()` and MUST NOT use `in` when inherited properties must be excluded.

Name: Plain-object keys are strings or symbols  
Rule: Arbitrary object-identity keys MUST use `Map` or another identity-preserving keyed structure rather than plain-object properties.

Name: Know what Object.keys omits  
Rule: Code requiring non-enumerable or symbol own properties MUST NOT rely on `Object.keys()` as a complete property inventory.

Name: Object.defineProperty descriptor defaults are false  
Rule: `Object.defineProperty()` calls MUST explicitly specify `writable`, `enumerable`, and `configurable` whenever those attributes matter and MUST NOT assume omitted flags are `true`.

Name: Avoid __proto__ mutation  
Rule: Code SHOULD NOT mutate prototypes through `__proto__`; explicit prototype APIs SHOULD be used when prototype mutation is actually required.

Name: Object.assign invokes getters and setters and can partially mutate  
Rule: `Object.assign()` MUST NOT be used where getter or setter execution, incremental target mutation, or loss of property descriptors would make the operation incorrect.

Name: Object.freeze is shallow  
Rule: `Object.freeze()` MUST NOT be treated as deep immutability; nested objects requiring immutability MUST be protected separately.

Name: Do not use instanceof for cross-realm Array detection  
Rule: Array detection that may cross JavaScript realms MUST use `Array.isArray()` rather than `instanceof Array`.

Name: Treat Proxy traps as semantic hooks, not transparent interception  
Rule: `Proxy` traps MUST preserve ECMAScript object invariants and required receiver semantics and MUST NOT assume `Reflect` forwarding automatically makes a trap transparent.

Name: Use Map.has when undefined is a valid Map value  
Rule: When `undefined` is a valid `Map` value, key presence MUST be tested with `map.has()` rather than inferred from `map.get()`.

Name: Map object keys use identity, not structural equality  
Rule: Object keys in a `Map` MUST be treated as identity-based; code requiring structural key equality MUST use a canonical key or other explicit representation.

Name: Avoid accidental sparse arrays  
Rule: Code SHOULD NOT create array holes unless sparse-array semantics are explicitly intended.

Name: Do not use delete to remove array elements  
Rule: `delete` MUST NOT be used to remove array elements when dense removal and length adjustment are intended.

Name: Beware the single-number Array constructor  
Rule: The single-number `Array()` constructor SHOULD NOT be used where a one-element array or initialized elements are intended.

Name: Changing array length can delete data or create holes  
Rule: Code MUST NOT assign to an array's `length` without accounting for element deletion when shrinking and hole creation when growing.

Name: Array.fill repeats object references  
Rule: `Array.prototype.fill()` MUST NOT be given one mutable object when distinct per-element objects are required.

Name: Supply a numeric comparator when sorting numbers  
Rule: `Array.prototype.sort()` MUST receive an explicit numeric comparator when numeric ordering is intended.

Name: Remember that sort mutates the original array  
Rule: `sort()` MUST NOT be used directly when mutation of the original array is unacceptable.

Name: Write well-formed sort comparators  
Rule: Sort comparators MUST define a consistent ordering, including anti-symmetry and transitivity, and MUST return results consistent with that ordering.

Name: Do not pass parseInt directly to map  
Rule: `parseInt` MUST NOT be passed directly as an `Array.prototype.map()` callback.

Name: Do not use map when you ignore its returned array  
Rule: `map()` SHOULD NOT be used solely for side effects when its returned array is intentionally ignored.

Name: Give reduce an initial value when emptiness is possible  
Rule: `reduce()` MUST receive an explicit initial value whenever the input may be empty.

Name: Avoid repeatedly copying a growing reduce accumulator  
Rule: Reducers SHOULD NOT repeatedly copy an increasingly large accumulator on every iteration when doing so creates avoidable quadratic work.

Name: Do not use forEach when you need early exit  
Rule: `forEach()` MUST NOT be used when iteration requires `break`-like early termination.

Name: Avoid structural mutation during iterative array methods  
Rule: Arrays SHOULD NOT be structurally mutated during traversal by iterative array methods unless the method's mutation semantics are deliberately required.

Name: Use includes when searching for NaN  
Rule: Array membership tests that must find `NaN` MUST use `includes()` or another `SameValueZero`-aware mechanism rather than `indexOf()`.

Name: Do not use bitwise operators as general numeric truncation  
Rule: Bitwise operators MUST NOT be used as general-purpose numeric truncation when values may exceed the signed 32-bit integer range.

Name: Do not compare calculated floating-point values with naive exact equality  
Rule: Calculated floating-point values MUST NOT be compared with exact equality when rounding error is possible; comparison MUST use a tolerance appropriate to the domain.

Name: Treat parseInt as a prefix parser, not strict numeric validation  
Rule: `parseInt()` MUST NOT be used as whole-string numeric validation when trailing invalid characters must cause rejection.

Name: Do not mix BigInt and Number arithmetic implicitly  
Rule: `BigInt` and `Number` arithmetic MUST NOT be mixed implicitly; conversions MUST be explicit and preserve required precision.

Name: Understand TypedArray numeric coercion  
Rule: Values written to typed arrays MUST be compatible with the target element type's coercion and range semantics and MUST NOT be assumed to preserve arbitrary `Number` values exactly.

Name: Specify endianness explicitly with DataView  
Rule: `DataView` operations for defined binary formats MUST explicitly use the byte order required by that format.

Name: Remember that transferring an ArrayBuffer detaches the original  
Rule: After an `ArrayBuffer` is transferred, code MUST NOT use the original buffer or its views as if they remain attached.

Name: Do not equate string length with user-perceived character count  
Rule: `String.length` and UTF-16 code-unit indexing MUST NOT be used as user-perceived character counting when Unicode grapheme semantics are required.

Name: Normalize Unicode when canonical equivalence matters  
Rule: Strings MUST be normalized before comparison when Unicode canonical equivalence is required.

Name: Handle lone surrogates before URI encoding when necessary  
Rule: Potentially malformed UTF-16 MUST be made well-formed or otherwise handled before URI encoding when lone surrogates may occur.

Name: Do not reuse global or sticky regexes without accounting for lastIndex  
Rule: Reused regular expressions with the `g` or `y` flag MUST explicitly account for or reset `lastIndex` between logically independent matches.

Name: Use Unicode-aware regex semantics for Unicode text  
Rule: Regular expressions intended to operate on Unicode code points or properties SHOULD use Unicode-aware flags and MUST NOT assume ASCII-oriented character classes represent all Unicode text.

Name: Remember that Date months are zero-based  
Rule: Numeric month values passed to or returned from legacy `Date` month APIs MUST be treated as zero-based.

Name: Account for Date setter overflow  
Rule: Date setter operations MUST account for overflow normalization whenever the resulting calendar month or day is semantically constrained.

Name: Consider Temporal for complex date and time-zone logic  
Rule: Complex calendar, duration, instant, or time-zone logic SHOULD use `Temporal` where supported and appropriate rather than forcing those semantics through legacy `Date`.

Name: Do not compare localized output to hardcoded strings  
Rule: Localized formatting output MUST NOT be treated as a stable machine-readable representation or compared to hardcoded presentation strings when locale or implementation variation is possible.

Name: Throw Error objects rather than strings or primitive values  
Rule: Application failures SHOULD be thrown as `Error` instances or appropriate subclasses rather than primitive values.

Name: Preserve error causality when wrapping errors  
Rule: Wrapped errors SHOULD preserve the original error through `cause` when the underlying failure is materially useful for diagnosis.

Name: Catch errors you can handle and rethrow unexpected ones  
Rule: Catch blocks MUST NOT silently swallow unexpected errors; failures the current layer cannot meaningfully handle MUST be rethrown or propagated.

Name: Choose Promise.all only when fail-fast semantics are appropriate  
Rule: `Promise.all()` MUST be used only when fail-fast aggregate rejection matches the required behavior; a different combinator MUST be used when every outcome must be observed.

Name: Distinguish Promise.any from Promise.race  
Rule: `Promise.any()` and `Promise.race()` MUST be selected according to whether first fulfillment or first settlement is required and MUST NOT be treated as interchangeable.

Name: Run independent asynchronous operations concurrently when appropriate  
Rule: Independent asynchronous operations SHOULD be started concurrently when no required dependency or ordering requires serialization.

Name: Promise.finally can replace the original failure  
Rule: A `.finally()` callback SHOULD perform cleanup only and MUST NOT throw or reject unless replacing the previous settlement is explicitly intended.

Name: Do not create unbounded recursive microtask chains  
Rule: Code MUST NOT create self-perpetuating microtask chains that can indefinitely starve tasks, rendering, timers, or input processing.

Name: Keep APIs consistently synchronous or asynchronous  
Rule: An API SHOULD provide a consistent synchronous or asynchronous callback contract across execution paths and SHOULD NOT invoke the same callback synchronously on some paths and asynchronously on others.

Name: Use top-level await deliberately  
Rule: Top-level `await` SHOULD NOT be placed on a critical module dependency path unless delaying dependent-module evaluation is intentional.

Name: Imported bindings are read-only live bindings  
Rule: Imported bindings MUST NOT be reassigned and MUST be treated as live bindings rather than copied local values.

Name: Use defer or modules instead of parser-blocking classic scripts when appropriate  
Rule: Classic scripts SHOULD use `defer`, or code SHOULD use modules, when execution does not need to block HTML parsing at the script's location.

Name: Use globalThis for portable access to the global object  
Rule: Code that must access the global object portably across JavaScript hosts SHOULD use `globalThis` rather than host-specific global names.

Name: Avoid top-level var in classic browser scripts  
Rule: Classic browser scripts SHOULD NOT declare top-level `var` bindings unless creating properties on the global object is intentional.

Name: Use structuredClone rather than JSON round-tripping for general deep cloning  
Rule: General deep cloning of supported JavaScript data SHOULD use `structuredClone()` rather than `JSON.stringify()` and `JSON.parse()` round-tripping.

Name: Know the limits of structured cloning  
Rule: `structuredClone()` MUST NOT be used when functions, DOM nodes, property descriptors, accessors, or other unsupported object semantics must be preserved.

Name: JSON.stringify silently transforms or removes some values  
Rule: Code serializing `undefined`, functions, or symbols with `JSON.stringify()` MUST NOT assume those values will round-trip unchanged.

Name: Map and Set do not serialize meaningfully with plain JSON.stringify  
Rule: `Map` and `Set` MUST NOT be serialized with plain `JSON.stringify()` when their contents must be preserved.

Name: BigInt is not supported by default JSON serialization  
Rule: `BigInt` values MUST NOT be passed to default `JSON.stringify()` without an explicit serializable representation.

Name: Fetch request and response bodies are one-shot streams  
Rule: Fetch request and response bodies MUST be treated as one-shot streams; code requiring multiple reads MUST clone the object before its first consumption when cloning is valid.

Name: Be careful cloning large streaming responses  
Rule: `Response.clone()` SHOULD NOT be used for large streaming bodies with substantially uneven consumer rates when potentially unbounded buffering is unacceptable.

Name: Do not set multipart Content-Type manually for FormData  
Rule: When `FormData` is passed directly to `fetch()`, code MUST NOT manually set the `multipart/form-data` `Content-Type` header.

Name: no-cors does not bypass CORS  
Rule: `mode: "no-cors"` MUST NOT be used as a mechanism for obtaining a readable cross-origin response.

Name: Treat cross-origin credential inclusion as a security decision  
Rule: Cross-origin request credentials MUST be enabled only when intentionally required and consistent with the application's CORS and CSRF security model.

Name: Use URL instead of hand-parsing URLs  
Rule: URLs and query parameters SHOULD be parsed and constructed with `URL` and `URLSearchParams` rather than ad hoc string splitting or concatenation.

Name: Preserve literal plus signs in URLSearchParams deliberately  
Rule: Raw values containing literal `+` characters MUST NOT be interpolated directly into `URLSearchParams` string input when those plus signs must be preserved literally.

Name: Distinguish encodeURI from encodeURIComponent  
Rule: `encodeURIComponent()` MUST be used for individual URI components, while `encodeURI()` SHOULD be reserved for complete URIs whose structural delimiters must remain syntax.

Name: Do not assume decodeURIComponent accepts arbitrary input  
Rule: `decodeURIComponent()` applied to external input MUST handle malformed encoding errors and MUST NOT be assumed to convert `+` into a space.

Name: Avoid heavy synchronous Web Storage work  
Rule: Large or frequent storage operations SHOULD NOT use synchronous `localStorage` or `sessionStorage` when blocking can materially affect responsiveness.

Name: Prefer Web Storage methods over property syntax  
Rule: Web Storage SHOULD be accessed through `getItem()`, `setItem()`, `removeItem()`, and related methods rather than object property syntax.

Name: Distinguish live and static DOM collections  
Rule: Code iterating DOM collections MUST account for whether the collection is live or static and MUST NOT assume a live collection remains unchanged while the DOM is mutated.

Name: Escape dynamic values used in CSS selectors  
Rule: Dynamic literal values inserted into CSS selectors MUST be correctly escaped, such as with `CSS.escape()`, when they may contain selector-significant characters.

Name: Distinguish event.target from event.currentTarget  
Rule: Event handlers MUST use `event.target` for the event origin and `event.currentTarget` for the listener's registered target and MUST NOT treat them as interchangeable when propagation can occur.

Name: Do not call preventDefault from a passive listener  
Rule: Passive event listeners MUST NOT call `preventDefault()`; a listener that must cancel default behavior MUST be registered non-passively.

Name: stopPropagation does not prevent the default action  
Rule: `stopPropagation()` MUST NOT be used as a substitute for `preventDefault()` when cancellation of a default browser action is required.

Name: Preserve listener identity when removing event listeners  
Rule: Code removing an event listener MUST reuse the original listener identity and compatible capture semantics, or use an equivalent lifecycle mechanism such as an `AbortSignal`.

Name: Repeated anonymous event listeners are distinct registrations  
Rule: Code SHOULD NOT repeatedly register newly created anonymous event listeners when a single reusable listener registration is intended.

Name: dataset values are strings  
Rule: Values read from `dataset` MUST be treated as strings and explicitly parsed when another type is required; deleting a data attribute MUST NOT be implemented by assigning `null`.

Name: Boolean HTML attributes are controlled by presence  
Rule: Boolean HTML attributes MUST represent false through absence and MUST NOT use the string `"false"` to represent a false state.

Name: Prefer feature detection to user-agent sniffing  
Rule: Browser capability decisions SHOULD use feature detection rather than user-agent sniffing unless the requirement is specifically dependent on user-agent identity.

Name: Use requestAnimationFrame for JavaScript-driven animation  
Rule: JavaScript-driven visual animation SHOULD use `requestAnimationFrame()` rather than fixed timer loops.

Name: Base animation progress on the requestAnimationFrame timestamp  
Rule: `requestAnimationFrame()` animations MUST calculate progress from elapsed time or the supplied timestamp and MUST NOT assume a fixed frame duration.

Name: Do not treat timer delays as exact schedules  
Rule: `setTimeout()` and `setInterval()` delays MUST NOT be treated as exact execution deadlines.

Name: Prefer recursive setTimeout when interval work may overrun  
Rule: Recurring work whose next execution must wait for the current execution to finish SHOULD use completion-based scheduling such as recursive `setTimeout()` rather than fixed `setInterval()`.

Name: Use performance.now for elapsed-time measurement  
Rule: Browser code measuring elapsed time SHOULD use `performance.now()` rather than wall-clock time when monotonic timing is required.

Name: Revoke object URLs when no longer needed  
Rule: Object URLs MUST be revoked when they are no longer needed and their lifetime is under application control.

Name: Use deterministic disposal for disposable resources when supported  
Rule: Disposable resources SHOULD use deterministic scope-bound disposal when both the runtime and resource support JavaScript's explicit resource-management protocol.

Name: Optional chaining only short-circuits a continuous chain  
Rule: Optional chaining MUST remain continuous through every property access that must be nullish-short-circuited; grouping MUST NOT terminate protection before a required access.

Name: Optional call does not prove a property is callable  
Rule: Optional-call syntax MUST NOT be treated as proof that an existing property is callable; callability MUST be guaranteed or checked when a non-function value is possible.

Name: Avoid accidental switch fallthrough  
Rule: Each `switch` case MUST terminate explicitly unless fallthrough is intentional and made clear.

Name: Avoid accidental assignment in conditions  
Rule: Assignment inside a conditional expression SHOULD NOT be used unless the assignment is intentional and made syntactically explicit.

Name: Do not mix ?? with && or || without explicit grouping  
Rule: `??` MUST NOT be combined with `&&` or `||` without explicit parentheses defining the intended grouping.

Name: Treat user-provided replacement strings as replacement syntax  
Rule: Arbitrary text passed to `String.prototype.replace()` MUST use a replacer function or equivalent handling when replacement-string `$` metasyntax must remain literal.

Name: Use WeakMap for object-associated metadata that should not retain keys  
Rule: Object-associated metadata that must not keep its object keys alive SHOULD use `WeakMap` rather than `Map`.

Name: Do not assume object properties enumerate purely in insertion order  
Rule: Plain-object enumeration MUST NOT be assumed to preserve pure insertion order when integer-index-like keys may be present.

Name: Use Reflect.ownKeys when every own key matters  
Rule: Reflection that requires every own property key MUST use `Reflect.ownKeys()` or an equivalent complete mechanism rather than `Object.keys()`.

Name: Preserve descriptors explicitly when cloning accessor definitions  
Rule: When property definitions rather than current property values must be copied, code MUST copy property descriptors explicitly rather than using spread or `Object.assign()`.

Name: Do not assume localeCompare returns only -1, 0, or 1  
Rule: `localeCompare()` results MUST be interpreted by sign rather than exact `-1` or `1` values, and repeated large-scale collation SHOULD reuse an `Intl.Collator`.

Name: Reuse Intl formatter objects for repeated formatting  
Rule: Repeated formatting with identical locale and options SHOULD reuse a constructed `Intl` formatter rather than recreate equivalent formatting setup for each value.

Name: Account for negative zero when it is semantically relevant  
Rule: Code that must distinguish `0` from `-0` MUST use `Object.is()` or equivalent `SameValue` semantics rather than ordinary equality.

Name: Know Math.round's negative-half behavior  
Rule: Code requiring a specific domain rounding rule MUST NOT assume `Math.round()` implements that rule for negative halfway values.

Name: Promise executor return values are ignored  
Rule: A `Promise` executor MUST settle the promise through `resolve` or `reject` and MUST NOT rely on the executor's return value.

Name: Remember that async functions always return promises  
Rule: Callers of `async` functions MUST treat their return values as promises even when the function returns a non-promise value internally.

Name: Avoid unnecessary await when scheduling order matters  
Rule: Code SHOULD NOT add `await` when no asynchronous unwrapping or sequencing is required and the additional microtask boundary could materially affect ordering or performance.

Name: for await...of adds asynchronous handling even for synchronous iterables  
Rule: Synchronous iterables SHOULD use `for...of` rather than `for await...of` unless asynchronous unwrapping or a unified asynchronous iteration contract is required.

Name: Avoid exporting a callable named then from dynamically imported modules  
Rule: A module intended for dynamic import SHOULD NOT export a callable named `then`.

Name: Do not cache-bust dynamic imports indefinitely without considering memory  
Rule: Code SHOULD NOT generate an unbounded sequence of unique dynamic-import URLs solely to bypass module caching.

Name: Browser bare module specifiers require resolution support  
Rule: Native browser modules MUST NOT use bare module specifiers unless an import map or another supported resolution mechanism defines them.

Name: Prefer non-capturing regex groups when capture data is unnecessary  
Rule: Regular-expression groups used only for grouping SHOULD be non-capturing unless their captured value is required.

Name: Prefer textContent over innerText when rendered-text semantics are unnecessary  
Rule: DOM code SHOULD use `textContent` rather than `innerText` when CSS-aware rendered-text semantics are not required.

Name: Remember that Set uses SameValueZero equality  
Rule: `Set` membership MUST be treated according to `SameValueZero` and object identity semantics; structural equality MUST be implemented separately when required.

Name: Class static initialization order is observable  
Rule: Static class initialization MUST respect declaration order and MUST NOT read later static fields as though they were already initialized.

Name: Parenthesize object literals returned implicitly from arrow functions  
Rule: Arrow functions that implicitly return object literals MUST wrap the object literal in parentheses.

Name: Choose an ASI-safe semicolon policy  
Rule: Code relying on automatic semicolon insertion MUST follow an ASI-safe statement-boundary convention that prevents continuation hazards; otherwise explicit semicolons SHOULD be used.
