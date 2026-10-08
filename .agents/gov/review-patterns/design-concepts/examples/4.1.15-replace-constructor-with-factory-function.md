# Replace Constructor with Factory Function

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.15
- **Aliases:** replace constructor with factory method
- **Definition:** Replace direct construction with a named creation function. It can make creation intent, validation, or subtype selection visible.
- **Why it matters:** A named factory function makes object creation read like a domain action instead of a list of constructor arguments. It centralizes validation, defaults, normalization, and subtype selection, which makes call sites easier to understand and future creation rules easier to change.
- **Related concepts:** Factory Method

## 2. Example

### 2.1 Scenario

A support system imports ticket rows from a partner feed. Rows with high severity should become escalated tickets, while other rows should become standard tickets.

### 2.2 Good form

```ts
type ImportRow = {
  customerEmail: string;
  summary: string;
  severity: number;
};

interface Ticket {
  customerEmail: string;
  summary: string;
  severity: number;
  queue: string;
}

class StandardTicket implements Ticket {
  readonly queue = "standard";

  constructor(
    readonly customerEmail: string,
    readonly summary: string,
    readonly severity: number,
  ) {}
}

class EscalatedTicket implements Ticket {
  readonly queue = "escalations";

  constructor(
    readonly customerEmail: string,
    readonly summary: string,
    readonly severity: number,
  ) {}
}

function normalizeSummary(summary: string): string {
  return summary.trim();
}

function assertValidEmail(email: string): void {
  if (!email.includes("@")) {
    throw new Error(`Invalid customer email: ${email}`);
  }
}

function createTicketFromImportRow(row: ImportRow): Ticket {
  const email = row.customerEmail.trim().toLowerCase();
  const summary = normalizeSummary(row.summary);

  assertValidEmail(email);

  if (row.severity >= 8) {
    return new EscalatedTicket(email, summary, row.severity);
  }

  return new StandardTicket(email, summary, row.severity);
}

export function importTickets(rows: ImportRow[]): Ticket[] {
  return rows.map(createTicketFromImportRow);
}
```

### 2.3 Less maintainable form

```ts
type ImportRow = {
  customerEmail: string;
  summary: string;
  severity: number;
};

interface Ticket {
  customerEmail: string;
  summary: string;
  severity: number;
  queue: string;
}

class StandardTicket implements Ticket {
  readonly queue = "standard";

  constructor(
    readonly customerEmail: string,
    readonly summary: string,
    readonly severity: number,
  ) {}
}

class EscalatedTicket implements Ticket {
  readonly queue = "escalations";

  constructor(
    readonly customerEmail: string,
    readonly summary: string,
    readonly severity: number,
  ) {}
}

function normalizeSummary(summary: string): string {
  return summary.trim();
}

function assertValidEmail(email: string): void {
  if (!email.includes("@")) {
    throw new Error(`Invalid customer email: ${email}`);
  }
}

export function importTickets(rows: ImportRow[]): Ticket[] {
  return rows.map((row) => {
    const email = row.customerEmail.trim().toLowerCase();
    const summary = normalizeSummary(row.summary);

    assertValidEmail(email);

    if (row.severity >= 8) {
      return new EscalatedTicket(email, summary, row.severity);
    }

    return new StandardTicket(email, summary, row.severity);
  });
}
```

### 2.4 Why this difference matters

The good form gives the creation rule a name: `createTicketFromImportRow`. The caller no longer has to inspect constructor calls, argument order, validation, and the severity branch to understand what kind of creation is happening. If the import rule changes, such as adding a default severity, routing more subtypes, or changing normalization, the change is localized in the factory function instead of being mixed into the import workflow.

### 2.5 Structural references

```text
Good: support-importer > tickets > ticket-import.ts > createTicketFromImportRow > new EscalatedTicket
Less maintainable: support-importer > tickets > ticket-import.ts > importTickets > new EscalatedTicket
```

The relevant structural difference is that object construction moves out of the workflow function and into a named creation function. The constructors still exist, but the call site depends on the factory function that represents the domain-specific creation intent.

## 3. Boundaries and distinctions

This refactoring is most useful when construction has meaning beyond simply assigning fields, such as validation, normalization, default values, caching, subtype selection, or a name that clarifies intent. It may not be worthwhile for simple value objects where `new Money(10, "USD")` is already clear and has no duplicated setup rule.

Direct construction can still be appropriate inside the factory function itself, in tests that intentionally exercise a constructor, or in code where the constructor is the clearest public creation API.

This differs from the Factory Method pattern. Replace Constructor with Factory Function is a refactoring that introduces a named creation function at a call site or module boundary. Factory Method is a design pattern where subclasses or overriding methods decide which concrete object to create. Here, the important change is replacing direct `new` usage with a named function that exposes and centralizes creation intent.
