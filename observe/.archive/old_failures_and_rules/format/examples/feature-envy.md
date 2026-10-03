# Feature Envy

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.6
- **Aliases:** None
- **Definition:** A function uses another object's data more than its own. Behavior is likely located away from the data and invariants it needs.
- **Why it matters:** It makes code harder to read and change because the reader must understand one object while looking at behavior located somewhere else. Changes to the envied object's data or rules can require edits in unrelated functions.
- **Related concepts:** Move Function

## 2. Example

### 2.1 Scenario

A billing system prints an invoice line for a customer's subscription. The monthly charge depends on subscription fields such as plan name, seat count, base price, and discount.

### 2.2 Good form

```ts
class Subscription {
  constructor(
    private readonly planName: string,
    private readonly baseMonthlyPriceCents: number,
    private readonly seatCount: number,
    private readonly discountPercent: number
  ) {}

  monthlyChargeCents(): number {
    const subtotal = this.baseMonthlyPriceCents * this.seatCount;
    return Math.round(subtotal * (100 - this.discountPercent) / 100);
  }

  invoiceDescription(): string {
    return `${this.planName} - ${this.seatCount} seats`;
  }
}

class Customer {
  constructor(
    public readonly name: string,
    private readonly subscription: Subscription
  ) {}

  currentSubscription(): Subscription {
    return this.subscription;
  }
}

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function buildInvoiceLine(customer: Customer): string {
  const subscription = customer.currentSubscription();

  return `${customer.name}: ${subscription.invoiceDescription()} - ${formatCents(
    subscription.monthlyChargeCents()
  )}`;
}

const customer = new Customer(
  "Acme Corp",
  new Subscription("Pro", 2_500, 4, 10)
);

console.log(buildInvoiceLine(customer));
```

### 2.3 Less maintainable form

```ts
class Subscription {
  constructor(
    private readonly planName: string,
    private readonly baseMonthlyPriceCents: number,
    private readonly seatCount: number,
    private readonly discountPercent: number
  ) {}

  getPlanName(): string {
    return this.planName;
  }

  getBaseMonthlyPriceCents(): number {
    return this.baseMonthlyPriceCents;
  }

  getSeatCount(): number {
    return this.seatCount;
  }

  getDiscountPercent(): number {
    return this.discountPercent;
  }
}

class Customer {
  constructor(
    public readonly name: string,
    private readonly subscription: Subscription
  ) {}

  currentSubscription(): Subscription {
    return this.subscription;
  }
}

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function buildInvoiceLine(customer: Customer): string {
  const subscription = customer.currentSubscription();

  const subtotal =
    subscription.getBaseMonthlyPriceCents() * subscription.getSeatCount();
  const monthlyCharge = Math.round(
    subtotal * (100 - subscription.getDiscountPercent()) / 100
  );
  const description = `${subscription.getPlanName()} - ${subscription.getSeatCount()} seats`;

  return `${customer.name}: ${description} - ${formatCents(monthlyCharge)}`;
}

const customer = new Customer(
  "Acme Corp",
  new Subscription("Pro", 2_500, 4, 10)
);

console.log(buildInvoiceLine(customer));
```

### 2.4 Why this difference matters

In the good form, the charge calculation and invoice description are close to the subscription data and rules they depend on. If the subscription pricing rule changes, the change is localized to `Subscription`.

In the less maintainable form, `buildInvoiceLine` repeatedly asks `Subscription` for its internal facts and performs subscription-specific behavior itself. That function envies `Subscription`: it knows too much about the subscription's structure and pricing rules, so subscription changes can ripple into invoice formatting code.

### 2.5 Structural references

```text
Good: Subscription.proratedChargeCents > own renewal data
Less maintainable: InvoiceCalculator.proratedSubscriptionCharge > subscription field access
```

The relevant structural difference is that the subscription-specific calculation is located with the subscription target in the good form, while the less maintainable form places that behavior in an invoice-building function that mainly manipulates subscription data.

## 3. Boundaries and distinctions

Feature Envy does not apply merely because a function calls another object. It becomes a smell when the function performs behavior that is mostly about another object's data, rules, or invariants.

The less maintainable form can be appropriate when the function is intentionally an adapter, mapper, serializer, report builder, or integration boundary that must assemble data from several sources without owning their domain rules. It can also be acceptable for simple data transfer objects that intentionally contain no behavior.

Feature Envy is closely related to Move Function. Feature Envy is the smell: behavior appears to be in the wrong place. Move Function is a common refactoring response: move the behavior to the object or module whose data it uses most. It is also distinct from general long method or poor naming issues, because the central problem is misplaced behavior relative to the data it depends on.
