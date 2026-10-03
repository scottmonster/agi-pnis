# Early Exit

## 1. Concept

- **Classification:** control-flow technique
- **Catalog identifier:** 1.1.2
- **Aliases:** None
- **Definition:** Return, break, or otherwise stop once the result is known or continuing is invalid. It removes unnecessary work and nesting; it is often the mechanism used by Guard Clauses.
- **Why it matters:** Early Exit keeps the main path of a function visible by handling terminal cases immediately. This reduces indentation, avoids carrying unnecessary state, and makes later changes less likely to disturb unrelated branches.
- **Related concepts:** Replace Control Flag with Break

## 2. Example

### 2.1 Scenario

A checkout service creates a shipping quote for a cart. Some cases have an immediate answer, such as an empty cart, a suspended customer, a digital-only cart, or an unsupported destination.

### 2.2 Good form

```ts
type CartItem = {
  name: string;
  weightKg: number;
  isDigital: boolean;
};

type Customer = {
  id: string;
  isSuspended: boolean;
};

type ShippingQuote = {
  available: boolean;
  priceCents: number;
  reason?: string;
};

const supportedCountries = new Set(["US", "CA", "GB"]);

function createShippingQuote(
  cart: CartItem[],
  customer: Customer,
  destinationCountry: string
): ShippingQuote {
  if (cart.length === 0) {
    return { available: false, priceCents: 0, reason: "Cart is empty" };
  }

  if (customer.isSuspended) {
    return { available: false, priceCents: 0, reason: "Customer account is suspended" };
  }

  if (cart.every((item) => item.isDigital)) {
    return { available: true, priceCents: 0, reason: "No physical shipping required" };
  }

  if (!supportedCountries.has(destinationCountry)) {
    return { available: false, priceCents: 0, reason: "Destination is not supported" };
  }

  const physicalWeightKg = cart
    .filter((item) => !item.isDigital)
    .reduce((total, item) => total + item.weightKg, 0);

  return {
    available: true,
    priceCents: 500 + physicalWeightKg * 120
  };
}
```

### 2.3 Less maintainable form

```ts
type CartItem = {
  name: string;
  weightKg: number;
  isDigital: boolean;
};

type Customer = {
  id: string;
  isSuspended: boolean;
};

type ShippingQuote = {
  available: boolean;
  priceCents: number;
  reason?: string;
};

const supportedCountries = new Set(["US", "CA", "GB"]);

function createShippingQuote(
  cart: CartItem[],
  customer: Customer,
  destinationCountry: string
): ShippingQuote {
  let quote: ShippingQuote;

  if (cart.length === 0) {
    quote = { available: false, priceCents: 0, reason: "Cart is empty" };
  } else {
    if (customer.isSuspended) {
      quote = { available: false, priceCents: 0, reason: "Customer account is suspended" };
    } else {
      if (cart.every((item) => item.isDigital)) {
        quote = { available: true, priceCents: 0, reason: "No physical shipping required" };
      } else {
        if (!supportedCountries.has(destinationCountry)) {
          quote = { available: false, priceCents: 0, reason: "Destination is not supported" };
        } else {
          const physicalWeightKg = cart
            .filter((item) => !item.isDigital)
            .reduce((total, item) => total + item.weightKg, 0);

          quote = {
            available: true,
            priceCents: 500 + physicalWeightKg * 120
          };
        }
      }
    }
  }

  return quote;
}
```

### 2.4 Why this difference matters

The good form stops as soon as each terminal result is known. The reader does not have to track a mutable `quote` variable through nested branches or mentally match each `else` to its condition. The normal quote calculation is left at the base indentation level, so adding another invalid case can be done by adding another early return without wrapping the existing logic.

### 2.5 Structural references

```text
Good: Shop API > checkout package > shipping.ts > createShippingQuote > early return at each terminal decision
Less maintainable: Shop API > checkout package > shipping.ts > createShippingQuote > nested branches around terminal decisions
```

The structural difference is the placement of exits inside the function. In the good form, terminal conditions end their own branch immediately. In the less maintainable form, all terminal conditions remain inside a single nested control structure until the final return.

## 3. Boundaries and distinctions

Early Exit applies when a function, loop, or operation can safely stop because the answer is already known or continuing would be invalid. It is most useful for validation failures, empty inputs, search success, authorization failures, unsupported states, and other terminal cases.

The less maintainable form can be appropriate when a single exit point is required by a specific framework, cleanup protocol, instrumentation rule, or language constraint. Even then, the code should avoid unnecessary nesting where possible.

Early Exit differs from Guard Clauses in scope. A guard clause is a common use of early exit near the start of a function to reject invalid or special cases. Early Exit is broader and also includes stopping from the middle of a loop with `break`, returning after a successful lookup, or exiting once further work cannot change the result.

Early Exit is also related to Replace Control Flag with Break. That refactoring removes a boolean flag used to keep a loop running and replaces it with a direct exit when the loop's purpose has been satisfied. Early Exit is the underlying control-flow idea, while Replace Control Flag with Break is a more specific refactoring.
