# Lazy Element

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.3.2
- **Aliases:** None
- **Definition:** A class, method, or other element no longer does enough to justify its existence. It adds a name and navigation step without a real responsibility.
- **Why it matters:** Lazy elements make readers jump through extra names, files, or call layers to understand behavior that could be expressed directly. They increase navigation cost and maintenance surface without adding abstraction, reuse, validation, or domain meaning.
- **Related concepts:** Inline Class, Inline Function

## 2. Example

### 2.1 Scenario

An order service builds an invoice summary from line items and applies a fixed sales tax rate. The tax calculation is used only at this point and has no additional policy, state, or variation.

### 2.2 Good form

```ts
type LineItem = {
  description: string;
  quantity: number;
  unitPriceCents: number;
};

type InvoiceSummary = {
  subtotalCents: number;
  taxCents: number;
  totalCents: number;
};

const SALES_TAX_RATE = 0.0825;

function createInvoiceSummary(items: LineItem[]): InvoiceSummary {
  const subtotalCents = items.reduce(
    (sum, item) => sum + item.quantity * item.unitPriceCents,
    0
  );

  const taxCents = Math.round(subtotalCents * SALES_TAX_RATE);

  return {
    subtotalCents,
    taxCents,
    totalCents: subtotalCents + taxCents,
  };
}

const invoice = createInvoiceSummary([
  { description: "Notebook", quantity: 2, unitPriceCents: 500 },
  { description: "Pen", quantity: 3, unitPriceCents: 150 },
]);

console.log(invoice);
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  description: string;
  quantity: number;
  unitPriceCents: number;
};

type InvoiceSummary = {
  subtotalCents: number;
  taxCents: number;
  totalCents: number;
};

const SALES_TAX_RATE = 0.0825;

class SalesTaxAmount {
  constructor(private readonly subtotalCents: number) {}

  value(): number {
    return Math.round(this.subtotalCents * SALES_TAX_RATE);
  }
}

function createInvoiceSummary(items: LineItem[]): InvoiceSummary {
  const subtotalCents = items.reduce(
    (sum, item) => sum + item.quantity * item.unitPriceCents,
    0
  );

  const taxCents = new SalesTaxAmount(subtotalCents).value();

  return {
    subtotalCents,
    taxCents,
    totalCents: subtotalCents + taxCents,
  };
}

const invoice = createInvoiceSummary([
  { description: "Notebook", quantity: 2, unitPriceCents: 500 },
  { description: "Pen", quantity: 3, unitPriceCents: 150 },
]);

console.log(invoice);
```

### 2.4 Why this difference matters

The good form keeps the small, local calculation where the reader already has the needed context. The less maintainable form introduces `SalesTaxAmount`, but that class only stores one number and exposes a one-line method. It does not own a rule, protect an invariant, support substitution, or remove duplication. Understanding the invoice total now requires an extra object and method lookup for behavior that is still just the same local expression.

### 2.5 Structural references

```text
Good: invoiceTotal > inline tax calculation
Less maintainable: SalesTaxAmount.value > pass-through wrapper
```

The relevant structural difference is the extra class and method in the less maintainable form. They add a navigation step between `createInvoiceSummary` and the tax calculation without adding a distinct responsibility.

## 3. Boundaries and distinctions

Lazy Element does not apply just because an element is small. A small function, class, type, or module can be justified when it gives an important domain concept a stable name, centralizes duplicated behavior, protects invariants, provides a public API boundary, enables polymorphism, isolates external dependencies, or makes a rule independently changeable.

The less maintainable form may be appropriate if the tax behavior is about to gain real policy variation, such as jurisdiction-specific rates, exemptions, rounding rules, or audit metadata. It may also be reasonable when preserving a public interface during a migration.

Lazy Element is the smell. Inline Class and Inline Function are common refactorings used to remove it. Inlining is not automatically better in every case. It is appropriate when the element has become a pass-through, wrapper, or tiny holder with no useful responsibility of its own.
