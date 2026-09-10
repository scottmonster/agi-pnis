# Prototype

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.4
- **Aliases:** None
- **Definition:** Create objects by copying a configured prototype. It can simplify creation where copying is the domain operation, while making copy semantics important.
- **Why it matters:** It makes object creation easier to read when new objects are mostly variations of a configured example, and it keeps copy rules in one place so later changes to nested state or defaults are less error-prone.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing service creates subscription invoices that all share the same currency, payment terms, and standard line items. Each customer invoice differs only by customer, issue date, and billing period.

### 2.2 Good form

```ts
type LineItem = {
  description: string;
  quantity: number;
  unitPriceCents: number;
};

type InvoiceMetadata = {
  template: string;
  billingPeriod?: string;
};

class InvoiceDraft {
  constructor(
    readonly customerId: string | null,
    readonly currency: string,
    readonly paymentTermsDays: number,
    readonly lineItems: LineItem[],
    readonly issueDate: Date,
    readonly metadata: InvoiceMetadata
  ) {}

  clone(changes: Partial<InvoiceDraft> = {}): InvoiceDraft {
    return new InvoiceDraft(
      changes.customerId ?? this.customerId,
      changes.currency ?? this.currency,
      changes.paymentTermsDays ?? this.paymentTermsDays,
      changes.lineItems
        ? changes.lineItems.map((item) => ({ ...item }))
        : this.lineItems.map((item) => ({ ...item })),
      changes.issueDate
        ? new Date(changes.issueDate)
        : new Date(this.issueDate),
      changes.metadata
        ? { ...changes.metadata }
        : { ...this.metadata }
    );
  }

  totalCents(): number {
    return this.lineItems.reduce(
      (sum, item) => sum + item.quantity * item.unitPriceCents,
      0
    );
  }
}

const subscriptionInvoicePrototype = new InvoiceDraft(
  null,
  "USD",
  30,
  [
    { description: "Platform subscription", quantity: 1, unitPriceCents: 5000 },
    { description: "Priority support", quantity: 1, unitPriceCents: 1500 }
  ],
  new Date("2026-01-01T00:00:00.000Z"),
  { template: "standard-subscription" }
);

function createInvoiceForCustomer(
  customerId: string,
  billingPeriod: string,
  issueDate: Date
): InvoiceDraft {
  return subscriptionInvoicePrototype.clone({
    customerId,
    issueDate,
    metadata: {
      ...subscriptionInvoicePrototype.metadata,
      billingPeriod
    }
  });
}

const invoice = createInvoiceForCustomer(
  "customer-42",
  "2026-01",
  new Date("2026-01-31T00:00:00.000Z")
);

console.log(invoice.currency);
console.log(invoice.totalCents());
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  description: string;
  quantity: number;
  unitPriceCents: number;
};

type InvoiceMetadata = {
  template: string;
  billingPeriod?: string;
};

class InvoiceDraft {
  constructor(
    readonly customerId: string | null,
    readonly currency: string,
    readonly paymentTermsDays: number,
    readonly lineItems: LineItem[],
    readonly issueDate: Date,
    readonly metadata: InvoiceMetadata
  ) {}

  totalCents(): number {
    return this.lineItems.reduce(
      (sum, item) => sum + item.quantity * item.unitPriceCents,
      0
    );
  }
}

function createInvoiceForCustomer(
  customerId: string,
  billingPeriod: string,
  issueDate: Date
): InvoiceDraft {
  return new InvoiceDraft(
    customerId,
    "USD",
    30,
    [
      { description: "Platform subscription", quantity: 1, unitPriceCents: 5000 },
      { description: "Priority support", quantity: 1, unitPriceCents: 1500 }
    ],
    new Date(issueDate),
    {
      template: "standard-subscription",
      billingPeriod
    }
  );
}

const invoice = createInvoiceForCustomer(
  "customer-42",
  "2026-01",
  new Date("2026-01-31T00:00:00.000Z")
);

console.log(invoice.currency);
console.log(invoice.totalCents());
```

### 2.4 Why this difference matters

The good form names the configured invoice as a prototype and creates customer-specific invoices by cloning it. The copy operation is explicit, so readers can see that new invoices are variants of the same configured object. The `clone` method also centralizes copy semantics for nested values such as line items, dates, and metadata, reducing the chance that one creation path accidentally shares mutable state or forgets a default.

The less maintainable form reconstructs the same configured invoice by hand inside the creation function. The behavior is the same, but the intended relationship to a standard invoice template is implicit, and future changes to the shared invoice shape must be repeated wherever similar invoices are manually assembled.

### 2.5 Structural references

```text
Good: createRenewalInvoice > subscriptionInvoicePrototype.clone
Less maintainable: createRenewalInvoice > new InvoiceDraft manual reconstruction
```

The structural difference is that the good form routes creation through a prototype object and its copy operation, while the less maintainable form places the configured defaults directly inside the construction site.

## 3. Boundaries and distinctions

Prototype is useful when new objects are naturally described as copies of a configured example, especially when the object has many defaults or nested values with important copy rules. It is less useful when construction is simple, when every object is substantially different, or when a direct constructor call is clearer.

The less maintainable form can be appropriate for a small object with one creation path and no meaningful template relationship. In that case, introducing a prototype may add indirection without improving understanding.

Prototype differs from a factory because the central idea is copying an existing configured object, not merely hiding construction behind a creation function. It differs from a builder because a builder assembles an object step by step, while a prototype starts from an already configured object and changes selected parts. Copy semantics are the main risk: shallow copying may accidentally share nested mutable state, while deep copying may be more expensive or may copy resources that should not be duplicated.
