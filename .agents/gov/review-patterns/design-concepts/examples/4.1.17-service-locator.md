# Service Locator

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.1.17
- **Aliases:** None
- **Definition:** An object explicitly asks a locator for a service. It centralizes lookup but hides the requested dependency from the constructor; it is not inherently an anti-pattern in Fowler's account.
- **Why it matters:** Service Locator can make lookup rules easier to read and change by putting service selection in one place, but readers must inspect method bodies to discover which services an object uses.
- **Related concepts:** Dependency Injection

## 2. Example

### 2.1 Scenario

A checkout component calculates a receipt total using a tax-rate service selected for the current store region. The intended behavior is the same in both examples: compute subtotal, tax, and total.

### 2.2 Good form

```ts
type Region = "US" | "EU";

interface TaxRateService {
  rateFor(region: Region): number;
}

class StandardTaxRateService implements TaxRateService {
  rateFor(region: Region): number {
    return region === "US" ? 0.07 : 0.2;
  }
}

class ServiceLocator {
  private services = new Map<string, unknown>();

  register<T>(name: string, service: T): void {
    this.services.set(name, service);
  }

  get<T>(name: string): T {
    const service = this.services.get(name);
    if (service === undefined) {
      throw new Error(`Service not registered: ${name}`);
    }
    return service as T;
  }
}

type CartLine = {
  sku: string;
  unitPrice: number;
  quantity: number;
};

type Receipt = {
  subtotal: number;
  tax: number;
  total: number;
};

class CheckoutSummary {
  constructor(private readonly locator: ServiceLocator) {}

  summarize(lines: CartLine[], region: Region): Receipt {
    const taxRates = this.locator.get<TaxRateService>("TaxRateService");

    const subtotal = lines.reduce(
      (sum, line) => sum + line.unitPrice * line.quantity,
      0,
    );
    const tax = subtotal * taxRates.rateFor(region);

    return {
      subtotal,
      tax,
      total: subtotal + tax,
    };
  }
}

const locator = new ServiceLocator();
locator.register<TaxRateService>("TaxRateService", new StandardTaxRateService());

const checkout = new CheckoutSummary(locator);
const receipt = checkout.summarize(
  [{ sku: "BOOK", unitPrice: 30, quantity: 2 }],
  "EU",
);

console.log(receipt);
```

### 2.3 Less maintainable form

```ts
type Region = "US" | "EU";

interface TaxRateService {
  rateFor(region: Region): number;
}

class StandardTaxRateService implements TaxRateService {
  rateFor(region: Region): number {
    return region === "US" ? 0.07 : 0.2;
  }
}

type CartLine = {
  sku: string;
  unitPrice: number;
  quantity: number;
};

type Receipt = {
  subtotal: number;
  tax: number;
  total: number;
};

class CheckoutSummary {
  summarize(lines: CartLine[], region: Region): Receipt {
    const taxRates = new StandardTaxRateService();

    const subtotal = lines.reduce(
      (sum, line) => sum + line.unitPrice * line.quantity,
      0,
    );
    const tax = subtotal * taxRates.rateFor(region);

    return {
      subtotal,
      tax,
      total: subtotal + tax,
    };
  }
}

const checkout = new CheckoutSummary();
const receipt = checkout.summarize(
  [{ sku: "BOOK", unitPrice: 30, quantity: 2 }],
  "EU",
);

console.log(receipt);
```

### 2.4 Why this difference matters

In the good form, `CheckoutSummary` explicitly asks a `ServiceLocator` for `TaxRateService`. The lookup rule is centralized in the locator setup, so replacing `StandardTaxRateService` with another implementation does not require editing the checkout calculation.

In the less maintainable form, `CheckoutSummary` directly constructs `StandardTaxRateService`. That preserves behavior, but it spreads service selection into the consumer. Any change to how tax-rate services are chosen must now touch checkout code instead of only the lookup configuration.

### 2.5 Structural references

```text
Good: shop > checkout > checkoutSummary.ts > CheckoutSummary.summarize > locator.get("TaxRateService")
Less maintainable: shop > checkout > checkoutSummary.ts > CheckoutSummary.summarize > new StandardTaxRateService()
```

The relevant structural difference is where service lookup occurs. The good form routes lookup through a locator target, while the less maintainable form embeds concrete service construction directly at the use site.

## 3. Boundaries and distinctions

Service Locator applies when an object explicitly asks another object for a named or typed service. It does not apply to ordinary object creation when the created object is local data rather than a shared or replaceable service.

The less maintainable form can be appropriate when the dependency is trivial, stable, and not expected to vary by environment, test, tenant, or runtime configuration. Direct construction is often simpler when central lookup would add indirection without a real change point.

Service Locator differs from Dependency Injection. With Dependency Injection, the needed service is supplied to the object, usually through a constructor, method, or property, so the dependency is visible from the outside. With Service Locator, the object receives or accesses a locator and asks for the service itself, which centralizes lookup but makes the exact service dependency less visible in the object's public construction contract.
