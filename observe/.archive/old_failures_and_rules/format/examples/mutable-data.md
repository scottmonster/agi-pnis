# Mutable Data

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.9
- **Aliases:** None
- **Definition:** State can be changed from multiple places without a narrow protocol. Readers must account for all potential writers and ordering.
- **Why it matters:** Mutable data makes code harder to read and change because a value seen in one line may have been altered by distant code before the next use. A narrow update protocol lets readers understand where changes can happen and what invariants are preserved.
- **Related concepts:** Encapsulate Collection, Value Object

## 2. Example

### 2.1 Scenario

A checkout service builds a shopping cart, applies one discount, and calculates the final total. The cart should preserve the invariant that quantities are positive and discounts are between 0 and 100 percent.

### 2.2 Good form

```ts
type CartLine = Readonly<{
  sku: string;
  unitPriceCents: number;
  quantity: number;
}>;

class Cart {
  private readonly linesBySku = new Map<string, CartLine>();
  private discountPercent = 0;

  addItem(sku: string, unitPriceCents: number, quantity: number): void {
    if (quantity <= 0) {
      throw new Error("Quantity must be positive.");
    }

    const existing = this.linesBySku.get(sku);
    const nextQuantity = (existing?.quantity ?? 0) + quantity;

    this.linesBySku.set(sku, {
      sku,
      unitPriceCents,
      quantity: nextQuantity,
    });
  }

  applyDiscount(percent: number): void {
    if (percent < 0 || percent > 100) {
      throw new Error("Discount must be between 0 and 100.");
    }

    this.discountPercent = percent;
  }

  lines(): readonly CartLine[] {
    return [...this.linesBySku.values()];
  }

  totalCents(): number {
    const subtotal = this.lines().reduce(
      (sum, line) => sum + line.unitPriceCents * line.quantity,
      0,
    );

    return Math.round(subtotal * (100 - this.discountPercent) / 100);
  }
}

function checkoutTotalCents(): number {
  const cart = new Cart();

  cart.addItem("COFFEE", 1200, 2);
  cart.applyDiscount(10);

  return cart.totalCents();
}
```

### 2.3 Less maintainable form

```ts
type CartLine = {
  sku: string;
  unitPriceCents: number;
  quantity: number;
};

type Cart = {
  lines: CartLine[];
  discountPercent: number;
};

function createCart(): Cart {
  return {
    lines: [],
    discountPercent: 0,
  };
}

function addItem(
  cart: Cart,
  sku: string,
  unitPriceCents: number,
  quantity: number,
): void {
  const existing = cart.lines.find((line) => line.sku === sku);

  if (existing) {
    existing.quantity += quantity;
    return;
  }

  cart.lines.push({ sku, unitPriceCents, quantity });
}

function applyDiscount(cart: Cart, percent: number): void {
  cart.discountPercent = percent;
}

function totalCents(cart: Cart): number {
  const subtotal = cart.lines.reduce(
    (sum, line) => sum + line.unitPriceCents * line.quantity,
    0,
  );

  return Math.round(subtotal * (100 - cart.discountPercent) / 100);
}

function checkoutTotalCents(): number {
  const cart = createCart();

  addItem(cart, "COFFEE", 1200, 2);
  applyDiscount(cart, 10);

  return totalCents(cart);
}
```

### 2.4 Why this difference matters

In the good form, the cart's mutable state is private and can only change through `addItem` and `applyDiscount`. Those methods enforce the cart's invariants, so a reader of `totalCents` only needs to understand that narrow protocol.

In the less maintainable form, `lines` and `discountPercent` are exposed as writable data. Any function with a `Cart` reference can push lines, replace the array, set a negative quantity, or overwrite the discount. A reader of `totalCents` must account for all possible writers and their ordering, not just the intended checkout steps.

### 2.5 Structural references

```text
Good: checkout > pricing > cart.ts > Cart.addItem > linesBySku
Less maintainable: checkout > pricing > cart.ts > applyDiscount > cart.lines and cart.discountPercent fields
```

The relevant structural difference is where writes are allowed. The good form routes all writes through a small set of functions that own the state. The less maintainable form exposes the state itself, so mutation can happen from any caller that receives the cart.

## 3. Boundaries and distinctions

Mutable data is not always a smell. Local mutation inside a short function is often clear, especially when the data does not escape. Private mutable state can also be appropriate when it is protected by a small API that preserves invariants.

The less maintainable form can be acceptable for simple data transfer objects, test fixtures, generated types, or performance-sensitive code where ownership is obvious and tightly scoped. It becomes a smell when shared state crosses module boundaries and many places can write to it.

Encapsulate Collection is a common refactoring for this smell: instead of exposing a mutable collection, provide intention-revealing methods such as `addItem` or `removeItem`. Value Object is a related design choice that avoids the issue by making values immutable and replacing them rather than changing them in place.
