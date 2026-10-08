# Decision Table / Table-Driven Logic

## 1. Concept

- **Classification:** control-flow technique
- **Catalog identifier:** 1.2.4
- **Aliases:** None
- **Definition:** Model combinations of conditions and actions as data rather than a branching tree. It makes coverage and differences inspectable when there are many combinations.
- **Why it matters:** Decision tables make complicated condition combinations easier to read, review, test, and change because the varying cases are listed as data instead of hidden inside nested branching logic.
- **Related concepts:** Replace Conditional with Polymorphism

## 2. Example

### 2.1 Scenario

An online store calculates a shipping fee from destination zone, membership status, order total, and whether expedited shipping was requested. The business rules have several combinations that should be easy to inspect and update.

### 2.2 Good form

```ts
type Zone = "domestic" | "international";

type ShippingRequest = {
  zone: Zone;
  isMember: boolean;
  orderTotal: number;
  expedited: boolean;
};

type ShippingRule = {
  name: string;
  when: (request: ShippingRequest) => boolean;
  fee: number;
};

const SHIPPING_RULES: ShippingRule[] = [
  {
    name: "free domestic member standard shipping over 50",
    when: request =>
      request.zone === "domestic" &&
      request.isMember &&
      request.orderTotal >= 50 &&
      !request.expedited,
    fee: 0
  },
  {
    name: "discounted domestic member expedited shipping",
    when: request =>
      request.zone === "domestic" &&
      request.isMember &&
      request.expedited,
    fee: 6
  },
  {
    name: "domestic expedited shipping",
    when: request =>
      request.zone === "domestic" &&
      request.expedited,
    fee: 10
  },
  {
    name: "domestic standard shipping",
    when: request =>
      request.zone === "domestic",
    fee: 5
  },
  {
    name: "international member shipping over 100",
    when: request =>
      request.zone === "international" &&
      request.isMember &&
      request.orderTotal >= 100,
    fee: 15
  },
  {
    name: "international standard shipping",
    when: request =>
      request.zone === "international",
    fee: 25
  }
];

function calculateShippingFee(request: ShippingRequest): number {
  const rule = SHIPPING_RULES.find(candidate => candidate.when(request));

  if (!rule) {
    throw new Error(`No shipping rule matched request: ${JSON.stringify(request)}`);
  }

  return rule.fee;
}

const fee = calculateShippingFee({
  zone: "domestic",
  isMember: true,
  orderTotal: 75,
  expedited: false
});

console.log(fee);
```

### 2.3 Less maintainable form

```ts
type Zone = "domestic" | "international";

type ShippingRequest = {
  zone: Zone;
  isMember: boolean;
  orderTotal: number;
  expedited: boolean;
};

function calculateShippingFee(request: ShippingRequest): number {
  if (request.zone === "domestic") {
    if (request.isMember) {
      if (request.expedited) {
        return 6;
      }

      if (request.orderTotal >= 50) {
        return 0;
      }

      return 5;
    }

    if (request.expedited) {
      return 10;
    }

    return 5;
  }

  if (request.zone === "international") {
    if (request.isMember) {
      if (request.orderTotal >= 100) {
        return 15;
      }

      return 25;
    }

    return 25;
  }

  throw new Error(`No shipping rule matched request: ${JSON.stringify(request)}`);
}

const fee = calculateShippingFee({
  zone: "domestic",
  isMember: true,
  orderTotal: 75,
  expedited: false
});

console.log(fee);
```

### 2.4 Why this difference matters

The good form separates rule selection from rule content. Each condition combination is represented as a row in `SHIPPING_RULES`, so reviewers can scan the available cases, compare fees, and add or reorder rules without editing a nested control-flow tree. The less maintainable form preserves the same behavior, but the combinations are distributed across nested `if` statements, making it harder to see which cases exist, which cases share the same result, and where a new exception should be inserted.

### 2.5 Structural references

```text
Good: checkout-service > shipping > shippingFee.ts > SHIPPING_RULES
Less maintainable: checkout-service > shipping > shippingFee.ts > calculateShippingFee > nested condition branches
```

The structural difference is that the good form places the decision cases in a table-like data structure used by a small lookup function, while the less maintainable form embeds the same cases directly in the function's branching structure.

## 3. Boundaries and distinctions

Decision tables are most useful when behavior depends on multiple conditions whose combinations must be reviewed as a set. They are less useful for a single simple condition, for logic where each branch performs substantially different procedural work, or for rules whose order would be surprising unless documented carefully.

The less maintainable form can be appropriate when there are only one or two obvious branches and no expected growth in rule combinations. It can also be clearer when the conditions are inherently sequential rather than combinatorial.

Decision Table / Table-Driven Logic differs from Replace Conditional with Polymorphism. A decision table keeps combinations of conditions and actions in data, usually selected by lookup or predicate matching. Replace Conditional with Polymorphism distributes behavior across types so that dispatch is based on the runtime object. Use a decision table when the important thing to understand is the matrix of cases. Use polymorphism when stable object variants own different behavior.
