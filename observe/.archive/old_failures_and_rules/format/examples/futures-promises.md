# Futures/Promises

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 1.3.6
- **Aliases:** None
- **Definition:** Represent a result that will be available later with an object that carries completion, value, and failure. Composable continuations can make asynchronous dependencies more explicit than nested callbacks.
- **Why it matters:** Futures and promises make asynchronous control flow easier to read, combine, return, and test because the pending result is represented as a value instead of being hidden inside nested callback structure.
- **Related concepts:** Callback Hell, Structured Concurrency

## 2. Example

### 2.1 Scenario

A notification service loads a user and the user's recent orders, then sends a summary email. If any step fails, the caller should receive the failure.

### 2.2 Good form

```ts
type User = {
  id: string;
  email: string;
};

type Order = {
  id: string;
  total: number;
};

function loadUser(userId: string): Promise<User> {
  return Promise.resolve({ id: userId, email: "ada@example.com" });
}

function loadRecentOrders(userId: string): Promise<Order[]> {
  return Promise.resolve([
    { id: "order-1", total: 42 },
    { id: "order-2", total: 18 }
  ]);
}

function sendEmail(to: string, subject: string, body: string): Promise<void> {
  console.log(`To: ${to}\nSubject: ${subject}\n${body}`);
  return Promise.resolve();
}

function formatSummary(user: User, orders: Order[]): string {
  const total = orders.reduce((sum, order) => sum + order.total, 0);
  return `Hello ${user.id}, you have ${orders.length} recent orders totaling ${total}.`;
}

async function sendOrderSummary(userId: string): Promise<void> {
  const user = await loadUser(userId);
  const orders = await loadRecentOrders(user.id);
  const body = formatSummary(user, orders);

  await sendEmail(user.email, "Your recent orders", body);
}

sendOrderSummary("user-123").catch((error: unknown) => {
  console.error("Could not send order summary", error);
});
```

### 2.3 Less maintainable form

```ts
type User = {
  id: string;
  email: string;
};

type Order = {
  id: string;
  total: number;
};

type Callback<T> = (error: Error | null, value?: T) => void;

function loadUser(userId: string, callback: Callback<User>): void {
  callback(null, { id: userId, email: "ada@example.com" });
}

function loadRecentOrders(userId: string, callback: Callback<Order[]>): void {
  callback(null, [
    { id: "order-1", total: 42 },
    { id: "order-2", total: 18 }
  ]);
}

function sendEmail(to: string, subject: string, body: string, callback: Callback<void>): void {
  console.log(`To: ${to}\nSubject: ${subject}\n${body}`);
  callback(null);
}

function formatSummary(user: User, orders: Order[]): string {
  const total = orders.reduce((sum, order) => sum + order.total, 0);
  return `Hello ${user.id}, you have ${orders.length} recent orders totaling ${total}.`;
}

function sendOrderSummary(userId: string, callback: Callback<void>): void {
  loadUser(userId, (userError, user) => {
    if (userError) {
      callback(userError);
      return;
    }

    if (!user) {
      callback(new Error("User was not loaded"));
      return;
    }

    loadRecentOrders(user.id, (ordersError, orders) => {
      if (ordersError) {
        callback(ordersError);
        return;
      }

      if (!orders) {
        callback(new Error("Orders were not loaded"));
        return;
      }

      const body = formatSummary(user, orders);

      sendEmail(user.email, "Your recent orders", body, (emailError) => {
        if (emailError) {
          callback(emailError);
          return;
        }

        callback(null);
      });
    });
  });
}

sendOrderSummary("user-123", (error) => {
  if (error) {
    console.error("Could not send order summary", error);
  }
});
```

### 2.4 Why this difference matters

In the good form, each asynchronous operation returns a `Promise`, so the future completion, value, and failure are carried by a composable object. `sendOrderSummary` can return that object to its caller, and `await` expresses the dependency order without burying later steps inside earlier callback bodies. Failure propagation is also part of the promise chain, so one `catch` can handle errors from loading the user, loading orders, or sending the email.

In the less maintainable form, the pending result is not a value that can be returned or combined. Each step must manually receive a callback, check for an error, check for a missing value, and decide whether to continue. Adding another asynchronous dependency would deepen the nesting and duplicate more error forwarding.

### 2.5 Structural references

```text
Good: notification-service > notifications > orderSummary.ts > sendOrderSummary > returned Promise
Less maintainable: notification-service > notifications > orderSummary.ts > sendOrderSummary > nested callbacks
```

The relevant structural difference is that the good form exposes the asynchronous result at the function boundary as a returned `Promise<void>`, while the less maintainable form hides completion behind callback parameters nested inside the function body.

## 3. Boundaries and distinctions

Futures and promises apply when an operation may complete later and the caller needs a handle for its eventual success or failure. They are less relevant for purely synchronous work, fire-and-forget events where no result or failure is observed, or very low-level APIs where callbacks are required by the runtime.

The less maintainable callback form can still be appropriate for tiny adapters around callback-based libraries, event listeners that may fire many times, or performance-sensitive code that deliberately avoids promise allocation. In those cases, it is often useful to keep the callback boundary small and convert to a promise at the application edge.

Futures and promises differ from Callback Hell because they are a technique for representing asynchronous results as composable values, while Callback Hell is the readability problem caused by deeply nested callbacks and duplicated continuation logic. They also differ from Structured Concurrency, which is about scoping and coordinating the lifetime of concurrent tasks. Promises can be used inside structured concurrency, but a promise by itself does not guarantee that child tasks are cancelled, awaited, or bounded by a parent scope.
