# Replace Magic Literal with Symbolic Constant

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.8
- **Aliases:** replace magic number
- **Definition:** Replace an unexplained literal with a named constant. It exposes the value's meaning and gives future changes one named location.
- **Why it matters:** A named constant tells readers what a value represents without making them infer it from context. It also reduces change risk because the value can be updated in one named location instead of hunting for repeated literals that may or may not mean the same thing.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout service calculates the shipping charge for a cart. Orders at or above the store's free-shipping threshold should receive free shipping.

### 2.2 Good form

```ts
type Cart = {
  subtotalCents: number;
};

const FREE_SHIPPING_MINIMUM_CENTS = 5000;
const FREE_SHIPPING_CENTS = 0;
const STANDARD_SHIPPING_CENTS = 799;

export function calculateShippingCents(cart: Cart): number {
  if (cart.subtotalCents >= FREE_SHIPPING_MINIMUM_CENTS) {
    return FREE_SHIPPING_CENTS;
  }

  return STANDARD_SHIPPING_CENTS;
}
```

### 2.3 Less maintainable form

```ts
type Cart = {
  subtotalCents: number;
};

export function calculateShippingCents(cart: Cart): number {
  if (cart.subtotalCents >= 5000) {
    return 0;
  }

  return 799;
}
```

### 2.4 Why this difference matters

In the good form, `FREE_SHIPPING_MINIMUM_CENTS` explains that `5000` is a business threshold, not an arbitrary calculation detail. If the threshold changes, the change is made at the constant definition. In the less maintainable form, a reader must infer what `5000` means, and a later maintainer may miss another use of the same value or accidentally change an unrelated `5000` with a different meaning.

### 2.5 Structural references

```text
Good: checkout-service > checkout > shipping.ts > calculateShippingCents > FREE_SHIPPING_MINIMUM_CENTS
Less maintainable: checkout-service > checkout > shipping.ts > calculateShippingCents > 5000 literal
```

The structural difference is that the good form gives the domain value a named target in the file, while the less maintainable form embeds the raw literal directly inside the function logic.

## 3. Boundaries and distinctions

This refactoring applies when a literal has domain meaning that is not obvious from the literal itself, such as a tax rate, timeout, retry limit, status code, size limit, or business threshold.

The less maintainable form can be acceptable when the literal is conventional and self-evident in context, such as `0` for an empty count, `1` for incrementing by one, or `""` for an empty string. It can also be acceptable in very small tests where an inline literal makes the expected behavior clearer than introducing a distant name.

This differs from extracting a variable because a symbolic constant names a stable value whose meaning is independent of one temporary calculation. It also differs from runtime configuration: if operators or users must change the value without code changes, the value should usually come from configuration rather than from a source-code constant.
