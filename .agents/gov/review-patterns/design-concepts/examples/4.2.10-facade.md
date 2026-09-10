# Facade

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.10
- **Aliases:** None
- **Definition:** Present a simpler interface over a complex subsystem. It reduces client knowledge and gives the subsystem a readable entry point.
- **Why it matters:** A facade keeps common client code focused on the business action instead of subsystem sequencing, parameter translation, and cross-service details. This improves readability and makes subsystem changes easier to localize.
- **Related concepts:** Hide Delegate

## 2. Example

### 2.1 Scenario

An online store needs to place an order by checking stock, charging the customer, creating a shipment, and sending a confirmation email. The intended behavior is the same in both examples: one checkout request produces one confirmed order.

### 2.2 Good form

```ts
type CartItem = {
  sku: string;
  quantity: number;
  priceCents: number;
};

type CheckoutRequest = {
  customerId: string;
  email: string;
  address: string;
  paymentToken: string;
  items: CartItem[];
};

type CheckoutResult = {
  orderId: string;
  shipmentId: string;
  totalCents: number;
};

class InventoryService {
  reserve(items: CartItem[]): string {
    if (items.length === 0) {
      throw new Error("Cannot reserve an empty cart.");
    }

    return "reservation-123";
  }
}

class PaymentService {
  charge(customerId: string, paymentToken: string, amountCents: number): string {
    if (amountCents <= 0) {
      throw new Error("Cannot charge an empty amount.");
    }

    return `payment-${customerId}-${paymentToken}`;
  }
}

class ShippingService {
  createShipment(address: string, items: CartItem[], reservationId: string): string {
    return `shipment-${reservationId}-${address.length}-${items.length}`;
  }
}

class EmailService {
  sendOrderConfirmation(email: string, orderId: string, shipmentId: string): void {
    console.log(`Sent confirmation to ${email} for ${orderId} and ${shipmentId}.`);
  }
}

class OrderRepository {
  save(customerId: string, paymentId: string, shipmentId: string, totalCents: number): string {
    return `order-${customerId}-${paymentId}-${shipmentId}-${totalCents}`;
  }
}

class CheckoutFacade {
  constructor(
    private readonly inventory: InventoryService,
    private readonly payments: PaymentService,
    private readonly shipping: ShippingService,
    private readonly email: EmailService,
    private readonly orders: OrderRepository
  ) {}

  placeOrder(request: CheckoutRequest): CheckoutResult {
    const totalCents = request.items.reduce(
      (sum, item) => sum + item.priceCents * item.quantity,
      0
    );

    const reservationId = this.inventory.reserve(request.items);
    const paymentId = this.payments.charge(
      request.customerId,
      request.paymentToken,
      totalCents
    );
    const shipmentId = this.shipping.createShipment(
      request.address,
      request.items,
      reservationId
    );
    const orderId = this.orders.save(
      request.customerId,
      paymentId,
      shipmentId,
      totalCents
    );

    this.email.sendOrderConfirmation(request.email, orderId, shipmentId);

    return { orderId, shipmentId, totalCents };
  }
}

function handleCheckout(request: CheckoutRequest): CheckoutResult {
  const checkout = new CheckoutFacade(
    new InventoryService(),
    new PaymentService(),
    new ShippingService(),
    new EmailService(),
    new OrderRepository()
  );

  return checkout.placeOrder(request);
}
```

### 2.3 Less maintainable form

```ts
type CartItem = {
  sku: string;
  quantity: number;
  priceCents: number;
};

type CheckoutRequest = {
  customerId: string;
  email: string;
  address: string;
  paymentToken: string;
  items: CartItem[];
};

type CheckoutResult = {
  orderId: string;
  shipmentId: string;
  totalCents: number;
};

class InventoryService {
  reserve(items: CartItem[]): string {
    if (items.length === 0) {
      throw new Error("Cannot reserve an empty cart.");
    }

    return "reservation-123";
  }
}

class PaymentService {
  charge(customerId: string, paymentToken: string, amountCents: number): string {
    if (amountCents <= 0) {
      throw new Error("Cannot charge an empty amount.");
    }

    return `payment-${customerId}-${paymentToken}`;
  }
}

class ShippingService {
  createShipment(address: string, items: CartItem[], reservationId: string): string {
    return `shipment-${reservationId}-${address.length}-${items.length}`;
  }
}

class EmailService {
  sendOrderConfirmation(email: string, orderId: string, shipmentId: string): void {
    console.log(`Sent confirmation to ${email} for ${orderId} and ${shipmentId}.`);
  }
}

class OrderRepository {
  save(customerId: string, paymentId: string, shipmentId: string, totalCents: number): string {
    return `order-${customerId}-${paymentId}-${shipmentId}-${totalCents}`;
  }
}

function handleCheckout(request: CheckoutRequest): CheckoutResult {
  const inventory = new InventoryService();
  const payments = new PaymentService();
  const shipping = new ShippingService();
  const email = new EmailService();
  const orders = new OrderRepository();

  const totalCents = request.items.reduce(
    (sum, item) => sum + item.priceCents * item.quantity,
    0
  );

  const reservationId = inventory.reserve(request.items);
  const paymentId = payments.charge(
    request.customerId,
    request.paymentToken,
    totalCents
  );
  const shipmentId = shipping.createShipment(
    request.address,
    request.items,
    reservationId
  );
  const orderId = orders.save(
    request.customerId,
    paymentId,
    shipmentId,
    totalCents
  );

  email.sendOrderConfirmation(request.email, orderId, shipmentId);

  return { orderId, shipmentId, totalCents };
}
```

### 2.4 Why this difference matters

The good form gives checkout clients one readable operation: `placeOrder`. The client does not need to know the order of reservation, charging, shipment creation, persistence, and email notification. If payment capture, shipment rules, or confirmation behavior changes, the change is localized in the facade instead of every caller that performs checkout.

The less maintainable form exposes the whole subsystem protocol to the client. Each caller must duplicate the same sequence and understand which intermediate values are required by later services. That makes the subsystem harder to use correctly and increases the chance that future callers omit or reorder a required step.

### 2.5 Structural references

```text
Good: store-api > checkout > checkout.ts > handleCheckout > CheckoutFacade.placeOrder
Less maintainable: store-api > checkout > checkout.ts > handleCheckout > inventory.reserve and payments.charge calls
```

The structural difference is that the good form routes the client function through a single subsystem entry point, while the less maintainable form makes the client coordinate inventory, payment, shipping, storage, and email services directly.

## 3. Boundaries and distinctions

Facade applies when several subsystem operations form a common higher-level use case and most clients should not need to know the subsystem details. It does not apply when the subsystem is already simple, when adding another layer would only rename one method, or when clients genuinely need full low-level control.

The less maintainable form can be appropriate inside the facade itself, in tests that verify subsystem interactions, in migration scripts, or in specialized workflows that intentionally vary the sequence.

Facade differs from Hide Delegate because a facade presents a simplified entry point over a broader subsystem, while Hide Delegate removes a navigation chain by letting an object forward a request to one of its collaborators. A facade may use delegation internally, but its main purpose is to simplify a complex API surface for clients.
