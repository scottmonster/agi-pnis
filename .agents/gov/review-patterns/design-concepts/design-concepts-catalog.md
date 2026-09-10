# Code Design Concept Catalog

_Entry format: <index> **<canonical name>** _(<classification>; also known as: aliases)_ - <concise definition>. _Related:_ canonical concepts._

## 1. Control flow and conditional logic

### 1.1 Flattening and ordering control flow

1.1.1 **Guard Clauses** _(Refactoring; also known as: replace nested conditional with guard clauses)_ - Handle exceptional or invalid cases at the start, leaving the normal path flat. It makes the dominant path visible and reduces nesting. _Related:_ Early Exit.

1.1.2 **Early Exit** _(Control-flow technique)_ - Return, break, or otherwise stop once the result is known or continuing is invalid. It removes unnecessary work and nesting; it is often the mechanism used by Guard Clauses. _Related:_ Replace Control Flag with Break.

1.1.3 **Linear Flow / Happy Path** _(Control-flow technique)_ - Arrange the ordinary sequence as the visually dominant, mostly straight-line path and move exceptional handling aside. It reduces the reader's need to reconstruct the usual case. _Related:_ Guard Clauses.

1.1.4 **Replace Control Flag with Break** _(Refactoring; also known as: remove control flag)_ - Replace a variable used only to stop a loop with the loop's termination control. It exposes loop exit intent instead of making later conditions depend on hidden state.

1.1.5 **Separate Query from Modifier** _(Refactoring)_ - Split a routine that both reports information and changes state into a query and a command. Callers can reason about observation and mutation separately. _Related:_ Command pattern.

1.1.6 **Replace Loop with Pipeline** _(Refactoring)_ - Express a collection traversal as a sequence of collection transformations. Where the pipeline is clearer, it names selection, mapping, and aggregation instead of exposing loop bookkeeping. _Related:_ Split Loop.

1.1.7 **Split Loop** _(Refactoring)_ - Give each independent purpose in a loop its own traversal. It prevents one loop from carrying unrelated accumulators and conditions. _Related:_ Replace Loop with Pipeline.

1.1.8 **Substitute Algorithm** _(Refactoring)_ - Replace one algorithm body with another that has the same observable result. A clearer algorithm can make the logic understandable without changing its contract.

### 1.2 Conditions and choices

1.2.1 **Decompose Conditional** _(Refactoring; also known as: decomposed conditional)_ - Extract a complicated test, then branch, and else branch into well-named functions. Names reveal the decision's business meaning. _Related:_ Extract Function.

1.2.2 **Consolidate Conditional Expression** _(Refactoring; also known as: consolidated conditional)_ - Combine conditions with the same consequence into one meaningful condition. It eliminates repeated outcomes and makes the shared decision explicit.

1.2.3 **Consolidate Duplicate Conditional Fragments** _(Refactoring)_ - Move code repeated in every branch outside the conditional. It reduces duplication and leaves each branch responsible only for its difference. _Related:_ Duplicate Code.

1.2.4 **Decision Table / Table-Driven Logic** _(Control-flow technique)_ - Model combinations of conditions and actions as data rather than a branching tree. It makes coverage and differences inspectable when there are many combinations. _Related:_ Replace Conditional with Polymorphism.

1.2.5 **Replace Conditional with Polymorphism** _(Refactoring)_ - Move behavior selected repeatedly by type or variant into the corresponding implementations. It localizes each variant and removes distributed type tests. _Related:_ Repeated Type Conditional, State, Strategy.

1.2.6 **Introduce Special Case** _(Refactoring; also known as: introduce null object)_ - Represent an exceptional or common special case with an object that implements ordinary behavior, avoiding repeated checks. It makes the remaining main path simpler, provided the special behavior is genuinely coherent. _Related:_ Null Object.

1.2.7 **Introduce Assertion** _(Refactoring)_ - State an assumption that the surrounding code relies on. It documents a local invariant and makes violations easier to find, but it is not input validation.

1.2.8 **Replace Exception with Precheck** _(Refactoring; also known as: replace exception with test)_ - Test a predictable condition before the operation rather than using an exception as ordinary branching. It clarifies expected flow; it does not apply to truly exceptional failures.

1.2.9 **Replace Error Code with Exception** _(Refactoring)_ - Replace a special return code that callers must inspect with exception-based failure signaling. It can separate successful-path logic from failure handling when the error is exceptional. _Related:_ Replace Exception with Precheck.

1.2.10 **Finite-State Machine (FSM)** _(Pattern)_ - Represent legal states and transitions explicitly, rather than letting them emerge from dispersed flags and conditionals. It makes state-dependent behavior and invalid transitions inspectable. _Related:_ State, Repeated Type Conditional.

### 1.3 Control-flow smells and asynchronous structures

1.3.1 **Arrow Code / Arrowhead** _(Code smell)_ - Successive nested conditions push code to the right in an arrow shape. The reader must retain every enclosing condition; flattening or extraction can help. _Related:_ Deep Nesting, Guard Clauses.

1.3.2 **Deep Nesting** _(Code smell)_ - Multiple levels of conditional or loop indentation require the reader to carry too much enclosing context. It is broader than the particular arrow shape. _Related:_ Arrow Code.

1.3.3 **Pyramid of Doom** _(Code smell)_ - Nested control constructs, especially callbacks, make later work depend on an increasingly indented chain of scopes. It obscures sequencing and error paths. _Related:_ Callback Hell.

1.3.4 **Callback Hell** _(Anti-pattern)_ - Asynchronous callbacks are nested so deeply that the operation and its error handling are buried in continuation scopes. It is the asynchronous form of a pyramid of doom. _Related:_ Continuation-Passing Style.

1.3.5 **Continuation-Passing Style (CPS)** _(Pattern)_ - Pass the next computation explicitly as a continuation. It makes non-linear or asynchronous sequencing expressible, but unstructured nesting can become Callback Hell. _Related:_ Callback Hell, Futures/Promises.

1.3.6 **Futures/Promises** _(Pattern)_ - Represent a result that will be available later with an object that carries completion, value, and failure. Composable continuations can make asynchronous dependencies more explicit than nested callbacks. _Related:_ Callback Hell, Structured Concurrency.

1.3.7 **Structured Concurrency** _(Pattern)_ - Scope concurrent work so child tasks complete or are cancelled before their parent scope finishes. It keeps lifetimes, cancellation, and error propagation visible instead of leaving detached work. _Related:_ Futures/Promises.

## 2. Functions, statements, and parameters

### 2.1 Naming, extraction, and local state

2.1.1 **Extract Function** _(Refactoring; also known as: extract method; replace inline code with function call)_ - Replace a detailed code fragment with a well-named function. It makes the caller show a higher-level narrative and gives the fragment a single nameable purpose. _Related:_ Long Function.

2.1.2 **Inline Function** _(Refactoring; also known as: inline method)_ - Replace a function call with its body when the function no longer adds meaning. It removes indirection that hides rather than names behavior. _Related:_ Middle Man.

2.1.3 **Extract Variable** _(Refactoring; also known as: introduce explaining variable)_ - Bind part of an expression to a meaningful local name. It makes an intermediate idea visible, particularly in a condition or calculation.

2.1.4 **Inline Variable** _(Refactoring; also known as: inline temp)_ - Replace a variable used only once with its expression. It removes a name that adds no concept and can expose the direct computation.

2.1.5 **Split Variable** _(Refactoring; also known as: split temp; remove assignments to parameters)_ - Give distinct roles separate variables rather than reassigning one name. It preserves what each value means across the routine.

2.1.6 **Replace Temp with Query** _(Refactoring)_ - Replace a local temporary with a query that computes the value. It makes the derived concept reusable and can enable further extraction, when repeated calculation is acceptable.

2.1.7 **Replace Derived Variable with Query** _(Refactoring)_ - Compute a value from its sources rather than storing and manually maintaining a duplicate. It prevents the local representation from going stale.

2.1.8 **Replace Magic Literal with Symbolic Constant** _(Refactoring; also known as: replace magic number)_ - Replace an unexplained literal with a named constant. It exposes the value's meaning and gives future changes one named location.

2.1.9 **Move Statements into Function** _(Refactoring)_ - Move call-site statements that always accompany a function into that function. It centralizes a repeated protocol and reduces callers' sequencing burden.

2.1.10 **Move Statements to Callers** _(Refactoring)_ - Move statements out when a function wrongly bundles behavior that different callers need to control. It makes the function's actual responsibility narrower.

2.1.11 **Split Phase** _(Refactoring)_ - Separate processing that performs different conceptual jobs into distinct stages. It makes each stage's inputs, outputs, and reasoning model clearer.

2.1.12 **Slide Statements** _(Refactoring)_ - Move related statements together. It makes the code's local grouping match its data/control dependency.

2.1.13 **Return Modified Value** _(Refactoring)_ - Have a function return the value it modified so callers can continue with the updated value directly. It can make a data transformation chain explicit and reduce separate lookup or mutation steps.

### 2.2 Function contracts and arguments

2.2.1 **Change Function Declaration** _(Refactoring; also known as: change signature, rename function/method, add or remove parameter)_ - Deliberately change a function's name, visibility, parameters, or result to make its contract fit its responsibility. Clear contracts make every call easier to read and change.

2.2.2 **Rename Variable / Rename Field** _(Refactoring)_ - Change a name to express the value or member's current role. A precise name removes local interpretation work. _Related:_ Mysterious Name.

2.2.3 **Parameterize Function** _(Refactoring; also known as: parameterize method)_ - Replace near-duplicate functions with one function whose explicit parameter describes the true variation. It centralizes shared behavior without using an opaque flag. _Related:_ Flag Argument.

2.2.4 **Remove Flag Argument** _(Refactoring; also known as: replace parameter with explicit methods)_ - Replace a boolean or mode parameter that selects different operations with distinct named operations. Call sites reveal the chosen behavior. _Related:_ Flag Argument.

2.2.5 **Replace Parameter with Query** _(Refactoring)_ - Let a function obtain an available value rather than passing it redundantly. It can simplify calls, but only when doing so does not hide a meaningful dependency.

2.2.6 **Replace Query with Parameter** _(Refactoring)_ - Pass a value explicitly instead of having a function obtain it. It exposes a dependency, makes behavior easier to understand in context, and can reduce hidden coupling.

2.2.7 **Preserve Whole Object** _(Refactoring)_ - Pass the object that owns a cluster of values instead of repeatedly extracting and passing individual values. It reduces argument noise when the callee genuinely operates on that object's information. _Related:_ Long Parameter List.

2.2.8 **Introduce Parameter Object** _(Refactoring)_ - Replace a recurring group of parameters with an object representing that group. It names the relationship, shortens calls, and provides a home for related behavior. _Related:_ Data Clump.

2.2.9 **Replace Function with Command** _(Refactoring; also known as: replace method with method object)_ - Turn an operation into an object that holds its parameters and intermediate state. It can clarify a complex operation or support composition, but adds indirection. _Related:_ Command.

2.2.10 **Replace Command with Function** _(Refactoring)_ - Collapse a command object into a function when the object no longer earns its state or extensibility cost. It restores a direct, readable operation.

2.2.11 **Fluent Interface** _(Pattern)_ - Design a call sequence so each call returns an object that permits the next meaningful call. It can make a coherent declarative sequence readable, but excessive chaining can become a Message Chain or hide intermediate values. _Related:_ Builder, Message Chain. _Distinction:_ method chaining is a common implementation technique, not a synonym for fluency.

## 3. Data, state, and model representation

### 3.1 Encapsulation and representation refactorings

3.1.1 **Encapsulate Variable** _(Refactoring; also known as: encapsulate field, self-encapsulate field)_ - Route access to mutable data through a named access point. It creates one place to understand, validate, or change its representation. _Related:_ Global Data, Mutable Data.

3.1.2 **Encapsulate Record** _(Refactoring; also known as: replace record with data class)_ - Replace direct access to a data record with an object that controls its fields and operations. It limits representation leakage and gives the model behavior a home. _Related:_ Data Class.

3.1.3 **Encapsulate Collection** _(Refactoring)_ - Prevent clients from directly mutating a collection and provide controlled collection operations. It preserves collection invariants and makes mutation sites visible.

3.1.4 **Replace Primitive with Object** _(Refactoring; also known as: replace data value with object; replace type code with class)_ - Represent a domain value with a small type rather than a raw primitive. It gives validation, formatting, and rules a single explicit home. _Related:_ Primitive Obsession, Value Object.

3.1.5 **Replace Array with Object** _(Refactoring)_ - Replace positional array elements with named fields. It removes index-based interpretation and makes the data's shape explicit.

3.1.6 **Change Value to Reference** _(Refactoring)_ - Make independently copied data share a referenced identity when the domain requires shared updates. It makes identity semantics explicit. _Related:_ Value Object.

3.1.7 **Change Reference to Value** _(Refactoring)_ - Make an object a freely copied value when shared identity is unnecessary. It reduces aliasing and the mental cost of tracking shared mutable state. _Related:_ Value Object.

3.1.8 **Replace Subclass with Fields** _(Refactoring; also known as: remove subclass)_ - Replace subclasses that differ only through constant data with fields or type data. It removes a hierarchy that does not carry distinct behavior.

3.1.9 **Remove Setting Method** _(Refactoring)_ - Remove a public setter when a field should be initialized once and then remain unchanged. It makes immutability and the object's valid lifecycle more visible.

3.1.10 **Replace Type Code with Subclasses** _(Refactoring; also known as: extract subclass)_ - Turn a type discriminator into subclasses when variants need distinct state or behavior. It organizes variation around the variant rather than dispersed checks. _Related:_ Repeated Type Conditional.

3.1.11 **Replace Type Code with State/Strategy** _(Refactoring)_ - Replace a changing type/mode code with a delegated State or Strategy object. It isolates changing behavior without making the owning object a long conditional. _Related:_ State, Strategy.

### 3.2 Named model patterns

3.2.1 **Value Object** _(Pattern)_ - Model a conceptual value by its attributes rather than a stable identity, ordinarily with value equality and safe copying/immutability. It makes equality and mutation expectations legible. _Related:_ Change Reference to Value.

3.2.2 **Null Object** _(Pattern)_ - Supply an object with neutral or special-case behavior in place of absent data. It can remove scattered null checks, but must not conceal a meaningful absence or failure.

3.2.3 **Data Transfer Object (DTO)** _(Pattern; also known as: data transfer object)_ - Package data for transfer across a boundary, usually without domain behavior. It makes boundary shape explicit, but should not be mistaken for a domain model. _Related:_ Data Class.

3.2.4 **Data Mapper** _(Pattern)_ - Keep mapping between domain objects and storage representations in a separate layer. It can keep persistence details out of domain code, at the cost of another abstraction. _Related:_ Active Record.

3.2.5 **Active Record** _(Pattern)_ - Let an object wrap a database row and carry persistence operations. It makes simple data access direct, while coupling model and storage concerns. _Related:_ Data Mapper.

3.2.6 **Repository** _(Pattern)_ - Provide collection-like access to domain objects while hiding storage queries. It can centralize persistence vocabulary, but is not automatically useful over every data source. _Related:_ Data Mapper.

## 4. Objects, dependencies, and collaboration

### 4.1 Object and dependency refactorings

4.1.1 **Extract Class** _(Refactoring)_ - Move a coherent subset of fields and behavior into a new class. It reduces a class's responsibilities and gives the extracted concept a name. _Related:_ Large Class, God Class.

4.1.2 **Inline Class** _(Refactoring)_ - Move a class's behavior and data into another class when it no longer represents a useful concept. It removes a needless hop. _Related:_ Lazy Element.

4.1.3 **Move Function / Move Field** _(Refactoring; also known as: move method)_ - Place behavior or data with the object that most naturally owns it. This reduces feature envy and makes responsibility discoverable. _Related:_ Feature Envy.

4.1.4 **Combine Functions into Class** _(Refactoring)_ - Group functions that operate on the same shared data into a class. It exposes the data-behavior relationship and limits parameter repetition.

4.1.5 **Combine Functions into Transform** _(Refactoring)_ - Group transformations over a common record into a single transformation pipeline. It keeps derived data creation close to its source representation.

4.1.6 **Hide Delegate** _(Refactoring)_ - Give a client a method on the server rather than making it navigate to a delegate. It reduces client knowledge of internal object structure. _Related:_ Message Chain, Law of Demeter.

4.1.7 **Remove Middle Man** _(Refactoring)_ - Remove a component that only forwards calls when the indirection no longer protects a useful boundary. It makes the actual collaborator visible. _Related:_ Middle Man.

4.1.8 **Extract Superclass** _(Refactoring)_ - Pull shared fields and behavior into an explicit supertype. It states a common contract and centralizes genuine commonality.

4.1.9 **Pull Up Method / Pull Up Field** _(Refactoring)_ - Move duplicated behavior or data from subclasses to a superclass. It prevents hierarchy-wide drift when the member is truly common.

4.1.10 **Pull Up Constructor Body** _(Refactoring)_ - Move common subclass-constructor initialization into the superclass constructor. It keeps shared initialization in one visible place and reduces constructor drift.

4.1.11 **Push Down Method / Push Down Field** _(Refactoring)_ - Move a superclass member used by only some subclasses into those subclasses. It makes the base contract smaller and more honest.

4.1.12 **Collapse Hierarchy** _(Refactoring)_ - Merge a superclass and subclass that no longer differ meaningfully. It removes inheritance ceremony without a behavioral distinction.

4.1.13 **Replace Subclass with Delegate** _(Refactoring)_ - Replace inheritance used for one varying part with delegation to a component. It can localize variation and avoid an artificial hierarchy.

4.1.14 **Replace Superclass with Delegate** _(Refactoring; also known as: replace inheritance with delegation)_ - Delegate inherited behavior to a contained object when inheritance exposes or couples too much. It makes the reused role explicit.

4.1.15 **Replace Constructor with Factory Function** _(Refactoring; also known as: replace constructor with factory method)_ - Replace direct construction with a named creation function. It can make creation intent, validation, or subtype selection visible. _Related:_ Factory Method.

4.1.16 **Dependency Injection** _(Pattern)_ - Supply a collaborator from outside the object, commonly through its constructor, rather than creating or locating it internally. Dependencies become visible in the contract and independently configurable. _Related:_ Service Locator.

4.1.17 **Service Locator** _(Pattern)_ - An object explicitly asks a locator for a service. It centralizes lookup but hides the requested dependency from the constructor; it is not inherently an anti-pattern in Fowler's account. _Related:_ Dependency Injection.

4.1.18 **Law of Demeter** _(Pattern; also known as: principle of least knowledge)_ - Limit a method to collaborating directly with its immediate objects rather than navigating through object graphs. It reduces structural coupling; it motivates Hide Delegate but is not identical to it. _Related:_ Message Chain.

### 4.2 Classic object patterns

4.2.1 **Factory Method** _(Pattern)_ - Let a base operation defer creation of a product to subclasses or supplied creators. It localizes construction variation. _Related:_ Abstract Factory, Replace Constructor with Factory Function.

4.2.2 **Abstract Factory** _(Pattern)_ - Provide an interface for creating a related family of objects without naming concrete classes. It keeps family substitutions coherent, but can add indirection.

4.2.3 **Builder** _(Pattern)_ - Construct a complex object step by step through a dedicated builder. It makes optional parts and construction order explicit.

4.2.4 **Prototype** _(Pattern)_ - Create objects by copying a configured prototype. It can simplify creation where copying is the domain operation, while making copy semantics important.

4.2.5 **Singleton** _(Pattern)_ - Restrict a type to one instance and provide access to it. It makes shared global state easy to reach but often hides dependencies and complicates change. _Related:_ Global Data, Service Locator.

4.2.6 **Adapter** _(Pattern)_ - Wrap an incompatible interface in one expected by clients. It isolates foreign or legacy API differences.

4.2.7 **Bridge** _(Pattern)_ - Separate an abstraction from its implementation so each can vary independently. It prevents a cross-product of subclasses when two dimensions genuinely vary.

4.2.8 **Composite** _(Pattern)_ - Treat individual and composed objects through a common interface. It simplifies client traversal of tree-like structures when the common operations are real.

4.2.9 **Decorator** _(Pattern)_ - Wrap an object to add behavior while preserving its interface. It localizes optional responsibilities, though stacked decorators can obscure behavior.

4.2.10 **Facade** _(Pattern)_ - Present a simpler interface over a complex subsystem. It reduces client knowledge and gives the subsystem a readable entry point. _Related:_ Hide Delegate.

4.2.11 **Flyweight** _(Pattern)_ - Share immutable common state across many fine-grained objects. It can reduce duplication but separates intrinsic from contextual state, which may increase cognitive cost.

4.2.12 **Proxy** _(Pattern)_ - Substitute an object that controls access to another object with the same interface. It localizes access, caching, or remoting concerns, but can hide cost or behavior.

4.2.13 **Chain of Responsibility** _(Pattern)_ - Pass a request through handlers until one handles it. It separates handlers, but ordering and the no-handler case must remain clear.

4.2.14 **Command** _(Pattern)_ - Represent a request as an object containing the operation and its context. It makes queuing, logging, undo, and parameterization explicit, at an object-cost trade-off. _Related:_ Replace Function with Command.

4.2.15 **Iterator** _(Pattern)_ - Traverse an aggregate through a dedicated cursor/interface rather than exposing its representation. It separates traversal from storage.

4.2.16 **Mediator** _(Pattern)_ - Route many-object collaboration through one coordinating object. It reduces peer-to-peer coupling, but the mediator can become a Large Class.

4.2.17 **Memento** _(Pattern)_ - Capture and restore an object's state without exposing its internals. It localizes undo/history mechanics and preserves encapsulation.

4.2.18 **Observer** _(Pattern)_ - Let dependents subscribe to state changes from a subject. It decouples publishers and listeners, while making event order and lifetime important.

4.2.19 **State** _(Pattern)_ - Delegate behavior that varies with an object's internal state to state-specific objects. It replaces scattered state conditionals with explicit state behavior. _Related:_ Strategy.

4.2.20 **Strategy** _(Pattern)_ - Encapsulate a family of interchangeable algorithms behind one interface. It makes a policy choice explicit and keeps each algorithm separate. _Related:_ State.

4.2.21 **Template Method** _(Pattern)_ - Put an algorithm's invariant skeleton in a base operation and defer selected steps to subclasses. It reveals the algorithm structure, but binds variation to inheritance.

4.2.22 **Visitor** _(Pattern)_ - Move operations over a stable object structure into visitor objects. It groups operations by concern, but makes adding new element types more costly.

## 5. Code smells and anti-patterns

### 5.1 Size, naming, and representation smells

5.1.1 **Mysterious Name** _(Code smell)_ - A name does not reveal its purpose, value, or role. It forces interpretation at every use; renaming is the usual first correction. _Related:_ Rename Variable.

5.1.2 **Long Function / Long Method** _(Code smell)_ - A routine contains enough distinct activity that its purpose and structure are no longer visible as one unit. It makes change and review require excessive local context. _Related:_ Extract Function.

5.1.3 **Large Class** _(Code smell; also known as: God Class, God Object)_ - A class accumulates too many unrelated responsibilities, behavior, or state. It becomes a central change hotspot with poor discoverability. _Related:_ Extract Class.

5.1.4 **Long Parameter List** _(Code smell)_ - A function requires many independent inputs. Calls become difficult to read and the list often reveals a missing object or misplaced responsibility. _Related:_ Introduce Parameter Object.

5.1.5 **Data Clump** _(Code smell)_ - The same group of values repeatedly appears together in parameters, fields, or locals. The recurring group likely names a missing concept. _Related:_ Introduce Parameter Object.

5.1.6 **Primitive Obsession** _(Code smell)_ - Domain concepts are repeatedly represented by raw strings, numbers, booleans, or collections. Rules and meaning spread because the type does not carry them. _Related:_ Replace Primitive with Object.

5.1.7 **Data Class** _(Code smell)_ - An object exposes data with little behavior while other code performs its domain work. It may be appropriate as a DTO, but is a smell when it is an anemic domain object. _Related:_ DTO, Feature Envy.

5.1.8 **Global Data** _(Code smell)_ - State is reachable from broadly unrelated code. Its readers and writers are difficult to find, making effects and changes nonlocal. _Related:_ Singleton, Encapsulate Variable.

5.1.9 **Mutable Data** _(Code smell)_ - State can be changed from multiple places without a narrow protocol. Readers must account for all potential writers and ordering. _Related:_ Encapsulate Collection, Value Object.

5.1.10 **Temporary Field** _(Code smell)_ - An instance field is meaningful only in certain paths or phases. It makes the object's normal invariant unclear. _Related:_ Replace Function with Command.

5.1.11 **Comments (as deodorant)** _(Code smell)_ - A comment explains code whose structure could instead express the idea. The smell is not comments themselves, but comments that mask unclear code. _Related:_ Extract Function, Rename Variable.

### 5.2 Duplication, coupling, and change smells

5.2.1 **Duplicate Code** _(Code smell; also known as: copy-and-paste programming)_ - The same or substantially similar logic appears in multiple places. Independent copies drift and make one conceptual change require many edits. _Related:_ Extract Function, Pull Up Method.

5.2.2 **Dead Code** _(Code smell)_ - Code remains although no meaningful execution path uses it. It adds false possibilities to the reader's model and can be removed after usage is established. _Related:_ Speculative Generality.

5.2.3 **Divergent Change** _(Code smell)_ - One module changes for several unrelated reasons. Its responsibilities are mixed, so a change risks unrelated behavior. _Related:_ Extract Class.

5.2.4 **Shotgun Surgery** _(Code smell)_ - One conceptual change requires many small edits across locations. Knowledge of one rule is scattered and omissions become likely. _Related:_ Move Function.

5.2.5 **Parallel Inheritance Hierarchies** _(Code smell)_ - Adding a subclass in one hierarchy requires a matching subclass in another. The duplicated variation structure makes extension brittle.

5.2.6 **Feature Envy** _(Code smell)_ - A function uses another object's data more than its own. Behavior is likely located away from the data and invariants it needs. _Related:_ Move Function.

5.2.7 **Message Chain** _(Code smell)_ - A client reaches through a chain such as `a.getB().getC()`. It exposes several internal relationships and makes structural changes ripple outward. _Related:_ Hide Delegate, Law of Demeter.

5.2.8 **Middle Man** _(Code smell)_ - A component mostly forwards calls to another component without contributing behavior or protecting a useful boundary. It adds navigation cost. _Related:_ Remove Middle Man.

5.2.9 **Inappropriate Intimacy** _(Code smell)_ - Classes know or manipulate each other's internal details too closely. Such coupling makes a local representation change nonlocal. _Related:_ Encapsulate Record.

5.2.10 **Incomplete Library Class** _(Code smell)_ - A library type lacks a needed operation but cannot be modified directly. Workarounds can scatter across callers; an adapter or wrapper can localize them. _Related:_ Adapter.

5.2.11 **Alternative Classes with Different Interfaces** _(Code smell)_ - Classes that perform the same role expose different method names or shapes. Callers cannot treat the shared concept uniformly.

5.2.12 **Refused Bequest** _(Code smell)_ - A subclass inherits behavior or data it does not need or cannot honor. The hierarchy advertises a false substitutability relationship. _Related:_ Replace Superclass with Delegate.

5.2.13 **Insider Trading** _(Code smell)_ - Modules or classes exchange knowledge of each other's private concerns more than their public collaboration requires. It turns internal changes into joint changes. _Related:_ Inappropriate Intimacy.

### 5.3 Dispensable or speculative structure

5.3.1 **Speculative Generality** _(Code smell)_ - Abstractions, parameters, hooks, or extension points exist for imagined future needs rather than a present burden. They enlarge the code readers must understand. _Related:_ Remove Dead Code.

5.3.2 **Lazy Element** _(Code smell)_ - A class, method, or other element no longer does enough to justify its existence. It adds a name and navigation step without a real responsibility. _Related:_ Inline Class, Inline Function.

5.3.3 **Repeated Type Conditional** _(Code smell; also known as: repeated switch, switch statements)_ - Similar branches repeatedly select behavior from a type, state, or mode code. Every new variant requires finding all of the decisions. _Related:_ Replace Conditional with Polymorphism.

5.3.4 **Complex Conditional** _(Code smell)_ - A condition combines enough logic that understanding the decision is substantial work. It obscures why a branch applies. _Related:_ Decompose Conditional.

5.3.5 **Flag Argument** _(Code smell)_ - A boolean or similar parameter makes one function perform distinct operations. The call does not name the behavior and the implementation tends toward conditional branching. _Related:_ Remove Flag Argument.

5.3.6 **Double Negative** _(Code smell)_ - A negated concept is negated again, such as `!isNotReady`. The reader must mentally invert the condition twice.

5.3.7 **Spaghetti Code** _(Anti-pattern)_ - Control flow and dependencies are tangled enough that there is no clear local structure or path of responsibility. It is an umbrella diagnosis, not an exact synonym for any one smell. _Related:_ Arrow Code, Duplicate Code, Message Chain.
