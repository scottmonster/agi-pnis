# Remove Setting Method

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.9
- **Aliases:** None
- **Definition:** Remove a public setter when a field should be initialized once and then remain unchanged. It makes immutability and the object's valid lifecycle more visible.
- **Why it matters:** It makes the object's allowed state changes explicit. Readers can see which values are fixed after construction, and maintainers do not have to search for later setter calls that might silently change object identity or lifecycle invariants.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An invoicing service assigns each invoice an id when the invoice is created. After creation, the invoice id must remain unchanged because payments, emails, and audit records refer to it.

### 2.2 Good form

```ts
let invoiceSequence = 0;

function nextInvoiceId(): string {
  invoiceSequence += 1;
  return `INV-${invoiceSequence.toString().padStart(6, "0")}`;
}

type InvoiceStatus = "draft" | "sent";

class Invoice {
  private status: InvoiceStatus = "draft";

  constructor(
    public readonly id: string,
    public readonly customerId: string,
  ) {}

  markSent(): void {
    this.status = "sent";
  }

  getStatus(): InvoiceStatus {
    return this.status;
  }
}

function createInvoice(customerId: string): Invoice {
  return new Invoice(nextInvoiceId(), customerId);
}

const invoice = createInvoice("customer-42");
invoice.markSent();

console.log(invoice.id);
console.log(invoice.getStatus());
```

### 2.3 Less maintainable form

```ts
let invoiceSequence = 0;

function nextInvoiceId(): string {
  invoiceSequence += 1;
  return `INV-${invoiceSequence.toString().padStart(6, "0")}`;
}

type InvoiceStatus = "draft" | "sent";

class Invoice {
  private currentId = "";
  private status: InvoiceStatus = "draft";

  constructor(public readonly customerId: string) {}

  get id(): string {
    return this.currentId;
  }

  setId(id: string): void {
    if (id.length === 0) {
      throw new Error("Invoice id is required.");
    }

    this.currentId = id;
  }

  markSent(): void {
    this.status = "sent";
  }

  getStatus(): InvoiceStatus {
    return this.status;
  }
}

function createInvoice(customerId: string): Invoice {
  const invoice = new Invoice(customerId);
  invoice.setId(nextInvoiceId());
  return invoice;
}

const invoice = createInvoice("customer-42");
invoice.markSent();

console.log(invoice.id);
console.log(invoice.getStatus());
```

### 2.4 Why this difference matters

In the good form, the invoice id is supplied at construction and exposed as `readonly`, so the code communicates that an invoice cannot exist in a valid state without an id and that the id is not part of the object's later mutable lifecycle. There is no public `setId` method for callers to discover, call in the wrong order, or call after the invoice has been sent.

In the less maintainable form, `setId` implies that changing the id is a normal operation. Even if current callers only use it during creation, future maintainers must treat the id as mutable and check whether later calls can invalidate references from payments, emails, or audit logs.

### 2.5 Structural references

```text
Good: billing-service > invoicing package > invoice.ts > createInvoice > Invoice.id constructor initialization
Less maintainable: billing-service > invoicing package > invoice.ts > createInvoice > Invoice.setId
```

The relevant structural difference is that the good form initializes the stable field through construction, while the less maintainable form exposes a public setting method as a separate lifecycle step.

## 3. Boundaries and distinctions

Remove Setting Method applies when a value should be assigned once and then remain stable, such as an identifier, creation timestamp, owning account, or configuration snapshot. It does not apply when changing the value is a real domain operation, such as updating a shipping address before dispatch or changing a user's display name.

The less maintainable form can be appropriate when an object must be built in stages because of framework constraints, deserialization, or dependency injection. In those cases, keep the setter as narrowly visible as possible, validate the completed object before use, or isolate the mutable construction phase from the immutable domain object.

This refactoring is specifically about removing a public setter that misrepresents a stable field as mutable. It is not merely about shortening code, hiding all state, or making every object immutable. Other fields on the same object may still be mutable if their changes are valid parts of the object's lifecycle.
