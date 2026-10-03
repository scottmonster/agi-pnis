# Comments (as deodorant)

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.11
- **Aliases:** None
- **Definition:** A comment explains code whose structure could instead express the idea. The smell is not comments themselves, but comments that mask unclear code.
- **Why it matters:** Comments that restate unclear code add a second thing to maintain, can drift from the behavior, and make readers decode both the implementation and the explanation. Clear names and extracted functions keep the meaning in the executable structure.
- **Related concepts:** Extract Function, Rename Variable

## 2. Example

### 2.1 Scenario

An online store calculates the shipping charge for an order. Domestic orders of at least 50 USD ship free unless the customer has requested expedited delivery.

### 2.2 Good form

```ts
type ShippingSpeed = "standard" | "expedited";

interface Order {
  subtotalCents: number;
  destinationCountry: string;
  shippingSpeed: ShippingSpeed;
}

const STORE_COUNTRY = "US";
const FREE_SHIPPING_MINIMUM_CENTS = 5000;
const STANDARD_SHIPPING_CENTS = 799;
const EXPEDITED_SHIPPING_CENTS = 1999;

function isDomesticOrder(order: Order): boolean {
  return order.destinationCountry === STORE_COUNTRY;
}

function qualifiesForFreeStandardShipping(order: Order): boolean {
  return (
    isDomesticOrder(order) &&
    order.subtotalCents >= FREE_SHIPPING_MINIMUM_CENTS &&
    order.shippingSpeed === "standard"
  );
}

function calculateShippingCents(order: Order): number {
  if (qualifiesForFreeStandardShipping(order)) {
    return 0;
  }

  if (order.shippingSpeed === "expedited") {
    return EXPEDITED_SHIPPING_CENTS;
  }

  return STANDARD_SHIPPING_CENTS;
}
```

### 2.3 Less maintainable form

```ts
type ShippingSpeed = "standard" | "expedited";

interface Order {
  subtotalCents: number;
  destinationCountry: string;
  shippingSpeed: ShippingSpeed;
}

const STORE_COUNTRY = "US";
const FREE_SHIPPING_MINIMUM_CENTS = 5000;
const STANDARD_SHIPPING_CENTS = 799;
const EXPEDITED_SHIPPING_CENTS = 1999;

function calculateShippingCents(order: Order): number {
  // Free shipping applies only to domestic standard orders of at least $50.
  if (
    order.destinationCountry === STORE_COUNTRY &&
    order.subtotalCents >= FREE_SHIPPING_MINIMUM_CENTS &&
    order.shippingSpeed === "standard"
  ) {
    return 0;
  }

  // Expedited shipping costs more than regular shipping.
  if (order.shippingSpeed === "expedited") {
    return EXPEDITED_SHIPPING_CENTS;
  }

  return STANDARD_SHIPPING_CENTS;
}
```

### 2.4 Why this difference matters

In the good form, the business rule is expressed by names that are part of the code: `qualifiesForFreeStandardShipping` and `isDomesticOrder`. A reader can understand the policy at the call site and inspect the extracted functions only when they need the details.

In the less maintainable form, the comments explain what the condition means because the condition itself is doing too much work. If the rule changes, the comment and the condition must both be updated, and they can disagree.

### 2.5 Structural references

```text
Good: calculateShippingCents > qualifiesForFreeShipping
Less maintainable: calculateShippingCents > inline free-shipping condition comment
```

The good form gives the shipping rule its own named function. The less maintainable form leaves the rule embedded inside `calculateShippingCents` and uses a comment as a substitute for that missing structure.

## 3. Boundaries and distinctions

This smell does not mean all comments are bad. Comments are appropriate when they explain intent, constraints, tradeoffs, legal requirements, external system quirks, or non-obvious reasons that the code cannot express directly.

The less maintainable form can be acceptable as a short-term step while exploring unfamiliar logic, or when a comment records context that would be lost in code alone. It becomes a smell when the comment mainly translates unclear names, dense conditions, or poorly structured code.

This concept differs from **Extract Function** because Extract Function is one common refactoring used to remove the smell by giving a block of logic a name. It differs from **Rename Variable** because renaming is another possible fix when the problem is an unclear identifier rather than a missing function boundary.
