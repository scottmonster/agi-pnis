# Template Method

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.21
- **Aliases:** None
- **Definition:** Put an algorithm's invariant skeleton in a base operation and defer selected steps to subclasses. It reveals the algorithm structure, but binds variation to inheritance.
- **Why it matters:** It makes the fixed order of an algorithm easy to read in one place while isolating the steps that vary. This reduces duplicated control flow, but it also means future variation must fit the inheritance model.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing service exports paid invoices in multiple formats. Every export fetches invoices, keeps only paid ones, serializes them, and writes a file, but the filename and serialization format vary.

### 2.2 Good form

```ts
type Invoice = {
  id: string;
  customer: string;
  amountCents: number;
  status: "paid" | "draft" | "void";
};

interface Storage {
  write(fileName: string, contents: string): void;
}

class MemoryStorage implements Storage {
  public readonly files = new Map<string, string>();

  write(fileName: string, contents: string): void {
    this.files.set(fileName, contents);
  }
}

abstract class PaidInvoiceExportJob {
  constructor(
    private readonly invoices: Invoice[],
    private readonly storage: Storage,
  ) {}

  // Template method: the invariant algorithm skeleton lives here.
  run(): void {
    const paidInvoices = this.loadInvoices().filter((invoice) => invoice.status === "paid");
    const contents = this.serialize(paidInvoices);
    this.storage.write(this.fileName(), contents);
  }

  protected loadInvoices(): Invoice[] {
    return this.invoices;
  }

  protected abstract fileName(): string;

  protected abstract serialize(invoices: Invoice[]): string;
}

class CsvPaidInvoiceExportJob extends PaidInvoiceExportJob {
  protected fileName(): string {
    return "paid-invoices.csv";
  }

  protected serialize(invoices: Invoice[]): string {
    const rows = invoices.map((invoice) =>
      [invoice.id, invoice.customer, invoice.amountCents].join(","),
    );

    return ["id,customer,amountCents", ...rows].join("\n");
  }
}

class JsonPaidInvoiceExportJob extends PaidInvoiceExportJob {
  protected fileName(): string {
    return "paid-invoices.json";
  }

  protected serialize(invoices: Invoice[]): string {
    return JSON.stringify(invoices, null, 2);
  }
}

const invoices: Invoice[] = [
  { id: "INV-001", customer: "Acme", amountCents: 12500, status: "paid" },
  { id: "INV-002", customer: "Globex", amountCents: 8300, status: "draft" },
  { id: "INV-003", customer: "Initech", amountCents: 4200, status: "paid" },
];

const storage = new MemoryStorage();

new CsvPaidInvoiceExportJob(invoices, storage).run();
new JsonPaidInvoiceExportJob(invoices, storage).run();
```

### 2.3 Less maintainable form

```ts
type Invoice = {
  id: string;
  customer: string;
  amountCents: number;
  status: "paid" | "draft" | "void";
};

interface Storage {
  write(fileName: string, contents: string): void;
}

class MemoryStorage implements Storage {
  public readonly files = new Map<string, string>();

  write(fileName: string, contents: string): void {
    this.files.set(fileName, contents);
  }
}

function exportPaidInvoicesAsCsv(invoices: Invoice[], storage: Storage): void {
  const loadedInvoices = invoices;
  const paidInvoices = loadedInvoices.filter((invoice) => invoice.status === "paid");

  const rows = paidInvoices.map((invoice) =>
    [invoice.id, invoice.customer, invoice.amountCents].join(","),
  );
  const contents = ["id,customer,amountCents", ...rows].join("\n");

  storage.write("paid-invoices.csv", contents);
}

function exportPaidInvoicesAsJson(invoices: Invoice[], storage: Storage): void {
  const loadedInvoices = invoices;
  const paidInvoices = loadedInvoices.filter((invoice) => invoice.status === "paid");

  const contents = JSON.stringify(paidInvoices, null, 2);

  storage.write("paid-invoices.json", contents);
}

const invoices: Invoice[] = [
  { id: "INV-001", customer: "Acme", amountCents: 12500, status: "paid" },
  { id: "INV-002", customer: "Globex", amountCents: 8300, status: "draft" },
  { id: "INV-003", customer: "Initech", amountCents: 4200, status: "paid" },
];

const storage = new MemoryStorage();

exportPaidInvoicesAsCsv(invoices, storage);
exportPaidInvoicesAsJson(invoices, storage);
```

### 2.4 Why this difference matters

In the good form, `PaidInvoiceExportJob.run` states the export algorithm once: load invoices, filter paid invoices, serialize, and write. Subclasses can only vary the selected steps, `fileName` and `serialize`, so readers can understand the workflow without comparing multiple functions.

In the less maintainable form, each export function repeats the same algorithm skeleton. If the invariant workflow changes, such as adding audit logging, sorting, authorization, or a different paid-invoice filter, every export function must be updated consistently.

### 2.5 Structural references

```text
Good: reporting-service > exports > invoiceExportJob.ts > PaidInvoiceExportJob.run > writeBody
Less maintainable: reporting-service > exports > invoiceExports.ts > exportPaidInvoicesAsCsv and exportPaidInvoicesAsJson
```

The relevant structural difference is that the good form has one central operation that owns the algorithm order, while the less maintainable form spreads the same order across multiple sibling functions.

## 3. Boundaries and distinctions

Template Method applies when several variants share a stable algorithm sequence and differ only in specific steps. It is a poor fit when the sequence itself changes often, when variants must be composed dynamically at runtime, or when inheritance would force unrelated implementations into the same hierarchy.

The less maintainable form can be appropriate for a tiny script, a one-off export, or a case with only one variant and no expected reuse. Avoid introducing a base class before there is a real shared algorithm skeleton.

Template Method is often confused with Strategy. Template Method uses inheritance: the base class controls the algorithm and subclasses override steps. Strategy uses composition: an object delegates a variable part to another object, often allowing runtime replacement. Template Method reveals a fixed workflow clearly, but it also couples variation to subclassing.
