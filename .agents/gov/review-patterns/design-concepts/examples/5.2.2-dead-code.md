# Dead Code

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.2
- **Aliases:** None
- **Definition:** Code remains although no meaningful execution path uses it. It adds false possibilities to the reader's model and can be removed after usage is established.
- **Why it matters:** Dead code makes readers spend time understanding behavior that cannot occur, increases the surface area for mistaken changes, and can hide the real execution paths that need maintenance.
- **Related concepts:** Speculative Generality

## 2. Example

### 2.1 Scenario

An online store calculates a checkout discount from the customer's loyalty tier. A previous coupon system has been retired, so the checkout path no longer passes or applies coupon codes.

### 2.2 Good form

```ts
type LoyaltyTier = "standard" | "silver" | "gold";

interface Cart {
  subtotalCents: number;
}

interface Customer {
  loyaltyTier: LoyaltyTier;
}

function calculateDiscountCents(cart: Cart, customer: Customer): number {
  const rateByTier: Record<LoyaltyTier, number> = {
    standard: 0,
    silver: 0.05,
    gold: 0.1,
  };

  return Math.round(cart.subtotalCents * rateByTier[customer.loyaltyTier]);
}

const cart: Cart = { subtotalCents: 12000 };
const customer: Customer = { loyaltyTier: "gold" };

console.log(calculateDiscountCents(cart, customer));
```

### 2.3 Less maintainable form

```ts
type LoyaltyTier = "standard" | "silver" | "gold";

interface Cart {
  subtotalCents: number;
}

interface Customer {
  loyaltyTier: LoyaltyTier;
}

function calculateDiscountCents(cart: Cart, customer: Customer): number {
  const rateByTier: Record<LoyaltyTier, number> = {
    standard: 0,
    silver: 0.05,
    gold: 0.1,
  };

  return Math.round(cart.subtotalCents * rateByTier[customer.loyaltyTier]);
}

function calculateRetiredCouponDiscountCents(cart: Cart, couponCode: string): number {
  if (couponCode === "WELCOME10") {
    return Math.round(cart.subtotalCents * 0.1);
  }

  if (couponCode === "FREESHIP") {
    return 500;
  }

  return 0;
}

const cart: Cart = { subtotalCents: 12000 };
const customer: Customer = { loyaltyTier: "gold" };

console.log(calculateDiscountCents(cart, customer));
```

### 2.4 Why this difference matters

The good form leaves only the discount logic that the checkout path can actually execute. The less maintainable form preserves `calculateRetiredCouponDiscountCents`, which suggests that coupon discounts may still be part of checkout behavior even though no meaningful path calls it. A maintainer may waste time checking whether old coupon rules still matter, update them unnecessarily, or accidentally reintroduce retired behavior.

### 2.5 Structural references

```text
Good: calculateDiscount > active discount calculation
Less maintainable: retiredHolidayDiscount > unused legacy discount function
```

The relevant structural difference is that the good form contains only reachable behavior in the pricing file, while the less maintainable form keeps an unreachable function beside the active checkout calculation.

## 3. Boundaries and distinctions

Dead Code does not apply just because usage is not obvious locally. Code may still be live when it is called by dependency injection, framework conventions, command-line entry points, reflection, scheduled jobs, migrations, tests, or external consumers of a public API.

Keeping apparently unused code can be appropriate during a documented deprecation window, for compatibility with older clients, for generated code, or for operational rollback. In those cases, the code should have an explicit owner, reason, and removal condition.

Dead Code differs from Speculative Generality. Speculative Generality is code added for imagined future flexibility, such as unused abstractions or configuration hooks. Dead Code is code that remains even though no meaningful execution path uses it. A piece of code can be both, but the dead-code concern is specifically that readers are asked to understand behavior that cannot run.
