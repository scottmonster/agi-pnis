# Chain of Responsibility

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.13
- **Aliases:** None
- **Definition:** Pass a request through handlers until one handles it. It separates handlers, but ordering and the no-handler case must remain clear.
- **Why it matters:** It makes request handling easier to read and change by keeping each handler focused on one decision, while preserving a clear processing order and explicit fallback behavior.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A support system routes incoming tickets to the first team that can handle them. Tickets that match no specialized handler are routed to a general support queue.

### 2.2 Good form

```ts
type Ticket = {
  id: string;
  subject: string;
  category: "billing" | "security" | "technical" | "general";
  priority: "low" | "normal" | "high";
};

type RoutedTicket = {
  ticketId: string;
  queue: string;
};

interface TicketHandler {
  handle(ticket: Ticket): RoutedTicket | null;
}

class BillingHandler implements TicketHandler {
  handle(ticket: Ticket): RoutedTicket | null {
    if (ticket.category !== "billing") {
      return null;
    }

    return {
      ticketId: ticket.id,
      queue: "billing-support"
    };
  }
}

class SecurityHandler implements TicketHandler {
  handle(ticket: Ticket): RoutedTicket | null {
    if (ticket.category !== "security" && ticket.priority !== "high") {
      return null;
    }

    return {
      ticketId: ticket.id,
      queue: "security-response"
    };
  }
}

class TechnicalHandler implements TicketHandler {
  handle(ticket: Ticket): RoutedTicket | null {
    if (ticket.category !== "technical") {
      return null;
    }

    return {
      ticketId: ticket.id,
      queue: "technical-support"
    };
  }
}

class GeneralSupportHandler implements TicketHandler {
  handle(ticket: Ticket): RoutedTicket {
    return {
      ticketId: ticket.id,
      queue: "general-support"
    };
  }
}

function routeTicket(ticket: Ticket): RoutedTicket {
  const handlers: TicketHandler[] = [
    new SecurityHandler(),
    new BillingHandler(),
    new TechnicalHandler(),
    new GeneralSupportHandler()
  ];

  for (const handler of handlers) {
    const routed = handler.handle(ticket);

    if (routed !== null) {
      return routed;
    }
  }

  throw new Error("Ticket routing chain must include a fallback handler.");
}

const routed = routeTicket({
  id: "T-1042",
  subject: "Suspicious account activity",
  category: "billing",
  priority: "high"
});

console.log(routed);
```

### 2.3 Less maintainable form

```ts
type Ticket = {
  id: string;
  subject: string;
  category: "billing" | "security" | "technical" | "general";
  priority: "low" | "normal" | "high";
};

type RoutedTicket = {
  ticketId: string;
  queue: string;
};

function routeTicket(ticket: Ticket): RoutedTicket {
  if (ticket.category === "security" || ticket.priority === "high") {
    return {
      ticketId: ticket.id,
      queue: "security-response"
    };
  }

  if (ticket.category === "billing") {
    return {
      ticketId: ticket.id,
      queue: "billing-support"
    };
  }

  if (ticket.category === "technical") {
    return {
      ticketId: ticket.id,
      queue: "technical-support"
    };
  }

  return {
    ticketId: ticket.id,
    queue: "general-support"
  };
}

const routed = routeTicket({
  id: "T-1042",
  subject: "Suspicious account activity",
  category: "billing",
  priority: "high"
});

console.log(routed);
```

### 2.4 Why this difference matters

The good form makes the routing chain explicit: each handler decides only whether it can handle the ticket, and `routeTicket` controls the order in which handlers are tried. This is important because order changes behavior: a high-priority billing ticket goes to security because `SecurityHandler` appears before `BillingHandler`.

The less maintainable form preserves the same behavior, but all routing rules are embedded in one conditional ladder. Adding, removing, reordering, or testing one handler requires editing the central function, increasing the chance of breaking another route. The good form localizes each rule while keeping the no-handler case clear through the final fallback handler and defensive error.

### 2.5 Structural references

```text
Good: support-system > routing > routeTicket.ts > routeTicket > handlers.find
Less maintainable: support-system > routing > routeTicket.ts > routeTicket > ticket.kind conditional branches
```

The relevant structural difference is that the good form represents routing as an ordered chain of separate handlers, while the less maintainable form represents the same order as branches inside one function.

## 3. Boundaries and distinctions

Chain of Responsibility fits when multiple possible handlers may process a request and the chosen handler depends on ordered, runtime checks. It is less useful when there is exactly one known target, when every handler must run, or when selection is a simple direct lookup such as `queueByCategory[ticket.category]`.

The less maintainable conditional form can be appropriate when the rule set is tiny, stable, and unlikely to gain independent handlers. In that case, introducing separate handler objects may add unnecessary structure.

Chain of Responsibility is different from a pipeline: in a pipeline, each step usually transforms or processes the request and passes it onward, while in Chain of Responsibility the request stops at the first handler that accepts it. It is also different from a strategy selection table: strategy selection usually chooses one algorithm directly, while Chain of Responsibility lets handlers decide in sequence whether they are responsible.
