# Rename Variable / Rename Field

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.2.2
- **Aliases:** None
- **Definition:** Change a name to express the value or member's current role. A precise name removes local interpretation work.
- **Why it matters:** Clear variable and field names let readers understand what a value represents without tracing assignments, checking call sites, or guessing from context. This makes later changes safer because the code states the role of the data directly.
- **Related concepts:** Mysterious Name

## 2. Example

### 2.1 Scenario

A billing service builds an email message that tells a customer how many days remain before a subscription renews and what the monthly price is.

### 2.2 Good form

```ts
type Subscription = {
  customerEmail: string;
  renewalDate: Date;
  monthlyPriceCents: number;
};

function daysUntil(targetDate: Date, today: Date): number {
  const millisecondsPerDay = 24 * 60 * 60 * 1000;
  return Math.ceil((targetDate.getTime() - today.getTime()) / millisecondsPerDay);
}

function buildRenewalNotice(subscription: Subscription, today: Date): string {
  const daysUntilRenewal = daysUntil(subscription.renewalDate, today);
  const monthlyPriceDollars = (subscription.monthlyPriceCents / 100).toFixed(2);

  return `Email ${subscription.customerEmail}: your subscription renews in ${daysUntilRenewal} days at $${monthlyPriceDollars} per month.`;
}

const notice = buildRenewalNotice(
  {
    customerEmail: "customer@example.com",
    renewalDate: new Date("2026-09-01T00:00:00Z"),
    monthlyPriceCents: 1299
  },
  new Date("2026-08-16T00:00:00Z")
);

console.log(notice);
```

### 2.3 Less maintainable form

```ts
type Subscription = {
  customerEmail: string;
  d: Date;
  value: number;
};

function daysUntil(targetDate: Date, today: Date): number {
  const millisecondsPerDay = 24 * 60 * 60 * 1000;
  return Math.ceil((targetDate.getTime() - today.getTime()) / millisecondsPerDay);
}

function buildRenewalNotice(s: Subscription, today: Date): string {
  const n = daysUntil(s.d, today);
  const amount = (s.value / 100).toFixed(2);

  return `Email ${s.customerEmail}: your subscription renews in ${n} days at $${amount} per month.`;
}

const notice = buildRenewalNotice(
  {
    customerEmail: "customer@example.com",
    d: new Date("2026-09-01T00:00:00Z"),
    value: 1299
  },
  new Date("2026-08-16T00:00:00Z")
);

console.log(notice);
```

### 2.4 Why this difference matters

The good form names the field by its domain role, `renewalDate`, and the local variable by the meaning of the computed value, `daysUntilRenewal`. A reader can understand the message construction without remembering that `d` means renewal date, `value` means monthly price in cents, or `n` means days until renewal. The behavior is unchanged, but the good names reduce the amount of context a maintainer must reconstruct before making a safe edit.

### 2.5 Structural references

```text
Good: billing-platform > notifications > renewalNotice.ts > buildRenewalNotice > subscription.renewalDate, daysUntilRenewal
Less maintainable: billing-platform > notifications > renewalNotice.ts > buildRenewalNotice > s.d, n
```

The structural difference is only the names at the target locations. The good form gives the field and local variable names that describe their current roles; the less maintainable form uses abbreviated or generic names that require interpretation.

## 3. Boundaries and distinctions

Rename Variable / Rename Field applies when a value or member already has the right behavior but the name no longer communicates its role. It does not apply when the problem is an incorrect calculation, misplaced responsibility, or a data model that needs to be split or reshaped.

Short names can be appropriate in narrow, conventional scopes, such as `i` in a small loop or `x` and `y` in coordinate math. Less descriptive names may also be unavoidable at external boundaries, such as third-party API payloads, database columns, or wire formats, although they can often be translated into clearer internal names.

This refactoring is the corrective action for a Mysterious Name. Mysterious Name describes the readability problem; Rename Variable / Rename Field is the behavior-preserving change that replaces the unclear name with one that matches the current domain meaning.
