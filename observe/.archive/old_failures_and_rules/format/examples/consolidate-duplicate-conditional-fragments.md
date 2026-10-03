# Consolidate Duplicate Conditional Fragments

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.2.3
- **Aliases:** None
- **Definition:** Move code repeated in every branch outside the conditional. It reduces duplication and leaves each branch responsible only for its difference.
- **Why it matters:** It makes the conditional easier to read because each branch shows only what changes. It also reduces maintenance risk because shared behavior is updated in one place instead of being kept in sync across branches.
- **Related concepts:** Duplicate Code

## 2. Example

### 2.1 Scenario

An order service sends a receipt after checkout. Expedited and standard orders need different shipping text, but receipt formatting, email delivery, and audit logging are the same.

### 2.2 Good form

```ts
type Order = {
  id: string;
  customerEmail: string;
  totalCents: number;
  expedited: boolean;
};

type AuditEvent = {
  orderId: string;
  receiptText: string;
};

function formatReceipt(order: Order, shippingNote: string): string {
  return `Order ${order.id}: $${(order.totalCents / 100).toFixed(2)}. ${shippingNote}`;
}

function sendEmail(to: string, body: string): void {
  console.log(`Sending email to ${to}: ${body}`);
}

function recordReceiptEvent(event: AuditEvent): void {
  console.log(`Receipt recorded for order ${event.orderId}`);
}

function sendCheckoutReceipt(order: Order): string {
  let shippingNote: string;

  if (order.expedited) {
    shippingNote = "Your order will ship with priority handling.";
  } else {
    shippingNote = "Your order will ship with standard handling.";
  }

  const receiptText = formatReceipt(order, shippingNote);
  sendEmail(order.customerEmail, receiptText);
  recordReceiptEvent({ orderId: order.id, receiptText });

  return receiptText;
}
```

### 2.3 Less maintainable form

```ts
type Order = {
  id: string;
  customerEmail: string;
  totalCents: number;
  expedited: boolean;
};

type AuditEvent = {
  orderId: string;
  receiptText: string;
};

function formatReceipt(order: Order, shippingNote: string): string {
  return `Order ${order.id}: $${(order.totalCents / 100).toFixed(2)}. ${shippingNote}`;
}

function sendEmail(to: string, body: string): void {
  console.log(`Sending email to ${to}: ${body}`);
}

function recordReceiptEvent(event: AuditEvent): void {
  console.log(`Receipt recorded for order ${event.orderId}`);
}

function sendCheckoutReceipt(order: Order): string {
  if (order.expedited) {
    const receiptText = formatReceipt(
      order,
      "Your order will ship with priority handling."
    );
    sendEmail(order.customerEmail, receiptText);
    recordReceiptEvent({ orderId: order.id, receiptText });

    return receiptText;
  } else {
    const receiptText = formatReceipt(
      order,
      "Your order will ship with standard handling."
    );
    sendEmail(order.customerEmail, receiptText);
    recordReceiptEvent({ orderId: order.id, receiptText });

    return receiptText;
  }
}
```

### 2.4 Why this difference matters

In the good form, the conditional is responsible only for choosing the shipping note. The shared receipt formatting, email sending, audit logging, and return happen once after the conditional. If the audit event changes or another shared receipt step is added, there is a single place to edit.

In the less maintainable form, both branches repeat the same post-processing. A future change can easily be applied to one branch but missed in the other, creating inconsistent behavior between expedited and standard orders.

### 2.5 Structural references

```text
Good: checkout-service > receipts > receipt.ts > sendCheckoutReceipt > shared receipt processing after conditional
Less maintainable: checkout-service > receipts > receipt.ts > sendCheckoutReceipt > duplicated receipt processing in each branch
```

The relevant structural difference is the location of the common fragment. In the good form, shared processing sits once after the conditional. In the less maintainable form, the same processing is embedded separately inside every branch.

## 3. Boundaries and distinctions

This refactoring applies when the repeated fragment is genuinely the same in every branch and can be moved without changing execution order, side effects, variable scope, or error behavior.

It does not apply when similar-looking code has branch-specific differences that are important to keep separate. The less maintainable form may also be appropriate when each branch is expected to diverge soon, or when moving the code outside the conditional would require awkward temporary variables that make the code harder to understand.

This concept is a specific response to Duplicate Code. Duplicate Code is the broader smell: the same logic appears in multiple places. Consolidate Duplicate Conditional Fragments addresses one narrow case: the duplication appears in every branch of the same conditional, so the repeated fragment can be placed before or after the conditional while each branch keeps only its distinct behavior.
