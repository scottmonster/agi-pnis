# Introduce Assertion

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.2.7
- **Aliases:** None
- **Definition:** State an assumption that the surrounding code relies on. It documents a local invariant and makes violations easier to find, but it is not input validation.
- **Why it matters:** Assertions make hidden assumptions explicit at the point where later code depends on them, improving readability and making broken invariants fail near their cause.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An invoicing function calculates a final charge after a promotion has already been selected by earlier pricing rules. The function assumes the selected promotion never exceeds the subtotal.

### 2.2 Good form

```ts
type InvoiceLine = {
  description: string;
  quantity: number;
  unitPriceCents: number;
};

type Promotion = {
  code: string;
  discountCents: number;
};

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function calculateSubtotalCents(lines: InvoiceLine[]): number {
  return lines.reduce(
    (total, line) => total + line.quantity * line.unitPriceCents,
    0
  );
}

function calculateInvoiceTotalCents(
  lines: InvoiceLine[],
  promotion: Promotion | null,
  taxRate: number
): number {
  const subtotalCents = calculateSubtotalCents(lines);
  const discountCents = promotion?.discountCents ?? 0;

  assert(
    discountCents <= subtotalCents,
    "pricing invariant violated: promotion discount exceeds subtotal"
  );

  const taxableCents = subtotalCents - discountCents;
  const taxCents = Math.round(taxableCents * taxRate);

  return taxableCents + taxCents;
}
```

### 2.3 Less maintainable form

```ts
type InvoiceLine = {
  description: string;
  quantity: number;
  unitPriceCents: number;
};

type Promotion = {
  code: string;
  discountCents: number;
};

function calculateSubtotalCents(lines: InvoiceLine[]): number {
  return lines.reduce(
    (total, line) => total + line.quantity * line.unitPriceCents,
    0
  );
}

function calculateInvoiceTotalCents(
  lines: InvoiceLine[],
  promotion: Promotion | null,
  taxRate: number
): number {
  const subtotalCents = calculateSubtotalCents(lines);
  const discountCents = promotion?.discountCents ?? 0;

  const taxableCents = subtotalCents - discountCents;
  const taxCents = Math.round(taxableCents * taxRate);

  return taxableCents + taxCents;
}
```

### 2.4 Why this difference matters

The good form states the invariant that the following calculation relies on: the taxable amount must not become negative because a promotion exceeded the subtotal. A reader does not have to infer that assumption from arithmetic several lines later. If an upstream pricing rule breaks the assumption, the assertion fails at the boundary where the invariant is needed, rather than allowing a surprising negative taxable amount to flow through later calculations.

### 2.5 Structural references

```text
Good: billing-service > pricing > invoice.ts > calculateInvoiceTotalCents > assertion of pricing invariant
Less maintainable: billing-service > pricing > invoice.ts > calculateInvoiceTotalCents > implicit pricing invariant
```

The structural difference is that the good form has an explicit assertion inside the function immediately before the code that depends on the invariant. The less maintainable form has the same dependency, but the invariant exists only implicitly in the arithmetic.

## 3. Boundaries and distinctions

Introduce Assertion applies when the code has a local assumption that should already be true if surrounding code is correct. It is not a substitute for input validation, authorization checks, parsing, or user-facing error handling. For example, if `promotion.discountCents` comes directly from an external request, the program should validate it and return an appropriate error instead of relying on an assertion.

The less maintainable form can be appropriate when the assumption is already guaranteed by a nearby type, a narrow domain model, or an immediately preceding validation step that makes the invariant obvious. Assertions should also be used carefully in runtime environments where they may be disabled or where throwing an internal error would be the wrong operational behavior.

This refactoring differs from adding a guard clause because a guard clause usually handles an expected alternative path, while an assertion documents a condition that must hold for the code to be correct. It also differs from tests because tests check behavior from outside the code path, while assertions document and check an invariant inside the code path itself.
