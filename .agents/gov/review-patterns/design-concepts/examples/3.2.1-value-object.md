# Value Object

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 3.2.1
- **Aliases:** None
- **Definition:** Model a conceptual value by its attributes rather than a stable identity, ordinarily with value equality and safe copying/immutability. It makes equality and mutation expectations legible.
- **Why it matters:** A value object makes it clear which attributes define sameness and prevents accidental shared mutation, so readers can reason about comparisons, copying, and changes without tracking object identity.
- **Related concepts:** Change Reference to Value

## 2. Example

### 2.1 Scenario

A checkout service totals line items and verifies that the amount about to be captured matches the amount previously authorized. Two amounts should be considered the same when their cents and currency match, not when they are the same object instance.

### 2.2 Good form

```ts
type Currency = "USD" | "EUR";

class Money {
  private constructor(
    public readonly cents: number,
    public readonly currency: Currency,
  ) {}

  static of(cents: number, currency: Currency): Money {
    if (!Number.isInteger(cents)) {
      throw new Error("Money must be stored as whole cents.");
    }

    return new Money(cents, currency);
  }

  add(other: Money): Money {
    this.requireSameCurrency(other);
    return Money.of(this.cents + other.cents, this.currency);
  }

  equals(other: Money): boolean {
    return this.cents === other.cents && this.currency === other.currency;
  }

  private requireSameCurrency(other: Money): void {
    if (this.currency !== other.currency) {
      throw new Error(`Cannot combine ${this.currency} with ${other.currency}.`);
    }
  }
}

type LineItem = {
  sku: string;
  quantity: number;
  unitPrice: Money;
};

function totalFor(items: LineItem[], currency: Currency): Money {
  return items.reduce(
    (sum, item) => sum.add(Money.of(item.unitPrice.cents * item.quantity, item.unitPrice.currency)),
    Money.of(0, currency),
  );
}

function canCapture(items: LineItem[], authorizedAmount: Money): boolean {
  const currentTotal = totalFor(items, authorizedAmount.currency);
  return currentTotal.equals(authorizedAmount);
}

const items: LineItem[] = [
  { sku: "notebook", quantity: 2, unitPrice: Money.of(500, "USD") },
  { sku: "pen", quantity: 3, unitPrice: Money.of(150, "USD") },
];

const authorizedAmount = Money.of(1450, "USD");

console.log(canCapture(items, authorizedAmount));
```

### 2.3 Less maintainable form

```ts
type Currency = "USD" | "EUR";

type AmountRecord = {
  id: string;
  cents: number;
  currency: Currency;
};

let nextAmountId = 1;

function createAmount(cents: number, currency: Currency): AmountRecord {
  if (!Number.isInteger(cents)) {
    throw new Error("Money must be stored as whole cents.");
  }

  return {
    id: `amount-${nextAmountId++}`,
    cents,
    currency,
  };
}

function addAmount(left: AmountRecord, right: AmountRecord): AmountRecord {
  if (left.currency !== right.currency) {
    throw new Error(`Cannot combine ${left.currency} with ${right.currency}.`);
  }

  return createAmount(left.cents + right.cents, left.currency);
}

function sameAmount(left: AmountRecord, right: AmountRecord): boolean {
  return left.cents === right.cents && left.currency === right.currency;
}

type LineItem = {
  sku: string;
  quantity: number;
  unitPrice: AmountRecord;
};

function totalFor(items: LineItem[], currency: Currency): AmountRecord {
  return items.reduce(
    (sum, item) => addAmount(sum, createAmount(item.unitPrice.cents * item.quantity, item.unitPrice.currency)),
    createAmount(0, currency),
  );
}

function canCapture(items: LineItem[], authorizedAmount: AmountRecord): boolean {
  const currentTotal = totalFor(items, authorizedAmount.currency);
  return sameAmount(currentTotal, authorizedAmount);
}

const items: LineItem[] = [
  { sku: "notebook", quantity: 2, unitPrice: createAmount(500, "USD") },
  { sku: "pen", quantity: 3, unitPrice: createAmount(150, "USD") },
];

const authorizedAmount = createAmount(1450, "USD");

console.log(canCapture(items, authorizedAmount));
```

### 2.4 Why this difference matters

In the good form, `Money` states that an amount is defined by `cents` and `currency`. Equality is part of the type, the fields are read-only, and arithmetic returns a new value. A reader does not need to wonder whether the generated object reference, allocation site, or mutation history affects sameness.

In the less maintainable form, `AmountRecord` carries an `id` even though the domain concept is an amount, not an entity. Callers must remember to ignore `id`, use `sameAmount`, and avoid mutating public fields. The intended value semantics are still implemented, but they are scattered across helpers and conventions instead of being made explicit by the type.

### 2.5 Structural references

```text
Good: checkout > pricing > money.ts > Money.equals > cents-and-currency comparison
Less maintainable: checkout > pricing > amount-record.ts > sameAmount > manual field comparison
```

The structural difference is that the good form localizes value equality and safe copying on the value type itself. The less maintainable form leaves the same comparison as an external helper for a mutable record that also exposes an irrelevant identity field.

## 3. Boundaries and distinctions

Use a value object when the domain concept is interchangeable with another instance that has the same attributes, such as money, date ranges, coordinates, measurements, or addresses in many contexts.

Do not use this pattern for concepts with stable identity across attribute changes. A customer, order, account, or database row is usually an entity because it remains the same thing even when its attributes change.

The less maintainable form can be appropriate at system boundaries, such as DTOs, ORM records, JSON payloads, or temporary data structures where identity, serialization shape, or framework requirements matter more than domain behavior. It can also be acceptable for small local calculations where mutation is tightly contained and not exposed.

A Value Object differs from Change Reference to Value: Value Object is the modeling style, while Change Reference to Value is a refactoring that replaces shared, identity-oriented references with value-based objects when identity is not needed.
