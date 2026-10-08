# Repository

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 3.2.6
- **Aliases:** None
- **Definition:** Provide collection-like access to domain objects while hiding storage queries. It can centralize persistence vocabulary, but is not automatically useful over every data source.
- **Why it matters:** A Repository keeps persistence-specific query details out of application logic, making domain workflows read in domain terms and reducing the number of places that must change when storage or query shape changes.
- **Related concepts:** Data Mapper

## 2. Example

### 2.1 Scenario

A billing job sends reminder emails for overdue invoices. The intended behavior is to find unpaid invoices older than a cutoff date, send a reminder for each one, and mark each invoice as reminded.

### 2.2 Good form

```ts
type InvoiceStatus = "unpaid" | "paid";

type InvoiceRecord = {
  id: string;
  customerEmail: string;
  dueDate: string;
  status: InvoiceStatus;
  remindedAt: string | null;
};

class Invoice {
  constructor(
    readonly id: string,
    readonly customerEmail: string,
    readonly dueDate: Date,
    readonly status: InvoiceStatus,
    private remindedAt: Date | null
  ) {}

  isUnpaid(): boolean {
    return this.status === "unpaid";
  }

  markReminderSent(at: Date): void {
    this.remindedAt = at;
  }

  toRecord(): InvoiceRecord {
    return {
      id: this.id,
      customerEmail: this.customerEmail,
      dueDate: this.dueDate.toISOString(),
      status: this.status,
      remindedAt: this.remindedAt?.toISOString() ?? null,
    };
  }
}

interface Database {
  query<T>(sql: string, params: unknown[]): Promise<T[]>;
  execute(sql: string, params: unknown[]): Promise<void>;
}

interface EmailGateway {
  send(to: string, subject: string, body: string): Promise<void>;
}

class InvoiceRepository {
  constructor(private readonly db: Database) {}

  async overdueUnreminded(cutoff: Date): Promise<Invoice[]> {
    const rows = await this.db.query<InvoiceRecord>(
      `
        SELECT id, customerEmail, dueDate, status, remindedAt
        FROM invoices
        WHERE status = ? AND dueDate < ? AND remindedAt IS NULL
      `,
      ["unpaid", cutoff.toISOString()]
    );

    return rows.map((row) => this.toDomain(row));
  }

  async save(invoice: Invoice): Promise<void> {
    const row = invoice.toRecord();

    await this.db.execute(
      `
        UPDATE invoices
        SET status = ?, remindedAt = ?
        WHERE id = ?
      `,
      [row.status, row.remindedAt, row.id]
    );
  }

  private toDomain(row: InvoiceRecord): Invoice {
    return new Invoice(
      row.id,
      row.customerEmail,
      new Date(row.dueDate),
      row.status,
      row.remindedAt === null ? null : new Date(row.remindedAt)
    );
  }
}

class SendOverdueInvoiceReminders {
  constructor(
    private readonly invoices: InvoiceRepository,
    private readonly email: EmailGateway
  ) {}

  async run(cutoff: Date, now: Date): Promise<void> {
    const overdueInvoices = await this.invoices.overdueUnreminded(cutoff);

    for (const invoice of overdueInvoices) {
      await this.email.send(
        invoice.customerEmail,
        "Overdue invoice reminder",
        `Invoice ${invoice.id} is overdue.`
      );

      invoice.markReminderSent(now);
      await this.invoices.save(invoice);
    }
  }
}
```

### 2.3 Less maintainable form

```ts
type InvoiceStatus = "unpaid" | "paid";

type InvoiceRecord = {
  id: string;
  customerEmail: string;
  dueDate: string;
  status: InvoiceStatus;
  remindedAt: string | null;
};

class Invoice {
  constructor(
    readonly id: string,
    readonly customerEmail: string,
    readonly dueDate: Date,
    readonly status: InvoiceStatus,
    private remindedAt: Date | null
  ) {}

  isUnpaid(): boolean {
    return this.status === "unpaid";
  }

  markReminderSent(at: Date): void {
    this.remindedAt = at;
  }

  toRecord(): InvoiceRecord {
    return {
      id: this.id,
      customerEmail: this.customerEmail,
      dueDate: this.dueDate.toISOString(),
      status: this.status,
      remindedAt: this.remindedAt?.toISOString() ?? null,
    };
  }
}

interface Database {
  query<T>(sql: string, params: unknown[]): Promise<T[]>;
  execute(sql: string, params: unknown[]): Promise<void>;
}

interface EmailGateway {
  send(to: string, subject: string, body: string): Promise<void>;
}

class SendOverdueInvoiceReminders {
  constructor(
    private readonly db: Database,
    private readonly email: EmailGateway
  ) {}

  async run(cutoff: Date, now: Date): Promise<void> {
    const rows = await this.db.query<InvoiceRecord>(
      `
        SELECT id, customerEmail, dueDate, status, remindedAt
        FROM invoices
        WHERE status = ? AND dueDate < ? AND remindedAt IS NULL
      `,
      ["unpaid", cutoff.toISOString()]
    );

    const overdueInvoices = rows.map(
      (row) =>
        new Invoice(
          row.id,
          row.customerEmail,
          new Date(row.dueDate),
          row.status,
          row.remindedAt === null ? null : new Date(row.remindedAt)
        )
    );

    for (const invoice of overdueInvoices) {
      await this.email.send(
        invoice.customerEmail,
        "Overdue invoice reminder",
        `Invoice ${invoice.id} is overdue.`
      );

      invoice.markReminderSent(now);
      const row = invoice.toRecord();

      await this.db.execute(
        `
          UPDATE invoices
          SET status = ?, remindedAt = ?
          WHERE id = ?
        `,
        [row.status, row.remindedAt, row.id]
      );
    }
  }
}
```

### 2.4 Why this difference matters

In the good form, the application workflow asks a domain-shaped collection for `overdueUnreminded` invoices and saves changed invoices back through the same persistence boundary. The SQL predicate, table names, parameter formatting, and row-to-domain reconstruction are centralized behind `InvoiceRepository`.

In the less maintainable form, the reminder use case must know both the business workflow and the storage query. If another use case needs the same overdue-invoice meaning, it may duplicate or slightly change the SQL. If the schema, date representation, or mapping changes, workflow code must be edited even though the business behavior did not change.

### 2.5 Structural references

```text
Good: billing-service > billing > invoiceRepository.ts > overdueUnreminded > overdue invoice collection access
Less maintainable: billing-service > billing > sendOverdueInvoiceReminders.ts > run > inline overdue invoice SQL
```

The relevant structural difference is that the good form gives the persistence vocabulary its own file and function, while the less maintainable form embeds the storage query inside the application workflow function.

## 3. Boundaries and distinctions

A Repository is useful when callers need a domain-oriented collection boundary, such as finding, adding, removing, or saving aggregates by business vocabulary. It is less useful when it only renames one simple data-source call without hiding meaningful query or mapping concerns. For example, wrapping a single HTTP client method with `getUserById` may add indirection without improving the domain model.

The less maintainable form can be appropriate for a small script, a one-off migration, a narrow reporting query, or code where the query itself is the main behavior and is unlikely to be reused as domain vocabulary.

Repository is related to Data Mapper but has a different focus. A Repository presents collection-like access to domain objects and expresses persistence operations in domain terms. A Data Mapper moves data between database records and domain objects while keeping the domain objects independent of the database. A Repository may use a Data Mapper internally, but the Repository is the caller-facing collection abstraction, not the mapping mechanism itself.
