# Message Chain

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.7
- **Aliases:** None
- **Definition:** A client reaches through a chain such as `a.getB().getC()`. It exposes several internal relationships and makes structural changes ripple outward.
- **Why it matters:** Message chains make client code depend on the shape of several collaborating objects, so a change to an intermediate relationship can force updates in many callers. Shorter, intention-revealing methods keep clients focused on the information they need rather than on how to navigate to it.
- **Related concepts:** Hide Delegate, Law of Demeter

## 2. Example

### 2.1 Scenario

A checkout service calculates whether an order needs an international shipping surcharge. The decision depends on the customer's shipping country.

### 2.2 Good form

```ts
type CountryCode = "US" | "CA" | "GB";

class Address {
  constructor(private readonly countryCode: CountryCode) {}

  getCountryCode(): CountryCode {
    return this.countryCode;
  }
}

class Customer {
  constructor(private readonly shippingAddress: Address) {}

  getShippingAddress(): Address {
    return this.shippingAddress;
  }
}

class Order {
  constructor(private readonly customer: Customer) {}

  shippingCountry(): CountryCode {
    return this.customer.getShippingAddress().getCountryCode();
  }
}

function calculateInternationalSurcharge(order: Order): number {
  return order.shippingCountry() === "US" ? 0 : 15;
}

const order = new Order(new Customer(new Address("CA")));
console.log(calculateInternationalSurcharge(order));
```

### 2.3 Less maintainable form

```ts
type CountryCode = "US" | "CA" | "GB";

class Address {
  constructor(private readonly countryCode: CountryCode) {}

  getCountryCode(): CountryCode {
    return this.countryCode;
  }
}

class Customer {
  constructor(private readonly shippingAddress: Address) {}

  getShippingAddress(): Address {
    return this.shippingAddress;
  }
}

class Order {
  constructor(private readonly customer: Customer) {}

  getCustomer(): Customer {
    return this.customer;
  }
}

function calculateInternationalSurcharge(order: Order): number {
  return order.getCustomer().getShippingAddress().getCountryCode() === "US" ? 0 : 15;
}

const order = new Order(new Customer(new Address("CA")));
console.log(calculateInternationalSurcharge(order));
```

### 2.4 Why this difference matters

In the good form, `calculateInternationalSurcharge` asks `Order` for the fact it needs: the shipping country. The checkout logic does not need to know that an order has a customer, that a customer has a shipping address, or that an address stores a country code.

In the less maintainable form, the function navigates through each intermediate object. If shipping information later moves from `Customer` to `Order`, or if `Address` is replaced by a different value object, every caller that uses the chain must change even though the business question stayed the same.

### 2.5 Structural references

```text
Good: Order.shippingCountry > delegated country lookup
Less maintainable: shippingCountryFor > order.customer.profile.shippingAddress.country
```

The structural difference is the number of object relationships exposed to the caller. The good form has one dependency from the function to `Order`'s shipping-country operation, while the less maintainable form exposes the path through `Order`, `Customer`, and `Address`.

## 3. Boundaries and distinctions

Message Chain applies when client code repeatedly reaches through one object to another to another, especially when the chain exposes domain structure that the caller does not need to know.

It does not usually apply to fluent APIs where each call intentionally returns the same builder or query object, such as `query.where(...).orderBy(...).limit(...)`. It is also less concerning for simple, stable data transfer objects at system boundaries, where the purpose is to expose a serialized shape.

The less maintainable form can be appropriate for short-lived scripts, tests that intentionally inspect object structure, or code whose main job is object mapping. Even then, repeated chains in business logic are a signal that a more direct method may belong on an intermediate object.

Hide Delegate is a common refactoring for Message Chain: add a method on the nearer object so clients do not navigate through the delegate. The Law of Demeter is the broader design principle that suggests an object should talk only to close collaborators rather than to objects obtained from those collaborators.
