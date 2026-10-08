# Introduce Special Case

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.2.6
- **Aliases:** introduce null object
- **Definition:** Represent an exceptional or common special case with an object that implements ordinary behavior, avoiding repeated checks. It makes the remaining main path simpler, provided the special behavior is genuinely coherent.
- **Why it matters:** It moves repeated exceptional-case decisions into one well-named object, so ordinary code can read as a single main path and future changes to the special behavior have one place to go.
- **Related concepts:** Null Object

## 2. Example

### 2.1 Scenario

A billing service creates invoice summaries for registered customers. If a customer id is unknown, the system should treat the invoice as a guest invoice with no discount and a fallback recipient.

### 2.2 Good form

```ts
type CustomerRow = {
  id: string;
  name: string;
  email: string;
  discountRate: number;
};

type InvoiceSummary = {
  recipient: string;
  subject: string;
  totalCents: number;
};

interface Customer {
  readonly displayName: string;
  readonly email: string;
  readonly discountRate: number;
}

class RegisteredCustomer implements Customer {
  constructor(private readonly row: CustomerRow) {}

  get displayName(): string {
    return this.row.name;
  }

  get email(): string {
    return this.row.email;
  }

  get discountRate(): number {
    return this.row.discountRate;
  }
}

class GuestCustomer implements Customer {
  get displayName(): string {
    return "Guest";
  }

  get email(): string {
    return "billing@example.com";
  }

  get discountRate(): number {
    return 0;
  }
}

const customerRows = new Map<string, CustomerRow>([
  [
    "cust-100",
    {
      id: "cust-100",
      name: "Avery Chen",
      email: "avery@example.com",
      discountRate: 0.1,
    },
  ],
]);

function customerFor(customerId: string): Customer {
  const row = customerRows.get(customerId);
  return row === undefined ? new GuestCustomer() : new RegisteredCustomer(row);
}

function createInvoiceSummary(customerId: string, subtotalCents: number): InvoiceSummary {
  const customer = customerFor(customerId);
  const totalCents = Math.round(subtotalCents * (1 - customer.discountRate));

  return {
    recipient: customer.email,
    subject: `Invoice for ${customer.displayName}`,
    totalCents,
  };
}

const invoice = createInvoiceSummary("missing-customer", 5000);
console.log(invoice);
```

### 2.3 Less maintainable form

```ts
type CustomerRow = {
  id: string;
  name: string;
  email: string;
  discountRate: number;
};

type InvoiceSummary = {
  recipient: string;
  subject: string;
  totalCents: number;
};

const customerRows = new Map<string, CustomerRow>([
  [
    "cust-100",
    {
      id: "cust-100",
      name: "Avery Chen",
      email: "avery@example.com",
      discountRate: 0.1,
    },
  ],
]);

function findCustomerRow(customerId: string): CustomerRow | null {
  return customerRows.get(customerId) ?? null;
}

function createInvoiceSummary(customerId: string, subtotalCents: number): InvoiceSummary {
  const customer = findCustomerRow(customerId);

  const recipient = customer === null ? "billing@example.com" : customer.email;
  const displayName = customer === null ? "Guest" : customer.name;
  const discountRate = customer === null ? 0 : customer.discountRate;
  const totalCents = Math.round(subtotalCents * (1 - discountRate));

  return {
    recipient,
    subject: `Invoice for ${displayName}`,
    totalCents,
  };
}

const invoice = createInvoiceSummary("missing-customer", 5000);
console.log(invoice);
```

### 2.4 Why this difference matters

In the good form, the unknown-customer case is represented by `GuestCustomer`, which implements the same `Customer` interface as a registered customer. `createInvoiceSummary` can therefore describe the billing calculation directly instead of repeatedly asking whether the customer is missing. If the fallback email, guest label, or guest discount changes, the change is localized to `GuestCustomer`.

In the less maintainable form, the same special case is spread across several conditional expressions. Each new customer-dependent field risks another `customer === null` check, and any future change to guest behavior must be found and updated everywhere those checks appear.

### 2.5 Structural references

```text
Good: billing-service > billing > invoice.ts > createInvoiceSummary > customer
Less maintainable: billing-service > billing > invoice.ts > createInvoiceSummary > customer === null checks
```

The relevant structural difference is that the good form places the special-case behavior behind the `Customer` target used by the main function, while the less maintainable form keeps the missing-customer condition inside the main function at each use site.

## 3. Boundaries and distinctions

Introduce Special Case applies when the exceptional value has coherent, stable behavior that can be expressed through the same interface as the ordinary value. It is a good fit for cases such as guest users, anonymous customers, empty permissions, or no-op notifications when the default behavior is meaningful.

It does not apply when absence itself is the important information, when callers must make different domain decisions for different missing reasons, or when hiding the special case would obscure an error. In those cases, an explicit `null`, `undefined`, `Result`, exception, or validation error may be clearer.

The less maintainable form can be appropriate near system boundaries, such as parsing an API response or database row, where the code is translating uncertain external data into internal domain objects. After that boundary, repeated checks become a maintenance smell if they all implement the same special behavior.

A Null Object is a common form of Introduce Special Case where the special object does little or nothing, such as a logger that discards messages. Introduce Special Case is broader: the special object may perform real default behavior, such as using a fallback billing recipient and a zero discount for a guest customer.
