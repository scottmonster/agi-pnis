# Adapter

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.6
- **Aliases:** None
- **Definition:** Wrap an incompatible interface in one expected by clients. It isolates foreign or legacy API differences.
- **Why it matters:** Adapter keeps client code readable by letting it depend on the interface it actually needs, while containing legacy or foreign API details in one place. This makes future API changes easier to understand, test, and modify.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout service needs to charge customers through an old bank payment API. The application expects a simple `PaymentProcessor` interface, but the bank client uses different method names, parameter names, currency units, and response codes.

### 2.2 Good form

```ts
type PaymentRequest = {
  customerId: string;
  amountDollars: number;
  currency: "USD" | "EUR";
};

type PaymentResult = {
  approved: boolean;
  transactionId: string;
};

interface PaymentProcessor {
  charge(request: PaymentRequest): PaymentResult;
}

class LegacyBankClient {
  makePayment(accountRef: string, cents: number, isoCurrency: string): {
    statusCode: "00" | "05";
    bankTransactionRef: string;
  } {
    return {
      statusCode: cents > 0 ? "00" : "05",
      bankTransactionRef: `bank-${accountRef}-${Date.now()}`
    };
  }
}

class LegacyBankPaymentAdapter implements PaymentProcessor {
  constructor(private readonly bankClient: LegacyBankClient) {}

  charge(request: PaymentRequest): PaymentResult {
    const response = this.bankClient.makePayment(
      request.customerId,
      Math.round(request.amountDollars * 100),
      request.currency
    );

    return {
      approved: response.statusCode === "00",
      transactionId: response.bankTransactionRef
    };
  }
}

function checkout(
  paymentProcessor: PaymentProcessor,
  request: PaymentRequest
): PaymentResult {
  return paymentProcessor.charge(request);
}

const bankClient = new LegacyBankClient();
const paymentProcessor = new LegacyBankPaymentAdapter(bankClient);

const result = checkout(paymentProcessor, {
  customerId: "cust-123",
  amountDollars: 49.99,
  currency: "USD"
});

console.log(result);
```

### 2.3 Less maintainable form

```ts
type PaymentRequest = {
  customerId: string;
  amountDollars: number;
  currency: "USD" | "EUR";
};

type PaymentResult = {
  approved: boolean;
  transactionId: string;
};

class LegacyBankClient {
  makePayment(accountRef: string, cents: number, isoCurrency: string): {
    statusCode: "00" | "05";
    bankTransactionRef: string;
  } {
    return {
      statusCode: cents > 0 ? "00" : "05",
      bankTransactionRef: `bank-${accountRef}-${Date.now()}`
    };
  }
}

function checkout(
  bankClient: LegacyBankClient,
  request: PaymentRequest
): PaymentResult {
  const response = bankClient.makePayment(
    request.customerId,
    Math.round(request.amountDollars * 100),
    request.currency
  );

  return {
    approved: response.statusCode === "00",
    transactionId: response.bankTransactionRef
  };
}

const bankClient = new LegacyBankClient();

const result = checkout(bankClient, {
  customerId: "cust-123",
  amountDollars: 49.99,
  currency: "USD"
});

console.log(result);
```

### 2.4 Why this difference matters

In the good form, `checkout` depends on `PaymentProcessor`, the interface that matches the application's needs. The `LegacyBankPaymentAdapter` is the only place that knows the bank API uses cents, `accountRef`, `makePayment`, `statusCode`, and `bankTransactionRef`.

In the less maintainable form, checkout logic and bank API translation are mixed together. If the bank changes its response codes or another payment provider is added, the checkout function must change even though its business purpose has not changed.

### 2.5 Structural references

```text
Good: LegacyBankPaymentAdapter > charge
Less maintainable: checkout > LegacyBankClient.makePayment
```

The good form places the incompatible API translation behind an adapter target. The less maintainable form makes the checkout function directly target the legacy client, so the client code is structurally coupled to the foreign interface.

## 3. Boundaries and distinctions

Adapter applies when existing code needs to work with an interface that does not match what the client expects. It is most useful when the mismatch is likely to appear in multiple places, when the foreign API is hard to read, or when the external API may change independently of the application.

The less maintainable form can be appropriate for a short-lived script, a one-off integration, or code where there is only one caller and no meaningful interface mismatch beyond a single simple method call.

Adapter is not needed when the client already uses the provider's interface naturally. It also should not be used to hide business rules. The adapter should translate interfaces, names, data shapes, units, and response formats, while domain decisions should remain in application or domain code.
