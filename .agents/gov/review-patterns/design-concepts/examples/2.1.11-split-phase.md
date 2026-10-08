# Split Phase

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.11
- **Aliases:** None
- **Definition:** Separate processing that performs different conceptual jobs into distinct stages. It makes each stage's inputs, outputs, and reasoning model clearer.
- **Why it matters:** Split Phase makes code easier to read and change by separating different kinds of work, such as translating raw input and applying business rules. Each phase can be understood, tested, and modified with a clearer purpose.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout service receives raw cart data from an HTTP request and calculates the final amount owed. The raw request values must be normalized before pricing rules are applied.

### 2.2 Good form

```ts
type RawCheckoutRequest = {
  customerType?: string;
  items?: Array<{
    sku?: string;
    quantity?: string;
    unitPriceCents?: string;
  }>;
  couponCode?: string;
};

type PricingItem = {
  sku: string;
  quantity: number;
  unitPriceCents: number;
};

type PricingInput = {
  customerType: "standard" | "vip";
  items: PricingItem[];
  couponCode: string | null;
};

type Invoice = {
  subtotalCents: number;
  discountCents: number;
  totalCents: number;
};

function buildPricingInput(request: RawCheckoutRequest): PricingInput {
  return {
    customerType: request.customerType === "vip" ? "vip" : "standard",
    items: (request.items ?? []).map((item) => ({
      sku: item.sku ?? "unknown",
      quantity: Number(item.quantity ?? "0"),
      unitPriceCents: Number(item.unitPriceCents ?? "0"),
    })),
    couponCode: request.couponCode?.trim().toUpperCase() || null,
  };
}

function calculateInvoice(input: PricingInput): Invoice {
  const subtotalCents = input.items.reduce(
    (sum, item) => sum + item.quantity * item.unitPriceCents,
    0
  );

  const vipDiscountCents =
    input.customerType === "vip" ? Math.round(subtotalCents * 0.1) : 0;

  const couponDiscountCents = input.couponCode === "SAVE5" ? 500 : 0;

  const discountCents = Math.min(
    subtotalCents,
    vipDiscountCents + couponDiscountCents
  );

  return {
    subtotalCents,
    discountCents,
    totalCents: subtotalCents - discountCents,
  };
}

function priceCheckout(request: RawCheckoutRequest): Invoice {
  const pricingInput = buildPricingInput(request);
  return calculateInvoice(pricingInput);
}
```

### 2.3 Less maintainable form

```ts
type RawCheckoutRequest = {
  customerType?: string;
  items?: Array<{
    sku?: string;
    quantity?: string;
    unitPriceCents?: string;
  }>;
  couponCode?: string;
};

type Invoice = {
  subtotalCents: number;
  discountCents: number;
  totalCents: number;
};

function priceCheckout(request: RawCheckoutRequest): Invoice {
  let subtotalCents = 0;

  for (const item of request.items ?? []) {
    const quantity = Number(item.quantity ?? "0");
    const unitPriceCents = Number(item.unitPriceCents ?? "0");
    subtotalCents += quantity * unitPriceCents;
  }

  const customerType = request.customerType === "vip" ? "vip" : "standard";
  const couponCode = request.couponCode?.trim().toUpperCase() || null;

  const vipDiscountCents =
    customerType === "vip" ? Math.round(subtotalCents * 0.1) : 0;

  const couponDiscountCents = couponCode === "SAVE5" ? 500 : 0;

  const discountCents = Math.min(
    subtotalCents,
    vipDiscountCents + couponDiscountCents
  );

  return {
    subtotalCents,
    discountCents,
    totalCents: subtotalCents - discountCents,
  };
}
```

### 2.4 Why this difference matters

The good form separates the work into two phases: converting raw request data into a pricing-specific input model, then calculating the invoice from that model. The pricing phase no longer has to reason about optional strings, default values, trimming, or normalization. It can focus only on pricing rules.

This makes future changes more localized. For example, changing how request data is interpreted affects `buildPricingInput`, while changing discount rules affects `calculateInvoice`.

### 2.5 Structural references

```text
Good: checkout-service > pricing > checkoutPricing.ts > priceCheckout > buildPricingInput and calculateInvoice
Less maintainable: checkout-service > pricing > checkoutPricing.ts > priceCheckout > interleaved normalization and calculation statements
```

The structural difference is that the good form introduces a clear phase boundary inside the pricing flow. The less maintainable form keeps input normalization and invoice calculation in the same function body.

## 3. Boundaries and distinctions

Split Phase applies when one flow is doing separate conceptual jobs, especially when an early part prepares data for a later part. It is less useful when the steps are already simple, tightly coupled, and unlikely to change independently.

The less maintainable form can be acceptable for very small code paths where adding separate phases would create more ceremony than clarity. If the logic grows, gains more rules, or needs separate testing, splitting phases becomes more valuable.

Split Phase is not just extracting a helper function. The important point is the boundary between stages with different inputs, outputs, and reasoning models. A helper that merely hides a few lines without creating a distinct stage does not provide the same benefit.
