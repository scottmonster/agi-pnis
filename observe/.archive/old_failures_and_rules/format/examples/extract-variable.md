# Extract Variable

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.3
- **Aliases:** introduce explaining variable
- **Definition:** Bind part of an expression to a meaningful local name. It makes an intermediate idea visible, particularly in a condition or calculation.
- **Why it matters:** It turns hidden sub-expressions into named facts, making the code easier to read, review, debug, and change without altering behavior.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An order service decides whether a customer qualifies for free shipping. The rule depends on the order subtotal, customer loyalty tier, and whether the destination is domestic.

### 2.2 Good form

```ts
type LoyaltyTier = "standard" | "silver" | "gold";

interface Order {
  subtotalCents: number;
  destinationCountry: string;
  customer: {
    loyaltyTier: LoyaltyTier;
  };
}

function qualifiesForFreeShipping(order: Order): boolean {
  const isDomesticDestination = order.destinationCountry === "US";
  const meetsStandardThreshold = order.subtotalCents >= 7500;
  const meetsGoldThreshold = order.customer.loyaltyTier === "gold" && order.subtotalCents >= 5000;

  return isDomesticDestination && (meetsStandardThreshold || meetsGoldThreshold);
}

const order: Order = {
  subtotalCents: 6200,
  destinationCountry: "US",
  customer: {
    loyaltyTier: "gold"
  }
};

console.log(qualifiesForFreeShipping(order));
```

### 2.3 Less maintainable form

```ts
type LoyaltyTier = "standard" | "silver" | "gold";

interface Order {
  subtotalCents: number;
  destinationCountry: string;
  customer: {
    loyaltyTier: LoyaltyTier;
  };
}

function qualifiesForFreeShipping(order: Order): boolean {
  return order.destinationCountry === "US" &&
    (order.subtotalCents >= 7500 ||
      (order.customer.loyaltyTier === "gold" && order.subtotalCents >= 5000));
}

const order: Order = {
  subtotalCents: 6200,
  destinationCountry: "US",
  customer: {
    loyaltyTier: "gold"
  }
};

console.log(qualifiesForFreeShipping(order));
```

### 2.4 Why this difference matters

The good form gives names to the meaningful parts of the shipping rule: `isDomesticDestination`, `meetsStandardThreshold`, and `meetsGoldThreshold`. A reader can understand the business rule before inspecting the exact comparisons. If the gold threshold changes, or if the domestic rule becomes more complex, the relevant part has a clear place to change.

The less maintainable form preserves the same behavior, but the reader must mentally parse nested boolean logic to discover the intermediate ideas.

### 2.5 Structural references

```text
Good: order-service > shipping > shipping.ts > qualifiesForFreeShipping > extracted local variables
Less maintainable: order-service > shipping > shipping.ts > qualifiesForFreeShipping > inline boolean expression
```

The structural difference is inside the function body: the good form introduces local variables for meaningful sub-expressions, while the less maintainable form leaves those sub-expressions embedded directly in the return statement.

## 3. Boundaries and distinctions

Extract Variable applies when part of an expression represents a meaningful intermediate idea. It is most useful for complex conditions, calculations, chained calls, or repeated sub-expressions.

It may not be worth applying when the expression is already obvious, such as `return priceCents > 0;`, or when the name would merely restate the code without adding meaning, such as `const isGreaterThanZero = priceCents > 0;`.

The less maintainable form can be appropriate for very short expressions where introducing a name would add noise. Extract Variable should also not be used to hide side effects behind a harmless-sounding name.

Extract Variable differs from extracting a function: Extract Variable names an intermediate value inside the current scope, while extracting a function moves logic into a separate callable unit.
