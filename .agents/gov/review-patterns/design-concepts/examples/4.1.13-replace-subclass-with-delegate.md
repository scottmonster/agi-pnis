# Replace Subclass with Delegate

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.13
- **Aliases:** None
- **Definition:** Replace inheritance used for one varying part with delegation to a component. It can localize variation and avoid an artificial hierarchy.
- **Why it matters:** It makes the varying behavior explicit as a separate component, so readers can understand what changes without navigating an inheritance hierarchy. It also makes future changes easier because new variations can be added or swapped without creating more subclasses of the main domain object.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An order system supports standard and express shipping. The order data and subtotal logic are the same, but shipping cost and delivery estimate vary by shipping option.

### 2.2 Good form

```ts
type LineItem = {
  name: string;
  quantity: number;
  unitPriceCents: number;
};

type ShippingQuote = {
  shippingCostCents: number;
  estimatedDays: number;
};

interface ShippingPolicy {
  quoteFor(subtotalCents: number): ShippingQuote;
}

class StandardShippingPolicy implements ShippingPolicy {
  quoteFor(subtotalCents: number): ShippingQuote {
    return {
      shippingCostCents: subtotalCents >= 5000 ? 0 : 599,
      estimatedDays: 5,
    };
  }
}

class ExpressShippingPolicy implements ShippingPolicy {
  quoteFor(subtotalCents: number): ShippingQuote {
    return {
      shippingCostCents: 1499,
      estimatedDays: 2,
    };
  }
}

class Order {
  constructor(
    private readonly items: LineItem[],
    private readonly shippingPolicy: ShippingPolicy,
  ) {}

  subtotalCents(): number {
    return this.items.reduce(
      (total, item) => total + item.quantity * item.unitPriceCents,
      0,
    );
  }

  shippingQuote(): ShippingQuote {
    return this.shippingPolicy.quoteFor(this.subtotalCents());
  }

  totalCents(): number {
    return this.subtotalCents() + this.shippingQuote().shippingCostCents;
  }
}

const items: LineItem[] = [
  { name: "Keyboard", quantity: 1, unitPriceCents: 4500 },
  { name: "Cable", quantity: 2, unitPriceCents: 750 },
];

const standardOrder = new Order(items, new StandardShippingPolicy());
const expressOrder = new Order(items, new ExpressShippingPolicy());

console.log(standardOrder.totalCents());
console.log(expressOrder.totalCents());
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  name: string;
  quantity: number;
  unitPriceCents: number;
};

type ShippingQuote = {
  shippingCostCents: number;
  estimatedDays: number;
};

abstract class Order {
  constructor(private readonly items: LineItem[]) {}

  subtotalCents(): number {
    return this.items.reduce(
      (total, item) => total + item.quantity * item.unitPriceCents,
      0,
    );
  }

  abstract shippingQuote(): ShippingQuote;

  totalCents(): number {
    return this.subtotalCents() + this.shippingQuote().shippingCostCents;
  }
}

class StandardOrder extends Order {
  shippingQuote(): ShippingQuote {
    return {
      shippingCostCents: this.subtotalCents() >= 5000 ? 0 : 599,
      estimatedDays: 5,
    };
  }
}

class ExpressOrder extends Order {
  shippingQuote(): ShippingQuote {
    return {
      shippingCostCents: 1499,
      estimatedDays: 2,
    };
  }
}

const items: LineItem[] = [
  { name: "Keyboard", quantity: 1, unitPriceCents: 4500 },
  { name: "Cable", quantity: 2, unitPriceCents: 750 },
];

const standardOrder = new StandardOrder(items);
const expressOrder = new ExpressOrder(items);

console.log(standardOrder.totalCents());
console.log(expressOrder.totalCents());
```

### 2.4 Why this difference matters

In the good form, `Order` owns the stable order behavior, while shipping variation is localized in `ShippingPolicy` objects. A reader can see that the only interchangeable part is shipping, not the entire order type. Adding a new shipping option, such as overnight shipping, means adding another policy implementation and passing it to `Order`.

In the less maintainable form, each shipping option becomes a subclass of `Order`, even though the subclass exists only to vary shipping. That makes the hierarchy imply that standard and express orders are fundamentally different kinds of orders, when they are really the same order with a different component.

### 2.5 Structural references

```text
Good: Order.shippingQuote > ShippingPolicy.quoteFor
Less maintainable: ExpressOrder.shippingQuote > overridden shipping quote method
```

Good: the target variation is reached through a delegated shipping policy selected by the function that creates or uses the order. Less maintainable: the target variation is embedded in subclass overrides, so the function must choose a different order subtype to get different shipping behavior.

## 3. Boundaries and distinctions

Replace Subclass with Delegate does not apply just because subclasses exist. If each subclass represents a stable, meaningful kind with substantial behavior and identity beyond one varying feature, inheritance may still be appropriate.

The less maintainable form can be acceptable when the subtype relationship is central to the model and clients genuinely need polymorphic order types. For example, if `InternationalOrder` has different validation, tax rules, customs data, lifecycle states, and fulfillment behavior, a subclass or separate type may be clearer than a single delegated component.

This refactoring is closely related to the Strategy pattern, but they are not the same thing. Strategy describes a design shape where interchangeable behavior is represented by an object. Replace Subclass with Delegate is the refactoring move that changes an inheritance-based design into a delegation-based one, often producing a Strategy-like result.
