# Decompose Conditional

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.2.1
- **Aliases:** decomposed conditional
- **Definition:** Extract a complicated test, then branch, and else branch into well-named functions. Names reveal the decision's business meaning.
- **Why it matters:** It turns a dense conditional into a readable business decision, making the code easier to understand, verify, and change without reinterpreting the whole condition each time.
- **Related concepts:** Extract Function

## 2. Example

### 2.1 Scenario

A subscription billing service calculates the monthly invoice total for a customer. Customers receive a holiday discount only when several business rules are satisfied.

### 2.2 Good form

```ts
type Customer = {
  id: string;
  isActive: boolean;
  yearsSubscribed: number;
  hasOverdueInvoice: boolean;
};

type BillingPeriod = {
  month: number;
  year: number;
};

function calculateInvoiceTotal(
  customer: Customer,
  baseMonthlyPrice: number,
  billingPeriod: BillingPeriod
): number {
  if (isEligibleForHolidayDiscount(customer, billingPeriod)) {
    return totalWithHolidayDiscount(baseMonthlyPrice);
  }

  return totalWithoutHolidayDiscount(baseMonthlyPrice);
}

function isEligibleForHolidayDiscount(
  customer: Customer,
  billingPeriod: BillingPeriod
): boolean {
  return (
    customer.isActive &&
    customer.yearsSubscribed >= 2 &&
    !customer.hasOverdueInvoice &&
    isHolidayBillingPeriod(billingPeriod)
  );
}

function isHolidayBillingPeriod(billingPeriod: BillingPeriod): boolean {
  return billingPeriod.month === 12;
}

function totalWithHolidayDiscount(baseMonthlyPrice: number): number {
  const holidayDiscountRate = 0.15;
  return baseMonthlyPrice * (1 - holidayDiscountRate);
}

function totalWithoutHolidayDiscount(baseMonthlyPrice: number): number {
  return baseMonthlyPrice;
}
```

### 2.3 Less maintainable form

```ts
type Customer = {
  id: string;
  isActive: boolean;
  yearsSubscribed: number;
  hasOverdueInvoice: boolean;
};

type BillingPeriod = {
  month: number;
  year: number;
};

function calculateInvoiceTotal(
  customer: Customer,
  baseMonthlyPrice: number,
  billingPeriod: BillingPeriod
): number {
  if (
    customer.isActive &&
    customer.yearsSubscribed >= 2 &&
    !customer.hasOverdueInvoice &&
    billingPeriod.month === 12
  ) {
    const holidayDiscountRate = 0.15;
    return baseMonthlyPrice * (1 - holidayDiscountRate);
  } else {
    return baseMonthlyPrice;
  }
}
```

### 2.4 Why this difference matters

The good form names the decision as `isEligibleForHolidayDiscount`, so the reader first sees the business rule being applied instead of parsing boolean mechanics. It also names the consequences as `totalWithHolidayDiscount` and `totalWithoutHolidayDiscount`, separating the meaning of each branch from the details of the calculation.

When discount eligibility changes, the condition can be updated in one focused function. When the discount calculation changes, the branch behavior can be updated separately. The less maintainable form mixes the test, the discounted branch, and the normal branch in one block, so each change requires re-reading the whole conditional.

### 2.5 Structural references

```text
Good: billing-service > pricing > invoice.ts > calculateInvoiceTotal > named condition and named branches
Less maintainable: billing-service > pricing > invoice.ts > calculateInvoiceTotal > inline condition and inline branches
```

The structural difference is that the good form moves the conditional test and branch bodies into separate functions with business names. The less maintainable form keeps all decision details inside the caller's conditional block.

## 3. Boundaries and distinctions

Decompose Conditional applies when a conditional is hard to read because the test, then branch, or else branch contains meaningful logic that deserves a name. It is most useful when the names can express domain intent, such as eligibility, approval, risk, pricing, or routing decisions.

It may not be necessary for very small conditionals where the condition and branches are already obvious, such as `if (isEnabled) return;`. The less maintainable form can be acceptable for short, local checks that are unlikely to change and do not hide business meaning.

Decompose Conditional is closely related to Extract Function, but it is more specific. Extract Function can be used for any coherent block of code. Decompose Conditional uses extraction in a targeted way: extract the condition, the then branch, and often the else branch so the conditional reads like a business decision rather than an implementation puzzle.
