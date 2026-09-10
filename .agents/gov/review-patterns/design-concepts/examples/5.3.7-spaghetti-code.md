# Spaghetti Code

## 1. Concept

- **Classification:** anti-pattern
- **Catalog identifier:** 5.3.7
- **Aliases:** None
- **Definition:** Control flow and dependencies are tangled enough that there is no clear local structure or path of responsibility. It is an umbrella diagnosis, not an exact synonym for any one smell.
- **Why it matters:** Spaghetti Code makes a reader trace many interleaved branches, flags, side effects, and dependency calls before they can understand what the code does. Changes become risky because validation, calculation, persistence, payment, and notification logic are not separated into clear responsibilities.
- **Related concepts:** Arrow Code, Duplicate Code, Message Chain

## 2. Example

### 2.1 Scenario

An online shop places an order by validating the cart, calculating the total, charging the customer, saving the order, and sending a confirmation email.

### 2.2 Good form

```ts
type CartItem = {
  sku: string;
  quantity: number;
  unitPriceCents: number;
};

type Customer = {
  id: string;
  email: string;
  paymentToken: string;
};

type Order = {
  id: string;
  customerId: string;
  totalCents: number;
  items: CartItem[];
};

type PaymentGateway = {
  charge(paymentToken: string, amountCents: number): Promise<string>;
};

type OrderRepository = {
  save(order: Order): Promise<void>;
};

type EmailSender = {
  send(to: string, subject: string, body: string): Promise<void>;
};

type CheckoutDependencies = {
  paymentGateway: PaymentGateway;
  orderRepository: OrderRepository;
  emailSender: EmailSender;
  createOrderId: () => string;
};

function validateCart(items: CartItem[]): void {
  if (items.length === 0) {
    throw new Error("Cart is empty");
  }

  for (const item of items) {
    if (item.quantity <= 0) {
      throw new Error(`Invalid quantity for ${item.sku}`);
    }

    if (item.unitPriceCents < 0) {
      throw new Error(`Invalid price for ${item.sku}`);
    }
  }
}

function calculateTotalCents(items: CartItem[]): number {
  return items.reduce(
    (total, item) => total + item.quantity * item.unitPriceCents,
    0
  );
}

function buildOrder(
  orderId: string,
  customer: Customer,
  items: CartItem[],
  totalCents: number
): Order {
  return {
    id: orderId,
    customerId: customer.id,
    totalCents,
    items: [...items],
  };
}

async function placeOrder(
  customer: Customer,
  items: CartItem[],
  dependencies: CheckoutDependencies
): Promise<Order> {
  validateCart(items);

  const totalCents = calculateTotalCents(items);
  await dependencies.paymentGateway.charge(customer.paymentToken, totalCents);

  const order = buildOrder(
    dependencies.createOrderId(),
    customer,
    items,
    totalCents
  );

  await dependencies.orderRepository.save(order);
  await dependencies.emailSender.send(
    customer.email,
    "Order confirmed",
    `Your order ${order.id} was placed for ${totalCents} cents.`
  );

  return order;
}
```

### 2.3 Less maintainable form

```ts
type CartItem = {
  sku: string;
  quantity: number;
  unitPriceCents: number;
};

type Customer = {
  id: string;
  email: string;
  paymentToken: string;
};

type Order = {
  id: string;
  customerId: string;
  totalCents: number;
  items: CartItem[];
};

type PaymentGateway = {
  charge(paymentToken: string, amountCents: number): Promise<string>;
};

type OrderRepository = {
  save(order: Order): Promise<void>;
};

type EmailSender = {
  send(to: string, subject: string, body: string): Promise<void>;
};

type CheckoutDependencies = {
  paymentGateway: PaymentGateway;
  orderRepository: OrderRepository;
  emailSender: EmailSender;
  createOrderId: () => string;
};

async function placeOrderSpaghetti(
  customer: Customer,
  items: CartItem[],
  dependencies: CheckoutDependencies
): Promise<Order> {
  let totalCents = 0;
  let invalidMessage = "";
  let order: Order | undefined;
  let shouldCharge = true;
  let shouldSave = false;
  let shouldEmail = false;

  if (items.length === 0) {
    invalidMessage = "Cart is empty";
    shouldCharge = false;
  } else {
    for (const item of items) {
      if (item.quantity <= 0) {
        invalidMessage = `Invalid quantity for ${item.sku}`;
        shouldCharge = false;
        break;
      } else {
        if (item.unitPriceCents < 0) {
          invalidMessage = `Invalid price for ${item.sku}`;
          shouldCharge = false;
          break;
        } else {
          totalCents = totalCents + item.quantity * item.unitPriceCents;
        }
      }
    }
  }

  if (!shouldCharge) {
    throw new Error(invalidMessage);
  }

  if (shouldCharge) {
    const paymentId = await dependencies.paymentGateway.charge(
      customer.paymentToken,
      totalCents
    );

    order = {
      id: dependencies.createOrderId(),
      customerId: customer.id,
      totalCents,
      items: [...items],
    };
    shouldSave = true;
  }

  if (shouldSave && order !== undefined) {
    await dependencies.orderRepository.save(order);
    shouldEmail = true;
  }

  if (shouldEmail && order !== undefined) {
    await dependencies.emailSender.send(
      customer.email,
      "Order confirmed",
      `Your order ${order.id} was placed for ${totalCents} cents.`
    );
  }

  if (order === undefined) {
    throw new Error("Order could not be created");
  }

  return order;
}
```

### 2.4 Why this difference matters

The good form gives each step a local responsibility: validation, total calculation, order construction, payment, persistence, and notification can be read independently and then composed in a simple workflow. The less maintainable form preserves the same behavior, but the workflow is hidden behind flags, nested branches, mutation, and interleaved concerns. A reader must reconstruct the path of responsibility from scattered state changes before safely changing even one rule.

### 2.5 Structural references

```text
Good: placeOrder > validateCart, calculateTotalCents, createOrder, save, and send confirmation calls
Less maintainable: placeOrderSpaghetti > flags shouldCharge, shouldSave, shouldEmail and order mutation
```

The structural difference is that the good form keeps the main function as a coordinator of clearly named local operations, while the less maintainable form places several responsibilities inside one tangled function with control state passed implicitly through mutable variables.

## 3. Boundaries and distinctions

Spaghetti Code does not apply just because a function is long, has several branches, or performs several steps. The diagnosis applies when the control flow and dependencies are tangled enough that no clear local structure or path of responsibility remains.

The less maintainable form can be acceptable as a short-lived spike, a generated artifact, or a small script that will not be changed after use. It becomes an anti-pattern when production code grows around it and routine changes require tracing unrelated branches and side effects.

Spaghetti Code is broader than Arrow Code, Duplicate Code, or Message Chain. Arrow Code focuses on deeply nested conditional shape. Duplicate Code focuses on repeated logic. Message Chain focuses on excessive navigation through object relationships. Spaghetti Code can include any of these, but its defining problem is the overall tangle of control flow and dependencies.
