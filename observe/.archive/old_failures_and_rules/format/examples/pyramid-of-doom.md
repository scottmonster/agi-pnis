# Pyramid of Doom

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 1.3.3
- **Aliases:** None
- **Definition:** Nested control constructs, especially callbacks, make later work depend on an increasingly indented chain of scopes. It obscures sequencing and error paths.
- **Why it matters:** Deep nesting makes the order of operations, failure handling, and future changes harder to see because each step is visually and structurally buried inside the previous one.
- **Related concepts:** Callback Hell

## 2. Example

### 2.1 Scenario

A checkout service loads an order, charges its payment method, marks the order as paid, and sends a receipt. Each step must happen only after the previous step succeeds.

### 2.2 Good form

```ts
type Order = {
  id: string;
  customerEmail: string;
  paymentMethodId: string;
};

type Charge = {
  id: string;
  amountCents: number;
};

const orders: Record<string, Order> = {
  "order-123": {
    id: "order-123",
    customerEmail: "customer@example.com",
    paymentMethodId: "pm-456",
  },
};

function loadOrder(orderId: string, callback: (error: Error | null, order?: Order) => void): void {
  const order = orders[orderId];

  if (!order) {
    callback(new Error(`Order not found: ${orderId}`));
    return;
  }

  callback(null, order);
}

function chargePayment(
  order: Order,
  callback: (error: Error | null, charge?: Charge) => void,
): void {
  callback(null, {
    id: "charge-789",
    amountCents: 4999,
  });
}

function markOrderPaid(
  orderId: string,
  chargeId: string,
  callback: (error: Error | null) => void,
): void {
  console.log(`Marked ${orderId} as paid with ${chargeId}`);
  callback(null);
}

function sendReceipt(
  email: string,
  charge: Charge,
  callback: (error: Error | null) => void,
): void {
  console.log(`Sent receipt for ${charge.id} to ${email}`);
  callback(null);
}

function loadOrderAsync(orderId: string): Promise<Order> {
  return new Promise((resolve, reject) => {
    loadOrder(orderId, (error, order) => {
      if (error) {
        reject(error);
        return;
      }

      if (!order) {
        reject(new Error("Order callback completed without an order"));
        return;
      }

      resolve(order);
    });
  });
}

function chargePaymentAsync(order: Order): Promise<Charge> {
  return new Promise((resolve, reject) => {
    chargePayment(order, (error, charge) => {
      if (error) {
        reject(error);
        return;
      }

      if (!charge) {
        reject(new Error("Payment callback completed without a charge"));
        return;
      }

      resolve(charge);
    });
  });
}

function markOrderPaidAsync(orderId: string, chargeId: string): Promise<void> {
  return new Promise((resolve, reject) => {
    markOrderPaid(orderId, chargeId, (error) => {
      if (error) {
        reject(error);
        return;
      }

      resolve();
    });
  });
}

function sendReceiptAsync(email: string, charge: Charge): Promise<void> {
  return new Promise((resolve, reject) => {
    sendReceipt(email, charge, (error) => {
      if (error) {
        reject(error);
        return;
      }

      resolve();
    });
  });
}

async function sendReceiptForPaidOrder(orderId: string): Promise<void> {
  const order = await loadOrderAsync(orderId);
  const charge = await chargePaymentAsync(order);

  await markOrderPaidAsync(order.id, charge.id);
  await sendReceiptAsync(order.customerEmail, charge);
}

sendReceiptForPaidOrder("order-123").catch((error) => {
  console.error(error.message);
});
```

### 2.3 Less maintainable form

```ts
type Order = {
  id: string;
  customerEmail: string;
  paymentMethodId: string;
};

type Charge = {
  id: string;
  amountCents: number;
};

const orders: Record<string, Order> = {
  "order-123": {
    id: "order-123",
    customerEmail: "customer@example.com",
    paymentMethodId: "pm-456",
  },
};

function loadOrder(orderId: string, callback: (error: Error | null, order?: Order) => void): void {
  const order = orders[orderId];

  if (!order) {
    callback(new Error(`Order not found: ${orderId}`));
    return;
  }

  callback(null, order);
}

function chargePayment(
  order: Order,
  callback: (error: Error | null, charge?: Charge) => void,
): void {
  callback(null, {
    id: "charge-789",
    amountCents: 4999,
  });
}

function markOrderPaid(
  orderId: string,
  chargeId: string,
  callback: (error: Error | null) => void,
): void {
  console.log(`Marked ${orderId} as paid with ${chargeId}`);
  callback(null);
}

function sendReceipt(
  email: string,
  charge: Charge,
  callback: (error: Error | null) => void,
): void {
  console.log(`Sent receipt for ${charge.id} to ${email}`);
  callback(null);
}

function sendReceiptForPaidOrderNested(orderId: string): void {
  loadOrder(orderId, (loadError, order) => {
    if (loadError) {
      console.error(loadError.message);
      return;
    }

    if (!order) {
      console.error("Order callback completed without an order");
      return;
    }

    chargePayment(order, (chargeError, charge) => {
      if (chargeError) {
        console.error(chargeError.message);
        return;
      }

      if (!charge) {
        console.error("Payment callback completed without a charge");
        return;
      }

      markOrderPaid(order.id, charge.id, (markError) => {
        if (markError) {
          console.error(markError.message);
          return;
        }

        sendReceipt(order.customerEmail, charge, (receiptError) => {
          if (receiptError) {
            console.error(receiptError.message);
            return;
          }
        });
      });
    });
  });
}

sendReceiptForPaidOrderNested("order-123");
```

### 2.4 Why this difference matters

The good form keeps the workflow at one indentation level inside `sendReceiptForPaidOrder`: load the order, charge it, mark it paid, then send the receipt. Each operation is still dependent on the previous one, but that dependency is expressed as a linear sequence instead of nested scopes.

The less maintainable form creates a pyramid: every later step is placed inside the callback of the previous step. As more steps or error cases are added, the important path moves farther right, local error handling is repeated, and changing the sequence requires editing multiple nested blocks.

### 2.5 Structural references

```text
Good: checkout-service > orders package > checkout.ts > sendReceiptForPaidOrder > sequential awaits
Less maintainable: checkout-service > orders package > checkout.ts > sendReceiptForPaidOrderNested > nested callback chain
```

The relevant structural difference is that the good form keeps the target workflow as a flat sequence within one function body, while the less maintainable form embeds the target workflow inside an increasingly deep callback chain.

## 3. Boundaries and distinctions

Pyramid of Doom does not apply to every nested block. A small `if` inside a loop, a short validation branch, or a nested expression can be acceptable when the structure remains easy to scan and the nesting does not hide the main sequence.

The less maintainable form may be appropriate for very small callback-based code, for APIs that cannot be converted to promises, or for event handlers where nesting represents a real containment relationship rather than a forced sequence of dependent steps. Even then, extraction, early returns, named functions, or promise wrappers can often reduce the pyramid.

Pyramid of Doom is closely related to Callback Hell, but they are not identical. Callback Hell usually refers specifically to excessive nested callbacks in asynchronous code. Pyramid of Doom is broader: it can come from callbacks, conditionals, loops, or other control constructs whenever later work is buried under an expanding chain of indentation.
