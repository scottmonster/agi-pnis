# Speculative Generality

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.3.1
- **Aliases:** None
- **Definition:** Abstractions, parameters, hooks, or extension points exist for imagined future needs rather than a present burden. They enlarge the code readers must understand.
- **Why it matters:** It makes simple behavior look more variable than it is, forcing readers to understand unused abstractions and possible extension paths before they can see the actual current rule.
- **Related concepts:** Remove Dead Code

## 2. Example

### 2.1 Scenario

A checkout service currently supports one discount code, `SAVE10`, which subtracts 10 percent from the cart subtotal. There is no current requirement for multiple discount types, plugins, or pricing hooks.

### 2.2 Good form

```ts
type CartItem = {
  name: string;
  unitPriceCents: number;
  quantity: number;
};

function calculateTotalCents(items: CartItem[], discountCode?: string): number {
  const subtotal = items.reduce(
    (sum, item) => sum + item.unitPriceCents * item.quantity,
    0
  );

  if (discountCode === "SAVE10") {
    return Math.round(subtotal * 0.9);
  }

  return subtotal;
}

const total = calculateTotalCents(
  [
    { name: "Notebook", unitPriceCents: 1200, quantity: 2 },
    { name: "Pen", unitPriceCents: 200, quantity: 3 }
  ],
  "SAVE10"
);

console.log(total);
```

### 2.3 Less maintainable form

```ts
type CartItem = {
  name: string;
  unitPriceCents: number;
  quantity: number;
};

type DiscountContext = {
  items: CartItem[];
  subtotalCents: number;
  discountCode?: string;
  customerSegment?: string;
  campaignId?: string;
};

type PricingHooks = {
  beforeDiscount?: (context: DiscountContext) => DiscountContext;
  afterDiscount?: (totalCents: number, context: DiscountContext) => number;
};

interface DiscountStrategy {
  canApply(context: DiscountContext): boolean;
  apply(context: DiscountContext): number;
}

class PercentageDiscountStrategy implements DiscountStrategy {
  constructor(
    private readonly code: string,
    private readonly percentage: number
  ) {}

  canApply(context: DiscountContext): boolean {
    return context.discountCode === this.code;
  }

  apply(context: DiscountContext): number {
    return Math.round(context.subtotalCents * (1 - this.percentage));
  }
}

class DiscountEngine {
  private readonly strategies: DiscountStrategy[] = [];

  constructor(private readonly hooks: PricingHooks = {}) {}

  register(strategy: DiscountStrategy): void {
    this.strategies.push(strategy);
  }

  calculate(context: DiscountContext): number {
    const preparedContext = this.hooks.beforeDiscount
      ? this.hooks.beforeDiscount(context)
      : context;

    const strategy = this.strategies.find((candidate) =>
      candidate.canApply(preparedContext)
    );

    const total = strategy
      ? strategy.apply(preparedContext)
      : preparedContext.subtotalCents;

    return this.hooks.afterDiscount
      ? this.hooks.afterDiscount(total, preparedContext)
      : total;
  }
}

function calculateTotalCents(items: CartItem[], discountCode?: string): number {
  const subtotalCents = items.reduce(
    (sum, item) => sum + item.unitPriceCents * item.quantity,
    0
  );

  const engine = new DiscountEngine();
  engine.register(new PercentageDiscountStrategy("SAVE10", 0.1));

  return engine.calculate({
    items,
    subtotalCents,
    discountCode
  });
}

const total = calculateTotalCents(
  [
    { name: "Notebook", unitPriceCents: 1200, quantity: 2 },
    { name: "Pen", unitPriceCents: 200, quantity: 3 }
  ],
  "SAVE10"
);

console.log(total);
```

### 2.4 Why this difference matters

The good form exposes the only current rule directly: `SAVE10` reduces the subtotal by 10 percent. A reader can understand the behavior by reading one function.

The less maintainable form preserves the same behavior, but adds a strategy interface, an engine, registration, optional hooks, and unused context fields for possible future pricing needs. Those extension points are not paying for themselves yet. They increase the amount of code a maintainer must inspect and make it harder to tell which variation is real and which is only imagined.

### 2.5 Structural references

```text
Good: discountFor > direct active rule
Less maintainable: DiscountEngine.calculate > registeredRules extension list
```

The relevant structural difference is that the good form keeps the current pricing rule inside the function that needs it, while the less maintainable form inserts extra extension structures between the function and the single rule it currently supports.

## 3. Boundaries and distinctions

Speculative Generality does not apply when the abstraction serves a present, demonstrated need. For example, a strategy registry can be appropriate if the system already supports several discount types, loads customer-specific pricing modules, or exposes a stable plugin API used by external teams.

The less maintainable form may also be appropriate when the cost of later change is known to be high and the variation is already committed, such as a public SDK extension point that must remain backward compatible. In that case, the abstraction is not merely speculative.

This smell differs from Remove Dead Code. Dead code is unused or unreachable and can often be deleted outright. Speculative Generality may be executed, but its extra parameters, hooks, interfaces, or layers exist for hypothetical variation rather than current behavior. The usual remedy is to collapse the unnecessary abstraction until real duplication or real variability appears.
