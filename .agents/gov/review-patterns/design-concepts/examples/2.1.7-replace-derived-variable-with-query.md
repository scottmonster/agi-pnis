# Replace Derived Variable with Query

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.7
- **Aliases:** None
- **Definition:** Compute a value from its sources rather than storing and manually maintaining a duplicate. It prevents the local representation from going stale.
- **Why it matters:** It reduces the number of places that must be updated when state changes, making the code easier to read, reason about, and safely modify.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A shopping cart stores line items with prices and quantities. The cart needs to report its subtotal in cents.

### 2.2 Good form

```ts
type CartItem = {
  sku: string;
  unitPriceCents: number;
  quantity: number;
};

class ShoppingCart {
  private readonly items: CartItem[] = [];

  addItem(sku: string, unitPriceCents: number, quantity: number): void {
    this.items.push({ sku, unitPriceCents, quantity });
  }

  changeQuantity(sku: string, quantity: number): void {
    const item = this.items.find((candidate) => candidate.sku === sku);
    if (!item) {
      throw new Error(`Item not found: ${sku}`);
    }

    item.quantity = quantity;
  }

  get subtotalCents(): number {
    return this.items.reduce(
      (total, item) => total + item.unitPriceCents * item.quantity,
      0,
    );
  }
}

const cart = new ShoppingCart();
cart.addItem("COFFEE", 1299, 2);
cart.changeQuantity("COFFEE", 3);

console.log(cart.subtotalCents);
```

### 2.3 Less maintainable form

```ts
type CartItem = {
  sku: string;
  unitPriceCents: number;
  quantity: number;
};

class ShoppingCart {
  private readonly items: CartItem[] = [];
  private subtotalCentsValue = 0;

  addItem(sku: string, unitPriceCents: number, quantity: number): void {
    this.items.push({ sku, unitPriceCents, quantity });
    this.subtotalCentsValue += unitPriceCents * quantity;
  }

  changeQuantity(sku: string, quantity: number): void {
    const item = this.items.find((candidate) => candidate.sku === sku);
    if (!item) {
      throw new Error(`Item not found: ${sku}`);
    }

    this.subtotalCentsValue -= item.unitPriceCents * item.quantity;
    item.quantity = quantity;
    this.subtotalCentsValue += item.unitPriceCents * item.quantity;
  }

  get subtotalCents(): number {
    return this.subtotalCentsValue;
  }
}

const cart = new ShoppingCart();
cart.addItem("COFFEE", 1299, 2);
cart.changeQuantity("COFFEE", 3);

console.log(cart.subtotalCents);
```

### 2.4 Why this difference matters

In the good form, `subtotalCents` has one source of truth: the current `items`. Any operation that changes an item automatically affects the subtotal because the subtotal is calculated when requested.

In the less maintainable form, `subtotalCentsValue` duplicates information already present in `items`. Every method that changes the cart must also remember to update the duplicate value correctly. Adding a future operation such as `removeItem`, `applyDiscount`, or `clear` creates another chance for the stored subtotal to become stale.

### 2.5 Structural references

```text
Good: shopping-cart > checkout > cart.ts > ShoppingCart.subtotalCents > computed subtotal
Less maintainable: shopping-cart > checkout > cart.ts > ShoppingCart.subtotalCents > stored subtotalCentsValue
```

The relevant structural difference is that the good form places the derived value behind a query that computes from `items`, while the less maintainable form stores a separate field that must be synchronized with `items`.

## 3. Boundaries and distinctions

This refactoring applies when a stored value can be reliably computed from other local state, and when recomputing it is clear and affordable enough for the use case.

The stored form can be appropriate when the value is expensive to compute, must be persisted as a historical snapshot, comes from an external system, or is intentionally cached with clear invalidation rules. In those cases, the field is not merely an accidental duplicate, or the performance tradeoff is explicit.

This concept is not about replacing every field with a getter. Source data such as `items`, `unitPriceCents`, and `quantity` should still be stored because they are not derived from other local fields. It is specifically about removing duplicate derived state, such as a subtotal that can be calculated from line items.
