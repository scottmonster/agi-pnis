# State

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.19
- **Aliases:** None
- **Definition:** Delegate behavior that varies with an object's internal state to state-specific objects. It replaces scattered state conditionals with explicit state behavior.
- **Why it matters:** It makes state-dependent behavior easier to read and change by grouping each state's rules in one place instead of spreading conditional branches across many methods.
- **Related concepts:** Strategy

## 2. Example

### 2.1 Scenario

An ecommerce order can be paid, cancelled, or shipped depending on its current lifecycle status. Each action has different behavior in draft, paid, shipped, and cancelled states.

### 2.2 Good form

```ts
type OrderStatus = "draft" | "paid" | "shipped" | "cancelled";

interface OrderState {
  readonly status: OrderStatus;
  pay(order: Order): void;
  cancel(order: Order): void;
  ship(order: Order): void;
}

class Order {
  private state: OrderState;

  constructor() {
    this.state = new DraftOrderState();
  }

  get status(): OrderStatus {
    return this.state.status;
  }

  transitionTo(state: OrderState): void {
    this.state = state;
  }

  pay(): void {
    this.state.pay(this);
  }

  cancel(): void {
    this.state.cancel(this);
  }

  ship(): void {
    this.state.ship(this);
  }
}

class DraftOrderState implements OrderState {
  readonly status = "draft" as const;

  pay(order: Order): void {
    order.transitionTo(new PaidOrderState());
  }

  cancel(order: Order): void {
    order.transitionTo(new CancelledOrderState());
  }

  ship(): void {
    throw new Error("Cannot ship an unpaid order.");
  }
}

class PaidOrderState implements OrderState {
  readonly status = "paid" as const;

  pay(): void {
    throw new Error("Order is already paid.");
  }

  cancel(order: Order): void {
    order.transitionTo(new CancelledOrderState());
  }

  ship(order: Order): void {
    order.transitionTo(new ShippedOrderState());
  }
}

class ShippedOrderState implements OrderState {
  readonly status = "shipped" as const;

  pay(): void {
    throw new Error("Cannot pay for a shipped order.");
  }

  cancel(): void {
    throw new Error("Cannot cancel a shipped order.");
  }

  ship(): void {
    throw new Error("Order is already shipped.");
  }
}

class CancelledOrderState implements OrderState {
  readonly status = "cancelled" as const;

  pay(): void {
    throw new Error("Cannot pay for a cancelled order.");
  }

  cancel(): void {
    throw new Error("Order is already cancelled.");
  }

  ship(): void {
    throw new Error("Cannot ship a cancelled order.");
  }
}

const order = new Order();
order.pay();
order.ship();

console.log(order.status); // "shipped"
```

### 2.3 Less maintainable form

```ts
type OrderStatus = "draft" | "paid" | "shipped" | "cancelled";

class Order {
  private currentStatus: OrderStatus = "draft";

  get status(): OrderStatus {
    return this.currentStatus;
  }

  pay(): void {
    switch (this.currentStatus) {
      case "draft":
        this.currentStatus = "paid";
        return;
      case "paid":
        throw new Error("Order is already paid.");
      case "shipped":
        throw new Error("Cannot pay for a shipped order.");
      case "cancelled":
        throw new Error("Cannot pay for a cancelled order.");
    }
  }

  cancel(): void {
    switch (this.currentStatus) {
      case "draft":
      case "paid":
        this.currentStatus = "cancelled";
        return;
      case "shipped":
        throw new Error("Cannot cancel a shipped order.");
      case "cancelled":
        throw new Error("Order is already cancelled.");
    }
  }

  ship(): void {
    switch (this.currentStatus) {
      case "draft":
        throw new Error("Cannot ship an unpaid order.");
      case "paid":
        this.currentStatus = "shipped";
        return;
      case "shipped":
        throw new Error("Order is already shipped.");
      case "cancelled":
        throw new Error("Cannot ship a cancelled order.");
    }
  }
}

const order = new Order();
order.pay();
order.ship();

console.log(order.status); // "shipped"
```

### 2.4 Why this difference matters

In the good form, each state owns the behavior that is valid while the order is in that state. To understand what a paid order can do, you read `PaidOrderState` instead of scanning every method for `"paid"` branches. Adding a new state, such as `RefundedOrderState`, mostly means adding one new state object and defining its transitions, rather than editing every state-dependent method.

In the less maintainable form, the lifecycle rules are scattered across `pay`, `cancel`, and `ship`. Every new state or action requires checking multiple switch statements, which increases the chance of inconsistent transitions or missing branches.

### 2.5 Structural references

```text
Good: checkout-service > orders > order.ts > Order.pay > state
Less maintainable: checkout-service > orders > order.ts > Order.pay > currentStatus
```

The good structure routes behavior through a state object target, so state-specific behavior is located behind the delegated `state` reference. The less maintainable structure keeps only a status value target, so each function must inspect that value and implement its own state branching.

## 3. Boundaries and distinctions

State is useful when an object's behavior changes meaningfully across a lifecycle and those differences appear in several operations. It is less useful when there are only one or two simple conditionals, when the states are unlikely to grow, or when the status is just data with no behavior attached.

The less maintainable form can be appropriate for small, stable workflows where a switch statement is clearer than introducing several state classes. It can also be reasonable when all state-specific logic is intentionally centralized in one short function.

State differs from Strategy because State models an object's internal lifecycle and often changes the active behavior from inside the object as transitions occur. Strategy usually represents an interchangeable algorithm selected by a caller or configuration, and strategies do not necessarily represent lifecycle phases or transition to one another.
