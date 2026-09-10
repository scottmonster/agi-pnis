# Combine Functions into Transform

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.5
- **Aliases:** None
- **Definition:** Group transformations over a common record into a single transformation pipeline. It keeps derived data creation close to its source representation.
- **Why it matters:** It makes derived fields easier to find, review, and change because the logic for enriching a record is centralized instead of scattered across separate helper calls.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout service receives a raw order record and needs to derive subtotal, discount, tax, and final total before sending the order summary to the customer.

### 2.2 Good form

```ts
type LineItem = {
  sku: string;
  quantity: number;
  unitPrice: number;
};

type RawOrder = {
  id: string;
  customerId: string;
  loyaltyTier: "standard" | "gold";
  taxRate: number;
  items: LineItem[];
};

type OrderSummary = RawOrder & {
  subtotal: number;
  discount: number;
  taxableAmount: number;
  tax: number;
  total: number;
};

function transformOrder(order: RawOrder): OrderSummary {
  const subtotal = order.items.reduce(
    (sum, item) => sum + item.quantity * item.unitPrice,
    0
  );

  const discount = order.loyaltyTier === "gold" ? subtotal * 0.1 : 0;
  const taxableAmount = subtotal - discount;
  const tax = taxableAmount * order.taxRate;
  const total = taxableAmount + tax;

  return {
    ...order,
    subtotal,
    discount,
    taxableAmount,
    tax,
    total
  };
}

function formatCustomerSummary(order: RawOrder): string {
  const summary = transformOrder(order);

  return [
    `Order: ${summary.id}`,
    `Subtotal: $${summary.subtotal.toFixed(2)}`,
    `Discount: $${summary.discount.toFixed(2)}`,
    `Tax: $${summary.tax.toFixed(2)}`,
    `Total: $${summary.total.toFixed(2)}`
  ].join("\n");
}

const order: RawOrder = {
  id: "ORD-1001",
  customerId: "CUST-42",
  loyaltyTier: "gold",
  taxRate: 0.08,
  items: [
    { sku: "BOOK", quantity: 2, unitPrice: 15 },
    { sku: "BAG", quantity: 1, unitPrice: 40 }
  ]
};

console.log(formatCustomerSummary(order));
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  sku: string;
  quantity: number;
  unitPrice: number;
};

type RawOrder = {
  id: string;
  customerId: string;
  loyaltyTier: "standard" | "gold";
  taxRate: number;
  items: LineItem[];
};

function calculateSubtotal(order: RawOrder): number {
  return order.items.reduce(
    (sum, item) => sum + item.quantity * item.unitPrice,
    0
  );
}

function calculateDiscount(order: RawOrder): number {
  const subtotal = calculateSubtotal(order);
  return order.loyaltyTier === "gold" ? subtotal * 0.1 : 0;
}

function calculateTax(order: RawOrder): number {
  const subtotal = calculateSubtotal(order);
  const discount = calculateDiscount(order);
  return (subtotal - discount) * order.taxRate;
}

function calculateTotal(order: RawOrder): number {
  const subtotal = calculateSubtotal(order);
  const discount = calculateDiscount(order);
  const tax = calculateTax(order);
  return subtotal - discount + tax;
}

function formatCustomerSummary(order: RawOrder): string {
  const subtotal = calculateSubtotal(order);
  const discount = calculateDiscount(order);
  const tax = calculateTax(order);
  const total = calculateTotal(order);

  return [
    `Order: ${order.id}`,
    `Subtotal: $${subtotal.toFixed(2)}`,
    `Discount: $${discount.toFixed(2)}`,
    `Tax: $${tax.toFixed(2)}`,
    `Total: $${total.toFixed(2)}`
  ].join("\n");
}

const order: RawOrder = {
  id: "ORD-1001",
  customerId: "CUST-42",
  loyaltyTier: "gold",
  taxRate: 0.08,
  items: [
    { sku: "BOOK", quantity: 2, unitPrice: 15 },
    { sku: "BAG", quantity: 1, unitPrice: 40 }
  ]
};

console.log(formatCustomerSummary(order));
```

### 2.4 Why this difference matters

In the good form, all derived values for the order are created in one transformation over the raw record. Readers can see the dependency chain from `subtotal` to `discount`, `taxableAmount`, `tax`, and `total` in one place. If the business rule changes, such as adding a shipping fee or changing which amount is taxable, the derived representation has a single obvious home.

In the less maintainable form, each derived value is exposed as a separate function that repeatedly re-derives earlier values. The relationship between those values is spread across several functions, making it easier to update one calculation while missing another.

### 2.5 Structural references

```text
Good: checkout-service > orders > order-summary.ts > transformOrder > OrderSummary
Less maintainable: checkout-service > orders > order-summary.ts > calculateTotal > total
```

The relevant structural difference is that the good form has one transformation function that produces the enriched order representation, while the less maintainable form leaves each derived value as a separate calculation used directly by the caller.

## 3. Boundaries and distinctions

Combine Functions into Transform applies when multiple derived values are computed from the same source record and are commonly needed together. It is most useful when those values form a coherent enriched representation of the original data.

The less maintainable form can be appropriate when each calculation is genuinely independent, rarely used with the others, or belongs to a different domain concern. Separate functions may also be better when callers need only one expensive calculation and creating the full transformed record would waste significant work.

This refactoring is not just extracting helper functions. Extraction separates named pieces of logic, while Combine Functions into Transform gathers related derivations into a single pipeline that produces an enriched record. It also differs from building a general object model: the goal is not to add behavior everywhere, but to keep derived data creation close to the source representation it extends.
