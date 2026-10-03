# Finite-State Machine (FSM)

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 1.2.10
- **Aliases:** None
- **Definition:** Represent legal states and transitions explicitly, rather than letting them emerge from dispersed flags and conditionals. It makes state-dependent behavior and invalid transitions inspectable.
- **Why it matters:** An FSM makes state-dependent behavior easier to read because the allowed states and transitions are visible in one structure. It improves maintainability by making new states, events, and invalid transitions explicit instead of spreading rules across nested conditionals and boolean flags.
- **Related concepts:** State, Repeated Type Conditional

## 2. Example

### 2.1 Scenario

An order in an online store can be paid, shipped, delivered, or canceled. The service must reject invalid transitions, such as shipping an order before payment.

### 2.2 Good form

```ts
type OrderState = "created" | "paid" | "shipped" | "delivered" | "canceled";
type OrderEvent = "pay" | "ship" | "deliver" | "cancel";

interface Order {
  id: string;
  state: OrderState;
}

const transitions: Record<OrderState, Partial<Record<OrderEvent, OrderState>>> = {
  created: {
    pay: "paid",
    cancel: "canceled",
  },
  paid: {
    ship: "shipped",
    cancel: "canceled",
  },
  shipped: {
    deliver: "delivered",
  },
  delivered: {},
  canceled: {},
};

function transitionOrder(order: Order, event: OrderEvent): Order {
  const nextState = transitions[order.state][event];

  if (!nextState) {
    throw new Error(`Cannot ${event} order ${order.id} while it is ${order.state}`);
  }

  return {
    ...order,
    state: nextState,
  };
}

const order: Order = { id: "ord_123", state: "created" };

const paidOrder = transitionOrder(order, "pay");
const shippedOrder = transitionOrder(paidOrder, "ship");
const deliveredOrder = transitionOrder(shippedOrder, "deliver");

console.log(deliveredOrder.state);
```

### 2.3 Less maintainable form

```ts
interface Order {
  id: string;
  isPaid: boolean;
  isShipped: boolean;
  isDelivered: boolean;
  isCanceled: boolean;
}

type OrderEvent = "pay" | "ship" | "deliver" | "cancel";

function currentOrderState(order: Order): string {
  if (order.isCanceled) {
    return "canceled";
  }

  if (order.isDelivered) {
    return "delivered";
  }

  if (order.isShipped) {
    return "shipped";
  }

  if (order.isPaid) {
    return "paid";
  }

  return "created";
}

function transitionOrder(order: Order, event: OrderEvent): Order {
  const state = currentOrderState(order);

  if (event === "pay") {
    if (state !== "created") {
      throw new Error(`Cannot pay order ${order.id} while it is ${state}`);
    }

    return {
      ...order,
      isPaid: true,
    };
  }

  if (event === "ship") {
    if (state !== "paid") {
      throw new Error(`Cannot ship order ${order.id} while it is ${state}`);
    }

    return {
      ...order,
      isShipped: true,
    };
  }

  if (event === "deliver") {
    if (state !== "shipped") {
      throw new Error(`Cannot deliver order ${order.id} while it is ${state}`);
    }

    return {
      ...order,
      isDelivered: true,
    };
  }

  if (event === "cancel") {
    if (state !== "created" && state !== "paid") {
      throw new Error(`Cannot cancel order ${order.id} while it is ${state}`);
    }

    return {
      ...order,
      isCanceled: true,
    };
  }

  throw new Error(`Unsupported event: ${event}`);
}

const order: Order = {
  id: "ord_123",
  isPaid: false,
  isShipped: false,
  isDelivered: false,
  isCanceled: false,
};

const paidOrder = transitionOrder(order, "pay");
const shippedOrder = transitionOrder(paidOrder, "ship");
const deliveredOrder = transitionOrder(shippedOrder, "deliver");

console.log(currentOrderState(deliveredOrder));
```

### 2.4 Why this difference matters

The good form names the legal states as a single state value and puts the transition rules in one table. A reader can inspect the whole lifecycle by looking at `transitions`, and invalid transitions are rejected by the absence of an entry.

The less maintainable form lets state emerge from several booleans and repeated conditionals. This makes invalid combinations possible, such as `isDelivered: true` and `isCanceled: true`, and forces each operation to reconstruct what state the order is in before deciding what is allowed. Adding a new state or event requires editing scattered branches instead of extending one explicit transition model.

### 2.5 Structural references

```text
Good: checkout-service > orders > orderState.ts > transitions
Less maintainable: checkout-service > orders > orderState.ts > transitionOrder > boolean flags and event branches
```

The structural difference is that the good form centralizes the state graph in one transition table, while the less maintainable form distributes the same state rules across multiple flags and conditional branches.

## 3. Boundaries and distinctions

An FSM is most useful when an object or process has a defined lifecycle, a finite set of states, and events that are only valid in certain states. It may be unnecessary for simple data with no lifecycle rules, or for a value that only has one independent boolean property.

The less maintainable form can be acceptable for very small, temporary code where there are only one or two states and no expectation that transitions will grow. It becomes risky when more flags, events, or invalid combinations appear.

An FSM differs from the State pattern in scope. An FSM is the explicit model of states and transitions. The State pattern is an object-oriented way to attach behavior to state-specific objects. An FSM can be implemented with a table, a switch, objects, or a library.

An FSM also differs from Repeated Type Conditional. Repeated Type Conditional describes scattered checks that branch on a type or state value in many places. An FSM can reduce that problem by making the allowed transitions explicit and centralized, but an FSM implementation can still become a repeated conditional if state rules are duplicated across many functions.
