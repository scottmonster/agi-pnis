# Extract Class

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.1
- **Aliases:** None
- **Definition:** Move a coherent subset of fields and behavior into a new class. It reduces a class's responsibilities and gives the extracted concept a name.
- **Why it matters:** It makes code easier to read and change by separating one concept from another. A class with fewer responsibilities is easier to understand, test, and extend without modifying unrelated behavior.
- **Related concepts:** Large Class, God Class

## 2. Example

### 2.1 Scenario

A billing service prints mailing labels for customers. Address data and address-specific formatting rules have grown inside the customer model.

### 2.2 Good form

```ts
type CountryCode = "US" | "CA";

class BillingAddress {
  constructor(
    private readonly street: string,
    private readonly city: string,
    private readonly region: string,
    private readonly postalCode: string,
    private readonly country: CountryCode,
  ) {}

  formatForMailing(): string {
    return [
      this.street,
      `${this.city}, ${this.region} ${this.postalCode}`,
      this.country,
    ].join("\n");
  }

  isDomestic(): boolean {
    return this.country === "US";
  }
}

class Customer {
  constructor(
    private readonly id: string,
    private readonly name: string,
    private readonly email: string,
    private readonly billingAddress: BillingAddress,
  ) {}

  statementRecipient(): string {
    return `${this.name}\n${this.billingAddress.formatForMailing()}`;
  }

  shipsDomestically(): boolean {
    return this.billingAddress.isDomestic();
  }
}

function createStatementRecipient(): string {
  const address = new BillingAddress(
    "500 Market St",
    "San Francisco",
    "CA",
    "94105",
    "US",
  );

  const customer = new Customer(
    "cus_123",
    "Avery Chen",
    "avery@example.com",
    address,
  );

  return customer.statementRecipient();
}
```

### 2.3 Less maintainable form

```ts
type CountryCode = "US" | "CA";

class Customer {
  constructor(
    private readonly id: string,
    private readonly name: string,
    private readonly email: string,
    private readonly billingStreet: string,
    private readonly billingCity: string,
    private readonly billingRegion: string,
    private readonly billingPostalCode: string,
    private readonly billingCountry: CountryCode,
  ) {}

  statementRecipient(): string {
    return `${this.name}\n${this.formatBillingAddressForMailing()}`;
  }

  shipsDomestically(): boolean {
    return this.isDomesticBillingAddress();
  }

  private formatBillingAddressForMailing(): string {
    return [
      this.billingStreet,
      `${this.billingCity}, ${this.billingRegion} ${this.billingPostalCode}`,
      this.billingCountry,
    ].join("\n");
  }

  private isDomesticBillingAddress(): boolean {
    return this.billingCountry === "US";
  }
}

function createStatementRecipient(): string {
  const customer = new Customer(
    "cus_123",
    "Avery Chen",
    "avery@example.com",
    "500 Market St",
    "San Francisco",
    "CA",
    "94105",
    "US",
  );

  return customer.statementRecipient();
}
```

### 2.4 Why this difference matters

In the good form, address fields and address behavior are grouped under `BillingAddress`, giving that concept a clear name and a single place to change address formatting or country rules. `Customer` no longer needs to know the details of how an address is formatted or classified. In the less maintainable form, customer identity, contact data, address storage, and address behavior all compete inside one class, so every address-related change makes `Customer` larger and harder to reason about.

### 2.5 Structural references

```text
Good: billing-service > domain > customer.ts > Customer.statementRecipient > BillingAddress
Less maintainable: billing-service > domain > customer.ts > Customer.statementRecipient > billing address fields and helpers
```

The relevant structural difference is that the good form introduces a separate target for the address concept, while the less maintainable form keeps the same concept embedded as fields and helper functions inside `Customer`.

## 3. Boundaries and distinctions

Extract Class applies when a subset of fields and methods forms a cohesive concept that can be named and changed independently. It does not apply when the data and behavior are not cohesive, when the original class is already small and clear, or when extraction would create a class with no meaningful responsibility.

The less maintainable form can be acceptable for very small, stable code where the embedded data has no behavior and no expected variation. For example, a short data transfer object may not benefit from another class if it only carries values across a boundary.

Extract Class is a refactoring, while Large Class and God Class are smells that may motivate it. A Large Class has accumulated too much code or data. A God Class centralizes too many system responsibilities. Extract Class is one possible remedy when part of that excess responsibility can be separated into a coherent abstraction.
