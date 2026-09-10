# Linear Flow / Happy Path

## 1. Concept

- **Classification:** control-flow technique
- **Catalog identifier:** 1.1.3
- **Aliases:** None
- **Definition:** Arrange the ordinary sequence as the visually dominant, mostly straight-line path and move exceptional handling aside. It reduces the reader's need to reconstruct the usual case.
- **Why it matters:** It lets readers identify the usual behavior quickly, because validation failures and exceptional outcomes do not visually bury the main sequence of work.
- **Related concepts:** Guard Clauses

## 2. Example

### 2.1 Scenario

A checkout service approves an order only when it exists, is not already paid, has items, and its payment is authorized. Otherwise it returns the appropriate rejection result.

### 2.2 Good form

```ts
type OrderStatus = "draft" | "paid";

interface Order {
  id: string;
  status: OrderStatus;
  itemCount: number;
  totalCents: number;
}

interface PaymentGateway {
  authorize(orderId: string, amountCents: number): boolean;
}

type ApprovalResult =
  | { approved: true; confirmationCode: string }
  | { approved: false; reason: string };

function createConfirmationCode(order: Order): string {
  return `CONF-${order.id}`;
}

function approveOrder(
  order: Order | null,
  paymentGateway: PaymentGateway
): ApprovalResult {
  if (order === null) {
    return { approved: false, reason: "Order not found" };
  }

  if (order.status === "paid") {
    return { approved: false, reason: "Order already paid" };
  }

  if (order.itemCount === 0) {
    return { approved: false, reason: "Order has no items" };
  }

  const authorized = paymentGateway.authorize(order.id, order.totalCents);
  if (!authorized) {
    return { approved: false, reason: "Payment was declined" };
  }

  return {
    approved: true,
    confirmationCode: createConfirmationCode(order)
  };
}
```

### 2.3 Less maintainable form

```ts
type OrderStatus = "draft" | "paid";

interface Order {
  id: string;
  status: OrderStatus;
  itemCount: number;
  totalCents: number;
}

interface PaymentGateway {
  authorize(orderId: string, amountCents: number): boolean;
}

type ApprovalResult =
  | { approved: true; confirmationCode: string }
  | { approved: false; reason: string };

function createConfirmationCode(order: Order): string {
  return `CONF-${order.id}`;
}

function approveOrder(
  order: Order | null,
  paymentGateway: PaymentGateway
): ApprovalResult {
  let result: ApprovalResult;

  if (order !== null) {
    if (order.status !== "paid") {
      if (order.itemCount > 0) {
        const authorized = paymentGateway.authorize(order.id, order.totalCents);

        if (authorized) {
          result = {
            approved: true,
            confirmationCode: createConfirmationCode(order)
          };
        } else {
          result = { approved: false, reason: "Payment was declined" };
        }
      } else {
        result = { approved: false, reason: "Order has no items" };
      }
    } else {
      result = { approved: false, reason: "Order already paid" };
    }
  } else {
    result = { approved: false, reason: "Order not found" };
  }

  return result;
}
```

### 2.4 Why this difference matters

The good form makes the ordinary approval sequence visually dominant: validate disqualifying cases, authorize payment, then return the success result. Each exceptional case exits immediately, so the reader does not have to track nested conditions to discover what happens in the normal case.

The less maintainable form preserves the same behavior, but the success path is buried inside several levels of indentation. To understand the ordinary flow, the reader must mentally invert conditions such as `order !== null`, `order.status !== "paid"`, and `order.itemCount > 0`, then match each `else` branch to its condition.

### 2.5 Structural references

```text
Good: checkout-service > orders > checkout.ts > approveOrder > dominant success path
Less maintainable: checkout-service > orders > checkout.ts > approveOrder > nested success path
```

The structural difference is inside the same function: the good form keeps the success path at the outer indentation level after guard exits, while the less maintainable form places the same path inside nested conditional blocks.

## 3. Boundaries and distinctions

Linear Flow / Happy Path applies when there is a clear ordinary case and several early disqualifying or exceptional cases. It is most useful when those exceptional cases can be handled locally with returns, throws, or other simple exits.

The less maintainable nested form can be appropriate when branches are genuinely symmetrical alternatives rather than exceptions. For example, a decision table, parser, or state machine may need to show several peer paths rather than one dominant path.

This concept is closely related to Guard Clauses, but they are not identical. Guard Clauses are one technique for moving exceptional handling aside with early exits. Linear Flow / Happy Path is the broader readability goal: making the usual sequence of work easy to see as a mostly straight-line path.
