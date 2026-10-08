# Flag Argument

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.3.5
- **Aliases:** None
- **Definition:** A boolean or similar parameter makes one function perform distinct operations. The call does not name the behavior and the implementation tends toward conditional branching.
- **Why it matters:** Flag arguments hide intent at call sites and force readers to inspect the callee to understand what `true` or `false` means. As more behavior variants are added, the function tends to accumulate conditionals, making it harder to test, change, and name clearly.
- **Related concepts:** Remove Flag Argument

## 2. Example

### 2.1 Scenario

An order service sends either a normal shipping confirmation or an expedited shipping confirmation. Both paths notify the customer, but the message content differs.

### 2.2 Good form

```ts
type Order = {
  id: string;
  customerEmail: string;
};

function sendEmail(to: string, subject: string, body: string): void {
  console.log(`To: ${to}\nSubject: ${subject}\n${body}`);
}

function sendStandardShippingConfirmation(order: Order): void {
  sendEmail(
    order.customerEmail,
    `Order ${order.id} has shipped`,
    "Your order is on the way and should arrive in 5 to 7 business days."
  );
}

function sendExpeditedShippingConfirmation(order: Order): void {
  sendEmail(
    order.customerEmail,
    `Order ${order.id} has shipped with expedited delivery`,
    "Your order is on the way and should arrive in 1 to 2 business days."
  );
}

const order: Order = {
  id: "A123",
  customerEmail: "customer@example.com"
};

sendExpeditedShippingConfirmation(order);
```

### 2.3 Less maintainable form

```ts
type Order = {
  id: string;
  customerEmail: string;
};

function sendEmail(to: string, subject: string, body: string): void {
  console.log(`To: ${to}\nSubject: ${subject}\n${body}`);
}

function sendShippingConfirmation(order: Order, expedited: boolean): void {
  if (expedited) {
    sendEmail(
      order.customerEmail,
      `Order ${order.id} has shipped with expedited delivery`,
      "Your order is on the way and should arrive in 1 to 2 business days."
    );
    return;
  }

  sendEmail(
    order.customerEmail,
    `Order ${order.id} has shipped`,
    "Your order is on the way and should arrive in 5 to 7 business days."
  );
}

const order: Order = {
  id: "A123",
  customerEmail: "customer@example.com"
};

sendShippingConfirmation(order, true);
```

### 2.4 Why this difference matters

In the good form, the selected behavior is named at the call site: `sendExpeditedShippingConfirmation(order)`. A reader does not need to know what a boolean value means. Each function also has one clear responsibility, so changes to expedited messaging are isolated from standard messaging.

In the less maintainable form, `sendShippingConfirmation(order, true)` does not explain the requested behavior unless the reader already knows the meaning of the second argument. The implementation must branch on that flag, which encourages one function to become a container for multiple behaviors.

### 2.5 Structural references

```text
Good: bookStandardDelivery and bookExpressDelivery > explicit operations
Less maintainable: bookDelivery > express flag branch
```

The relevant structural difference is that the good form gives each operation its own named function, while the less maintainable form uses one function whose behavior is selected by a flag parameter.

## 3. Boundaries and distinctions

A boolean parameter is not always a flag argument. It is usually fine when the boolean is domain data used as data, such as `customer.isActive`, rather than a switch that tells a function which operation to perform.

The less maintainable form can be appropriate for private implementation helpers when the public API exposes intention-revealing functions and the flag is not leaked to callers. It may also be acceptable when the function truly has one behavior and the boolean only supplies a simple value, not an alternate mode.

Flag Argument differs from Remove Flag Argument because Flag Argument names the smell, while Remove Flag Argument names the refactoring that replaces the flag-controlled function with clearer alternatives, commonly separate intention-revealing functions.
