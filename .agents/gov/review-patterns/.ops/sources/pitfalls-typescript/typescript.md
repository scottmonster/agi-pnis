#### User said:

Research as comprehensively as practical for TypeScript-specific pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms, especially cases where experienced TypeScript developers recommend "do this instead of that."

The goal is to identify as many distinct, materially useful TypeScript practices as possible, not just the most popular or obvious examples.

Research across the full TypeScript language, type system, compiler behavior, standard development practices, and ecosystem conventions.

Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.

Actively look for unexpected or less obvious classes of issues that may not fit common TypeScript best-practice lists.

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
- Impact - High, Medium, or Low based on how materially the issue can affect correctness, reliability, maintainability, type safety, or development outcomes.
- Consensus - High, Medium, or Low based on how broadly the recommendation is supported by authoritative sources and experienced TypeScript practitioners.
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

- official TypeScript documentation
- TypeScript handbook and release documentation
- TypeScript compiler and repository documentation
- guidance from TypeScript maintainers and contributors
- established engineering documentation
- respected TypeScript experts and practitioners
- technically rigorous articles and discussions

Do not treat popularity, repetition, or search ranking alone as evidence of correctness or consensus.

Evaluate Impact and Consensus independently. A finding may have high impact but low consensus, or low impact but high consensus.

Include disputed practices when they are materially relevant, but assign an appropriate Consensus rating and accurately describe the disagreement rather than presenting one side as settled guidance.

Avoid duplicate findings that describe the same underlying issue. Merge substantially equivalent recommendations while preserving genuinely different cases, conditions, or failure modes.

Focus on TypeScript-specific guidance or practices whose consequences materially change when TypeScript is involved. Do not fill the results with generic programming advice unless TypeScript introduces a distinct consideration.

Do not stop after finding a conventional "top TypeScript best practices" list. Use iterative discovery to identify additional terminology, failure modes, recommendations, and sources from the findings themselves.

Continue researching until further searching is producing primarily duplicates, minor stylistic preferences, weakly supported claims, or findings with little practical significance.

-----
#### Assistant said:

I’ll treat this as a discovery-first survey rather than working from a checklist. I’ll prioritize primary TypeScript and typescript-eslint sources, then use practitioner material mainly to surface less obvious or disputed cases that the official docs do not frame as recommendations.

-----
#### Assistant said:

The first pass is already surfacing an important distinction: many of the strongest TypeScript hazards are not syntax mistakes, but places where the checker is intentionally unsound or where JavaScript runtime behavior escapes the static model. I’m separating those from lower-impact style rules so they do not get flattened into a generic best-practices list.

-----
#### Assistant said:

A second discovery pass is adding several less obvious failure classes that are easy to miss in ordinary TypeScript lists: open structural object types, callback bivariance, refinement invalidation after function calls, type-only module resolution that does not match runtime resolution, library `const enum` version skew, and declarations that typecheck while leaving runtime state uninitialized.

-----
#### Assistant said:

The results below are the distinct findings that survived deduplication. The categories were derived from clustering the findings after discovery rather than being used to constrain the search.

#### 1. High Impact

Name: Enable the `strict` family  
Category: Compiler strictness  
Impact: High  
Consensus: High  
Description: Use `strict: true` as the normal baseline rather than selectively opting into type safety after problems appear.  
Why: It enables the core strictness checks that eliminate large classes of unsound inference, nullability, function compatibility, initialization, and other errors.  
Source URL: https://www.typescriptlang.org/tsconfig/strict.html citeturn935437view8turn933169search7

Name: Keep `strictNullChecks` enabled  
Category: Nullability  
Impact: High  
Consensus: High  
Description: Treat `null` and `undefined` as distinct types instead of allowing them to flow through ordinary values.  
Why: Without it, APIs such as `find` can be treated as returning a value even when they can actually return `undefined`, directly enabling runtime failures.  
Source URL: https://www.typescriptlang.org/tsconfig/strictNullChecks.html citeturn935437view9turn933169search4

Name: Reject implicit `any`  
Category: Type inference safety  
Impact: High  
Consensus: High  
Description: Keep `noImplicitAny` enabled rather than allowing unresolved types to silently fall back to `any`.  
Why: An implicit `any` disables checking at precisely the locations where the compiler could not establish what a value is.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/basic-types.html citeturn933169search9

Name: Prefer `unknown` over `any` for unknown values  
Category: Dynamic-data boundaries  
Impact: High  
Consensus: High  
Description: Use `unknown` when a value can legitimately be anything but must be inspected before use; reserve `any` for deliberate type-checking escape hatches.  
Why: `unknown` forces narrowing before operations, while `any` propagates unchecked assumptions throughout the program.  
Source URL: https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html citeturn935437view6

Name: Prevent `any` from propagating  
Category: Dynamic-data boundaries  
Impact: High  
Consensus: High  
Description: Use type-aware lint rules such as `no-unsafe-assignment`, `no-unsafe-argument`, `no-unsafe-call`, `no-unsafe-member-access`, and `no-unsafe-return` to contain unavoidable `any` values.  
Why: A single `any` can silently infect otherwise strongly typed code through assignments, calls, returns, and property access.  
Source URL: https://typescript-eslint.io/rules/no-unsafe-assignment/ citeturn107781search9turn107781search8turn107781search12

Name: Validate external data at runtime  
Category: Runtime type boundaries  
Impact: High  
Consensus: High  
Description: Parse and validate JSON, API responses, environment data, storage values, and other external inputs instead of asserting that they match TypeScript interfaces.  
Why: TypeScript types are erased and provide no runtime validation, so an asserted external value can violate its declared type without the checker knowing.  
Source URL: https://effectivetypescript.com/2021/05/06/unsoundness/ citeturn933169search27

Name: Narrow instead of asserting  
Category: Type assertion discipline  
Impact: High  
Consensus: High  
Description: Prefer control-flow narrowing, validation, type guards, or checked construction over `as T`, especially assertions that narrow to a more specific type.  
Why: Assertions tell the compiler to accept an assumption without proving it and do not change or validate the runtime value.  
Source URL: https://typescript-eslint.io/rules/no-unsafe-type-assertion/ citeturn107781search15

Name: Treat double assertions as an escape hatch  
Category: Type assertion discipline  
Impact: High  
Consensus: High  
Description: Avoid patterns such as `value as unknown as T` except at a deliberately audited unsafe boundary.  
Why: The intermediate `unknown` exists mainly to bypass TypeScript's assertion compatibility check, so the resulting type has effectively been accepted on trust.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/everyday-types.html citeturn113548search7

Name: Avoid routine non-null assertions  
Category: Nullability  
Impact: High  
Consensus: High  
Description: Prefer proving that a value is non-nullish rather than silencing the checker with `value!`.  
Why: The non-null assertion is erased at runtime and can convert a legitimate `undefined` or `null` path into an unchecked runtime failure.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/everyday-types.html citeturn113548search7

Name: Treat indexed access as potentially missing  
Category: Indexed access safety  
Impact: High  
Consensus: High  
Description: Enable `noUncheckedIndexedAccess`, particularly for arrays, dictionaries, and index-signature-heavy code.  
Why: Ordinary TypeScript indexed access can claim a value is present even when the key or array index does not exist.  
Source URL: https://www.typescriptlang.org/tsconfig/noUncheckedIndexedAccess.html citeturn463657search2

Name: Model variants as discriminated unions  
Category: Variant modeling  
Impact: High  
Consensus: High  
Description: Prefer separate union members with a literal discriminant over one large object containing many optional fields plus assertions.  
Why: The union lets TypeScript encode which fields can coexist and narrow them together, preventing impossible or partially initialized states.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/narrowing.html citeturn935437view1

Name: Make closed unions exhaustive  
Category: Exhaustiveness  
Impact: High  
Consensus: High  
Description: Exhaustively handle discriminated unions and enums with `never`, an `assertNever` pattern, or `switch-exhaustiveness-check`.  
Why: Adding a new variant otherwise leaves existing control flow silently incomplete.  
Source URL: https://typescript-eslint.io/rules/switch-exhaustiveness-check/ citeturn107781search11

Name: Never accidentally float Promises  
Category: Async control flow  
Impact: High  
Consensus: High  
Description: Await, return, aggregate, or explicitly handle every Promise rather than letting it become an unused expression.  
Why: Floating Promises cause lost errors, incorrect sequencing, and work that callers assume has completed when it has not.  
Source URL: https://typescript-eslint.io/rules/no-floating-promises/ citeturn596557search5

Name: Do not pass async functions to APIs expecting `void` callbacks  
Category: Async callback contracts  
Impact: High  
Consensus: High  
Description: Avoid `async` callbacks in `forEach`, event APIs, or other `() => void` positions unless the returned Promise is deliberately handled. Use an awaited loop, `Promise.all`, or explicit rejection handling instead.  
Why: TypeScript permits value-returning functions in void-returning positions, so the Promise can be silently ignored.  
Source URL: https://typescript-eslint.io/rules/no-misused-promises/ citeturn596557search3turn742315search8

Name: Use `return await` when the surrounding `try`/`catch` must handle rejection  
Category: Async error handling  
Impact: High  
Consensus: High  
Description: Inside an error-handling context, use `return await promise` when a rejection is supposed to be caught locally rather than directly returning the Promise.  
Why: Returning the Promise without awaiting it lets its later rejection escape the surrounding `catch`.  
Source URL: https://typescript-eslint.io/rules/return-await/ citeturn596557search7

Name: Match `module` and `moduleResolution` to the actual runtime or bundler  
Category: Module/runtime alignment  
Impact: High  
Consensus: High  
Description: Use Node modes for Node, `bundler` for bundler semantics, and otherwise configure TypeScript to model the actual host instead of choosing options solely to silence import errors.  
Why: TypeScript uses these options to predict runtime resolution and module behavior; the wrong model can typecheck imports that the runtime cannot load.  
Source URL: https://www.typescriptlang.org/docs/handbook/modules/reference.html citeturn921293search23

Name: Do not mistake `paths` for runtime aliasing  
Category: Module/runtime alignment  
Impact: High  
Consensus: High  
Description: Use `paths` only when the runtime or bundler implements the same mapping, and do not publish libraries whose emitted imports depend on private `paths` aliases.  
Why: `paths` changes TypeScript resolution but does not rewrite emitted module specifiers.  
Source URL: https://www.typescriptlang.org/docs/handbook/modules/reference.html citeturn935437view4

Name: Use runtime-correct extensions in Node ESM  
Category: Node module semantics  
Impact: High  
Consensus: High  
Description: In Node ESM source, write relative specifiers that will be valid in emitted JavaScript, commonly `./file.js`, rather than assuming TypeScript will rewrite extensionless or `.ts` imports.  
Why: Node ESM requires runtime-resolvable extensions and TypeScript normally preserves the module specifier.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-7.html citeturn921293search13turn935437view4

Name: Do not publish ambient `const enum`s  
Category: Library API design  
Impact: High  
Consensus: High  
Description: Prefer ordinary enums, literal objects, or de-constified declarations when publishing library APIs instead of exposing ambient `const enum` values to consumers.  
Why: Consumers can inline values from one library version and execute another, and some isolated transpilation workflows cannot safely consume ambient const enums.  
Source URL: https://www.typescriptlang.org/docs/handbook/enums.html citeturn113548search24

Name: Give CJS and ESM entrypoints separate declarations  
Category: Library publishing  
Impact: High  
Consensus: High  
Description: A package exposing both CommonJS and ESM entrypoints should provide declaration files whose detected module formats correspond to each JavaScript entrypoint.  
Why: A single declaration file cannot correctly represent both module identities and can cause consumers to see missing or incompatible exports.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-7.html citeturn638739search0turn638739search1

Name: Treat declaration files as trusted claims, not runtime proof  
Category: Declaration trust boundaries  
Impact: High  
Consensus: High  
Description: Investigate and correct inaccurate `.d.ts` declarations instead of assuming that successful type checking proves the dependency behaves as declared.  
Why: A declaration file can describe behavior the JavaScript implementation does not actually provide.  
Source URL: https://effectivetypescript.com/2021/05/06/unsoundness/ citeturn933169search27

Name: Keep property initialization checked  
Category: Class initialization  
Impact: High  
Consensus: High  
Description: Keep `strictPropertyInitialization` enabled and use definite-assignment assertions only when an external initialization mechanism genuinely guarantees assignment.  
Why: `property!: T` suppresses a real initialization check and can leave runtime properties undefined while their type claims otherwise.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/classes.html citeturn935437view5

Name: Avoid class-interface declaration merging  
Category: Declaration merging  
Impact: High  
Consensus: High  
Description: Do not merge a class and interface of the same name to add instance members unless the runtime actually initializes those members through a controlled mechanism.  
Why: TypeScript can believe merged members exist even though constructing the class leaves them undefined.  
Source URL: https://typescript-eslint.io/rules/no-unsafe-declaration-merging/ citeturn107781search0

Name: Do not confuse `lib` with runtime support  
Category: Runtime environment modeling  
Impact: High  
Consensus: High  
Description: Configure `lib` to describe APIs actually supplied by the target runtime or by intentional polyfills, rather than enabling newer libraries merely to eliminate type errors.  
Why: Adding a library declaration tells TypeScript that an API exists but does not install or polyfill that API.  
Source URL: https://www.typescriptlang.org/tsconfig/lib.html citeturn921293search14

Name: Use separate TypeScript projects for genuinely different environments  
Category: Project configuration  
Impact: High  
Consensus: High  
Description: Use separate tsconfigs or project references when code is checked against materially different runtimes such as Node, DOM, workers, tests, or separately published packages.  
Why: A single compilation can accidentally expose globals or resolution behavior that is unavailable in one of the actual execution environments.  
Source URL: https://www.typescriptlang.org/docs/handbook/modules/guides/choosing-compiler-options.html citeturn596557search1

Name: Enable `isolatedModules` with single-file transpilers  
Category: Transpilation compatibility  
Impact: High  
Consensus: High  
Description: Enable `isolatedModules` when Babel, SWC, esbuild, or another tool transpiles files without whole-program type information.  
Why: It catches TypeScript constructs whose correct JavaScript transformation depends on information unavailable to a single-file transpiler.  
Source URL: https://www.typescriptlang.org/tsconfig/isolatedModules.html citeturn128915search38

Name: Bundle declarations when bundling library JavaScript  
Category: Library publishing  
Impact: High  
Consensus: High  
Description: If a library bundles internal JavaScript modules, ensure its declaration output represents that bundled module structure rather than blindly publishing the unbundled declaration graph.  
Why: Declaration imports valid under bundler resolution can remain invalid for consumers running Node-style resolution.  
Source URL: https://www.typescriptlang.org/docs/handbook/modules/guides/choosing-compiler-options.html citeturn596557search1

Name: Do not assume TypeScript detects every CJS/ESM interop failure  
Category: Module/runtime alignment  
Impact: High  
Consensus: High  
Description: Test actual Node interop behavior, particularly `require()` of ESM and CommonJS named imports, rather than treating successful type checking as a complete runtime compatibility test.  
Why: TypeScript intentionally cannot detect some runtime cases, including certain top-level-await and synthetic-named-export situations.  
Source URL: https://www.typescriptlang.org/docs/handbook/modules/theory.html citeturn128915search31turn921293search11

Name: Do not mix standard and legacy decorator semantics accidentally  
Category: Decorators  
Impact: High  
Consensus: High  
Description: Know whether a framework expects modern decorators or legacy `experimentalDecorators`; existing legacy decorators are not automatically compatible with the standard decorator model.  
Why: Their invocation, typing, emit, parameter-decorator support, and metadata behavior differ materially.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-0.html citeturn120883search0

Name: Keep type checking as a build or CI gate  
Category: Build correctness  
Impact: High  
Consensus: High  
Description: If a bundler, transpiler, `--noCheck`, or transpile-only workflow emits JavaScript despite type errors, run a separate required type-checking step.  
Why: Successful JavaScript emission does not mean TypeScript validation occurred or passed.  
Source URL: https://www.typescriptlang.org/docs/handbook/compiler-options.html citeturn463657search4turn113548search10

Name: Enable `erasableSyntaxOnly` when relying on native Node type stripping  
Category: Native TypeScript execution  
Impact: High  
Consensus: High  
Description: When running TypeScript directly through Node's type-stripping support, enable `erasableSyntaxOnly` or otherwise avoid TypeScript constructs requiring JavaScript transformation, such as enums, parameter properties, runtime namespaces, and `import =`.  
Why: Native stripping can remove type syntax but cannot execute TypeScript-specific runtime constructs that require transformation.  
Source URL: https://www.typescriptlang.org/tsconfig/ citeturn463657search0turn463657search1

Name: Prefer function-property signatures where callback variance must be sound  
Category: Function variance  
Impact: High  
Consensus: Medium  
Description: Under `strictFunctionTypes`, prefer properties such as `handler: (x: T) => void` for callback contracts where contravariant checking matters; method syntax retains bivariant parameter behavior for compatibility.  
Why: Method bivariance can accept a callback that handles a narrower input than the caller may actually provide.  
Source URL: https://typescript-eslint.io/rules/method-signature-style/ citeturn107781search10

Name: Accept `readonly` arrays when mutation is not required  
Category: Variance and mutation  
Impact: High  
Consensus: Medium  
Description: Type non-mutating array inputs as `readonly T[]` or `ReadonlyArray<T>` instead of mutable arrays.  
Why: Mutable array covariance can create an unsound write path, while readonly inputs prevent the callee from exploiting that mutation hole.  
Source URL: https://effectivetypescript.com/2021/05/06/unsoundness/ citeturn933169search27

Name: Do not trust refinements across mutation-capable calls  
Category: Control-flow refinement  
Impact: High  
Consensus: Medium  
Description: If a callback or function call can mutate an object that has been narrowed, capture the narrowed primitive locally or expose a readonly view before the call.  
Why: TypeScript generally does not invalidate refinements after arbitrary function calls even though the called code can mutate the refined property.  
Source URL: https://effectivetypescript.com/2021/05/06/unsoundness/ citeturn933169search27

Name: Write type predicates that are valid in both branches  
Category: User-defined narrowing  
Impact: High  
Consensus: Medium  
Description: A function returning `x is T` should justify not only that `true` implies `T`, but also that `false` safely excludes `T`; avoid predicates based on thresholds or truthiness when that implication is false.  
Why: An incorrect predicate can make the checker unsound in the false branch and produce runtime failures in partitioning or control flow.  
Source URL: https://effectivetypescript.com/2024/02/27/type-guards/ citeturn481893view2

Name: Avoid caller-selected return-only generics  
Category: Generic API safety  
Impact: High  
Consensus: Medium  
Description: Avoid APIs such as `parse<T>(input): T` when `T` is not inferred from or validated against an input; return `unknown` or a validated schema-derived type instead.  
Why: A return-only generic often behaves like an assertion controlled by the caller and gives the appearance of type safety without evidence that the runtime value is `T`.  
Source URL: https://effectivetypescript.com/2020/08/12/generics-golden-rule/ citeturn481893view4

#### 2. Medium Impact

Name: Distinguish absent optional properties from explicit `undefined`  
Category: Optional property semantics  
Impact: Medium  
Consensus: High  
Description: Enable `exactOptionalPropertyTypes` when property presence itself has meaning, rather than automatically treating `foo?: T` as permitting `foo: undefined`.  
Why: JavaScript operations such as `in`, spreading, defaults, and serialization can distinguish an absent property from a present property containing `undefined`.  
Source URL: https://www.typescriptlang.org/tsconfig/exactOptionalPropertyTypes.html citeturn463657search2

Name: Treat caught exceptions as `unknown`  
Category: Exception handling  
Impact: Medium  
Consensus: High  
Description: Keep `useUnknownInCatchVariables` behavior and narrow caught values before assuming they are `Error` objects.  
Why: JavaScript permits throwing any value, not just `Error`.  
Source URL: https://www.typescriptlang.org/tsconfig/ citeturn463657search2

Name: Do not use truthiness when valid data can be falsy  
Category: Narrowing semantics  
Impact: Medium  
Consensus: High  
Description: Prefer explicit nullish or domain-specific checks when `0`, `""`, `false`, or `NaN` are legitimate values.  
Why: Truthiness narrowing removes all falsy values, not merely `null` and `undefined`.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/narrowing.html citeturn935437view1

Name: Prefer `??` to `||` for nullish defaults  
Category: Nullish semantics  
Impact: Medium  
Consensus: High  
Description: Use nullish coalescing when the fallback should apply only to `null` or `undefined`.  
Why: `||` also replaces valid falsy values such as `0`, `false`, and empty strings.  
Source URL: https://typescript-eslint.io/rules/prefer-nullish-coalescing/ citeturn850037search23

Name: Remember that optional chaining only guards its chain  
Category: Nullish semantics  
Impact: Medium  
Consensus: High  
Description: Do not assume `foo?.bar` protects later independent operations such as arithmetic on the resulting value.  
Why: The expression can still evaluate to `undefined`, which later code must account for.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html citeturn128915search11

Name: Prefer `satisfies` when checking a value without widening it  
Category: Literal inference  
Impact: Medium  
Consensus: High  
Description: For configuration objects, lookup tables, and similar values, use `satisfies` when you want structural validation while retaining the expression's precise inferred type.  
Why: A broad annotation can discard useful literal information, while an assertion can suppress validation.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html citeturn128915search37

Name: Do not mistake excess-property checks for exact object types  
Category: Structural object semantics  
Impact: Medium  
Consensus: High  
Description: Treat TypeScript object types as open structural contracts; assigning an object literal directly gets special excess-property checking, but equivalent values can contain additional runtime keys.  
Why: Intermediate variables and structurally compatible objects can carry properties not listed in the target type.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/objects.html citeturn935437view2

Name: Do not blindly cast `Object.keys` to `keyof T`  
Category: Structural object iteration  
Impact: Medium  
Consensus: High  
Description: Assume runtime objects may contain keys beyond their static type; use `Object.entries`, targeted validation, or a `keyof` cast only when exact keys are genuinely guaranteed.  
Why: Structural typing intentionally allows extra properties, which is why `Object.keys` cannot generally return `(keyof T)[]` safely.  
Source URL: https://effectivetypescript.com/2020/05/26/iterate-objects/ citeturn481893view3

Name: Remember that unions are inclusive  
Category: Union modeling  
Impact: Medium  
Consensus: High  
Description: `A | B` allows a value satisfying both `A` and `B`; use a discriminant or an explicit XOR construction when mutual exclusivity is required.  
Why: Structural typing can otherwise admit semantically invalid combinations that happen to satisfy both sides.  
Source URL: https://effectivetypescript.com/2021/11/11/optional-never/ citeturn933169search30

Name: Treat `readonly` as shallow and static  
Category: Immutability semantics  
Impact: Medium  
Consensus: High  
Description: Do not interpret TypeScript `readonly` as deep runtime immutability.  
Why: Nested values may remain mutable, and aliases with mutable types can still modify the same runtime object.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/objects.html citeturn935437view2

Name: Do not treat `as const` as deep immutability  
Category: Literal inference  
Impact: Medium  
Consensus: High  
Description: Use `as const` for literal preservation and readonly tuple/property inference, not as a guarantee that every referenced nested object can never mutate.  
Why: A const assertion changes static inference but does not freeze the runtime object graph.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html citeturn113548search17

Name: Use branded types when structurally identical primitives represent different domains  
Category: Nominal modeling  
Impact: Medium  
Consensus: High  
Description: For values such as validated strings, IDs, currencies, or tokens that share an underlying primitive but must not be interchangeable, introduce a brand or `unique symbol` marker where the distinction is valuable.  
Why: Plain aliases such as `type UserId = string` and `type ProductId = string` remain structurally interchangeable.  
Source URL: https://www.typescriptlang.org/play/typescript/language-extensions/nominal-typing.ts.html citeturn128915search0

Name: Use literal unions for closed value sets  
Category: Domain modeling  
Impact: Medium  
Consensus: High  
Description: Prefer `"open" | "closed"` over plain `string` when the actual domain contains a known finite set of string values.  
Why: The type then rejects invalid states and improves narrowing, autocomplete, and exhaustive handling.  
Source URL: https://www.typescriptlang.org/docs/handbook/literal-types.html citeturn933169search8

Name: Do not use `{}` to mean an empty object  
Category: Top types and object types  
Impact: Medium  
Consensus: High  
Description: `{}` means essentially any non-nullish value, including primitives; use a precise object shape, `object`, `unknown`, or another type matching the actual intent.  
Why: Treating `{}` as "object with no properties" creates unexpectedly broad APIs and constraints.  
Source URL: https://typescript-eslint.io/rules/no-empty-object-type/ citeturn216272search20

Name: Use primitive type names, not boxed wrapper types  
Category: Primitive modeling  
Impact: Medium  
Consensus: High  
Description: Use `string`, `number`, `boolean`, `symbol`, and `object`, not `String`, `Number`, `Boolean`, `Symbol`, or `Object`.  
Why: The capitalized forms describe boxed objects with materially different and usually unintended semantics.  
Source URL: https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html citeturn935437view6

Name: Avoid the `Function` type  
Category: Function typing  
Impact: Medium  
Consensus: High  
Description: Describe callable values with an actual call signature instead of `Function`.  
Why: `Function` provides almost no useful information about accepted arguments or returned values and enables unsafe calls.  
Source URL: https://typescript-eslint.io/rules/no-unsafe-function-type/ citeturn107781search16

Name: Make generic parameters structurally meaningful  
Category: Generic modeling  
Impact: Medium  
Consensus: High  
Description: Do not expect `Thing<A>` and `Thing<B>` to be distinct if `Thing<T>` never uses `T` in its structure.  
Why: TypeScript is structural, so an unused phantom type parameter has no effect on assignability unless represented by a member or brand.  
Source URL: https://www.typescriptlang.org/docs/handbook/type-compatibility.html citeturn113548search1

Name: Prefer explicit type-only imports with predictable emit  
Category: Module emit  
Impact: Medium  
Consensus: High  
Description: Use `import type` and `export type`, commonly with `verbatimModuleSyntax`, when an import exists only for the type system.  
Why: It makes the runtime/type boundary explicit and avoids relying on complex import-elision inference.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-8.html citeturn113548search12

Name: Prefer top-level `import type` when every imported binding is type-only  
Category: Module side effects  
Impact: Medium  
Consensus: High  
Description: Under `verbatimModuleSyntax`, prefer `import type { A, B } from "mod"` over `import { type A, type B } from "mod"` when there are no runtime bindings.  
Why: The inline form can emit `import {} from "mod"`, preserving an unintended runtime side-effect import.  
Source URL: https://typescript-eslint.io/rules/no-import-type-side-effects citeturn742315search1

Name: Check unresolved side-effect imports  
Category: Module correctness  
Impact: Medium  
Consensus: High  
Description: Keep `noUncheckedSideEffectImports` enabled rather than allowing misspelled or missing side-effect-only modules to disappear silently.  
Why: A side-effect import often exists specifically to initialize runtime behavior, so silently failing to resolve it can change program behavior.  
Source URL: https://www.typescriptlang.org/tsconfig/noUncheckedSideEffectImports.html citeturn107781search44

Name: Force module treatment when files should never be global scripts  
Category: Module scope  
Impact: Medium  
Consensus: High  
Description: Use `moduleDetection: "force"` or explicit module syntax in projects where source files should not contribute declarations to the global scope.  
Why: Script files share global scope and can produce accidental cross-file globals and surprising declaration collisions.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-7.html citeturn638739search0

Name: Enforce import filename casing  
Category: Cross-platform correctness  
Impact: Medium  
Consensus: High  
Description: Keep `forceConsistentCasingInFileNames` enabled.  
Why: Case-insensitive development filesystems can accept imports that fail on case-sensitive CI or production filesystems.  
Source URL: https://www.typescriptlang.org/tsconfig/ citeturn463657search2

Name: Require explicit `override` markers  
Category: Class inheritance  
Impact: Medium  
Consensus: High  
Description: Enable `noImplicitOverride` so an overriding member must explicitly say `override`.  
Why: It catches accidental shadowing and exposes refactors where a base member was renamed or removed while derived classes silently retain unrelated members.  
Source URL: https://www.typescriptlang.org/docs/handbook/compiler-options.html citeturn463657search4

Name: Detect missing return paths  
Category: Control-flow checking  
Impact: Medium  
Consensus: High  
Description: Consider `noImplicitReturns` for functions whose control paths are expected to return consistently.  
Why: It catches branches that accidentally fall through and return `undefined` instead of the intended value.  
Source URL: https://www.typescriptlang.org/docs/handbook/compiler-options.html citeturn463657search4

Name: Signal uncertain index-signature properties with bracket access  
Category: Indexed object APIs  
Impact: Medium  
Consensus: High  
Description: Consider `noPropertyAccessFromIndexSignature` when dictionary-like objects mix declared properties and arbitrary keys.  
Why: Bracket access visually distinguishes a known property from one whose existence is supplied only by an index signature.  
Source URL: https://www.typescriptlang.org/tsconfig/noPropertyAccessFromIndexSignature.html citeturn190211search1

Name: Keep built-in iterator return values strict  
Category: Iterator typing  
Impact: Medium  
Consensus: High  
Description: Retain `strictBuiltinIteratorReturn`, normally via `strict`, rather than allowing iterator completion values to leak `any`.  
Why: Older iterator typing could make `.next().value` substantially less safe than the iterator's actual return behavior.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-6.html citeturn107781search5turn107781search31

Name: Use `skipLibCheck` deliberately, not as a universal fix  
Category: Declaration checking  
Impact: Medium  
Consensus: High  
Description: Treat `skipLibCheck` as a performance or migration tradeoff and fix duplicate or incompatible dependency declarations when practical.  
Why: It saves work by skipping declaration-file checking at the expense of type-system accuracy and can conceal inconsistent dependencies.  
Source URL: https://www.typescriptlang.org/tsconfig/ citeturn463657search0

Name: Do not treat `exclude` as an import firewall  
Category: Project file inclusion  
Impact: Medium  
Consensus: High  
Description: Remember that `exclude` only changes what `include` discovers; imported or explicitly referenced files can still become part of the program.  
Why: Assuming otherwise can unexpectedly typecheck, emit, or expose files thought to be excluded.  
Source URL: https://www.typescriptlang.org/tsconfig/ citeturn596557search2

Name: Understand that `types` controls globals, not imported package types  
Category: Ambient type configuration  
Impact: Medium  
Consensus: High  
Description: Use `types` to control automatically included global `@types` packages, not to restrict types available through explicit imports.  
Why: Misunderstanding the option leads to missing globals or false expectations about dependency isolation. TypeScript 6 and 7 also use an empty default set, making explicit configuration more important during migration.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-6-0.html citeturn921293search0

Name: Import `.ts` extensions only when the runtime/build pipeline supports them  
Category: Module specifiers  
Impact: Medium  
Consensus: High  
Description: Use `allowImportingTsExtensions` only in no-emit/declaration-only or compatible runtime workflows rather than assuming emitted JavaScript can resolve `.ts` files.  
Why: TypeScript does not normally transform a `.ts` specifier into a runnable JavaScript path.  
Source URL: https://www.typescriptlang.org/tsconfig/allowImportingTsExtensions.html citeturn128915search30turn463657search6

Name: Do not use `paths` to fake monorepo packages  
Category: Monorepo module resolution  
Impact: Medium  
Consensus: High  
Description: Use package-manager workspaces or actual package resolution for sibling packages rather than pointing `paths` directly into another package.  
Why: `paths` bypasses normal package resolution features such as `exports`, `types`, and `typesVersions`, so development may not model installed behavior.  
Source URL: https://www.typescriptlang.org/docs/handbook/modules/reference.html citeturn935437view4

Name: Prefer ES modules over TypeScript namespaces in modern code  
Category: Code organization  
Impact: Medium  
Consensus: High  
Description: Use standard ES modules for normal application and library organization; reserve namespaces primarily for declaration or legacy scenarios where they are actually required.  
Why: ES modules align with JavaScript's runtime module system, tooling, and ecosystem direction.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/modules.html citeturn921293search3

Name: Do not disable `esModuleInterop` to obtain stricter ESM behavior  
Category: ESM/CJS interoperability  
Impact: Medium  
Consensus: High  
Description: For modern projects, use current interop behavior and `verbatimModuleSyntax` when you need less transformation rather than turning `esModuleInterop` off.  
Why: Disabling interop historically permitted module-namespace semantics that violate ESM expectations and made migration harder; TypeScript 6 deprecated the false setting.  
Source URL: https://www.typescriptlang.org/docs/handbook/modules/appendices/esm-cjs-interop.html citeturn921293search12turn128915search27

Name: Prefer `@ts-expect-error` over `@ts-ignore`  
Category: Diagnostic suppression  
Impact: Medium  
Consensus: High  
Description: When a type error genuinely must be suppressed, use `@ts-expect-error`, ideally with an explanation, rather than an indefinite `@ts-ignore`.  
Why: `@ts-expect-error` itself becomes an error once the suppressed error disappears, preventing stale suppressions from silently remaining.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-9.html citeturn579747search0

Name: Do not mark callback parameters optional just because callers may ignore them  
Category: Callback API design  
Impact: Medium  
Consensus: High  
Description: In a callback type, write `index: number`, not `index?: number`, when the API always supplies the argument.  
Why: An optional callback parameter means the implementation is permitted to omit it; TypeScript already allows callers to provide callbacks accepting fewer arguments.  
Source URL: https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html citeturn935437view6

Name: Declare ignored callback returns as `void`, not `any`  
Category: Callback API design  
Impact: Medium  
Consensus: High  
Description: When an API ignores a callback's return value, declare the callback as returning `void` rather than `any`.  
Why: `any` allows the API implementation to accidentally consume the unchecked callback result, whereas `void` prevents that use.  
Source URL: https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html citeturn935437view6

Name: Prefer union parameters over unnecessary overloads  
Category: Function API design  
Impact: Medium  
Consensus: High  
Description: If multiple overloads have the same arity and return behavior and differ mainly by argument type, prefer one signature with a union parameter.  
Why: Union signatures are easier to call with union-typed values and reduce overload-resolution complexity.  
Source URL: https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html citeturn113548search8

Name: Remember that overload implementation signatures are hidden  
Category: Function overloads  
Impact: Medium  
Consensus: High  
Description: Do not assume callers can use a parameter combination merely because the implementation signature accepts it; expose every supported call shape through overload signatures.  
Why: TypeScript resolves calls against the public overload list, not the implementation signature.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/functions.html citeturn935437view3

Name: Put specific overloads before general ones  
Category: Function overloads  
Impact: Medium  
Consensus: High  
Description: Order more specific overloads before broad catch-all overloads.  
Why: Overload resolution can select an earlier matching signature, so a broad signature can hide a more precise result type.  
Source URL: https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html citeturn935437view6

Name: Push generic type parameters down  
Category: Generic inference  
Impact: Medium  
Consensus: High  
Description: Prefer `<T>(arg: T[])` to `<T extends any[]>(arg: T)` when the operation only needs the array element type.  
Why: Over-constraining the parameter can force property access through the constraint and produce poorer inference, including `any`.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/functions.html citeturn107781search39

Name: Use as few generic parameters as the relationship requires  
Category: Generic API design  
Impact: Medium  
Consensus: High  
Description: Remove type parameters that do not meaningfully relate two or more positions or otherwise contribute information.  
Why: Unnecessary type parameters complicate inference and can make APIs appear more type-safe or flexible than they really are.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/functions.html citeturn107781search39

Name: Do not fabricate a subtype from only its generic constraint  
Category: Generic soundness  
Impact: Medium  
Consensus: High  
Description: If a function promises to return `T extends Base`, do not construct and return merely a `Base` value as though it were an arbitrary caller-provided `T`.  
Why: The caller's subtype may contain additional required invariants or properties that the generic implementation cannot know how to create.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/functions.html citeturn935437view3

Name: Remember that conditional types distribute over naked unions  
Category: Conditional types  
Impact: Medium  
Consensus: High  
Description: `T extends U ? X : Y` distributes when `T` is a naked type parameter; wrap both sides in tuples such as `[T] extends [U]` when whole-union testing is intended.  
Why: Unintended distributivity can produce radically different and much larger resulting types.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/conditional-types citeturn638739search17

Name: Use `const` type parameters when an API needs literal-preserving inference  
Category: Generic inference  
Impact: Medium  
Consensus: High  
Description: For APIs that routinely require callers to write `as const`, consider a `const` type parameter with an appropriate readonly constraint.  
Why: It moves literal-preserving inference into the API contract and avoids relying on every caller to remember a const assertion.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-0.html citeturn107781search2

Name: Do not spread values into objects merely because TypeScript permits it  
Category: Object spread semantics  
Impact: Medium  
Consensus: High  
Description: Be cautious spreading arrays, Promises, functions, class instances, Maps, Sets, and other non-record values into object literals.  
Why: Object spread copies enumerable own properties, which often has little relationship to the conceptual value being spread and can silently discard important state.  
Source URL: https://typescript-eslint.io/rules/no-misused-spread/ citeturn107781search7

Name: Do not use `delete` to remove an array element  
Category: Array semantics  
Impact: Medium  
Consensus: High  
Description: Use `splice`, filtering, or another explicit array operation rather than `delete array[index]`.  
Why: `delete` creates a sparse hole while leaving the array's length unchanged, which rarely matches the intended array semantics.  
Source URL: https://typescript-eslint.io/rules/no-array-delete/ citeturn216272search1

Name: Do not detach methods that depend on `this`  
Category: Method binding  
Impact: Medium  
Consensus: High  
Description: Bind the method, wrap it, use an arrow-property function, or annotate `this: void` when a method genuinely does not depend on a receiver.  
Why: Extracting a method from its object loses its receiver even though its type may otherwise look callable.  
Source URL: https://typescript-eslint.io/rules/unbound-method/ citeturn596557search8

Name: Use JavaScript `#private` when runtime privacy matters  
Category: Class encapsulation  
Impact: Medium  
Consensus: High  
Description: Use ECMAScript private fields for hard runtime privacy rather than assuming the TypeScript `private` modifier creates an inaccessible runtime slot.  
Why: TypeScript `private` is primarily a static restriction, while `#private` is enforced by JavaScript itself.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/classes.html citeturn935437view5

Name: Use `declare` for type-only inherited field refinement  
Category: Class field semantics  
Impact: Medium  
Consensus: High  
Description: When narrowing the type of an inherited class field without changing its runtime value, write `declare field: NarrowerType` instead of redeclaring a normal field.  
Why: Under standard class-field semantics, a derived field declaration can run after `super()` and overwrite the value initialized by the base class.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/classes.html citeturn935437view5

Name: Do not expect `implements` to supply contextual typing  
Category: Class/interface contracts  
Impact: Medium  
Consensus: High  
Description: Explicitly type class members as needed even when the class has an `implements Interface` clause.  
Why: `implements` checks compatibility after the member's own type has been determined; it does not automatically infer or rewrite that member's parameter types.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/classes.html citeturn128915search2

Name: Treat Promise rejection callback values as `unknown`  
Category: Async error handling  
Impact: Medium  
Consensus: High  
Description: Annotate `.catch((error: unknown) => ...)` or enforce the corresponding lint rule.  
Why: `useUnknownInCatchVariables` applies to language `catch` clauses but not to `Promise.prototype.catch`, whose callback parameter is otherwise `any`.  
Source URL: https://typescript-eslint.io/rules/use-unknown-in-catch-callback-variable/ citeturn596557search6

Name: Do not rely on value-returning functions fitting `void` contracts without considering the result  
Category: Function return semantics  
Impact: Medium  
Consensus: Medium  
Description: TypeScript intentionally permits a value-returning function where `() => void` is expected; use `strict-void-return` when your architecture treats ignored return values as suspicious.  
Why: The rule can expose ignored Promises, generators, accidental `.map`/`.forEach` confusion, and mismatches between static `void` and runtime return values.  
Source URL: https://typescript-eslint.io/rules/strict-void-return/ citeturn742315search0

Name: Give enum members explicit values when the values cross boundaries  
Category: Enum stability  
Impact: Medium  
Consensus: High  
Description: Explicitly initialize enum members when their numeric/string values are persisted, serialized, stored in databases, sent over APIs, or otherwise externally significant.  
Why: Automatic numeric numbering can shift when members are inserted or reordered.  
Source URL: https://typescript-eslint.io/rules/prefer-enum-initializers/ citeturn216272search2

Name: Use type-aware linting for checks the compiler intentionally does not perform  
Category: Static analysis  
Impact: Medium  
Consensus: High  
Description: For production TypeScript, consider a typescript-eslint type-checked preset rather than relying on `tsc` alone.  
Why: Type-aware linting catches deliberately permitted TypeScript behaviors such as floating Promises, unsafe `any` propagation, unbound methods, and incomplete switches.  
Source URL: https://typescript-eslint.io/rules/ citeturn107781search6turn958099search1

Name: Be cautious with generic object spread return types  
Category: Generic object modeling  
Impact: Medium  
Consensus: Medium  
Description: Avoid treating a generic object spread as though its type-level intersection precisely models runtime overwrite behavior, especially in reusable generic helpers.  
Why: TypeScript historically models generic spread using intersections even though JavaScript performs shallow property overwrite, creating potential mismatches.  
Source URL: https://effectivetypescript.com/2021/05/06/unsoundness/ citeturn933169search27

Name: Account for the TypeScript 7 compiler-API transition  
Category: Toolchain compatibility  
Impact: Medium  
Consensus: High  
Description: As of TypeScript 7.0, tools requiring the programmatic TypeScript compiler API may still need TypeScript 6 through `@typescript/typescript6` or the documented alias arrangement until the new API arrives.  
Why: TypeScript 7.0 ships the compiler and language service but not the stable programmatic API expected for 7.1, so blindly upgrading the `typescript` package can break API-dependent tooling.  
Source URL: https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/ citeturn958099search0

Name: Put the `"types"` condition first in package exports  
Category: Library publishing  
Impact: Medium  
Consensus: High  
Description: When publishing conditional package exports with dedicated declaration paths, place the `"types"` condition before runtime conditions.  
Why: Conditional export ordering participates in resolution, and TypeScript explicitly requires this ordering for the intended declaration branch to win.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-7.html citeturn638739search0

#### 3. Low Impact

Name: Consider `as const` objects instead of enums when runtime enum machinery is unnecessary  
Category: Runtime representation  
Impact: Low  
Consensus: Medium  
Description: For simple constant sets, a plain object with `as const` plus derived union types can often replace a TypeScript enum; ordinary enums remain valid when their runtime object semantics are useful.  
Why: The object approach stays closer to standard JavaScript and avoids adding a TypeScript-specific runtime construct.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html citeturn113548search17

Name: Avoid heterogeneous enums  
Category: Enum modeling  
Impact: Low  
Consensus: High  
Description: Do not mix numeric and string members in one enum without a strong interoperability reason.  
Why: Heterogeneous runtime representations complicate reasoning and usually provide no advantage over a consistent enum or union.  
Source URL: https://www.typescriptlang.org/docs/handbook/enums.html citeturn935437view7

Name: Avoid accidental duplicate enum values  
Category: Enum modeling  
Impact: Low  
Consensus: High  
Description: Give different enum members different values unless aliases are intentional and documented.  
Why: Duplicate values make reverse interpretation and equality-based logic ambiguous.  
Source URL: https://typescript-eslint.io/rules/no-duplicate-enum-values/ citeturn216272search4

Name: Compare enums through enum members rather than raw underlying values  
Category: Enum abstraction  
Impact: Low  
Consensus: High  
Description: Prefer `status === Status.Ready` over `status === 2` or the equivalent raw string when the value is conceptually an enum.  
Why: Raw comparisons couple code to the enum's current representation and can survive a value change incorrectly.  
Source URL: https://typescript-eslint.io/rules/no-unsafe-enum-comparison/ citeturn989542search10

Name: Use `NoInfer` when one argument should validate but not influence inference  
Category: Generic inference control  
Impact: Low  
Consensus: High  
Description: Use `NoInfer<T>` for secondary inputs such as defaults that must conform to a type inferred elsewhere but should not widen that inferred type.  
Why: Without it, an invalid secondary argument can become another inference candidate and broaden the generic type enough to accept itself.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-4.html citeturn933169search18

Name: Remember utility inference over overloads uses the last signature  
Category: Type-level function introspection  
Impact: Low  
Consensus: High  
Description: Do not expect conditional inference or utilities such as `ReturnType` to perform overload resolution for a hypothetical call; overloaded types are generally inferred from their final signature.  
Why: A broad final implementation-style signature can therefore produce less specific type-level results than individual overloads suggest.  
Source URL: https://www.typescriptlang.org/docs/handbook/advanced-types.html citeturn107781search36

Name: Do not use variance annotations as a way to force structural variance  
Category: Advanced generics  
Impact: Low  
Consensus: High  
Description: Normally let TypeScript infer variance; add `in`/`out` annotations only for accurately understood recursive types, diagnostics, or measured performance cases.  
Why: Variance annotations do not override structural comparison semantics and incorrect annotations can create unpredictable expectations.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/generics.html citeturn113548search0

Name: Do not assume `rootDir` controls what enters the program  
Category: Project file layout  
Impact: Low  
Consensus: High  
Description: Use `include`, `files`, references, and import structure to control program membership; use `rootDir` primarily to define source/output layout expectations.  
Why: `rootDir` does not itself exclude source files from type checking.  
Source URL: https://www.typescriptlang.org/tsconfig/rootDir.html citeturn401290search7

Name: Prefer interface extension over large object intersections when composition is equivalent  
Category: Compiler scalability  
Impact: Low  
Consensus: High  
Description: In heavily composed object hierarchies, prefer `interface Foo extends A, B` over repeatedly constructing `A & B & {...}` when either representation meets the semantic need.  
Why: Interfaces flatten relationships, report property conflicts more directly, and are generally easier for the checker to cache and compare.  
Source URL: https://github.com/microsoft/TypeScript/wiki/Performance citeturn107781search1

Name: Name repeatedly evaluated complex types  
Category: Compiler scalability  
Impact: Low  
Consensus: High  
Description: Extract heavily reused conditional, mapped, or other complex anonymous types into named aliases when type-checking performance becomes material.  
Why: Named types give the compiler opportunities to reuse cached results instead of repeatedly evaluating the same complex expression.  
Source URL: https://github.com/microsoft/TypeScript/wiki/Performance citeturn107781search1

Name: Add explicit exported return types when profiling shows inference cost  
Category: Compiler scalability  
Impact: Low  
Consensus: High  
Description: Do not annotate every trivial expression, but consider explicit return and public API types in declaration-heavy or very large projects where compiler profiling identifies inference/serialization cost.  
Why: Named explicit types can reduce work and produce smaller, more stable declaration representations.  
Source URL: https://github.com/microsoft/TypeScript/wiki/Performance citeturn107781search1

Name: Break very large workspaces into project references when scale warrants it  
Category: Compiler scalability  
Impact: Low  
Consensus: High  
Description: Use project references when a workspace becomes large enough that build or editor scale is itself a demonstrated problem.  
Why: References divide the program into independently understandable units and can materially improve build and editor interaction at scale.  
Source URL: https://www.typescriptlang.org/tsconfig/ citeturn596557search2

Name: Consider `isolatedDeclarations` for scalable library declaration generation  
Category: Declaration generation  
Impact: Low  
Consensus: High  
Description: Library/tooling authors who need declaration generation without whole-program inference can use `isolatedDeclarations` and explicitly type the necessary exported surface.  
Why: It makes declaration emit locally derivable and enables more parallel or third-party declaration-generation workflows.  
Source URL: https://www.typescriptlang.org/tsconfig/isolatedDeclarations.html citeturn128915search4turn128915search1

Name: Remember that `typesVersions` can be bypassed by `"exports"` resolution  
Category: Library publishing  
Impact: Low  
Consensus: High  
Description: If a package uses conditional `"exports"`, do not assume a separate `typesVersions` mapping will also participate in that resolution path; use versioned `"types@..."` export conditions when necessary.  
Why: TypeScript does not read `typesVersions` in cases where package `"exports"` are being resolved.  
Source URL: https://www.typescriptlang.org/docs/handbook/modules/reference.html citeturn638739search6turn638739search4

Name: Check runtime support when using explicit resource management  
Category: Runtime feature support  
Impact: Low  
Consensus: High  
Description: When using `using`, `await using`, `DisposableStack`, or related facilities against older runtimes, configure the appropriate libraries and provide the required runtime support or polyfills.  
Why: TypeScript can typecheck or downlevel parts of the feature, but runtime disposal symbols and supporting objects must actually exist.  
Source URL: https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-2.html citeturn921293search2

Name: Keep getter and setter types logically related  
Category: Accessor contracts  
Impact: Low  
Consensus: Medium  
Description: TypeScript permits explicitly annotated getter and setter types that are completely unrelated, but prefer a getter type assignable to its corresponding setter type unless the unusual asymmetry is intentional.  
Why: Unrelated types make ordinary reasoning such as `obj.value = obj.value` fail and can make property APIs surprisingly difficult to use.  
Source URL: https://typescript-eslint.io/rules/related-getter-setter-pairs/ citeturn742315search3

Name: Avoid type-level redundancy that hides widening  
Category: Union and intersection hygiene  
Impact: Low  
Consensus: Medium  
Description: Remove constituents such as `string | "foo"`, `unknown | T`, or `any | T` when the broader type completely absorbs the narrower one unless the redundancy is deliberately documentary.  
Why: Redundant constituents can make a type appear more constrained than it actually is, particularly when `any` or `unknown` has erased useful information.  
Source URL: https://typescript-eslint.io/rules/no-redundant-type-constituents/ citeturn742315search4

Name: Do not add explicit variance annotations as routine documentation  
Category: Advanced generics  
Impact: Low  
Consensus: High  
Description: Even when variance is understood, avoid sprinkling `in` and `out` through normal APIs solely to document intent.  
Why: TypeScript already derives variance structurally, and its documentation explicitly describes manual annotations as rarely necessary.  
Source URL: https://www.typescriptlang.org/docs/handbook/2/generics.html citeturn113548search0

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

I’ll preserve the original finding names and convert each finding independently, including conditional and lower-consensus cases. I’ll keep the normative strength proportional to the evidence rather than treating the whole set as mandatory.

-----
#### Assistant said:

Name: Enable the `strict` family  
Rule: TypeScript projects SHOULD enable `strict: true`; individual strict checks SHOULD be disabled only when a concrete compatibility constraint requires it.

Name: Keep `strictNullChecks` enabled  
Rule: TypeScript projects MUST enable `strictNullChecks` so `null` and `undefined` are not implicitly assignable to non-nullish types.

Name: Reject implicit `any`  
Rule: TypeScript projects MUST enable `noImplicitAny` and MUST NOT allow unresolved parameter or variable types to silently become `any`.

Name: Prefer `unknown` over `any` for unknown values  
Rule: Values whose type is genuinely unknown SHOULD be typed as `unknown`; `any` SHOULD be reserved for deliberate type-checking escape hatches.

Name: Prevent `any` from propagating  
Rule: Unavoidable `any` values MUST be contained at explicit boundaries and MUST NOT propagate unchecked through assignment, arguments, calls, member access, or returns.

Name: Validate external data at runtime  
Rule: External or untrusted data MUST be runtime-validated before it is treated as satisfying a TypeScript application type.

Name: Narrow instead of asserting  
Rule: Code SHOULD establish a value's type through narrowing or validation rather than `as T`; assertions SHOULD be limited to invariants established outside the type system.

Name: Treat double assertions as an escape hatch  
Rule: Double assertions such as `value as unknown as T` SHOULD NOT be used except at deliberate unsafe boundaries where the asserted invariant is externally guaranteed.

Name: Avoid routine non-null assertions  
Rule: Non-null assertions (`!`) SHOULD NOT be used when nullability can be proven through control flow, validation, or more accurate types.

Name: Treat indexed access as potentially missing  
Rule: Indexed access whose key or index is not statically guaranteed to exist MUST be treated as potentially missing, with `noUncheckedIndexedAccess` SHOULD be enabled where practical.

Name: Model variants as discriminated unions  
Rule: Mutually related object variants with variant-specific fields SHOULD be modeled as discriminated unions rather than one object type with independently optional fields.

Name: Make closed unions exhaustive  
Rule: Control flow that handles a closed discriminated union or enum MUST detect unhandled variants exhaustively.

Name: Never accidentally float Promises  
Rule: Every created Promise MUST be awaited, returned, aggregated, explicitly handled, or deliberately marked as intentionally unhandled.

Name: Do not pass async functions to APIs expecting `void` callbacks  
Rule: An async function MUST NOT be passed to a `void`-returning callback position unless its returned Promise is explicitly handled.

Name: Use `return await` when the surrounding `try`/`catch` must handle rejection  
Rule: A Promise returned from within a `try` block MUST be awaited before returning when the surrounding `catch` is intended to handle its rejection.

Name: Match `module` and `moduleResolution` to the actual runtime or bundler  
Rule: `module` and `moduleResolution` MUST model the module semantics of the runtime, bundler, or host that will actually execute or resolve the code.

Name: Do not mistake `paths` for runtime aliasing  
Rule: A TypeScript `paths` mapping MUST have an equivalent runtime or bundler mapping, and published output MUST NOT depend on private `paths` aliases.

Name: Use runtime-correct extensions in Node ESM  
Rule: Relative imports emitted for Node ESM MUST use module specifiers and file extensions that Node can resolve at runtime.

Name: Do not publish ambient `const enum`s  
Rule: Published declaration files MUST NOT expose ambient `const enum`s to consumers.

Name: Give CJS and ESM entrypoints separate declarations  
Rule: A package exposing distinct CommonJS and ESM entrypoints MUST provide declarations whose module format corresponds to each entrypoint.

Name: Treat declaration files as trusted claims, not runtime proof  
Rule: Successful checking against a `.d.ts` file MUST NOT be treated as proof that the corresponding runtime implementation satisfies those declarations.

Name: Keep property initialization checked  
Rule: Class properties MUST satisfy `strictPropertyInitialization`; definite-assignment assertions SHOULD be used only when initialization is guaranteed by a mechanism TypeScript cannot observe.

Name: Avoid class-interface declaration merging  
Rule: A class and same-named interface MUST NOT be merged to declare instance members unless those members are actually initialized at runtime.

Name: Do not confuse `lib` with runtime support  
Rule: The configured `lib` set MUST describe APIs supplied by the actual runtime or intentional polyfills and MUST NOT be used merely to silence missing-API errors.

Name: Use separate TypeScript projects for genuinely different environments  
Rule: Code targeting materially different runtime environments SHOULD be checked by separate TypeScript configurations or projects when their globals, libraries, or resolution semantics differ.

Name: Enable `isolatedModules` with single-file transpilers  
Rule: Projects transpiled by tools that process each file without whole-program type information MUST enable `isolatedModules`.

Name: Bundle declarations when bundling library JavaScript  
Rule: A library that bundles JavaScript modules MUST publish declarations whose module structure and imports are valid for the bundled package consumed by users.

Name: Do not assume TypeScript detects every CJS/ESM interop failure  
Rule: CJS/ESM interactions whose runtime compatibility TypeScript cannot verify MUST be exercised against the actual target runtime rather than accepted solely because type checking succeeds.

Name: Do not mix standard and legacy decorator semantics accidentally  
Rule: Decorator syntax, compiler settings, and framework expectations MUST consistently use either the supported standard decorator model or the required legacy decorator model.

Name: Keep type checking as a build or CI gate  
Rule: Any build pipeline that can emit JavaScript without type checking MUST run a separate required TypeScript type-checking step before successful completion.

Name: Enable `erasableSyntaxOnly` when relying on native Node type stripping  
Rule: Code executed through Node's native TypeScript type stripping MUST enable `erasableSyntaxOnly` or otherwise exclude TypeScript syntax requiring runtime transformation.

Name: Prefer function-property signatures where callback variance must be sound  
Rule: Callback members SHOULD use function-property signatures rather than method signatures when contravariant parameter checking is required for soundness.

Name: Accept `readonly` arrays when mutation is not required  
Rule: Function parameters accepting arrays SHOULD use `readonly T[]` or `ReadonlyArray<T>` when the function does not need to mutate the array.

Name: Do not trust refinements across mutation-capable calls  
Rule: A narrowed property MUST be captured, revalidated, or otherwise protected before use after a call that can mutate the narrowed object.

Name: Write type predicates that are valid in both branches  
Rule: A user-defined predicate returning `value is T` MUST guarantee that `true` establishes `T` and that `false` safely excludes `T`.

Name: Avoid caller-selected return-only generics  
Rule: APIs SHOULD NOT expose caller-selected return-only generics whose type parameter is neither inferred from input nor established by runtime validation.

Name: Distinguish absent optional properties from explicit `undefined`  
Rule: When property absence and explicit `undefined` have different semantics, the type model MUST preserve that distinction, such as by enabling `exactOptionalPropertyTypes`.

Name: Treat caught exceptions as `unknown`  
Rule: Caught exception values MUST be treated as `unknown` until narrowed to a usable type.

Name: Do not use truthiness when valid data can be falsy  
Rule: Truthiness checks MUST NOT be used to test presence when valid domain values can include `0`, `""`, `false`, or other falsy values.

Name: Prefer `??` to `||` for nullish defaults  
Rule: When a fallback applies only to `null` or `undefined`, code MUST use nullish semantics such as `??` rather than `||`.

Name: Remember that optional chaining only guards its chain  
Rule: The result of an optional chain MUST still be treated as potentially `undefined` by operations occurring after the guarded chain.

Name: Prefer `satisfies` when checking a value without widening it  
Rule: Code SHOULD use `satisfies` when a value must be checked against a type while retaining its narrower inferred literal type.

Name: Do not mistake excess-property checks for exact object types  
Rule: Code MUST NOT rely on excess-property checking to guarantee that a structurally typed runtime object contains no additional properties.

Name: Do not blindly cast `Object.keys` to `keyof T`  
Rule: `Object.keys(value)` SHOULD NOT be asserted as `(keyof T)[]` unless the runtime object is guaranteed to contain only keys represented by `T`.

Name: Remember that unions are inclusive  
Rule: When two object alternatives must be mutually exclusive, code MUST encode that exclusivity explicitly rather than assuming `A | B` prohibits values satisfying both.

Name: Treat `readonly` as shallow and static  
Rule: TypeScript `readonly` MUST NOT be treated as a guarantee of deep or runtime immutability.

Name: Do not treat `as const` as deep immutability  
Rule: `as const` MUST NOT be treated as a guarantee that the complete referenced object graph is immutable at runtime.

Name: Use branded types when structurally identical primitives represent different domains  
Rule: Structurally identical primitive values SHOULD use branded or otherwise nominal types when accidental interchange between their domains would be materially incorrect.

Name: Use literal unions for closed value sets  
Rule: A known finite set of permitted primitive values SHOULD be represented by literal types rather than an unconstrained primitive type.

Name: Do not use `{}` to mean an empty object  
Rule: `{}` MUST NOT be used to mean an object with no properties; code MUST use a type whose semantics match the intended value domain.

Name: Use primitive type names, not boxed wrapper types  
Rule: Type annotations MUST use primitive types such as `string`, `number`, `boolean`, and `symbol` instead of their boxed `String`, `Number`, `Boolean`, and `Symbol` types unless boxed objects are specifically required.

Name: Avoid the `Function` type  
Rule: Callable values SHOULD NOT be typed as `Function` when their call signature can be expressed explicitly.

Name: Make generic parameters structurally meaningful  
Rule: A generic parameter intended to affect assignability MUST participate in the type's structure; otherwise it SHOULD be removed or represented explicitly.

Name: Prefer explicit type-only imports with predictable emit  
Rule: Imports and exports used exclusively in type positions SHOULD use `import type` or `export type` when the project's emit model supports them.

Name: Prefer top-level `import type` when every imported binding is type-only  
Rule: Under `verbatimModuleSyntax`, an import containing only type bindings SHOULD use top-level `import type` rather than an empty-emitting value import.

Name: Check unresolved side-effect imports  
Rule: Projects relying on side-effect imports SHOULD enable `noUncheckedSideEffectImports` or otherwise require those imports to resolve successfully.

Name: Force module treatment when files should never be global scripts  
Rule: Projects in which source files are intended exclusively as modules SHOULD use `moduleDetection: "force"` or explicit module syntax to prevent accidental global scripts.

Name: Enforce import filename casing  
Rule: TypeScript projects SHOULD enable `forceConsistentCasingInFileNames`, and import path casing MUST match the actual file name.

Name: Require explicit `override` markers  
Rule: Projects using class inheritance SHOULD enable `noImplicitOverride` so members that override base-class members are explicitly marked `override`.

Name: Detect missing return paths  
Rule: Projects whose functions are expected to return consistently across control-flow paths SHOULD enable `noImplicitReturns`.

Name: Signal uncertain index-signature properties with bracket access  
Rule: Dictionary-like APIs whose undeclared keys come from index signatures SHOULD use `noPropertyAccessFromIndexSignature` when distinguishing known properties from arbitrary keys is important.

Name: Keep built-in iterator return values strict  
Rule: TypeScript projects SHOULD keep `strictBuiltinIteratorReturn` enabled, normally through `strict`, so iterator completion values do not degrade to unsafe types.

Name: Use `skipLibCheck` deliberately, not as a universal fix  
Rule: `skipLibCheck` SHOULD NOT be enabled merely to hide incompatible declarations; it SHOULD be used only as a deliberate performance or migration tradeoff.

Name: Do not treat `exclude` as an import firewall  
Rule: TypeScript configuration MUST NOT rely on `exclude` to prevent imported or referenced files from entering the program.

Name: Understand that `types` controls globals, not imported package types  
Rule: The `types` compiler option MUST be used only to control automatically included ambient type packages, not as a mechanism for restricting explicitly imported package types.

Name: Import `.ts` extensions only when the runtime/build pipeline supports them  
Rule: Source imports ending in `.ts` MUST NOT be used unless the configured emit and runtime pipeline explicitly supports those specifiers.

Name: Do not use `paths` to fake monorepo packages  
Rule: Monorepo package relationships SHOULD use actual package or workspace resolution rather than TypeScript `paths` mappings that bypass package `exports`, `types`, or related metadata.

Name: Prefer ES modules over TypeScript namespaces in modern code  
Rule: Modern application and library code SHOULD use standard ES modules instead of TypeScript namespaces unless namespace semantics are specifically required.

Name: Do not disable `esModuleInterop` to obtain stricter ESM behavior  
Rule: Projects SHOULD NOT disable `esModuleInterop` merely to obtain stricter ESM syntax or emit behavior; module syntax controls SHOULD be configured separately.

Name: Prefer `@ts-expect-error` over `@ts-ignore`  
Rule: A necessary TypeScript diagnostic suppression SHOULD use `@ts-expect-error` rather than `@ts-ignore` so stale suppressions become detectable.

Name: Do not mark callback parameters optional just because callers may ignore them  
Rule: A callback parameter MUST NOT be declared optional when the API always supplies that argument.

Name: Declare ignored callback returns as `void`, not `any`  
Rule: A callback whose return value is intentionally ignored MUST be declared as returning `void` rather than `any`.

Name: Prefer union parameters over unnecessary overloads  
Rule: Functions SHOULD use a union parameter instead of multiple overloads when the overloads have the same arity and return behavior and differ only by argument type.

Name: Remember that overload implementation signatures are hidden  
Rule: Every supported public call shape of an overloaded function MUST be represented by an overload signature rather than only by the implementation signature.

Name: Put specific overloads before general ones  
Rule: Overload declarations MUST place more specific matching signatures before broader catch-all signatures when ordering can affect resolution.

Name: Push generic type parameters down  
Rule: Generic constraints SHOULD expose only the structure required by the implementation rather than constraining a type parameter to a broader container type unnecessarily.

Name: Use as few generic parameters as the relationship requires  
Rule: Generic APIs SHOULD NOT introduce type parameters that do not contribute information or express a meaningful relationship in the API.

Name: Do not fabricate a subtype from only its generic constraint  
Rule: A generic function returning `T extends Base` MUST NOT construct only a `Base` value and return it as arbitrary `T` without additional evidence establishing that subtype.

Name: Remember that conditional types distribute over naked unions  
Rule: Conditional types MUST account for distributivity over naked type parameters, and non-distributive tests MUST use a non-distributive formulation when whole-union evaluation is intended.

Name: Use `const` type parameters when an API needs literal-preserving inference  
Rule: Generic APIs SHOULD use `const` type parameters when preserving caller literal types is part of the API contract and callers would otherwise require repeated `as const` assertions.

Name: Do not spread values into objects merely because TypeScript permits it  
Rule: Values SHOULD NOT be object-spread unless copying their enumerable own properties is the intended runtime operation.

Name: Do not use `delete` to remove an array element  
Rule: `delete array[index]` MUST NOT be used when the intent is to remove an element and compact the array.

Name: Do not detach methods that depend on `this`  
Rule: A method that depends on its receiver MUST NOT be passed or stored as an unbound function.

Name: Use JavaScript `#private` when runtime privacy matters  
Rule: Class state requiring runtime-enforced privacy MUST use JavaScript private fields or an equivalent runtime mechanism rather than relying only on TypeScript `private`.

Name: Use `declare` for type-only inherited field refinement  
Rule: A derived class that only refines the static type of an inherited field MUST use `declare` rather than emitting a new field initialization.

Name: Do not expect `implements` to supply contextual typing  
Rule: Class members MUST NOT rely on an `implements` clause to infer their parameter or member types when those types are not otherwise inferable.

Name: Treat Promise rejection callback values as `unknown`  
Rule: Promise rejection callback parameters MUST be treated as `unknown` until narrowed.

Name: Do not rely on value-returning functions fitting `void` contracts without considering the result  
Rule: A function passed to a `() => void` position SHOULD NOT return a value whose loss has semantic significance unless that value is handled explicitly.

Name: Give enum members explicit values when the values cross boundaries  
Rule: Enum members whose values are persisted, serialized, transmitted, or otherwise externally significant MUST have explicit stable values.

Name: Use type-aware linting for checks the compiler intentionally does not perform  
Rule: Production TypeScript projects SHOULD use type-aware static analysis for materially relevant hazards that `tsc` intentionally permits.

Name: Be cautious with generic object spread return types  
Rule: Generic object-spread helpers SHOULD NOT expose a naive intersection type when conflicting keys can make runtime overwrite semantics differ materially from that type.

Name: Account for the TypeScript 7 compiler-API transition  
Rule: TypeScript 7.0 toolchains that depend on the programmatic compiler API MUST use the documented TypeScript 6 compatibility package or equivalent until a compatible TypeScript 7 API is available.

Name: Put the `"types"` condition first in package exports  
Rule: Package export conditions that include a `"types"` branch MUST place `"types"` before the corresponding runtime conditions.

Name: Consider `as const` objects instead of enums when runtime enum machinery is unnecessary  
Rule: Closed constant sets SHOULD use an `as const` object plus derived types instead of an enum when enum-specific runtime behavior provides no material benefit.

Name: Avoid heterogeneous enums  
Rule: Enums SHOULD NOT mix string and numeric members unless an interoperability requirement specifically requires heterogeneous values.

Name: Avoid accidental duplicate enum values  
Rule: Distinct enum members SHOULD NOT share the same value unless the duplication is an intentional alias.

Name: Compare enums through enum members rather than raw underlying values  
Rule: Code SHOULD compare enum-typed values against enum members rather than their raw underlying literals when the enum abstraction is intended to be preserved.

Name: Use `NoInfer` when one argument should validate but not influence inference  
Rule: `NoInfer<T>` SHOULD be used when an argument must conform to an already inferred generic type but MUST NOT participate in inferring or widening that type.

Name: Remember utility inference over overloads uses the last signature  
Rule: Type-level inference utilities MUST NOT be assumed to resolve individual overloads when the desired result depends on a non-final overload signature.

Name: Do not use variance annotations as a way to force structural variance  
Rule: `in` and `out` annotations MUST NOT be used to override or force assignability behavior that conflicts with a type's actual structural variance.

Name: Do not assume `rootDir` controls what enters the program  
Rule: `rootDir` MUST NOT be used as the mechanism for controlling which files participate in a TypeScript program.

Name: Prefer interface extension over large object intersections when composition is equivalent  
Rule: When object composition is semantically equivalent and checker scalability is material, interface extension SHOULD be preferred over repeatedly composed large intersection types.

Name: Name repeatedly evaluated complex types  
Rule: Reused complex conditional, mapped, or composite types SHOULD be extracted into named aliases when repeated evaluation materially affects type-checking performance.

Name: Add explicit exported return types when profiling shows inference cost  
Rule: Exported functions SHOULD receive explicit return types when compiler profiling shows that inferring or serializing those types materially affects performance.

Name: Break very large workspaces into project references when scale warrants it  
Rule: Large TypeScript workspaces SHOULD use project references when workspace size demonstrably causes material build or editor scalability problems.

Name: Consider `isolatedDeclarations` for scalable library declaration generation  
Rule: Library builds requiring declaration generation without whole-program inference SHOULD use `isolatedDeclarations` and provide the exported annotations that mode requires.

Name: Remember that `typesVersions` can be bypassed by `"exports"` resolution  
Rule: Packages using `"exports"` and version-specific declarations MUST NOT rely on `typesVersions` where export resolution bypasses it; compatible versioned type conditions MUST be used instead.

Name: Check runtime support when using explicit resource management  
Rule: Code using `using`, `await using`, or related explicit-resource-management APIs MUST target a runtime that provides the required disposal support or supply compatible runtime support.

Name: Keep getter and setter types logically related  
Rule: Getter and setter types for the same property SHOULD remain mutually coherent, with unrelated types used only when the asymmetric contract is intentional.

Name: Avoid type-level redundancy that hides widening  
Rule: Redundant union or intersection constituents that are completely absorbed by broader constituents SHOULD be removed unless their presence is intentionally documentary.

Name: Do not add explicit variance annotations as routine documentation  
Rule: Explicit variance annotations SHOULD NOT be added solely as routine documentation when TypeScript can correctly infer the type's variance.
