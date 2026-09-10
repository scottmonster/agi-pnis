# Guard Clauses

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.1.1
- **Aliases:** replace nested conditional with guard clauses
- **Definition:** Handle exceptional or invalid cases at the start, leaving the normal path flat. It makes the dominant path visible and reduces nesting.
- **Why it matters:** Guard clauses make preconditions and exceptional cases explicit before the main logic begins, so readers can see the normal path without mentally tracking nested branches.
- **Related concepts:** Early Exit

## 2. Example

### 2.1 Scenario

A support system determines whether an agent can issue a refund for an order. Refunds are allowed only for paid orders, within 30 days, and only when the requested amount does not exceed the amount paid.

### 2.2 Good form

```ts
type OrderStatus = "draft" | "paid" | "refunded" | "cancelled";

interface Order {
  id: string;
  status: OrderStatus;
  paidAt: Date | null;
  amountPaidCents: number;
}

interface RefundRequest {
  order: Order;
  amountCents: number;
  requestedAt: Date;
}

interface RefundDecision {
  approved: boolean;
  reason: string;
}

const REFUND_WINDOW_DAYS = 30;
const MS_PER_DAY = 24 * 60 * 60 * 1000;

function daysBetween(start: Date, end: Date): number {
  return Math.floor((end.getTime() - start.getTime()) / MS_PER_DAY);
}

function decideRefund(request: RefundRequest): RefundDecision {
  const { order, amountCents, requestedAt } = request;

  if (order.status !== "paid") {
    return { approved: false, reason: "Order is not paid." };
  }

  if (order.paidAt === null) {
    return { approved: false, reason: "Order has no payment date." };
  }

  if (daysBetween(order.paidAt, requestedAt) > REFUND_WINDOW_DAYS) {
    return { approved: false, reason: "Refund window has expired." };
  }

  if (amountCents <= 0) {
    return { approved: false, reason: "Refund amount must be positive." };
  }

  if (amountCents > order.amountPaidCents) {
    return { approved: false, reason: "Refund amount exceeds amount paid." };
  }

  return { approved: true, reason: "Refund approved." };
}
```

### 2.3 Less maintainable form

```ts
type OrderStatus = "draft" | "paid" | "refunded" | "cancelled";

interface Order {
  id: string;
  status: OrderStatus;
  paidAt: Date | null;
  amountPaidCents: number;
}

interface RefundRequest {
  order: Order;
  amountCents: number;
  requestedAt: Date;
}

interface RefundDecision {
  approved: boolean;
  reason: string;
}

const REFUND_WINDOW_DAYS = 30;
const MS_PER_DAY = 24 * 60 * 60 * 1000;

function daysBetween(start: Date, end: Date): number {
  return Math.floor((end.getTime() - start.getTime()) / MS_PER_DAY);
}

function decideRefund(request: RefundRequest): RefundDecision {
  const { order, amountCents, requestedAt } = request;

  if (order.status === "paid") {
    if (order.paidAt !== null) {
      if (daysBetween(order.paidAt, requestedAt) <= REFUND_WINDOW_DAYS) {
        if (amountCents > 0) {
          if (amountCents <= order.amountPaidCents) {
            return { approved: true, reason: "Refund approved." };
          }

          return { approved: false, reason: "Refund amount exceeds amount paid." };
        }

        return { approved: false, reason: "Refund amount must be positive." };
      }

      return { approved: false, reason: "Refund window has expired." };
    }

    return { approved: false, reason: "Order has no payment date." };
  }

  return { approved: false, reason: "Order is not paid." };
}
```

### 2.4 Why this difference matters

The good form checks each invalid or exceptional case immediately and returns as soon as that case is known. After those guards, the remaining code is the successful refund path, so the reader does not need to keep a stack of conditions in mind. Adding another precondition, such as "agent must have refund permission", can be done as another guard near the top without increasing indentation around the normal case.

### 2.5 Structural references

```text
Good: checkout-service > refunds > refund-decision.ts > decideRefund > guard clauses
Less maintainable: checkout-service > refunds > refund-decision.ts > decideRefund > nested conditional
```

The structural difference is inside the same function: the good form keeps invalid cases as top-level checks, while the less maintainable form embeds the successful path inside multiple conditional levels.

## 3. Boundaries and distinctions

Guard clauses fit best when a function has clear preconditions, invalid inputs, exceptional states, or simple disqualifying cases. They are less useful when all branches are equally important alternatives in a business decision, where a balanced conditional, lookup table, strategy, or pattern matching style may communicate intent better.

The nested form can be appropriate when a condition truly defines a scope that several related operations must share, especially if returning early would split a single cohesive operation into scattered exits. Guard clauses should also not hide required cleanup; if resources must be released, use language constructs such as `try`/`finally` or scoped resource management.

Guard Clauses are related to Early Exit, but they are more specific. Early Exit is the general act of leaving a function, loop, or block before its end. Guard Clauses are early exits used at the start of a function or block to reject invalid, exceptional, or non-applicable cases so the dominant path remains flat.
