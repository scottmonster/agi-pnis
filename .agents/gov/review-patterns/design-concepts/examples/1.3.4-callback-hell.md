# Callback Hell

## 1. Concept

- **Classification:** anti-pattern
- **Catalog identifier:** 1.3.4
- **Aliases:** None
- **Definition:** Asynchronous callbacks are nested so deeply that the operation and its error handling are buried in continuation scopes. It is the asynchronous form of a pyramid of doom.
- **Why it matters:** Callback hell makes the main operation hard to follow because each next step is hidden inside another callback. Error handling is repeated at every nesting level, which makes changes risky and makes it easy to skip cleanup, return from the wrong scope, or handle errors inconsistently.
- **Related concepts:** Continuation-Passing Style

## 2. Example

### 2.1 Scenario

A checkout flow must load a user, load that user's cart, charge the payment method, and save a receipt. Each data operation is asynchronous and may fail.

### 2.2 Good form

```ts
type User = { id: string; paymentToken: string };
type Cart = { userId: string; totalCents: number };
type Charge = { id: string; amountCents: number };
type Receipt = { id: string; userId: string; chargeId: string };

type Callback<T> = (error: Error | null, value?: T) => void;

function getUser(userId: string, callback: Callback<User>): void {
  callback(null, { id: userId, paymentToken: "tok_123" });
}

function getCart(userId: string, callback: Callback<Cart>): void {
  callback(null, { userId, totalCents: 4999 });
}

function chargeCard(paymentToken: string, amountCents: number, callback: Callback<Charge>): void {
  callback(null, { id: "ch_123", amountCents });
}

function saveReceipt(userId: string, chargeId: string, callback: Callback<Receipt>): void {
  callback(null, { id: "rcpt_123", userId, chargeId });
}

function toPromise<T>(operation: (callback: Callback<T>) => void): Promise<T> {
  return new Promise((resolve, reject) => {
    operation((error, value) => {
      if (error) {
        reject(error);
        return;
      }

      resolve(value as T);
    });
  });
}

async function checkout(userId: string): Promise<Receipt> {
  const user = await toPromise<User>((callback) => getUser(userId, callback));
  const cart = await toPromise<Cart>((callback) => getCart(user.id, callback));
  const charge = await toPromise<Charge>((callback) =>
    chargeCard(user.paymentToken, cart.totalCents, callback)
  );

  return toPromise<Receipt>((callback) => saveReceipt(user.id, charge.id, callback));
}

checkout("user-1")
  .then((receipt) => {
    console.log(`Saved receipt ${receipt.id}`);
  })
  .catch((error: Error) => {
    console.error(`Checkout failed: ${error.message}`);
  });
```

### 2.3 Less maintainable form

```ts
type User = { id: string; paymentToken: string };
type Cart = { userId: string; totalCents: number };
type Charge = { id: string; amountCents: number };
type Receipt = { id: string; userId: string; chargeId: string };

type Callback<T> = (error: Error | null, value?: T) => void;

function getUser(userId: string, callback: Callback<User>): void {
  callback(null, { id: userId, paymentToken: "tok_123" });
}

function getCart(userId: string, callback: Callback<Cart>): void {
  callback(null, { userId, totalCents: 4999 });
}

function chargeCard(paymentToken: string, amountCents: number, callback: Callback<Charge>): void {
  callback(null, { id: "ch_123", amountCents });
}

function saveReceipt(userId: string, chargeId: string, callback: Callback<Receipt>): void {
  callback(null, { id: "rcpt_123", userId, chargeId });
}

function checkout(userId: string, callback: Callback<Receipt>): void {
  getUser(userId, (userError, user) => {
    if (userError) {
      callback(userError);
      return;
    }

    getCart(user!.id, (cartError, cart) => {
      if (cartError) {
        callback(cartError);
        return;
      }

      chargeCard(user!.paymentToken, cart!.totalCents, (chargeError, charge) => {
        if (chargeError) {
          callback(chargeError);
          return;
        }

        saveReceipt(user!.id, charge!.id, (receiptError, receipt) => {
          if (receiptError) {
            callback(receiptError);
            return;
          }

          callback(null, receipt);
        });
      });
    });
  });
}

checkout("user-1", (error, receipt) => {
  if (error) {
    console.error(`Checkout failed: ${error.message}`);
    return;
  }

  console.log(`Saved receipt ${receipt!.id}`);
});
```

### 2.4 Why this difference matters

The good form keeps the checkout sequence at one indentation level, so the reader can see the business process in order: user, cart, charge, receipt. Error propagation is handled once by promise rejection and the final `catch`.

The less maintainable form exhibits callback hell because each asynchronous step is inside the previous step's continuation. The main operation is buried several scopes deep, and every level repeats error handling before the next operation can be read. Adding a new step, retry, cleanup action, or logging rule requires editing inside nested continuations and increases the chance of placing logic in the wrong callback scope.

### 2.5 Structural references

```text
Good: checkout-service > checkout > checkout.ts > checkout > await sequence
Less maintainable: checkout-service > checkout > checkout.ts > checkout > nested callback chain
```

The relevant structural difference is where the asynchronous continuation lives. In the good form, the `checkout` function has a flat sequence of awaited operations. In the less maintainable form, the same sequence is represented as callbacks nested inside callbacks, so later steps are structurally buried under earlier continuation scopes.

## 3. Boundaries and distinctions

Callback hell does not mean that every callback is bad. A single callback, a small event handler, or a callback used to adapt an API can be clear and appropriate. The anti-pattern appears when asynchronous callbacks are nested deeply enough that control flow, error handling, and future changes become difficult to reason about.

The less maintainable form may be acceptable for very small glue code, legacy APIs that require callbacks, or low-level adapters whose only job is to convert a callback interface into a promise-based one. It becomes harmful when business workflow is implemented directly inside a growing chain of continuations.

Callback hell is related to Continuation-Passing Style, but they are not the same. Continuation-Passing Style is a general programming style where the next computation is passed as a function. Callback hell is a specific maintainability failure that can occur when asynchronous continuations are nested too deeply. It is also related to the broader pyramid of doom shape, but callback hell specifically concerns asynchronous callbacks and their continuation scopes.
