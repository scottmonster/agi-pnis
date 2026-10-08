# Pull Up Method / Pull Up Field

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.9
- **Aliases:** None
- **Definition:** Move duplicated behavior or data from subclasses to a superclass. It prevents hierarchy-wide drift when the member is truly common.
- **Why it matters:** It makes the hierarchy easier to read and maintain by giving shared behavior or data one authoritative location. When the common member changes, maintainers update the superclass instead of finding and synchronizing duplicate subclass implementations.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing system sends the same payment receipt text through email and SMS. The sender label and receipt formatting are identical for both notifier types, while only the delivery channel differs.

### 2.2 Good form

```ts
type Receipt = {
  invoiceId: string;
  amount: number;
};

abstract class InvoiceNotifier {
  protected readonly sender = "Billing Team";

  notifyPaid(receipt: Receipt): void {
    const message = this.formatReceipt(receipt);
    this.deliver(message);
  }

  protected formatReceipt(receipt: Receipt): string {
    return `${this.sender}: Payment received for invoice ${receipt.invoiceId}: $${receipt.amount.toFixed(2)}`;
  }

  protected abstract deliver(message: string): void;
}

class EmailInvoiceNotifier extends InvoiceNotifier {
  constructor(private readonly emailAddress: string) {
    super();
  }

  protected deliver(message: string): void {
    console.log(`Email to ${this.emailAddress}: ${message}`);
  }
}

class SmsInvoiceNotifier extends InvoiceNotifier {
  constructor(private readonly phoneNumber: string) {
    super();
  }

  protected deliver(message: string): void {
    console.log(`SMS to ${this.phoneNumber}: ${message}`);
  }
}

const receipt: Receipt = { invoiceId: "INV-1042", amount: 149.99 };

new EmailInvoiceNotifier("customer@example.com").notifyPaid(receipt);
new SmsInvoiceNotifier("+15551234567").notifyPaid(receipt);
```

### 2.3 Less maintainable form

```ts
type Receipt = {
  invoiceId: string;
  amount: number;
};

abstract class InvoiceNotifier {
  abstract notifyPaid(receipt: Receipt): void;
}

class EmailInvoiceNotifier extends InvoiceNotifier {
  private readonly sender = "Billing Team";

  constructor(private readonly emailAddress: string) {
    super();
  }

  notifyPaid(receipt: Receipt): void {
    const message = this.formatReceipt(receipt);
    console.log(`Email to ${this.emailAddress}: ${message}`);
  }

  private formatReceipt(receipt: Receipt): string {
    return `${this.sender}: Payment received for invoice ${receipt.invoiceId}: $${receipt.amount.toFixed(2)}`;
  }
}

class SmsInvoiceNotifier extends InvoiceNotifier {
  private readonly sender = "Billing Team";

  constructor(private readonly phoneNumber: string) {
    super();
  }

  notifyPaid(receipt: Receipt): void {
    const message = this.formatReceipt(receipt);
    console.log(`SMS to ${this.phoneNumber}: ${message}`);
  }

  private formatReceipt(receipt: Receipt): string {
    return `${this.sender}: Payment received for invoice ${receipt.invoiceId}: $${receipt.amount.toFixed(2)}`;
  }
}

const receipt: Receipt = { invoiceId: "INV-1042", amount: 149.99 };

new EmailInvoiceNotifier("customer@example.com").notifyPaid(receipt);
new SmsInvoiceNotifier("+15551234567").notifyPaid(receipt);
```

### 2.4 Why this difference matters

In the good form, the shared field `sender` and shared receipt behavior `notifyPaid` and `formatReceipt` live in `InvoiceNotifier`, the superclass that represents what all invoice notifiers have in common. Each subclass only supplies the part that actually varies: how to deliver the message.

In the less maintainable form, the same sender value and formatting logic are repeated in every subclass. If the receipt wording, currency formatting, or sender label changes, each subclass must be updated consistently. Missing one creates hierarchy-wide drift, where subclasses that should behave alike slowly become inconsistent.

### 2.5 Structural references

```text
Good: InvoiceNotifier > sender, notifyPaid, and formatReceipt
Less maintainable: EmailInvoiceNotifier and SmsInvoiceNotifier > duplicate sender and formatReceipt members
```

The relevant structural difference is that the common field and common methods have one superclass location in the good form, but multiple subclass locations in the less maintainable form.

## 3. Boundaries and distinctions

Pull Up Method / Pull Up Field applies when the member is genuinely common across subclasses and belongs to the abstraction represented by the superclass. It should not be used when two members are only accidentally similar, when subclasses need different invariants, or when moving the member upward would force irrelevant data or behavior onto other subclasses.

The less maintainable form can be appropriate temporarily when subclasses are expected to diverge soon, or when the commonality is not yet stable enough to justify changing the superclass contract.

This refactoring differs from creating a new superclass because it assumes a relevant superclass already exists. It also differs from simply extracting a helper function because the shared member is part of the inheritance hierarchy's common state or behavior, not just reusable standalone logic.
