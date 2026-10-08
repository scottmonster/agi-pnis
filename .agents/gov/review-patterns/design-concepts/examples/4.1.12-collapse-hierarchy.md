# Collapse Hierarchy

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.12
- **Aliases:** None
- **Definition:** Merge a superclass and subclass that no longer differ meaningfully. It removes inheritance ceremony without a behavioral distinction.
- **Why it matters:** It reduces the number of types a reader must understand, removes needless indirection, and makes future changes easier because shared behavior has only one obvious home.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing service creates renewal invoices for subscriptions. A former distinction between general invoices and renewal invoices has disappeared, so both now have identical behavior.

### 2.2 Good form

```ts
type LineItem = {
  description: string;
  amountCents: number;
};

class Invoice {
  constructor(
    private readonly customerId: string,
    private readonly lineItems: LineItem[],
  ) {}

  totalCents(): number {
    return this.lineItems.reduce((sum, item) => sum + item.amountCents, 0);
  }

  summary(): string {
    return `Invoice for ${this.customerId}: $${(this.totalCents() / 100).toFixed(2)}`;
  }
}

function createRenewalInvoice(customerId: string, monthlyPriceCents: number): Invoice {
  return new Invoice(customerId, [
    { description: "Monthly subscription renewal", amountCents: monthlyPriceCents },
  ]);
}

const invoice = createRenewalInvoice("cust-42", 2900);
console.log(invoice.summary());
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  description: string;
  amountCents: number;
};

class BaseInvoice {
  constructor(
    private readonly customerId: string,
    private readonly lineItems: LineItem[],
  ) {}

  totalCents(): number {
    return this.lineItems.reduce((sum, item) => sum + item.amountCents, 0);
  }

  summary(): string {
    return `Invoice for ${this.customerId}: $${(this.totalCents() / 100).toFixed(2)}`;
  }
}

class RenewalInvoice extends BaseInvoice {
}

function createRenewalInvoice(customerId: string, monthlyPriceCents: number): RenewalInvoice {
  return new RenewalInvoice(customerId, [
    { description: "Monthly subscription renewal", amountCents: monthlyPriceCents },
  ]);
}

const invoice = createRenewalInvoice("cust-42", 2900);
console.log(invoice.summary());
```

### 2.4 Why this difference matters

In the good form, the invoice behavior is represented by one type. A reader does not have to inspect both `BaseInvoice` and `RenewalInvoice` to discover that the subclass adds nothing. If the invoice calculation or summary format changes, there is only one meaningful place to edit and one type name to use in signatures.

In the less maintainable form, inheritance suggests that `RenewalInvoice` has a behavioral distinction from `BaseInvoice`, but it does not. That false signal makes the design harder to understand and invites future changes to preserve an unnecessary hierarchy.

### 2.5 Structural references

```text
Good: billing-service > billing > invoice.ts > createRenewalInvoice > Invoice
Less maintainable: billing-service > billing > invoice.ts > createRenewalInvoice > RenewalInvoice
```

The relevant structural difference is that the good form has one concrete invoice target, while the less maintainable form routes construction through a subclass that only inherits from a superclass without adding behavior.

## 3. Boundaries and distinctions

Collapse Hierarchy applies when a superclass and subclass no longer have a meaningful behavioral, data, or conceptual difference. It does not apply when the subclass has distinct rules, overrides, invariants, lifecycle behavior, or a clearly useful domain meaning.

The less maintainable form can be appropriate temporarily if a public API must preserve the subclass name for compatibility, if a framework requires a subclass, or if an imminent feature will add real subclass-specific behavior. In those cases, the hierarchy has an external or near-term reason to exist.

This refactoring is not about removing all inheritance. It is specifically about removing inheritance where the levels have become redundant. If multiple subclasses still vary behavior behind a common interface, the hierarchy may remain useful.
