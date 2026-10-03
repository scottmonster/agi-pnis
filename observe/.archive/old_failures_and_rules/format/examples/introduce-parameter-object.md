# Introduce Parameter Object

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.2.8
- **Aliases:** None
- **Definition:** Replace a recurring group of parameters with an object representing that group. It names the relationship, shortens calls, and provides a home for related behavior.
- **Why it matters:** It makes related values explicit as one concept, reduces repeated long parameter lists, and localizes validation or behavior that belongs to the group.
- **Related concepts:** Data Clump

## 2. Example

### 2.1 Scenario

A reporting module repeatedly passes the same start and end dates to calculate order totals and format a report title. The dates represent one business concept: the reporting period.

### 2.2 Good form

```ts
type Order = {
  id: string;
  totalCents: number;
  placedAt: Date;
};

type DateRange = {
  start: Date;
  end: Date;
};

function contains(range: DateRange, value: Date): boolean {
  return value >= range.start && value <= range.end;
}

function formatRange(range: DateRange): string {
  return `${range.start.toISOString().slice(0, 10)} to ${range.end
    .toISOString()
    .slice(0, 10)}`;
}

function totalOrdersInRange(orders: Order[], range: DateRange): number {
  return orders
    .filter((order) => contains(range, order.placedAt))
    .reduce((sum, order) => sum + order.totalCents, 0);
}

function buildRevenueSummary(orders: Order[], range: DateRange): string {
  const totalCents = totalOrdersInRange(orders, range);
  return `Revenue for ${formatRange(range)}: $${(totalCents / 100).toFixed(2)}`;
}

const orders: Order[] = [
  { id: "a100", totalCents: 2500, placedAt: new Date("2024-03-02") },
  { id: "a101", totalCents: 4100, placedAt: new Date("2024-03-15") },
  { id: "a102", totalCents: 9900, placedAt: new Date("2024-04-01") },
];

const marchRange: DateRange = {
  start: new Date("2024-03-01"),
  end: new Date("2024-03-31"),
};

console.log(buildRevenueSummary(orders, marchRange));
```

### 2.3 Less maintainable form

```ts
type Order = {
  id: string;
  totalCents: number;
  placedAt: Date;
};

function isDateBetween(value: Date, start: Date, end: Date): boolean {
  return value >= start && value <= end;
}

function formatDateRange(start: Date, end: Date): string {
  return `${start.toISOString().slice(0, 10)} to ${end
    .toISOString()
    .slice(0, 10)}`;
}

function totalOrdersBetween(orders: Order[], start: Date, end: Date): number {
  return orders
    .filter((order) => isDateBetween(order.placedAt, start, end))
    .reduce((sum, order) => sum + order.totalCents, 0);
}

function buildRevenueSummary(orders: Order[], start: Date, end: Date): string {
  const totalCents = totalOrdersBetween(orders, start, end);
  return `Revenue for ${formatDateRange(start, end)}: $${(totalCents / 100).toFixed(2)}`;
}

const orders: Order[] = [
  { id: "a100", totalCents: 2500, placedAt: new Date("2024-03-02") },
  { id: "a101", totalCents: 4100, placedAt: new Date("2024-03-15") },
  { id: "a102", totalCents: 9900, placedAt: new Date("2024-04-01") },
];

const start = new Date("2024-03-01");
const end = new Date("2024-03-31");

console.log(buildRevenueSummary(orders, start, end));
```

### 2.4 Why this difference matters

In the good form, `DateRange` names the relationship between `start` and `end`, so readers see that the two dates are one reporting period rather than independent values. Call sites are shorter and less error-prone because the range travels as a unit. Behavior that depends on the pair, such as containment and formatting, can be written against the parameter object instead of repeatedly accepting the same two arguments.

### 2.5 Structural references

```text
Good: reporting-service > reporting > revenueReport.ts > buildRevenueSummary > DateRange parameter
Less maintainable: reporting-service > reporting > revenueReport.ts > buildRevenueSummary > start and end parameters
```

The relevant structural difference is that the good form has one parameter representing the whole date range, while the less maintainable form repeats two separate parameters wherever that range is needed.

## 3. Boundaries and distinctions

Introduce Parameter Object applies when the same group of parameters recurs together and represents a meaningful concept. It is less useful for a one-off function, for unrelated values that only happen to appear together once, or when adding an object would obscure a simple call more than it clarifies it.

The less maintainable form can be appropriate for very small local functions or stable APIs where the parameter group is not repeated and has no meaningful behavior. Introducing an object too early can create unnecessary types.

This refactoring often addresses a Data Clump, where the same set of values appears together across multiple functions or objects. The distinction is that Data Clump describes the smell, while Introduce Parameter Object is one refactoring that can remove it by giving the clumped data a named structure.
