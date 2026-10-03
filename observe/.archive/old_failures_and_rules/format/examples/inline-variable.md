# Inline Variable

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.4
- **Aliases:** inline temp
- **Definition:** Replace a variable used only once with its expression. It removes a name that adds no concept and can expose the direct computation.
- **Why it matters:** It reduces unnecessary indirection, so the reader can see the computation at the point where its value is needed instead of tracking a short-lived name that does not add meaning.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing function calculates the monthly charge for a subscription based on seat count, price per seat, and a discount rate. The intermediate variable merely repeats the function's purpose and is used only once.

### 2.2 Good form

```ts
type Subscription = {
  seatCount: number;
  pricePerSeatCents: number;
  discountRate: number;
};

function monthlyChargeCents(subscription: Subscription): number {
  return Math.round(
    subscription.seatCount *
      subscription.pricePerSeatCents *
      (1 - subscription.discountRate)
  );
}
```

### 2.3 Less maintainable form

```ts
type Subscription = {
  seatCount: number;
  pricePerSeatCents: number;
  discountRate: number;
};

function monthlyChargeCents(subscription: Subscription): number {
  const charge = Math.round(
    subscription.seatCount *
      subscription.pricePerSeatCents *
      (1 - subscription.discountRate)
  );

  return charge;
}
```

### 2.4 Why this difference matters

In the good form, the returned value is visible directly as the calculation the function performs. In the less maintainable form, `charge` is a one-use variable whose name does not introduce a new domain concept beyond the function name `monthlyChargeCents`. The reader has to follow an extra binding from `return charge` back to the assignment without gaining additional understanding.

### 2.5 Structural references

```text
Good: billing-app > billing > subscription.ts > monthlyChargeCents > return expression
Less maintainable: billing-app > billing > subscription.ts > monthlyChargeCents > single-use charge variable
```

The relevant structural difference is that the good form places the calculation directly in the return expression, while the less maintainable form adds an unnecessary local variable between the calculation and its only use.

## 3. Boundaries and distinctions

Inline Variable applies when a local variable is used once and its name does not clarify the code. The less maintainable form can be appropriate when the variable name captures a meaningful domain concept, when the value is reused, when the expression is long enough that naming improves comprehension, or when the variable supports debugging or stepwise refactoring.

This is the opposite of extracting a variable: Extract Variable introduces a name to explain an expression, while Inline Variable removes a name that is not carrying useful meaning. It also differs from inlining a function, which replaces a function call with the function body rather than replacing a one-use local variable with its expression.
