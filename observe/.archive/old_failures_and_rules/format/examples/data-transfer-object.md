# Data Transfer Object (DTO)

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 3.2.3
- **Aliases:** data transfer object
- **Definition:** Package data for transfer across a boundary, usually without domain behavior. It makes boundary shape explicit, but should not be mistaken for a domain model.
- **Why it matters:** A DTO makes the data contract at a system boundary easy to see, review, and change without exposing domain objects or domain behavior to callers.
- **Related concepts:** Data Class

## 2. Example

### 2.1 Scenario

An HTTP endpoint returns a customer's order summary to a web client. The domain model calculates totals, but the API response should expose only the stable boundary shape needed by the client.

### 2.2 Good form

```ts
type OrderLine = {
  sku: string;
  quantity: number;
  unitPriceCents: number;
};

class Order {
  constructor(
    public readonly id: string,
    public readonly customerId: string,
    private readonly lines: OrderLine[],
  ) {}

  totalCents(): number {
    return this.lines.reduce(
      (sum, line) => sum + line.quantity * line.unitPriceCents,
      0,
    );
  }

  itemCount(): number {
    return this.lines.reduce((sum, line) => sum + line.quantity, 0);
  }
}

type OrderSummaryDto = {
  orderId: string;
  itemCount: number;
  totalCents: number;
};

function toOrderSummaryDto(order: Order): OrderSummaryDto {
  return {
    orderId: order.id,
    itemCount: order.itemCount(),
    totalCents: order.totalCents(),
  };
}

function getOrderSummary(orderId: string): OrderSummaryDto {
  const order = new Order(orderId, "customer-123", [
    { sku: "BOOK-1", quantity: 2, unitPriceCents: 1500 },
    { sku: "PEN-1", quantity: 3, unitPriceCents: 200 },
  ]);

  return toOrderSummaryDto(order);
}

const responseBody = JSON.stringify(getOrderSummary("order-456"));
console.log(responseBody);
```

### 2.3 Less maintainable form

```ts
type OrderLine = {
  sku: string;
  quantity: number;
  unitPriceCents: number;
};

class Order {
  constructor(
    public readonly id: string,
    public readonly customerId: string,
    public readonly lines: OrderLine[],
  ) {}

  totalCents(): number {
    return this.lines.reduce(
      (sum, line) => sum + line.quantity * line.unitPriceCents,
      0,
    );
  }

  itemCount(): number {
    return this.lines.reduce((sum, line) => sum + line.quantity, 0);
  }
}

function getOrderSummary(orderId: string): Order {
  return new Order(orderId, "customer-123", [
    { sku: "BOOK-1", quantity: 2, unitPriceCents: 1500 },
    { sku: "PEN-1", quantity: 3, unitPriceCents: 200 },
  ]);
}

const order = getOrderSummary("order-456");
const responseBody = JSON.stringify({
  orderId: order.id,
  itemCount: order.itemCount(),
  totalCents: order.totalCents(),
});
console.log(responseBody);
```

### 2.4 Why this difference matters

In the good form, `OrderSummaryDto` names the boundary contract directly: the response contains `orderId`, `itemCount`, and `totalCents`. The mapping function is the only place where domain state and calculations are translated into transfer data.

In the less maintainable form, the endpoint returns the domain object and the response shape is assembled outside the boundary function. That makes it harder to see what the API promises, encourages callers to depend on domain details such as `customerId` or `lines`, and makes future domain changes more likely to affect the API accidentally.

### 2.5 Structural references

```text
Good: checkout-service > orders > orderController.ts > getOrderSummary > OrderSummaryDto
Less maintainable: checkout-service > orders > orderController.ts > getOrderSummary > Order
```

The structural difference is the target type at the boundary function. The good form targets a DTO that represents transfer data, while the less maintainable form targets the domain model itself.

## 3. Boundaries and distinctions

A DTO is useful when data crosses a boundary, such as an HTTP API, message queue, persistence adapter, external service client, or process boundary. It is less useful for purely internal calls where the domain model is already the right abstraction and no separate contract is needed.

The less maintainable form can be acceptable for a small prototype, a private script, or a very narrow internal endpoint where the domain object is intentionally the contract and unlikely to change independently. It becomes risky when clients depend on the shape, names, or serialization behavior of a domain object.

A DTO differs from a domain model because it should usually contain transfer data and little or no domain behavior. A domain model represents business concepts and rules. A DTO also overlaps with a Data Class because both may mostly hold data, but the intent is different: a DTO exists to define and carry data across a boundary, while a Data Class is a broader structural concept and may be a design smell if it replaces behavior that belongs with the data.
