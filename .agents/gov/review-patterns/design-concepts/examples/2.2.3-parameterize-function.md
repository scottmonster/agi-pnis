# Parameterize Function

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.2.3
- **Aliases:** parameterize method
- **Definition:** Replace near-duplicate functions with one function whose explicit parameter describes the true variation. It centralizes shared behavior without using an opaque flag.
- **Why it matters:** It makes the shared behavior visible in one place, makes the varying value explicit, and reduces the chance that duplicate functions drift apart during maintenance.
- **Related concepts:** Flag Argument

## 2. Example

### 2.1 Scenario

An online store calculates discounted totals for different promotion types. The calculation is identical except for the discount percentage.

### 2.2 Good form

```ts
type LineItem = {
  name: string;
  unitPrice: number;
  quantity: number;
};

type Order = {
  id: string;
  items: LineItem[];
};

function orderSubtotal(order: Order): number {
  return order.items.reduce(
    (total, item) => total + item.unitPrice * item.quantity,
    0
  );
}

function roundCurrency(amount: number): number {
  return Math.round(amount * 100) / 100;
}

function discountedTotal(order: Order, discountPercent: number): number {
  const subtotal = orderSubtotal(order);
  const discountMultiplier = 1 - discountPercent / 100;

  return roundCurrency(subtotal * discountMultiplier);
}

const order: Order = {
  id: "order-1001",
  items: [
    { name: "Notebook", unitPrice: 8, quantity: 3 },
    { name: "Pen", unitPrice: 2.5, quantity: 4 }
  ]
};

const seasonalPromotionTotal = discountedTotal(order, 10);
const loyaltyPromotionTotal = discountedTotal(order, 15);
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  name: string;
  unitPrice: number;
  quantity: number;
};

type Order = {
  id: string;
  items: LineItem[];
};

function orderSubtotal(order: Order): number {
  return order.items.reduce(
    (total, item) => total + item.unitPrice * item.quantity,
    0
  );
}

function roundCurrency(amount: number): number {
  return Math.round(amount * 100) / 100;
}

function seasonalPromotionTotal(order: Order): number {
  const subtotal = orderSubtotal(order);
  const discountMultiplier = 1 - 10 / 100;

  return roundCurrency(subtotal * discountMultiplier);
}

function loyaltyPromotionTotal(order: Order): number {
  const subtotal = orderSubtotal(order);
  const discountMultiplier = 1 - 15 / 100;

  return roundCurrency(subtotal * discountMultiplier);
}

const order: Order = {
  id: "order-1001",
  items: [
    { name: "Notebook", unitPrice: 8, quantity: 3 },
    { name: "Pen", unitPrice: 2.5, quantity: 4 }
  ]
};

const seasonalTotal = seasonalPromotionTotal(order);
const loyaltyTotal = loyaltyPromotionTotal(order);
```

### 2.4 Why this difference matters

The good form identifies the true variation as `discountPercent` and gives the duplicated calculation one home. If rounding, subtotal handling, or discount math changes, there is one function to update. The less maintainable form hides the shared structure across multiple near-identical functions, so future changes must be repeated consistently.

### 2.5 Structural references

```text
Good: shop-app > pricing > pricing.ts > discountedTotal > discountPercent
Less maintainable: shop-app > pricing > pricing.ts > seasonalPromotionTotal and loyaltyPromotionTotal > duplicated discount percentages
```

The structural difference is that the good form has one function with a parameter for the varying discount value, while the less maintainable form has multiple functions whose bodies differ only by embedded constants.

## 3. Boundaries and distinctions

Parameterize Function applies when functions are near-duplicates and the real variation can be named as a meaningful parameter, such as `discountPercent`, `minimumBalance`, or `retryLimit`.

It does not apply when the functions represent genuinely different behavior with different steps, responsibilities, or reasons to change. In that case, separate functions, extracted helpers, strategy objects, or polymorphism may be clearer.

The less maintainable form can be appropriate when the named functions are intentional domain-facing wrappers, for example `seasonalPromotionTotal(order)` calling `discountedTotal(order, 10)`. In that design, the duplication is removed while the public name remains expressive.

This differs from a Flag Argument. Parameterize Function uses a parameter that names the actual varying value. A Flag Argument usually passes an opaque boolean or mode switch, such as `calculateTotal(order, true)`, causing one function to contain multiple behavioral branches.
