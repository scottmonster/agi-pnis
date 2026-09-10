# Change Value to Reference

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.6
- **Aliases:** None
- **Definition:** Make independently copied data share a referenced identity when the domain requires shared updates. It makes identity semantics explicit.
- **Why it matters:** It makes the code easier to understand and maintain when multiple records should observe the same changing domain entity. Instead of searching for and synchronizing many copies, readers can see that updates happen through one shared reference.
- **Related concepts:** Value Object

## 2. Example

### 2.1 Scenario

An ordering system applies discounts based on a customer's membership tier. When the business changes the discount for a tier, every customer in that tier should use the new discount immediately.

### 2.2 Good form

```ts
type TierId = "standard" | "gold";

type CustomerTier = {
  id: TierId;
  name: string;
  discountRate: number;
};

type Customer = {
  id: string;
  name: string;
  tier: CustomerTier;
};

type Order = {
  id: string;
  customer: Customer;
  subtotalCents: number;
};

const tierById = new Map<TierId, CustomerTier>([
  ["standard", { id: "standard", name: "Standard", discountRate: 0 }],
  ["gold", { id: "gold", name: "Gold", discountRate: 0.1 }],
]);

function getTier(tierId: TierId): CustomerTier {
  const tier = tierById.get(tierId);

  if (!tier) {
    throw new Error(`Unknown tier: ${tierId}`);
  }

  return tier;
}

function priceOrder(order: Order): number {
  return Math.round(order.subtotalCents * (1 - order.customer.tier.discountRate));
}

function changeTierDiscount(tierId: TierId, discountRate: number): void {
  getTier(tierId).discountRate = discountRate;
}

const alice: Customer = {
  id: "cust-1",
  name: "Alice",
  tier: getTier("gold"),
};

const order: Order = {
  id: "order-1",
  customer: alice,
  subtotalCents: 10_000,
};

const beforeChange = priceOrder(order);

changeTierDiscount("gold", 0.15);

const afterChange = priceOrder(order);

console.log({ beforeChange, afterChange });
// { beforeChange: 9000, afterChange: 8500 }
```

### 2.3 Less maintainable form

```ts
type TierId = "standard" | "gold";

type CustomerTierSnapshot = {
  id: TierId;
  name: string;
  discountRate: number;
};

type Customer = {
  id: string;
  name: string;
  tier: CustomerTierSnapshot;
};

type Order = {
  id: string;
  customer: Customer;
  subtotalCents: number;
};

const tierTemplates: Record<TierId, CustomerTierSnapshot> = {
  standard: { id: "standard", name: "Standard", discountRate: 0 },
  gold: { id: "gold", name: "Gold", discountRate: 0.1 },
};

function copyTier(tierId: TierId): CustomerTierSnapshot {
  const template = tierTemplates[tierId];

  return {
    id: template.id,
    name: template.name,
    discountRate: template.discountRate,
  };
}

function priceOrder(order: Order): number {
  return Math.round(order.subtotalCents * (1 - order.customer.tier.discountRate));
}

function changeTierDiscount(
  tierId: TierId,
  discountRate: number,
  customers: Customer[],
): void {
  tierTemplates[tierId].discountRate = discountRate;

  for (const customer of customers) {
    if (customer.tier.id === tierId) {
      customer.tier.discountRate = discountRate;
    }
  }
}

const alice: Customer = {
  id: "cust-1",
  name: "Alice",
  tier: copyTier("gold"),
};

const customers = [alice];

const order: Order = {
  id: "order-1",
  customer: alice,
  subtotalCents: 10_000,
};

const beforeChange = priceOrder(order);

changeTierDiscount("gold", 0.15, customers);

const afterChange = priceOrder(order);

console.log({ beforeChange, afterChange });
// { beforeChange: 9000, afterChange: 8500 }
```

### 2.4 Why this difference matters

In the good form, `CustomerTier` is a referenced domain identity. Every gold customer points to the same `CustomerTier` object, so changing the gold discount changes the single shared entity that pricing already reads.

In the less maintainable form, each customer receives a copied tier snapshot. The code must remember to find and update every copy whenever the tier changes. That makes the shared-update rule implicit and fragile, because a missed copy can produce inconsistent prices.

### 2.5 Structural references

```text
Good: ordering-service > pricing > orderPricing.ts > changeTierDiscount > CustomerTier reference
Less maintainable: ordering-service > pricing > orderPricing.ts > changeTierDiscount > copied tier snapshots
```

The relevant structural difference is where tier identity lives. The good form centralizes tier state behind a shared reference, while the less maintainable form distributes equivalent tier state across many copied customer records.

## 3. Boundaries and distinctions

Change Value to Reference applies when the domain needs shared identity and shared updates. A membership tier, account, product, or supplier may need this when one change should be observed by many holders.

It does not apply when the data is intentionally a value. For example, a historical invoice should usually keep the discount rate that was used when the invoice was issued, even if the current tier discount changes later. In that case, a copied immutable value is appropriate because it records a past fact.

This differs from a Value Object. A Value Object is defined by its attributes and is usually interchangeable with another object containing the same attributes. Change Value to Reference is used when equality by attributes is not enough because the domain requires a distinct identity whose changes are shared by all users of that identity.
