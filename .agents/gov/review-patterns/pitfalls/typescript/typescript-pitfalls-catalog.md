# TypeScript Pitfalls Catalog
_Entry format: <index> **<canonical name>** _(impact: [high|medium|low]; consensus: [high|medium|low])_ - <concise definition>._

## 1. Core Type Safety and Variant Modeling

### Compiler strictness

1.1.1 **Enable the `strict` family** _(impact: high; consensus: high)_ - Use `strict: true` as the normal baseline rather than selectively opting into type safety after problems appear.
### Nullability

1.2.1 **Keep `strictNullChecks` enabled** _(impact: high; consensus: high)_ - Treat `null` and `undefined` as distinct types instead of allowing them to flow through ordinary values.
### Type inference safety

1.3.1 **Reject implicit `any`** _(impact: high; consensus: high)_ - Keep `noImplicitAny` enabled rather than allowing unresolved types to silently fall back to `any`.
### Dynamic-data boundaries

1.4.1 **Prefer `unknown` over `any` for unknown values** _(impact: high; consensus: high)_ - Use `unknown` when a value can legitimately be anything but must be inspected before use; reserve `any` for deliberate type-checking escape hatches.
1.4.2 **Prevent `any` from propagating** _(impact: high; consensus: high)_ - Use type-aware lint rules such as `no-unsafe-assignment`, `no-unsafe-argument`, `no-unsafe-call`, `no-unsafe-member-access`, and `no-unsafe-return` to contain unavoidable `any` values.
### Runtime type boundaries

1.5.1 **Validate external data at runtime** _(impact: high; consensus: high)_ - Parse and validate JSON, API responses, environment data, storage values, and other external inputs instead of asserting that they match TypeScript interfaces.
### Type assertion discipline

1.6.1 **Narrow instead of asserting** _(impact: high; consensus: high)_ - Prefer control-flow narrowing, validation, type guards, or checked construction over `as T`, especially assertions that narrow to a more specific type.
1.6.2 **Treat double assertions as an escape hatch** _(impact: high; consensus: high)_ - Avoid patterns such as `value as unknown as T` except at a deliberately audited unsafe boundary.
### Nullability

1.7.1 **Avoid routine non-null assertions** _(impact: high; consensus: high)_ - Prefer proving that a value is non-nullish rather than silencing the checker with `value!`.
### Indexed access safety

1.8.1 **Treat indexed access as potentially missing** _(impact: high; consensus: high)_ - Enable `noUncheckedIndexedAccess`, particularly for arrays, dictionaries, and index-signature-heavy code.
### Variant modeling

1.9.1 **Model variants as discriminated unions** _(impact: high; consensus: high)_ - Prefer separate union members with a literal discriminant over one large object containing many optional fields plus assertions.
### Exhaustiveness

1.10.1 **Make closed unions exhaustive** _(impact: high; consensus: high)_ - Exhaustively handle discriminated unions and enums with `never`, an `assertNever` pattern, or `switch-exhaustiveness-check`.

## 2. Asynchronous Behavior

### Async control flow

2.1.1 **Never accidentally float Promises** _(impact: high; consensus: high)_ - Await, return, aggregate, or explicitly handle every Promise rather than letting it become an unused expression.
### Async callback contracts

2.2.1 **Do not pass async functions to APIs expecting `void` callbacks** _(impact: high; consensus: high)_ - Avoid `async` callbacks in `forEach`, event APIs, or other `() => void` positions unless the returned Promise is deliberately handled. Use an awaited loop, `Promise.all`, or explicit rejection handling instead.
### Async error handling

2.3.1 **Use `return await` when the surrounding `try`/`catch` must handle rejection** _(impact: high; consensus: high)_ - Inside an error-handling context, use `return await promise` when a rejection is supposed to be caught locally rather than directly returning the Promise.

## 3. Module and Library Boundaries

### Module/runtime alignment

3.1.1 **Match `module` and `moduleResolution` to the actual runtime or bundler** _(impact: high; consensus: high)_ - Use Node modes for Node, `bundler` for bundler semantics, and otherwise configure TypeScript to model the actual host instead of choosing options solely to silence import errors.
3.1.2 **Do not mistake `paths` for runtime aliasing** _(impact: high; consensus: high)_ - Use `paths` only when the runtime or bundler implements the same mapping, and do not publish libraries whose emitted imports depend on private `paths` aliases.
### Node module semantics

3.2.1 **Use runtime-correct extensions in Node ESM** _(impact: high; consensus: high)_ - In Node ESM source, write relative specifiers that will be valid in emitted JavaScript, commonly `./file.js`, rather than assuming TypeScript will rewrite extensionless or `.ts` imports.
### Library API design

3.3.1 **Do not publish ambient `const enum`s** _(impact: high; consensus: high)_ - Prefer ordinary enums, literal objects, or de-constified declarations when publishing library APIs instead of exposing ambient `const enum` values to consumers.
### Library publishing

3.4.1 **Give CJS and ESM entrypoints separate declarations** _(impact: high; consensus: high)_ - A package exposing both CommonJS and ESM entrypoints should provide declaration files whose detected module formats correspond to each JavaScript entrypoint.
### Declaration trust boundaries

3.5.1 **Treat declaration files as trusted claims, not runtime proof** _(impact: high; consensus: high)_ - Investigate and correct inaccurate `.d.ts` declarations instead of assuming that successful type checking proves the dependency behaves as declared.

## 4. Runtime and Build Configuration

### Class initialization

4.1.1 **Keep property initialization checked** _(impact: high; consensus: high)_ - Keep `strictPropertyInitialization` enabled and use definite-assignment assertions only when an external initialization mechanism genuinely guarantees assignment.
### Declaration merging

4.2.1 **Avoid class-interface declaration merging** _(impact: high; consensus: high)_ - Do not merge a class and interface of the same name to add instance members unless the runtime actually initializes those members through a controlled mechanism.
### Runtime environment modeling

4.3.1 **Do not confuse `lib` with runtime support** _(impact: high; consensus: high)_ - Configure `lib` to describe APIs actually supplied by the target runtime or by intentional polyfills, rather than enabling newer libraries merely to eliminate type errors.
### Project configuration

4.4.1 **Use separate TypeScript projects for genuinely different environments** _(impact: high; consensus: high)_ - Use separate tsconfigs or project references when code is checked against materially different runtimes such as Node, DOM, workers, tests, or separately published packages.
### Transpilation compatibility

4.5.1 **Enable `isolatedModules` with single-file transpilers** _(impact: high; consensus: high)_ - Enable `isolatedModules` when Babel, SWC, esbuild, or another tool transpiles files without whole-program type information.
### Library publishing

4.6.1 **Bundle declarations when bundling library JavaScript** _(impact: high; consensus: high)_ - If a library bundles internal JavaScript modules, ensure its declaration output represents that bundled module structure rather than blindly publishing the unbundled declaration graph.
### Module/runtime alignment

4.7.1 **Do not assume TypeScript detects every CJS/ESM interop failure** _(impact: high; consensus: high)_ - Test actual Node interop behavior, particularly `require()` of ESM and CommonJS named imports, rather than treating successful type checking as a complete runtime compatibility test.
### Decorators

4.8.1 **Do not mix standard and legacy decorator semantics accidentally** _(impact: high; consensus: high)_ - Know whether a framework expects modern decorators or legacy `experimentalDecorators`; existing legacy decorators are not automatically compatible with the standard decorator model.
### Build correctness

4.9.1 **Keep type checking as a build or CI gate** _(impact: high; consensus: high)_ - If a bundler, transpiler, `--noCheck`, or transpile-only workflow emits JavaScript despite type errors, run a separate required type-checking step.
### Native TypeScript execution

4.10.1 **Enable `erasableSyntaxOnly` when relying on native Node type stripping** _(impact: high; consensus: high)_ - When running TypeScript directly through Node's type-stripping support, enable `erasableSyntaxOnly` or otherwise avoid TypeScript constructs requiring JavaScript transformation, such as enums, parameter properties, runtime namespaces, and `import =`.

## 5. Advanced Type-System Soundness

### Function variance

5.1.1 **Prefer function-property signatures where callback variance must be sound** _(impact: high; consensus: medium)_ - Under `strictFunctionTypes`, prefer properties such as `handler: (x: T) => void` for callback contracts where contravariant checking matters; method syntax retains bivariant parameter behavior for compatibility.
### Variance and mutation

5.2.1 **Accept `readonly` arrays when mutation is not required** _(impact: high; consensus: medium)_ - Type non-mutating array inputs as `readonly T[]` or `ReadonlyArray<T>` instead of mutable arrays.
### Control-flow refinement

5.3.1 **Do not trust refinements across mutation-capable calls** _(impact: high; consensus: medium)_ - If a callback or function call can mutate an object that has been narrowed, capture the narrowed primitive locally or expose a readonly view before the call.
### User-defined narrowing

5.4.1 **Write type predicates that are valid in both branches** _(impact: high; consensus: medium)_ - A function returning `x is T` should justify not only that `true` implies `T`, but also that `false` safely excludes `T`; avoid predicates based on thresholds or truthiness when that implication is false.
### Generic API safety

5.5.1 **Avoid caller-selected return-only generics** _(impact: high; consensus: medium)_ - Avoid APIs such as `parse<T>(input): T` when `T` is not inferred from or validated against an input; return `unknown` or a validated schema-derived type instead.

## 6. Nullish Semantics and Data Modeling

### Optional property semantics

6.1.1 **Distinguish absent optional properties from explicit `undefined`** _(impact: medium; consensus: high)_ - Enable `exactOptionalPropertyTypes` when property presence itself has meaning, rather than automatically treating `foo?: T` as permitting `foo: undefined`.
### Exception handling

6.2.1 **Treat caught exceptions as `unknown`** _(impact: medium; consensus: high)_ - Keep `useUnknownInCatchVariables` behavior and narrow caught values before assuming they are `Error` objects.
### Narrowing semantics

6.3.1 **Do not use truthiness when valid data can be falsy** _(impact: medium; consensus: high)_ - Prefer explicit nullish or domain-specific checks when `0`, `""`, `false`, or `NaN` are legitimate values.
### Nullish semantics

6.4.1 **Prefer `??` to `||` for nullish defaults** _(impact: medium; consensus: high)_ - Use nullish coalescing when the fallback should apply only to `null` or `undefined`.
6.4.2 **Remember that optional chaining only guards its chain** _(impact: medium; consensus: high)_ - Do not assume `foo?.bar` protects later independent operations such as arithmetic on the resulting value.
### Literal inference

6.5.1 **Prefer `satisfies` when checking a value without widening it** _(impact: medium; consensus: high)_ - For configuration objects, lookup tables, and similar values, use `satisfies` when you want structural validation while retaining the expression's precise inferred type.
### Structural object semantics

6.6.1 **Do not mistake excess-property checks for exact object types** _(impact: medium; consensus: high)_ - Treat TypeScript object types as open structural contracts; assigning an object literal directly gets special excess-property checking, but equivalent values can contain additional runtime keys.
### Structural object iteration

6.7.1 **Do not blindly cast `Object.keys` to `keyof T`** _(impact: medium; consensus: high)_ - Assume runtime objects may contain keys beyond their static type; use `Object.entries`, targeted validation, or a `keyof` cast only when exact keys are genuinely guaranteed.
### Union modeling

6.8.1 **Remember that unions are inclusive** _(impact: medium; consensus: high)_ - `A | B` allows a value satisfying both `A` and `B`; use a discriminant or an explicit XOR construction when mutual exclusivity is required.
### Immutability semantics

6.9.1 **Treat `readonly` as shallow and static** _(impact: medium; consensus: high)_ - Do not interpret TypeScript `readonly` as deep runtime immutability.
### Literal inference

6.10.1 **Do not treat `as const` as deep immutability** _(impact: medium; consensus: high)_ - Use `as const` for literal preservation and readonly tuple/property inference, not as a guarantee that every referenced nested object can never mutate.
### Nominal modeling

6.11.1 **Use branded types when structurally identical primitives represent different domains** _(impact: medium; consensus: high)_ - For values such as validated strings, IDs, currencies, or tokens that share an underlying primitive but must not be interchangeable, introduce a brand or `unique symbol` marker where the distinction is valuable.
### Domain modeling

6.12.1 **Use literal unions for closed value sets** _(impact: medium; consensus: high)_ - Prefer `"open" | "closed"` over plain `string` when the actual domain contains a known finite set of string values.
### Top types and object types

6.13.1 **Do not use `{}` to mean an empty object** _(impact: medium; consensus: high)_ - `{}` means essentially any non-nullish value, including primitives; use a precise object shape, `object`, `unknown`, or another type matching the actual intent.
### Primitive modeling

6.14.1 **Use primitive type names, not boxed wrapper types** _(impact: medium; consensus: high)_ - Use `string`, `number`, `boolean`, `symbol`, and `object`, not `String`, `Number`, `Boolean`, `Symbol`, or `Object`.

## 7. APIs, Modules, and Project Semantics

### Function typing

7.1.1 **Avoid the `Function` type** _(impact: medium; consensus: high)_ - Describe callable values with an actual call signature instead of `Function`.
### Generic modeling

7.2.1 **Make generic parameters structurally meaningful** _(impact: medium; consensus: high)_ - Do not expect `Thing<A>` and `Thing<B>` to be distinct if `Thing<T>` never uses `T` in its structure.
### Module emit

7.3.1 **Prefer explicit type-only imports with predictable emit** _(impact: medium; consensus: high)_ - Use `import type` and `export type`, commonly with `verbatimModuleSyntax`, when an import exists only for the type system.
### Module side effects

7.4.1 **Prefer top-level `import type` when every imported binding is type-only** _(impact: medium; consensus: high)_ - Under `verbatimModuleSyntax`, prefer `import type { A, B } from "mod"` over `import { type A, type B } from "mod"` when there are no runtime bindings.
### Module correctness

7.5.1 **Check unresolved side-effect imports** _(impact: medium; consensus: high)_ - Keep `noUncheckedSideEffectImports` enabled rather than allowing misspelled or missing side-effect-only modules to disappear silently.
### Module scope

7.6.1 **Force module treatment when files should never be global scripts** _(impact: medium; consensus: high)_ - Use `moduleDetection: "force"` or explicit module syntax in projects where source files should not contribute declarations to the global scope.
### Cross-platform correctness

7.7.1 **Enforce import filename casing** _(impact: medium; consensus: high)_ - Keep `forceConsistentCasingInFileNames` enabled.
### Class inheritance

7.8.1 **Require explicit `override` markers** _(impact: medium; consensus: high)_ - Enable `noImplicitOverride` so an overriding member must explicitly say `override`.
### Control-flow checking

7.9.1 **Detect missing return paths** _(impact: medium; consensus: high)_ - Consider `noImplicitReturns` for functions whose control paths are expected to return consistently.
### Indexed object APIs

7.10.1 **Signal uncertain index-signature properties with bracket access** _(impact: medium; consensus: high)_ - Consider `noPropertyAccessFromIndexSignature` when dictionary-like objects mix declared properties and arbitrary keys.
### Iterator typing

7.11.1 **Keep built-in iterator return values strict** _(impact: medium; consensus: high)_ - Retain `strictBuiltinIteratorReturn`, normally via `strict`, rather than allowing iterator completion values to leak `any`.
### Declaration checking

7.12.1 **Use `skipLibCheck` deliberately, not as a universal fix** _(impact: medium; consensus: high)_ - Treat `skipLibCheck` as a performance or migration tradeoff and fix duplicate or incompatible dependency declarations when practical.
### Project file inclusion

7.13.1 **Do not treat `exclude` as an import firewall** _(impact: medium; consensus: high)_ - Remember that `exclude` only changes what `include` discovers; imported or explicitly referenced files can still become part of the program.
### Ambient type configuration

7.14.1 **Understand that `types` controls globals, not imported package types** _(impact: medium; consensus: high)_ - Use `types` to control automatically included global `@types` packages, not to restrict types available through explicit imports.
### Module specifiers

7.15.1 **Import `.ts` extensions only when the runtime/build pipeline supports them** _(impact: medium; consensus: high)_ - Use `allowImportingTsExtensions` only in no-emit/declaration-only or compatible runtime workflows rather than assuming emitted JavaScript can resolve `.ts` files.
### Monorepo module resolution

7.16.1 **Do not use `paths` to fake monorepo packages** _(impact: medium; consensus: high)_ - Use package-manager workspaces or actual package resolution for sibling packages rather than pointing `paths` directly into another package.
### Code organization

7.17.1 **Prefer ES modules over TypeScript namespaces in modern code** _(impact: medium; consensus: high)_ - Use standard ES modules for normal application and library organization; reserve namespaces primarily for declaration or legacy scenarios where they are actually required.
### ESM/CJS interoperability

7.18.1 **Do not disable `esModuleInterop` to obtain stricter ESM behavior** _(impact: medium; consensus: high)_ - For modern projects, use current interop behavior and `verbatimModuleSyntax` when you need less transformation rather than turning `esModuleInterop` off.
### Diagnostic suppression

7.19.1 **Prefer `@ts-expect-error` over `@ts-ignore`** _(impact: medium; consensus: high)_ - When a type error genuinely must be suppressed, use `@ts-expect-error`, ideally with an explanation, rather than an indefinite `@ts-ignore`.

## 8. Function and Generic API Design

### Callback API design

8.1.1 **Do not mark callback parameters optional just because callers may ignore them** _(impact: medium; consensus: high)_ - In a callback type, write `index: number`, not `index?: number`, when the API always supplies the argument.
8.1.2 **Declare ignored callback returns as `void`, not `any`** _(impact: medium; consensus: high)_ - When an API ignores a callback's return value, declare the callback as returning `void` rather than `any`.
### Function API design

8.2.1 **Prefer union parameters over unnecessary overloads** _(impact: medium; consensus: high)_ - If multiple overloads have the same arity and return behavior and differ mainly by argument type, prefer one signature with a union parameter.
### Function overloads

8.3.1 **Remember that overload implementation signatures are hidden** _(impact: medium; consensus: high)_ - Do not assume callers can use a parameter combination merely because the implementation signature accepts it; expose every supported call shape through overload signatures.
8.3.2 **Put specific overloads before general ones** _(impact: medium; consensus: high)_ - Order more specific overloads before broad catch-all overloads.
### Generic inference

8.4.1 **Push generic type parameters down** _(impact: medium; consensus: high)_ - Prefer `<T>(arg: T[])` to `<T extends any[]>(arg: T)` when the operation only needs the array element type.
### Generic API design

8.5.1 **Use as few generic parameters as the relationship requires** _(impact: medium; consensus: high)_ - Remove type parameters that do not meaningfully relate two or more positions or otherwise contribute information.
### Generic soundness

8.6.1 **Do not fabricate a subtype from only its generic constraint** _(impact: medium; consensus: high)_ - If a function promises to return `T extends Base`, do not construct and return merely a `Base` value as though it were an arbitrary caller-provided `T`.
### Conditional types

8.7.1 **Remember that conditional types distribute over naked unions** _(impact: medium; consensus: high)_ - `T extends U ? X : Y` distributes when `T` is a naked type parameter; wrap both sides in tuples such as `[T] extends [U]` when whole-union testing is intended.
### Generic inference

8.8.1 **Use `const` type parameters when an API needs literal-preserving inference** _(impact: medium; consensus: high)_ - For APIs that routinely require callers to write `as const`, consider a `const` type parameter with an appropriate readonly constraint.

## 9. Object and Class Runtime Semantics

### Object spread semantics

9.1.1 **Do not spread values into objects merely because TypeScript permits it** _(impact: medium; consensus: high)_ - Be cautious spreading arrays, Promises, functions, class instances, Maps, Sets, and other non-record values into object literals.
### Array semantics

9.2.1 **Do not use `delete` to remove an array element** _(impact: medium; consensus: high)_ - Use `splice`, filtering, or another explicit array operation rather than `delete array[index]`.
### Method binding

9.3.1 **Do not detach methods that depend on `this`** _(impact: medium; consensus: high)_ - Bind the method, wrap it, use an arrow-property function, or annotate `this: void` when a method genuinely does not depend on a receiver.
### Class encapsulation

9.4.1 **Use JavaScript `#private` when runtime privacy matters** _(impact: medium; consensus: high)_ - Use ECMAScript private fields for hard runtime privacy rather than assuming the TypeScript `private` modifier creates an inaccessible runtime slot.
### Class field semantics

9.5.1 **Use `declare` for type-only inherited field refinement** _(impact: medium; consensus: high)_ - When narrowing the type of an inherited class field without changing its runtime value, write `declare field: NarrowerType` instead of redeclaring a normal field.
### Class/interface contracts

9.6.1 **Do not expect `implements` to supply contextual typing** _(impact: medium; consensus: high)_ - Explicitly type class members as needed even when the class has an `implements Interface` clause.
### Async error handling

9.7.1 **Treat Promise rejection callback values as `unknown`** _(impact: medium; consensus: high)_ - Annotate `.catch((error: unknown) => ...)` or enforce the corresponding lint rule.
### Function return semantics

9.8.1 **Do not rely on value-returning functions fitting `void` contracts without considering the result** _(impact: medium; consensus: medium)_ - TypeScript intentionally permits a value-returning function where `() => void` is expected; use `strict-void-return` when your architecture treats ignored return values as suspicious.

## 10. Static Analysis, Enums, and Toolchain Behavior

### Enum stability

10.1.1 **Give enum members explicit values when the values cross boundaries** _(impact: medium; consensus: high)_ - Explicitly initialize enum members when their numeric/string values are persisted, serialized, stored in databases, sent over APIs, or otherwise externally significant.
### Static analysis

10.2.1 **Use type-aware linting for checks the compiler intentionally does not perform** _(impact: medium; consensus: high)_ - For production TypeScript, consider a typescript-eslint type-checked preset rather than relying on `tsc` alone.
### Generic object modeling

10.3.1 **Be cautious with generic object spread return types** _(impact: medium; consensus: medium)_ - Avoid treating a generic object spread as though its type-level intersection precisely models runtime overwrite behavior, especially in reusable generic helpers.
### Toolchain compatibility

10.4.1 **Account for the TypeScript 7 compiler-API transition** _(impact: medium; consensus: high)_ - As of TypeScript 7.0, tools requiring the programmatic TypeScript compiler API may still need TypeScript 6 through `@typescript/typescript6` or the documented alias arrangement until the new API arrives.
### Library publishing

10.5.1 **Put the `"types"` condition first in package exports** _(impact: medium; consensus: high)_ - When publishing conditional package exports with dedicated declaration paths, place the `"types"` condition before runtime conditions.
### Runtime representation

10.6.1 **Consider `as const` objects instead of enums when runtime enum machinery is unnecessary** _(impact: low; consensus: medium)_ - For simple constant sets, a plain object with `as const` plus derived union types can often replace a TypeScript enum; ordinary enums remain valid when their runtime object semantics are useful.
### Enum modeling

10.7.1 **Avoid heterogeneous enums** _(impact: low; consensus: high)_ - Do not mix numeric and string members in one enum without a strong interoperability reason.
10.7.2 **Avoid accidental duplicate enum values** _(impact: low; consensus: high)_ - Give different enum members different values unless aliases are intentional and documented.
### Enum abstraction

10.8.1 **Compare enums through enum members rather than raw underlying values** _(impact: low; consensus: high)_ - Prefer `status === Status.Ready` over `status === 2` or the equivalent raw string when the value is conceptually an enum.
### Generic inference control

10.9.1 **Use `NoInfer` when one argument should validate but not influence inference** _(impact: low; consensus: high)_ - Use `NoInfer<T>` for secondary inputs such as defaults that must conform to a type inferred elsewhere but should not widen that inferred type.
### Type-level function introspection

10.10.1 **Remember utility inference over overloads uses the last signature** _(impact: low; consensus: high)_ - Do not expect conditional inference or utilities such as `ReturnType` to perform overload resolution for a hypothetical call; overloaded types are generally inferred from their final signature.
### Advanced generics

10.11.1 **Do not use variance annotations as a way to force structural variance** _(impact: low; consensus: high)_ - Normally let TypeScript infer variance; add `in`/`out` annotations only for accurately understood recursive types, diagnostics, or measured performance cases.
### Project file layout

10.12.1 **Do not assume `rootDir` controls what enters the program** _(impact: low; consensus: high)_ - Use `include`, `files`, references, and import structure to control program membership; use `rootDir` primarily to define source/output layout expectations.

## 11. Scale, Publication, and Advanced Language Semantics

### Compiler scalability

11.1.1 **Prefer interface extension over large object intersections when composition is equivalent** _(impact: low; consensus: high)_ - In heavily composed object hierarchies, prefer `interface Foo extends A, B` over repeatedly constructing `A & B & {...}` when either representation meets the semantic need.
11.1.2 **Name repeatedly evaluated complex types** _(impact: low; consensus: high)_ - Extract heavily reused conditional, mapped, or other complex anonymous types into named aliases when type-checking performance becomes material.
11.1.3 **Add explicit exported return types when profiling shows inference cost** _(impact: low; consensus: high)_ - Do not annotate every trivial expression, but consider explicit return and public API types in declaration-heavy or very large projects where compiler profiling identifies inference/serialization cost.
11.1.4 **Break very large workspaces into project references when scale warrants it** _(impact: low; consensus: high)_ - Use project references when a workspace becomes large enough that build or editor scale is itself a demonstrated problem.
### Declaration generation

11.2.1 **Consider `isolatedDeclarations` for scalable library declaration generation** _(impact: low; consensus: high)_ - Library/tooling authors who need declaration generation without whole-program inference can use `isolatedDeclarations` and explicitly type the necessary exported surface.
### Library publishing

11.3.1 **Remember that `typesVersions` can be bypassed by `"exports"` resolution** _(impact: low; consensus: high)_ - If a package uses conditional `"exports"`, do not assume a separate `typesVersions` mapping will also participate in that resolution path; use versioned `"types@..."` export conditions when necessary.
### Runtime feature support

11.4.1 **Check runtime support when using explicit resource management** _(impact: low; consensus: high)_ - When using `using`, `await using`, `DisposableStack`, or related facilities against older runtimes, configure the appropriate libraries and provide the required runtime support or polyfills.
### Accessor contracts

11.5.1 **Keep getter and setter types logically related** _(impact: low; consensus: medium)_ - TypeScript permits explicitly annotated getter and setter types that are completely unrelated, but prefer a getter type assignable to its corresponding setter type unless the unusual asymmetry is intentional.
### Union and intersection hygiene

11.6.1 **Avoid type-level redundancy that hides widening** _(impact: low; consensus: medium)_ - Remove constituents such as `string | "foo"`, `unknown | T`, or `any | T` when the broader type completely absorbs the narrower one unless the redundancy is deliberately documentary.
### Advanced generics

11.7.1 **Do not add explicit variance annotations as routine documentation** _(impact: low; consensus: high)_ - Even when variance is understood, avoid sprinkling `in` and `out` through normal APIs solely to document intent.
