# Replace Command with Function

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.2.10
- **Aliases:** None
- **Definition:** Collapse a command object into a function when the object no longer earns its state or extensibility cost. It restores a direct, readable operation.
- **Why it matters:** It removes an unnecessary object layer so readers can see the operation, its inputs, and its result without jumping through construction and `execute` indirection.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing service calculates the renewal quote for a customer changing or extending a subscription plan. The calculation is immediate and has no need for queuing, undo, retries, or polymorphic command handling.

### 2.2 Good form

```ts
type Plan = {
  id: string;
  monthlyPriceCents: number;
};

type Customer = {
  id: string;
  loyaltyDiscountPercent: number;
};

type RenewalQuote = {
  customerId: string;
  planId: string;
  months: number;
  totalCents: number;
};

function calculateRenewalQuote(
  customer: Customer,
  plan: Plan,
  months: number
): RenewalQuote {
  const subtotalCents = plan.monthlyPriceCents * months;
  const discountCents = Math.round(
    subtotalCents * (customer.loyaltyDiscountPercent / 100)
  );

  return {
    customerId: customer.id,
    planId: plan.id,
    months,
    totalCents: subtotalCents - discountCents,
  };
}

const customer: Customer = {
  id: "cust_123",
  loyaltyDiscountPercent: 10,
};

const plan: Plan = {
  id: "pro",
  monthlyPriceCents: 3000,
};

const quote = calculateRenewalQuote(customer, plan, 12);
console.log(quote.totalCents);
```

### 2.3 Less maintainable form

```ts
type Plan = {
  id: string;
  monthlyPriceCents: number;
};

type Customer = {
  id: string;
  loyaltyDiscountPercent: number;
};

type RenewalQuote = {
  customerId: string;
  planId: string;
  months: number;
  totalCents: number;
};

class CalculateRenewalQuoteCommand {
  constructor(
    private readonly customer: Customer,
    private readonly plan: Plan,
    private readonly months: number
  ) {}

  execute(): RenewalQuote {
    const subtotalCents = this.plan.monthlyPriceCents * this.months;
    const discountCents = Math.round(
      subtotalCents * (this.customer.loyaltyDiscountPercent / 100)
    );

    return {
      customerId: this.customer.id,
      planId: this.plan.id,
      months: this.months,
      totalCents: subtotalCents - discountCents,
    };
  }
}

const customer: Customer = {
  id: "cust_123",
  loyaltyDiscountPercent: 10,
};

const plan: Plan = {
  id: "pro",
  monthlyPriceCents: 3000,
};

const quote = new CalculateRenewalQuoteCommand(customer, plan, 12).execute();
console.log(quote.totalCents);
```

### 2.4 Why this difference matters

The good form makes the operation explicit: `calculateRenewalQuote(customer, plan, 12)` names the work and passes all required inputs directly. The less maintainable form stores those same inputs in a short-lived object, then immediately calls `execute`, adding ceremony without adding behavior. Since there is no command queue, undo history, delayed execution, or polymorphic dispatcher, the command object only hides a simple calculation behind allocation and method indirection.

### 2.5 Structural references

```text
Good: billing-service > pricing > renewalQuote.ts > function calculateRenewalQuote > renewal quote calculation
Less maintainable: billing-service > pricing > renewalQuote.ts > function execute > renewal quote calculation
```

The relevant structural difference is that the good form places the calculation in the directly named operation, while the less maintainable form buries the same operation inside a command object's `execute` method.

## 3. Boundaries and distinctions

Replace Command with Function does not apply when the command object is carrying useful design weight. Keep a command object when it supports delayed execution, job queues, retries, undo and redo, audit trails, permissions, batching, composition, dependency injection, or polymorphic handling of many command types through a shared interface.

The less maintainable form can be appropriate when callers need to treat operations as first-class objects rather than immediate function calls. For example, a payment command that can be serialized, scheduled, retried, cancelled, logged, or replayed may justify its object structure.

This refactoring is specifically about removing an unnecessary command object and replacing it with a direct function. It is not merely renaming `execute`, inlining all call sites, or rejecting the Command pattern in general. The Command pattern remains useful when object identity, lifecycle, or uniform handling of actions matters.
