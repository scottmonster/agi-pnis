# Visitor

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.22
- **Aliases:** None
- **Definition:** Move operations over a stable object structure into visitor objects. It groups operations by concern, but makes adding new element types more costly.
- **Why it matters:** Visitor makes behavior easier to read and maintain when many operations must run across the same stable set of element types, because each operation is collected in one visitor instead of being scattered across every element class.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A helpdesk system has several stable ticket types. The product team needs multiple operations over those tickets, such as creating dashboard summaries and calculating priority scores.

### 2.2 Good form

```ts
interface TicketVisitor<R> {
  visitBugReport(ticket: BugReport): R;
  visitFeatureRequest(ticket: FeatureRequest): R;
  visitBillingQuestion(ticket: BillingQuestion): R;
}

interface Ticket {
  id: string;
  title: string;
  accept<R>(visitor: TicketVisitor<R>): R;
}

class BugReport implements Ticket {
  constructor(
    public readonly id: string,
    public readonly title: string,
    public readonly severity: "low" | "medium" | "high",
  ) {}

  accept<R>(visitor: TicketVisitor<R>): R {
    return visitor.visitBugReport(this);
  }
}

class FeatureRequest implements Ticket {
  constructor(
    public readonly id: string,
    public readonly title: string,
    public readonly votes: number,
  ) {}

  accept<R>(visitor: TicketVisitor<R>): R {
    return visitor.visitFeatureRequest(this);
  }
}

class BillingQuestion implements Ticket {
  constructor(
    public readonly id: string,
    public readonly title: string,
    public readonly accountValue: number,
  ) {}

  accept<R>(visitor: TicketVisitor<R>): R {
    return visitor.visitBillingQuestion(this);
  }
}

class DashboardSummaryVisitor implements TicketVisitor<string> {
  visitBugReport(ticket: BugReport): string {
    return `Bug ${ticket.id}: ${ticket.title} (${ticket.severity})`;
  }

  visitFeatureRequest(ticket: FeatureRequest): string {
    return `Feature ${ticket.id}: ${ticket.title} (${ticket.votes} votes)`;
  }

  visitBillingQuestion(ticket: BillingQuestion): string {
    return `Billing ${ticket.id}: ${ticket.title} ($${ticket.accountValue})`;
  }
}

class PriorityScoreVisitor implements TicketVisitor<number> {
  visitBugReport(ticket: BugReport): number {
    return ticket.severity === "high" ? 100 : ticket.severity === "medium" ? 60 : 30;
  }

  visitFeatureRequest(ticket: FeatureRequest): number {
    return Math.min(90, ticket.votes * 2);
  }

  visitBillingQuestion(ticket: BillingQuestion): number {
    return ticket.accountValue >= 10_000 ? 80 : 40;
  }
}

function renderDashboard(tickets: Ticket[]): Array<{ summary: string; priority: number }> {
  const summaryVisitor = new DashboardSummaryVisitor();
  const priorityVisitor = new PriorityScoreVisitor();

  return tickets.map((ticket) => ({
    summary: ticket.accept(summaryVisitor),
    priority: ticket.accept(priorityVisitor),
  }));
}

const tickets: Ticket[] = [
  new BugReport("BUG-12", "Checkout crashes", "high"),
  new FeatureRequest("FEAT-7", "Add dark mode", 18),
  new BillingQuestion("BILL-3", "Invoice discrepancy", 12_500),
];

console.log(renderDashboard(tickets));
```

### 2.3 Less maintainable form

```ts
interface Ticket {
  id: string;
  title: string;
  toDashboardSummary(): string;
  priorityScore(): number;
}

class BugReport implements Ticket {
  constructor(
    public readonly id: string,
    public readonly title: string,
    public readonly severity: "low" | "medium" | "high",
  ) {}

  toDashboardSummary(): string {
    return `Bug ${this.id}: ${this.title} (${this.severity})`;
  }

  priorityScore(): number {
    return this.severity === "high" ? 100 : this.severity === "medium" ? 60 : 30;
  }
}

class FeatureRequest implements Ticket {
  constructor(
    public readonly id: string,
    public readonly title: string,
    public readonly votes: number,
  ) {}

  toDashboardSummary(): string {
    return `Feature ${this.id}: ${this.title} (${this.votes} votes)`;
  }

  priorityScore(): number {
    return Math.min(90, this.votes * 2);
  }
}

class BillingQuestion implements Ticket {
  constructor(
    public readonly id: string,
    public readonly title: string,
    public readonly accountValue: number,
  ) {}

  toDashboardSummary(): string {
    return `Billing ${this.id}: ${this.title} ($${this.accountValue})`;
  }

  priorityScore(): number {
    return this.accountValue >= 10_000 ? 80 : 40;
  }
}

function renderDashboard(tickets: Ticket[]): Array<{ summary: string; priority: number }> {
  return tickets.map((ticket) => ({
    summary: ticket.toDashboardSummary(),
    priority: ticket.priorityScore(),
  }));
}

const tickets: Ticket[] = [
  new BugReport("BUG-12", "Checkout crashes", "high"),
  new FeatureRequest("FEAT-7", "Add dark mode", 18),
  new BillingQuestion("BILL-3", "Invoice discrepancy", 12_500),
];

console.log(renderDashboard(tickets));
```

### 2.4 Why this difference matters

In the good form, each operation is represented by a visitor. Dashboard formatting lives in `DashboardSummaryVisitor`, and priority scoring lives in `PriorityScoreVisitor`. A reader can understand or change one concern without scanning every ticket type.

In the less maintainable form, every ticket class contains pieces of every operation. Adding a new operation, such as exporting tickets to CSV or producing audit labels, requires modifying each ticket class. Visitor reverses that dependency: adding an operation usually means adding a new visitor, while the ticket classes remain unchanged. The tradeoff is that adding a new ticket type requires updating the visitor interface and every existing visitor.

### 2.5 Structural references

```text
Good: drawing-app > shapes > areaVisitor.ts > AreaVisitor.visitCircle
Less maintainable: drawing-app > shapes > shapes.ts > Circle.area and Rectangle.area
```

The relevant structural difference is where operation logic is grouped. The good form puts each operation in a visitor function set, while the less maintainable form embeds each operation as methods across the element types.

## 3. Boundaries and distinctions

Visitor fits best when the object structure is stable and new operations are more common than new element types. It is a poor fit when element types change frequently, because each new element type forces changes to the visitor contract and all concrete visitors.

The less maintainable form can be appropriate when there are only one or two operations, the behavior is intrinsic to the element, or the domain model should own the behavior directly. In those cases, Visitor may add unnecessary indirection.

Visitor is not just a general callback or iteration technique. Its defining mechanism is double dispatch: each element accepts a visitor and calls the visitor method specific to its concrete type. This lets operations vary by element type while keeping the operation grouped outside the elements.
