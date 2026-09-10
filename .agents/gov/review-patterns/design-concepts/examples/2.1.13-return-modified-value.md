# Return Modified Value

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.13
- **Aliases:** None
- **Definition:** Have a function return the value it modified so callers can continue with the updated value directly. It can make a data transformation chain explicit and reduce separate lookup or mutation steps.
- **Why it matters:** Returning the modified value makes the flow of an updated object visible at the call site. Readers can see which value continues through the transformation, and future changes can add or reorder steps without introducing extra temporary lookups or disconnected mutation statements.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout service builds an invoice draft, applies a coupon, and then adds tax before returning the final invoice. Each step intentionally updates the same draft object.

### 2.2 Good form

```ts
type InvoiceDraft = {
  customerId: string;
  subtotalCents: number;
  discountCents: number;
  taxCents: number;
  totalCents: number;
};

type Coupon = {
  code: string;
  discountCents: number;
};

function applyCoupon(invoice: InvoiceDraft, coupon: Coupon): InvoiceDraft {
  invoice.discountCents = Math.min(coupon.discountCents, invoice.subtotalCents);
  invoice.totalCents = invoice.subtotalCents - invoice.discountCents + invoice.taxCents;
  return invoice;
}

function applyTax(invoice: InvoiceDraft, taxRate: number): InvoiceDraft {
  const taxableCents = invoice.subtotalCents - invoice.discountCents;
  invoice.taxCents = Math.round(taxableCents * taxRate);
  invoice.totalCents = taxableCents + invoice.taxCents;
  return invoice;
}

function prepareInvoice(customerId: string, subtotalCents: number, coupon: Coupon): InvoiceDraft {
  const invoice: InvoiceDraft = {
    customerId,
    subtotalCents,
    discountCents: 0,
    taxCents: 0,
    totalCents: subtotalCents,
  };

  return applyTax(applyCoupon(invoice, coupon), 0.0825);
}

const preparedInvoice = prepareInvoice("cust-42", 10_000, {
  code: "WELCOME",
  discountCents: 1_500,
});

console.log(preparedInvoice.totalCents);
```

### 2.3 Less maintainable form

```ts
type InvoiceDraft = {
  customerId: string;
  subtotalCents: number;
  discountCents: number;
  taxCents: number;
  totalCents: number;
};

type Coupon = {
  code: string;
  discountCents: number;
};

function applyCoupon(invoice: InvoiceDraft, coupon: Coupon): void {
  invoice.discountCents = Math.min(coupon.discountCents, invoice.subtotalCents);
  invoice.totalCents = invoice.subtotalCents - invoice.discountCents + invoice.taxCents;
}

function applyTax(invoice: InvoiceDraft, taxRate: number): void {
  const taxableCents = invoice.subtotalCents - invoice.discountCents;
  invoice.taxCents = Math.round(taxableCents * taxRate);
  invoice.totalCents = taxableCents + invoice.taxCents;
}

function prepareInvoice(customerId: string, subtotalCents: number, coupon: Coupon): InvoiceDraft {
  const invoice: InvoiceDraft = {
    customerId,
    subtotalCents,
    discountCents: 0,
    taxCents: 0,
    totalCents: subtotalCents,
  };

  applyCoupon(invoice, coupon);
  applyTax(invoice, 0.0825);

  return invoice;
}

const preparedInvoice = prepareInvoice("cust-42", 10_000, {
  code: "WELCOME",
  discountCents: 1_500,
});

console.log(preparedInvoice.totalCents);
```

### 2.4 Why this difference matters

In the good form, each mutating function returns the same `InvoiceDraft` it updated. The call site can pass the updated value directly to the next transformation, so the sequence reads as one explicit data flow: create draft, apply coupon, apply tax, return the updated invoice.

In the less maintainable form, the functions still mutate the invoice, but the returned value is disconnected from the mutation. A reader must track the side effects across separate statements and remember that `invoice` has changed after each call. That becomes harder to maintain when more transformation steps are added or when the invoice is passed through helper functions.

### 2.5 Structural references

```text
Good: checkout-service > pricing > invoice.ts > prepareInvoice > applyCoupon returned invoice
Less maintainable: checkout-service > pricing > invoice.ts > prepareInvoice > side-effect-only applyCoupon call
```

Both forms modify the same `invoice` target in the same function. The structural difference is that the good form keeps the modified target as the returned value from each transformation, while the less maintainable form updates the target only through side effects and then refers back to the original local variable.

## 3. Boundaries and distinctions

Return Modified Value applies when a function intentionally modifies an existing value and callers benefit from immediately continuing with that updated value. It is most useful when several operations form a transformation sequence over the same object.

It does not apply when a function should be a pure transformation that returns a new value instead of mutating its argument. In that case, the clearer design is to avoid mutation entirely. It also does not apply when returning the modified value would imply ownership or identity guarantees the function cannot safely provide.

The less maintainable form can be appropriate when a mutating function is an event-style command whose result should not be chained, such as logging, sending a notification, or updating an external store. Returning `void` can also be clearer when the caller should not depend on the modified object as an expression result.

This refactoring is specifically about returning the value that was modified. It is not the same as changing a function from mutable to immutable behavior, and it is not merely about fluent APIs. A fluent API may return `this` for method chaining, while Return Modified Value can apply to ordinary functions that update and return a parameter.
