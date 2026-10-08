# Change Function Declaration

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.2.1
- **Aliases:** change signature, rename function/method, add or remove parameter
- **Definition:** Deliberately change a function's name, visibility, parameters, or result to make its contract fit its responsibility. Clear contracts make every call easier to read and change.
- **Why it matters:** A function declaration is the contract every caller must understand. A precise name, explicit parameter shape, and clear result reduce guessing at call sites and make later changes safer.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing service creates an invoice charge for a customer. The same behavior is easier to maintain when the function declaration names the responsibility and groups the required inputs clearly.

### 2.2 Good form

```ts
type Currency = "USD" | "EUR";

type InvoiceChargeRequest = {
  customerId: string;
  amountCents: number;
  currency: Currency;
  expedited: boolean;
};

type InvoiceCharge = {
  customerId: string;
  amountCents: number;
  currency: Currency;
  processingFeeCents: number;
  totalCents: number;
};

function createInvoiceCharge(request: InvoiceChargeRequest): InvoiceCharge {
  const processingFeeCents = request.expedited ? 500 : 100;

  return {
    customerId: request.customerId,
    amountCents: request.amountCents,
    currency: request.currency,
    processingFeeCents,
    totalCents: request.amountCents + processingFeeCents,
  };
}

const charge = createInvoiceCharge({
  customerId: "cus_42",
  amountCents: 12500,
  currency: "USD",
  expedited: true,
});

console.log(charge.totalCents);
```

### 2.3 Less maintainable form

```ts
type InvoiceCharge = {
  customerId: string;
  amountCents: number;
  currency: string;
  processingFeeCents: number;
  totalCents: number;
};

function charge(id: string, amount: number, curr: string, fast: boolean): InvoiceCharge {
  const processingFeeCents = fast ? 500 : 100;

  return {
    customerId: id,
    amountCents: amount,
    currency: curr,
    processingFeeCents,
    totalCents: amount + processingFeeCents,
  };
}

const invoiceCharge = charge("cus_42", 12500, "USD", true);

console.log(invoiceCharge.totalCents);
```

### 2.4 Why this difference matters

The good form changes the function declaration so the contract matches the responsibility: `createInvoiceCharge` says what the function does, `InvoiceChargeRequest` names each input, and `Currency` restricts valid currency values. Callers no longer need to remember positional argument order or infer that `amount` means cents and `fast` means expedited processing. If another input is needed later, the request object can be extended with less risk of breaking or misordering existing calls.

### 2.5 Structural references

```text
Good: billing-service > billing > invoiceCharges.ts > createInvoiceCharge > declaration
Less maintainable: billing-service > billing > invoiceCharges.ts > charge > declaration
```

The relevant structural difference is the function declaration: the good form exposes a specific name and a named request object, while the less maintainable form exposes a vague name and several positional parameters.

## 3. Boundaries and distinctions

Change Function Declaration applies when the intended behavior remains the same but the function contract becomes clearer or better aligned with its responsibility. It does not apply when the main change is adding new business behavior, rewriting the algorithm, or moving code without changing the callable contract.

The less maintainable form can be acceptable for very small private helpers with obvious arguments, generated code, or compatibility layers that must preserve an external API. In those cases, changing the declaration may create more disruption than clarity.

This refactoring differs from changing a call site only: the central change is to the function's declared contract, then callers are updated to match. It also differs from extracting a function, which creates a new function boundary; Change Function Declaration improves an existing boundary.
