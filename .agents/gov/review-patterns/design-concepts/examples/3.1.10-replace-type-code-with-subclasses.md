# Replace Type Code with Subclasses

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.10
- **Aliases:** extract subclass
- **Definition:** Turn a type discriminator into subclasses when variants need distinct state or behavior. It organizes variation around the variant rather than dispersed checks.
- **Why it matters:** It makes variant-specific state and behavior explicit in one place, reducing repeated conditional checks and making new variants easier to add safely.
- **Related concepts:** Repeated Type Conditional

## 2. Example

### 2.1 Scenario

A payroll service calculates monthly pay for employees. Salaried, hourly, and contract employees use different data and different compensation rules.

### 2.2 Good form

```ts
type EmployeeRecord =
  | { kind: "salaried"; id: string; name: string; annualSalary: number }
  | { kind: "hourly"; id: string; name: string; hourlyRate: number; hoursWorked: number }
  | { kind: "contract"; id: string; name: string; contractAmount: number; completionPercent: number };

abstract class Employee {
  constructor(
    readonly id: string,
    readonly name: string,
  ) {}

  abstract monthlyPay(): number;
}

class SalariedEmployee extends Employee {
  constructor(id: string, name: string, private readonly annualSalary: number) {
    super(id, name);
  }

  monthlyPay(): number {
    return this.annualSalary / 12;
  }
}

class HourlyEmployee extends Employee {
  constructor(
    id: string,
    name: string,
    private readonly hourlyRate: number,
    private readonly hoursWorked: number,
  ) {
    super(id, name);
  }

  monthlyPay(): number {
    return this.hourlyRate * this.hoursWorked;
  }
}

class ContractEmployee extends Employee {
  constructor(
    id: string,
    name: string,
    private readonly contractAmount: number,
    private readonly completionPercent: number,
  ) {
    super(id, name);
  }

  monthlyPay(): number {
    return this.contractAmount * this.completionPercent;
  }
}

function createEmployee(record: EmployeeRecord): Employee {
  switch (record.kind) {
    case "salaried":
      return new SalariedEmployee(record.id, record.name, record.annualSalary);
    case "hourly":
      return new HourlyEmployee(record.id, record.name, record.hourlyRate, record.hoursWorked);
    case "contract":
      return new ContractEmployee(
        record.id,
        record.name,
        record.contractAmount,
        record.completionPercent,
      );
  }
}

function totalMonthlyPayroll(records: EmployeeRecord[]): number {
  return records
    .map(createEmployee)
    .reduce((total, employee) => total + employee.monthlyPay(), 0);
}
```

### 2.3 Less maintainable form

```ts
type EmployeeKind = "salaried" | "hourly" | "contract";

type EmployeeRecord = {
  id: string;
  name: string;
  kind: EmployeeKind;
  annualSalary?: number;
  hourlyRate?: number;
  hoursWorked?: number;
  contractAmount?: number;
  completionPercent?: number;
};

function monthlyPay(employee: EmployeeRecord): number {
  switch (employee.kind) {
    case "salaried":
      return required(employee.annualSalary, "annualSalary") / 12;
    case "hourly":
      return required(employee.hourlyRate, "hourlyRate") * required(employee.hoursWorked, "hoursWorked");
    case "contract":
      return (
        required(employee.contractAmount, "contractAmount") *
        required(employee.completionPercent, "completionPercent")
      );
  }
}

function required(value: number | undefined, fieldName: string): number {
  if (value === undefined) {
    throw new Error(`Missing ${fieldName}`);
  }

  return value;
}

function totalMonthlyPayroll(records: EmployeeRecord[]): number {
  return records.reduce((total, employee) => total + monthlyPay(employee), 0);
}
```

### 2.4 Why this difference matters

In the good form, each employee variant owns the data and calculation that only applies to that variant. The payroll total can ask every `Employee` for `monthlyPay()` without knowing which kind it is. Adding a new employee kind means adding a subclass and updating the construction boundary, rather than finding every `switch` on `kind` and keeping optional fields consistent.

In the less maintainable form, the type code controls behavior from outside the variant. The record must carry many optional fields that are invalid for most employees, and every behavior that differs by kind tends to become another conditional over `employee.kind`.

### 2.5 Structural references

```text
Good: Employee.monthlyPay > subclass implementations
Less maintainable: monthlyPay > employee.kind conditional
```

The structural difference is that the good form places variant behavior in subtype implementations, while the less maintainable form centralizes variant selection in a conditional over a type discriminator.

## 3. Boundaries and distinctions

This refactoring applies when the discriminator represents stable variants that need different behavior or variant-specific state. It is less useful when the type code is only passive data, when the variants do not behave differently, or when the discriminator comes from an external protocol and is only being decoded at a boundary.

The less maintainable form can be appropriate for simple data transfer objects, persistence records, logging events, or short-lived code where a type field is not used to drive scattered behavior. A single factory or decoding `switch` can also remain after the refactoring, because it is a boundary that creates the correct subclass rather than a repeated business-rule conditional.

This differs from Repeated Type Conditional: repeated type conditionals are the symptom, while Replace Type Code with Subclasses is one refactoring that removes the symptom by moving variant-specific behavior into subclasses. It also differs from merely renaming a type field or creating constants for type values, which leaves the same conditional structure in place.
