# Insider Trading

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.13
- **Aliases:** None
- **Definition:** Modules or classes exchange knowledge of each other's private concerns more than their public collaboration requires. It turns internal changes into joint changes.
- **Why it matters:** It makes code harder to read and change because callers must understand another module's internal rules, data shape, and reasons for change instead of relying on a clear public behavior.
- **Related concepts:** Inappropriate Intimacy

## 2. Example

### 2.1 Scenario

A checkout flow gives a loyalty discount to customers who have been members for at least two years, are not suspended, and have spent at least $1,000. The intended behavior is the same in both examples.

### 2.2 Good form

```ts
type Cents = number;

function addYears(date: Date, years: number): Date {
  const result = new Date(date);
  result.setFullYear(result.getFullYear() + years);
  return result;
}

class Customer {
  constructor(
    private readonly joinedOn: Date,
    private readonly suspended: boolean,
    private readonly lifetimeSpendCents: Cents,
  ) {}

  qualifiesForLoyaltyDiscount(today: Date): boolean {
    const hasTwoYearsOfMembership = addYears(this.joinedOn, 2) <= today;
    const hasEnoughSpend = this.lifetimeSpendCents >= 100_000;

    return hasTwoYearsOfMembership && hasEnoughSpend && !this.suspended;
  }
}

class Checkout {
  totalDueCents(customer: Customer, subtotalCents: Cents, today: Date): Cents {
    if (!customer.qualifiesForLoyaltyDiscount(today)) {
      return subtotalCents;
    }

    return Math.round(subtotalCents * 0.9);
  }
}

const customer = new Customer(new Date("2021-01-10"), false, 125_000);
const checkout = new Checkout();

console.log(checkout.totalDueCents(customer, 50_000, new Date("2024-01-10")));
```

### 2.3 Less maintainable form

```ts
type Cents = number;

function addYears(date: Date, years: number): Date {
  const result = new Date(date);
  result.setFullYear(result.getFullYear() + years);
  return result;
}

type CustomerAccountSnapshot = {
  joinedOn: Date;
  suspended: boolean;
  lifetimeSpendCents: Cents;
};

class Customer {
  constructor(
    private readonly joinedOn: Date,
    private readonly suspended: boolean,
    private readonly lifetimeSpendCents: Cents,
  ) {}

  accountSnapshot(): CustomerAccountSnapshot {
    return {
      joinedOn: this.joinedOn,
      suspended: this.suspended,
      lifetimeSpendCents: this.lifetimeSpendCents,
    };
  }
}

class Checkout {
  totalDueCents(customer: Customer, subtotalCents: Cents, today: Date): Cents {
    const account = customer.accountSnapshot();

    const hasTwoYearsOfMembership = addYears(account.joinedOn, 2) <= today;
    const hasEnoughSpend = account.lifetimeSpendCents >= 100_000;
    const qualifiesForLoyaltyDiscount =
      hasTwoYearsOfMembership && hasEnoughSpend && !account.suspended;

    if (!qualifiesForLoyaltyDiscount) {
      return subtotalCents;
    }

    return Math.round(subtotalCents * 0.9);
  }
}

const customer = new Customer(new Date("2021-01-10"), false, 125_000);
const checkout = new Checkout();

console.log(checkout.totalDueCents(customer, 50_000, new Date("2024-01-10")));
```

### 2.4 Why this difference matters

In the good form, `Checkout` collaborates with `Customer` through a public behavior: `qualifiesForLoyaltyDiscount`. The customer owns the meaning of its membership date, suspension state, and lifetime spend.

In the less maintainable form, `Checkout` knows the customer's internal data shape and repeats the customer's eligibility policy. If the customer model changes, for example by replacing `joinedOn` with membership tiers or by changing how suspension affects discounts, both `Customer` and `Checkout` must change together. That coupling is the Insider Trading smell.

### 2.5 Structural references

```text
Good: LoyaltyAccount.canUseReward > encapsulated eligibility rule
Less maintainable: CheckoutDiscounts.applyReward > account.points and account.lastRewardDate checks
```

The relevant structural difference is where the customer-specific rule lives. In the good form, the rule is behind the `Customer` public API. In the less maintainable form, a separate collaborator reaches through an exposed snapshot and performs logic based on `Customer` internals.

## 3. Boundaries and distinctions

Insider Trading does not apply merely because two modules collaborate closely. It is acceptable for a caller to use another module's stable public API, even if the collaboration is frequent. It also may be appropriate to expose data in simple data transfer objects, persistence records, reports, or integration boundaries where the purpose is explicitly to carry data rather than protect domain behavior.

The smell appears when one module must understand another module's private concerns to do its job, such as knowing internal fields, lifecycle states, validation rules, cache details, or representation choices that should belong to the other module.

Insider Trading is closely related to Inappropriate Intimacy. Inappropriate Intimacy is the broader smell of classes being too entangled with each other's details. Insider Trading emphasizes the exchange or leakage of private knowledge across module boundaries, especially when that leakage makes internal changes require coordinated edits in multiple places.
