# Complex Conditional

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.3.4
- **Aliases:** None
- **Definition:** A condition combines enough logic that understanding the decision is substantial work. It obscures why a branch applies.
- **Why it matters:** Complex conditionals force readers to parse boolean mechanics before they can understand the business decision. This makes changes risky because a small edit to one clause can alter the meaning of the whole branch.
- **Related concepts:** Decompose Conditional

## 2. Example

### 2.1 Scenario

A subscription service decides whether to offer a retention discount when a customer attempts to cancel. The same decision uses account status, payment history, plan type, and recent discount usage.

### 2.2 Good form

```ts
type Plan = "free" | "basic" | "pro" | "enterprise";

interface CustomerAccount {
  plan: Plan;
  monthsActive: number;
  isInTrial: boolean;
  hasOpenFraudReview: boolean;
  failedPaymentsLast90Days: number;
  usedRetentionDiscountInLastYear: boolean;
}

function shouldOfferRetentionDiscount(account: CustomerAccount): boolean {
  if (!isEligiblePaidCustomer(account)) {
    return false;
  }

  if (hasPaymentOrFraudRisk(account)) {
    return false;
  }

  return hasEnoughTenure(account) && hasNotRecentlyUsedRetentionDiscount(account);
}

function isEligiblePaidCustomer(account: CustomerAccount): boolean {
  return account.plan !== "free" && account.plan !== "enterprise" && !account.isInTrial;
}

function hasPaymentOrFraudRisk(account: CustomerAccount): boolean {
  return account.failedPaymentsLast90Days > 1 || account.hasOpenFraudReview;
}

function hasEnoughTenure(account: CustomerAccount): boolean {
  return account.monthsActive >= 6;
}

function hasNotRecentlyUsedRetentionDiscount(account: CustomerAccount): boolean {
  return !account.usedRetentionDiscountInLastYear;
}
```

### 2.3 Less maintainable form

```ts
type Plan = "free" | "basic" | "pro" | "enterprise";

interface CustomerAccount {
  plan: Plan;
  monthsActive: number;
  isInTrial: boolean;
  hasOpenFraudReview: boolean;
  failedPaymentsLast90Days: number;
  usedRetentionDiscountInLastYear: boolean;
}

function shouldOfferRetentionDiscount(account: CustomerAccount): boolean {
  return (
    account.plan !== "free" &&
    account.plan !== "enterprise" &&
    !account.isInTrial &&
    account.failedPaymentsLast90Days <= 1 &&
    !account.hasOpenFraudReview &&
    account.monthsActive >= 6 &&
    !account.usedRetentionDiscountInLastYear
  );
}
```

### 2.4 Why this difference matters

The good form names the reasons behind the decision: paid customer eligibility, payment or fraud risk, tenure, and recent discount use. A reader can understand the branch by reading domain-level predicates instead of mentally evaluating every boolean operator.

The less maintainable form preserves the same behavior, but the intent is hidden inside one long expression. Adding a new rule or changing an existing one requires careful operator-level reasoning, which increases the chance of breaking the decision.

### 2.5 Structural references

```text
Good: canApproveExpense > isWithinManagerLimit and hasCompliantReceipt
Less maintainable: canApproveExpense > inline combined approval condition
```

The relevant structural difference is that the good form moves parts of the decision into named predicate functions. The less maintainable form keeps every rule in one conditional expression inside the target function.

## 3. Boundaries and distinctions

A condition is not complex merely because it has more than one clause. Short, familiar checks such as `user.isActive && user.emailVerified` may be clear enough inline.

The less maintainable form can be appropriate when the condition is small, local, and unlikely to change, or when extracting names would add noise without clarifying intent.

Complex Conditional differs from Decompose Conditional: Complex Conditional is the smell, while Decompose Conditional is the refactoring that addresses it by replacing difficult boolean logic with named condition, consequence, and alternative steps.
