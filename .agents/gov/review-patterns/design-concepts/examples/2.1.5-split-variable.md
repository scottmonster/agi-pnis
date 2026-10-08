# Split Variable

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.5
- **Aliases:** split temp, remove assignments to parameters
- **Definition:** Give distinct roles separate variables rather than reassigning one name. It preserves what each value means across the routine.
- **Why it matters:** It makes each intermediate value's meaning explicit, so readers can follow the calculation without mentally tracking how one variable's role changes over time.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An order service calculates the final amount charged for a cart by applying a member discount and then adding sales tax.

### 2.2 Good form

```ts
type CartItem = {
  name: string;
  unitPriceCents: number;
  quantity: number;
};

function calculateChargeCents(
  items: CartItem[],
  isMember: boolean,
  taxRate: number
): number {
  const subtotalCents = items.reduce(
    (sum, item) => sum + item.unitPriceCents * item.quantity,
    0
  );

  const discountCents = isMember ? Math.round(subtotalCents * 0.1) : 0;
  const discountedSubtotalCents = subtotalCents - discountCents;
  const taxCents = Math.round(discountedSubtotalCents * taxRate);
  const chargeCents = discountedSubtotalCents + taxCents;

  return chargeCents;
}
```

### 2.3 Less maintainable form

```ts
type CartItem = {
  name: string;
  unitPriceCents: number;
  quantity: number;
};

function calculateChargeCents(
  items: CartItem[],
  isMember: boolean,
  taxRate: number
): number {
  let totalCents = items.reduce(
    (sum, item) => sum + item.unitPriceCents * item.quantity,
    0
  );

  const discountCents = isMember ? Math.round(totalCents * 0.1) : 0;
  totalCents = totalCents - discountCents;

  const taxCents = Math.round(totalCents * taxRate);
  totalCents = totalCents + taxCents;

  return totalCents;
}
```

### 2.4 Why this difference matters

The good form gives each role in the calculation its own name: `subtotalCents`, `discountedSubtotalCents`, `taxCents`, and `chargeCents`. Those names preserve what each value means at that point in the routine.

The less maintainable form reuses `totalCents` for multiple meanings: original subtotal, discounted subtotal, and final charge. To understand or change the function, a reader must inspect the assignment history to know which meaning `totalCents` currently has.

### 2.5 Structural references

```text
Good: order-service > pricing > charge.ts > calculateChargeCents > subtotalCents/discountedSubtotalCents/chargeCents
Less maintainable: order-service > pricing > charge.ts > calculateChargeCents > totalCents
```

The relevant structural difference is inside the function target: the good form represents distinct calculation roles with distinct local variables, while the less maintainable form represents several roles by repeatedly assigning to one local variable.

## 3. Boundaries and distinctions

Split Variable applies when one variable is reused for different meanings during a routine. It does not apply to ordinary accumulation where the variable has one stable role, such as `sum`, `count`, or `index` in a loop.

The less maintainable form can be acceptable for very small, conventional accumulators where the variable's role never changes. For example, incrementing `totalCents` while summing line items is not a split-variable problem if `totalCents` always means the running total.

This refactoring is different from simply renaming a variable. Renaming improves a single variable's name, while Split Variable creates separate variables because there are separate concepts to name. It is also different from extracting a function: extraction moves logic to a new routine, while Split Variable can improve clarity within the same routine.
