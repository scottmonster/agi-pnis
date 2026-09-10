# Temporary Field

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.10
- **Aliases:** None
- **Definition:** An instance field is meaningful only in certain paths or phases. It makes the object's normal invariant unclear.
- **Why it matters:** Temporary fields make readers ask whether the field is always valid, only valid after a specific method call, or left over from a previous operation. This weakens the object's invariant, makes reuse riskier, and spreads one calculation's local state across the whole object.
- **Related concepts:** Replace Function with Command

## 2. Example

### 2.1 Scenario

A billing service calculates invoice totals from line items, applying a volume discount and then tax. The intermediate values are needed only while calculating one invoice.

### 2.2 Good form

```ts
type LineItem = {
  description: string;
  quantity: number;
  unitPrice: number;
};

type InvoiceTotals = {
  subtotal: number;
  discount: number;
  tax: number;
  total: number;
};

function roundMoney(amount: number): number {
  return Math.round(amount * 100) / 100;
}

export function calculateInvoiceTotals(
  items: LineItem[],
  taxRate: number
): InvoiceTotals {
  const subtotal = items.reduce(
    (sum, item) => sum + item.quantity * item.unitPrice,
    0
  );

  const discount = subtotal >= 1000 ? roundMoney(subtotal * 0.1) : 0;
  const taxableSubtotal = subtotal - discount;
  const tax = roundMoney(taxableSubtotal * taxRate);
  const total = roundMoney(taxableSubtotal + tax);

  return {
    subtotal: roundMoney(subtotal),
    discount,
    tax,
    total
  };
}
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  description: string;
  quantity: number;
  unitPrice: number;
};

type InvoiceTotals = {
  subtotal: number;
  discount: number;
  tax: number;
  total: number;
};

function roundMoney(amount: number): number {
  return Math.round(amount * 100) / 100;
}

export class InvoiceCalculator {
  private subtotal = 0;
  private discount = 0;
  private taxableSubtotal = 0;
  private tax = 0;

  calculate(items: LineItem[], taxRate: number): InvoiceTotals {
    this.computeSubtotal(items);
    this.computeDiscount();
    this.computeTaxableSubtotal();
    this.computeTax(taxRate);

    return {
      subtotal: roundMoney(this.subtotal),
      discount: this.discount,
      tax: this.tax,
      total: roundMoney(this.taxableSubtotal + this.tax)
    };
  }

  private computeSubtotal(items: LineItem[]): void {
    this.subtotal = items.reduce(
      (sum, item) => sum + item.quantity * item.unitPrice,
      0
    );
  }

  private computeDiscount(): void {
    this.discount = this.subtotal >= 1000 ? roundMoney(this.subtotal * 0.1) : 0;
  }

  private computeTaxableSubtotal(): void {
    this.taxableSubtotal = this.subtotal - this.discount;
  }

  private computeTax(taxRate: number): void {
    this.tax = roundMoney(this.taxableSubtotal * taxRate);
  }
}
```

### 2.4 Why this difference matters

In the good form, the intermediate calculation values are local variables. Their lifetime and meaning are limited to one invoice calculation, so a reader can see that `subtotal`, `discount`, `taxableSubtotal`, and `tax` are not part of any lasting object state.

In the less maintainable form, those same intermediate values are instance fields. Outside the narrow execution path of `calculate`, the fields have no independent meaning. They may contain default zeroes before calculation or values from the last calculation afterward. This makes the object's invariant unclear and forces maintainers to reason about call order and reuse instead of just the invoice calculation.

### 2.5 Structural references

```text
Good: generateMonthlyUsageReport > usageByAccount local state
Less maintainable: MonthlyUsageReporter > usageByAccount and currentMonth fields
```

The relevant structural difference is where the calculation state lives. The good form keeps phase-specific values inside the function that needs them, while the less maintainable form promotes those values to instance fields even though they are meaningful only during one method's execution.

## 3. Boundaries and distinctions

Temporary Field does not apply to fields that are stable parts of an object's state, such as configuration, identity, accumulated domain state, or cached values with a clear invalidation rule. A field is not temporary merely because its value changes.

The less maintainable form can be appropriate when the object itself represents one calculation run, such as a short-lived command object created per invoice. In that case, intermediate fields can be valid for the lifetime of that command object, especially if construction and execution make the lifecycle explicit.

Temporary Field is related to **Replace Function with Command** because a complex function can sometimes be turned into a dedicated command object whose fields hold intermediate calculation state. The key distinction is intent and lifetime: temporary fields on a long-lived domain or service object obscure the object's invariant, while fields on a short-lived command can describe the state of one operation.
