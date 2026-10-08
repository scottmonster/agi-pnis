# Slide Statements

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.12
- **Aliases:** None
- **Definition:** Move related statements together. It makes the code's local grouping match its data/control dependency.
- **Why it matters:** It reduces the distance between a value, the logic that depends on it, and the effect it produces, making the code easier to scan, reason about, and safely change.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An order service calculates the final charge for a cart, including subtotal, coupon discount, tax, and shipping. The behavior is the same in both versions, but the related coupon statements are grouped differently.

### 2.2 Good form

```ts
type CartItem = {
  name: string;
  unitPriceCents: number;
  quantity: number;
};

type Coupon = {
  code: string;
  percentOff: number;
  expiresAt: Date;
};

function calculateShippingCents(subtotalCents: number): number {
  return subtotalCents >= 5_000 ? 0 : 799;
}

function calculateTaxCents(taxableCents: number): number {
  return Math.round(taxableCents * 0.0825);
}

function calculateFinalChargeCents(
  items: CartItem[],
  coupon: Coupon | null,
  now: Date
): number {
  const subtotalCents = items.reduce(
    (sum, item) => sum + item.unitPriceCents * item.quantity,
    0
  );

  const validCoupon =
    coupon !== null && coupon.expiresAt.getTime() > now.getTime();
  const discountCents = validCoupon
    ? Math.round(subtotalCents * (coupon.percentOff / 100))
    : 0;
  const discountedSubtotalCents = subtotalCents - discountCents;

  const taxCents = calculateTaxCents(discountedSubtotalCents);
  const shippingCents = calculateShippingCents(subtotalCents);

  return discountedSubtotalCents + taxCents + shippingCents;
}
```

### 2.3 Less maintainable form

```ts
type CartItem = {
  name: string;
  unitPriceCents: number;
  quantity: number;
};

type Coupon = {
  code: string;
  percentOff: number;
  expiresAt: Date;
};

function calculateShippingCents(subtotalCents: number): number {
  return subtotalCents >= 5_000 ? 0 : 799;
}

function calculateTaxCents(taxableCents: number): number {
  return Math.round(taxableCents * 0.0825);
}

function calculateFinalChargeCents(
  items: CartItem[],
  coupon: Coupon | null,
  now: Date
): number {
  const subtotalCents = items.reduce(
    (sum, item) => sum + item.unitPriceCents * item.quantity,
    0
  );

  const validCoupon =
    coupon !== null && coupon.expiresAt.getTime() > now.getTime();

  const shippingCents = calculateShippingCents(subtotalCents);

  const discountCents = validCoupon
    ? Math.round(subtotalCents * (coupon.percentOff / 100))
    : 0;
  const discountedSubtotalCents = subtotalCents - discountCents;

  const taxCents = calculateTaxCents(discountedSubtotalCents);

  return discountedSubtotalCents + taxCents + shippingCents;
}
```

### 2.4 Why this difference matters

In the good form, the coupon validity check, discount calculation, and discounted subtotal calculation are adjacent because they form one dependency chain. A reader can understand the discount logic without skipping over the unrelated shipping calculation. This also makes future changes safer, such as replacing coupon rules or extracting discount logic, because the statements that must move together are already grouped together.

### 2.5 Structural references

```text
Good: billing-service > invoices > invoiceEmail.ts > sendInvoiceEmail > calculate totals statement group
Less maintainable: billing-service > invoices > invoiceEmail.ts > sendInvoiceEmail > separated total statements
```

The relevant structural difference is local statement placement inside the same function. The good form keeps dependent statements in one contiguous group, while the less maintainable form separates them with an unrelated shipping statement.

## 3. Boundaries and distinctions

Slide Statements applies when statements can be moved without changing behavior and when moving them improves the local grouping of related data or control flow. It does not apply if reordering statements changes side effects, changes when errors are thrown, changes observable timing, or violates a required control-flow sequence.

The less maintainable form can be appropriate temporarily when preserving a fragile order is more important than grouping, or when the intervening statement has a necessary side effect that must occur at that exact point.

Slide Statements differs from extracting a function: it only reorders existing statements within the current scope. It also differs from renaming or simplifying expressions: the code may keep the same names and expressions, but the local order changes so related work appears together.
