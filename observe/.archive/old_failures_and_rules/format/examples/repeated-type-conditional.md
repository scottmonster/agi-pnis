# Repeated Type Conditional

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.3.3
- **Aliases:** repeated switch, switch statements
- **Definition:** Similar branches repeatedly select behavior from a type, state, or mode code. Every new variant requires finding all of the decisions.
- **Why it matters:** Repeated type-based decisions scatter variant-specific behavior across the codebase, making it harder to understand what each variant does and easier to miss a required change when a new variant is added.
- **Related concepts:** Replace Conditional with Polymorphism

## 2. Example

### 2.1 Scenario

A billing service calculates subscription invoice totals and support response times for customers on free, pro, and enterprise plans.

### 2.2 Good form

```ts
type Money = number;

interface SubscriptionPlan {
  readonly name: string;
  monthlyCharge(seats: number): Money;
  supportResponseHours(): number;
}

class FreePlan implements SubscriptionPlan {
  readonly name = "free";

  monthlyCharge(_seats: number): Money {
    return 0;
  }

  supportResponseHours(): number {
    return 72;
  }
}

class ProPlan implements SubscriptionPlan {
  readonly name = "pro";

  monthlyCharge(seats: number): Money {
    return 20 * seats;
  }

  supportResponseHours(): number {
    return 24;
  }
}

class EnterprisePlan implements SubscriptionPlan {
  readonly name = "enterprise";

  monthlyCharge(seats: number): Money {
    return 15 * seats + 500;
  }

  supportResponseHours(): number {
    return 4;
  }
}

class Customer {
  constructor(
    readonly name: string,
    readonly seats: number,
    private readonly plan: SubscriptionPlan,
  ) {}

  invoiceSummary(): {
    customer: string;
    plan: string;
    total: Money;
    responseHours: number;
  } {
    return {
      customer: this.name,
      plan: this.plan.name,
      total: this.plan.monthlyCharge(this.seats),
      responseHours: this.plan.supportResponseHours(),
    };
  }
}

const customers = [
  new Customer("Northwind", 3, new ProPlan()),
  new Customer("Contoso", 50, new EnterprisePlan()),
  new Customer("Solo Dev", 1, new FreePlan()),
];

const summaries = customers.map((customer) => customer.invoiceSummary());
console.log(summaries);
```

### 2.3 Less maintainable form

```ts
type Money = number;
type PlanCode = "free" | "pro" | "enterprise";

interface CustomerRecord {
  name: string;
  seats: number;
  plan: PlanCode;
}

function monthlyCharge(customer: CustomerRecord): Money {
  switch (customer.plan) {
    case "free":
      return 0;
    case "pro":
      return 20 * customer.seats;
    case "enterprise":
      return 15 * customer.seats + 500;
  }
}

function supportResponseHours(customer: CustomerRecord): number {
  switch (customer.plan) {
    case "free":
      return 72;
    case "pro":
      return 24;
    case "enterprise":
      return 4;
  }
}

function invoiceSummary(customer: CustomerRecord): {
  customer: string;
  plan: PlanCode;
  total: Money;
  responseHours: number;
} {
  return {
    customer: customer.name,
    plan: customer.plan,
    total: monthlyCharge(customer),
    responseHours: supportResponseHours(customer),
  };
}

const customers: CustomerRecord[] = [
  { name: "Northwind", seats: 3, plan: "pro" },
  { name: "Contoso", seats: 50, plan: "enterprise" },
  { name: "Solo Dev", seats: 1, plan: "free" },
];

const summaries = customers.map(invoiceSummary);
console.log(summaries);
```

### 2.4 Why this difference matters

In the good form, each subscription variant owns its own behavior. To add a new plan, the change is localized to a new `SubscriptionPlan` implementation and the code that chooses that implementation.

In the less maintainable form, the same plan code is inspected in multiple functions. Adding a new plan requires finding every `switch` over `customer.plan` and updating each one consistently. The risk is not the existence of one conditional, but the repetition of the same type-based decision across separate behaviors.

### 2.5 Structural references

```text
Good: SubscriptionPlan.monthlyCharge and supportResponseHours
Less maintainable: monthlyCharge and supportResponseHours > repeated plan.kind switches
```

The good form places plan-specific behavior behind the `SubscriptionPlan` target, so callers ask the selected plan object for behavior. The less maintainable form keeps the plan as a code value and repeats selection logic in separate functions such as `monthlyCharge` and `supportResponseHours`.

## 3. Boundaries and distinctions

This concept does not apply to every conditional. A single, local, easy-to-read conditional over a stable value is often fine. A switch can also be appropriate at a system boundary, such as parsing an API payload, mapping database values, or constructing the right object before behavior is delegated elsewhere.

The less maintainable form may be acceptable when the set of variants is genuinely closed, the behavior is trivial, and all decisions are intentionally kept in one small location. It becomes a smell when similar conditionals spread across functions or files and must be kept synchronized.

Repeated Type Conditional is the smell that motivates the refactoring named Replace Conditional with Polymorphism. The smell is the scattered repeated selection by type, state, or mode code. The refactoring is one common remedy: move each variant's behavior into a type or object that represents that variant.
