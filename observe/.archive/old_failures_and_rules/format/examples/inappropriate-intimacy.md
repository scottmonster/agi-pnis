# Inappropriate Intimacy

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.9
- **Aliases:** None
- **Definition:** Classes know or manipulate each other's internal details too closely. Such coupling makes a local representation change nonlocal.
- **Why it matters:** It hides ownership of data and behavior, so readers must inspect multiple classes to understand one change. A small internal representation change in one class can force edits in unrelated callers, increasing maintenance cost and defect risk.
- **Related concepts:** Encapsulate Record

## 2. Example

### 2.1 Scenario

An online shop applies a loyalty discount during checkout and updates the customer's loyalty account after purchase. The behavior is the same in both examples: calculate a discount from the customer's tier and points, then record earned points and purchase time.

### 2.2 Good form

```ts
type Tier = "standard" | "gold";

type Receipt = {
  subtotal: number;
  discount: number;
  total: number;
};

class Customer {
  private loyaltyAccount: {
    points: number;
    tier: Tier;
    lastPurchaseAt?: Date;
  };

  constructor(points: number, tier: Tier) {
    this.loyaltyAccount = { points, tier };
  }

  calculateLoyaltyDiscount(subtotal: number): number {
    const rate = this.loyaltyAccount.tier === "gold" ? 0.1 : 0.05;
    const discountFromTier = subtotal * rate;
    const discountFromPoints = this.loyaltyAccount.points / 100;

    return Math.min(discountFromTier, discountFromPoints);
  }

  recordPurchase(totalPaid: number, purchasedAt: Date): void {
    this.loyaltyAccount.points += Math.floor(totalPaid);
    this.loyaltyAccount.lastPurchaseAt = purchasedAt;
  }

  loyaltySnapshot(): { points: number; tier: Tier; lastPurchaseAt?: Date } {
    return { ...this.loyaltyAccount };
  }
}

class CheckoutService {
  checkout(customer: Customer, subtotal: number, purchasedAt: Date): Receipt {
    const discount = customer.calculateLoyaltyDiscount(subtotal);
    const total = subtotal - discount;

    customer.recordPurchase(total, purchasedAt);

    return { subtotal, discount, total };
  }
}

const customer = new Customer(800, "gold");
const receipt = new CheckoutService().checkout(
  customer,
  120,
  new Date("2026-01-15T10:00:00Z"),
);

console.log(receipt);
console.log(customer.loyaltySnapshot());
```

### 2.3 Less maintainable form

```ts
type Tier = "standard" | "gold";

type Receipt = {
  subtotal: number;
  discount: number;
  total: number;
};

class Customer {
  loyaltyAccount: {
    points: number;
    tier: Tier;
    lastPurchaseAt?: Date;
  };

  constructor(points: number, tier: Tier) {
    this.loyaltyAccount = { points, tier };
  }
}

class CheckoutService {
  checkout(customer: Customer, subtotal: number, purchasedAt: Date): Receipt {
    const rate = customer.loyaltyAccount.tier === "gold" ? 0.1 : 0.05;
    const discountFromTier = subtotal * rate;
    const discountFromPoints = customer.loyaltyAccount.points / 100;
    const discount = Math.min(discountFromTier, discountFromPoints);
    const total = subtotal - discount;

    customer.loyaltyAccount.points += Math.floor(total);
    customer.loyaltyAccount.lastPurchaseAt = purchasedAt;

    return { subtotal, discount, total };
  }
}

const customer = new Customer(800, "gold");
const receipt = new CheckoutService().checkout(
  customer,
  120,
  new Date("2026-01-15T10:00:00Z"),
);

console.log(receipt);
console.log(customer.loyaltyAccount);
```

### 2.4 Why this difference matters

In the good form, `Customer` owns the meaning and representation of its loyalty account. `CheckoutService` only asks for a discount and reports a completed purchase, so it does not need to know that points, tier, and last purchase time are stored together in a record.

In the less maintainable form, `CheckoutService` knows the exact nested shape of `Customer.loyaltyAccount` and mutates it directly. If `Customer` later stores loyalty data in cents, moves it to a separate object, renames `points`, or changes how tiers work, checkout code must change too. That is the inappropriate intimacy: one class depends on another class's internal details instead of its public behavior.

### 2.5 Structural references

```text
Good: Cart.applyPromotion > promotion rule
Less maintainable: CheckoutPage.applyPromotion > cart.items and cart.discountCode mutation
```

The relevant structural difference is the target of the dependency. The good form targets public behavior on `Customer`; the less maintainable form targets and mutates a nested internal record owned by `Customer`.

## 3. Boundaries and distinctions

Inappropriate Intimacy does not apply just because two classes collaborate frequently. Collaboration is normal when one object calls another object's stable public operations. The smell appears when a class must understand or manipulate another class's private representation to do its job.

The less maintainable form can be acceptable for simple data transfer objects, serialization boundaries, database result rows, tests that intentionally inspect state, or code inside a narrow module where the record is explicitly shared and has no behavior. It becomes risky when the accessed structure represents another object's domain rules or invariants.

This differs from **Encapsulate Record**, which is a refactoring that can address the problem by replacing direct record access with named operations or accessors. Inappropriate Intimacy is the smell: excessive knowledge between classes. Encapsulate Record is one possible remedy when the intimacy comes from exposing a structured record.
