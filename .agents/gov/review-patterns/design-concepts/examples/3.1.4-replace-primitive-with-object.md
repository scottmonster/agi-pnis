# Replace Primitive with Object

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.4
- **Aliases:** replace data value with object, replace type code with class
- **Definition:** Represent a domain value with a small type rather than a raw primitive. It gives validation, formatting, and rules a single explicit home.
- **Why it matters:** It makes domain meaning visible in code and keeps validation, formatting, comparison, and rule changes near the value they describe instead of scattering them across callers.
- **Related concepts:** Primitive Obsession, Value Object

## 2. Example

### 2.1 Scenario

A subscription checkout receives a plan code from a request and returns a price quote. The supported plan codes, display labels, and prices must stay consistent everywhere the code is used.

### 2.2 Good form

```ts
type PlanValue = "basic" | "pro" | "enterprise";

interface SubscriptionQuote {
  plan: PlanValue;
  displayName: string;
  monthlyPriceCents: number;
  currency: "USD";
}

class PlanCode {
  private constructor(private readonly value: PlanValue) {}

  static parse(input: string): PlanCode {
    const normalized = input.trim().toLowerCase();

    if (
      normalized !== "basic" &&
      normalized !== "pro" &&
      normalized !== "enterprise"
    ) {
      throw new Error(`Unsupported subscription plan: ${input}`);
    }

    return new PlanCode(normalized);
  }

  toValue(): PlanValue {
    return this.value;
  }

  displayName(): string {
    switch (this.value) {
      case "basic":
        return "Basic";
      case "pro":
        return "Pro";
      case "enterprise":
        return "Enterprise";
    }
  }

  monthlyPriceCents(): number {
    switch (this.value) {
      case "basic":
        return 1_200;
      case "pro":
        return 2_900;
      case "enterprise":
        return 9_900;
    }
  }
}

function quoteSubscription(rawPlanCode: string): SubscriptionQuote {
  const planCode = PlanCode.parse(rawPlanCode);

  return {
    plan: planCode.toValue(),
    displayName: planCode.displayName(),
    monthlyPriceCents: planCode.monthlyPriceCents(),
    currency: "USD",
  };
}

console.log(quoteSubscription(" Pro "));
```

### 2.3 Less maintainable form

```ts
type PlanCode = string;

interface SubscriptionQuote {
  plan: PlanCode;
  displayName: string;
  monthlyPriceCents: number;
  currency: "USD";
}

function normalizePlanCode(input: string): string {
  return input.trim().toLowerCase();
}

function isSupportedPlanCode(planCode: string): boolean {
  return (
    planCode === "basic" ||
    planCode === "pro" ||
    planCode === "enterprise"
  );
}

function displayNameForPlan(planCode: string): string {
  switch (planCode) {
    case "basic":
      return "Basic";
    case "pro":
      return "Pro";
    case "enterprise":
      return "Enterprise";
    default:
      throw new Error(`Unsupported subscription plan: ${planCode}`);
  }
}

function monthlyPriceCentsForPlan(planCode: string): number {
  switch (planCode) {
    case "basic":
      return 1_200;
    case "pro":
      return 2_900;
    case "enterprise":
      return 9_900;
    default:
      throw new Error(`Unsupported subscription plan: ${planCode}`);
  }
}

function quoteSubscription(rawPlanCode: string): SubscriptionQuote {
  const planCode = normalizePlanCode(rawPlanCode);

  if (!isSupportedPlanCode(planCode)) {
    throw new Error(`Unsupported subscription plan: ${rawPlanCode}`);
  }

  return {
    plan: planCode,
    displayName: displayNameForPlan(planCode),
    monthlyPriceCents: monthlyPriceCentsForPlan(planCode),
    currency: "USD",
  };
}

console.log(quoteSubscription(" Pro "));
```

### 2.4 Why this difference matters

In the good form, `PlanCode` is the explicit domain value. It owns normalization, validation, display formatting, and pricing rules, so code that accepts a `PlanCode` can trust that the value is supported. Adding a new plan or changing a plan label has one obvious home.

In the less maintainable form, the plan is still just a string. The type alias gives a name, but it does not prevent unsupported strings or keep related rules together. Each function must remember to normalize, validate, and handle the same set of literals.

### 2.5 Structural references

```text
Good: checkout-api > subscriptions > pricing.ts > quoteSubscription > PlanCode
Less maintainable: checkout-api > subscriptions > pricing.ts > quoteSubscription > rawPlanCode string
```

The structural difference is that the good form introduces a domain object at the point where the request value becomes meaningful business data. The less maintainable form keeps the value as a raw primitive and relies on separate helper functions to interpret it.

## 3. Boundaries and distinctions

Replace Primitive with Object is useful when a primitive carries domain meaning and has behavior or rules attached to it, such as validation, formatting, allowed values, parsing, comparison, or calculations.

It does not need to be applied to every number or string. A local loop counter, a temporary display string, or a value simply passed through to an external API may be clearer as a primitive. The less maintainable form can also be acceptable for very small code paths where the value has no domain rules and is unlikely to grow.

This refactoring addresses the symptom often called Primitive Obsession, where important concepts are represented only by strings, numbers, or booleans. It is related to Value Object, but not identical. A value object usually emphasizes immutability, equality by value, and lack of identity. Replace Primitive with Object is the refactoring move that introduces such a type, even if the first version only centralizes validation and behavior.
