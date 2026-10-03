# Pull Up Constructor Body

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.10
- **Aliases:** None
- **Definition:** Move common subclass-constructor initialization into the superclass constructor. It keeps shared initialization in one visible place and reduces constructor drift.
- **Why it matters:** Shared construction rules are easier to read, verify, and change when they live in the superclass that owns the shared state. Each subclass constructor then shows only what is unique to that subclass.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing system creates different document types. Every billing document records the same customer and audit fields, while each subtype adds its own specific data.

### 2.2 Good form

```ts
abstract class BillingDocument {
  public readonly customerId: string;
  public readonly issuedBy: string;
  public readonly issuedAt: Date;

  protected constructor(customerId: string, issuedBy: string) {
    if (customerId.trim() === "") {
      throw new Error("customerId is required");
    }

    this.customerId = customerId;
    this.issuedBy = issuedBy;
    this.issuedAt = new Date();
  }
}

class Invoice extends BillingDocument {
  public readonly invoiceNumber: string;
  public readonly amountCents: number;

  constructor(
    customerId: string,
    issuedBy: string,
    invoiceNumber: string,
    amountCents: number
  ) {
    super(customerId, issuedBy);
    this.invoiceNumber = invoiceNumber;
    this.amountCents = amountCents;
  }
}

class CreditNote extends BillingDocument {
  public readonly creditNoteNumber: string;
  public readonly refundedCents: number;

  constructor(
    customerId: string,
    issuedBy: string,
    creditNoteNumber: string,
    refundedCents: number
  ) {
    super(customerId, issuedBy);
    this.creditNoteNumber = creditNoteNumber;
    this.refundedCents = refundedCents;
  }
}

const invoice = new Invoice("cust-123", "billing-api", "inv-9001", 12500);
const creditNote = new CreditNote("cust-123", "billing-api", "cn-3001", 2500);

console.log(invoice.customerId, invoice.issuedAt);
console.log(creditNote.customerId, creditNote.issuedAt);
```

### 2.3 Less maintainable form

```ts
abstract class BillingDocument {
  public customerId!: string;
  public issuedBy!: string;
  public issuedAt!: Date;
}

class Invoice extends BillingDocument {
  public readonly invoiceNumber: string;
  public readonly amountCents: number;

  constructor(
    customerId: string,
    issuedBy: string,
    invoiceNumber: string,
    amountCents: number
  ) {
    super();

    if (customerId.trim() === "") {
      throw new Error("customerId is required");
    }

    this.customerId = customerId;
    this.issuedBy = issuedBy;
    this.issuedAt = new Date();

    this.invoiceNumber = invoiceNumber;
    this.amountCents = amountCents;
  }
}

class CreditNote extends BillingDocument {
  public readonly creditNoteNumber: string;
  public readonly refundedCents: number;

  constructor(
    customerId: string,
    issuedBy: string,
    creditNoteNumber: string,
    refundedCents: number
  ) {
    super();

    if (customerId.trim() === "") {
      throw new Error("customerId is required");
    }

    this.customerId = customerId;
    this.issuedBy = issuedBy;
    this.issuedAt = new Date();

    this.creditNoteNumber = creditNoteNumber;
    this.refundedCents = refundedCents;
  }
}

const invoice = new Invoice("cust-123", "billing-api", "inv-9001", 12500);
const creditNote = new CreditNote("cust-123", "billing-api", "cn-3001", 2500);

console.log(invoice.customerId, invoice.issuedAt);
console.log(creditNote.customerId, creditNote.issuedAt);
```

### 2.4 Why this difference matters

In the good form, the superclass constructor is the single place that establishes the shared `BillingDocument` state and validation rule. Subclass constructors only pass common inputs to `super(...)` and then initialize subtype-specific fields.

In the less maintainable form, every subclass repeats the same validation and assignments. If the audit fields change, a new validation rule is added, or the timestamp source changes, each subclass constructor must be updated consistently. Missing one constructor creates constructor drift, where different subclasses no longer build the shared superclass state the same way.

### 2.5 Structural references

```text
Good: PaymentAccount.constructor > accountId and ownerEmail assignments
Less maintainable: CreditAccount and DebitAccount constructors > duplicate validation and assignments
```

The relevant structural difference is the location of the shared constructor body. In the good form, shared initialization is centralized in the superclass constructor. In the less maintainable form, the same initialization is scattered across subclass constructors.

## 3. Boundaries and distinctions

Pull Up Constructor Body applies when multiple subclass constructors perform the same initialization for state or invariants owned by the superclass. It is most useful when the duplicated code is truly common and should run for every subclass instance.

It does not apply when the constructor logic is only superficially similar but depends on subtype-specific rules, ordering, side effects, or validation. In those cases, forcing the code into the superclass can hide important subclass behavior or require awkward conditionals.

The less maintainable form can be acceptable when there are only one or two short-lived subclasses, when the shared superclass is not stable yet, or when each subclass is expected to diverge soon. Duplication may also be appropriate if the superclass does not conceptually own the initialized state.

This refactoring is different from pulling up an ordinary method or field. Pull Up Constructor Body is specifically about construction-time initialization: moving the common body of subclass constructors into the superclass constructor while preserving subclass-specific constructor work in each subclass.
