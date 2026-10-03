# Deep Nesting

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 1.3.2
- **Aliases:** None
- **Definition:** Multiple levels of conditional or loop indentation require the reader to carry too much enclosing context. It is broader than the particular arrow shape.
- **Why it matters:** Deep nesting makes readers track many active conditions at once, which increases the chance of misunderstanding behavior and makes later changes riskier.
- **Related concepts:** Arrow Code

## 2. Example

### 2.1 Scenario

An order service applies a loyalty discount only when the order is valid, the customer is active, and the order total meets the discount threshold.

### 2.2 Good form

```ts
type Customer = {
  id: string;
  active: boolean;
  loyaltyTier: "standard" | "gold";
};

type Order = {
  id: string;
  customer?: Customer;
  items: Array<{ sku: string; price: number; quantity: number }>;
};

function calculateDiscountedTotal(order: Order): number {
  if (!order.customer) {
    return 0;
  }

  if (!order.customer.active) {
    return 0;
  }

  const total = order.items.reduce(
    (sum, item) => sum + item.price * item.quantity,
    0
  );

  if (total < 100) {
    return total;
  }

  if (order.customer.loyaltyTier !== "gold") {
    return total;
  }

  return total * 0.9;
}

const order: Order = {
  id: "ord-100",
  customer: { id: "cust-1", active: true, loyaltyTier: "gold" },
  items: [
    { sku: "keyboard", price: 80, quantity: 1 },
    { sku: "mouse", price: 30, quantity: 1 }
  ]
};

console.log(calculateDiscountedTotal(order));
```

### 2.3 Less maintainable form

```ts
type Customer = {
  id: string;
  active: boolean;
  loyaltyTier: "standard" | "gold";
};

type Order = {
  id: string;
  customer?: Customer;
  items: Array<{ sku: string; price: number; quantity: number }>;
};

function calculateDiscountedTotal(order: Order): number {
  let discountedTotal = 0;

  if (order.customer) {
    if (order.customer.active) {
      let total = 0;

      for (const item of order.items) {
        total += item.price * item.quantity;
      }

      if (total >= 100) {
        if (order.customer.loyaltyTier === "gold") {
          discountedTotal = total * 0.9;
        } else {
          discountedTotal = total;
        }
      } else {
        discountedTotal = total;
      }
    }
  }

  return discountedTotal;
}

const order: Order = {
  id: "ord-100",
  customer: { id: "cust-1", active: true, loyaltyTier: "gold" },
  items: [
    { sku: "keyboard", price: 80, quantity: 1 },
    { sku: "mouse", price: 30, quantity: 1 }
  ]
};

console.log(calculateDiscountedTotal(order));
```

### 2.4 Why this difference matters

The good form handles disqualifying cases early, so the main calculation stays at a shallow indentation level. A reader can understand each rule independently: no customer, inactive customer, below threshold, non-gold customer, then discount. The less maintainable form requires the reader to remember every enclosing condition before interpreting the innermost assignment.

### 2.5 Structural references

```text
Good: checkout-service > orders > discounts.ts > calculateDiscountedTotal > discounted total return
Less maintainable: checkout-service > orders > discounts.ts > calculateDiscountedTotal > nested discounted total assignment
```

Both examples place the behavior in the same function. The relevant structural difference is inside the function body: the good form keeps the target calculation near the top indentation level, while the less maintainable form buries the target assignment under several nested control-flow blocks.

## 3. Boundaries and distinctions

Deep nesting is not about any single `if`, loop, or indentation level being inherently wrong. Nesting is often appropriate when the inner logic genuinely depends on the outer context and extracting it would obscure the flow. It may also be acceptable in small, stable code where the complete condition stack is immediately obvious.

The smell appears when understanding a line requires carrying too many enclosing conditions or loops in memory. Common remedies include guard clauses, extracting functions, combining related predicates, returning early, or simplifying control flow.

Deep Nesting is broader than Arrow Code. Arrow Code is a specific visual pattern where nested conditionals drift to the right like an arrow. Deep Nesting includes that pattern, but it also includes nested loops, mixed loops and conditionals, or any indentation structure that makes local reasoning difficult.
