# Large Class

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.3
- **Aliases:** God Class, God Object
- **Definition:** A class accumulates too many unrelated responsibilities, behavior, or state. It becomes a central change hotspot with poor discoverability.
- **Why it matters:** Large classes are harder to read because unrelated details compete for attention. They are harder to understand because callers and maintainers must learn many responsibilities at once. They are harder to maintain because unrelated changes tend to touch the same file, increasing merge conflicts, regression risk, and the chance that hidden coupling will be introduced.
- **Related concepts:** Extract Class

## 2. Example

### 2.1 Scenario

An order checkout feature calculates invoice totals, creates a receipt email, sends it, and records an audit message. The intended behavior is the same in both examples.

### 2.2 Good form

```ts
type LineItem = {
  name: string;
  quantity: number;
  unitPriceCents: number;
};

type Order = {
  id: string;
  customerEmail: string;
  items: LineItem[];
};

type Invoice = {
  subtotalCents: number;
  taxCents: number;
  totalCents: number;
};

type EmailMessage = {
  to: string;
  subject: string;
  body: string;
};

type CheckoutResult = {
  invoice: Invoice;
  email: EmailMessage;
  auditRecord: string;
};

class OrderTotalCalculator {
  constructor(private readonly taxRate: number) {}

  calculate(items: LineItem[]): Invoice {
    const subtotalCents = items.reduce(
      (sum, item) => sum + item.quantity * item.unitPriceCents,
      0
    );
    const taxCents = Math.round(subtotalCents * this.taxRate);

    return {
      subtotalCents,
      taxCents,
      totalCents: subtotalCents + taxCents
    };
  }
}

class ReceiptEmailComposer {
  compose(customerEmail: string, invoice: Invoice): EmailMessage {
    return {
      to: customerEmail,
      subject: "Your receipt",
      body: `Subtotal: ${invoice.subtotalCents} cents
Tax: ${invoice.taxCents} cents
Total: ${invoice.totalCents} cents`
    };
  }
}

class AuditRecordFormatter {
  format(orderId: string, invoice: Invoice): string {
    return `order=${orderId} total=${invoice.totalCents}`;
  }
}

class InMemoryEmailGateway {
  readonly sentMessages: EmailMessage[] = [];

  send(message: EmailMessage): void {
    this.sentMessages.push(message);
  }
}

class CheckoutService {
  constructor(
    private readonly totals: OrderTotalCalculator,
    private readonly receipts: ReceiptEmailComposer,
    private readonly auditRecords: AuditRecordFormatter,
    private readonly emailGateway: InMemoryEmailGateway
  ) {}

  checkout(order: Order): CheckoutResult {
    const invoice = this.totals.calculate(order.items);
    const email = this.receipts.compose(order.customerEmail, invoice);

    this.emailGateway.send(email);

    return {
      invoice,
      email,
      auditRecord: this.auditRecords.format(order.id, invoice)
    };
  }
}

const emailGateway = new InMemoryEmailGateway();
const checkout = new CheckoutService(
  new OrderTotalCalculator(0.08),
  new ReceiptEmailComposer(),
  new AuditRecordFormatter(),
  emailGateway
);

const result = checkout.checkout({
  id: "ord-1001",
  customerEmail: "customer@example.com",
  items: [
    { name: "Notebook", quantity: 2, unitPriceCents: 500 },
    { name: "Pen", quantity: 3, unitPriceCents: 150 }
  ]
});

console.log(result.invoice.totalCents);
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  name: string;
  quantity: number;
  unitPriceCents: number;
};

type Order = {
  id: string;
  customerEmail: string;
  items: LineItem[];
};

type Invoice = {
  subtotalCents: number;
  taxCents: number;
  totalCents: number;
};

type EmailMessage = {
  to: string;
  subject: string;
  body: string;
};

type CheckoutResult = {
  invoice: Invoice;
  email: EmailMessage;
  auditRecord: string;
};

class CheckoutManager {
  readonly sentMessages: EmailMessage[] = [];

  constructor(private readonly taxRate: number) {}

  checkout(order: Order): CheckoutResult {
    const invoice = this.calculateInvoice(order.items);
    const email = this.composeReceiptEmail(order.customerEmail, invoice);

    this.sendEmail(email);

    return {
      invoice,
      email,
      auditRecord: this.formatAuditRecord(order.id, invoice)
    };
  }

  private calculateInvoice(items: LineItem[]): Invoice {
    const subtotalCents = this.calculateSubtotal(items);
    const taxCents = this.calculateTax(subtotalCents);

    return {
      subtotalCents,
      taxCents,
      totalCents: subtotalCents + taxCents
    };
  }

  private calculateSubtotal(items: LineItem[]): number {
    return items.reduce(
      (sum, item) => sum + item.quantity * item.unitPriceCents,
      0
    );
  }

  private calculateTax(subtotalCents: number): number {
    return Math.round(subtotalCents * this.taxRate);
  }

  private composeReceiptEmail(customerEmail: string, invoice: Invoice): EmailMessage {
    return {
      to: customerEmail,
      subject: "Your receipt",
      body: `Subtotal: ${invoice.subtotalCents} cents
Tax: ${invoice.taxCents} cents
Total: ${invoice.totalCents} cents`
    };
  }

  private sendEmail(message: EmailMessage): void {
    this.sentMessages.push(message);
  }

  private formatAuditRecord(orderId: string, invoice: Invoice): string {
    return `order=${orderId} total=${invoice.totalCents}`;
  }
}

const checkout = new CheckoutManager(0.08);

const result = checkout.checkout({
  id: "ord-1001",
  customerEmail: "customer@example.com",
  items: [
    { name: "Notebook", quantity: 2, unitPriceCents: 500 },
    { name: "Pen", quantity: 3, unitPriceCents: 150 }
  ]
});

console.log(result.invoice.totalCents);
```

### 2.4 Why this difference matters

In the good form, each class has one clear reason to change: pricing rules, receipt wording, audit formatting, email delivery, or checkout orchestration. A maintainer can find the relevant behavior quickly and modify it without scanning unrelated methods.

In the less maintainable form, `CheckoutManager` owns calculation, formatting, delivery, persistence-like state, and orchestration. A change to tax rules, email copy, audit format, or delivery behavior all lands in the same class. As more checkout features are added, the class becomes a central hotspot and its responsibilities become less discoverable.

### 2.5 Structural references

```text
Good: checkout-service > checkout > checkoutService.ts > CheckoutService > submitOrder
Less maintainable: checkout-service > checkout > checkoutManager.ts > CheckoutManager > calculateTotal, composeReceiptEmail, and auditLine
```

The relevant structural difference is that the good form distributes separate responsibilities across several focused classes, while the less maintainable form concentrates those responsibilities in one class.

## 3. Boundaries and distinctions

Large Class does not mean every long class is automatically wrong. A class can be sizable but still cohesive if its methods and state all support one narrow responsibility. Data transfer objects, generated code, schema models, and framework-required declarations may also contain many members without representing a design smell.

The less maintainable form can be acceptable for a short-lived prototype, a tiny script, or a deliberately temporary implementation where the cost of decomposition is greater than the expected maintenance cost. It becomes a smell when the class keeps growing, attracts unrelated changes, or becomes the default place to put new behavior.

Large Class is closely related to **Extract Class**, which is a refactoring used to fix the smell by moving a coherent subset of fields and methods into a new class. It is different from a facade or coordinator: a facade may expose a simple entry point while delegating real work elsewhere, but a Large Class usually contains the unrelated work itself.
