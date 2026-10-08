# Replace Function with Command

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.2.9
- **Aliases:** replace method with method object
- **Definition:** Turn an operation into an object that holds its parameters and intermediate state. It can clarify a complex operation or support composition, but adds indirection.
- **Why it matters:** Moving a complex operation into a command object gives intermediate state clear names and focused helper methods, making the calculation easier to read, test, and change without threading many temporary values through one large function.
- **Related concepts:** Command

## 2. Example

### 2.1 Scenario

A checkout service calculates an order quote from line items, a customer loyalty discount, tax, and shipping. The intended behavior is the same in both examples.

### 2.2 Good form

```ts
type LineItem = {
  sku: string;
  unitPriceCents: number;
  quantity: number;
};

type Customer = {
  id: string;
  loyaltyTier: "standard" | "gold";
};

type Quote = {
  subtotalCents: number;
  discountCents: number;
  taxCents: number;
  shippingCents: number;
  totalCents: number;
};

class BuildOrderQuoteCommand {
  private subtotalCents = 0;
  private discountCents = 0;
  private taxableCents = 0;
  private taxCents = 0;
  private shippingCents = 0;

  constructor(
    private readonly items: LineItem[],
    private readonly customer: Customer,
    private readonly destinationState: string
  ) {}

  execute(): Quote {
    this.calculateSubtotal();
    this.applyLoyaltyDiscount();
    this.calculateTax();
    this.calculateShipping();

    return {
      subtotalCents: this.subtotalCents,
      discountCents: this.discountCents,
      taxCents: this.taxCents,
      shippingCents: this.shippingCents,
      totalCents: this.taxableCents + this.taxCents + this.shippingCents
    };
  }

  private calculateSubtotal(): void {
    this.subtotalCents = this.items.reduce(
      (sum, item) => sum + item.unitPriceCents * item.quantity,
      0
    );
  }

  private applyLoyaltyDiscount(): void {
    this.discountCents =
      this.customer.loyaltyTier === "gold"
        ? Math.round(this.subtotalCents * 0.1)
        : 0;

    this.taxableCents = this.subtotalCents - this.discountCents;
  }

  private calculateTax(): void {
    const taxRate = this.destinationState === "CA" ? 0.0825 : 0.06;
    this.taxCents = Math.round(this.taxableCents * taxRate);
  }

  private calculateShipping(): void {
    this.shippingCents = this.taxableCents >= 5000 ? 0 : 799;
  }
}

function buildOrderQuote(
  items: LineItem[],
  customer: Customer,
  destinationState: string
): Quote {
  return new BuildOrderQuoteCommand(items, customer, destinationState).execute();
}
```

### 2.3 Less maintainable form

```ts
type LineItem = {
  sku: string;
  unitPriceCents: number;
  quantity: number;
};

type Customer = {
  id: string;
  loyaltyTier: "standard" | "gold";
};

type Quote = {
  subtotalCents: number;
  discountCents: number;
  taxCents: number;
  shippingCents: number;
  totalCents: number;
};

function buildOrderQuote(
  items: LineItem[],
  customer: Customer,
  destinationState: string
): Quote {
  const subtotalCents = items.reduce(
    (sum, item) => sum + item.unitPriceCents * item.quantity,
    0
  );

  const discountCents =
    customer.loyaltyTier === "gold" ? Math.round(subtotalCents * 0.1) : 0;

  const taxableCents = subtotalCents - discountCents;
  const taxRate = destinationState === "CA" ? 0.0825 : 0.06;
  const taxCents = Math.round(taxableCents * taxRate);
  const shippingCents = taxableCents >= 5000 ? 0 : 799;

  return {
    subtotalCents,
    discountCents,
    taxCents,
    shippingCents,
    totalCents: taxableCents + taxCents + shippingCents
  };
}
```

### 2.4 Why this difference matters

The good form turns the quote calculation into a command object whose fields hold both inputs and intermediate results. That lets each step become a small method without passing `subtotalCents`, `discountCents`, and `taxableCents` through a chain of helper functions. When the quote rules grow, such as adding promotions, regional fees, or audit details, the command can gain new state and steps while keeping the public `buildOrderQuote` function stable.

The less maintainable form is still correct, but all intermediate state lives inside one function. As the operation grows, the reader must track the ordering and meaning of many local variables in a single scope.

### 2.5 Structural references

```text
Good: checkout > pricing > quote-command.ts > BuildOrderQuoteCommand.execute > quote calculation
Less maintainable: checkout > pricing > quote.ts > buildOrderQuote > quote calculation
```

The structural difference is that the good form gives the operation its own command object, with `execute` coordinating smaller methods that share object state. The less maintainable form keeps the whole operation inside one function body.

## 3. Boundaries and distinctions

Replace Function with Command is most useful when an operation has many steps, important intermediate state, or needs to be composed, queued, logged, retried, tested by step, or extended with variants. It is not necessary for a short, clear function with little temporary state. In those cases, introducing a command object can make the code harder to follow by adding indirection without enough benefit.

The less maintainable form can be appropriate when the operation is simple, unlikely to grow, and easiest to understand as one expression or one small function.

This refactoring is related to the Command pattern, but they are not identical. Replace Function with Command is the refactoring move: converting an existing function into an object that represents the operation. The Command pattern is the broader design pattern where requests are represented as objects, often to support queuing, undo, logging, scheduling, or dispatching.
