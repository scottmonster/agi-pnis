# Move Statements to Callers

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.10
- **Aliases:** None
- **Definition:** Move statements out when a function wrongly bundles behavior that different callers need to control. It makes the function's actual responsibility narrower.
- **Why it matters:** It keeps a function focused on the behavior all callers actually share, so caller-specific steps are visible where the caller's intent is expressed. This reduces conditional logic, makes changes safer, and prevents one caller's formatting or side effects from leaking into another caller's path.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing system builds an overdue invoice summary for both customer reminder emails and internal review notes. The summary is shared, but each caller needs to control its own surrounding message text.

### 2.2 Good form

```ts
type Invoice = {
  id: string;
  customerEmail: string;
  accountOwner: string;
  totalCents: number;
  daysOverdue: number;
};

type Email = {
  to: string;
  subject: string;
  body: string;
};

function formatMoney(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function renderOverdueSummary(invoice: Invoice): string {
  return [
    `Invoice ${invoice.id} is ${invoice.daysOverdue} days overdue.`,
    `Amount due: ${formatMoney(invoice.totalCents)}.`
  ].join("\n");
}

function buildReminderEmail(invoice: Invoice): Email {
  const body = [
    renderOverdueSummary(invoice),
    "",
    `Pay now: https://billing.example.com/invoices/${invoice.id}/pay`,
    "Thank you."
  ].join("\n");

  return {
    to: invoice.customerEmail,
    subject: `Payment reminder for invoice ${invoice.id}`,
    body
  };
}

function buildInternalReviewNote(invoice: Invoice): string {
  return [
    "INTERNAL REVIEW",
    renderOverdueSummary(invoice),
    `Account owner: ${invoice.accountOwner}.`
  ].join("\n");
}

const invoice: Invoice = {
  id: "INV-1007",
  customerEmail: "customer@example.com",
  accountOwner: "Riley",
  totalCents: 125000,
  daysOverdue: 18
};

const email = buildReminderEmail(invoice);
const reviewNote = buildInternalReviewNote(invoice);

console.log(email.body);
console.log(reviewNote);
```

### 2.3 Less maintainable form

```ts
type Invoice = {
  id: string;
  customerEmail: string;
  accountOwner: string;
  totalCents: number;
  daysOverdue: number;
};

type Email = {
  to: string;
  subject: string;
  body: string;
};

type OverdueSummaryAudience = "customerEmail" | "internalReview";

function formatMoney(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function renderOverdueSummary(invoice: Invoice, audience: OverdueSummaryAudience): string {
  const lines = [
    `Invoice ${invoice.id} is ${invoice.daysOverdue} days overdue.`,
    `Amount due: ${formatMoney(invoice.totalCents)}.`
  ];

  if (audience === "customerEmail") {
    lines.push("");
    lines.push(`Pay now: https://billing.example.com/invoices/${invoice.id}/pay`);
    lines.push("Thank you.");
  }

  if (audience === "internalReview") {
    lines.unshift("INTERNAL REVIEW");
    lines.push(`Account owner: ${invoice.accountOwner}.`);
  }

  return lines.join("\n");
}

function buildReminderEmail(invoice: Invoice): Email {
  return {
    to: invoice.customerEmail,
    subject: `Payment reminder for invoice ${invoice.id}`,
    body: renderOverdueSummary(invoice, "customerEmail")
  };
}

function buildInternalReviewNote(invoice: Invoice): string {
  return renderOverdueSummary(invoice, "internalReview");
}

const invoice: Invoice = {
  id: "INV-1007",
  customerEmail: "customer@example.com",
  accountOwner: "Riley",
  totalCents: 125000,
  daysOverdue: 18
};

const email = buildReminderEmail(invoice);
const reviewNote = buildInternalReviewNote(invoice);

console.log(email.body);
console.log(reviewNote);
```

### 2.4 Why this difference matters

In the good form, `renderOverdueSummary` contains only the summary statements that every caller needs. The customer payment link, thank-you line, internal label, and account-owner line have been moved to the callers that decide whether those statements belong in the output.

In the less maintainable form, `renderOverdueSummary` knows about both customer email formatting and internal review formatting. Adding another caller would likely add another audience value and more conditional branches, even though the shared responsibility is only rendering the overdue summary.

### 2.5 Structural references

```text
Good: billing-app > billing > overdueMessages.ts > buildReminderEmail > customer email statements
Less maintainable: billing-app > billing > overdueMessages.ts > renderOverdueSummary > customer email statements
```

The relevant structural difference is where the caller-specific statements live. In the good form, they are inside the caller function that owns the customer email use case. In the less maintainable form, they are inside the shared summary function, making that function responsible for behavior that only some callers need.

## 3. Boundaries and distinctions

Move Statements to Callers applies when a function includes steps that are not part of its stable, shared responsibility and different callers need to vary, omit, reorder, or replace those steps.

It does not apply when the statements are required invariants of the function. For example, validation, cleanup, transaction handling, or audit logging may belong inside the function if every valid use of that function must perform them consistently. The less maintainable form can also be appropriate temporarily when there is only one caller, or when centralizing the behavior is required to enforce a policy.

This refactoring differs from simply extracting a function. Extraction creates a new named function from existing statements, while Move Statements to Callers changes ownership of statements from the callee to its callers. It also differs from moving a whole function to another module, because the function stays in place and becomes narrower.
