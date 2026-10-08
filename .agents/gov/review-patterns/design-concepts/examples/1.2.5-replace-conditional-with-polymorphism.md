# Replace Conditional with Polymorphism

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.2.5
- **Aliases:** None
- **Definition:** Move behavior selected repeatedly by type or variant into the corresponding implementations. It localizes each variant and removes distributed type tests.
- **Why it matters:** It makes variant-specific behavior easier to read and change because each variant owns its own rules. Adding or modifying a variant does not require finding and editing repeated conditionals spread across the codebase.
- **Related concepts:** Repeated Type Conditional, State, Strategy

## 2. Example

### 2.1 Scenario

An online store calculates shipping cost and delivery wording for the same set of shipping methods. Each method has its own pricing rule and customer-facing delivery estimate.

### 2.2 Good form

```ts
type Shipment = {
  weightKg: number;
  distanceKm: number;
};

interface ShippingMethod {
  calculateCost(shipment: Shipment): number;
  deliveryLabel(): string;
}

class StandardShipping implements ShippingMethod {
  calculateCost(shipment: Shipment): number {
    return 5 + shipment.weightKg * 0.5 + shipment.distanceKm * 0.02;
  }

  deliveryLabel(): string {
    return "Delivery in 5 to 7 business days";
  }
}

class ExpressShipping implements ShippingMethod {
  calculateCost(shipment: Shipment): number {
    return 12 + shipment.weightKg * 0.9 + shipment.distanceKm * 0.04;
  }

  deliveryLabel(): string {
    return "Delivery in 2 to 3 business days";
  }
}

class OvernightShipping implements ShippingMethod {
  calculateCost(shipment: Shipment): number {
    return 25 + shipment.weightKg * 1.4 + shipment.distanceKm * 0.08;
  }

  deliveryLabel(): string {
    return "Delivery by the next business day";
  }
}

function quoteShipment(shipment: Shipment, method: ShippingMethod): string {
  const cost = method.calculateCost(shipment).toFixed(2);
  return `${method.deliveryLabel()}: $${cost}`;
}

const shipment: Shipment = { weightKg: 3, distanceKm: 120 };
const quote = quoteShipment(shipment, new ExpressShipping());

console.log(quote);
```

### 2.3 Less maintainable form

```ts
type Shipment = {
  weightKg: number;
  distanceKm: number;
};

type ShippingMethodKind = "standard" | "express" | "overnight";

function calculateShippingCost(
  shipment: Shipment,
  method: ShippingMethodKind
): number {
  switch (method) {
    case "standard":
      return 5 + shipment.weightKg * 0.5 + shipment.distanceKm * 0.02;
    case "express":
      return 12 + shipment.weightKg * 0.9 + shipment.distanceKm * 0.04;
    case "overnight":
      return 25 + shipment.weightKg * 1.4 + shipment.distanceKm * 0.08;
  }
}

function deliveryLabel(method: ShippingMethodKind): string {
  switch (method) {
    case "standard":
      return "Delivery in 5 to 7 business days";
    case "express":
      return "Delivery in 2 to 3 business days";
    case "overnight":
      return "Delivery by the next business day";
  }
}

function quoteShipment(shipment: Shipment, method: ShippingMethodKind): string {
  const cost = calculateShippingCost(shipment, method).toFixed(2);
  return `${deliveryLabel(method)}: $${cost}`;
}

const shipment: Shipment = { weightKg: 3, distanceKm: 120 };
const quote = quoteShipment(shipment, "express");

console.log(quote);
```

### 2.4 Why this difference matters

In the good form, the decision about which behavior to run happens when the appropriate `ShippingMethod` implementation is selected. After that, callers use the common interface and do not need to test the method kind. The pricing rule and delivery label for `ExpressShipping` are in one place, so changing express shipping does not require editing multiple switches.

In the less maintainable form, every new shipping method must be added to each conditional that branches on `ShippingMethodKind`. If one switch is missed, the code can become inconsistent even though all branches represent the same conceptual variant.

### 2.5 Structural references

```text
Good: store > shipping > shipping-methods.ts > quoteShipment > ShippingMethod polymorphic calls
Less maintainable: store > shipping > shipping-methods.ts > calculateShippingCost and deliveryLabel > ShippingMethodKind switches
```

The relevant structural difference is that the good form routes behavior through a stable interface with variant-specific implementations, while the less maintainable form keeps variant behavior in repeated conditional branches keyed by the same type code.

## 3. Boundaries and distinctions

Replace Conditional with Polymorphism applies when the same type or variant check controls behavior in multiple places, or when a conditional is growing because each branch represents a stable domain variant. It is less useful for a one-time conditional, a simple guard clause, or logic where the conditions are incidental and do not represent substitutable variants.

The less maintainable form can be appropriate when the set of variants is tiny, the conditional is isolated, or the code is simpler as a direct branch than as several new implementations. It can also be reasonable when all behavior must be viewed together, such as a compact lookup table or a short serialization mapping.

This refactoring differs from **Repeated Type Conditional** because that term names the smell: repeated branching on the same type or variant. Replace Conditional with Polymorphism is the refactoring that can remove that smell. It differs from **State** because State uses polymorphic objects to represent changing behavior across an object's lifecycle. It differs from **Strategy** because Strategy usually means choosing an interchangeable algorithm intentionally, while Replace Conditional with Polymorphism is specifically about moving branch-selected behavior into the variants that own it.
