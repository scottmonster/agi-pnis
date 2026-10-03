# Consolidate Conditional Expression

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.2.2
- **Aliases:** consolidated conditional
- **Definition:** Combine conditions with the same consequence into one meaningful condition. It eliminates repeated outcomes and makes the shared decision explicit.
- **Why it matters:** It makes the reason for a shared branch easier to see, reduces duplicated outcomes, and gives future changes one place to update when the decision rule changes.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing service calculates a late fee for overdue accounts. The fee is waived when the customer is an employee, the account is still in its grace period, or there is an open billing dispute.

### 2.2 Good form

```ts
type CustomerType = "standard" | "employee";

type Account = {
  customerType: CustomerType;
  daysPastDue: number;
  hasOpenBillingDispute: boolean;
  balanceCents: number;
};

function qualifiesForLateFeeWaiver(account: Account): boolean {
  return (
    account.customerType === "employee" ||
    account.daysPastDue <= 5 ||
    account.hasOpenBillingDispute
  );
}

function calculateLateFeeCents(account: Account): number {
  if (qualifiesForLateFeeWaiver(account)) {
    return 0;
  }

  return Math.round(account.balanceCents * 0.02);
}
```

### 2.3 Less maintainable form

```ts
type CustomerType = "standard" | "employee";

type Account = {
  customerType: CustomerType;
  daysPastDue: number;
  hasOpenBillingDispute: boolean;
  balanceCents: number;
};

function calculateLateFeeCents(account: Account): number {
  if (account.customerType === "employee") {
    return 0;
  }

  if (account.daysPastDue <= 5) {
    return 0;
  }

  if (account.hasOpenBillingDispute) {
    return 0;
  }

  return Math.round(account.balanceCents * 0.02);
}
```

### 2.4 Why this difference matters

The good form makes the shared decision explicit: all three checks answer the same question, "does this account qualify for a late fee waiver?" The repeated `return 0` branches in the less maintainable form force the reader to notice that the outcomes are identical and infer the larger business rule. If the waiver rule changes, the good form provides one named condition to inspect and update.

### 2.5 Structural references

```text
Good: billing-app > billing > lateFees.ts > calculateLateFeeCents > single waiver condition
Less maintainable: billing-app > billing > lateFees.ts > calculateLateFeeCents > repeated zero-fee branches
```

The relevant structural difference is inside the function body: the good form has one named conditional expression for the shared outcome, while the less maintainable form spreads the same outcome across multiple separate branches.

## 3. Boundaries and distinctions

Consolidate Conditional Expression applies when multiple conditions produce the same consequence and can be safely treated as one decision. It does not apply when the branches have different behavior, different side effects, different ordering requirements, or distinct logging and auditing needs.

The less maintainable form may be appropriate when each branch is expected to diverge soon, when each condition needs separate diagnostics, or when the sequence of checks is itself part of the domain logic.

This refactoring is often paired with extracting a function or variable to name the combined condition, but the core concept is the consolidation of equivalent conditional branches. Extracting a function names code; consolidating a conditional removes repeated outcomes by expressing one shared decision.
