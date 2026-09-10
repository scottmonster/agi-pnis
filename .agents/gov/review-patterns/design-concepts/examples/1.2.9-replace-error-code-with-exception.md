# Replace Error Code with Exception

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.2.9
- **Aliases:** None
- **Definition:** Replace a special return code that callers must inspect with exception-based failure signaling. It can separate successful-path logic from failure handling when the error is exceptional.
- **Why it matters:** It keeps normal control flow focused on successful work, makes failure paths explicit, and reduces the risk that callers forget to inspect special return values.
- **Related concepts:** Replace Exception with Precheck

## 2. Example

### 2.1 Scenario

A checkout service withdraws funds from a customer account before confirming an order. Insufficient funds are an exceptional failure for this operation and must stop order confirmation.

### 2.2 Good form

```ts
class InsufficientFundsError extends Error {
  constructor(accountId: string, requested: number, available: number) {
    super(
      `Account ${accountId} has insufficient funds: requested ${requested}, available ${available}`
    );
    this.name = "InsufficientFundsError";
  }
}

class Account {
  constructor(
    public readonly id: string,
    private balance: number
  ) {}

  withdraw(amount: number): void {
    if (amount > this.balance) {
      throw new InsufficientFundsError(this.id, amount, this.balance);
    }

    this.balance -= amount;
  }

  getBalance(): number {
    return this.balance;
  }
}

function confirmOrder(account: Account, orderTotal: number): string {
  try {
    account.withdraw(orderTotal);
    return "ORDER_CONFIRMED";
  } catch (error) {
    if (error instanceof InsufficientFundsError) {
      return "PAYMENT_DECLINED";
    }

    throw error;
  }
}

const account = new Account("acct-123", 50);
const status = confirmOrder(account, 75);

console.log(status);
console.log(account.getBalance());
```

### 2.3 Less maintainable form

```ts
type WithdrawResult = "OK" | "INSUFFICIENT_FUNDS";

class Account {
  constructor(
    public readonly id: string,
    private balance: number
  ) {}

  withdraw(amount: number): WithdrawResult {
    if (amount > this.balance) {
      return "INSUFFICIENT_FUNDS";
    }

    this.balance -= amount;
    return "OK";
  }

  getBalance(): number {
    return this.balance;
  }
}

function confirmOrder(account: Account, orderTotal: number): string {
  const withdrawResult = account.withdraw(orderTotal);

  if (withdrawResult === "INSUFFICIENT_FUNDS") {
    return "PAYMENT_DECLINED";
  }

  return "ORDER_CONFIRMED";
}

const account = new Account("acct-123", 50);
const status = confirmOrder(account, 75);

console.log(status);
console.log(account.getBalance());
```

### 2.4 Why this difference matters

In the good form, `withdraw` either completes or throws a typed exception. Callers that care about the failure handle `InsufficientFundsError`, while the successful path does not need to carry and inspect a status code. This makes the contract harder to ignore: a caller cannot accidentally treat a failed withdrawal as a successful one by forgetting to check `"INSUFFICIENT_FUNDS"`.

In the less maintainable form, every caller must remember that the returned value is not ordinary business data but a failure signal. As more error codes are added, successful logic becomes mixed with branching error handling at each call site.

### 2.5 Structural references

```text
Good: checkout-service > payments > account.ts > withdraw > throw InsufficientFundsError
Less maintainable: checkout-service > payments > account.ts > withdraw > return "INSUFFICIENT_FUNDS"
```

The relevant structural difference is where failure is represented: the good form signals the exceptional path through an exception from `withdraw`, while the less maintainable form embeds the failure signal in the function's ordinary return value.

## 3. Boundaries and distinctions

Use this refactoring when the return code represents an exceptional failure that should interrupt the normal operation and should not be silently ignored. It is especially useful when many callers would otherwise repeat the same error-code checks.

Do not use it for ordinary, expected alternatives that are part of normal domain flow, such as validation results displayed beside form fields, cache misses, optional lookups, or parsing attempts where failure is common and expected. In those cases, a result type, union type, boolean, or explicit precheck may be clearer.

The less maintainable form can be appropriate at system boundaries where protocols require status codes, such as HTTP responses, process exit codes, database driver codes, or low-level APIs shared with languages that do not use exceptions. Even then, application code may translate those codes into exceptions internally if the failure is exceptional.

This differs from **Replace Exception with Precheck**. Replace Error Code with Exception moves exceptional failure from a special return value into exception handling. Replace Exception with Precheck removes avoidable exceptions by checking a condition before calling an operation when the failure is expected and can be handled as normal control flow.
