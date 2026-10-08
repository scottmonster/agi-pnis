# Double Negative

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.3.6
- **Aliases:** None
- **Definition:** A negated concept is negated again, such as `!isNotReady`. The reader must mentally invert the condition twice.
- **Why it matters:** Double negatives make boolean logic slower to read and easier to misinterpret, especially in conditions that control important behavior. Positive names and direct conditions reduce mental translation and make later changes safer.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout service sends a receipt only when the payment processor is ready. The readiness check depends on both the processor status and whether a health check has completed.

### 2.2 Good form

```ts
type ProcessorStatus = "ready" | "starting" | "offline";

interface PaymentProcessor {
  status: ProcessorStatus;
  lastHealthCheckAt: Date | null;
}

function isReady(processor: PaymentProcessor): boolean {
  return processor.status === "ready" && processor.lastHealthCheckAt !== null;
}

function shouldSendReceipt(processor: PaymentProcessor): boolean {
  return isReady(processor);
}
```

### 2.3 Less maintainable form

```ts
type ProcessorStatus = "ready" | "starting" | "offline";

interface PaymentProcessor {
  status: ProcessorStatus;
  lastHealthCheckAt: Date | null;
}

function isNotReady(processor: PaymentProcessor): boolean {
  return processor.status !== "ready" || processor.lastHealthCheckAt === null;
}

function shouldSendReceipt(processor: PaymentProcessor): boolean {
  return !isNotReady(processor);
}
```

### 2.4 Why this difference matters

The good form asks one positive question: `isReady(processor)`. The less maintainable form asks a negative question and then negates the answer: `!isNotReady(processor)`. That forces the reader to translate "not not ready" into "ready" before understanding the behavior. When the condition is later extended, the negative form also makes it easier to introduce mistakes while preserving or reversing the logic.

### 2.5 Structural references

```text
Good: canIssueReceipt > isReady predicate
Less maintainable: canIssueReceipt > !payment.isNotReady expression
```

The relevant structural difference is the predicate used by `shouldSendReceipt`: the good form calls a positive readiness predicate directly, while the less maintainable form negates a predicate that is already expressed negatively.

## 3. Boundaries and distinctions

Double Negative applies when a negative concept is negated again, such as `!isNotReady`, `!hasNoItems`, or `notDisabled === false`. It does not apply to every use of `!`; negating a positive predicate like `!isReady` can be clear when the branch really handles the not-ready case.

The less maintainable form may be acceptable at a boundary where an external API already exposes a negative property and renaming is not practical. Even then, it is often better to translate once at the boundary into a positive local name.

This smell is specifically about double inversion in boolean meaning. It is not the same as general boolean simplification, although simplifying a condition may remove it. It is also not merely a naming preference: the problem is the combination of a negative name or concept with another negation that the reader must mentally undo.
