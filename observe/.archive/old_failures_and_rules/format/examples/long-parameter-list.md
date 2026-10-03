# Long Parameter List

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.4
- **Aliases:** None
- **Definition:** A function requires many independent inputs. Calls become difficult to read and the list often reveals a missing object or misplaced responsibility.
- **Why it matters:** Long parameter lists make call sites hard to read because each argument's meaning depends on its position. They also make functions harder to change because adding, removing, or reordering data requires updates across many callers.
- **Related concepts:** Introduce Parameter Object

## 2. Example

### 2.1 Scenario

An order service calculates the final amount for an online purchase. The calculation needs customer, destination, discount, tax, shipping, and gift-wrap information.

### 2.2 Good form

```ts
type CustomerTier = "standard" | "gold" | "platinum";

interface PricingRequest {
  subtotal: number;
  customerTier: CustomerTier;
  destinationCountry: string;
  destinationPostalCode: string;
  couponCode?: string;
  giftWrap: boolean;
  expeditedShipping: boolean;
}

function calculateFinalAmount(request: PricingRequest): number {
  const tierDiscountRate =
    request.customerTier === "platinum"
      ? 0.15
      : request.customerTier === "gold"
        ? 0.1
        : 0;

  const couponDiscount = request.couponCode === "SAVE10" ? 10 : 0;
  const discountedSubtotal = Math.max(
    request.subtotal - request.subtotal * tierDiscountRate - couponDiscount,
    0,
  );

  const taxRate = request.destinationCountry === "US" ? 0.07 : 0.12;
  const shippingCost = request.expeditedShipping ? 25 : 8;
  const giftWrapCost = request.giftWrap ? 5 : 0;
  const remoteAreaSurcharge = request.destinationPostalCode.startsWith("99") ? 12 : 0;

  return discountedSubtotal + discountedSubtotal * taxRate + shippingCost + giftWrapCost + remoteAreaSurcharge;
}

const total = calculateFinalAmount({
  subtotal: 120,
  customerTier: "gold",
  destinationCountry: "US",
  destinationPostalCode: "94105",
  couponCode: "SAVE10",
  giftWrap: true,
  expeditedShipping: false,
});

console.log(total);
```

### 2.3 Less maintainable form

```ts
type CustomerTier = "standard" | "gold" | "platinum";

function calculateFinalAmount(
  subtotal: number,
  customerTier: CustomerTier,
  destinationCountry: string,
  destinationPostalCode: string,
  couponCode: string | undefined,
  giftWrap: boolean,
  expeditedShipping: boolean,
): number {
  const tierDiscountRate =
    customerTier === "platinum"
      ? 0.15
      : customerTier === "gold"
        ? 0.1
        : 0;

  const couponDiscount = couponCode === "SAVE10" ? 10 : 0;
  const discountedSubtotal = Math.max(
    subtotal - subtotal * tierDiscountRate - couponDiscount,
    0,
  );

  const taxRate = destinationCountry === "US" ? 0.07 : 0.12;
  const shippingCost = expeditedShipping ? 25 : 8;
  const giftWrapCost = giftWrap ? 5 : 0;
  const remoteAreaSurcharge = destinationPostalCode.startsWith("99") ? 12 : 0;

  return discountedSubtotal + discountedSubtotal * taxRate + shippingCost + giftWrapCost + remoteAreaSurcharge;
}

const total = calculateFinalAmount(
  120,
  "gold",
  "US",
  "94105",
  "SAVE10",
  true,
  false,
);

console.log(total);
```

### 2.4 Why this difference matters

The good form groups the independent inputs into a named `PricingRequest`, so each call labels the meaning of every value. This reduces reliance on positional memory, makes boolean arguments understandable, and gives the calculation a single object that can evolve as pricing data changes. The less maintainable form forces callers to remember the exact order of seven independent parameters, making mistakes such as swapping booleans or passing the wrong string easier.

### 2.5 Structural references

```text
Good: pricing-service > pricing > finalAmount.ts > calculateFinalAmount > request: PricingRequest
Less maintainable: pricing-service > pricing > finalAmount.ts > calculateFinalAmount > subtotal, tier, destination, coupon, and flag parameters
```

The relevant structural difference is that the good form passes one cohesive parameter object into the function, while the less maintainable form exposes many separate parameters directly in the function signature.

## 3. Boundaries and distinctions

A long parameter list is not always a problem. It may be acceptable for small private functions, generated code, low-level performance-sensitive APIs, or simple data constructors where the call sites are rare and obvious. It is also less concerning when parameters are strongly related and always change together.

The smell applies when many independent inputs make calls hard to read or suggest that related data should belong to a request object, domain object, configuration object, or another responsibility holder.

This differs from Introduce Parameter Object, which is a refactoring used to address the smell by grouping related parameters. It also differs from merely having a large object available in scope: passing an entire object can be worse if the function only needs one or two fields, because that hides dependencies rather than clarifying them.
