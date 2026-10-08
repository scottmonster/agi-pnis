# Inline Function

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.1.2
- **Aliases:** inline method
- **Definition:** Replace a function call with its body when the function no longer adds meaning. It removes indirection that hides rather than names behavior.
- **Why it matters:** It makes code easier to read by keeping trivial behavior at the call site, so readers do not have to jump to another function that only repeats what the caller already implies.
- **Related concepts:** Middle Man

## 2. Example

### 2.1 Scenario

An invoicing service builds the body of an invoice reminder email. A previous helper only returns a field from the invoice and no longer captures any business rule.

### 2.2 Good form

```ts
type Invoice = {
  id: string;
  customerName: string;
  totalCents: number;
  dueDate: Date;
};

function formatMoney(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function formatDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

export function buildInvoiceReminder(invoice: Invoice): string {
  const total = formatMoney(invoice.totalCents);
  const dueDate = formatDate(invoice.dueDate);

  return `Hello ${invoice.customerName}, invoice ${invoice.id} for ${total} is due on ${dueDate}.`;
}
```

### 2.3 Less maintainable form

```ts
type Invoice = {
  id: string;
  customerName: string;
  totalCents: number;
  dueDate: Date;
};

function formatMoney(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function formatDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function invoiceDueDate(invoice: Invoice): Date {
  return invoice.dueDate;
}

export function buildInvoiceReminder(invoice: Invoice): string {
  const total = formatMoney(invoice.totalCents);
  const dueDate = formatDate(invoiceDueDate(invoice));

  return `Hello ${invoice.customerName}, invoice ${invoice.id} for ${total} is due on ${dueDate}.`;
}
```

### 2.4 Why this difference matters

In the good form, the call site shows the actual behavior directly: the reminder uses `invoice.dueDate`. In the less maintainable form, `invoiceDueDate(invoice)` suggests there may be a rule, calculation, or abstraction worth understanding, but the function only returns the same field. That extra hop adds navigation cost without adding meaning.

### 2.5 Structural references

```text
Good: billing-app > billing > invoice-email.ts > buildInvoiceReminder > invoice.dueDate
Less maintainable: billing-app > billing > invoice-email.ts > buildInvoiceReminder > invoiceDueDate(invoice)
```

The less maintainable structure adds a separate function target for behavior that is just a field access. The good structure keeps that behavior inside the caller, where it is used.

## 3. Boundaries and distinctions

Inline Function does not apply when the function name explains a domain rule, hides a volatile implementation, removes duplication, or provides a useful seam for testing or extension. A small function can still be valuable if it says something the body does not say clearly.

The less maintainable form may be appropriate if `invoiceDueDate` is expected to grow into a real policy, such as calculating grace periods, handling time zones, or selecting between contract-specific due dates. In that case, the function would name a meaningful concept rather than merely forward a property.

Inline Function differs from removing a Middle Man. Inline Function removes a local function whose body is clearer than its call. Removing a Middle Man targets a delegating object or layer that only forwards requests to another object, reducing unnecessary pass-through structure at a broader design level.
