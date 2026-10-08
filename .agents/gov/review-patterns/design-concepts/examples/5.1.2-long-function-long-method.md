# Long Function / Long Method

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.2
- **Aliases:** None
- **Definition:** A routine contains enough distinct activity that its purpose and structure are no longer visible as one unit. It makes change and review require excessive local context.
- **Why it matters:** Long routines force readers to hold many unrelated details in memory at once. This makes behavior harder to understand, increases the chance of accidental changes, and makes review slower because validation, calculation, persistence, and notification logic are mixed in one place.
- **Related concepts:** Extract Function

## 2. Example

### 2.1 Scenario

An order checkout service validates a cart, calculates totals, stores the order, and sends a confirmation email. Both examples preserve the same behavior.

### 2.2 Good form

```ts
type CartItem = {
  sku: string;
  name: string;
  quantity: number;
  unitPriceCents: number;
};

type Customer = {
  id: string;
  email: string;
  state: string;
  loyaltyLevel: "standard" | "gold";
};

type Order = {
  id: string;
  customerId: string;
  items: CartItem[];
  subtotalCents: number;
  discountCents: number;
  taxCents: number;
  totalCents: number;
};

const savedOrders: Order[] = [];
const sentEmails: string[] = [];

function submitOrder(customer: Customer, items: CartItem[]): Order {
  validateCart(items);

  const subtotalCents = calculateSubtotal(items);
  const discountCents = calculateDiscount(customer, subtotalCents);
  const taxableCents = subtotalCents - discountCents;
  const taxCents = calculateTax(customer.state, taxableCents);

  const order = createOrder(customer, items, subtotalCents, discountCents, taxCents);
  saveOrder(order);
  sendConfirmationEmail(customer, order);

  return order;
}

function validateCart(items: CartItem[]): void {
  if (items.length === 0) {
    throw new Error("Cannot submit an empty cart.");
  }

  for (const item of items) {
    if (item.quantity <= 0) {
      throw new Error(`Invalid quantity for ${item.sku}.`);
    }

    if (item.unitPriceCents < 0) {
      throw new Error(`Invalid price for ${item.sku}.`);
    }
  }
}

function calculateSubtotal(items: CartItem[]): number {
  return items.reduce(
    (total, item) => total + item.quantity * item.unitPriceCents,
    0
  );
}

function calculateDiscount(customer: Customer, subtotalCents: number): number {
  if (customer.loyaltyLevel === "gold" && subtotalCents >= 10_000) {
    return Math.round(subtotalCents * 0.1);
  }

  return 0;
}

function calculateTax(state: string, taxableCents: number): number {
  const taxRate = state === "CA" ? 0.0825 : 0.05;
  return Math.round(taxableCents * taxRate);
}

function createOrder(
  customer: Customer,
  items: CartItem[],
  subtotalCents: number,
  discountCents: number,
  taxCents: number
): Order {
  return {
    id: `order-${savedOrders.length + 1}`,
    customerId: customer.id,
    items: items.map((item) => ({ ...item })),
    subtotalCents,
    discountCents,
    taxCents,
    totalCents: subtotalCents - discountCents + taxCents
  };
}

function saveOrder(order: Order): void {
  savedOrders.push(order);
}

function sendConfirmationEmail(customer: Customer, order: Order): void {
  sentEmails.push(
    `To: ${customer.email}; Order ${order.id}; Total: ${order.totalCents}`
  );
}
```

### 2.3 Less maintainable form

```ts
type CartItem = {
  sku: string;
  name: string;
  quantity: number;
  unitPriceCents: number;
};

type Customer = {
  id: string;
  email: string;
  state: string;
  loyaltyLevel: "standard" | "gold";
};

type Order = {
  id: string;
  customerId: string;
  items: CartItem[];
  subtotalCents: number;
  discountCents: number;
  taxCents: number;
  totalCents: number;
};

const savedOrders: Order[] = [];
const sentEmails: string[] = [];

function submitOrder(customer: Customer, items: CartItem[]): Order {
  if (items.length === 0) {
    throw new Error("Cannot submit an empty cart.");
  }

  for (const item of items) {
    if (item.quantity <= 0) {
      throw new Error(`Invalid quantity for ${item.sku}.`);
    }

    if (item.unitPriceCents < 0) {
      throw new Error(`Invalid price for ${item.sku}.`);
    }
  }

  let subtotalCents = 0;
  for (const item of items) {
    subtotalCents += item.quantity * item.unitPriceCents;
  }

  let discountCents = 0;
  if (customer.loyaltyLevel === "gold" && subtotalCents >= 10_000) {
    discountCents = Math.round(subtotalCents * 0.1);
  }

  const taxableCents = subtotalCents - discountCents;

  let taxRate = 0.05;
  if (customer.state === "CA") {
    taxRate = 0.0825;
  }

  const taxCents = Math.round(taxableCents * taxRate);

  const copiedItems: CartItem[] = [];
  for (const item of items) {
    copiedItems.push({
      sku: item.sku,
      name: item.name,
      quantity: item.quantity,
      unitPriceCents: item.unitPriceCents
    });
  }

  const order: Order = {
    id: `order-${savedOrders.length + 1}`,
    customerId: customer.id,
    items: copiedItems,
    subtotalCents,
    discountCents,
    taxCents,
    totalCents: subtotalCents - discountCents + taxCents
  };

  savedOrders.push(order);

  sentEmails.push(
    `To: ${customer.email}; Order ${order.id}; Total: ${order.totalCents}`
  );

  return order;
}
```

### 2.4 Why this difference matters

The good form keeps `submitOrder` as a readable outline of the checkout workflow. Each distinct activity has a small function with a name that explains its purpose, so a reader can inspect validation, pricing, persistence, or notification only when needed.

The less maintainable form makes one routine carry every detail. To change tax rules, email content, discount behavior, or validation, a reviewer must scan through unrelated code and verify that nearby local variables and control flow are not accidentally affected.

### 2.5 Structural references

```text
Good: checkout-service > orders > checkout.ts > submitOrder > validateOrder and chargePayment calls
Less maintainable: checkout-service > orders > checkout.ts > submitOrder > inline validation, payment, persistence, and email statements
```

The relevant structural difference is that the good version gives the top-level function one coordinating role and moves distinct activities into named helper functions. The less maintainable version keeps all activities inside the same function body, so the function is the only visible unit of structure.

## 3. Boundaries and distinctions

A function is not long merely because it has many lines. A generated parser, a simple table of constant values, or a straight-line sequence that expresses one cohesive operation may be acceptable even when physically large.

The less maintainable form can be appropriate for a short-lived script, a small spike, or code that is about to be deleted, where extraction would add more ceremony than clarity. It can also be reasonable to delay extraction until repeated edits reveal stable boundaries.

Long Function / Long Method is about too many distinct activities hidden inside one routine. Extract Function is a common refactoring used to fix it by moving coherent parts into named routines. This differs from Duplicate Code, where the main problem is repeated logic, and from Large Class, where too many responsibilities accumulate at the type level rather than inside a single routine.
