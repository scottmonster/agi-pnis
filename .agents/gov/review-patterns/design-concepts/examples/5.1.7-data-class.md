# Data Class

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.7
- **Aliases:** None
- **Definition:** An object exposes data with little behavior while other code performs its domain work. It may be appropriate as a DTO, but is a smell when it is an anemic domain object.
- **Why it matters:** Data classes scatter domain rules across callers, making the code harder to read and change because the data and the behavior that gives it meaning are separated.
- **Related concepts:** DTO, Feature Envy

## 2. Example

### 2.1 Scenario

An invoicing system records payments against an invoice and determines whether the invoice is paid. The intended behavior is that payments reduce the outstanding balance, but overpayment is rejected.

### 2.2 Good form

```ts
type Payment = {
  readonly amountCents: number;
  readonly paidAt: Date;
};

class Invoice {
  private readonly payments: Payment[] = [];

  constructor(
    public readonly id: string,
    private readonly totalCents: number
  ) {
    if (totalCents <= 0) {
      throw new Error("Invoice total must be positive.");
    }
  }

  addPayment(amountCents: number, paidAt: Date = new Date()): void {
    if (amountCents <= 0) {
      throw new Error("Payment amount must be positive.");
    }

    if (amountCents > this.balanceCents()) {
      throw new Error("Payment exceeds remaining balance.");
    }

    this.payments.push({ amountCents, paidAt });
  }

  balanceCents(): number {
    return this.totalCents - this.payments.reduce(
      (sum, payment) => sum + payment.amountCents,
      0
    );
  }

  isPaid(): boolean {
    return this.balanceCents() === 0;
  }
}

const invoice = new Invoice("inv-1001", 10_000);

invoice.addPayment(4_000, new Date("2024-04-01"));
invoice.addPayment(6_000, new Date("2024-04-03"));

console.log(invoice.isPaid());
```

### 2.3 Less maintainable form

```ts
type Payment = {
  amountCents: number;
  paidAt: Date;
};

type Invoice = {
  id: string;
  totalCents: number;
  payments: Payment[];
};

function addPayment(invoice: Invoice, amountCents: number, paidAt: Date = new Date()): void {
  if (amountCents <= 0) {
    throw new Error("Payment amount must be positive.");
  }

  if (amountCents > balanceCents(invoice)) {
    throw new Error("Payment exceeds remaining balance.");
  }

  invoice.payments.push({ amountCents, paidAt });
}

function balanceCents(invoice: Invoice): number {
  return invoice.totalCents - invoice.payments.reduce(
    (sum, payment) => sum + payment.amountCents,
    0
  );
}

function isPaid(invoice: Invoice): boolean {
  return balanceCents(invoice) === 0;
}

const invoice: Invoice = {
  id: "inv-1001",
  totalCents: 10_000,
  payments: []
};

addPayment(invoice, 4_000, new Date("2024-04-01"));
addPayment(invoice, 6_000, new Date("2024-04-03"));

console.log(isPaid(invoice));
```

### 2.4 Why this difference matters

In the good form, `Invoice` owns the rules that make its data meaningful: valid payment amounts, overpayment prevention, balance calculation, and paid status. A reader can understand invoice behavior by reading the invoice object itself.

In the less maintainable form, `Invoice` is only a bag of fields. The rules live in separate functions that take the invoice as an argument and inspect or mutate its internals. As more invoice behavior is added, callers can duplicate rules, bypass validation, or change fields directly, making the domain model harder to trust and maintain.

### 2.5 Structural references

```text
Good: invoicing > domain > invoice.ts > Invoice.addPayment > paidTotalCents update
Less maintainable: invoicing > domain > invoice.ts > addPayment > invoice.paidTotalCents and invoice.status writes
```

The relevant structural difference is that the good form places domain behavior with the invoice data, while the less maintainable form leaves the invoice as exposed data and moves the invoice rules into separate functions.

## 3. Boundaries and distinctions

A data-only object is not automatically a smell. It is often appropriate for a DTO that carries data across a process boundary, such as an HTTP request body, database row, or serialized message. In those cases, the object is intentionally simple and domain behavior belongs elsewhere.

The smell appears when the object represents a domain concept but does not protect its own invariants or provide the behavior expected of that concept. An invoice that allows any caller to mutate its payments without validation is an anemic domain object, not just a harmless data carrier.

Data Class differs from Feature Envy. Data Class focuses on an object that has data but little behavior. Feature Envy focuses on a function or method that uses another object more than its own object. They often appear together: external functions may envy the data class because they repeatedly inspect and manipulate its fields.
