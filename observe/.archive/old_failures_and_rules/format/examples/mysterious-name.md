# Mysterious Name

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.1
- **Aliases:** None
- **Definition:** A name does not reveal its purpose, value, or role. It forces interpretation at every use; renaming is the usual first correction.
- **Why it matters:** Mysterious names make readers repeatedly infer meaning from implementation details instead of understanding intent from the name itself. This slows review, increases the chance of incorrect changes, and makes related logic harder to find.
- **Related concepts:** Rename Variable

## 2. Example

### 2.1 Scenario

A checkout service calculates an invoice total from line items, applying a loyalty discount before domestic sales tax. The behavior is identical in both examples.

### 2.2 Good form

```ts
type InvoiceLine = {
  unitPriceCents: number;
  quantity: number;
};

type Customer = {
  loyaltyTier: "standard" | "gold";
  shippingRegion: "domestic" | "international";
};

function getLoyaltyDiscountRate(customer: Customer): number {
  return customer.loyaltyTier === "gold" ? 0.1 : 0;
}

function getSalesTaxRate(customer: Customer): number {
  return customer.shippingRegion === "domestic" ? 0.0825 : 0;
}

export function calculateInvoiceTotalCents(
  invoiceLines: InvoiceLine[],
  customer: Customer
): number {
  const subtotalCents = invoiceLines.reduce(
    (totalCents, invoiceLine) =>
      totalCents + invoiceLine.unitPriceCents * invoiceLine.quantity,
    0
  );

  const loyaltyDiscountRate = getLoyaltyDiscountRate(customer);
  const discountedSubtotalCents = Math.round(
    subtotalCents * (1 - loyaltyDiscountRate)
  );

  const salesTaxRate = getSalesTaxRate(customer);
  const salesTaxCents = Math.round(discountedSubtotalCents * salesTaxRate);

  return discountedSubtotalCents + salesTaxCents;
}
```

### 2.3 Less maintainable form

```ts
type L = {
  p: number;
  q: number;
};

type C = {
  t: "standard" | "gold";
  r: "domestic" | "international";
};

function f(c: C): number {
  return c.t === "gold" ? 0.1 : 0;
}

function g(c: C): number {
  return c.r === "domestic" ? 0.0825 : 0;
}

export function calc(xs: L[], c: C): number {
  const a = xs.reduce((z, x) => z + x.p * x.q, 0);

  const b = f(c);
  const d = Math.round(a * (1 - b));

  const e = g(c);
  const h = Math.round(d * e);

  return d + h;
}
```

### 2.4 Why this difference matters

The good form names the business concepts directly: invoice lines, unit prices, quantities, loyalty discount rate, discounted subtotal, sales tax, and invoice total. A reader can understand the calculation at each use site without mentally mapping symbols like `a`, `b`, `d`, `f`, and `g` back to hidden meanings.

The less maintainable form preserves behavior, but every name requires interpretation from surrounding arithmetic. That makes later changes riskier, such as changing the tax rule, adjusting discount order, or investigating a rounding issue.

### 2.5 Structural references

```text
Good: checkout > pricing > invoice-total.ts > calculateInvoiceTotalCents > loyaltyDiscountRate
Less maintainable: checkout > pricing > invoice-total.ts > calc > b
```

The structural difference is the name of the same target role. In the good form, the variable name states that it is the loyalty discount rate. In the less maintainable form, `b` gives no clue about its purpose, so the reader must inspect assignments and uses to recover meaning.

## 3. Boundaries and distinctions

Mysterious Name does not apply when a short name is conventional and clear in context, such as `i` for a tiny loop index, `x` and `y` for coordinates, or well-known domain abbreviations used consistently by the team. It can also be acceptable in generated code, protocol bindings, or compatibility layers where names must match an external schema.

The less maintainable form may be appropriate only when the name is constrained by an external interface or when the scope is so small and conventional that a longer name would not add clarity.

Mysterious Name is the smell. Rename Variable is a refactoring commonly used to correct it. The smell identifies that a name hides intent; the refactoring changes the name while preserving behavior.
