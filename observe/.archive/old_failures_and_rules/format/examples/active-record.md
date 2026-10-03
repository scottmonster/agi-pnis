# Active Record

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 3.2.5
- **Aliases:** None
- **Definition:** Let an object wrap a database row and carry persistence operations. It makes simple data access direct, while coupling model and storage concerns.
- **Why it matters:** Active Record can make simple CRUD-oriented code easier to read because the data, row-shaped behavior, and persistence operations are found on the same object. This improves local understandability for straightforward models, but can reduce maintainability when persistence concerns grow complex.
- **Related concepts:** Data Mapper

## 2. Example

### 2.1 Scenario

An admin tool deactivates user accounts that have been inactive for more than a year. The application stores users in a `users` table and must update the same row when the account is deactivated.

### 2.2 Good form

```ts
type UserRow = {
  id: string;
  email: string;
  active: boolean;
  lastLoginAt: Date;
};

class InMemoryDatabase {
  private users = new Map<string, UserRow>();

  constructor(seedUsers: UserRow[]) {
    for (const user of seedUsers) {
      this.users.set(user.id, { ...user });
    }
  }

  async findUserById(id: string): Promise<UserRow | undefined> {
    const row = this.users.get(id);
    return row ? { ...row } : undefined;
  }

  async updateUser(row: UserRow): Promise<void> {
    if (!this.users.has(row.id)) {
      throw new Error(`User ${row.id} does not exist`);
    }

    this.users.set(row.id, { ...row });
  }
}

class UserRecord {
  private constructor(
    private readonly database: InMemoryDatabase,
    private row: UserRow,
  ) {}

  static async find(
    database: InMemoryDatabase,
    id: string,
  ): Promise<UserRecord | undefined> {
    const row = await database.findUserById(id);
    return row ? new UserRecord(database, row) : undefined;
  }

  get id(): string {
    return this.row.id;
  }

  get email(): string {
    return this.row.email;
  }

  get active(): boolean {
    return this.row.active;
  }

  isDormant(referenceDate: Date): boolean {
    const oneYearInMilliseconds = 365 * 24 * 60 * 60 * 1000;
    return (
      referenceDate.getTime() - this.row.lastLoginAt.getTime() >
      oneYearInMilliseconds
    );
  }

  async deactivate(): Promise<void> {
    this.row = { ...this.row, active: false };
    await this.save();
  }

  async save(): Promise<void> {
    await this.database.updateUser(this.row);
  }
}

async function deactivateDormantUser(
  database: InMemoryDatabase,
  userId: string,
  referenceDate: Date,
): Promise<boolean> {
  const user = await UserRecord.find(database, userId);

  if (!user || !user.active || !user.isDormant(referenceDate)) {
    return false;
  }

  await user.deactivate();
  return true;
}

async function example(): Promise<void> {
  const database = new InMemoryDatabase([
    {
      id: "user-1",
      email: "alex@example.com",
      active: true,
      lastLoginAt: new Date("2022-01-01"),
    },
  ]);

  await deactivateDormantUser(database, "user-1", new Date("2024-03-01"));
}
```

### 2.3 Less maintainable form

```ts
type UserRow = {
  id: string;
  email: string;
  active: boolean;
  lastLoginAt: Date;
};

class InMemoryDatabase {
  private users = new Map<string, UserRow>();

  constructor(seedUsers: UserRow[]) {
    for (const user of seedUsers) {
      this.users.set(user.id, { ...user });
    }
  }

  async findUserById(id: string): Promise<UserRow | undefined> {
    const row = this.users.get(id);
    return row ? { ...row } : undefined;
  }

  async updateUser(row: UserRow): Promise<void> {
    if (!this.users.has(row.id)) {
      throw new Error(`User ${row.id} does not exist`);
    }

    this.users.set(row.id, { ...row });
  }
}

function userIsDormant(row: UserRow, referenceDate: Date): boolean {
  const oneYearInMilliseconds = 365 * 24 * 60 * 60 * 1000;
  return (
    referenceDate.getTime() - row.lastLoginAt.getTime() >
    oneYearInMilliseconds
  );
}

async function deactivateDormantUser(
  database: InMemoryDatabase,
  userId: string,
  referenceDate: Date,
): Promise<boolean> {
  const row = await database.findUserById(userId);

  if (!row || !row.active || !userIsDormant(row, referenceDate)) {
    return false;
  }

  await database.updateUser({
    id: row.id,
    email: row.email,
    active: false,
    lastLoginAt: row.lastLoginAt,
  });

  return true;
}

async function example(): Promise<void> {
  const database = new InMemoryDatabase([
    {
      id: "user-1",
      email: "alex@example.com",
      active: true,
      lastLoginAt: new Date("2022-01-01"),
    },
  ]);

  await deactivateDormantUser(database, "user-1", new Date("2024-03-01"));
}
```

### 2.4 Why this difference matters

In the good form, `UserRecord` is an Active Record: it represents one `users` row and owns persistence operations such as `find`, `save`, and `deactivate`. A reader can understand how a user row is loaded, inspected, changed, and stored by reading the record type itself.

In the less maintainable form, the row is a passive data structure. The calling function must know how to check user state, rebuild the row, and call the database update operation directly. As more user operations are added, persistence details are likely to spread across many functions instead of staying attached to the row-shaped object.

### 2.5 Structural references

```text
Good: admin-tool > users > user-record.ts > UserRecord.deactivate > users row
Less maintainable: admin-tool > users > deactivate-dormant-user.ts > deactivateDormantUser > users row
```

The relevant structural difference is where persistence behavior lives. In the good form, the target database row is wrapped by a record object that exposes row-specific operations. In the less maintainable form, the function that performs the use case manipulates and persists the row directly.

## 3. Boundaries and distinctions

Active Record fits best when the model is close to the database schema and operations are mostly simple create, read, update, and delete behavior. It is less suitable when domain logic is complex, when objects combine data from many tables, or when persistence must be isolated from domain behavior for testing, portability, or architectural boundaries.

The less maintainable form can be appropriate for very small scripts, one-off migrations, or simple administrative tasks where introducing a record type would add more structure than the code needs.

Active Record differs from Data Mapper. In Active Record, the object that represents the row also knows how to load and save itself. In Data Mapper, domain objects usually avoid persistence methods, and a separate mapper or repository moves data between objects and the database. Data Mapper reduces coupling between model and storage, while Active Record favors directness by accepting that coupling.
