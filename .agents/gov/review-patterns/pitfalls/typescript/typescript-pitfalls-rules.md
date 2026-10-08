# TypeScript Pitfalls Rules

## 1. Core Type Safety and Variant Modeling

### Compiler strictness

1.1.1 **Enable the `strict` family** - TypeScript projects SHOULD enable `strict: true`; individual strict checks SHOULD be disabled only when a concrete compatibility constraint requires it.
### Nullability

1.2.1 **Keep `strictNullChecks` enabled** - TypeScript projects MUST enable `strictNullChecks` so `null` and `undefined` are not implicitly assignable to non-nullish types.
### Type inference safety

1.3.1 **Reject implicit `any`** - TypeScript projects MUST enable `noImplicitAny` and MUST NOT allow unresolved parameter or variable types to silently become `any`.
### Dynamic-data boundaries

1.4.1 **Prefer `unknown` over `any` for unknown values** - Values whose type is genuinely unknown SHOULD be typed as `unknown`; `any` SHOULD be reserved for deliberate type-checking escape hatches.
1.4.2 **Prevent `any` from propagating** - Unavoidable `any` values MUST be contained at explicit boundaries and MUST NOT propagate unchecked through assignment, arguments, calls, member access, or returns.
### Runtime type boundaries

1.5.1 **Validate external data at runtime** - External or untrusted data MUST be runtime-validated before it is treated as satisfying a TypeScript application type.
### Type assertion discipline

1.6.1 **Narrow instead of asserting** - Code SHOULD establish a value's type through narrowing or validation rather than `as T`; assertions SHOULD be limited to invariants established outside the type system.
1.6.2 **Treat double assertions as an escape hatch** - Double assertions such as `value as unknown as T` SHOULD NOT be used except at deliberate unsafe boundaries where the asserted invariant is externally guaranteed.
### Nullability

1.7.1 **Avoid routine non-null assertions** - Non-null assertions (`!`) SHOULD NOT be used when nullability can be proven through control flow, validation, or more accurate types.
### Indexed access safety

1.8.1 **Treat indexed access as potentially missing** - Indexed access whose key or index is not statically guaranteed to exist MUST be treated as potentially missing, with `noUncheckedIndexedAccess` SHOULD be enabled where practical.
### Variant modeling

1.9.1 **Model variants as discriminated unions** - Mutually related object variants with variant-specific fields SHOULD be modeled as discriminated unions rather than one object type with independently optional fields.
### Exhaustiveness

1.10.1 **Make closed unions exhaustive** - Control flow that handles a closed discriminated union or enum MUST detect unhandled variants exhaustively.

## 2. Asynchronous Behavior

### Async control flow

2.1.1 **Never accidentally float Promises** - Every created Promise MUST be awaited, returned, aggregated, explicitly handled, or deliberately marked as intentionally unhandled.
### Async callback contracts

2.2.1 **Do not pass async functions to APIs expecting `void` callbacks** - An async function MUST NOT be passed to a `void`-returning callback position unless its returned Promise is explicitly handled.
### Async error handling

2.3.1 **Use `return await` when the surrounding `try`/`catch` must handle rejection** - A Promise returned from within a `try` block MUST be awaited before returning when the surrounding `catch` is intended to handle its rejection.

## 3. Module and Library Boundaries

### Module/runtime alignment

3.1.1 **Match `module` and `moduleResolution` to the actual runtime or bundler** - `module` and `moduleResolution` MUST model the module semantics of the runtime, bundler, or host that will actually execute or resolve the code.
3.1.2 **Do not mistake `paths` for runtime aliasing** - A TypeScript `paths` mapping MUST have an equivalent runtime or bundler mapping, and published output MUST NOT depend on private `paths` aliases.
### Node module semantics

3.2.1 **Use runtime-correct extensions in Node ESM** - Relative imports emitted for Node ESM MUST use module specifiers and file extensions that Node can resolve at runtime.
### Library API design

3.3.1 **Do not publish ambient `const enum`s** - Published declaration files MUST NOT expose ambient `const enum`s to consumers.
### Library publishing

3.4.1 **Give CJS and ESM entrypoints separate declarations** - A package exposing distinct CommonJS and ESM entrypoints MUST provide declarations whose module format corresponds to each entrypoint.
### Declaration trust boundaries

3.5.1 **Treat declaration files as trusted claims, not runtime proof** - Successful checking against a `.d.ts` file MUST NOT be treated as proof that the corresponding runtime implementation satisfies those declarations.

## 4. Runtime and Build Configuration

### Class initialization

4.1.1 **Keep property initialization checked** - Class properties MUST satisfy `strictPropertyInitialization`; definite-assignment assertions SHOULD be used only when initialization is guaranteed by a mechanism TypeScript cannot observe.
### Declaration merging

4.2.1 **Avoid class-interface declaration merging** - A class and same-named interface MUST NOT be merged to declare instance members unless those members are actually initialized at runtime.
### Runtime environment modeling

4.3.1 **Do not confuse `lib` with runtime support** - The configured `lib` set MUST describe APIs supplied by the actual runtime or intentional polyfills and MUST NOT be used merely to silence missing-API errors.
### Project configuration

4.4.1 **Use separate TypeScript projects for genuinely different environments** - Code targeting materially different runtime environments SHOULD be checked by separate TypeScript configurations or projects when their globals, libraries, or resolution semantics differ.
### Transpilation compatibility

4.5.1 **Enable `isolatedModules` with single-file transpilers** - Projects transpiled by tools that process each file without whole-program type information MUST enable `isolatedModules`.
### Library publishing

4.6.1 **Bundle declarations when bundling library JavaScript** - A library that bundles JavaScript modules MUST publish declarations whose module structure and imports are valid for the bundled package consumed by users.
### Module/runtime alignment

4.7.1 **Do not assume TypeScript detects every CJS/ESM interop failure** - CJS/ESM interactions whose runtime compatibility TypeScript cannot verify MUST be exercised against the actual target runtime rather than accepted solely because type checking succeeds.
### Decorators

4.8.1 **Do not mix standard and legacy decorator semantics accidentally** - Decorator syntax, compiler settings, and framework expectations MUST consistently use either the supported standard decorator model or the required legacy decorator model.
### Build correctness

4.9.1 **Keep type checking as a build or CI gate** - Any build pipeline that can emit JavaScript without type checking MUST run a separate required TypeScript type-checking step before successful completion.
### Native TypeScript execution

4.10.1 **Enable `erasableSyntaxOnly` when relying on native Node type stripping** - Code executed through Node's native TypeScript type stripping MUST enable `erasableSyntaxOnly` or otherwise exclude TypeScript syntax requiring runtime transformation.

## 5. Advanced Type-System Soundness

### Function variance

5.1.1 **Prefer function-property signatures where callback variance must be sound** - Callback members SHOULD use function-property signatures rather than method signatures when contravariant parameter checking is required for soundness.
### Variance and mutation

5.2.1 **Accept `readonly` arrays when mutation is not required** - Function parameters accepting arrays SHOULD use `readonly T[]` or `ReadonlyArray<T>` when the function does not need to mutate the array.
### Control-flow refinement

5.3.1 **Do not trust refinements across mutation-capable calls** - A narrowed property MUST be captured, revalidated, or otherwise protected before use after a call that can mutate the narrowed object.
### User-defined narrowing

5.4.1 **Write type predicates that are valid in both branches** - A user-defined predicate returning `value is T` MUST guarantee that `true` establishes `T` and that `false` safely excludes `T`.
### Generic API safety

5.5.1 **Avoid caller-selected return-only generics** - APIs SHOULD NOT expose caller-selected return-only generics whose type parameter is neither inferred from input nor established by runtime validation.

## 6. Nullish Semantics and Data Modeling

### Optional property semantics

6.1.1 **Distinguish absent optional properties from explicit `undefined`** - When property absence and explicit `undefined` have different semantics, the type model MUST preserve that distinction, such as by enabling `exactOptionalPropertyTypes`.
### Exception handling

6.2.1 **Treat caught exceptions as `unknown`** - Caught exception values MUST be treated as `unknown` until narrowed to a usable type.
### Narrowing semantics

6.3.1 **Do not use truthiness when valid data can be falsy** - Truthiness checks MUST NOT be used to test presence when valid domain values can include `0`, `""`, `false`, or other falsy values.
### Nullish semantics

6.4.1 **Prefer `??` to `||` for nullish defaults** - When a fallback applies only to `null` or `undefined`, code MUST use nullish semantics such as `??` rather than `||`.
6.4.2 **Remember that optional chaining only guards its chain** - The result of an optional chain MUST still be treated as potentially `undefined` by operations occurring after the guarded chain.
### Literal inference

6.5.1 **Prefer `satisfies` when checking a value without widening it** - Code SHOULD use `satisfies` when a value must be checked against a type while retaining its narrower inferred literal type.
### Structural object semantics

6.6.1 **Do not mistake excess-property checks for exact object types** - Code MUST NOT rely on excess-property checking to guarantee that a structurally typed runtime object contains no additional properties.
### Structural object iteration

6.7.1 **Do not blindly cast `Object.keys` to `keyof T`** - `Object.keys(value)` SHOULD NOT be asserted as `(keyof T)[]` unless the runtime object is guaranteed to contain only keys represented by `T`.
### Union modeling

6.8.1 **Remember that unions are inclusive** - When two object alternatives must be mutually exclusive, code MUST encode that exclusivity explicitly rather than assuming `A | B` prohibits values satisfying both.
### Immutability semantics

6.9.1 **Treat `readonly` as shallow and static** - TypeScript `readonly` MUST NOT be treated as a guarantee of deep or runtime immutability.
### Literal inference

6.10.1 **Do not treat `as const` as deep immutability** - `as const` MUST NOT be treated as a guarantee that the complete referenced object graph is immutable at runtime.
### Nominal modeling

6.11.1 **Use branded types when structurally identical primitives represent different domains** - Structurally identical primitive values SHOULD use branded or otherwise nominal types when accidental interchange between their domains would be materially incorrect.
### Domain modeling

6.12.1 **Use literal unions for closed value sets** - A known finite set of permitted primitive values SHOULD be represented by literal types rather than an unconstrained primitive type.
### Top types and object types

6.13.1 **Do not use `{}` to mean an empty object** - `{}` MUST NOT be used to mean an object with no properties; code MUST use a type whose semantics match the intended value domain.
### Primitive modeling

6.14.1 **Use primitive type names, not boxed wrapper types** - Type annotations MUST use primitive types such as `string`, `number`, `boolean`, and `symbol` instead of their boxed `String`, `Number`, `Boolean`, and `Symbol` types unless boxed objects are specifically required.

## 7. APIs, Modules, and Project Semantics

### Function typing

7.1.1 **Avoid the `Function` type** - Callable values SHOULD NOT be typed as `Function` when their call signature can be expressed explicitly.
### Generic modeling

7.2.1 **Make generic parameters structurally meaningful** - A generic parameter intended to affect assignability MUST participate in the type's structure; otherwise it SHOULD be removed or represented explicitly.
### Module emit

7.3.1 **Prefer explicit type-only imports with predictable emit** - Imports and exports used exclusively in type positions SHOULD use `import type` or `export type` when the project's emit model supports them.
### Module side effects

7.4.1 **Prefer top-level `import type` when every imported binding is type-only** - Under `verbatimModuleSyntax`, an import containing only type bindings SHOULD use top-level `import type` rather than an empty-emitting value import.
### Module correctness

7.5.1 **Check unresolved side-effect imports** - Projects relying on side-effect imports SHOULD enable `noUncheckedSideEffectImports` or otherwise require those imports to resolve successfully.
### Module scope

7.6.1 **Force module treatment when files should never be global scripts** - Projects in which source files are intended exclusively as modules SHOULD use `moduleDetection: "force"` or explicit module syntax to prevent accidental global scripts.
### Cross-platform correctness

7.7.1 **Enforce import filename casing** - TypeScript projects SHOULD enable `forceConsistentCasingInFileNames`, and import path casing MUST match the actual file name.
### Class inheritance

7.8.1 **Require explicit `override` markers** - Projects using class inheritance SHOULD enable `noImplicitOverride` so members that override base-class members are explicitly marked `override`.
### Control-flow checking

7.9.1 **Detect missing return paths** - Projects whose functions are expected to return consistently across control-flow paths SHOULD enable `noImplicitReturns`.
### Indexed object APIs

7.10.1 **Signal uncertain index-signature properties with bracket access** - Dictionary-like APIs whose undeclared keys come from index signatures SHOULD use `noPropertyAccessFromIndexSignature` when distinguishing known properties from arbitrary keys is important.
### Iterator typing

7.11.1 **Keep built-in iterator return values strict** - TypeScript projects SHOULD keep `strictBuiltinIteratorReturn` enabled, normally through `strict`, so iterator completion values do not degrade to unsafe types.
### Declaration checking

7.12.1 **Use `skipLibCheck` deliberately, not as a universal fix** - `skipLibCheck` SHOULD NOT be enabled merely to hide incompatible declarations; it SHOULD be used only as a deliberate performance or migration tradeoff.
### Project file inclusion

7.13.1 **Do not treat `exclude` as an import firewall** - TypeScript configuration MUST NOT rely on `exclude` to prevent imported or referenced files from entering the program.
### Ambient type configuration

7.14.1 **Understand that `types` controls globals, not imported package types** - The `types` compiler option MUST be used only to control automatically included ambient type packages, not as a mechanism for restricting explicitly imported package types.
### Module specifiers

7.15.1 **Import `.ts` extensions only when the runtime/build pipeline supports them** - Source imports ending in `.ts` MUST NOT be used unless the configured emit and runtime pipeline explicitly supports those specifiers.
### Monorepo module resolution

7.16.1 **Do not use `paths` to fake monorepo packages** - Monorepo package relationships SHOULD use actual package or workspace resolution rather than TypeScript `paths` mappings that bypass package `exports`, `types`, or related metadata.
### Code organization

7.17.1 **Prefer ES modules over TypeScript namespaces in modern code** - Modern application and library code SHOULD use standard ES modules instead of TypeScript namespaces unless namespace semantics are specifically required.
### ESM/CJS interoperability

7.18.1 **Do not disable `esModuleInterop` to obtain stricter ESM behavior** - Projects SHOULD NOT disable `esModuleInterop` merely to obtain stricter ESM syntax or emit behavior; module syntax controls SHOULD be configured separately.
### Diagnostic suppression

7.19.1 **Prefer `@ts-expect-error` over `@ts-ignore`** - A necessary TypeScript diagnostic suppression SHOULD use `@ts-expect-error` rather than `@ts-ignore` so stale suppressions become detectable.

## 8. Function and Generic API Design

### Callback API design

8.1.1 **Do not mark callback parameters optional just because callers may ignore them** - A callback parameter MUST NOT be declared optional when the API always supplies that argument.
8.1.2 **Declare ignored callback returns as `void`, not `any`** - A callback whose return value is intentionally ignored MUST be declared as returning `void` rather than `any`.
### Function API design

8.2.1 **Prefer union parameters over unnecessary overloads** - Functions SHOULD use a union parameter instead of multiple overloads when the overloads have the same arity and return behavior and differ only by argument type.
### Function overloads

8.3.1 **Remember that overload implementation signatures are hidden** - Every supported public call shape of an overloaded function MUST be represented by an overload signature rather than only by the implementation signature.
8.3.2 **Put specific overloads before general ones** - Overload declarations MUST place more specific matching signatures before broader catch-all signatures when ordering can affect resolution.
### Generic inference

8.4.1 **Push generic type parameters down** - Generic constraints SHOULD expose only the structure required by the implementation rather than constraining a type parameter to a broader container type unnecessarily.
### Generic API design

8.5.1 **Use as few generic parameters as the relationship requires** - Generic APIs SHOULD NOT introduce type parameters that do not contribute information or express a meaningful relationship in the API.
### Generic soundness

8.6.1 **Do not fabricate a subtype from only its generic constraint** - A generic function returning `T extends Base` MUST NOT construct only a `Base` value and return it as arbitrary `T` without additional evidence establishing that subtype.
### Conditional types

8.7.1 **Remember that conditional types distribute over naked unions** - Conditional types MUST account for distributivity over naked type parameters, and non-distributive tests MUST use a non-distributive formulation when whole-union evaluation is intended.
### Generic inference

8.8.1 **Use `const` type parameters when an API needs literal-preserving inference** - Generic APIs SHOULD use `const` type parameters when preserving caller literal types is part of the API contract and callers would otherwise require repeated `as const` assertions.

## 9. Object and Class Runtime Semantics

### Object spread semantics

9.1.1 **Do not spread values into objects merely because TypeScript permits it** - Values SHOULD NOT be object-spread unless copying their enumerable own properties is the intended runtime operation.
### Array semantics

9.2.1 **Do not use `delete` to remove an array element** - `delete array[index]` MUST NOT be used when the intent is to remove an element and compact the array.
### Method binding

9.3.1 **Do not detach methods that depend on `this`** - A method that depends on its receiver MUST NOT be passed or stored as an unbound function.
### Class encapsulation

9.4.1 **Use JavaScript `#private` when runtime privacy matters** - Class state requiring runtime-enforced privacy MUST use JavaScript private fields or an equivalent runtime mechanism rather than relying only on TypeScript `private`.
### Class field semantics

9.5.1 **Use `declare` for type-only inherited field refinement** - A derived class that only refines the static type of an inherited field MUST use `declare` rather than emitting a new field initialization.
### Class/interface contracts

9.6.1 **Do not expect `implements` to supply contextual typing** - Class members MUST NOT rely on an `implements` clause to infer their parameter or member types when those types are not otherwise inferable.
### Async error handling

9.7.1 **Treat Promise rejection callback values as `unknown`** - Promise rejection callback parameters MUST be treated as `unknown` until narrowed.
### Function return semantics

9.8.1 **Do not rely on value-returning functions fitting `void` contracts without considering the result** - A function passed to a `() => void` position SHOULD NOT return a value whose loss has semantic significance unless that value is handled explicitly.

## 10. Static Analysis, Enums, and Toolchain Behavior

### Enum stability

10.1.1 **Give enum members explicit values when the values cross boundaries** - Enum members whose values are persisted, serialized, transmitted, or otherwise externally significant MUST have explicit stable values.
### Static analysis

10.2.1 **Use type-aware linting for checks the compiler intentionally does not perform** - Production TypeScript projects SHOULD use type-aware static analysis for materially relevant hazards that `tsc` intentionally permits.
### Generic object modeling

10.3.1 **Be cautious with generic object spread return types** - Generic object-spread helpers SHOULD NOT expose a naive intersection type when conflicting keys can make runtime overwrite semantics differ materially from that type.
### Toolchain compatibility

10.4.1 **Account for the TypeScript 7 compiler-API transition** - TypeScript 7.0 toolchains that depend on the programmatic compiler API MUST use the documented TypeScript 6 compatibility package or equivalent until a compatible TypeScript 7 API is available.
### Library publishing

10.5.1 **Put the `"types"` condition first in package exports** - Package export conditions that include a `"types"` branch MUST place `"types"` before the corresponding runtime conditions.
### Runtime representation

10.6.1 **Consider `as const` objects instead of enums when runtime enum machinery is unnecessary** - Closed constant sets SHOULD use an `as const` object plus derived types instead of an enum when enum-specific runtime behavior provides no material benefit.
### Enum modeling

10.7.1 **Avoid heterogeneous enums** - Enums SHOULD NOT mix string and numeric members unless an interoperability requirement specifically requires heterogeneous values.
10.7.2 **Avoid accidental duplicate enum values** - Distinct enum members SHOULD NOT share the same value unless the duplication is an intentional alias.
### Enum abstraction

10.8.1 **Compare enums through enum members rather than raw underlying values** - Code SHOULD compare enum-typed values against enum members rather than their raw underlying literals when the enum abstraction is intended to be preserved.
### Generic inference control

10.9.1 **Use `NoInfer` when one argument should validate but not influence inference** - `NoInfer<T>` SHOULD be used when an argument must conform to an already inferred generic type but MUST NOT participate in inferring or widening that type.
### Type-level function introspection

10.10.1 **Remember utility inference over overloads uses the last signature** - Type-level inference utilities MUST NOT be assumed to resolve individual overloads when the desired result depends on a non-final overload signature.
### Advanced generics

10.11.1 **Do not use variance annotations as a way to force structural variance** - `in` and `out` annotations MUST NOT be used to override or force assignability behavior that conflicts with a type's actual structural variance.
### Project file layout

10.12.1 **Do not assume `rootDir` controls what enters the program** - `rootDir` MUST NOT be used as the mechanism for controlling which files participate in a TypeScript program.

## 11. Scale, Publication, and Advanced Language Semantics

### Compiler scalability

11.1.1 **Prefer interface extension over large object intersections when composition is equivalent** - When object composition is semantically equivalent and checker scalability is material, interface extension SHOULD be preferred over repeatedly composed large intersection types.
11.1.2 **Name repeatedly evaluated complex types** - Reused complex conditional, mapped, or composite types SHOULD be extracted into named aliases when repeated evaluation materially affects type-checking performance.
11.1.3 **Add explicit exported return types when profiling shows inference cost** - Exported functions SHOULD receive explicit return types when compiler profiling shows that inferring or serializing those types materially affects performance.
11.1.4 **Break very large workspaces into project references when scale warrants it** - Large TypeScript workspaces SHOULD use project references when workspace size demonstrably causes material build or editor scalability problems.
### Declaration generation

11.2.1 **Consider `isolatedDeclarations` for scalable library declaration generation** - Library builds requiring declaration generation without whole-program inference SHOULD use `isolatedDeclarations` and provide the exported annotations that mode requires.
### Library publishing

11.3.1 **Remember that `typesVersions` can be bypassed by `"exports"` resolution** - Packages using `"exports"` and version-specific declarations MUST NOT rely on `typesVersions` where export resolution bypasses it; compatible versioned type conditions MUST be used instead.
### Runtime feature support

11.4.1 **Check runtime support when using explicit resource management** - Code using `using`, `await using`, or related explicit-resource-management APIs MUST target a runtime that provides the required disposal support or supply compatible runtime support.
### Accessor contracts

11.5.1 **Keep getter and setter types logically related** - Getter and setter types for the same property SHOULD remain mutually coherent, with unrelated types used only when the asymmetric contract is intentional.
### Union and intersection hygiene

11.6.1 **Avoid type-level redundancy that hides widening** - Redundant union or intersection constituents that are completely absorbed by broader constituents SHOULD be removed unless their presence is intentionally documentary.
### Advanced generics

11.7.1 **Do not add explicit variance annotations as routine documentation** - Explicit variance annotations SHOULD NOT be added solely as routine documentation when TypeScript can correctly infer the type's variance.
