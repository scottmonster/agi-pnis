# Code Design Concept Rules

## 1. Control flow and conditional logic

### 1.1 Flattening and ordering control flow

1.1.1 **Guard Clauses** - Use early guards for clear invalid or exceptional cases to keep the dominant path flat and visible; retain nested scope for cohesive operations or required cleanup.
1.1.2 **Early Exit** - Exit when a result is known or further work is invalid; use a single exit only when cleanup protocols or language constraints require it.
1.1.3 **Linear Flow / Happy Path** - Make the ordinary sequence visually dominant and move simple exceptional handling aside; keep balanced branches when alternatives are genuine peers.
1.1.4 **Replace Control Flag with Break** - Replace a variable used only to stop one loop with a loop break; retain flags that represent domain state or cross scopes.
1.1.5 **Separate Query from Modifier** - Split routines that report information and mutate state when callers may need either independently; keep a combined operation when atomicity or race safety requires it.
1.1.6 **Replace Loop with Pipeline** - Use collection transformations for filtering, mapping, and aggregation when they clarify traversal; retain loops for central early exits, visible side effects, or measured performance needs.
1.1.7 **Split Loop** - Give independent results separate traversals so each loop has one purpose; keep a combined loop when work coordinates per item or a single pass is measurably necessary.
1.1.8 **Substitute Algorithm** - Replace an algorithm with a clearer equivalent only when its observable contract, including edge cases, remains unchanged.

### 1.2 Conditions and choices

1.2.1 **Decompose Conditional** - Extract a hard-to-read condition and meaningful branches into well-named operations when their names clarify the business decision.
1.2.2 **Consolidate Conditional Expression** - Combine conditions that safely lead to the same outcome into one named decision, unless their order, effects, or diagnostics must remain distinct.
1.2.3 **Consolidate Duplicate Conditional Fragments** - Move behavior shared by every conditional branch outside the conditional when doing so preserves ordering, scope, and error behavior.
1.2.4 **Decision Table / Table-Driven Logic** - Use table-driven logic when many condition combinations must be reviewed as a set; keep simpler or inherently sequential decisions as direct branches.
1.2.5 **Replace Conditional with Polymorphism** - Move repeated branching on stable variants into variant implementations when each variant owns distinct behavior; keep isolated, small conditionals direct.
1.2.6 **Introduce Special Case** - Introduce a special-case object when absent or exceptional values have coherent shared behavior; retain explicit absence when it carries important domain information.
1.2.7 **Introduce Assertion** - Assert a local invariant immediately before code relies on it, but validate untrusted input and expected failures through normal handling instead.
1.2.8 **Replace Exception with Precheck** - Precheck predictable, inexpensive normal-flow conditions instead of catching exceptions, while retaining exception handling for exceptional or race-prone failures.
1.2.9 **Replace Error Code with Exception** - Signal exceptional failures with exceptions when special return codes burden or can be ignored by callers; retain result codes for expected outcomes and protocol boundaries.
1.2.10 **Finite-State Machine (FSM)** - Use an FSM when a process has a finite lifecycle and state-dependent events; centralize legal transitions to prevent invalid combinations.

### 1.3 Control-flow smells and asynchronous structures

1.3.1 **Arrow Code / Arrowhead** - Avoid successively nesting conditions when early exits or extraction can keep the main path flat and visible.
1.3.2 **Deep Nesting** - Avoid stacking conditions or loops when readers must retain too much enclosing context; flatten or extract while keeping genuine subordinate logic local.
1.3.3 **Pyramid of Doom** - Avoid burying a dependent sequence in expanding nested control scopes; make its order and failure paths easy to scan.
1.3.4 **Callback Hell** - Avoid deeply nesting asynchronous callbacks when they obscure the operation or duplicate error handling; use a flatter, structured boundary where appropriate.
1.3.5 **Continuation-Passing Style (CPS)** - Use explicit, named continuations when non-linear or asynchronous sequencing needs them, and keep their flow structured rather than deeply nested.
1.3.6 **Futures/Promises** - Use futures or promises when callers need a composable handle for an operation's later value or failure, rather than hiding it in nested callbacks.
1.3.7 **Structured Concurrency** - Scope child tasks to their parent operation when they should finish, fail, or cancel together; make intentionally detached work explicitly owned elsewhere.

## 2. Functions, statements, and parameters

### 2.1 Naming, extraction, and local state

2.1.1 **Extract Function** - Extract a fragment with a coherent, nameable purpose when doing so makes the caller's narrative clearer; keep tiny or unstable fragments inline.
2.1.2 **Inline Function** - Inline a function when its body is clearer than its call and it adds no domain meaning, seam, or reusable abstraction.
2.1.3 **Extract Variable** - Name a complex or meaningful subexpression with a local variable when the name makes the intermediate idea clearer.
2.1.4 **Inline Variable** - Inline a single-use local when its name adds no concept; retain it when it improves readability, reuse, or debugging.
2.1.5 **Split Variable** - Give values with distinct roles separate names instead of reassigning one variable; retain conventional accumulators with one stable meaning.
2.1.6 **Replace Temp with Query** - Replace a derived local with a reusable query when recomputation is safe and affordable; retain the temporary for expensive, stateful, or time-sensitive work.
2.1.7 **Replace Derived Variable with Query** - Compute a value from its source state instead of storing duplicate derived state when recomputation is clear and affordable; use stored values only for explicit caching, snapshots, or external data.
2.1.8 **Replace Magic Literal with Symbolic Constant** - Replace literals with domain meaning with named constants; keep conventional, self-evident literals inline when a name would add noise.
2.1.9 **Move Statements into Function** - Move a call sequence into a function when every caller must perform the same stable protocol; leave steps with legitimate caller variation outside.
2.1.10 **Move Statements to Callers** - Move callee behavior to callers when only some callers need to vary, omit, or reorder it; retain steps that are required operation invariants.
2.1.11 **Split Phase** - Separate processing into stages when it performs distinct jobs with different inputs or reasoning models; keep small, tightly coupled flows together.
2.1.12 **Slide Statements** - Group statements with their data and control dependencies when reordering preserves behavior, timing, errors, and required side-effect order.
2.1.13 **Return Modified Value** - Return an intentionally modified value when callers benefit from chaining the same object through transformations; keep event-style commands or immutable transformations distinct.

### 2.2 Function contracts and arguments

2.2.1 **Change Function Declaration** - Change a function's name, visibility, parameters, or result when its contract no longer clearly matches its responsibility, while preserving required compatibility.
2.2.2 **Rename Variable / Rename Field** - Rename a variable or field when its current name does not clearly express the value's domain role.
2.2.3 **Parameterize Function** - Parameterize near-duplicate functions when one explicit parameter captures their true variation without hiding distinct behavior behind a flag.
2.2.4 **Remove Flag Argument** - Replace a boolean or mode argument with explicitly named operations when it selects materially different behavior.
2.2.5 **Replace Parameter with Query** - Let a function obtain a value internally only when the value is already available and doing so does not hide a meaningful dependency.
2.2.6 **Replace Query with Parameter** - Pass a value as a parameter when obtaining it is not the function's responsibility and an explicit dependency improves context or testability.
2.2.7 **Preserve Whole Object** - Pass the owning object when the callee genuinely needs a coherent cluster of its values; avoid doing so when it leaks unnecessary structure.
2.2.8 **Introduce Parameter Object** - Introduce a parameter object when a recurring group of values represents one meaningful concept, rather than grouping unrelated or one-off arguments.
2.2.9 **Replace Function with Command** - Turn an operation into a command object when its growing steps or intermediate state need a focused home; keep short, direct operations as functions.
2.2.10 **Replace Command with Function** - Replace a command object with a direct function when immediate execution needs no object lifecycle, queuing, undo, retries, or polymorphic dispatch.
2.2.11 **Fluent Interface** - Use a staged fluent interface when a coherent workflow benefits from guiding each meaningful next call; keep independent or branching work explicit.

## 3. Data, state, and model representation

### 3.1 Encapsulation and representation refactorings

3.1.1 **Encapsulate Variable** - Route mutable data with access rules or a changing representation through named accessors; keep direct access for simple local or immutable values.
3.1.2 **Encapsulate Record** - Wrap shared, structured records with associated behavior or invariants to control representation; retain transparent records at interchange boundaries.
3.1.3 **Encapsulate Collection** - Expose controlled collection operations when mutations must preserve invariants or lifecycle rules, rather than allowing clients to mutate the collection directly.
3.1.4 **Replace Primitive with Object** - Introduce a small domain type when a primitive needs validation, formatting, comparison, or business rules; keep rule-free local or pass-through values primitive.
3.1.5 **Replace Array with Object** - Replace positional arrays with named fields when element meanings or the data shape must be clear and maintainable.
3.1.6 **Change Value to Reference** - Share a referenced identity when a domain update must be observed by every holder; preserve copied values for historical facts or independent snapshots.
3.1.7 **Change Reference to Value** - Make objects with no meaningful identity immutable, freely copied values to prevent aliasing; retain references for intentionally shared or identity-bearing entities.
3.1.8 **Replace Subclass with Fields** - Replace subclasses that differ only in fixed data with fields or type data; retain subclasses for distinct behavior, invariants, or framework requirements.
3.1.9 **Remove Setting Method** - Remove public setters for fields that must be initialized once and remain stable; limit staged construction setters when frameworks require them.
3.1.10 **Replace Type Code with Subclasses** - Replace a stable discriminator with subclasses when variants have distinct behavior or state; keep a decoding switch at the construction boundary and retain passive type data.
3.1.11 **Replace Type Code with State/Strategy** - Delegate a mode code to State or Strategy when its behavior changes independently of its owner; keep a small stable lookup or boundary switch when delegation adds no value.

### 3.2 Named model patterns

3.2.1 **Value Object** - Model interchangeable domain concepts as immutable value objects with equality based on their defining attributes; retain entities when stable identity matters.
3.2.2 **Null Object** - Use a Null Object only for expected absence with safe, deliberate neutral behavior; represent failures or meaningful missing data explicitly.
3.2.3 **Data Transfer Object (DTO)** - Use DTOs to define data crossing a boundary, keeping them separate from domain behavior; avoid them for internal calls without a distinct contract.
3.2.4 **Data Mapper** - Use a Data Mapper when persistence representations are nontrivial or change independently from behavior-rich domain objects; keep mapping outside the domain model.
3.2.5 **Active Record** - Use Active Record for simple CRUD models that closely match storage; separate persistence when complex domain logic or storage variation makes coupling costly.
3.2.6 **Repository** - Use a Repository when domain workflows need reusable, collection-like access in business terms; avoid wrappers that only rename a simple data-source call.

## 4. Objects, dependencies, and collaboration

### 4.1 Object and dependency refactorings

4.1.1 **Extract Class** - Extract a cohesive, independently changing group of fields and behavior into a named class; keep small stable value carriers intact.
4.1.2 **Inline Class** - Inline a class that only stores data or forwards behavior for one owner, unless it remains an independent domain concept.
4.1.3 **Move Function / Move Field** - Move behavior or data to the object it chiefly serves, but keep genuinely cross-cutting or coordinating logic at its current boundary.
4.1.4 **Combine Functions into Class** - Group functions that repeatedly operate on the same data into a class when they form one coherent responsibility.
4.1.5 **Combine Functions into Transform** - Combine commonly needed derivations from one source record into an enriched transformation, unless calculations are independent or expensive to compute together.
4.1.6 **Hide Delegate** - Expose an intent-level operation on the server when clients should not depend on its internal delegate path; keep deliberate public collaborators accessible.
4.1.7 **Remove Middle Man** - Remove a forwarding-only intermediary when it no longer protects policy, a stable boundary, or a meaningful abstraction.
4.1.8 **Extract Superclass** - Extract a superclass only for types with genuine shared state, behavior, and a meaningful common contract.
4.1.9 **Pull Up Method / Pull Up Field** - Pull a member into an existing superclass when it is truly common to the hierarchy and belongs to its shared abstraction.
4.1.10 **Pull Up Constructor Body** - Move initialization shared by every subclass into the superclass constructor when the superclass owns the state and invariants.
4.1.11 **Push Down Method / Push Down Field** - Push a superclass member into the subclasses that actually use it when it is not part of the real base contract.
4.1.12 **Collapse Hierarchy** - Collapse a superclass and subclass when they no longer differ in behavior, data, or domain meaning.
4.1.13 **Replace Subclass with Delegate** - Replace inheritance with a delegated component when a subclass exists only to vary one part of otherwise stable behavior.
4.1.14 **Replace Superclass with Delegate** - Replace inheritance with a contained delegate when reuse exposes an overbroad API or the type is not a true subtype.
4.1.15 **Replace Constructor with Factory Function** - Introduce a named factory when creation needs to express intent, validation, normalization, defaults, caching, or subtype selection.
4.1.16 **Dependency Injection** - Supply configurable, replaceable, or external collaborators through the object's contract; create purely private short-lived details internally.
4.1.17 **Service Locator** - Use a locator only when centralized lookup of a shared, replaceable service is needed, recognizing that it hides the dependency from the contract.
4.1.18 **Law of Demeter** - Keep domain objects and services from navigating internal object topology; allow direct traversal for deliberately transparent data shapes.

### 4.2 Classic object patterns

4.2.1 **Factory Method** - Use a factory method when a stable workflow creates one product that varies by subclass, configuration, or supplied creator; keep direct construction for a single stable product.
4.2.2 **Abstract Factory** - Use an abstract factory when related product families must vary together; avoid its extra indirection for one stable product type.
4.2.3 **Builder** - Use a builder for complex construction with optional or ordered parts; keep direct creation for small, stable objects.
4.2.4 **Prototype** - Use configured copies when new objects are meaningful variations of a template, and define copy semantics for nested mutable state.
4.2.5 **Singleton** - Restrict a type to one instance only when that lifetime is intentional; prefer explicit composition or injection for ordinary shared dependencies.
4.2.6 **Adapter** - Wrap a foreign or legacy interface when clients need a different contract, keeping API translation and format conversion at the boundary.
4.2.7 **Bridge** - Separate abstraction from implementation when both dimensions genuinely vary independently, avoiding a cross-product of subclasses.
4.2.8 **Composite** - Use a common interface for leaves and groups when clients perform the same meaningful operations across a tree-like structure.
4.2.9 **Decorator** - Wrap an object to add optional behavior without changing its interface, and prevent decorator stacks from obscuring essential behavior.
4.2.10 **Facade** - Provide a focused entry point when clients need only a simple view of a complex subsystem.
4.2.11 **Flyweight** - Share immutable intrinsic state across many fine-grained objects when duplication matters, while keeping contextual state outside the shared object.
4.2.12 **Proxy** - Substitute a same-interface object to localize access, caching, or remoting concerns, and keep consequential hidden costs clear to callers.
4.2.13 **Chain of Responsibility** - Route a request through decoupled handlers when one handler should decide whether to process it, with handler order and the no-handler outcome explicit.
4.2.14 **Command** - Represent a request as an object when it needs queuing, logging, undo, or parameterization; use direct calls when that object-level behavior adds no value.
4.2.15 **Iterator** - Provide dedicated traversal when clients should traverse an aggregate without depending on its storage representation.
4.2.16 **Mediator** - Centralize dense collaboration among peer objects when direct links cause coupling, while keeping the mediator from accumulating unrelated responsibilities.
4.2.17 **Memento** - Capture and restore state for undo or history without exposing internals, and manage snapshot lifetime and storage deliberately.
4.2.18 **Observer** - Use subscriptions for independent dependents of state changes, and define event ordering, error handling, and listener lifetime.
4.2.19 **State** - Delegate behavior to state objects when an internal lifecycle affects several operations; retain simple conditionals for small, stable state logic.
4.2.20 **Strategy** - Encapsulate interchangeable algorithms when callers or configuration choose a policy explicitly, rather than modeling internal lifecycle transitions.
4.2.21 **Template Method** - Use a base algorithm with overridable steps when variants share a stable sequence; prefer composition when variation must change at runtime.
4.2.22 **Visitor** - Use visitors when element types are stable and new operations are common; avoid them when new element types change frequently.

## 5. Code smells and anti-patterns

### 5.1 Size, naming, and representation smells

5.1.1 **Mysterious Name** - Avoid names that hide purpose, value, or role; use clear domain names unless short or externally constrained names are conventional in context.
5.1.2 **Long Function / Long Method** - Avoid routines that mix distinct activities and obscure their purpose; extract coherent steps when doing so makes change and review clearer.
5.1.3 **Large Class** - Avoid classes that accumulate unrelated responsibilities or become change hotspots; extract cohesive responsibilities when decomposition improves discoverability.
5.1.4 **Long Parameter List** - Avoid functions with many independent inputs; group genuinely related values or relocate responsibility when it clarifies calls without hiding dependencies.
5.1.5 **Data Clump** - Avoid repeatedly passing the same related values after a decoding boundary; introduce a named concept when the cluster has stable shared meaning.
5.1.6 **Primitive Obsession** - Avoid representing a recurring domain concept only with raw primitives when its validation, units, formatting, or allowed values need a shared home.
5.1.7 **Data Class** - Avoid anemic domain objects by placing their invariants and domain behavior with the data; keep data-only objects for intentional transfer boundaries.
5.1.8 **Global Data** - Avoid mutable state reachable from unrelated code; centralize intentional shared infrastructure state behind a narrow, controlled API.
5.1.9 **Mutable Data** - Avoid shared state that many locations can change without a protocol; constrain mutation behind an invariant-preserving API or use immutable values.
5.1.10 **Temporary Field** - Avoid fields on long-lived objects that matter only during certain operations; localize intermediate state or use a short-lived command with an explicit lifecycle.
5.1.11 **Comments (as deodorant)** - Avoid comments that merely translate unclear code; improve names or structure while retaining comments that explain non-obvious intent, constraints, or tradeoffs.

### 5.2 Duplication, coupling, and change smells

5.2.1 **Duplicate Code** - Avoid separately maintaining logic that represents one business rule and is likely to change together; extract it only when the shared abstraction is clearer than the repetition.
5.2.2 **Dead Code** - Remove code with no meaningful execution path after confirming it is not reached by frameworks, external consumers, or an active compatibility or rollback plan.
5.2.3 **Divergent Change** - Separate a module when unrelated policy changes repeatedly require editing it, unless its scope is small or intentionally temporary.
5.2.4 **Shotgun Surgery** - Consolidate knowledge of a single policy when changing it requires coordinated edits in many locations; leave genuinely cross-cutting or independently evolving changes distributed.
5.2.5 **Parallel Inheritance Hierarchies** - Avoid one-to-one subclass dependencies across hierarchies; make coupled variation explicit with composition or a mapping when both dimensions must vary together.
5.2.6 **Feature Envy** - Place behavior with the object whose domain data and invariants it chiefly uses, except at deliberate adapter, mapping, reporting, or integration boundaries.
5.2.7 **Message Chain** - Avoid navigation chains that expose internal domain relationships in business logic; add direct operations unless working with a fluent API, stable data boundary, or mapper.
5.2.8 **Middle Man** - Remove forwarding components that add neither behavior nor a useful boundary; retain delegation that enforces access, adapts instability, or preserves a public contract.
5.2.9 **Inappropriate Intimacy** - Avoid making a class depend on another class's private representation; collaborate through stable public behavior unless data is intentionally shared at a boundary.
5.2.10 **Incomplete Library Class** - Introduce a local adapter or wrapper when callers repeatedly need a concrete library operation it lacks; keep isolated one-off workarounds local and avoid global monkey-patching.
5.2.11 **Alternative Classes with Different Interfaces** - Give alternatives serving the same caller role a uniform local interface, and isolate unavoidable external API differences behind adapters.
5.2.12 **Refused Bequest** - Avoid subclassing unless the subtype can honor the inherited public and protected contract; use delegation when only implementation reuse is needed.
5.2.13 **Insider Trading** - Keep modules collaborating through stable public behavior instead of internal rules or representation details, except at deliberate data-transfer or integration boundaries.

### 5.3 Dispensable or speculative structure

5.3.1 **Speculative Generality** - Avoid abstractions for imagined variation; add them only for a demonstrated need or committed compatibility boundary.
5.3.2 **Lazy Element** - Inline or remove elements that only forward work, unless they provide a meaningful domain, API, invariant, or variation boundary.
5.3.3 **Repeated Type Conditional** - Avoid scattering similar type or mode branches; centralize variant behavior when repeated decisions must evolve together.
5.3.4 **Complex Conditional** - Extract and name boolean logic when it obscures the decision; keep short, familiar local checks inline.
5.3.5 **Flag Argument** - Avoid public flags that select distinct operations; expose named operations, while retaining booleans that represent domain data.
5.3.6 **Double Negative** - Avoid negating an already negative concept; translate unavoidable negative boundary data into a positive local predicate.
5.3.7 **Spaghetti Code** - Untangle interleaved control flow and dependencies into clear local responsibilities when routine changes require tracing unrelated paths.
