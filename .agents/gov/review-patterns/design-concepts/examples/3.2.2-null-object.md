# Null Object

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 3.2.2
- **Aliases:** Introduce Special Case when used as a transformation
- **Definition:** Supply an object with neutral or special-case behavior in place of absent data. It can remove scattered null checks, but must not conceal a meaningful absence or failure.
- **Why it matters:** It keeps the handling of an expected absence in one named object, making normal code paths easier to read and reducing repeated conditional logic that is easy to update inconsistently.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An order summary screen may be opened for either a registered customer or a guest checkout. Guest checkout is an expected case: it should show a generic name, use the standard price tier, and skip marketing email.

### 2.2 Good form

```ts
type PriceTier = "standard" | "vip";

interface Customer {
  displayName(): string;
  priceTier(): PriceTier;
  sendMarketingEmail(message: string): void;
}

class RegisteredCustomer implements Customer {
  constructor(
    private readonly name: string,
    private readonly tier: PriceTier,
    private readonly email: string
  ) {}

  displayName(): string {
    return this.name;
  }

  priceTier(): PriceTier {
    return this.tier;
  }

  sendMarketingEmail(message: string): void {
    console.log(`Sending to ${this.email}: ${message}`);
  }
}

class GuestCustomer implements Customer {
  displayName(): string {
    return "Guest";
  }

  priceTier(): PriceTier {
    return "standard";
  }

  sendMarketingEmail(_message: string): void {
    // Guest checkout has no email address by design.
  }
}

interface Order {
  id: string;
  total: number;
  customer: Customer;
}

function loadOrder(orderId: string): Order {
  const registeredCustomer =
    orderId === "registered"
      ? new RegisteredCustomer("Avery Chen", "vip", "avery@example.com")
      : new GuestCustomer();

  return {
    id: orderId,
    total: 120,
    customer: registeredCustomer
  };
}

function discountFor(tier: PriceTier): number {
  return tier === "vip" ? 0.15 : 0;
}

function renderOrderSummary(orderId: string): string {
  const order = loadOrder(orderId);
  const customer = order.customer;
  const discount = discountFor(customer.priceTier());

  customer.sendMarketingEmail("Thanks for your order.");

  return [
    `Order: ${order.id}`,
    `Customer: ${customer.displayName()}`,
    `Discount: ${discount * 100}%`,
    `Total: $${order.total}`
  ].join("\n");
}

console.log(renderOrderSummary("guest"));
```

### 2.3 Less maintainable form

```ts
type PriceTier = "standard" | "vip";

interface CustomerRecord {
  name: string;
  tier: PriceTier;
  email: string;
}

interface Order {
  id: string;
  total: number;
  customer: CustomerRecord | null;
}

function loadOrder(orderId: string): Order {
  const customer =
    orderId === "registered"
      ? {
          name: "Avery Chen",
          tier: "vip" as PriceTier,
          email: "avery@example.com"
        }
      : null;

  return {
    id: orderId,
    total: 120,
    customer
  };
}

function discountFor(tier: PriceTier): number {
  return tier === "vip" ? 0.15 : 0;
}

function renderOrderSummary(orderId: string): string {
  const order = loadOrder(orderId);

  const customerName = order.customer === null ? "Guest" : order.customer.name;
  const tier = order.customer === null ? "standard" : order.customer.tier;
  const discount = discountFor(tier);

  if (order.customer !== null) {
    console.log(`Sending to ${order.customer.email}: Thanks for your order.`);
  }

  return [
    `Order: ${order.id}`,
    `Customer: ${customerName}`,
    `Discount: ${discount * 100}%`,
    `Total: $${order.total}`
  ].join("\n");
}

console.log(renderOrderSummary("guest"));
```

### 2.4 Why this difference matters

The good form gives the expected guest case a real object with explicit behavior: guest name, standard tier, and no-op marketing email. The rendering function can describe the normal order-summary workflow without repeatedly asking whether a customer exists. When guest behavior changes, the change is localized to `GuestCustomer` instead of being spread across every caller that touches `customer`.

The less maintainable form preserves the same behavior, but the meaning of `null` must be rediscovered at each use site. Every new use of the customer must remember the same fallback rules, which increases the chance that one branch will use a different guest name, discount tier, or email policy.

### 2.5 Structural references

```text
Good: order-ui > orders > orderSummary.ts > renderOrderSummary > GuestCustomer
Less maintainable: order-ui > orders > orderSummary.ts > renderOrderSummary > nullable Order.customer checks
```

The good form makes `customer` always refer to an object that answers the customer protocol, with absence represented by `GuestCustomer`. The less maintainable form makes `customer` a nullable value, so each function that uses it must branch around the missing object.

## 3. Boundaries and distinctions

Null Object fits when absence is expected and has safe, well-defined behavior, such as a guest user, empty logger, zero discount, or no-op notification target. It should not be used when absence is meaningful information that callers must handle differently, such as a missing payment method, failed lookup, permission denial, or corrupted input. In those cases, returning `null`, `undefined`, `Result`, `Either`, or throwing an error may communicate the situation more honestly.

The less maintainable nullable form can be appropriate at system boundaries, such as database rows, JSON payloads, or APIs where missing data must be represented directly. A common approach is to translate that boundary representation into a Null Object inside the domain model only when the absence has a legitimate neutral behavior.

Null Object is not just a default value. A default value is often a primitive fallback, while a Null Object implements the same interface as the real object and centralizes special-case behavior. It is also not a way to ignore errors: a no-op object is maintainable only when doing nothing is the intended behavior, not when it hides a failure that should be visible.
