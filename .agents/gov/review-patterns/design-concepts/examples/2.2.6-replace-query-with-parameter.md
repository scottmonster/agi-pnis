# Replace Query with Parameter

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.2.6
- **Aliases:** None
- **Definition:** Pass a value explicitly instead of having a function obtain it. It exposes a dependency, makes behavior easier to understand in context, and can reduce hidden coupling.
- **Why it matters:** It makes a function's inputs visible at the call site, so readers can understand what affects the result without inspecting hidden queries, global state, or collaborators. This improves testability and reduces coupling between the function and data sources it does not need to own.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout service calculates an order total using the customer's loyalty discount rate. The intended behavior is the same in both versions: apply the discount rate for the customer placing the order.

### 2.2 Good form

```ts
type LineItem = {
  sku: string;
  quantity: number;
  unitPriceCents: number;
};

type Order = {
  customerId: string;
  items: LineItem[];
};

class CustomerDiscounts {
  private readonly ratesByCustomerId = new Map<string, number>([
    ["customer-100", 0.1],
    ["customer-200", 0.05],
  ]);

  getLoyaltyDiscountRate(customerId: string): number {
    return this.ratesByCustomerId.get(customerId) ?? 0;
  }
}

function subtotalCents(order: Order): number {
  return order.items.reduce(
    (sum, item) => sum + item.quantity * item.unitPriceCents,
    0,
  );
}

function priceOrder(order: Order, loyaltyDiscountRate: number): number {
  const subtotal = subtotalCents(order);
  return Math.round(subtotal * (1 - loyaltyDiscountRate));
}

function checkout(order: Order, discounts: CustomerDiscounts): number {
  const loyaltyDiscountRate = discounts.getLoyaltyDiscountRate(order.customerId);
  return priceOrder(order, loyaltyDiscountRate);
}

const order: Order = {
  customerId: "customer-100",
  items: [
    { sku: "notebook", quantity: 2, unitPriceCents: 500 },
    { sku: "pen", quantity: 3, unitPriceCents: 150 },
  ],
};

const totalCents = checkout(order, new CustomerDiscounts());
console.log(totalCents);
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  sku: string;
  quantity: number;
  unitPriceCents: number;
};

type Order = {
  customerId: string;
  items: LineItem[];
};

class CustomerDiscounts {
  private readonly ratesByCustomerId = new Map<string, number>([
    ["customer-100", 0.1],
    ["customer-200", 0.05],
  ]);

  getLoyaltyDiscountRate(customerId: string): number {
    return this.ratesByCustomerId.get(customerId) ?? 0;
  }
}

function subtotalCents(order: Order): number {
  return order.items.reduce(
    (sum, item) => sum + item.quantity * item.unitPriceCents,
    0,
  );
}

function priceOrder(order: Order, discounts: CustomerDiscounts): number {
  const loyaltyDiscountRate = discounts.getLoyaltyDiscountRate(order.customerId);
  const subtotal = subtotalCents(order);
  return Math.round(subtotal * (1 - loyaltyDiscountRate));
}

function checkout(order: Order, discounts: CustomerDiscounts): number {
  return priceOrder(order, discounts);
}

const order: Order = {
  customerId: "customer-100",
  items: [
    { sku: "notebook", quantity: 2, unitPriceCents: 500 },
    { sku: "pen", quantity: 3, unitPriceCents: 150 },
  ],
};

const totalCents = checkout(order, new CustomerDiscounts());
console.log(totalCents);
```

### 2.4 Why this difference matters

In the good form, `priceOrder` states its real pricing inputs directly: an `Order` and a `loyaltyDiscountRate`. A reader does not need to inspect the function body to discover that customer discount lookup affects the result. The function is also easier to test because a test can pass `0.1` or `0` directly instead of constructing a discount provider.

In the less maintainable form, `priceOrder` hides part of its dependency by querying `CustomerDiscounts` itself. That couples pricing calculation to discount lookup and makes the function do two jobs: retrieve the rate and apply the rate. Passing the already-known value keeps lookup responsibility at the caller and leaves the calculation focused.

### 2.5 Structural references

```text
Good: checkout-service > pricing > pricing.ts > priceOrder > loyaltyDiscountRate parameter
Less maintainable: checkout-service > pricing > pricing.ts > priceOrder > discounts.getLoyaltyDiscountRate query
```

The relevant structural difference is that the good form makes the discount rate an explicit parameter of `priceOrder`, while the less maintainable form performs the discount lookup inside `priceOrder`.

## 3. Boundaries and distinctions

Replace Query with Parameter is useful when a function does not need to own how a value is obtained and only needs the value to complete its work. It is especially helpful when the queried value comes from global state, a service, a repository, the clock, configuration, or another collaborator that hides an input to the function's behavior.

The less maintainable form can be appropriate when the query is truly part of the function's responsibility, when the queried value must be read at the exact moment of use, or when moving the query outward would force callers to know implementation details they should not know. If many values must be passed together, that may indicate a need for a parameter object or a better abstraction rather than a long parameter list.

This refactoring is not about changing the algorithm. Both versions compute the same result. The difference is where the dependency is expressed: as an explicit input in the good form, or as an internal query in the less maintainable form.
