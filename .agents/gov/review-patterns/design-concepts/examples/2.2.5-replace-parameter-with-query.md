# Replace Parameter with Query

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.2.5
- **Aliases:** None
- **Definition:** Let a function obtain an available value rather than passing it redundantly. It can simplify calls, but only when doing so does not hide a meaningful dependency.
- **Why it matters:** It reduces duplicated knowledge at call sites, makes function calls easier to read, and prevents callers from accidentally passing a value that disagrees with data the function already has.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An order-pricing function applies a customer discount. The discount can be derived from the `customer` already present on the `Order`, so callers do not need to pass it separately.

### 2.2 Good form

```ts
type Customer = {
  id: string;
  yearsActive: number;
  isEmployee: boolean;
};

type LineItem = {
  sku: string;
  quantity: number;
  unitPrice: number;
};

type Order = {
  id: string;
  customer: Customer;
  items: LineItem[];
};

function discountRateFor(customer: Customer): number {
  if (customer.isEmployee) {
    return 0.2;
  }

  if (customer.yearsActive >= 5) {
    return 0.1;
  }

  return 0;
}

function roundCurrency(amount: number): number {
  return Math.round(amount * 100) / 100;
}

function priceOrder(order: Order): number {
  const subtotal = order.items.reduce(
    (sum, item) => sum + item.quantity * item.unitPrice,
    0
  );

  const discountRate = discountRateFor(order.customer);

  return roundCurrency(subtotal * (1 - discountRate));
}

const order: Order = {
  id: "order-1001",
  customer: {
    id: "customer-7",
    yearsActive: 6,
    isEmployee: false
  },
  items: [
    { sku: "notebook", quantity: 2, unitPrice: 8.5 },
    { sku: "pen", quantity: 3, unitPrice: 1.25 }
  ]
};

const total = priceOrder(order);
```

### 2.3 Less maintainable form

```ts
type Customer = {
  id: string;
  yearsActive: number;
  isEmployee: boolean;
};

type LineItem = {
  sku: string;
  quantity: number;
  unitPrice: number;
};

type Order = {
  id: string;
  customer: Customer;
  items: LineItem[];
};

function discountRateFor(customer: Customer): number {
  if (customer.isEmployee) {
    return 0.2;
  }

  if (customer.yearsActive >= 5) {
    return 0.1;
  }

  return 0;
}

function roundCurrency(amount: number): number {
  return Math.round(amount * 100) / 100;
}

function priceOrder(order: Order, discountRate: number): number {
  const subtotal = order.items.reduce(
    (sum, item) => sum + item.quantity * item.unitPrice,
    0
  );

  return roundCurrency(subtotal * (1 - discountRate));
}

const order: Order = {
  id: "order-1001",
  customer: {
    id: "customer-7",
    yearsActive: 6,
    isEmployee: false
  },
  items: [
    { sku: "notebook", quantity: 2, unitPrice: 8.5 },
    { sku: "pen", quantity: 3, unitPrice: 1.25 }
  ]
};

const total = priceOrder(order, discountRateFor(order.customer));
```

### 2.4 Why this difference matters

In the good form, `priceOrder` receives the `Order` and queries the discount rate from `order.customer`, which it already has. The call site only supplies the information that is not already available to the function.

In the less maintainable form, every caller must remember to calculate and pass a `discountRate` that matches the order's customer. That creates a redundant parameter and allows inconsistent calls, such as pricing one customer's order with another customer's discount.

### 2.5 Structural references

```text
Good: sales-service > orders > discounts.ts > finalPriceFor > discountRateFor(order.customer)
Less maintainable: sales-service > orders > discounts.ts > finalPriceFor > discountRate parameter
```

The relevant structural difference is that the good form derives the discount inside `priceOrder` from data already reachable through `order`, while the less maintainable form adds a separate parameter for the same derived value.

## 3. Boundaries and distinctions

Replace Parameter with Query applies when the callee can obtain the value reliably from information it already has. It should not be used if removing the parameter hides an important dependency, makes the function reach into unrelated global state, or couples the function to data it should not know about.

The less maintainable form can be appropriate when the supplied value is intentionally independent from the available data. For example, a caller may need to price an order using a historical discount snapshot, a promotional override, or a simulated rate for testing a pricing scenario. In those cases, the parameter communicates a real input rather than redundant information.

This refactoring is specifically about removing a parameter whose value can be queried by the function. It is not the same as merely inlining a variable at the call site, and it is not a reason to make functions depend on hidden mutable state.
