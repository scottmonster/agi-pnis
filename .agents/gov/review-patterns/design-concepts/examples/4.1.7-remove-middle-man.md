# Remove Middle Man

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.7
- **Aliases:** None
- **Definition:** Remove a component that only forwards calls when the indirection no longer protects a useful boundary. It makes the actual collaborator visible.
- **Why it matters:** It reduces needless delegation, makes the real dependency easier to see, and avoids changing a wrapper every time callers need another operation from the same collaborator.
- **Related concepts:** Middle Man

## 2. Example

### 2.1 Scenario

A support dashboard displays a customer's subscription plan. The account object used to forward subscription calls, but callers now routinely need subscription details directly.

### 2.2 Good form

```ts
type Plan = "Free" | "Pro" | "Enterprise";

class Subscription {
  constructor(private readonly plan: Plan) {}

  planName(): string {
    return this.plan;
  }
}

class Account {
  constructor(public readonly subscription: Subscription) {}
}

function renderSupportSummary(account: Account): string {
  return `Current plan: ${account.subscription.planName()}`;
}

const account = new Account(new Subscription("Pro"));
console.log(renderSupportSummary(account));
```

### 2.3 Less maintainable form

```ts
type Plan = "Free" | "Pro" | "Enterprise";

class Subscription {
  constructor(private readonly plan: Plan) {}

  planName(): string {
    return this.plan;
  }
}

class Account {
  constructor(private readonly subscription: Subscription) {}

  subscriptionPlanName(): string {
    return this.subscription.planName();
  }
}

function renderSupportSummary(account: Account): string {
  return `Current plan: ${account.subscriptionPlanName()}`;
}

const account = new Account(new Subscription("Pro"));
console.log(renderSupportSummary(account));
```

### 2.4 Why this difference matters

In the good form, the dashboard calls the collaborator that owns the behavior: `Subscription`. `Account` no longer contains a method whose only job is to pass the call through. If the dashboard later needs another subscription operation, the caller can use `account.subscription` directly instead of adding another forwarding method to `Account`.

In the less maintainable form, `Account.subscriptionPlanName()` hides the real collaborator without adding policy, validation, translation, or stability. That extra method increases the surface area of `Account` and makes future subscription changes ripple through the middle object.

### 2.5 Structural references

```text
Good: support-dashboard > accounts > account.ts > renderSupportSummary > Subscription.planName
Less maintainable: support-dashboard > accounts > account.ts > renderSupportSummary > Account.subscriptionPlanName
```

The relevant structural difference is that the good form points the caller at the actual target behavior on `Subscription`, while the less maintainable form routes the same call through `Account` even though `Account` contributes no behavior.

## 3. Boundaries and distinctions

Remove Middle Man applies when the intermediate component only forwards calls and no longer protects a useful boundary. It should not be applied when the middle component hides an unstable dependency, enforces authorization, performs validation, adapts an external API, preserves a public interface, or expresses a meaningful domain abstraction.

The less maintainable form can be appropriate if callers should not know that subscriptions exist, if `Account` must remain the only public entry point, or if the forwarding method is expected to absorb future changes in subscription storage or representation.

This differs from the related smell Middle Man: Middle Man names the problem, where a component mostly delegates to another component. Remove Middle Man is the refactoring that fixes that problem by letting callers work with the real collaborator directly.
