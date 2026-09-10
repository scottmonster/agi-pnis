# Hide Delegate

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.6
- **Aliases:** None
- **Definition:** Give a client a method on the server rather than making it navigate to a delegate. It reduces client knowledge of internal object structure.
- **Why it matters:** It keeps client code focused on the action it needs, rather than on the server object's internal collaborators. This improves readability and makes internal relationship changes easier because fewer callers depend on the same object path.
- **Related concepts:** Message Chain, Law of Demeter

## 2. Example

### 2.1 Scenario

A support ticket escalation must notify the manager of the assigned employee's department. The client should not need to know how a ticket reaches that manager.

### 2.2 Good form

```ts
type EmailAddress = string;

class Manager {
  constructor(public readonly email: EmailAddress) {}
}

class Department {
  constructor(private readonly manager: Manager) {}

  managerEmail(): EmailAddress {
    return this.manager.email;
  }
}

class Employee {
  constructor(private readonly department: Department) {}

  departmentManagerEmail(): EmailAddress {
    return this.department.managerEmail();
  }
}

class Ticket {
  constructor(
    public readonly id: string,
    private readonly assignee: Employee
  ) {}

  assignedDepartmentManagerEmail(): EmailAddress {
    return this.assignee.departmentManagerEmail();
  }
}

class EmailService {
  send(to: EmailAddress, subject: string): void {
    console.log(`Sending "${subject}" to ${to}`);
  }
}

function sendEscalationNotice(ticket: Ticket, emailService: EmailService): void {
  emailService.send(
    ticket.assignedDepartmentManagerEmail(),
    `Escalation for ticket ${ticket.id}`
  );
}

const manager = new Manager("manager@example.com");
const department = new Department(manager);
const assignee = new Employee(department);
const ticket = new Ticket("T-1042", assignee);

sendEscalationNotice(ticket, new EmailService());
```

### 2.3 Less maintainable form

```ts
type EmailAddress = string;

class Manager {
  constructor(public readonly email: EmailAddress) {}
}

class Department {
  constructor(public readonly manager: Manager) {}
}

class Employee {
  constructor(public readonly department: Department) {}
}

class Ticket {
  constructor(
    public readonly id: string,
    public readonly assignee: Employee
  ) {}
}

class EmailService {
  send(to: EmailAddress, subject: string): void {
    console.log(`Sending "${subject}" to ${to}`);
  }
}

function sendEscalationNotice(ticket: Ticket, emailService: EmailService): void {
  emailService.send(
    ticket.assignee.department.manager.email,
    `Escalation for ticket ${ticket.id}`
  );
}

const manager = new Manager("manager@example.com");
const department = new Department(manager);
const assignee = new Employee(department);
const ticket = new Ticket("T-1042", assignee);

sendEscalationNotice(ticket, new EmailService());
```

### 2.4 Why this difference matters

In the good form, the client asks the `Ticket` for the information it needs: `assignedDepartmentManagerEmail()`. The path from ticket to assignee to department to manager is hidden behind methods owned by the objects that know that structure.

In the less maintainable form, `sendEscalationNotice` depends directly on `ticket.assignee.department.manager.email`. If the ticket later assigns work to a team, if departments change how managers are represented, or if manager contact details move to a profile object, every client that navigates the chain may need to change. Hide Delegate localizes that knowledge.

### 2.5 Structural references

```text
Good: support-portal > tickets > ticket.ts > sendEscalationNotice > Ticket.assignedDepartmentManagerEmail
Less maintainable: support-portal > tickets > ticket.ts > sendEscalationNotice > ticket.assignee.department.manager.email
```

The relevant structural difference is where the client points. In the good form, the client targets a method on `Ticket`, the server object it already has. In the less maintainable form, the client targets a nested delegate path and therefore depends on internal object structure.

## 3. Boundaries and distinctions

Hide Delegate applies when a client repeatedly navigates through one object to reach another object that should be treated as an implementation detail of the first object. It is most useful when the server object can offer a meaningful operation or query that matches the client's intent.

It does not apply when the delegate is already a deliberate part of the public model. For example, if callers are meant to work directly with an `Employee` or `Department`, exposing that object can be appropriate. Hiding every collaborator can also create bloated wrapper objects with many shallow forwarding methods. If clients genuinely need broad access to the delegate's behavior, exposing the delegate may be clearer.

The less maintainable form can be acceptable for simple data transfer objects, test setup, serialization boundaries, or code where the nested shape is the stable public contract. In those cases, the object structure is not an accidental implementation detail.

Hide Delegate is closely related to Message Chain. A message chain is the visible navigation through several objects, such as `ticket.assignee.department.manager.email`. Hide Delegate is one refactoring that removes that chain from the client. It also supports the Law of Demeter, which advises objects to talk only to close collaborators, but Hide Delegate is a concrete refactoring technique rather than the broader design principle.
