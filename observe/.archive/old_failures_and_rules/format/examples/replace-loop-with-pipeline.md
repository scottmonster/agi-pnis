# Replace Loop with Pipeline

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.1.6
- **Aliases:** None
- **Definition:** Express a collection traversal as a sequence of collection transformations. Where the pipeline is clearer, it names selection, mapping, and aggregation instead of exposing loop bookkeeping.
- **Why it matters:** It makes the purpose of each traversal step easier to read by separating filtering, transformation, and aggregation into named collection operations instead of mixing them inside loop control and mutable state.
- **Related concepts:** Split Loop

## 2. Example

### 2.1 Scenario

An order reporting function calculates the total revenue from shipped priority orders. Cancelled orders and non-priority orders must be ignored.

### 2.2 Good form

```ts
type OrderStatus = "pending" | "shipped" | "cancelled";

type Order = {
  id: string;
  status: OrderStatus;
  priority: boolean;
  items: Array<{
    sku: string;
    quantity: number;
    unitPrice: number;
  }>;
};

function orderTotal(order: Order): number {
  return order.items.reduce(
    (sum, item) => sum + item.quantity * item.unitPrice,
    0
  );
}

export function shippedPriorityRevenue(orders: Order[]): number {
  return orders
    .filter((order) => order.status === "shipped")
    .filter((order) => order.priority)
    .map(orderTotal)
    .reduce((sum, total) => sum + total, 0);
}
```

### 2.3 Less maintainable form

```ts
type OrderStatus = "pending" | "shipped" | "cancelled";

type Order = {
  id: string;
  status: OrderStatus;
  priority: boolean;
  items: Array<{
    sku: string;
    quantity: number;
    unitPrice: number;
  }>;
};

export function shippedPriorityRevenue(orders: Order[]): number {
  let revenue = 0;

  for (const order of orders) {
    if (order.status === "shipped") {
      if (order.priority) {
        let orderTotal = 0;

        for (const item of order.items) {
          orderTotal += item.quantity * item.unitPrice;
        }

        revenue += orderTotal;
      }
    }
  }

  return revenue;
}
```

### 2.4 Why this difference matters

The pipeline version states the traversal as a sequence of collection transformations: select shipped orders, select priority orders, convert each order to a total, then aggregate the totals. The loop version preserves the same behavior, but the reader must separate loop mechanics, nested conditionals, temporary accumulation, and the business rule by inspection.

This makes the pipeline easier to change when the traversal changes. For example, adding another selection rule or changing the mapped value can usually be localized to one pipeline step instead of being woven into nested loop control.

### 2.5 Structural references

```text
Good: reporting-service > orders > revenueReport.ts > shippedPriorityRevenue > order pipeline
Less maintainable: reporting-service > orders > revenueReport.ts > shippedPriorityRevenue > loop with mutable accumulators
```

The structural difference is inside the function body: the good form represents the traversal as chained collection operations, while the less maintainable form represents it as explicit iteration with mutable intermediate totals.

## 3. Boundaries and distinctions

Replace Loop with Pipeline applies when a loop is primarily traversing a collection to filter, map, sort, group, or aggregate values, and when naming those steps through collection operations makes the intent clearer.

It does not apply automatically to every loop. A loop can be more appropriate when the traversal has complex control flow, early exits that are central to the logic, heavy mutation of external state, performance constraints that make intermediate arrays unacceptable, or side effects where a pipeline would hide important sequencing.

The less maintainable form may be acceptable when debugging low-level iteration, implementing a performance-critical hot path, or expressing logic that does not fit naturally into collection transformations.

This differs from Split Loop. Split Loop separates one loop that does multiple independent things into multiple loops. Replace Loop with Pipeline changes the representation of a traversal from explicit loop bookkeeping to a sequence of collection transformations. The two refactorings can work together, but they address different problems.
