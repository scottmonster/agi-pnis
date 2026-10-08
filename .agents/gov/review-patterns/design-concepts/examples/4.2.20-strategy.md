# Strategy

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.20
- **Aliases:** None
- **Definition:** Encapsulate a family of interchangeable algorithms behind one interface. It makes a policy choice explicit and keeps each algorithm separate.
- **Why it matters:** Strategy makes code easier to read and change by isolating each algorithm behind a shared contract, so adding or replacing a policy does not require editing one large conditional block.
- **Related concepts:** State

## 2. Example

### 2.1 Scenario

An online store calculates shipping cost for an order. The checkout flow supports standard shipping, express shipping, and in-store pickup.

### 2.2 Good form

```ts
type ShippingMethod = "standard" | "express" | "pickup";

type Order = {
  subtotal: number;
  weightKg: number;
};

interface ShippingStrategy {
  calculate(order: Order): number;
}

class StandardShipping implements ShippingStrategy {
  calculate(order: Order): number {
    return 5 + order.weightKg * 1.25;
  }
}

class ExpressShipping implements ShippingStrategy {
  calculate(order: Order): number {
    return 15 + order.weightKg * 3;
  }
}

class PickupShipping implements ShippingStrategy {
  calculate(_order: Order): number {
    return 0;
  }
}

const shippingStrategies: Record<ShippingMethod, ShippingStrategy> = {
  standard: new StandardShipping(),
  express: new ExpressShipping(),
  pickup: new PickupShipping(),
};

function calculateShippingCost(order: Order, method: ShippingMethod): number {
  const strategy = shippingStrategies[method];
  return strategy.calculate(order);
}

const order: Order = { subtotal: 80, weightKg: 4 };

console.log(calculateShippingCost(order, "standard")); // 10
console.log(calculateShippingCost(order, "express")); // 27
console.log(calculateShippingCost(order, "pickup")); // 0
```

### 2.3 Less maintainable form

```ts
type ShippingMethod = "standard" | "express" | "pickup";

type Order = {
  subtotal: number;
  weightKg: number;
};

function calculateShippingCost(order: Order, method: ShippingMethod): number {
  if (method === "standard") {
    return 5 + order.weightKg * 1.25;
  }

  if (method === "express") {
    return 15 + order.weightKg * 3;
  }

  if (method === "pickup") {
    return 0;
  }

  const exhaustiveCheck: never = method;
  return exhaustiveCheck;
}

const order: Order = { subtotal: 80, weightKg: 4 };

console.log(calculateShippingCost(order, "standard")); // 10
console.log(calculateShippingCost(order, "express")); // 27
console.log(calculateShippingCost(order, "pickup")); // 0
```

### 2.4 Why this difference matters

The good form names shipping calculation as a replaceable policy and gives every algorithm the same `ShippingStrategy` interface. The checkout function only selects and invokes a strategy, so it does not need to know the details of each shipping formula.

In the less maintainable form, every algorithm is embedded inside `calculateShippingCost`. Adding a new shipping method means editing the same conditional function, increasing the chance of mixing unrelated formulas, breaking existing behavior, or making the function harder to scan.

### 2.5 Structural references

```text
Good: shop-api > checkout > shipping.ts > calculateShippingCost > ShippingStrategy.calculate
Less maintainable: shop-api > checkout > shipping.ts > calculateShippingCost > method === "overnight" branch
```

The relevant structural difference is where the algorithm varies. In the good form, variation is represented as interchangeable strategy implementations behind one target interface. In the less maintainable form, variation is represented as branches inside the checkout calculation function.

## 3. Boundaries and distinctions

Strategy is useful when several algorithms have the same purpose and callers should be able to choose among them explicitly. It is especially helpful when algorithms change independently, are selected at runtime, or are reused in different contexts.

Strategy may be unnecessary when there is only one algorithm, when the variation is trivial and unlikely to grow, or when a short conditional is clearer than introducing several small objects. The less maintainable form can be appropriate for a small, closed set of cases where the branching logic is simple and local.

Strategy differs from State. Strategy usually represents an explicit policy choice made by the caller or configuration, such as choosing a shipping calculation method. State represents behavior that changes because an object moves through internal states over time, such as an order moving from `draft` to `paid` to `shipped`.
