# Replace Superclass with Delegate

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.14
- **Aliases:** replace inheritance with delegation
- **Definition:** Delegate inherited behavior to a contained object when inheritance exposes or couples too much. It makes the reused role explicit.
- **Why it matters:** It makes the reused behavior visible as a separate role, reduces accidental public API exposure, and lets the containing type change independently from the reused type.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A subscription system needs premium subscriptions to show customer profile information and calculate plan benefits. A premium subscription reuses customer profile behavior, but it should not itself be treated as a customer profile.

### 2.2 Good form

```ts
type Plan = "standard" | "gold";

class CustomerProfile {
  constructor(
    private readonly customerId: string,
    private readonly name: string,
    private readonly email: string
  ) {}

  displayName(): string {
    return this.name;
  }

  contactEmail(): string {
    return this.email;
  }

  profileLabel(): string {
    return `${this.name} <${this.email}>`;
  }

  id(): string {
    return this.customerId;
  }
}

class PremiumSubscription {
  constructor(
    private readonly customerProfile: CustomerProfile,
    private readonly plan: Plan
  ) {}

  subscriberName(): string {
    return this.customerProfile.displayName();
  }

  contactEmail(): string {
    return this.customerProfile.contactEmail();
  }

  summaryLabel(): string {
    return this.customerProfile.profileLabel();
  }

  monthlyCharge(): number {
    return this.plan === "gold" ? 49 : 29;
  }

  supportTicketsPerMonth(): number {
    return this.plan === "gold" ? 20 : 10;
  }
}

function renderSubscriptionSummary(subscription: PremiumSubscription): string {
  return [
    `Subscriber: ${subscription.summaryLabel()}`,
    `Charge: $${subscription.monthlyCharge()}`,
    `Tickets: ${subscription.supportTicketsPerMonth()}`
  ].join("\n");
}

const profile = new CustomerProfile("cust-42", "Ava Patel", "ava@example.com");
const subscription = new PremiumSubscription(profile, "gold");

console.log(renderSubscriptionSummary(subscription));
```

### 2.3 Less maintainable form

```ts
type Plan = "standard" | "gold";

class CustomerProfile {
  constructor(
    private readonly customerId: string,
    private readonly name: string,
    private readonly email: string
  ) {}

  displayName(): string {
    return this.name;
  }

  contactEmail(): string {
    return this.email;
  }

  profileLabel(): string {
    return `${this.name} <${this.email}>`;
  }

  id(): string {
    return this.customerId;
  }
}

class PremiumSubscription extends CustomerProfile {
  constructor(
    customerId: string,
    name: string,
    email: string,
    private readonly plan: Plan
  ) {
    super(customerId, name, email);
  }

  subscriberName(): string {
    return this.displayName();
  }

  summaryLabel(): string {
    return this.profileLabel();
  }

  monthlyCharge(): number {
    return this.plan === "gold" ? 49 : 29;
  }

  supportTicketsPerMonth(): number {
    return this.plan === "gold" ? 20 : 10;
  }
}

function renderSubscriptionSummary(subscription: PremiumSubscription): string {
  return [
    `Subscriber: ${subscription.summaryLabel()}`,
    `Charge: $${subscription.monthlyCharge()}`,
    `Tickets: ${subscription.supportTicketsPerMonth()}`
  ].join("\n");
}

const subscription = new PremiumSubscription(
  "cust-42",
  "Ava Patel",
  "ava@example.com",
  "gold"
);

console.log(renderSubscriptionSummary(subscription));
```

### 2.4 Why this difference matters

In the good form, `PremiumSubscription` contains a `CustomerProfile` and delegates only the profile behavior it wants to expose. The customer role is explicit through the `customerProfile` field, so readers can see that a subscription uses a profile rather than being a profile.

In the less maintainable form, `PremiumSubscription` inherits the entire `CustomerProfile` API. Any profile methods become subscription methods, even when callers should not depend on them. Changes to `CustomerProfile` can accidentally affect `PremiumSubscription` callers, and the domain model becomes harder to understand because the inheritance relationship overstates the real relationship.

### 2.5 Structural references

```text
Good: PremiumSubscription > customerProfile field
Less maintainable: PremiumSubscription extends CustomerProfile
```

The good structure places the reused behavior behind a contained field, `customerProfile`, inside `PremiumSubscription`. The less maintainable structure places the reused behavior in the superclass chain, making every inherited `CustomerProfile` member part of `PremiumSubscription`.

## 3. Boundaries and distinctions

Replace Superclass with Delegate applies when inheritance is being used mainly to reuse behavior, but the subclass is not truly a specialized form of the superclass or should not expose the full superclass API.

The inheritance form can be appropriate when the subtype genuinely satisfies the superclass contract everywhere the superclass is expected, and exposing the inherited API is intentional. For example, a specific kind of profile that must be usable anywhere a `CustomerProfile` is accepted may still be a valid subclass.

This refactoring differs from simply extracting helper functions because the reused behavior remains represented as an object with its own state and domain meaning. It also differs from replacing a subclass with a strategy: a strategy usually varies an algorithm, while this refactoring removes an overbroad superclass relationship and replaces it with an explicit contained delegate.
