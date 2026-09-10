# Global Data

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.8
- **Aliases:** None
- **Definition:** State is reachable from broadly unrelated code. Its readers and writers are difficult to find, making effects and changes nonlocal.
- **Why it matters:** Global data makes behavior harder to read and change because any unrelated code can read or modify the state. A local change can affect distant execution paths, so maintainers must search broadly to understand cause and effect.
- **Related concepts:** Singleton, Encapsulate Variable

## 2. Example

### 2.1 Scenario

An online store calculates an order total using a tax rate and an optional free-shipping threshold. Different checkout flows need to use the same pricing rules without allowing unrelated code to silently change them.

### 2.2 Good form

```ts
type LineItem = {
  name: string;
  unitPriceCents: number;
  quantity: number;
};

type PricingSettings = {
  taxRate: number;
  freeShippingThresholdCents: number;
  standardShippingCents: number;
};

type OrderTotal = {
  subtotalCents: number;
  taxCents: number;
  shippingCents: number;
  totalCents: number;
};

function calculateOrderTotal(
  items: LineItem[],
  settings: PricingSettings
): OrderTotal {
  const subtotalCents = items.reduce(
    (sum, item) => sum + item.unitPriceCents * item.quantity,
    0
  );

  const taxCents = Math.round(subtotalCents * settings.taxRate);
  const shippingCents =
    subtotalCents >= settings.freeShippingThresholdCents
      ? 0
      : settings.standardShippingCents;

  return {
    subtotalCents,
    taxCents,
    shippingCents,
    totalCents: subtotalCents + taxCents + shippingCents
  };
}

const pricingSettings: PricingSettings = {
  taxRate: 0.0825,
  freeShippingThresholdCents: 5000,
  standardShippingCents: 799
};

const cart: LineItem[] = [
  { name: "Notebook", unitPriceCents: 1299, quantity: 2 },
  { name: "Pen", unitPriceCents: 299, quantity: 3 }
];

const total = calculateOrderTotal(cart, pricingSettings);
console.log(total);
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  name: string;
  unitPriceCents: number;
  quantity: number;
};

type OrderTotal = {
  subtotalCents: number;
  taxCents: number;
  shippingCents: number;
  totalCents: number;
};

let taxRate = 0.0825;
let freeShippingThresholdCents = 5000;
let standardShippingCents = 799;

function applyHolidayShippingPromotion(): void {
  freeShippingThresholdCents = 2500;
}

function calculateOrderTotal(items: LineItem[]): OrderTotal {
  const subtotalCents = items.reduce(
    (sum, item) => sum + item.unitPriceCents * item.quantity,
    0
  );

  const taxCents = Math.round(subtotalCents * taxRate);
  const shippingCents =
    subtotalCents >= freeShippingThresholdCents ? 0 : standardShippingCents;

  return {
    subtotalCents,
    taxCents,
    shippingCents,
    totalCents: subtotalCents + taxCents + shippingCents
  };
}

const cart: LineItem[] = [
  { name: "Notebook", unitPriceCents: 1299, quantity: 4 },
  { name: "Pen", unitPriceCents: 299, quantity: 3 }
];

applyHolidayShippingPromotion();

const total = calculateOrderTotal(cart);
console.log(total);
```

### 2.4 Why this difference matters

In the good form, the pricing state needed by `calculateOrderTotal` is explicit in the function signature. A reader can see which data affects the result, and a caller can choose the correct settings for the checkout flow.

In the less maintainable form, `taxRate`, `freeShippingThresholdCents`, and `standardShippingCents` are reachable from broad module scope. `calculateOrderTotal` depends on state that is not visible at the call site, and `applyHolidayShippingPromotion` can change future totals without touching the calculation call. The effect is nonlocal: understanding one order total requires finding every possible reader and writer of the shared variables.

### 2.5 Structural references

```text
Good: store > checkout > totals.ts > calculateOrderTotal > settings: PricingSettings
Less maintainable: store > checkout > totals.ts > module scope > freeShippingThresholdCents and standardShippingCents
```

The relevant structural difference is where the mutable pricing state is reachable. In the good form, it is passed into the function that needs it. In the less maintainable form, it lives at module scope, so unrelated functions in the same file can read or change it without that dependency appearing in the calculation function signature.

## 3. Boundaries and distinctions

Global Data applies when state is broadly reachable and can influence behavior from outside the immediate code being read. It does not apply to immutable constants, such as fixed conversion factors or enum-like values, when they cannot be changed at runtime and have no hidden write paths.

A less maintainable global form may be acceptable for small scripts, process-wide constants, or infrastructure state that is deliberately centralized and tightly controlled. Even then, access should usually be limited through a narrow API so readers and writers are easy to find.

Global Data is related to Singleton but not identical. A Singleton is a design pattern that restricts a type to one instance; it becomes a Global Data smell when that instance exposes shared mutable state to unrelated code. Encapsulate Variable is a refactoring that can reduce this smell by hiding direct access behind functions or methods, making reads and writes easier to control and locate.
