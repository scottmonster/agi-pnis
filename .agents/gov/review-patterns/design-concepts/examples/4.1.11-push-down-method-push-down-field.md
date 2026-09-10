# Push Down Method / Push Down Field

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.11
- **Aliases:** None
- **Definition:** Move a superclass member used by only some subclasses into those subclasses. It makes the base contract smaller and more honest.
- **Why it matters:** Readers can understand what every subclass is actually required to support, and maintainers can change specialized behavior without adding irrelevant state or methods to the whole hierarchy.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing system has trial and paid subscriptions. Only paid subscriptions can send renewal invoice messages, so the invoice email field and renewal invoice method belong only on the paid subclass.

### 2.2 Good form

```ts
type Money = {
  cents: number;
  currency: string;
};

function formatMoney(money: Money): string {
  return `${money.currency} ${(money.cents / 100).toFixed(2)}`;
}

abstract class Subscription {
  constructor(public readonly accountId: string) {}

  abstract label(): string;
}

class TrialSubscription extends Subscription {
  constructor(
    accountId: string,
    private readonly expiresOn: Date,
  ) {
    super(accountId);
  }

  label(): string {
    return `Trial subscription ${this.accountId} expires on ${this.expiresOn.toISOString().slice(0, 10)}`;
  }
}

class PaidSubscription extends Subscription {
  constructor(
    accountId: string,
    private readonly planName: string,
    private readonly renewalPrice: Money,
    private readonly invoiceEmail: string,
  ) {
    super(accountId);
  }

  label(): string {
    return `Paid subscription ${this.accountId} is on the ${this.planName} plan`;
  }

  renewalInvoiceMessage(): string {
    return `Send ${formatMoney(this.renewalPrice)} renewal invoice for ${this.planName} to ${this.invoiceEmail}`;
  }
}

function describeSubscription(subscription: Subscription): string {
  return subscription.label();
}

function createRenewalNotice(subscription: PaidSubscription): string {
  return subscription.renewalInvoiceMessage();
}

const trial = new TrialSubscription("acct_trial", new Date("2026-02-01"));
const paid = new PaidSubscription(
  "acct_paid",
  "Pro",
  { cents: 4900, currency: "USD" },
  "billing@example.com",
);

console.log(describeSubscription(trial));
console.log(describeSubscription(paid));
console.log(createRenewalNotice(paid));
```

### 2.3 Less maintainable form

```ts
type Money = {
  cents: number;
  currency: string;
};

function formatMoney(money: Money): string {
  return `${money.currency} ${(money.cents / 100).toFixed(2)}`;
}

abstract class Subscription {
  constructor(
    public readonly accountId: string,
    protected readonly invoiceEmail?: string,
  ) {}

  abstract label(): string;

  renewalInvoiceMessage(planName: string, renewalPrice: Money): string {
    if (this.invoiceEmail === undefined) {
      throw new Error("This subscription does not have an invoice email.");
    }

    return `Send ${formatMoney(renewalPrice)} renewal invoice for ${planName} to ${this.invoiceEmail}`;
  }
}

class TrialSubscription extends Subscription {
  constructor(
    accountId: string,
    private readonly expiresOn: Date,
  ) {
    super(accountId);
  }

  label(): string {
    return `Trial subscription ${this.accountId} expires on ${this.expiresOn.toISOString().slice(0, 10)}`;
  }
}

class PaidSubscription extends Subscription {
  constructor(
    accountId: string,
    private readonly planName: string,
    private readonly renewalPrice: Money,
    invoiceEmail: string,
  ) {
    super(accountId, invoiceEmail);
  }

  label(): string {
    return `Paid subscription ${this.accountId} is on the ${this.planName} plan`;
  }

  renewalInvoiceMessageForPaidAccount(): string {
    return this.renewalInvoiceMessage(this.planName, this.renewalPrice);
  }
}

function describeSubscription(subscription: Subscription): string {
  return subscription.label();
}

function createRenewalNotice(subscription: PaidSubscription): string {
  return subscription.renewalInvoiceMessageForPaidAccount();
}

const trial = new TrialSubscription("acct_trial", new Date("2026-02-01"));
const paid = new PaidSubscription(
  "acct_paid",
  "Pro",
  { cents: 4900, currency: "USD" },
  "billing@example.com",
);

console.log(describeSubscription(trial));
console.log(describeSubscription(paid));
console.log(createRenewalNotice(paid));
```

### 2.4 Why this difference matters

In the good form, `Subscription` contains only behavior shared by every subscription: an account id and a label contract. The paid-only `invoiceEmail` field and `renewalInvoiceMessage` method live on `PaidSubscription`, where their assumptions are always valid.

In the less maintainable form, every `Subscription` appears to support renewal invoice behavior, even though `TrialSubscription` cannot use it correctly. That forces optional state, runtime checks, and forwarding methods. Pushing the field and method down removes misleading API surface from the superclass and makes the subclass-specific rule visible in the type structure.

### 2.5 Structural references

```text
Good: BillingPortal > subscriptions > subscription.ts > PaidSubscription.renewalInvoiceMessage > renewal invoice behavior
Less maintainable: BillingPortal > subscriptions > subscription.ts > Subscription.renewalInvoiceMessage > renewal invoice behavior
```

The relevant structural difference is where the specialized member is declared. In the good form, the renewal invoice behavior is located in the subclass that has the required invoice state. In the less maintainable form, the same behavior is declared on the superclass, so unrelated subclasses inherit a member outside their valid responsibility.

## 3. Boundaries and distinctions

Push Down Method / Push Down Field applies when a superclass member is not part of the real common contract and is used only by one or some subclasses. It is not needed when all subclasses genuinely share the member, when callers must treat the member polymorphically through the base type, or when the hierarchy is about to be simplified in another way.

The less maintainable form can be appropriate temporarily if an API compatibility constraint requires the member to remain on the superclass, or if a migration is underway and subclasses have not yet been separated cleanly. It is also appropriate if every subtype is expected to gain the behavior soon and the superclass contract is intentionally being expanded.

This refactoring differs from pulling up a method or field, which moves common members from subclasses into a superclass. It also differs from extracting a subclass, which creates a new subtype for a specialized responsibility. Push down assumes the subtype already exists and moves misplaced superclass members to the subclasses where they are actually meaningful.
