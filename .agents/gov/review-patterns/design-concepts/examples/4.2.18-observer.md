# Observer

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.18
- **Aliases:** None
- **Definition:** Let dependents subscribe to state changes from a subject. It decouples publishers and listeners, while making event order and lifetime important.
- **Why it matters:** Observer makes change propagation explicit: readers can see where listeners register, when they are notified, and how they are removed. This improves maintainability when adding, replacing, or disabling reactions to state changes without editing the subject.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An inventory service tracks product stock. When stock changes, the application updates a product page and sends a low-stock alert.

### 2.2 Good form

```ts
type StockEvent = {
  sku: string;
  quantity: number;
};

type StockListener = (event: StockEvent) => void;

class Inventory {
  private quantities = new Map<string, number>();
  private listeners = new Set<StockListener>();

  subscribe(listener: StockListener): () => void {
    this.listeners.add(listener);

    return () => {
      this.listeners.delete(listener);
    };
  }

  setStock(sku: string, quantity: number): void {
    this.quantities.set(sku, quantity);
    this.notify({ sku, quantity });
  }

  private notify(event: StockEvent): void {
    for (const listener of this.listeners) {
      listener(event);
    }
  }
}

class ProductPage {
  updateStockLabel(event: StockEvent): void {
    console.log(`Product ${event.sku}: ${event.quantity} left`);
  }
}

class LowStockAlerts {
  sendIfNeeded(event: StockEvent): void {
    if (event.quantity <= 3) {
      console.log(`Low stock alert for ${event.sku}`);
    }
  }
}

const inventory = new Inventory();
const productPage = new ProductPage();
const alerts = new LowStockAlerts();

const unsubscribePage = inventory.subscribe((event) => {
  productPage.updateStockLabel(event);
});

inventory.subscribe((event) => {
  alerts.sendIfNeeded(event);
});

inventory.setStock("SKU-123", 2);

unsubscribePage();
inventory.setStock("SKU-123", 10);
```

### 2.3 Less maintainable form

```ts
type StockEvent = {
  sku: string;
  quantity: number;
};

class ProductPage {
  updateStockLabel(event: StockEvent): void {
    console.log(`Product ${event.sku}: ${event.quantity} left`);
  }
}

class LowStockAlerts {
  sendIfNeeded(event: StockEvent): void {
    if (event.quantity <= 3) {
      console.log(`Low stock alert for ${event.sku}`);
    }
  }
}

class Inventory {
  private quantities = new Map<string, number>();

  constructor(
    private readonly productPage: ProductPage,
    private readonly alerts: LowStockAlerts
  ) {}

  setStock(sku: string, quantity: number, updatePage: boolean): void {
    this.quantities.set(sku, quantity);

    const event = { sku, quantity };

    if (updatePage) {
      this.productPage.updateStockLabel(event);
    }

    this.alerts.sendIfNeeded(event);
  }
}

const productPage = new ProductPage();
const alerts = new LowStockAlerts();
const inventory = new Inventory(productPage, alerts);

inventory.setStock("SKU-123", 2, true);
inventory.setStock("SKU-123", 10, false);
```

### 2.4 Why this difference matters

In the good form, `Inventory` only owns stock state and publishes a `StockEvent` to registered listeners. `ProductPage` and `LowStockAlerts` can be added, removed, tested, or replaced without changing `Inventory`.

In the less maintainable form, `Inventory` directly knows every reaction to a stock change. Adding another reaction requires editing the subject, and listener lifetime becomes an ad hoc flag such as `updatePage` instead of a clear subscription and unsubscription mechanism.

### 2.5 Structural references

```text
Good: inventory-app > stock > inventory.ts > Inventory.subscribe > listeners
Less maintainable: inventory-app > stock > inventory.ts > setStock > productPage.updateStockLabel and alerts.sendIfNeeded
```

The relevant structural difference is that the good form stores dependents behind a listener collection owned by the subject, while the less maintainable form embeds concrete dependent calls inside the state-changing function.

## 3. Boundaries and distinctions

Observer is useful when one subject has multiple independent dependents that should react to state changes, especially when those dependents vary at runtime.

It may not be needed when there is only one fixed reaction, when call order must be a simple direct sequence, or when the subject and dependent are intentionally part of the same small module. The less maintainable form can be appropriate for tiny code paths where indirection would obscure a straightforward operation.

Observer is not the same as polling: polling asks dependents to repeatedly check state, while Observer pushes changes to them. It is also not just a callback parameter: a callback usually handles one operation, while Observer manages a set of subscribers over a subject's lifetime. Event order, duplicate subscriptions, error handling, and unsubscribe behavior should be considered because they affect how safely the pattern behaves in real systems.
