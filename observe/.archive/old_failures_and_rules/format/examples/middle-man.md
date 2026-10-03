# Middle Man

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.8
- **Aliases:** None
- **Definition:** A component mostly forwards calls to another component without contributing behavior or protecting a useful boundary. It adds navigation cost.
- **Why it matters:** Middle Man makes readers follow extra indirection to find the real behavior. It also increases maintenance work because method names, signatures, and tests may need to change in multiple places even though only one component actually does the work.
- **Related concepts:** Remove Middle Man

## 2. Example

### 2.1 Scenario

A subscription billing service charges a customer's saved payment method through a payment gateway. The business behavior is to submit a monthly subscription charge and return the resulting receipt id.

### 2.2 Good form

```ts
type Money = {
  amountInCents: number;
  currency: "USD";
};

type ChargeRequest = {
  customerId: string;
  paymentMethodId: string;
  amount: Money;
  description: string;
};

type PaymentReceipt = {
  receiptId: string;
  chargedAmount: Money;
};

interface PaymentGateway {
  charge(request: ChargeRequest): Promise<PaymentReceipt>;
}

class StripePaymentGateway implements PaymentGateway {
  async charge(request: ChargeRequest): Promise<PaymentReceipt> {
    return {
      receiptId: `receipt-${request.customerId}-${request.amount.amountInCents}`,
      chargedAmount: request.amount,
    };
  }
}

class SubscriptionBilling {
  constructor(private readonly paymentGateway: PaymentGateway) {}

  async billMonthlySubscription(
    customerId: string,
    paymentMethodId: string,
  ): Promise<string> {
    const receipt = await this.paymentGateway.charge({
      customerId,
      paymentMethodId,
      amount: { amountInCents: 2900, currency: "USD" },
      description: "Monthly subscription",
    });

    return receipt.receiptId;
  }
}

async function run(): Promise<void> {
  const billing = new SubscriptionBilling(new StripePaymentGateway());
  const receiptId = await billing.billMonthlySubscription("cust-123", "pm-456");
  console.log(receiptId);
}

void run();
```

### 2.3 Less maintainable form

```ts
type Money = {
  amountInCents: number;
  currency: "USD";
};

type ChargeRequest = {
  customerId: string;
  paymentMethodId: string;
  amount: Money;
  description: string;
};

type PaymentReceipt = {
  receiptId: string;
  chargedAmount: Money;
};

interface PaymentGateway {
  charge(request: ChargeRequest): Promise<PaymentReceipt>;
}

class StripePaymentGateway implements PaymentGateway {
  async charge(request: ChargeRequest): Promise<PaymentReceipt> {
    return {
      receiptId: `receipt-${request.customerId}-${request.amount.amountInCents}`,
      chargedAmount: request.amount,
    };
  }
}

class CustomerPayments {
  constructor(private readonly paymentGateway: PaymentGateway) {}

  async charge(request: ChargeRequest): Promise<PaymentReceipt> {
    return this.paymentGateway.charge(request);
  }
}

class SubscriptionBilling {
  constructor(private readonly customerPayments: CustomerPayments) {}

  async billMonthlySubscription(
    customerId: string,
    paymentMethodId: string,
  ): Promise<string> {
    const receipt = await this.customerPayments.charge({
      customerId,
      paymentMethodId,
      amount: { amountInCents: 2900, currency: "USD" },
      description: "Monthly subscription",
    });

    return receipt.receiptId;
  }
}

async function run(): Promise<void> {
  const customerPayments = new CustomerPayments(new StripePaymentGateway());
  const billing = new SubscriptionBilling(customerPayments);
  const receiptId = await billing.billMonthlySubscription("cust-123", "pm-456");
  console.log(receiptId);
}

void run();
```

### 2.4 Why this difference matters

In the good form, `SubscriptionBilling` calls the component that performs the payment operation. A reader can navigate from the billing rule directly to the payment behavior.

In the less maintainable form, `CustomerPayments` does not add validation, policy, transformation, caching, logging, security, or a stable abstraction. It only forwards `charge` to `PaymentGateway.charge`, so it creates another place to inspect and another signature to keep synchronized without adding useful behavior.

### 2.5 Structural references

```text
Good: PaymentService.charge > gateway.charge direct call
Less maintainable: BillingService.charge > forwards to PaymentService.charge
```

The relevant structural difference is the extra forwarding step in the less maintainable form. `CustomerPayments.charge` is not a meaningful boundary in this scenario because it only passes the same request to the real target.

## 3. Boundaries and distinctions

Middle Man does not apply when the forwarding component protects a useful boundary. A delegating component can be appropriate when it enforces access rules, hides an unstable vendor API, adapts data shapes, centralizes cross-cutting behavior, preserves a public API, or expresses a domain concept that callers should depend on.

The less maintainable form can also be acceptable temporarily during migration, when callers are being moved from an old API to a new one. In that case, the forwarding layer should have a clear purpose and expected lifetime.

Middle Man differs from useful delegation because useful delegation contributes behavior or reduces coupling. It differs from the refactoring Remove Middle Man, which is the corrective action: clients bypass the unnecessary forwarding component and call the real collaborator directly.
