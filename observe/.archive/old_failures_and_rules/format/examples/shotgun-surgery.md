# Shotgun Surgery

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.4
- **Aliases:** None
- **Definition:** One conceptual change requires many small edits across locations. Knowledge of one rule is scattered and omissions become likely.
- **Why it matters:** It makes code harder to understand and change because readers must discover every place that encodes the same rule before they can safely modify it.
- **Related concepts:** Move Function

## 2. Example

### 2.1 Scenario

A billing system applies the same late-fee policy in customer reminders, ledger entries, and support previews. The intended behavior is identical in both examples.

### 2.2 Good form

```ts
type Invoice = {
  id: string;
  customerEmail: string;
  dueDate: Date;
  totalCents: number;
};

type LedgerEntry = {
  invoiceId: string;
  amountCents: number;
  reason: string;
};

const DAY_IN_MS = 24 * 60 * 60 * 1000;

function daysPastDue(invoice: Invoice, today: Date): number {
  return Math.max(0, Math.floor((today.getTime() - invoice.dueDate.getTime()) / DAY_IN_MS));
}

function calculateLateFeeCents(invoice: Invoice, today: Date): number {
  const daysLate = daysPastDue(invoice, today);
  const dailyFeeCents = daysLate * 150;
  const percentageCapCents = Math.round(invoice.totalCents * 0.1);

  return Math.min(dailyFeeCents, percentageCapCents);
}

function buildPaymentReminder(invoice: Invoice, today: Date): string {
  const lateFeeCents = calculateLateFeeCents(invoice, today);

  return [
    `To: ${invoice.customerEmail}`,
    `Invoice ${invoice.id} is overdue.`,
    `Late fee: $${(lateFeeCents / 100).toFixed(2)}`
  ].join("\n");
}

function createLateFeeLedgerEntry(invoice: Invoice, today: Date): LedgerEntry {
  return {
    invoiceId: invoice.id,
    amountCents: calculateLateFeeCents(invoice, today),
    reason: "Late fee"
  };
}

function buildSupportPreview(invoice: Invoice, today: Date): string {
  const lateFeeCents = calculateLateFeeCents(invoice, today);

  return `Invoice ${invoice.id}: current late fee is $${(lateFeeCents / 100).toFixed(2)}.`;
}
```

### 2.3 Less maintainable form

```ts
type Invoice = {
  id: string;
  customerEmail: string;
  dueDate: Date;
  totalCents: number;
};

type LedgerEntry = {
  invoiceId: string;
  amountCents: number;
  reason: string;
};

const DAY_IN_MS = 24 * 60 * 60 * 1000;

function buildPaymentReminder(invoice: Invoice, today: Date): string {
  const daysLate = Math.max(0, Math.floor((today.getTime() - invoice.dueDate.getTime()) / DAY_IN_MS));
  const dailyFeeCents = daysLate * 150;
  const percentageCapCents = Math.round(invoice.totalCents * 0.1);
  const lateFeeCents = Math.min(dailyFeeCents, percentageCapCents);

  return [
    `To: ${invoice.customerEmail}`,
    `Invoice ${invoice.id} is overdue.`,
    `Late fee: $${(lateFeeCents / 100).toFixed(2)}`
  ].join("\n");
}

function createLateFeeLedgerEntry(invoice: Invoice, today: Date): LedgerEntry {
  const daysLate = Math.max(0, Math.floor((today.getTime() - invoice.dueDate.getTime()) / DAY_IN_MS));
  const dailyFeeCents = daysLate * 150;
  const percentageCapCents = Math.round(invoice.totalCents * 0.1);
  const lateFeeCents = Math.min(dailyFeeCents, percentageCapCents);

  return {
    invoiceId: invoice.id,
    amountCents: lateFeeCents,
    reason: "Late fee"
  };
}

function buildSupportPreview(invoice: Invoice, today: Date): string {
  const daysLate = Math.max(0, Math.floor((today.getTime() - invoice.dueDate.getTime()) / DAY_IN_MS));
  const dailyFeeCents = daysLate * 150;
  const percentageCapCents = Math.round(invoice.totalCents * 0.1);
  const lateFeeCents = Math.min(dailyFeeCents, percentageCapCents);

  return `Invoice ${invoice.id}: current late fee is $${(lateFeeCents / 100).toFixed(2)}.`;
}
```

### 2.4 Why this difference matters

In the good form, the late-fee policy has one home: `calculateLateFeeCents`. If the business changes the daily fee or the cap, the change is made once and every caller gets the new behavior.

In the less maintainable form, the same rule is repeated in reminder, ledger, and support code. A policy change requires several small edits in separate locations. Missing one location creates inconsistent behavior, which is the mechanism behind Shotgun Surgery.

### 2.5 Structural references

```text
Good: calculateLateFeeCents > shared late-fee rule
Less maintainable: invoiceLateFeeCents and statementLateFeeCents > duplicated late-fee formulas
```

The relevant structural difference is that the good form localizes one business rule in one function, while the less maintainable form spreads the same rule across multiple functions that must be edited together.

## 3. Boundaries and distinctions

Shotgun Surgery does not apply to every change that touches multiple files. Some changes are naturally cross-cutting, such as adding a required field to an API contract, updating a public type, or introducing a new feature that genuinely affects several workflows.

The less maintainable form can be acceptable for short-lived experiments, generated code, or deliberately independent policies that only look similar today but are expected to evolve separately.

Shotgun Surgery is a smell about scattered knowledge: one conceptual rule is duplicated across locations. `Move Function` is a refactoring that may help when behavior is in the wrong place, but moving a function alone is not the goal. The goal is to put the rule where callers can share it, so one policy change does not require many coordinated edits.
