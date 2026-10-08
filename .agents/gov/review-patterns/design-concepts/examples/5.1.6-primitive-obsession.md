# Primitive Obsession

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.6
- **Aliases:** None
- **Definition:** Domain concepts are repeatedly represented by raw strings, numbers, booleans, or collections. Rules and meaning spread because the type does not carry them.
- **Why it matters:** Primitive Obsession makes code harder to read and change because important domain meaning is hidden behind general-purpose types. Validation, formatting, and interpretation are duplicated across functions instead of being owned by one explicit domain type.
- **Related concepts:** Replace Primitive with Object

## 2. Example

### 2.1 Scenario

A checkout service creates shipping labels for orders shipped to the United States or Canada. Postal code normalization and country-specific validation must be applied consistently.

### 2.2 Good form

```ts
type CountryCode = "US" | "CA";

class PostalCode {
  private constructor(
    private readonly value: string,
    private readonly country: CountryCode
  ) {}

  static create(rawValue: string, country: CountryCode): PostalCode {
    const normalized = rawValue.trim().toUpperCase();

    if (country === "US" && !/^\d{5}(-\d{4})?$/.test(normalized)) {
      throw new Error("US postal code must be a ZIP or ZIP+4 code.");
    }

    if (country === "CA" && !/^[A-Z]\d[A-Z] \d[A-Z]\d$/.test(normalized)) {
      throw new Error("Canadian postal code must use the format A1A 1A1.");
    }

    return new PostalCode(normalized, country);
  }

  toString(): string {
    return this.value;
  }

  belongsTo(country: CountryCode): boolean {
    return this.country === country;
  }
}

interface ShippingAddress {
  recipient: string;
  street: string;
  city: string;
  country: CountryCode;
  postalCode: PostalCode;
}

function createShippingLabel(address: ShippingAddress): string {
  if (!address.postalCode.belongsTo(address.country)) {
    throw new Error("Postal code country does not match address country.");
  }

  return [
    address.recipient,
    address.street,
    `${address.city}, ${address.country} ${address.postalCode.toString()}`
  ].join("\n");
}

const postalCode = PostalCode.create("94105", "US");

const label = createShippingLabel({
  recipient: "Avery Chen",
  street: "100 Market St",
  city: "San Francisco",
  country: "US",
  postalCode
});

console.log(label);
```

### 2.3 Less maintainable form

```ts
type CountryCode = "US" | "CA";

interface ShippingAddress {
  recipient: string;
  street: string;
  city: string;
  country: CountryCode;
  postalCode: string;
}

function createShippingLabel(address: ShippingAddress): string {
  const normalizedPostalCode = address.postalCode.trim().toUpperCase();

  if (address.country === "US" && !/^\d{5}(-\d{4})?$/.test(normalizedPostalCode)) {
    throw new Error("US postal code must be a ZIP or ZIP+4 code.");
  }

  if (address.country === "CA" && !/^[A-Z]\d[A-Z] \d[A-Z]\d$/.test(normalizedPostalCode)) {
    throw new Error("Canadian postal code must use the format A1A 1A1.");
  }

  return [
    address.recipient,
    address.street,
    `${address.city}, ${address.country} ${normalizedPostalCode}`
  ].join("\n");
}

const label = createShippingLabel({
  recipient: "Avery Chen",
  street: "100 Market St",
  city: "San Francisco",
  country: "US",
  postalCode: "94105"
});

console.log(label);
```

### 2.4 Why this difference matters

In the good form, `PostalCode` carries the domain meaning, normalization rule, validation rule, and country relationship. Code that receives a `PostalCode` can rely on those guarantees instead of rechecking a plain string. In the less maintainable form, `postalCode` is just a `string`, so every function that uses it must remember how to trim it, uppercase it, validate it, and interpret it with the country. As more features need postal codes, the same rules are likely to spread and drift.

### 2.5 Structural references

```text
Good: checkout-service > domain > shipping.ts > createShippingLabel > PostalCode
Less maintainable: checkout-service > domain > shipping.ts > createShippingLabel > postalCode string
```

The structural difference is that the good form introduces a named domain type at the target location, while the less maintainable form keeps the domain concept as a raw primitive field and handles its rules inside the consuming function.

## 3. Boundaries and distinctions

Primitive Obsession does not apply every time code uses strings, numbers, booleans, or arrays. Primitives are appropriate for values with no special domain rules, short-lived local calculations, simple data transfer boundaries, or code where adding a domain type would not clarify behavior.

The less maintainable form can be acceptable for very small scripts, prototypes, or one-off parsing code where the primitive is used in only one place and has no stable business meaning. It becomes a smell when the same primitive represents an important concept across multiple functions or when validation, formatting, units, or allowed values are repeated.

Replace Primitive with Object is a common refactoring for this smell. Primitive Obsession is the problem: important concepts are hidden in raw types. Replace Primitive with Object is one solution: introduce a small domain object that owns the concept's rules and meaning.
