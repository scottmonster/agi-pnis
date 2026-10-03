# Continuation-Passing Style (CPS)

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 1.3.5
- **Aliases:** None
- **Definition:** Pass the next computation explicitly as a continuation. It makes non-linear or asynchronous sequencing expressible, but unstructured nesting can become Callback Hell.
- **Why it matters:** CPS makes control flow visible as data: each step receives the computation to run next. This can make asynchronous or conditional sequencing easier to change, but only when continuations are named and structured clearly.
- **Related concepts:** Callback Hell, Futures/Promises

## 2. Example

### 2.1 Scenario

A checkout service validates a cart, reserves inventory, charges the customer, and sends a receipt. Each step is asynchronous and may fail.

### 2.2 Good form

```ts
type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: Error };

type Continuation<T> = (result: Result<T>) => void;

type CheckoutRequest = {
  cartId: string;
  customerEmail: string;
  amountInCents: number;
};

type ValidCart = CheckoutRequest & { validated: true };
type Reservation = { cartId: string; reservationId: string; amountInCents: number; customerEmail: string };
type Payment = { reservationId: string; paymentId: string; customerEmail: string };
type Receipt = { paymentId: string; sentTo: string };

function succeed<T>(value: T): Result<T> {
  return { ok: true, value };
}

function fail<T>(message: string): Result<T> {
  return { ok: false, error: new Error(message) };
}

function validateCart(request: CheckoutRequest, next: Continuation<ValidCart>): void {
  setTimeout(() => {
    if (request.amountInCents <= 0) {
      next(fail("cart total must be positive"));
      return;
    }

    next(succeed({ ...request, validated: true }));
  }, 10);
}

function reserveInventory(cart: ValidCart, next: Continuation<Reservation>): void {
  setTimeout(() => {
    next(
      succeed({
        cartId: cart.cartId,
        reservationId: `res-${cart.cartId}`,
        amountInCents: cart.amountInCents,
        customerEmail: cart.customerEmail,
      }),
    );
  }, 10);
}

function chargePayment(reservation: Reservation, next: Continuation<Payment>): void {
  setTimeout(() => {
    next(
      succeed({
        reservationId: reservation.reservationId,
        paymentId: `pay-${reservation.reservationId}`,
        customerEmail: reservation.customerEmail,
      }),
    );
  }, 10);
}

function sendReceipt(payment: Payment, next: Continuation<Receipt>): void {
  setTimeout(() => {
    next(
      succeed({
        paymentId: payment.paymentId,
        sentTo: payment.customerEmail,
      }),
    );
  }, 10);
}

function placeOrderCps(request: CheckoutRequest, done: Continuation<Receipt>): void {
  const afterValidation: Continuation<ValidCart> = (cartResult) => {
    if (!cartResult.ok) {
      done(cartResult);
      return;
    }

    reserveInventory(cartResult.value, afterReservation);
  };

  const afterReservation: Continuation<Reservation> = (reservationResult) => {
    if (!reservationResult.ok) {
      done(reservationResult);
      return;
    }

    chargePayment(reservationResult.value, afterPayment);
  };

  const afterPayment: Continuation<Payment> = (paymentResult) => {
    if (!paymentResult.ok) {
      done(paymentResult);
      return;
    }

    sendReceipt(paymentResult.value, done);
  };

  validateCart(request, afterValidation);
}
```

### 2.3 Less maintainable form

```ts
type Result<T> =
  | { ok: true; value: T }
  | { ok: false; error: Error };

type Continuation<T> = (result: Result<T>) => void;

type CheckoutRequest = {
  cartId: string;
  customerEmail: string;
  amountInCents: number;
};

type ValidCart = CheckoutRequest & { validated: true };
type Reservation = { cartId: string; reservationId: string; amountInCents: number; customerEmail: string };
type Payment = { reservationId: string; paymentId: string; customerEmail: string };
type Receipt = { paymentId: string; sentTo: string };

function succeed<T>(value: T): Result<T> {
  return { ok: true, value };
}

function fail<T>(message: string): Result<T> {
  return { ok: false, error: new Error(message) };
}

function validateCart(request: CheckoutRequest, next: Continuation<ValidCart>): void {
  setTimeout(() => {
    if (request.amountInCents <= 0) {
      next(fail("cart total must be positive"));
      return;
    }

    next(succeed({ ...request, validated: true }));
  }, 10);
}

function reserveInventory(cart: ValidCart, next: Continuation<Reservation>): void {
  setTimeout(() => {
    next(
      succeed({
        cartId: cart.cartId,
        reservationId: `res-${cart.cartId}`,
        amountInCents: cart.amountInCents,
        customerEmail: cart.customerEmail,
      }),
    );
  }, 10);
}

function chargePayment(reservation: Reservation, next: Continuation<Payment>): void {
  setTimeout(() => {
    next(
      succeed({
        reservationId: reservation.reservationId,
        paymentId: `pay-${reservation.reservationId}`,
        customerEmail: reservation.customerEmail,
      }),
    );
  }, 10);
}

function sendReceipt(payment: Payment, next: Continuation<Receipt>): void {
  setTimeout(() => {
    next(
      succeed({
        paymentId: payment.paymentId,
        sentTo: payment.customerEmail,
      }),
    );
  }, 10);
}

function placeOrderNested(request: CheckoutRequest, done: Continuation<Receipt>): void {
  validateCart(request, (cartResult) => {
    if (!cartResult.ok) {
      done(cartResult);
      return;
    }

    reserveInventory(cartResult.value, (reservationResult) => {
      if (!reservationResult.ok) {
        done(reservationResult);
        return;
      }

      chargePayment(reservationResult.value, (paymentResult) => {
        if (!paymentResult.ok) {
          done(paymentResult);
          return;
        }

        sendReceipt(paymentResult.value, (receiptResult) => {
          done(receiptResult);
        });
      });
    });
  });
}
```

### 2.4 Why this difference matters

Both versions use continuations, but the good form gives each continuation a name that represents a phase of the computation. The next computation is still passed explicitly, but it is not hidden inside a growing pyramid of anonymous functions. This makes the order of steps, the failure exits, and the insertion point for a new step easier to see and change.

The less maintainable form preserves the same behavior, but it uses CPS in an unstructured way. Each continuation is embedded inside the previous one, so adding another asynchronous step increases nesting and makes local changes affect surrounding indentation and error handling.

### 2.5 Structural references

```text
Good: checkout-service > checkout > checkout.ts > placeOrderCps > named continuation sequence
Less maintainable: checkout-service > checkout > checkout.ts > placeOrderNested > nested anonymous continuation chain
```

The structural difference is where the continuations live. In the good form, continuations are separate named targets inside the function. In the less maintainable form, each continuation is structurally contained inside the previous continuation.

## 3. Boundaries and distinctions

CPS applies when a function receives the rest of the computation as an explicit argument, usually a callback such as `next`, `done`, `resolve`, or `onComplete`. It is most useful when control flow is not a simple straight-line return, such as asynchronous work, early exits, retries, backtracking, coroutines, or interpreters.

The less maintainable nested form can be acceptable for a very small one-off sequence with one or two callbacks, especially when the code is local and unlikely to change. It becomes problematic when the nested shape obscures the actual sequence, duplicates error handling, or makes inserting a new step require editing several levels of indentation.

CPS is not the same as Callback Hell. Callback Hell is a maintainability failure that can result from unstructured CPS-style callbacks. CPS is also not the same as Futures or Promises. Futures and Promises package a future result into an object and usually provide chaining methods such as `then` or `catch`; CPS passes the next computation directly as a function argument.
