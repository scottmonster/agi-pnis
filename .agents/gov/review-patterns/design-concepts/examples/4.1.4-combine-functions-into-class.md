# Combine Functions into Class

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.4
- **Aliases:** None
- **Definition:** Group functions that operate on the same shared data into a class. It exposes the data-behavior relationship and limits parameter repetition.
- **Why it matters:** It makes the shared data that the functions depend on explicit, reduces repeated parameters, and gives readers one place to look for behavior tied to that data.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing module calculates a subscription invoice subtotal, tax, total, and display summary from the same invoice data and tax rate. The intended behavior is the same in both examples.

### 2.2 Good form

```ts
type LineItem = {
  description: string;
  quantity: number;
  unitPrice: number;
};

type InvoiceData = {
  customerName: string;
  items: LineItem[];
};

class SubscriptionInvoice {
  constructor(
    private readonly data: InvoiceData,
    private readonly taxRate: number,
  ) {}

  subtotal(): number {
    return this.data.items.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0,
    );
  }

  tax(): number {
    return this.subtotal() * this.taxRate;
  }

  total(): number {
    return this.subtotal() + this.tax();
  }

  summary(): string {
    return `${this.data.customerName}: $${this.total().toFixed(2)}`;
  }
}

const invoiceData: InvoiceData = {
  customerName: "Northwind Traders",
  items: [
    { description: "Pro subscription", quantity: 1, unitPrice: 120 },
    { description: "Extra seats", quantity: 3, unitPrice: 15 },
  ],
};

const invoice = new SubscriptionInvoice(invoiceData, 0.08);
const summary = invoice.summary();
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  description: string;
  quantity: number;
  unitPrice: number;
};

type InvoiceData = {
  customerName: string;
  items: LineItem[];
};

function calculateSubtotal(data: InvoiceData): number {
  return data.items.reduce(
    (sum, item) => sum + item.quantity * item.unitPrice,
    0,
  );
}

function calculateTax(data: InvoiceData, taxRate: number): number {
  return calculateSubtotal(data) * taxRate;
}

function calculateTotal(data: InvoiceData, taxRate: number): number {
  return calculateSubtotal(data) + calculateTax(data, taxRate);
}

function formatInvoiceSummary(data: InvoiceData, taxRate: number): string {
  return `${data.customerName}: $${calculateTotal(data, taxRate).toFixed(2)}`;
}

const invoiceData: InvoiceData = {
  customerName: "Northwind Traders",
  items: [
    { description: "Pro subscription", quantity: 1, unitPrice: 120 },
    { description: "Extra seats", quantity: 3, unitPrice: 15 },
  ],
};

const summary = formatInvoiceSummary(invoiceData, 0.08);
```

### 2.4 Why this difference matters

The good form makes `InvoiceData` and `taxRate` the state of a single `SubscriptionInvoice` object, so each operation no longer has to repeat those parameters. This shows that subtotal, tax, total, and summary are a cohesive set of behaviors over the same data. When invoice behavior changes, the reader has one focused place to inspect and modify.

### 2.5 Structural references

```text
Good: SubscriptionInvoice > summary
Less maintainable: formatInvoiceSummary > invoiceData and taxRate parameters
```

The relevant structural difference is that the good form introduces a class as the owner of the shared invoice data and gathers the related functions under it. The less maintainable form leaves the same behavior as separate file-level functions, so the shared data relationship is only implied by repeated parameters.

## 3. Boundaries and distinctions

Combine Functions into Class applies when several functions repeatedly operate on the same data and form a coherent behavior group. It does not apply when the functions are unrelated, when they only share incidental primitive parameters, or when a stateless functional style is clearer for a small pipeline.

The less maintainable form can be appropriate for a single simple helper, a module of independent pure functions, or code where introducing an object would add ceremony without clarifying ownership. This refactoring differs from merely moving one function, because the key change is grouping several behaviors around shared data. It also differs from extracting a data class alone, because the goal is to colocate both the data and the behavior that depends on it.
