# Change Reference to Value

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.7
- **Aliases:** None
- **Definition:** Make an object a freely copied value when shared identity is unnecessary. It reduces aliasing and the mental cost of tracking shared mutable state.
- **Why it matters:** Code is easier to read and change when small domain objects can be passed, copied, and compared without wondering who else may observe a mutation through the same reference.
- **Related concepts:** Value Object

## 2. Example

### 2.1 Scenario

A billing service creates two invoices from the same quoted total. Later, support corrects one invoice total while the other invoice must remain unchanged.

### 2.2 Good form

```ts
type Currency = "USD" | "EUR";

class Money {
  public readonly cents: number;
  public readonly currency: Currency;

  public constructor(cents: number, currency: Currency) {
    if (!Number.isInteger(cents)) {
      throw new Error("Money must be stored in whole cents.");
    }

    this.cents = cents;
    this.currency = currency;
  }

  public withCents(cents: number): Money {
    return new Money(cents, this.currency);
  }

  public equals(other: Money): boolean {
    return this.cents === other.cents && this.currency === other.currency;
  }

  public format(): string {
    return `${this.currency} ${(this.cents / 100).toFixed(2)}`;
  }
}

type Invoice = Readonly<{
  id: string;
  total: Money;
}>;

function issueTwoInvoices(quotedTotal: Money): readonly [Invoice, Invoice] {
  return [
    { id: "INV-100", total: quotedTotal },
    { id: "INV-101", total: quotedTotal },
  ];
}

function correctInvoiceTotal(invoice: Invoice, correctedTotal: Money): Invoice {
  return { ...invoice, total: correctedTotal };
}

const quotedTotal = new Money(10_000, "USD");
const [firstInvoice, secondInvoice] = issueTwoInvoices(quotedTotal);

const correctedFirstInvoice = correctInvoiceTotal(
  firstInvoice,
  firstInvoice.total.withCents(9_500),
);

const invoiceSummaries = [
  correctedFirstInvoice.total.format(),
  secondInvoice.total.format(),
];
```

### 2.3 Less maintainable form

```ts
type Currency = "USD" | "EUR";

class MutableMoney {
  private cents: number;
  public readonly currency: Currency;

  public constructor(cents: number, currency: Currency) {
    if (!Number.isInteger(cents)) {
      throw new Error("Money must be stored in whole cents.");
    }

    this.cents = cents;
    this.currency = currency;
  }

  public setCents(cents: number): void {
    if (!Number.isInteger(cents)) {
      throw new Error("Money must be stored in whole cents.");
    }

    this.cents = cents;
  }

  public copy(): MutableMoney {
    return new MutableMoney(this.cents, this.currency);
  }

  public format(): string {
    return `${this.currency} ${(this.cents / 100).toFixed(2)}`;
  }
}

type Invoice = {
  id: string;
  total: MutableMoney;
};

function issueTwoInvoices(quotedTotal: MutableMoney): [Invoice, Invoice] {
  return [
    { id: "INV-100", total: quotedTotal.copy() },
    { id: "INV-101", total: quotedTotal.copy() },
  ];
}

function correctInvoiceTotal(invoice: Invoice, correctedCents: number): Invoice {
  invoice.total.setCents(correctedCents);
  return invoice;
}

const quotedTotal = new MutableMoney(10_000, "USD");
const [firstInvoice, secondInvoice] = issueTwoInvoices(quotedTotal);

const correctedFirstInvoice = correctInvoiceTotal(firstInvoice, 9_500);

const invoiceSummaries = [
  correctedFirstInvoice.total.format(),
  secondInvoice.total.format(),
];
```

### 2.4 Why this difference matters

In the good form, `Money` has value semantics: it is immutable, comparable by its fields, and replacement creates a new value. Sharing the same `Money` instance between invoices is harmless because no caller can change it through an alias.

In the less maintainable form, `MutableMoney` is a reference with hidden update behavior. The code must remember to call `copy()` when assigning totals to invoices. The intended behavior is preserved, but correctness depends on defensive copying discipline instead of the type itself expressing that invoice totals are independent values.

### 2.5 Structural references

```text
Good: billing-service > billing > invoiceTotals.ts > correctInvoiceTotal > Money value
Less maintainable: billing-service > billing > invoiceTotals.ts > correctInvoiceTotal > MutableMoney reference
```

The relevant structural difference is the target of the invoice total: the good form replaces an immutable value, while the less maintainable form mutates a referenced object and relies on earlier defensive copies to avoid aliasing.

## 3. Boundaries and distinctions

Change Reference to Value applies when an object has no meaningful identity beyond its fields, such as money amounts, dates, quantities, coordinates, names, or small configuration records.

It does not apply when identity is part of the domain. For example, a customer, account, order, session, or database entity may need stable identity even if some of its fields are equal to another object's fields. A shared mutable reference can also be appropriate for intentionally shared state, such as a cache, connection pool, live document model, or aggregate root managed by a repository.

A Value Object is the resulting design style: equality and meaning come from values rather than identity. Change Reference to Value is the refactoring move that changes code from identity-oriented references toward that value-object style.
