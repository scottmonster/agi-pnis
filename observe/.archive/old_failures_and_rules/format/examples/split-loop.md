# Split Loop

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.1.7
- **Aliases:** None
- **Definition:** Give each independent purpose in a loop its own traversal. It prevents one loop from carrying unrelated accumulators and conditions.
- **Why it matters:** It makes each traversal express one reason for iterating, so readers can understand, test, and change each calculation without mentally separating unrelated conditions and accumulators.
- **Related concepts:** Replace Loop with Pipeline

## 2. Example

### 2.1 Scenario

A billing report needs to calculate the total value of overdue unpaid invoices and also list unique high-risk customers. These two results are derived from the same invoice list but serve independent purposes.

### 2.2 Good form

```ts
type Invoice = {
  id: string;
  customerId: string;
  amountCents: number;
  dueDate: string;
  paid: boolean;
  riskScore: number;
};

type CollectionsReport = {
  overdueTotalCents: number;
  highRiskCustomerIds: string[];
};

function buildCollectionsReport(invoices: Invoice[], today: Date): CollectionsReport {
  let overdueTotalCents = 0;

  for (const invoice of invoices) {
    const isOverdue = !invoice.paid && new Date(invoice.dueDate) < today;

    if (isOverdue) {
      overdueTotalCents += invoice.amountCents;
    }
  }

  const highRiskCustomerIds: string[] = [];
  const seenCustomerIds = new Set<string>();

  for (const invoice of invoices) {
    const isHighRisk = invoice.riskScore >= 80;

    if (isHighRisk && !seenCustomerIds.has(invoice.customerId)) {
      seenCustomerIds.add(invoice.customerId);
      highRiskCustomerIds.push(invoice.customerId);
    }
  }

  return {
    overdueTotalCents,
    highRiskCustomerIds,
  };
}
```

### 2.3 Less maintainable form

```ts
type Invoice = {
  id: string;
  customerId: string;
  amountCents: number;
  dueDate: string;
  paid: boolean;
  riskScore: number;
};

type CollectionsReport = {
  overdueTotalCents: number;
  highRiskCustomerIds: string[];
};

function buildCollectionsReport(invoices: Invoice[], today: Date): CollectionsReport {
  let overdueTotalCents = 0;
  const highRiskCustomerIds: string[] = [];
  const seenCustomerIds = new Set<string>();

  for (const invoice of invoices) {
    const isOverdue = !invoice.paid && new Date(invoice.dueDate) < today;

    if (isOverdue) {
      overdueTotalCents += invoice.amountCents;
    }

    const isHighRisk = invoice.riskScore >= 80;

    if (isHighRisk && !seenCustomerIds.has(invoice.customerId)) {
      seenCustomerIds.add(invoice.customerId);
      highRiskCustomerIds.push(invoice.customerId);
    }
  }

  return {
    overdueTotalCents,
    highRiskCustomerIds,
  };
}
```

### 2.4 Why this difference matters

The good form gives each purpose its own loop: one traversal answers "how much money is overdue" and the other answers "which customers are high risk". The less maintainable form makes one loop carry two unrelated sets of state, conditions, and business rules. When the overdue calculation changes, readers still have to inspect the high-risk customer logic to ensure they are not disturbing it, and vice versa.

### 2.5 Structural references

```text
Good: billing-reporting > collections > collectionsReport.ts > buildCollectionsReport > overdue-total traversal and high-risk-customer traversal
Less maintainable: billing-reporting > collections > collectionsReport.ts > buildCollectionsReport > combined invoice traversal
```

The structural difference is that the good form has separate loop targets inside the same function, each dedicated to one independent result. The less maintainable form has a single loop target that mixes both results.

## 3. Boundaries and distinctions

Split Loop applies when one traversal is doing multiple independent jobs over the same collection. It does not apply when the operations must be coordinated step by step, when one result depends on state produced earlier in the same iteration, or when preserving a single pass is necessary for measured performance reasons on very large or streaming data.

The less maintainable form can be appropriate when the loop body is tiny, the purposes are tightly coupled, or profiling shows that an extra traversal is a real bottleneck. It should not be kept merely because a single pass looks more efficient before performance has been measured.

Split Loop differs from Replace Loop with Pipeline. Split Loop separates independent loop purposes and may still use ordinary `for` loops. Replace Loop with Pipeline changes the expression of iteration into operations such as `filter`, `map`, and `reduce`. The two can be combined: first split unrelated traversals, then replace one or more loops with pipelines if that improves clarity.
