# Inline Class

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.2
- **Aliases:** None
- **Definition:** Move a class's behavior and data into another class when it no longer represents a useful concept. It removes a needless hop.
- **Why it matters:** It improves readability and maintainability by removing an object that only forwards access to data or behavior. Readers can understand and change the owning concept without navigating through a class that no longer adds meaning.
- **Related concepts:** Lazy Element

## 2. Example

### 2.1 Scenario

An invoicing service prints a customer's billing address on invoices. The separate `BillingAddress` class used to contain validation rules, but now it only stores three fields and formats them once.

### 2.2 Good form

```ts
type Invoice = {
  id: string;
  totalCents: number;
};

class Customer {
  constructor(
    public readonly name: string,
    private readonly billingStreet: string,
    private readonly billingCity: string,
    private readonly billingPostalCode: string,
  ) {}

  formattedBillingAddress(): string {
    return `${this.billingStreet}, ${this.billingCity} ${this.billingPostalCode}`;
  }
}

function buildBillingSummary(customer: Customer, invoice: Invoice): string {
  return [
    `Invoice: ${invoice.id}`,
    `Customer: ${customer.name}`,
    `Billing address: ${customer.formattedBillingAddress()}`,
    `Total: $${(invoice.totalCents / 100).toFixed(2)}`,
  ].join("\n");
}

const customer = new Customer("Acme Supplies", "12 Market Street", "Denver", "80202");
const invoice = { id: "INV-1007", totalCents: 25900 };

console.log(buildBillingSummary(customer, invoice));
```

### 2.3 Less maintainable form

```ts
type Invoice = {
  id: string;
  totalCents: number;
};

class BillingAddress {
  constructor(
    private readonly street: string,
    private readonly city: string,
    private readonly postalCode: string,
  ) {}

  format(): string {
    return `${this.street}, ${this.city} ${this.postalCode}`;
  }
}

class Customer {
  constructor(
    public readonly name: string,
    private readonly billingAddress: BillingAddress,
  ) {}

  formattedBillingAddress(): string {
    return this.billingAddress.format();
  }
}

function buildBillingSummary(customer: Customer, invoice: Invoice): string {
  return [
    `Invoice: ${invoice.id}`,
    `Customer: ${customer.name}`,
    `Billing address: ${customer.formattedBillingAddress()}`,
    `Total: $${(invoice.totalCents / 100).toFixed(2)}`,
  ].join("\n");
}

const customer = new Customer(
  "Acme Supplies",
  new BillingAddress("12 Market Street", "Denver", "80202"),
);
const invoice = { id: "INV-1007", totalCents: 25900 };

console.log(buildBillingSummary(customer, invoice));
```

### 2.4 Why this difference matters

The good form inlines `BillingAddress` into `Customer` because the address class no longer represents a useful independent concept. It has no lifecycle, no shared behavior, and no separate policy. Keeping it forces readers to jump from `Customer.formattedBillingAddress()` to `BillingAddress.format()` just to see a simple string formatting operation. Inlining the fields and behavior places the billing-address detail where it is actually used and removes an unnecessary delegation step.

### 2.5 Structural references

```text
Good: invoicing-service > billing > invoiceSummary.ts > buildBillingSummary > Customer billing address fields
Less maintainable: invoicing-service > billing > invoiceSummary.ts > buildBillingSummary > BillingAddress wrapper
```

The relevant structural difference is that the good form keeps the address data and formatting behavior inside the owning `Customer` concept, while the less maintainable form introduces a separate `BillingAddress` target that adds an extra navigation hop without adding a distinct responsibility.

## 3. Boundaries and distinctions

Inline Class applies when a class has become too small or too passive to justify its existence. It is especially appropriate when the class only stores data for one owner, forwards calls, or contains behavior that is always used through another class.

The less maintainable form may be appropriate if `BillingAddress` is still a real domain concept. For example, it should remain separate if addresses are shared across customers, validated independently, persisted separately, reused by shipping and billing workflows, or expected to grow address-specific behavior such as normalization, geocoding, or country-specific formatting.

Inline Class is related to Lazy Element, but they are not identical. Lazy Element names the smell: a class, function, or other program element that does too little to justify itself. Inline Class is the refactoring used when that lazy element is specifically a class whose data and behavior should be moved into another class.
