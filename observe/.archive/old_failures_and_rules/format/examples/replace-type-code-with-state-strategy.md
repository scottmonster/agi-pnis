# Replace Type Code with State/Strategy

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.11
- **Aliases:** None
- **Definition:** Replace a changing type/mode code with a delegated State or Strategy object. It isolates changing behavior without making the owning object a long conditional.
- **Why it matters:** It keeps mode-specific behavior close to the mode that owns it, making the owning object easier to read and reducing the need to edit a central conditional every time behavior changes.
- **Related concepts:** State, Strategy

## 2. Example

### 2.1 Scenario

A billing service calculates a monthly charge for subscriptions. Each plan has different pricing behavior, and new plans are expected to be added over time.

### 2.2 Good form

```ts
type PlanCode = "basic" | "pro" | "enterprise";

interface PlanPricing {
  monthlyCharge(activeUsers: number): number;
}

class BasicPricing implements PlanPricing {
  monthlyCharge(activeUsers: number): number {
    return 20;
  }
}

class ProPricing implements PlanPricing {
  monthlyCharge(activeUsers: number): number {
    return 50 + activeUsers * 5;
  }
}

class EnterprisePricing implements PlanPricing {
  monthlyCharge(activeUsers: number): number {
    return 500 + Math.max(0, activeUsers - 100) * 2;
  }
}

function pricingFor(planCode: PlanCode): PlanPricing {
  switch (planCode) {
    case "basic":
      return new BasicPricing();
    case "pro":
      return new ProPricing();
    case "enterprise":
      return new EnterprisePricing();
  }
}

class Subscription {
  private readonly pricing: PlanPricing;

  constructor(
    private readonly accountId: string,
    planCode: PlanCode,
    private readonly activeUsers: number
  ) {
    this.pricing = pricingFor(planCode);
  }

  monthlyCharge(): number {
    return this.pricing.monthlyCharge(this.activeUsers);
  }

  invoiceLabel(): string {
    return `Subscription ${this.accountId}`;
  }
}

const subscription = new Subscription("acct-123", "pro", 12);
console.log(subscription.invoiceLabel());
console.log(subscription.monthlyCharge());
```

### 2.3 Less maintainable form

```ts
type PlanCode = "basic" | "pro" | "enterprise";

class Subscription {
  constructor(
    private readonly accountId: string,
    private readonly planCode: PlanCode,
    private readonly activeUsers: number
  ) {}

  monthlyCharge(): number {
    switch (this.planCode) {
      case "basic":
        return 20;
      case "pro":
        return 50 + this.activeUsers * 5;
      case "enterprise":
        return 500 + Math.max(0, this.activeUsers - 100) * 2;
    }
  }

  invoiceLabel(): string {
    return `Subscription ${this.accountId}`;
  }
}

const subscription = new Subscription("acct-123", "pro", 12);
console.log(subscription.invoiceLabel());
console.log(subscription.monthlyCharge());
```

### 2.4 Why this difference matters

In the good form, the plan code is converted into a pricing strategy, and `Subscription` delegates pricing behavior to that object. The owner no longer needs to know every pricing rule, so adding a new plan mainly means adding another `PlanPricing` implementation and updating creation logic.

In the less maintainable form, `Subscription.monthlyCharge` depends directly on every possible plan code. As more plan-specific behavior appears, the class tends to accumulate larger switches and unrelated responsibilities, making it harder to read and riskier to change.

### 2.5 Structural references

```text
Good: billing-service > billing > subscription.ts > Subscription.monthlyCharge > PlanPricing delegation
Less maintainable: billing-service > billing > subscription.ts > Subscription.monthlyCharge > planCode switch
```

The relevant structural difference is that the good form places variable pricing behavior behind a delegated strategy object, while the less maintainable form keeps that behavior inside the owner as a conditional over a type code.

## 3. Boundaries and distinctions

This refactoring is useful when a type or mode code controls behavior that changes independently from the owning object. It is less useful when the code is only stored, displayed, serialized, or used for a small stable lookup with no meaningful behavior behind it.

The less maintainable form can be acceptable for a short-lived script, a very small closed set of cases, or a boundary layer that maps external data into internal objects. A simple switch can also be clearer when there is only one tiny decision and no expected variation.

State and Strategy are closely related. Use Strategy when the delegated object represents an interchangeable algorithm or policy, such as pricing. Use State when the delegated object represents the current lifecycle state of the owner and state transitions are part of the model. Replace Type Code with State/Strategy is the refactoring move that replaces the type-code conditional with one of these delegation structures.
