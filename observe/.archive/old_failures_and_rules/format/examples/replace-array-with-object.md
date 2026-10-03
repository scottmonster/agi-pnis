# Replace Array with Object

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.5
- **Aliases:** None
- **Definition:** Replace positional array elements with named fields. It removes index-based interpretation and makes the data's shape explicit.
- **Why it matters:** Named fields make code easier to read and change because each value carries its meaning at the point of use, instead of requiring readers to remember which array index represents which concept.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A billing service receives imported subscription data and calculates the monthly charge for one customer. Each imported record contains a customer id, plan code, active user count, and discount percentage.

### 2.2 Good form

```ts
type SubscriptionImport = {
  customerId: string;
  planCode: "starter" | "business" | "enterprise";
  activeUsers: number;
  discountPercent: number;
};

const monthlyPlanPrices: Record<SubscriptionImport["planCode"], number> = {
  starter: 20,
  business: 80,
  enterprise: 250,
};

function calculateMonthlyCharge(subscription: SubscriptionImport): number {
  const basePrice = monthlyPlanPrices[subscription.planCode];
  const userCharge = subscription.activeUsers * 12;
  const discount = (basePrice + userCharge) * (subscription.discountPercent / 100);

  return basePrice + userCharge - discount;
}

const importedSubscription: SubscriptionImport = {
  customerId: "cust-1042",
  planCode: "business",
  activeUsers: 14,
  discountPercent: 10,
};

console.log(calculateMonthlyCharge(importedSubscription));
```

### 2.3 Less maintainable form

```ts
type SubscriptionImportRow = [string, "starter" | "business" | "enterprise", number, number];

const monthlyPlanPrices: Record<SubscriptionImportRow[1], number> = {
  starter: 20,
  business: 80,
  enterprise: 250,
};

function calculateMonthlyCharge(subscriptionRow: SubscriptionImportRow): number {
  const basePrice = monthlyPlanPrices[subscriptionRow[1]];
  const userCharge = subscriptionRow[2] * 12;
  const discount = (basePrice + userCharge) * (subscriptionRow[3] / 100);

  return basePrice + userCharge - discount;
}

const importedSubscriptionRow: SubscriptionImportRow = ["cust-1042", "business", 14, 10];

console.log(calculateMonthlyCharge(importedSubscriptionRow));
```

### 2.4 Why this difference matters

The good form gives each element of the imported subscription a stable name: `planCode`, `activeUsers`, and `discountPercent`. A reader can understand the calculation without decoding numeric indexes. If the import shape changes, references to affected fields are searchable and type-checked by name. In the less maintainable form, the meaning of `subscriptionRow[1]`, `subscriptionRow[2]`, and `subscriptionRow[3]` depends on an external ordering convention, so reordering or inserting a value can silently change behavior if every index is not updated correctly.

### 2.5 Structural references

```text
Good: billing-importer > subscription-billing > charge.ts > calculateMonthlyCharge > subscription
Less maintainable: billing-importer > subscription-billing > charge.ts > calculateMonthlyCharge > subscriptionRow
```

The structural difference is that the function target is an object with named fields in the good form, while the less maintainable form uses an array target whose positions must be interpreted by index.

## 3. Boundaries and distinctions

Replace Array with Object applies when array positions represent different named facts about one thing, such as customer id, plan code, active user count, and discount percentage. It does not apply to homogeneous collections where every element has the same role, such as a list of subscription ids or a list of monthly charges.

The array form can be appropriate when working at a boundary that inherently supplies positional data, such as raw CSV rows, database tuples, or compact wire formats. Even then, it is often useful to convert the positional data into an object soon after parsing so the rest of the code uses named fields.

This refactoring is different from merely renaming variables. The data structure changes from positional access to property access. It is also different from replacing a primitive value with an object, because the original structure already groups multiple values, but hides their meanings behind indexes.
