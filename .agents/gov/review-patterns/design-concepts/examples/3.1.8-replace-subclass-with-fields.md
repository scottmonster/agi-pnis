# Replace Subclass with Fields

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.8
- **Aliases:** remove subclass
- **Definition:** Replace subclasses that differ only through constant data with fields or type data. It removes a hierarchy that does not carry distinct behavior.
- **Why it matters:** It makes the model easier to read and change by keeping simple variations as data instead of spreading fixed values across subclasses. Adding or editing a case becomes a data change rather than a hierarchy change.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing service calculates monthly invoices for subscription plans. Each plan uses the same calculation, and the only differences are fixed values such as name, base price, and included seats.

### 2.2 Good form

```ts
type PlanCode = "starter" | "pro" | "enterprise";

type PlanFields = {
  code: PlanCode;
  displayName: string;
  monthlyPriceCents: number;
  includedSeats: number;
  extraSeatPriceCents: number;
};

class SubscriptionPlan {
  constructor(private readonly fields: PlanFields) {}

  get code(): PlanCode {
    return this.fields.code;
  }

  get displayName(): string {
    return this.fields.displayName;
  }

  monthlyInvoiceCents(activeSeats: number): number {
    const extraSeats = Math.max(0, activeSeats - this.fields.includedSeats);
    return this.fields.monthlyPriceCents + extraSeats * this.fields.extraSeatPriceCents;
  }
}

const planCatalog: Record<PlanCode, SubscriptionPlan> = {
  starter: new SubscriptionPlan({
    code: "starter",
    displayName: "Starter",
    monthlyPriceCents: 2900,
    includedSeats: 3,
    extraSeatPriceCents: 800,
  }),
  pro: new SubscriptionPlan({
    code: "pro",
    displayName: "Pro",
    monthlyPriceCents: 9900,
    includedSeats: 10,
    extraSeatPriceCents: 600,
  }),
  enterprise: new SubscriptionPlan({
    code: "enterprise",
    displayName: "Enterprise",
    monthlyPriceCents: 29900,
    includedSeats: 50,
    extraSeatPriceCents: 400,
  }),
};

function quoteMonthlyInvoice(planCode: PlanCode, activeSeats: number): string {
  const plan = planCatalog[planCode];
  const dollars = (plan.monthlyInvoiceCents(activeSeats) / 100).toFixed(2);
  return `${plan.displayName}: $${dollars}`;
}

console.log(quoteMonthlyInvoice("pro", 12));
```

### 2.3 Less maintainable form

```ts
type PlanCode = "starter" | "pro" | "enterprise";

abstract class SubscriptionPlan {
  abstract get code(): PlanCode;
  abstract get displayName(): string;
  protected abstract get monthlyPriceCents(): number;
  protected abstract get includedSeats(): number;
  protected abstract get extraSeatPriceCents(): number;

  monthlyInvoiceCents(activeSeats: number): number {
    const extraSeats = Math.max(0, activeSeats - this.includedSeats);
    return this.monthlyPriceCents + extraSeats * this.extraSeatPriceCents;
  }
}

class StarterPlan extends SubscriptionPlan {
  get code(): PlanCode {
    return "starter";
  }

  get displayName(): string {
    return "Starter";
  }

  protected get monthlyPriceCents(): number {
    return 2900;
  }

  protected get includedSeats(): number {
    return 3;
  }

  protected get extraSeatPriceCents(): number {
    return 800;
  }
}

class ProPlan extends SubscriptionPlan {
  get code(): PlanCode {
    return "pro";
  }

  get displayName(): string {
    return "Pro";
  }

  protected get monthlyPriceCents(): number {
    return 9900;
  }

  protected get includedSeats(): number {
    return 10;
  }

  protected get extraSeatPriceCents(): number {
    return 600;
  }
}

class EnterprisePlan extends SubscriptionPlan {
  get code(): PlanCode {
    return "enterprise";
  }

  get displayName(): string {
    return "Enterprise";
  }

  protected get monthlyPriceCents(): number {
    return 29900;
  }

  protected get includedSeats(): number {
    return 50;
  }

  protected get extraSeatPriceCents(): number {
    return 400;
  }
}

function createPlan(planCode: PlanCode): SubscriptionPlan {
  switch (planCode) {
    case "starter":
      return new StarterPlan();
    case "pro":
      return new ProPlan();
    case "enterprise":
      return new EnterprisePlan();
  }
}

function quoteMonthlyInvoice(planCode: PlanCode, activeSeats: number): string {
  const plan = createPlan(planCode);
  const dollars = (plan.monthlyInvoiceCents(activeSeats) / 100).toFixed(2);
  return `${plan.displayName}: $${dollars}`;
}

console.log(quoteMonthlyInvoice("pro", 12));
```

### 2.4 Why this difference matters

In the good form, the variation between plans is represented directly as fields on `SubscriptionPlan`. The calculation remains in one place, and the plan catalog shows all fixed plan data together.

In the less maintainable form, each subclass exists only to return constants. The inheritance hierarchy suggests that each plan has distinct behavior, but it does not. Adding a new plan requires adding a new subclass and updating the factory, even though the real change is only another row of data.

### 2.5 Structural references

```text
Good: billing-service > billing > plan.ts > planCatalog > plan fields
Less maintainable: billing-service > billing > plan.ts > createPlan > constant-only subclasses
```

The relevant structural difference is that the good form keeps plan differences as data entries in one catalog, while the less maintainable form spreads the same kind of differences across multiple subclasses and a factory function.

## 3. Boundaries and distinctions

Replace Subclass with Fields applies when subclasses differ only by constant values or simple type data and share the same behavior. It does not apply when subclasses enforce different invariants, override algorithms, integrate with different dependencies, or provide behavior that callers intentionally use polymorphically.

The subclass form can be appropriate if each plan is expected to gain distinct behavior soon, or if an existing framework requires separate subclasses for registration, serialization, or dependency injection. Even then, avoid creating subclasses just to hold labels, prices, limits, or other fixed values.

This refactoring is the opposite direction of introducing subclasses for meaningful behavioral variation. It also differs from merely adding an enum or type code: the point is not the field itself, but removing a hierarchy whose subclasses do not justify their existence through different behavior.
