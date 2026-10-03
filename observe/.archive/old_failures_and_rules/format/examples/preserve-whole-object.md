# Preserve Whole Object

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.2.7
- **Aliases:** None
- **Definition:** Pass the object that owns a cluster of values instead of repeatedly extracting and passing individual values. It reduces argument noise when the callee genuinely operates on that object's information.
- **Why it matters:** It keeps related data grouped at the call site, making the code easier to read and reducing the number of places that must change when the callee needs another value from the same object.
- **Related concepts:** Long Parameter List

## 2. Example

### 2.1 Scenario

A checkout service calculates an order total by adding a shipping quote. The shipping calculation needs several values that all belong to the same `Order`.

### 2.2 Good form

```ts
type Address = {
  country: string;
  postalCode: string;
};

type Order = {
  subtotalCents: number;
  destination: Address;
  expedited: boolean;
};

function quoteShipping(order: Order): number {
  const baseShippingCents = order.destination.country === "US" ? 799 : 2499;
  const expeditedSurchargeCents = order.expedited ? 1299 : 0;
  const freeDomesticShippingDiscountCents =
    order.subtotalCents >= 10000 && order.destination.country === "US"
      ? baseShippingCents
      : 0;

  return baseShippingCents + expeditedSurchargeCents - freeDomesticShippingDiscountCents;
}

function totalCheckoutCents(order: Order): number {
  return order.subtotalCents + quoteShipping(order);
}

const order: Order = {
  subtotalCents: 12500,
  destination: {
    country: "US",
    postalCode: "94105",
  },
  expedited: true,
};

console.log(totalCheckoutCents(order));
```

### 2.3 Less maintainable form

```ts
type Address = {
  country: string;
  postalCode: string;
};

type Order = {
  subtotalCents: number;
  destination: Address;
  expedited: boolean;
};

function quoteShipping(
  subtotalCents: number,
  destinationCountry: string,
  expedited: boolean,
): number {
  const baseShippingCents = destinationCountry === "US" ? 799 : 2499;
  const expeditedSurchargeCents = expedited ? 1299 : 0;
  const freeDomesticShippingDiscountCents =
    subtotalCents >= 10000 && destinationCountry === "US" ? baseShippingCents : 0;

  return baseShippingCents + expeditedSurchargeCents - freeDomesticShippingDiscountCents;
}

function totalCheckoutCents(order: Order): number {
  return (
    order.subtotalCents +
    quoteShipping(order.subtotalCents, order.destination.country, order.expedited)
  );
}

const order: Order = {
  subtotalCents: 12500,
  destination: {
    country: "US",
    postalCode: "94105",
  },
  expedited: true,
};

console.log(totalCheckoutCents(order));
```

### 2.4 Why this difference matters

In the good form, `quoteShipping` receives the `Order`, which is the object that owns the values needed for the calculation. The call site communicates "quote shipping for this order" instead of listing the individual pieces of the order. If shipping later needs `postalCode`, the good form can change inside `quoteShipping` without changing every caller that already has an `Order`.

In the less maintainable form, the caller must know which pieces of `Order` the shipping calculation needs and pass them in the correct order. That spreads knowledge of the calculation's data requirements across callers and makes the parameter list grow as more order data is needed.

### 2.5 Structural references

```text
Good: checkout-service > shipping > shippingQuote.ts > quoteShipping > order parameter
Less maintainable: checkout-service > shipping > shippingQuote.ts > quoteShipping > extracted scalar parameters
```

The relevant structural difference is the function boundary: the good form has one parameter representing the whole owning object, while the less maintainable form has multiple scalar parameters extracted from that same object before the call.

## 3. Boundaries and distinctions

Preserve Whole Object applies when the callee genuinely works with information from the object as a coherent source. It should not be used just to shorten a parameter list if the callee only needs one simple value, or if passing the whole object creates an inappropriate dependency on a larger domain type.

The less maintainable form can be appropriate at system boundaries, public APIs, logging, serialization, privacy-sensitive code, or other places where exposing the whole object would leak data or couple the callee to more structure than it should know.

This refactoring is related to Long Parameter List because it often reduces a long list of arguments. The distinction is that Preserve Whole Object specifically replaces several values extracted from the same existing object with that object itself. If the values come from unrelated sources, Introduce Parameter Object may be a better fit.
