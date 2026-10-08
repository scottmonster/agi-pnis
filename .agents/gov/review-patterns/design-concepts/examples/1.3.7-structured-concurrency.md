# Structured Concurrency

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 1.3.7
- **Aliases:** None
- **Definition:** Scope concurrent work so child tasks complete or are cancelled before their parent scope finishes. It keeps lifetimes, cancellation, and error propagation visible instead of leaving detached work.
- **Why it matters:** Structured concurrency makes concurrent code easier to read and maintain because the function that starts work is also responsible for waiting for it, cancelling it, and propagating its errors.
- **Related concepts:** Futures/Promises

## 2. Example

### 2.1 Scenario

An API handler builds a dashboard by fetching a user profile and that user's recent orders concurrently. If either fetch fails or the request is cancelled, the other fetch should not continue in the background.

### 2.2 Good form

```ts
type User = {
  id: string;
  name: string;
};

type Order = {
  id: string;
  total: number;
};

type Dashboard = {
  user: User;
  orders: Order[];
};

async function fetchJson<T>(url: string, signal: AbortSignal): Promise<T> {
  const response = await fetch(url, { signal });

  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }

  return (await response.json()) as T;
}

async function getDashboard(userId: string, requestSignal: AbortSignal): Promise<Dashboard> {
  const scope = new AbortController();

  const cancelScopeFromRequest = () => {
    scope.abort(requestSignal.reason);
  };

  if (requestSignal.aborted) {
    cancelScopeFromRequest();
  } else {
    requestSignal.addEventListener("abort", cancelScopeFromRequest, { once: true });
  }

  const userTask = fetchJson<User>(`/api/users/${userId}`, scope.signal);
  const ordersTask = fetchJson<Order[]>(`/api/users/${userId}/orders`, scope.signal);

  try {
    const [user, orders] = await Promise.all([userTask, ordersTask]);
    return { user, orders };
  } catch (error) {
    scope.abort(error);
    await Promise.allSettled([userTask, ordersTask]);
    throw error;
  } finally {
    requestSignal.removeEventListener("abort", cancelScopeFromRequest);
  }
}
```

### 2.3 Less maintainable form

```ts
type User = {
  id: string;
  name: string;
};

type Order = {
  id: string;
  total: number;
};

type Dashboard = {
  user: User;
  orders: Order[];
};

async function fetchJson<T>(url: string, signal: AbortSignal): Promise<T> {
  const response = await fetch(url, { signal });

  if (!response.ok) {
    throw new Error(`Request failed: ${response.status}`);
  }

  return (await response.json()) as T;
}

async function getDashboard(userId: string, requestSignal: AbortSignal): Promise<Dashboard> {
  const detachedOrdersController = new AbortController();
  const ordersTask = fetchJson<Order[]>(
    `/api/users/${userId}/orders`,
    detachedOrdersController.signal
  );

  ordersTask.catch(() => undefined);

  const user = await fetchJson<User>(`/api/users/${userId}`, requestSignal);
  const orders = await ordersTask;

  return { user, orders };
}
```

### 2.4 Why this difference matters

In the good form, both fetches belong to the same visible scope inside `getDashboard`. The function starts both child tasks, awaits both child tasks, cancels the sibling task if one fails, and waits for cancellation to settle before returning or throwing.

In the less maintainable form, the orders request is started with its own independent controller. If the user request fails or the client cancels the request, the orders request can keep running after `getDashboard` has already exited. That makes resource use, failure handling, and request lifetime harder to reason about.

### 2.5 Structural references

```text
Good: dashboard-service > api > dashboard.ts > getDashboard > scoped child tasks
Less maintainable: dashboard-service > api > dashboard.ts > getDashboard > detached orders task
```

The structural difference is that the good form keeps all child work inside the parent function's cancellation and waiting scope. The less maintainable form creates a child task whose lifetime is not fully owned by the parent function.

## 3. Boundaries and distinctions

Structured concurrency applies when concurrent operations are part of one parent operation and should finish, fail, or be cancelled together. It is especially useful in request handlers, batch steps, UI actions, and command execution paths.

The less maintainable form can be appropriate when work is intentionally independent, such as enqueueing a durable background job, sending telemetry best-effort, or starting a long-lived service task managed by another supervisor. In those cases, the detached lifetime should be explicit and owned by another clear component.

Structured concurrency is different from Futures/Promises. A Promise represents a future result of asynchronous work. Structured concurrency is the lifetime discipline that determines where that work is started, who waits for it, how cancellation is propagated, and where errors are observed.
