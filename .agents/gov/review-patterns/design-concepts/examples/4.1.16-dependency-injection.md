# Dependency Injection

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.1.16
- **Aliases:** None
- **Definition:** Supply a collaborator from outside the object, commonly through its constructor, rather than creating or locating it internally. Dependencies become visible in the contract and independently configurable.
- **Why it matters:** Dependency Injection makes collaborators explicit at the boundary of an object, so readers can see what the object needs, tests can replace external services, and changes to infrastructure do not require editing the dependent business logic.
- **Related concepts:** Service Locator

## 2. Example

### 2.1 Scenario

A billing service sends an email when an invoice is paid. The notification behavior is the same in both examples, but the email-sending collaborator is supplied differently.

### 2.2 Good form

```ts
type Invoice = {
  id: string;
  customerEmail: string;
  totalCents: number;
};

type EmailMessage = {
  to: string;
  subject: string;
  body: string;
};

interface EmailSender {
  send(message: EmailMessage): Promise<void>;
}

class SmtpEmailSender implements EmailSender {
  constructor(private readonly host: string) {}

  async send(message: EmailMessage): Promise<void> {
    console.log(`Sending through ${this.host} to ${message.to}: ${message.subject}`);
  }
}

class InvoiceNotifier {
  constructor(private readonly emailSender: EmailSender) {}

  async notifyPaid(invoice: Invoice): Promise<void> {
    await this.emailSender.send({
      to: invoice.customerEmail,
      subject: `Invoice ${invoice.id} paid`,
      body: `Thank you for your payment of $${(invoice.totalCents / 100).toFixed(2)}.`
    });
  }
}

async function main(): Promise<void> {
  const emailSender = new SmtpEmailSender("smtp.example.com");
  const notifier = new InvoiceNotifier(emailSender);

  await notifier.notifyPaid({
    id: "INV-1001",
    customerEmail: "customer@example.com",
    totalCents: 12999
  });
}

void main();
```

### 2.3 Less maintainable form

```ts
type Invoice = {
  id: string;
  customerEmail: string;
  totalCents: number;
};

type EmailMessage = {
  to: string;
  subject: string;
  body: string;
};

interface EmailSender {
  send(message: EmailMessage): Promise<void>;
}

class SmtpEmailSender implements EmailSender {
  constructor(private readonly host: string) {}

  async send(message: EmailMessage): Promise<void> {
    console.log(`Sending through ${this.host} to ${message.to}: ${message.subject}`);
  }
}

class InvoiceNotifier {
  async notifyPaid(invoice: Invoice): Promise<void> {
    const emailSender = new SmtpEmailSender("smtp.example.com");

    await emailSender.send({
      to: invoice.customerEmail,
      subject: `Invoice ${invoice.id} paid`,
      body: `Thank you for your payment of $${(invoice.totalCents / 100).toFixed(2)}.`
    });
  }
}

async function main(): Promise<void> {
  const notifier = new InvoiceNotifier();

  await notifier.notifyPaid({
    id: "INV-1001",
    customerEmail: "customer@example.com",
    totalCents: 12999
  });
}

void main();
```

### 2.4 Why this difference matters

In the good form, `InvoiceNotifier` declares that it needs an `EmailSender`. That contract lets the caller choose the concrete sender, such as SMTP in production or a fake sender in tests. The notification logic only depends on the email-sending capability, not on how the sender is constructed.

In the less maintainable form, `InvoiceNotifier` hides its dependency by constructing `SmtpEmailSender` internally. Changing the SMTP host, replacing the transport, or testing notification behavior without sending email requires editing or working around `InvoiceNotifier` itself.

### 2.5 Structural references

```text
Good: InvoiceNotifier.constructor > emailSender parameter
Less maintainable: InvoiceNotifier.notifyPaid > new SmtpEmailSender()
```

The relevant structural difference is where the collaborator enters the object. In the good form, the dependency crosses the boundary through the constructor. In the less maintainable form, the dependency is created inside the method that uses it, so the object's contract does not reveal the collaborator it requires.

## 3. Boundaries and distinctions

Dependency Injection applies when an object needs a collaborator whose implementation, configuration, lifecycle, or test replacement should be controlled from outside that object. It is most useful for services, gateways, repositories, clocks, random number generators, loggers, and other collaborators that affect behavior or connect to external systems.

It does not need to be applied to every local value or simple data structure. Creating short-lived internal objects can be appropriate when they are purely private implementation details, have no external configuration, and are not useful seams for testing or replacement.

The less maintainable form can be acceptable in composition code, such as application startup, where concrete objects are intentionally assembled. Dependency Injection does not remove object construction from the system - it moves construction to a boundary where choices are explicit.

Dependency Injection differs from Service Locator. With Dependency Injection, required collaborators are supplied directly, usually through constructor parameters, so dependencies are visible in the contract. With Service Locator, the object asks a registry or container for collaborators, which can preserve configurability but hides the true dependencies inside the implementation.
