# Extract Function

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.1
- **Aliases:** extract method, replace inline code with function call
- **Definition:** Replace a detailed code fragment with a well-named function. It makes the caller show a higher-level narrative and gives the fragment a single nameable purpose.
- **Why it matters:** It separates intent from implementation details, so readers can understand the caller at a glance and inspect the extracted function only when they need the details. It also gives the behavior one place to change and one name to discuss.
- **Related concepts:** Long Function

## 2. Example

### 2.1 Scenario

A billing service builds a short invoice summary that includes the subtotal, any late fee, and the remaining balance. The late-fee calculation is detailed enough that it distracts from the summary-building narrative.

### 2.2 Good form

```ts
type InvoiceLine = {
  description: string;
  quantity: number;
  unitPriceCents: number;
};

type Invoice = {
  id: string;
  customerName: string;
  dueDate: Date;
  amountPaidCents: number;
  lines: InvoiceLine[];
};

function buildInvoiceSummary(invoice: Invoice, today: Date): string {
  const subtotalCents = invoice.lines.reduce(
    (sum, line) => sum + line.quantity * line.unitPriceCents,
    0
  );

  const lateFeeCents = calculateLateFeeCents(invoice, subtotalCents, today);
  const balanceCents = subtotalCents + lateFeeCents - invoice.amountPaidCents;

  return [
    `Invoice ${invoice.id} for ${invoice.customerName}`,
    `Subtotal: ${formatCents(subtotalCents)}`,
    `Late fee: ${formatCents(lateFeeCents)}`,
    `Balance due: ${formatCents(balanceCents)}`
  ].join("\n");
}

function calculateLateFeeCents(
  invoice: Invoice,
  subtotalCents: number,
  today: Date
): number {
  const millisecondsPerDay = 24 * 60 * 60 * 1000;
  const dueAtMidnight = new Date(
    invoice.dueDate.getFullYear(),
    invoice.dueDate.getMonth(),
    invoice.dueDate.getDate()
  );
  const todayAtMidnight = new Date(
    today.getFullYear(),
    today.getMonth(),
    today.getDate()
  );

  const daysLate = Math.floor(
    (todayAtMidnight.getTime() - dueAtMidnight.getTime()) / millisecondsPerDay
  );

  if (daysLate <= 0 || invoice.amountPaidCents >= subtotalCents) {
    return 0;
  }

  return Math.min(Math.round(subtotalCents * 0.02 * daysLate), 5_000);
}

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}
```

### 2.3 Less maintainable form

```ts
type InvoiceLine = {
  description: string;
  quantity: number;
  unitPriceCents: number;
};

type Invoice = {
  id: string;
  customerName: string;
  dueDate: Date;
  amountPaidCents: number;
  lines: InvoiceLine[];
};

function buildInvoiceSummary(invoice: Invoice, today: Date): string {
  const subtotalCents = invoice.lines.reduce(
    (sum, line) => sum + line.quantity * line.unitPriceCents,
    0
  );

  const millisecondsPerDay = 24 * 60 * 60 * 1000;
  const dueAtMidnight = new Date(
    invoice.dueDate.getFullYear(),
    invoice.dueDate.getMonth(),
    invoice.dueDate.getDate()
  );
  const todayAtMidnight = new Date(
    today.getFullYear(),
    today.getMonth(),
    today.getDate()
  );

  const daysLate = Math.floor(
    (todayAtMidnight.getTime() - dueAtMidnight.getTime()) / millisecondsPerDay
  );

  let lateFeeCents = 0;
  if (daysLate > 0 && invoice.amountPaidCents < subtotalCents) {
    lateFeeCents = Math.min(Math.round(subtotalCents * 0.02 * daysLate), 5_000);
  }

  const balanceCents = subtotalCents + lateFeeCents - invoice.amountPaidCents;

  return [
    `Invoice ${invoice.id} for ${invoice.customerName}`,
    `Subtotal: ${formatCents(subtotalCents)}`,
    `Late fee: ${formatCents(lateFeeCents)}`,
    `Balance due: ${formatCents(balanceCents)}`
  ].join("\n");
}

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}
```

### 2.4 Why this difference matters

In the good form, `buildInvoiceSummary` reads as a sequence of invoice-summary steps: compute the subtotal, compute the late fee, compute the balance, and format the output. The date normalization, day-counting, eligibility check, percentage fee, and cap are still present, but they are grouped behind the name `calculateLateFeeCents`.

That name gives the detailed fragment a single purpose. If the late-fee policy changes, the maintainer has a focused function to inspect and modify instead of scanning through the summary formatting logic.

### 2.5 Structural references

```text
Good: billing-app > billing > invoiceSummary.ts > buildInvoiceSummary > calculateLateFeeCents
Less maintainable: billing-app > billing > invoiceSummary.ts > buildInvoiceSummary > inline late-fee calculation
```

The relevant structural difference is that the good form moves the late-fee calculation into its own function and replaces the original detailed fragment with a function call. The less maintainable form keeps that detailed calculation inside the caller.

## 3. Boundaries and distinctions

Extract Function applies when a code fragment has a coherent purpose that can be named better than the raw statements can explain themselves. It is especially useful when the caller mixes different levels of detail, such as business steps and low-level date arithmetic.

The less maintainable form can be acceptable when the fragment is very small, already obvious, used only once, and an extracted name would add more indirection than clarity. It can also be reasonable during early exploration before the concept or name of the fragment is stable.

Extract Function is different from simply making a function shorter. The goal is not line count by itself, but a clearer separation between the caller's narrative and the extracted fragment's implementation. Long Function is a related smell that may suggest using Extract Function, but Extract Function is the refactoring action, while Long Function describes a possible problem.
