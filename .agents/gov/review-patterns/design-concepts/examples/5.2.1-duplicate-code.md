# Duplicate Code

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.1
- **Aliases:** copy-and-paste programming
- **Definition:** The same or substantially similar logic appears in multiple places. Independent copies drift and make one conceptual change require many edits.
- **Why it matters:** Duplicate Code makes behavior harder to understand and maintain because readers must compare multiple similar blocks to know whether they are intentionally different. A single business rule change can require many edits, increasing the chance that one copy is missed or changed inconsistently.
- **Related concepts:** Extract Function, Pull Up Method

## 2. Example

### 2.1 Scenario

An order service produces both a web receipt and an email receipt. Both receipts must apply the same subtotal, discount, tax, and total calculation.

### 2.2 Good form

```ts
type OrderItem = {
  name: string;
  unitPrice: number;
  quantity: number;
};

type Order = {
  id: string;
  items: OrderItem[];
  discountRate: number;
  taxRate: number;
};

type OrderTotals = {
  subtotal: number;
  discount: number;
  tax: number;
  total: number;
};

function calculateOrderTotals(order: Order): OrderTotals {
  const subtotal = order.items.reduce(
    (sum, item) => sum + item.unitPrice * item.quantity,
    0
  );

  const discount = subtotal * order.discountRate;
  const taxableAmount = subtotal - discount;
  const tax = taxableAmount * order.taxRate;

  return {
    subtotal,
    discount,
    tax,
    total: taxableAmount + tax
  };
}

function formatMoney(amount: number): string {
  return `$${amount.toFixed(2)}`;
}

function renderWebReceipt(order: Order): string {
  const totals = calculateOrderTotals(order);

  return [
    `Order ${order.id}`,
    `Subtotal: ${formatMoney(totals.subtotal)}`,
    `Discount: ${formatMoney(totals.discount)}`,
    `Tax: ${formatMoney(totals.tax)}`,
    `Total: ${formatMoney(totals.total)}`
  ].join("\n");
}

function renderEmailReceipt(order: Order): string {
  const totals = calculateOrderTotals(order);

  return [
    `Thank you for your order ${order.id}.`,
    `Subtotal: ${formatMoney(totals.subtotal)}`,
    `Discount: ${formatMoney(totals.discount)}`,
    `Tax: ${formatMoney(totals.tax)}`,
    `Total charged: ${formatMoney(totals.total)}`
  ].join("\n");
}

const order: Order = {
  id: "A100",
  discountRate: 0.1,
  taxRate: 0.08,
  items: [
    { name: "Notebook", unitPrice: 12, quantity: 2 },
    { name: "Pen", unitPrice: 3, quantity: 4 }
  ]
};

console.log(renderWebReceipt(order));
console.log(renderEmailReceipt(order));
```

### 2.3 Less maintainable form

```ts
type OrderItem = {
  name: string;
  unitPrice: number;
  quantity: number;
};

type Order = {
  id: string;
  items: OrderItem[];
  discountRate: number;
  taxRate: number;
};

function formatMoney(amount: number): string {
  return `$${amount.toFixed(2)}`;
}

function renderWebReceipt(order: Order): string {
  const subtotal = order.items.reduce(
    (sum, item) => sum + item.unitPrice * item.quantity,
    0
  );

  const discount = subtotal * order.discountRate;
  const taxableAmount = subtotal - discount;
  const tax = taxableAmount * order.taxRate;
  const total = taxableAmount + tax;

  return [
    `Order ${order.id}`,
    `Subtotal: ${formatMoney(subtotal)}`,
    `Discount: ${formatMoney(discount)}`,
    `Tax: ${formatMoney(tax)}`,
    `Total: ${formatMoney(total)}`
  ].join("\n");
}

function renderEmailReceipt(order: Order): string {
  const subtotal = order.items.reduce(
    (sum, item) => sum + item.unitPrice * item.quantity,
    0
  );

  const discount = subtotal * order.discountRate;
  const taxableAmount = subtotal - discount;
  const tax = taxableAmount * order.taxRate;
  const total = taxableAmount + tax;

  return [
    `Thank you for your order ${order.id}.`,
    `Subtotal: ${formatMoney(subtotal)}`,
    `Discount: ${formatMoney(discount)}`,
    `Tax: ${formatMoney(tax)}`,
    `Total charged: ${formatMoney(total)}`
  ].join("\n");
}

const order: Order = {
  id: "A100",
  discountRate: 0.1,
  taxRate: 0.08,
  items: [
    { name: "Notebook", unitPrice: 12, quantity: 2 },
    { name: "Pen", unitPrice: 3, quantity: 4 }
  ]
};

console.log(renderWebReceipt(order));
console.log(renderEmailReceipt(order));
```

### 2.4 Why this difference matters

In the good form, the pricing rule has one authoritative implementation in `calculateOrderTotals`. The receipt functions only decide how to present the result. If the tax rule, discount rule, or rounding policy changes, there is one calculation to inspect and edit.

In the less maintainable form, the same calculation is copied into both receipt functions. A future change must be applied to every copy, and any missed or slightly different edit can make the web and email receipts disagree.

### 2.5 Structural references

```text
Good: receiptTotalCents > shared line-total calculation
Less maintainable: emailReceiptTotalCents and printableReceiptTotalCents > copied line-total calculation
```

The relevant structural difference is that the good form gives the repeated calculation its own function, while the less maintainable form embeds the same calculation separately inside each receipt-rendering function.

## 3. Boundaries and distinctions

Duplicate Code does not apply to every repeated token or similar-looking line. Repetition is usually harmless when it is declarative, very small, generated, or intentionally duplicated to keep unrelated modules independent. The smell is strongest when multiple copies represent the same business rule or algorithm and are likely to change together.

The less maintainable form can be acceptable as a temporary step while exploring code, when the duplication is trivial and unlikely to change, or when removing it would create an abstraction that is harder to understand than the repetition.

Extract Function is a common refactoring used to remove Duplicate Code by moving repeated logic into a named function. Pull Up Method is a related refactoring for duplicated behavior across related types, where the shared method is moved to a common parent. Duplicate Code is the smell; Extract Function and Pull Up Method are possible remedies depending on where the duplication occurs.
