# Fluent Interface

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 2.2.11
- **Aliases:** None
- **Definition:** Design a call sequence so each call returns an object that permits the next meaningful call. It can make a coherent declarative sequence readable, but excessive chaining can become a Message Chain or hide intermediate values.
- **Why it matters:** A fluent interface makes a required sequence read like a small domain sentence, so callers can understand the intent without inspecting temporary state or remembering valid call order. It also improves maintainability by making invalid or incomplete sequences harder to express.
- **Related concepts:** Builder, Message Chain. Distinction: method chaining is a common implementation technique, not a synonym for fluency.

## 2. Example

### 2.1 Scenario

A billing service builds an overdue-invoice report for one customer. The report must choose a customer, choose a status, choose an ordering, choose a limit, and then execute.

### 2.2 Good form

```ts
type InvoiceStatus = "open" | "paid" | "overdue";

type Invoice = {
  id: string;
  customerId: string;
  status: InvoiceStatus;
  dueDate: string;
  amount: number;
};

interface CustomerStep {
  forCustomer(customerId: string): StatusStep;
}

interface StatusStep {
  withStatus(status: InvoiceStatus): SortStep;
}

interface SortStep {
  orderedBy(field: "dueDate" | "amount", direction: "asc" | "desc"): LimitStep;
}

interface LimitStep {
  limitTo(count: number): ExecuteStep;
}

interface ExecuteStep {
  execute(): Invoice[];
}

class InvoiceReportQuery
  implements CustomerStep, StatusStep, SortStep, LimitStep, ExecuteStep
{
  private customerId = "";
  private status: InvoiceStatus = "open";
  private sortField: "dueDate" | "amount" = "dueDate";
  private sortDirection: "asc" | "desc" = "asc";
  private maxRows = 10;

  private constructor(private readonly invoices: Invoice[]) {}

  static from(invoices: Invoice[]): CustomerStep {
    return new InvoiceReportQuery(invoices);
  }

  forCustomer(customerId: string): StatusStep {
    this.customerId = customerId;
    return this;
  }

  withStatus(status: InvoiceStatus): SortStep {
    this.status = status;
    return this;
  }

  orderedBy(field: "dueDate" | "amount", direction: "asc" | "desc"): LimitStep {
    this.sortField = field;
    this.sortDirection = direction;
    return this;
  }

  limitTo(count: number): ExecuteStep {
    this.maxRows = count;
    return this;
  }

  execute(): Invoice[] {
    const direction = this.sortDirection === "asc" ? 1 : -1;

    return this.invoices
      .filter(
        invoice =>
          invoice.customerId === this.customerId &&
          invoice.status === this.status
      )
      .sort((left, right) => {
        const leftValue = left[this.sortField];
        const rightValue = right[this.sortField];

        if (leftValue < rightValue) {
          return -1 * direction;
        }

        if (leftValue > rightValue) {
          return 1 * direction;
        }

        return 0;
      })
      .slice(0, this.maxRows);
  }
}

function buildOverdueInvoiceReport(
  invoices: Invoice[],
  customerId: string
): Invoice[] {
  return InvoiceReportQuery
    .from(invoices)
    .forCustomer(customerId)
    .withStatus("overdue")
    .orderedBy("dueDate", "asc")
    .limitTo(10)
    .execute();
}
```

### 2.3 Less maintainable form

```ts
type InvoiceStatus = "open" | "paid" | "overdue";

type Invoice = {
  id: string;
  customerId: string;
  status: InvoiceStatus;
  dueDate: string;
  amount: number;
};

class GenericInvoiceQuery {
  private filters: Array<{ field: string; value: string }> = [];
  private sortField = "dueDate";
  private sortDirection: "asc" | "desc" = "asc";
  private maxRows = 10;

  constructor(private readonly invoices: Invoice[]) {}

  where(field: string, value: string): this {
    this.filters.push({ field, value });
    return this;
  }

  sort(field: string, direction: "asc" | "desc"): this {
    this.sortField = field;
    this.sortDirection = direction;
    return this;
  }

  take(count: number): this {
    this.maxRows = count;
    return this;
  }

  run(): Invoice[] {
    const direction = this.sortDirection === "asc" ? 1 : -1;

    return this.invoices
      .filter(invoice =>
        this.filters.every(filter => {
          const invoiceValue = invoice[filter.field as keyof Invoice];
          return String(invoiceValue) === filter.value;
        })
      )
      .sort((left, right) => {
        const leftValue = left[this.sortField as keyof Invoice];
        const rightValue = right[this.sortField as keyof Invoice];

        if (leftValue < rightValue) {
          return -1 * direction;
        }

        if (leftValue > rightValue) {
          return 1 * direction;
        }

        return 0;
      })
      .slice(0, this.maxRows);
  }
}

function buildOverdueInvoiceReport(
  invoices: Invoice[],
  customerId: string
): Invoice[] {
  return new GenericInvoiceQuery(invoices)
    .where("customerId", customerId)
    .where("status", "overdue")
    .sort("dueDate", "asc")
    .take(10)
    .run();
}
```

### 2.4 Why this difference matters

The good form makes the valid reporting sequence explicit in the return types: after selecting a customer, the caller can only select a status; after selecting a status, the caller can only choose ordering; execution is only available after the required steps are complete. The chain reads as a domain-specific sentence.

The less maintainable form uses chaining, but every method returns the same broad object. It permits many meaningless sequences, such as running without required filters, sorting by an invalid field, or adding conditions in a confusing order. That is method chaining, but it is not the same as a fluent interface that guides the next meaningful call.

### 2.5 Structural references

```text
Good: buildOverdueInvoiceReport > staged report query methods
Less maintainable: buildOverdueInvoiceReport > rawQuery.where/select/orderBy chain
```

The relevant structural difference is the target API shape. The good form exposes staged operations whose returned types describe the next valid operation. The less maintainable form exposes one generic chainable object that accepts loosely typed operations in almost any order.

## 3. Boundaries and distinctions

A fluent interface is useful when the call sequence represents a coherent domain phrase or required workflow. It is less useful when the operations are independent, heavily branched, or easier to understand with named intermediate variables.

The less maintainable form can be appropriate for internal tooling, exploratory filters, or simple wrappers where flexibility is more important than guiding a fixed sequence. It becomes risky when callers must remember business rules that the API could have expressed.

Fluent Interface differs from Builder because a Builder focuses on assembling an object, while a fluent interface focuses on making a sequence of calls read clearly and permit meaningful next calls. A Builder may use a fluent interface, but it does not have to.

Fluent Interface also differs from Message Chain. A Message Chain navigates through a series of returned objects, often exposing too much object structure. A fluent interface deliberately designs the sequence as a readable domain expression. Method chaining is only one implementation technique; returning `this` from every method does not automatically make an API fluent.
