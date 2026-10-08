# Arrow Code / Arrowhead

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 1.3.1
- **Aliases:** None
- **Definition:** Successive nested conditions push code to the right in an arrow shape. The reader must retain every enclosing condition; flattening or extraction can help.
- **Why it matters:** Arrow code makes the main path hard to find because each line depends on all enclosing conditions. Flattening the flow reduces indentation, makes failure cases explicit, and makes later changes less likely to break hidden assumptions.
- **Related concepts:** Deep Nesting, Guard Clauses

## 2. Example

### 2.1 Scenario

A checkout service submits an order only when the order exists, has items, has a paid invoice, and can be reserved in inventory. Otherwise, it returns a specific rejection reason.

### 2.2 Good form

```ts
type Order = {
  id: string;
  items: string[];
  invoicePaid: boolean;
};

type SubmissionResult =
  | { status: "submitted"; orderId: string }
  | { status: "rejected"; reason: string };

function reserveInventory(order: Order): boolean {
  return order.items.every((item) => item.length > 0);
}

function submitOrder(order: Order | null): SubmissionResult {
  if (order === null) {
    return { status: "rejected", reason: "Order was not found" };
  }

  if (order.items.length === 0) {
    return { status: "rejected", reason: "Order has no items" };
  }

  if (!order.invoicePaid) {
    return { status: "rejected", reason: "Invoice is not paid" };
  }

  if (!reserveInventory(order)) {
    return { status: "rejected", reason: "Inventory could not be reserved" };
  }

  return { status: "submitted", orderId: order.id };
}
```

### 2.3 Less maintainable form

```ts
type Order = {
  id: string;
  items: string[];
  invoicePaid: boolean;
};

type SubmissionResult =
  | { status: "submitted"; orderId: string }
  | { status: "rejected"; reason: string };

function reserveInventory(order: Order): boolean {
  return order.items.every((item) => item.length > 0);
}

function submitOrder(order: Order | null): SubmissionResult {
  let result: SubmissionResult;

  if (order !== null) {
    if (order.items.length > 0) {
      if (order.invoicePaid) {
        if (reserveInventory(order)) {
          result = { status: "submitted", orderId: order.id };
        } else {
          result = { status: "rejected", reason: "Inventory could not be reserved" };
        }
      } else {
        result = { status: "rejected", reason: "Invoice is not paid" };
      }
    } else {
      result = { status: "rejected", reason: "Order has no items" };
    }
  } else {
    result = { status: "rejected", reason: "Order was not found" };
  }

  return result;
}
```

### 2.4 Why this difference matters

The good form handles each rejecting condition immediately, so the successful path stays at the outer indentation level. A reader can verify one rule at a time and then continue, without carrying the meaning of every surrounding `if`. In the less maintainable form, the actual submission is buried inside several nested conditions, so adding another rule or changing one rejection path requires navigating the whole arrow-shaped block.

### 2.5 Structural references

```text
Good: checkout-service > orders > submitOrder.ts > submitOrder > guard clauses
Less maintainable: checkout-service > orders > submitOrder.ts > submitOrder > nested conditional chain
```

The relevant structural difference is inside the function body: the good version represents validation as a flat sequence of exits, while the less maintainable version represents the same decisions as a growing nested conditional chain.

## 3. Boundaries and distinctions

Arrow code is about control flow that repeatedly nests conditions and pushes the important work to the right. It does not apply to every use of nesting: a small nested block can be clear when the inner operation is truly subordinate to the outer condition.

The less maintainable form may be acceptable for very short code where the nested relationship is the main idea and unlikely to grow. It can also be appropriate when a language or framework requires a nested callback shape, though extraction can often still help.

Arrow code is closely related to Deep Nesting, but the emphasis is different. Deep Nesting describes the structural depth; Arrow Code describes the visual and cognitive effect of successive conditional nesting. Guard Clauses are a common refactoring that fixes arrow code by returning early for invalid or exceptional cases, keeping the main path flat.
