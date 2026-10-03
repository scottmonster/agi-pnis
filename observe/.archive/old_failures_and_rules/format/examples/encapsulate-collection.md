# Encapsulate Collection

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.3
- **Aliases:** None
- **Definition:** Prevent clients from directly mutating a collection and provide controlled collection operations. It preserves collection invariants and makes mutation sites visible.
- **Why it matters:** It keeps collection rules close to the data they protect, so readers can understand how the collection changes without searching for arbitrary external mutations.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A shopping cart stores line items and must keep at most one item per SKU. Adding the same SKU again should increase its quantity instead of creating a duplicate line.

### 2.2 Good form

```ts
type CartItem = {
  readonly sku: string;
  readonly name: string;
  readonly unitPriceCents: number;
  readonly quantity: number;
};

class ShoppingCart {
  private readonly items: CartItem[] = [];

  getItems(): readonly CartItem[] {
    return this.items.map((item) => ({ ...item }));
  }

  addItem(sku: string, name: string, unitPriceCents: number, quantity: number): void {
    if (quantity <= 0) {
      throw new Error("Quantity must be positive.");
    }

    const existingIndex = this.items.findIndex((item) => item.sku === sku);

    if (existingIndex >= 0) {
      const existing = this.items[existingIndex];
      this.items[existingIndex] = {
        ...existing,
        quantity: existing.quantity + quantity,
      };
      return;
    }

    this.items.push({ sku, name, unitPriceCents, quantity });
  }

  removeItem(sku: string): void {
    const index = this.items.findIndex((item) => item.sku === sku);

    if (index >= 0) {
      this.items.splice(index, 1);
    }
  }

  totalCents(): number {
    return this.items.reduce(
      (total, item) => total + item.unitPriceCents * item.quantity,
      0,
    );
  }
}

const cart = new ShoppingCart();

cart.addItem("BK-101", "Refactoring", 4500, 1);
cart.addItem("BK-101", "Refactoring", 4500, 2);

console.log(cart.getItems());
console.log(cart.totalCents());
```

### 2.3 Less maintainable form

```ts
type CartItem = {
  sku: string;
  name: string;
  unitPriceCents: number;
  quantity: number;
};

class ShoppingCart {
  readonly items: CartItem[] = [];

  totalCents(): number {
    return this.items.reduce(
      (total, item) => total + item.unitPriceCents * item.quantity,
      0,
    );
  }
}

function addItemToCart(
  cart: ShoppingCart,
  sku: string,
  name: string,
  unitPriceCents: number,
  quantity: number,
): void {
  if (quantity <= 0) {
    throw new Error("Quantity must be positive.");
  }

  const existing = cart.items.find((item) => item.sku === sku);

  if (existing) {
    existing.quantity += quantity;
    return;
  }

  cart.items.push({ sku, name, unitPriceCents, quantity });
}

const cart = new ShoppingCart();

addItemToCart(cart, "BK-101", "Refactoring", 4500, 1);
addItemToCart(cart, "BK-101", "Refactoring", 4500, 2);

console.log(cart.items);
console.log(cart.totalCents());
```

### 2.4 Why this difference matters

In the good form, `ShoppingCart` owns its item collection and exposes only controlled operations such as `addItem`, `removeItem`, and `getItems`. That makes the one-item-per-SKU rule visible at the mutation point and prevents callers from bypassing validation by pushing directly into the array or changing item quantities in place.

In the less maintainable form, `items` is directly reachable. Even though `addItemToCart` currently preserves the intended behavior, any caller can still do `cart.items.push(...)`, mutate `quantity`, or create duplicate SKUs. The invariant is therefore a convention rather than something enforced by the object that owns the collection.

### 2.5 Structural references

```text
Good: checkout > cart > ShoppingCart.ts > addItem > items
Less maintainable: checkout > cart > ShoppingCart.ts > addItemToCart > cart.items
```

The relevant structural difference is where collection mutation is allowed. In the good form, writes to the collection are centralized behind methods on the owning module type. In the less maintainable form, external code can mutate the collection through a public array reference.

## 3. Boundaries and distinctions

Encapsulate Collection is useful when a collection has invariants, validation rules, lifecycle rules, or meaningful domain operations around mutation. It may not be necessary for a simple local array with no shared ownership, no invariants, and a short lifetime.

The less maintainable form can be acceptable for plain data transfer objects, test fixtures, small scripts, or intentionally mutable records where callers are expected to assemble data freely before handing it off.

This refactoring is specifically about controlling access to a collection. It is not just making a field private for style, nor is it the same as making data immutable everywhere. A collection may still be mutable internally, but mutation happens through explicit operations that preserve the owner object's rules.
