# Data Mapper

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 3.2.4
- **Aliases:** None
- **Definition:** Keep mapping between domain objects and storage representations in a separate layer. It can keep persistence details out of domain code, at the cost of another abstraction.
- **Why it matters:** Data Mapper keeps domain code focused on business meaning instead of table names, column names, query shapes, or serialization rules, which makes the model easier to read and safer to change when storage changes.
- **Related concepts:** Active Record

## 2. Example

### 2.1 Scenario

A customer profile is stored in a database row where `marketing_opt_in` is represented as `0` or `1`. The application needs to load a customer, change the email address, and save the customer back.

### 2.2 Good form

```ts
type CustomerStatus = "active" | "disabled";

type CustomerRow = {
  id: string;
  email: string;
  status: CustomerStatus;
  marketing_opt_in: 0 | 1;
};

interface CustomerTable {
  findById(id: string): Promise<CustomerRow | undefined>;
  upsert(row: CustomerRow): Promise<void>;
}

class Customer {
  constructor(
    public readonly id: string,
    private email: string,
    public readonly status: CustomerStatus,
    private marketingOptIn: boolean,
  ) {}

  changeEmail(nextEmail: string): void {
    if (!nextEmail.includes("@")) {
      throw new Error("Email address is invalid");
    }

    this.email = nextEmail;
  }

  currentEmail(): string {
    return this.email;
  }

  wantsMarketingEmail(): boolean {
    return this.marketingOptIn;
  }
}

class CustomerMapper {
  static toDomain(row: CustomerRow): Customer {
    return new Customer(
      row.id,
      row.email,
      row.status,
      row.marketing_opt_in === 1,
    );
  }

  static toRow(customer: Customer): CustomerRow {
    return {
      id: customer.id,
      email: customer.currentEmail(),
      status: customer.status,
      marketing_opt_in: customer.wantsMarketingEmail() ? 1 : 0,
    };
  }
}

class CustomerRepository {
  constructor(private readonly table: CustomerTable) {}

  async findById(id: string): Promise<Customer | undefined> {
    const row = await this.table.findById(id);
    return row ? CustomerMapper.toDomain(row) : undefined;
  }

  async save(customer: Customer): Promise<void> {
    await this.table.upsert(CustomerMapper.toRow(customer));
  }
}

async function changeCustomerEmail(
  repository: CustomerRepository,
  customerId: string,
  nextEmail: string,
): Promise<void> {
  const customer = await repository.findById(customerId);

  if (!customer) {
    throw new Error("Customer not found");
  }

  customer.changeEmail(nextEmail);
  await repository.save(customer);
}
```

### 2.3 Less maintainable form

```ts
type CustomerStatus = "active" | "disabled";

type CustomerRow = {
  id: string;
  email: string;
  status: CustomerStatus;
  marketing_opt_in: 0 | 1;
};

interface CustomerTable {
  findById(id: string): Promise<CustomerRow | undefined>;
  upsert(row: CustomerRow): Promise<void>;
}

class Customer {
  constructor(
    public readonly id: string,
    private email: string,
    public readonly status: CustomerStatus,
    private marketingOptIn: boolean,
  ) {}

  static fromRow(row: CustomerRow): Customer {
    return new Customer(
      row.id,
      row.email,
      row.status,
      row.marketing_opt_in === 1,
    );
  }

  toRow(): CustomerRow {
    return {
      id: this.id,
      email: this.email,
      status: this.status,
      marketing_opt_in: this.marketingOptIn ? 1 : 0,
    };
  }

  changeEmail(nextEmail: string): void {
    if (!nextEmail.includes("@")) {
      throw new Error("Email address is invalid");
    }

    this.email = nextEmail;
  }

  async save(table: CustomerTable): Promise<void> {
    await table.upsert(this.toRow());
  }
}

async function changeCustomerEmail(
  table: CustomerTable,
  customerId: string,
  nextEmail: string,
): Promise<void> {
  const row = await table.findById(customerId);

  if (!row) {
    throw new Error("Customer not found");
  }

  const customer = Customer.fromRow(row);
  customer.changeEmail(nextEmail);
  await customer.save(table);
}
```

### 2.4 Why this difference matters

In the good form, the `Customer` object describes customer behavior and state in domain terms, while `CustomerMapper` owns the translation between `Customer` and `CustomerRow`. If the database column changes from `marketing_opt_in` to `accepts_marketing`, or the stored value changes from `0 | 1` to `"yes" | "no"`, the change is localized to the mapper.

In the less maintainable form, the domain object knows about row shape, column names, and storage encoding. Reading `Customer` now requires understanding both business rules and persistence details. Changing storage representation risks editing and retesting domain behavior that should not have changed.

### 2.5 Structural references

```text
Good: customer-service > persistence > customerMapper.ts > CustomerMapper.toDomain > row-to-domain mapping
Less maintainable: customer-service > domain > customer.ts > Customer.fromRow > embedded row mapping
```

The relevant structural difference is where the mapping responsibility lives. In the good form, mapping is in a separate mapper function outside the domain object. In the less maintainable form, mapping is embedded in the domain object itself.

## 3. Boundaries and distinctions

Data Mapper is most useful when domain objects have behavior, persistence details are nontrivial, or storage and domain models change for different reasons. It may be unnecessary for simple CRUD screens, small scripts, or data objects that intentionally mirror one table or API response.

The less maintainable form can be appropriate when using Active Record deliberately, especially in applications where each domain object closely matches one database table and the convenience of `record.save()` is worth coupling the object to persistence.

Data Mapper differs from Active Record in responsibility placement. With Data Mapper, persistence mapping is external to the domain object. With Active Record, the object usually carries both domain data and persistence operations such as loading, saving, and translating to storage format.
