# Bridge

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.7
- **Aliases:** None
- **Definition:** Separate an abstraction from its implementation so each can vary independently. It prevents a cross-product of subclasses when two dimensions genuinely vary.
- **Why it matters:** Bridge makes the two reasons for change visible and separate. Readers can understand the high-level abstraction without reading every implementation variant, and maintainers can add a new abstraction or implementation without editing or duplicating the other dimension.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A monitoring service sends different kinds of notifications, such as alerts and digests, through different delivery channels, such as email and SMS. Notification type and delivery channel both vary independently.

### 2.2 Good form

```ts
interface MessageSender {
  send(recipient: string, subject: string, body: string): void;
}

class EmailSender implements MessageSender {
  send(recipient: string, subject: string, body: string): void {
    console.log(`EMAIL to ${recipient}: ${subject}\n${body}`);
  }
}

class SmsSender implements MessageSender {
  send(recipient: string, subject: string, body: string): void {
    console.log(`SMS to ${recipient}: ${subject} - ${body}`);
  }
}

abstract class Notification {
  protected constructor(protected readonly sender: MessageSender) {}

  abstract sendTo(recipient: string): void;
}

class AlertNotification extends Notification {
  constructor(
    sender: MessageSender,
    private readonly serviceName: string,
    private readonly errorCount: number,
  ) {
    super(sender);
  }

  sendTo(recipient: string): void {
    this.sender.send(
      recipient,
      `Alert: ${this.serviceName}`,
      `${this.errorCount} errors detected.`,
    );
  }
}

class DigestNotification extends Notification {
  constructor(
    sender: MessageSender,
    private readonly successfulJobs: number,
    private readonly failedJobs: number,
  ) {
    super(sender);
  }

  sendTo(recipient: string): void {
    this.sender.send(
      recipient,
      "Daily monitoring digest",
      `${this.successfulJobs} jobs succeeded, ${this.failedJobs} jobs failed.`,
    );
  }
}

const emailAlert = new AlertNotification(new EmailSender(), "payments-api", 12);
emailAlert.sendTo("on-call@example.com");

const smsDigest = new DigestNotification(new SmsSender(), 148, 3);
smsDigest.sendTo("+15550123");
```

### 2.3 Less maintainable form

```ts
abstract class Notification {
  abstract sendTo(recipient: string): void;
}

class EmailAlertNotification extends Notification {
  constructor(
    private readonly serviceName: string,
    private readonly errorCount: number,
  ) {
    super();
  }

  sendTo(recipient: string): void {
    console.log(
      `EMAIL to ${recipient}: Alert: ${this.serviceName}\n${this.errorCount} errors detected.`,
    );
  }
}

class SmsAlertNotification extends Notification {
  constructor(
    private readonly serviceName: string,
    private readonly errorCount: number,
  ) {
    super();
  }

  sendTo(recipient: string): void {
    console.log(
      `SMS to ${recipient}: Alert: ${this.serviceName} - ${this.errorCount} errors detected.`,
    );
  }
}

class EmailDigestNotification extends Notification {
  constructor(
    private readonly successfulJobs: number,
    private readonly failedJobs: number,
  ) {
    super();
  }

  sendTo(recipient: string): void {
    console.log(
      `EMAIL to ${recipient}: Daily monitoring digest\n${this.successfulJobs} jobs succeeded, ${this.failedJobs} jobs failed.`,
    );
  }
}

class SmsDigestNotification extends Notification {
  constructor(
    private readonly successfulJobs: number,
    private readonly failedJobs: number,
  ) {
    super();
  }

  sendTo(recipient: string): void {
    console.log(
      `SMS to ${recipient}: Daily monitoring digest - ${this.successfulJobs} jobs succeeded, ${this.failedJobs} jobs failed.`,
    );
  }
}

const emailAlert = new EmailAlertNotification("payments-api", 12);
emailAlert.sendTo("on-call@example.com");

const smsDigest = new SmsDigestNotification(148, 3);
smsDigest.sendTo("+15550123");
```

### 2.4 Why this difference matters

In the good form, `Notification` represents the abstraction dimension and `MessageSender` represents the implementation dimension. `AlertNotification` and `DigestNotification` decide what message should be sent, while `EmailSender` and `SmsSender` decide how it is delivered.

That split prevents a subclass cross-product. Adding a push notification channel requires one new `PushSender`, not `PushAlertNotification` and `PushDigestNotification`. Adding a new `WeeklyReportNotification` requires one notification class, not separate email, SMS, and push variants.

In the less maintainable form, each class combines both dimensions. The delivery logic is repeated across notification types, and the notification formatting is repeated across delivery channels. The number of classes grows as `notification types x delivery channels`.

### 2.5 Structural references

```text
Good: AlertNotification.sendTo > sender.send
Less maintainable: EmailAlertNotification.sendTo > email delivery expression
```

The good structure routes the abstraction through a separate implementation interface. The less maintainable structure embeds one delivery implementation directly inside each notification variant, forcing combined subclasses for every pair of choices.

## 3. Boundaries and distinctions

Bridge applies when two dimensions genuinely vary independently and both are expected to grow or change. It is not needed when there is only one varying dimension, when the combinations are fixed and tiny, or when a simple conditional is clearer than introducing collaborating types.

The less maintainable form can be acceptable for a small, closed set of combinations, especially in throwaway code or when each combination is truly unique and shares little behavior. If there will only ever be one notification type or one delivery channel, Bridge may add unnecessary indirection.

Bridge is often confused with Adapter and Strategy. Adapter makes an existing incompatible interface usable by another interface. Strategy swaps interchangeable behavior, usually within one abstraction. Bridge is specifically about separating an abstraction hierarchy from an implementation hierarchy so both can evolve independently.
