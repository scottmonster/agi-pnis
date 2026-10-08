# Move Function / Move Field

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.3
- **Aliases:** move method
- **Definition:** Place behavior or data with the object that most naturally owns it. This reduces feature envy and makes responsibility discoverable.
- **Why it matters:** Readers can find behavior and data where they expect it, changes stay localized to the object that owns the rule, and callers do not need to know another object's internal details.
- **Related concepts:** Feature Envy

## 2. Example

### 2.1 Scenario

An invoicing flow calculates the total for a customer's order. The customer billing profile owns the tax rate, so the tax calculation belongs with that profile rather than in the invoice assembly code.

### 2.2 Good form

```ts
type LineItem = {
  description: string;
  quantity: number;
  unitPriceCents: number;
};

class BillingProfile {
  constructor(
    public readonly customerId: string,
    private readonly taxRate: number,
  ) {}

  taxFor(subtotalCents: number): number {
    return Math.round(subtotalCents * this.taxRate);
  }
}

class Invoice {
  constructor(
    public readonly customerId: string,
    public readonly subtotalCents: number,
    public readonly taxCents: number,
  ) {}

  totalCents(): number {
    return this.subtotalCents + this.taxCents;
  }
}

function subtotalCents(items: LineItem[]): number {
  return items.reduce(
    (total, item) => total + item.quantity * item.unitPriceCents,
    0,
  );
}

function createInvoice(profile: BillingProfile, items: LineItem[]): Invoice {
  const subtotal = subtotalCents(items);
  const tax = profile.taxFor(subtotal);

  return new Invoice(profile.customerId, subtotal, tax);
}

const profile = new BillingProfile("customer-123", 0.0825);
const invoice = createInvoice(profile, [
  { description: "Notebook", quantity: 2, unitPriceCents: 1200 },
  { description: "Pen", quantity: 5, unitPriceCents: 250 },
]);

console.log(invoice.totalCents());
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  description: string;
  quantity: number;
  unitPriceCents: number;
};

class BillingProfile {
  constructor(public readonly customerId: string) {}
}

class Invoice {
  constructor(
    public readonly customerId: string,
    public readonly subtotalCents: number,
    public readonly taxCents: number,
  ) {}

  totalCents(): number {
    return this.subtotalCents + this.taxCents;
  }
}

const taxRatesByCustomerId: Record<string, number> = {
  "customer-123": 0.0825,
};

function subtotalCents(items: LineItem[]): number {
  return items.reduce(
    (total, item) => total + item.quantity * item.unitPriceCents,
    0,
  );
}

function taxForCustomer(customerId: string, subtotalCents: number): number {
  const taxRate = taxRatesByCustomerId[customerId] ?? 0;
  return Math.round(subtotalCents * taxRate);
}

function createInvoice(profile: BillingProfile, items: LineItem[]): Invoice {
  const subtotal = subtotalCents(items);
  const tax = taxForCustomer(profile.customerId, subtotal);

  return new Invoice(profile.customerId, subtotal, tax);
}

const profile = new BillingProfile("customer-123");
const invoice = createInvoice(profile, [
  { description: "Notebook", quantity: 2, unitPriceCents: 1200 },
  { description: "Pen", quantity: 5, unitPriceCents: 250 },
]);

console.log(invoice.totalCents());
```

### 2.4 Why this difference matters

In the good form, both the tax rate field and the tax calculation function live on `BillingProfile`, the object that owns customer-specific billing rules. `createInvoice` only coordinates invoice creation; it does not need to know how tax is stored or computed.

In the less maintainable form, the tax rate is stored separately from the billing profile and the calculation function reaches across that boundary using `customerId`. That creates feature envy: invoice code must understand billing-profile data indirectly. If tax rules change, maintainers must search outside the owning object and keep the external map, lookup key, and calculation function synchronized.

### 2.5 Structural references

```text
Good: billing > invoice.ts > BillingProfile > taxFor > taxRate
Less maintainable: billing > invoice.ts > taxForCustomer > taxRatesByCustomerId
```

The relevant structural difference is that the good form places the field and behavior inside `BillingProfile`, while the less maintainable form leaves both in file-level structures used by invoice creation.

## 3. Boundaries and distinctions

Move Function / Move Field applies when a function or field mostly serves another object, repeatedly reads another object's data, or makes callers understand details that should be owned elsewhere.

It does not apply when the behavior is intentionally cross-cutting, such as logging, metrics, formatting for a specific output adapter, or orchestration that genuinely coordinates several objects without favoring one owner. The less maintainable form can also be appropriate as a temporary integration layer when data is not yet modeled in the domain object, or when an external service is the real source of truth.

This refactoring is closely related to Feature Envy. Feature Envy describes the smell: code is more interested in another object's data than its own. Move Function / Move Field is one common remedy: move the envying behavior or misplaced data to the object it naturally belongs to.
