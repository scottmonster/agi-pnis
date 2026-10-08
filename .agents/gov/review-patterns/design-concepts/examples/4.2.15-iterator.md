# Iterator

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.15
- **Aliases:** None
- **Definition:** Traverse an aggregate through a dedicated cursor/interface rather than exposing its representation. It separates traversal from storage.
- **Why it matters:** Iterator keeps traversal logic out of client code, so readers can understand "what is being traversed" without also understanding "how it is stored." It makes storage changes easier because clients depend on a stable traversal interface instead of array indexes, linked nodes, pages, or other internal details.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An audit service prints all security events from an audit trail. The audit trail currently stores events in memory, but the printing code should not depend on that storage detail.

### 2.2 Good form

```ts
type AuditEvent = {
  id: string;
  type: "security" | "billing" | "system";
  message: string;
};

interface EventCursor {
  hasNext(): boolean;
  next(): AuditEvent;
}

class AuditTrail {
  private readonly events: AuditEvent[];

  constructor(events: AuditEvent[]) {
    this.events = events;
  }

  securityEvents(): EventCursor {
    return new FilteredEventCursor(this.events, event => event.type === "security");
  }
}

class FilteredEventCursor implements EventCursor {
  private index = 0;
  private buffered: AuditEvent | undefined;

  constructor(
    private readonly events: AuditEvent[],
    private readonly matches: (event: AuditEvent) => boolean,
  ) {}

  hasNext(): boolean {
    if (this.buffered !== undefined) {
      return true;
    }

    this.buffered = this.readNextMatch();
    return this.buffered !== undefined;
  }

  next(): AuditEvent {
    if (this.buffered !== undefined) {
      const event = this.buffered;
      this.buffered = undefined;
      return event;
    }

    const event = this.readNextMatch();

    if (event === undefined) {
      throw new Error("No more events");
    }

    return event;
  }

  private readNextMatch(): AuditEvent | undefined {
    while (this.index < this.events.length) {
      const event = this.events[this.index];
      this.index += 1;

      if (this.matches(event)) {
        return event;
      }
    }

    return undefined;
  }
}

function printSecurityEvents(auditTrail: AuditTrail): string[] {
  const lines: string[] = [];
  const events = auditTrail.securityEvents();

  while (events.hasNext()) {
    const event = events.next();
    lines.push(`[${event.id}] ${event.message}`);
  }

  return lines;
}

const auditTrail = new AuditTrail([
  { id: "A-100", type: "system", message: "Scheduler started" },
  { id: "A-101", type: "security", message: "Admin login failed" },
  { id: "A-102", type: "billing", message: "Invoice generated" },
  { id: "A-103", type: "security", message: "Password reset requested" },
]);

console.log(printSecurityEvents(auditTrail));
```

### 2.3 Less maintainable form

```ts
type AuditEvent = {
  id: string;
  type: "security" | "billing" | "system";
  message: string;
};

class AuditTrail {
  constructor(public readonly events: AuditEvent[]) {}
}

function printSecurityEvents(auditTrail: AuditTrail): string[] {
  const lines: string[] = [];

  for (let index = 0; index < auditTrail.events.length; index += 1) {
    const event = auditTrail.events[index];

    if (event.type === "security") {
      lines.push(`[${event.id}] ${event.message}`);
    }
  }

  return lines;
}

const auditTrail = new AuditTrail([
  { id: "A-100", type: "system", message: "Scheduler started" },
  { id: "A-101", type: "security", message: "Admin login failed" },
  { id: "A-102", type: "billing", message: "Invoice generated" },
  { id: "A-103", type: "security", message: "Password reset requested" },
]);

console.log(printSecurityEvents(auditTrail));
```

### 2.4 Why this difference matters

In the good form, `printSecurityEvents` only knows that it can advance through security events with `hasNext()` and `next()`. The indexing, filtering, and storage access are contained inside `FilteredEventCursor`. If `AuditTrail` later stores events in pages, a database cursor, a linked structure, or a stream, the traversal contract can remain the same.

In the less maintainable form, `printSecurityEvents` depends directly on `AuditTrail.events` being an array. It owns the index loop and repeats knowledge about filtering. Changing the aggregate representation would force client traversal code to change.

### 2.5 Structural references

```text
Good: audit-service > audit > auditTrail.ts > collectSecurityEvents > EventCursor.next
Less maintainable: audit-service > audit > auditTrail.ts > collectSecurityEvents > AuditTrail.events array traversal
```

The relevant structural difference is that the good form routes traversal through a dedicated cursor target, while the less maintainable form reaches into the aggregate storage target directly.

## 3. Boundaries and distinctions

Iterator is useful when clients need to traverse an aggregate without depending on its internal representation, especially when traversal rules may vary or storage may change.

It may be unnecessary for a small local array used in one place where the representation is already obvious and not part of an abstraction boundary. In TypeScript, built-in iteration with `for...of`, generator functions, or `Iterable<T>` can be a perfectly appropriate iterator form when it provides the needed cursor abstraction.

The less maintainable form can be acceptable for simple internal code where the collection is not an aggregate abstraction and no representation hiding is intended.

Iterator is not primarily about filtering, sorting, or transforming data. Those operations may be combined with an iterator, but the central idea is separating traversal from storage.
