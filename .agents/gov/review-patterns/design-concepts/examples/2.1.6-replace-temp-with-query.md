# Replace Temp with Query

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.6
- **Aliases:** None
- **Definition:** Replace a local temporary with a query that computes the value. It makes the derived concept reusable and can enable further extraction, when repeated calculation is acceptable.
- **Why it matters:** It gives a derived value a clear name at the query level, removes a local variable that can only be used in one place, and makes the calculation available to other functions without duplicating the formula.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An order summary calculates a subtotal and then applies a discount for large orders. The subtotal calculation is also useful when formatting the customer-facing receipt.

### 2.2 Good form

```ts
type LineItem = {
  name: string;
  unitPrice: number;
  quantity: number;
};

class Order {
  constructor(private readonly items: LineItem[]) {}

  total(): number {
    return this.subtotal() - this.discount();
  }

  receiptSummary(): string {
    return `Subtotal: $${this.subtotal().toFixed(2)}, total: $${this.total().toFixed(2)}`;
  }

  private subtotal(): number {
    return this.items.reduce(
      (sum, item) => sum + item.unitPrice * item.quantity,
      0
    );
  }

  private discount(): number {
    return this.subtotal() > 100 ? this.subtotal() * 0.1 : 0;
  }
}

const order = new Order([
  { name: "Keyboard", unitPrice: 60, quantity: 1 },
  { name: "Mouse", unitPrice: 30, quantity: 2 }
]);

console.log(order.receiptSummary());
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  name: string;
  unitPrice: number;
  quantity: number;
};

class Order {
  constructor(private readonly items: LineItem[]) {}

  total(): number {
    const subtotal = this.items.reduce(
      (sum, item) => sum + item.unitPrice * item.quantity,
      0
    );

    const discount = subtotal > 100 ? subtotal * 0.1 : 0;
    return subtotal - discount;
  }

  receiptSummary(): string {
    const subtotal = this.items.reduce(
      (sum, item) => sum + item.unitPrice * item.quantity,
      0
    );

    return `Subtotal: $${subtotal.toFixed(2)}, total: $${this.total().toFixed(2)}`;
  }
}

const order = new Order([
  { name: "Keyboard", unitPrice: 60, quantity: 1 },
  { name: "Mouse", unitPrice: 30, quantity: 2 }
]);

console.log(order.receiptSummary());
```

### 2.4 Why this difference matters

In the good form, the derived value `subtotal` is expressed as a query, so the calculation has one named home and can be reused by `total`, `discount`, and `receiptSummary`. This makes the code easier to read because callers can work with the concept `subtotal()` instead of the reduction formula. It also makes changes safer: if subtotal rules change, the formula changes in one place.

In the less maintainable form, `subtotal` is a local temporary inside each function that needs it. The name is useful only within that function, so other functions must repeat the calculation or introduce their own temporary. That duplication makes the derived concept harder to recognize and easier to update inconsistently.

### 2.5 Structural references

```text
Good: checkout-service > orders > order.ts > Order.subtotal > subtotal query
Less maintainable: checkout-service > orders > order.ts > Order.total > subtotal temporary
```

The relevant structural difference is that the good form moves the derived calculation from a function-local temporary into a reusable query on the same module-level type. The less maintainable form keeps the calculation embedded inside individual functions, so the structure hides the shared concept.

## 3. Boundaries and distinctions

Replace Temp with Query applies when a local temporary represents a derived value that can be recomputed safely and usefully named as a query. It is especially helpful before extracting methods, reusing a calculation, or making a function read more like a sequence of domain concepts.

The local temporary can be appropriate when the calculation is expensive, has side effects, depends on a moment-in-time value that must not be recomputed, or is only a short-lived intermediate with no useful meaning outside the immediate expression. In those cases, keeping the temporary can preserve performance, correctness, or clarity.

This refactoring is not the same as merely renaming a variable. The important change is moving the computation behind a query so the derived concept can be reused. It is also different from extracting a general helper for unrelated code: the query should represent a coherent value in the current object or module, not just hide arbitrary implementation details.
