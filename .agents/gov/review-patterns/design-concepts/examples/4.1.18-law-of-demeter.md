# Law of Demeter

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.1.18
- **Aliases:** principle of least knowledge
- **Definition:** Limit a method to collaborating directly with its immediate objects rather than navigating through object graphs. It reduces structural coupling; it motivates Hide Delegate but is not identical to it.
- **Why it matters:** It keeps code readable by making dependencies local and explicit. A method that talks only to its direct collaborators is easier to understand and less likely to break when internal object structure changes elsewhere.
- **Related concepts:** Message Chain

## 2. Example

### 2.1 Scenario

A checkout service calculates a delivery quote for an order. The quote depends on the postal code of the customer's delivery address.

### 2.2 Good form

```ts
type PostalCode = string;

class Address {
  constructor(private readonly postalCodeValue: PostalCode) {}

  postalCode(): PostalCode {
    return this.postalCodeValue;
  }
}

class CustomerProfile {
  constructor(private readonly shippingAddress: Address) {}

  shippingPostalCode(): PostalCode {
    return this.shippingAddress.postalCode();
  }
}

class Customer {
  constructor(private readonly profile: CustomerProfile) {}

  deliveryPostalCode(): PostalCode {
    return this.profile.shippingPostalCode();
  }
}

class Order {
  constructor(private readonly customer: Customer) {}

  deliveryPostalCode(): PostalCode {
    return this.customer.deliveryPostalCode();
  }
}

class DeliveryRates {
  costForPostalCode(postalCode: PostalCode): number {
    return postalCode.startsWith("9") ? 12.5 : 8.0;
  }
}

function quoteDelivery(order: Order, rates: DeliveryRates): number {
  return rates.costForPostalCode(order.deliveryPostalCode());
}

const order = new Order(
  new Customer(
    new CustomerProfile(
      new Address("94105")
    )
  )
);

console.log(quoteDelivery(order, new DeliveryRates()));
```

### 2.3 Less maintainable form

```ts
type PostalCode = string;

class Address {
  constructor(public readonly postalCode: PostalCode) {}
}

class CustomerProfile {
  constructor(public readonly shippingAddress: Address) {}
}

class Customer {
  constructor(public readonly profile: CustomerProfile) {}
}

class Order {
  constructor(public readonly customer: Customer) {}
}

class DeliveryRates {
  costForPostalCode(postalCode: PostalCode): number {
    return postalCode.startsWith("9") ? 12.5 : 8.0;
  }
}

function quoteDelivery(order: Order, rates: DeliveryRates): number {
  return rates.costForPostalCode(
    order.customer.profile.shippingAddress.postalCode
  );
}

const order = new Order(
  new Customer(
    new CustomerProfile(
      new Address("94105")
    )
  )
);

console.log(quoteDelivery(order, new DeliveryRates()));
```

### 2.4 Why this difference matters

In the good form, `quoteDelivery` collaborates only with its immediate parameters: `order` and `rates`. It asks the order for the information it needs and does not know how an order reaches a customer, how a customer stores a profile, or how a profile stores an address.

In the less maintainable form, `quoteDelivery` depends on the internal navigation path `order.customer.profile.shippingAddress.postalCode`. If the customer profile changes its address representation, the checkout function must change even though delivery quoting has not changed. That is the structural coupling the Law of Demeter is meant to reduce.

### 2.5 Structural references

```text
Good: quoteDelivery > Order.deliveryPostalCode
Less maintainable: quoteDelivery > order.customer.profile.shippingAddress.postalCode
```

The relevant structural difference is the target reached by the function. In the good form, the function targets behavior on its direct collaborator, the order. In the less maintainable form, the function targets a nested object several references away, creating a message chain through the object graph.

## 3. Boundaries and distinctions

The Law of Demeter is a guideline, not a ban on every dotted expression. It usually applies to behavior-rich domain objects and services where callers should not depend on internal object topology.

The less maintainable form can be appropriate when the object is intentionally a transparent data structure, such as a DTO, parsed JSON payload, configuration object, or database projection. Traversal is also reasonable when the method's purpose is specifically to inspect or transform a nested data shape.

The Law of Demeter differs from Hide Delegate. Law of Demeter is the design principle: avoid reaching through one object to talk to another. Hide Delegate is one possible refactoring that supports the principle by adding forwarding behavior to an intermediate object.

It also differs from Message Chain. A Message Chain is a common code smell where calls or property accesses are chained through several objects. The Law of Demeter explains why that smell can be harmful: the caller becomes coupled to the structure of objects it should not need to know.
