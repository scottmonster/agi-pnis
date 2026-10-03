# Move Statements into Function

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.9
- **Aliases:** None
- **Definition:** Move call-site statements that always accompany a function into that function. It centralizes a repeated protocol and reduces callers' sequencing burden.
- **Why it matters:** It makes the expected sequence easier to read and harder to forget or reorder incorrectly. Callers express the intent, while the function owns the small protocol that must happen every time.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An order service sends shipment emails. Every shipment email must be built, sent, and recorded in the notification audit log.

### 2.2 Good form

```ts
type Shipment = {
  id: string;
  customerEmail: string;
  trackingNumber: string;
};

type EmailMessage = {
  to: string;
  subject: string;
  body: string;
};

type EmailClient = {
  send(message: EmailMessage): void;
};

const notificationAuditLog: string[] = [];

function buildShipmentMessage(shipment: Shipment): EmailMessage {
  return {
    to: shipment.customerEmail,
    subject: `Your shipment ${shipment.id} is on the way`,
    body: `Track your package with tracking number ${shipment.trackingNumber}.`,
  };
}

function recordShipmentNotification(shipmentId: string): void {
  notificationAuditLog.push(`shipment-notification:${shipmentId}`);
}

function sendShipmentNotification(emailClient: EmailClient, shipment: Shipment): void {
  const message = buildShipmentMessage(shipment);
  emailClient.send(message);
  recordShipmentNotification(shipment.id);
}

function shipOrder(emailClient: EmailClient, shipment: Shipment): void {
  sendShipmentNotification(emailClient, shipment);
}

function resendShipmentNotification(emailClient: EmailClient, shipment: Shipment): void {
  sendShipmentNotification(emailClient, shipment);
}
```

### 2.3 Less maintainable form

```ts
type Shipment = {
  id: string;
  customerEmail: string;
  trackingNumber: string;
};

type EmailMessage = {
  to: string;
  subject: string;
  body: string;
};

type EmailClient = {
  send(message: EmailMessage): void;
};

const notificationAuditLog: string[] = [];

function buildShipmentMessage(shipment: Shipment): EmailMessage {
  return {
    to: shipment.customerEmail,
    subject: `Your shipment ${shipment.id} is on the way`,
    body: `Track your package with tracking number ${shipment.trackingNumber}.`,
  };
}

function recordShipmentNotification(shipmentId: string): void {
  notificationAuditLog.push(`shipment-notification:${shipmentId}`);
}

function shipOrder(emailClient: EmailClient, shipment: Shipment): void {
  const message = buildShipmentMessage(shipment);
  emailClient.send(message);
  recordShipmentNotification(shipment.id);
}

function resendShipmentNotification(emailClient: EmailClient, shipment: Shipment): void {
  const message = buildShipmentMessage(shipment);
  emailClient.send(message);
  recordShipmentNotification(shipment.id);
}
```

### 2.4 Why this difference matters

In the good form, the repeated protocol of building the shipment message, sending it, and recording the audit entry is inside `sendShipmentNotification`. Callers no longer need to remember the companion audit statement every time they send the same kind of email. If the protocol changes, such as adding metrics or changing the audit format, the change happens in one function instead of every call site.

### 2.5 Structural references

```text
Good: order-service > notifications > shipmentEmail.ts > shipOrder > sendShipmentNotification
Less maintainable: order-service > notifications > shipmentEmail.ts > shipOrder > buildShipmentMessage
```

The relevant structural difference is that the good form targets a function that owns the whole notification protocol. The less maintainable form targets a lower-level message-building function, leaving required companion statements spread across callers.

## 3. Boundaries and distinctions

This concept applies when the same statements always accompany a function call and represent one stable protocol. It does not apply when callers legitimately vary the sequence, skip some steps, or need independent control over each statement.

The less maintainable form can be appropriate while behavior is still experimental or when the surrounding statements are not truly mandatory. Moving them too early can hide useful flexibility behind a misleading abstraction.

This differs from merely extracting a function because the focus is not just reducing duplicate code. The key change is shifting responsibility for an always-required calling sequence from many callers into the function that represents the operation.
