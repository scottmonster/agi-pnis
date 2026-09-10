# Code Design Concept Sources

This ledger preserves the direct research sources for the canonical [code design concept catalog](../../design-concepts/design-concepts-catalog.md).

## 1. Control flow and conditional logic

### 1.1 Flattening and ordering control flow

#### 1.1.1 Guard Clauses

- [Fowler](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html)

#### 1.1.2 Early Exit

- [Fowler on guard clauses](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html)

#### 1.1.3 Linear Flow / Happy Path

- [Fowler on guard clauses](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html)

#### 1.1.4 Replace Control Flag with Break

- [Fowler](https://refactoring.com/catalog/replaceControlFlagWithBreak.html)

#### 1.1.5 Separate Query from Modifier

- [Fowler](https://refactoring.com/catalog/separateQueryFromModifier.html)

#### 1.1.6 Replace Loop with Pipeline

- [Fowler](https://refactoring.com/catalog/replaceLoopWithPipeline.html)

#### 1.1.7 Split Loop

- [Fowler](https://refactoring.com/catalog/splitLoop.html)

#### 1.1.8 Substitute Algorithm

- [Fowler](https://refactoring.com/catalog/substituteAlgorithm.html)

### 1.2 Conditions and choices

#### 1.2.1 Decompose Conditional

- [Fowler](https://refactoring.com/catalog/decomposeConditional.html)

#### 1.2.2 Consolidate Conditional Expression

- [Fowler](https://refactoring.com/catalog/consolidateConditionalExpression.html)

#### 1.2.3 Consolidate Duplicate Conditional Fragments

- [Fowler](https://refactoring.com/catalog/slideStatements.html)

#### 1.2.4 Decision Table / Table-Driven Logic

- [Fowler](https://martinfowler.com/dslCatalog/decisionTable.html)

#### 1.2.5 Replace Conditional with Polymorphism

- [Fowler](https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html)

#### 1.2.6 Introduce Special Case

- [Fowler](https://refactoring.com/catalog/introduceSpecialCase.html)

#### 1.2.7 Introduce Assertion

- [Fowler](https://refactoring.com/catalog/introduceAssertion.html)

#### 1.2.8 Replace Exception with Precheck

- [Fowler](https://refactoring.com/catalog/replaceExceptionWithPrecheck.html)

#### 1.2.9 Replace Error Code with Exception

- [Fowler](https://refactoring.com/catalog/replaceErrorCodeWithException.html)

#### 1.2.10 Finite-State Machine (FSM)

- [Refactoring Guru](https://refactoring.guru/design-patterns/state)

### 1.3 Control-flow smells and asynchronous structures

#### 1.3.1 Arrow Code / Arrowhead

- [Coding Horror](https://blog.codinghorror.com/flattening-arrow-code/)

#### 1.3.2 Deep Nesting

- [Linux kernel coding style](https://www.kernel.org/doc/html/v5.3/process/coding-style.html)

#### 1.3.3 Pyramid of Doom

- [SurviveJS](https://survivejs.com/blog/pyramid-of-doom)

#### 1.3.4 Callback Hell

- [SurviveJS](https://survivejs.com/blog/pyramid-of-doom)

#### 1.3.5 Continuation-Passing Style (CPS)

- [Guy Steele and Gerald Sussman, *Lambda: The Ultimate Imperative*](https://dspace.mit.edu/handle/1721.1/5753)

#### 1.3.6 Futures/Promises

- [Fowler, *P of EAA*: Asynchronous Completion Token](https://martinfowler.com/eaaCatalog/asynchronousCompletionToken.html)

#### 1.3.7 Structured Concurrency

- [Nathaniel J. Smith](https://vorpus.org/blog/notes-on-structured-concurrency-or-go-statement-considered-harmful/)

## 2. Functions, statements, and parameters

### 2.1 Naming, extraction, and local state

#### 2.1.1 Extract Function

- [Fowler](https://refactoring.com/catalog/extractFunction.html)

#### 2.1.2 Inline Function

- [Fowler](https://refactoring.com/catalog/inlineFunction.html)

#### 2.1.3 Extract Variable

- [Fowler](https://refactoring.com/catalog/extractVariable.html)

#### 2.1.4 Inline Variable

- [Fowler](https://refactoring.com/catalog/inlineVariable.html)

#### 2.1.5 Split Variable

- [Fowler](https://refactoring.com/catalog/splitVariable.html)

#### 2.1.6 Replace Temp with Query

- [Fowler](https://refactoring.com/catalog/replaceTempWithQuery.html)

#### 2.1.7 Replace Derived Variable with Query

- [Fowler](https://refactoring.com/catalog/replaceDerivedVariableWithQuery.html)

#### 2.1.8 Replace Magic Literal with Symbolic Constant

- [Fowler](https://refactoring.com/catalog/replaceMagicLiteral.html)

#### 2.1.9 Move Statements into Function

- [Fowler](https://refactoring.com/catalog/moveStatementsIntoFunction.html)

#### 2.1.10 Move Statements to Callers

- [Fowler](https://refactoring.com/catalog/moveStatementsToCallers.html)

#### 2.1.11 Split Phase

- [Fowler](https://refactoring.com/catalog/splitPhase.html)

#### 2.1.12 Slide Statements

- [Fowler](https://refactoring.com/catalog/slideStatements.html)

#### 2.1.13 Return Modified Value

- [Fowler](https://refactoring.com/catalog/returnModifiedValue.html)

### 2.2 Function contracts and arguments

#### 2.2.1 Change Function Declaration

- [Fowler](https://refactoring.com/catalog/changeFunctionDeclaration.html)

#### 2.2.2 Rename Variable / Rename Field

- [variable](https://refactoring.com/catalog/renameVariable.html), [field](https://refactoring.com/catalog/renameField.html)

#### 2.2.3 Parameterize Function

- [Fowler](https://refactoring.com/catalog/parameterizeFunction.html)

#### 2.2.4 Remove Flag Argument

- [Fowler](https://refactoring.com/catalog/removeFlagArgument.html)

#### 2.2.5 Replace Parameter with Query

- [Fowler](https://refactoring.com/catalog/replaceParameterWithQuery.html)

#### 2.2.6 Replace Query with Parameter

- [Fowler](https://refactoring.com/catalog/replaceQueryWithParameter.html)

#### 2.2.7 Preserve Whole Object

- [Fowler](https://refactoring.com/catalog/preserveWholeObject.html)

#### 2.2.8 Introduce Parameter Object

- [Fowler](https://refactoring.com/catalog/introduceParameterObject.html)

#### 2.2.9 Replace Function with Command

- [Fowler](https://refactoring.com/catalog/replaceFunctionWithCommand.html)

#### 2.2.10 Replace Command with Function

- [Fowler](https://refactoring.com/catalog/replaceCommandWithFunction.html)

#### 2.2.11 Fluent Interface

- [Fowler](https://martinfowler.com/bliki/FluentInterface.html)

## 3. Data, state, and model representation

### 3.1 Encapsulation and representation refactorings

#### 3.1.1 Encapsulate Variable

- [Fowler](https://refactoring.com/catalog/encapsulateVariable.html)

#### 3.1.2 Encapsulate Record

- [Fowler](https://refactoring.com/catalog/encapsulateRecord.html)

#### 3.1.3 Encapsulate Collection

- [Fowler](https://refactoring.com/catalog/encapsulateCollection.html)

#### 3.1.4 Replace Primitive with Object

- [Fowler](https://refactoring.com/catalog/replacePrimitiveWithObject.html)

#### 3.1.5 Replace Array with Object

- [Fowler](https://refactoring.com/catalog/replaceArrayWithObject.html)

#### 3.1.6 Change Value to Reference

- [Fowler](https://refactoring.com/catalog/changeValueToReference.html)

#### 3.1.7 Change Reference to Value

- [Fowler](https://refactoring.com/catalog/changeReferenceToValue.html)

#### 3.1.8 Replace Subclass with Fields

- [Fowler](https://refactoring.com/catalog/removeSubclass.html)

#### 3.1.9 Remove Setting Method

- [Fowler](https://refactoring.com/catalog/removeSettingMethod.html)

#### 3.1.10 Replace Type Code with Subclasses

- [Fowler](https://refactoring.com/catalog/replaceTypeCodeWithSubclasses.html)

#### 3.1.11 Replace Type Code with State/Strategy

- [Fowler](https://refactoring.com/catalog/replaceTypeCodeWithStateStrategy.html)

### 3.2 Named model patterns

#### 3.2.1 Value Object

- [Fowler](https://martinfowler.com/eaaCatalog/valueObject.html)

#### 3.2.2 Null Object

- [Fowler](https://refactoring.com/catalog/introduceSpecialCase.html). Alias: Introduce Special Case when used as a transformation

#### 3.2.3 Data Transfer Object (DTO)

- [Fowler](https://martinfowler.com/eaaCatalog/dataTransferObject.html)

#### 3.2.4 Data Mapper

- [Fowler](https://martinfowler.com/eaaCatalog/dataMapper.html)

#### 3.2.5 Active Record

- [Fowler](https://martinfowler.com/eaaCatalog/activeRecord.html)

#### 3.2.6 Repository

- [Fowler](https://martinfowler.com/eaaCatalog/repository.html)

## 4. Objects, dependencies, and collaboration

### 4.1 Object and dependency refactorings

#### 4.1.1 Extract Class

- [Fowler](https://refactoring.com/catalog/extractClass.html)

#### 4.1.2 Inline Class

- [Fowler](https://refactoring.com/catalog/inlineClass.html)

#### 4.1.3 Move Function / Move Field

- [function](https://refactoring.com/catalog/moveFunction.html), [field](https://refactoring.com/catalog/moveField.html)

#### 4.1.4 Combine Functions into Class

- [Fowler](https://refactoring.com/catalog/combineFunctionsIntoClass.html)

#### 4.1.5 Combine Functions into Transform

- [Fowler](https://refactoring.com/catalog/combineFunctionsIntoTransform.html)

#### 4.1.6 Hide Delegate

- [Fowler](https://refactoring.com/catalog/hideDelegate.html)

#### 4.1.7 Remove Middle Man

- [Fowler](https://refactoring.com/catalog/removeMiddleMan.html)

#### 4.1.8 Extract Superclass

- [Fowler](https://refactoring.com/catalog/extractSuperclass.html)

#### 4.1.9 Pull Up Method / Pull Up Field

- [method](https://refactoring.com/catalog/pullUpMethod.html), [field](https://refactoring.com/catalog/pullUpField.html)

#### 4.1.10 Pull Up Constructor Body

- [Fowler](https://refactoring.com/catalog/pullUpConstructorBody.html)

#### 4.1.11 Push Down Method / Push Down Field

- [method](https://refactoring.com/catalog/pushDownMethod.html), [field](https://refactoring.com/catalog/pushDownField.html)

#### 4.1.12 Collapse Hierarchy

- [Fowler](https://refactoring.com/catalog/collapseHierarchy.html)

#### 4.1.13 Replace Subclass with Delegate

- [Fowler](https://refactoring.com/catalog/replaceSubclassWithDelegate.html)

#### 4.1.14 Replace Superclass with Delegate

- [Fowler](https://refactoring.com/catalog/replaceSuperclassWithDelegate.html)

#### 4.1.15 Replace Constructor with Factory Function

- [Fowler](https://refactoring.com/catalog/replaceConstructorWithFactoryFunction.html)

#### 4.1.16 Dependency Injection

- [Fowler](https://martinfowler.com/articles/injection.html)

#### 4.1.17 Service Locator

- [Fowler](https://martinfowler.com/articles/injection.html)

#### 4.1.18 Law of Demeter

- [Northeastern University Demeter project](https://www2.ccs.neu.edu/research/demeter/demeter-method/LawOfDemeter/)

### 4.2 Classic object patterns

#### 4.2.1 Factory Method

- [Refactoring Guru](https://refactoring.guru/design-patterns/factory-method)

#### 4.2.2 Abstract Factory

- [Refactoring Guru](https://refactoring.guru/design-patterns/abstract-factory)

#### 4.2.3 Builder

- [Refactoring Guru](https://refactoring.guru/design-patterns/builder)

#### 4.2.4 Prototype

- [Refactoring Guru](https://refactoring.guru/design-patterns/prototype)

#### 4.2.5 Singleton

- [Refactoring Guru](https://refactoring.guru/design-patterns/singleton)

#### 4.2.6 Adapter

- [Refactoring Guru](https://refactoring.guru/design-patterns/adapter)

#### 4.2.7 Bridge

- [Refactoring Guru](https://refactoring.guru/design-patterns/bridge)

#### 4.2.8 Composite

- [Refactoring Guru](https://refactoring.guru/design-patterns/composite)

#### 4.2.9 Decorator

- [Refactoring Guru](https://refactoring.guru/design-patterns/decorator)

#### 4.2.10 Facade

- [Refactoring Guru](https://refactoring.guru/design-patterns/facade)

#### 4.2.11 Flyweight

- [Refactoring Guru](https://refactoring.guru/design-patterns/flyweight)

#### 4.2.12 Proxy

- [Refactoring Guru](https://refactoring.guru/design-patterns/proxy)

#### 4.2.13 Chain of Responsibility

- [Refactoring Guru](https://refactoring.guru/design-patterns/chain-of-responsibility)

#### 4.2.14 Command

- [Refactoring Guru](https://refactoring.guru/design-patterns/command)

#### 4.2.15 Iterator

- [Refactoring Guru](https://refactoring.guru/design-patterns/iterator)

#### 4.2.16 Mediator

- [Refactoring Guru](https://refactoring.guru/design-patterns/mediator)

#### 4.2.17 Memento

- [Refactoring Guru](https://refactoring.guru/design-patterns/memento)

#### 4.2.18 Observer

- [Refactoring Guru](https://refactoring.guru/design-patterns/observer)

#### 4.2.19 State

- [Refactoring Guru](https://refactoring.guru/design-patterns/state)

#### 4.2.20 Strategy

- [Refactoring Guru](https://refactoring.guru/design-patterns/strategy)

#### 4.2.21 Template Method

- [Refactoring Guru](https://refactoring.guru/design-patterns/template-method)

#### 4.2.22 Visitor

- [Refactoring Guru](https://refactoring.guru/design-patterns/visitor)

## 5. Code smells and anti-patterns

### 5.1 Size, naming, and representation smells

#### 5.1.1 Mysterious Name

- [Fowler](https://martinfowler.com/bliki/CodeSmell.html)

#### 5.1.2 Long Function / Long Method

- [Refactoring Guru](https://refactoring.guru/smells/long-method)

#### 5.1.3 Large Class

- [Refactoring Guru](https://refactoring.guru/smells/large-class)

#### 5.1.4 Long Parameter List

- [Refactoring Guru](https://refactoring.guru/smells/long-parameter-list)

#### 5.1.5 Data Clump

- [Fowler](https://martinfowler.com/bliki/DataClump.html)

#### 5.1.6 Primitive Obsession

- [Refactoring Guru](https://refactoring.guru/smells/primitive-obsession)

#### 5.1.7 Data Class

- [Refactoring Guru](https://refactoring.guru/smells/data-class)

#### 5.1.8 Global Data

- [Fowler](https://martinfowler.com/bliki/CodeSmell.html)

#### 5.1.9 Mutable Data

- [Fowler](https://martinfowler.com/bliki/CodeSmell.html)

#### 5.1.10 Temporary Field

- [Refactoring Guru](https://refactoring.guru/smells/temporary-field)

#### 5.1.11 Comments (as deodorant)

- [Refactoring Guru](https://refactoring.guru/smells/comments)

### 5.2 Duplication, coupling, and change smells

#### 5.2.1 Duplicate Code

- [Refactoring Guru](https://refactoring.guru/smells/duplicate-code)

#### 5.2.2 Dead Code

- [Fowler](https://refactoring.com/catalog/removeDeadCode.html)

#### 5.2.3 Divergent Change

- [Refactoring Guru](https://refactoring.guru/smells/divergent-change)

#### 5.2.4 Shotgun Surgery

- [Refactoring Guru](https://refactoring.guru/smells/shotgun-surgery)

#### 5.2.5 Parallel Inheritance Hierarchies

- [Refactoring Guru](https://refactoring.guru/smells/parallel-inheritance-hierarchies)

#### 5.2.6 Feature Envy

- [Refactoring Guru](https://refactoring.guru/smells/feature-envy)

#### 5.2.7 Message Chain

- [Refactoring Guru](https://refactoring.guru/smells/message-chains)

#### 5.2.8 Middle Man

- [Refactoring Guru](https://refactoring.guru/smells/middle-man)

#### 5.2.9 Inappropriate Intimacy

- [Refactoring Guru](https://refactoring.guru/smells/inappropriate-intimacy)

#### 5.2.10 Incomplete Library Class

- [Refactoring Guru](https://refactoring.guru/smells/incomplete-library-class)

#### 5.2.11 Alternative Classes with Different Interfaces

- [Refactoring Guru](https://refactoring.guru/smells/alternative-classes-with-different-interfaces)

#### 5.2.12 Refused Bequest

- [Refactoring Guru](https://refactoring.guru/smells/refused-bequest)

#### 5.2.13 Insider Trading

- [Fowler](https://martinfowler.com/bliki/CodeSmell.html)

### 5.3 Dispensable or speculative structure

#### 5.3.1 Speculative Generality

- [Refactoring Guru](https://refactoring.guru/smells/speculative-generality)

#### 5.3.2 Lazy Element

- [Fowler](https://martinfowler.com/bliki/CodeSmell.html)

#### 5.3.3 Repeated Type Conditional

- [Fowler](https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html)

#### 5.3.4 Complex Conditional

- [Fowler](https://refactoring.com/catalog/decomposeConditional.html)

#### 5.3.5 Flag Argument

- [Fowler](https://martinfowler.com/bliki/FlagArgument.html)

#### 5.3.6 Double Negative

- [Fowler](https://refactoring.com/catalog/removeDoubleNegative.html)

#### 5.3.7 Spaghetti Code

- [Brown et al., *AntiPatterns*](https://web.archive.org/web/20160304060927/http://www.antipatterns.com/briefing/sld023.htm)
