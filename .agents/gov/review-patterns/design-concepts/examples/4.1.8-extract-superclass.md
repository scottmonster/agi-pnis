# Extract Superclass

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 4.1.8
- **Aliases:** None
- **Definition:** Pull shared fields and behavior into an explicit supertype. It states a common contract and centralizes genuine commonality.
- **Why it matters:** It makes repeated structure and behavior visible as one concept, so readers can understand the shared contract once and maintain shared changes in one place.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A payroll system has salaried and hourly employees. Both employee types need the same identity fields and formatting behavior, while keeping their own pay calculation rules.

### 2.2 Good form

```ts
abstract class Employee {
  constructor(
    protected readonly name: string,
    protected readonly email: string,
    protected readonly taxId: string
  ) {}

  abstract monthlyPay(): number;

  mailingLabel(): string {
    return `${this.name} <${this.email}>`;
  }

  taxFormHeader(): string {
    return `Employee: ${this.name}\nTax ID: ${this.taxId}`;
  }
}

class SalariedEmployee extends Employee {
  constructor(
    name: string,
    email: string,
    taxId: string,
    private readonly annualSalary: number
  ) {
    super(name, email, taxId);
  }

  monthlyPay(): number {
    return this.annualSalary / 12;
  }
}

class HourlyEmployee extends Employee {
  constructor(
    name: string,
    email: string,
    taxId: string,
    private readonly hourlyRate: number,
    private readonly hoursWorkedThisMonth: number
  ) {
    super(name, email, taxId);
  }

  monthlyPay(): number {
    return this.hourlyRate * this.hoursWorkedThisMonth;
  }
}

function printPayrollSummary(employee: Employee): string {
  return [
    employee.mailingLabel(),
    employee.taxFormHeader(),
    `Monthly pay: $${employee.monthlyPay().toFixed(2)}`
  ].join("\n");
}

const employee = new SalariedEmployee(
  "Mina Patel",
  "mina@example.com",
  "TX-1042",
  120000
);

console.log(printPayrollSummary(employee));
```

### 2.3 Less maintainable form

```ts
class SalariedEmployee {
  constructor(
    private readonly name: string,
    private readonly email: string,
    private readonly taxId: string,
    private readonly annualSalary: number
  ) {}

  monthlyPay(): number {
    return this.annualSalary / 12;
  }

  mailingLabel(): string {
    return `${this.name} <${this.email}>`;
  }

  taxFormHeader(): string {
    return `Employee: ${this.name}\nTax ID: ${this.taxId}`;
  }
}

class HourlyEmployee {
  constructor(
    private readonly name: string,
    private readonly email: string,
    private readonly taxId: string,
    private readonly hourlyRate: number,
    private readonly hoursWorkedThisMonth: number
  ) {}

  monthlyPay(): number {
    return this.hourlyRate * this.hoursWorkedThisMonth;
  }

  mailingLabel(): string {
    return `${this.name} <${this.email}>`;
  }

  taxFormHeader(): string {
    return `Employee: ${this.name}\nTax ID: ${this.taxId}`;
  }
}

type PayrollEmployee = SalariedEmployee | HourlyEmployee;

function printPayrollSummary(employee: PayrollEmployee): string {
  return [
    employee.mailingLabel(),
    employee.taxFormHeader(),
    `Monthly pay: $${employee.monthlyPay().toFixed(2)}`
  ].join("\n");
}

const employee = new SalariedEmployee(
  "Mina Patel",
  "mina@example.com",
  "TX-1042",
  120000
);

console.log(printPayrollSummary(employee));
```

### 2.4 Why this difference matters

The good form gives the shared employee identity and document formatting behavior one explicit home: `Employee`. Readers can see that all employee variants share `name`, `email`, `taxId`, `mailingLabel`, and `taxFormHeader`, while each subtype supplies its own `monthlyPay` calculation. A change to the shared tax header format is made once in the superclass instead of being repeated across every employee type.

### 2.5 Structural references

```text
Good: Employee > id, name, and annualPay
Less maintainable: FullTimeEmployee and Contractor > duplicate id, name, annualPay members
```

The relevant structural difference is that the good form introduces one supertype as the shared target for common state and behavior. The less maintainable form leaves the same commonality scattered across sibling concrete types.

## 3. Boundaries and distinctions

Extract Superclass applies when multiple types already share genuine fields, behavior, and a meaningful common contract. It should not be used only to remove a few coincidental lines of duplication if the types do not represent the same general kind of thing. In that case, duplication may be clearer than forcing an artificial inheritance relationship.

The less maintainable form can be appropriate when the types are expected to diverge soon, when the shared behavior is temporary, or when composition would express the relationship better than inheritance.

Extract Superclass differs from extracting an interface because it centralizes implementation, not just a method shape. An interface can say that objects have `monthlyPay`, but it cannot hold the shared `mailingLabel` and `taxFormHeader` implementation. It also differs from simply pulling up one method or field because Extract Superclass creates an explicit supertype that names and organizes the broader common concept.
