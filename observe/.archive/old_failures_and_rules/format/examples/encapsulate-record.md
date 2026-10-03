# Encapsulate Record

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.2
- **Aliases:** replace record with data class
- **Definition:** Replace direct access to a data record with an object that controls its fields and operations. It limits representation leakage and gives the model behavior a home.
- **Why it matters:** It makes code easier to read and change by moving field-specific rules, derived values, and updates behind named operations instead of spreading record-shape knowledge across callers.
- **Related concepts:** Data Class

## 2. Example

### 2.1 Scenario

A shipping workflow needs to print a customer mailing label and award loyalty points when an order is prepared. The customer data originally arrives as a plain record from storage.

### 2.2 Good form

```ts
type CustomerRecord = {
  id: string;
  name: string;
  address: {
    street: string;
    city: string;
    postalCode: string;
  };
  loyaltyPoints: number;
};

class CustomerProfile {
  private constructor(private readonly record: CustomerRecord) {}

  static from(record: CustomerRecord): CustomerProfile {
    return new CustomerProfile({
      ...record,
      address: { ...record.address },
    });
  }

  get id(): string {
    return this.record.id;
  }

  awardLoyaltyPoints(points: number): void {
    if (points < 0) {
      throw new Error("Loyalty points must not be negative.");
    }

    this.record.loyaltyPoints += points;
  }

  formattedMailingLabel(): string {
    const name = this.record.name.trim();
    const { street, city, postalCode } = this.record.address;

    return `${name}\n${street}\n${city}, ${postalCode}`;
  }

  toRecord(): CustomerRecord {
    return {
      ...this.record,
      address: { ...this.record.address },
    };
  }
}

function prepareShipmentNotice(customer: CustomerProfile, orderId: string): string {
  customer.awardLoyaltyPoints(10);

  return `Order ${orderId} will ship to:\n${customer.formattedMailingLabel()}`;
}

const customer = CustomerProfile.from({
  id: "cus-123",
  name: "  Ada Lovelace  ",
  address: {
    street: "12 Algorithm Ave",
    city: "London",
    postalCode: "SW1A 1AA",
  },
  loyaltyPoints: 40,
});

console.log(prepareShipmentNotice(customer, "ord-9001"));
```

### 2.3 Less maintainable form

```ts
type CustomerRecord = {
  id: string;
  name: string;
  address: {
    street: string;
    city: string;
    postalCode: string;
  };
  loyaltyPoints: number;
};

function prepareShipmentNotice(customer: CustomerRecord, orderId: string): string {
  customer.loyaltyPoints += 10;

  const name = customer.name.trim();
  const street = customer.address.street;
  const city = customer.address.city;
  const postalCode = customer.address.postalCode;

  return `Order ${orderId} will ship to:\n${name}\n${street}\n${city}, ${postalCode}`;
}

const customer: CustomerRecord = {
  id: "cus-123",
  name: "  Ada Lovelace  ",
  address: {
    street: "12 Algorithm Ave",
    city: "London",
    postalCode: "SW1A 1AA",
  },
  loyaltyPoints: 40,
};

console.log(prepareShipmentNotice(customer, "ord-9001"));
```

### 2.4 Why this difference matters

In the good form, callers ask `CustomerProfile` to perform customer-specific operations: award points and format a mailing label. The raw record shape is hidden behind methods, so changes such as renaming `postalCode`, splitting the address into multiple fields, or adding loyalty-point validation are localized inside `CustomerProfile`.

In the less maintainable form, `prepareShipmentNotice` knows the exact nested record layout and mutates it directly. Every caller that formats an address or adjusts points must duplicate the same field access and business rules, making representation changes more expensive and error-prone.

### 2.5 Structural references

```text
Good: shipping-service > customers > customerProfile.ts > CustomerProfile > formattedMailingLabel
Less maintainable: shipping-service > customers > shipmentNotice.ts > prepareShipmentNotice > customer.address fields
```

The good structure places record access inside a dedicated object boundary, with functions depending on object operations. The less maintainable structure lets an application function reach directly into the record fields.

## 3. Boundaries and distinctions

Encapsulate Record is most useful when a record is shared across multiple callers, has nested structure, needs validation, or has behavior naturally associated with its data. It does not add much value for a short-lived local record, a simple serialization shape at an API boundary, or a one-off data transfer object that is only copied from one layer to another.

The less maintainable form can be appropriate when the record is deliberately just a transparent interchange format, such as JSON decoded from a request or a database row before it is converted into a domain object.

This refactoring is related to **Data Class**, but they are not the same. Encapsulate Record may start by creating a small class around data, but the goal is to control representation and give behavior a home. A Data Class is mainly a passive holder of fields and accessors. If the new object never gains meaningful operations or invariants, it may remain a Data Class rather than fully realizing the benefit of Encapsulate Record.
