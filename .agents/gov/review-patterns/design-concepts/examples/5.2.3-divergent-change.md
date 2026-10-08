# Divergent Change

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.3
- **Aliases:** None
- **Definition:** One module changes for several unrelated reasons. Its responsibilities are mixed, so a change risks unrelated behavior.
- **Why it matters:** It makes a module harder to read and understand because unrelated policies are interleaved. It also makes maintenance riskier because a tax, pricing, or formatting change can accidentally affect checkout behavior that should have remained untouched.
- **Related concepts:** Extract Class

## 2. Example

### 2.1 Scenario

An online store calculates an order subtotal, applies state tax, and returns a receipt. The intended behavior is the same in both examples: produce a receipt with line totals, subtotal, tax, and grand total.

### 2.2 Good form

```ts
type StateCode = "CA" | "NY" | "TX" | "OTHER";

type CartItem = {
  sku: string;
  name: string;
  quantity: number;
  unitPriceCents: number;
};

type ShippingAddress = {
  state: StateCode;
};

type ReceiptLine = {
  sku: string;
  description: string;
  amountCents: number;
};

type Receipt = {
  orderId: string;
  lines: ReceiptLine[];
  subtotalCents: number;
  taxCents: number;
  totalCents: number;
};

class PriceCalculator {
  subtotal(items: CartItem[]): number {
    return items.reduce(
      (total, item) => total + item.quantity * item.unitPriceCents,
      0
    );
  }
}

class TaxCalculator {
  taxFor(subtotalCents: number, address: ShippingAddress): number {
    const rates: Record<StateCode, number> = {
      CA: 0.0825,
      NY: 0.08,
      TX: 0.0625,
      OTHER: 0
    };

    return Math.round(subtotalCents * rates[address.state]);
  }
}

class ReceiptFormatter {
  createReceipt(
    orderId: string,
    items: CartItem[],
    subtotalCents: number,
    taxCents: number
  ): Receipt {
    const lines = items.map((item) => ({
      sku: item.sku,
      description: `${item.quantity} x ${item.name}`,
      amountCents: item.quantity * item.unitPriceCents
    }));

    return {
      orderId,
      lines,
      subtotalCents,
      taxCents,
      totalCents: subtotalCents + taxCents
    };
  }
}

class CheckoutService {
  constructor(
    private readonly prices: PriceCalculator,
    private readonly taxes: TaxCalculator,
    private readonly receipts: ReceiptFormatter
  ) {}

  checkout(
    orderId: string,
    items: CartItem[],
    address: ShippingAddress
  ): Receipt {
    const subtotalCents = this.prices.subtotal(items);
    const taxCents = this.taxes.taxFor(subtotalCents, address);

    return this.receipts.createReceipt(
      orderId,
      items,
      subtotalCents,
      taxCents
    );
  }
}

const checkout = new CheckoutService(
  new PriceCalculator(),
  new TaxCalculator(),
  new ReceiptFormatter()
);

const receipt = checkout.checkout(
  "order-1001",
  [
    { sku: "BK-1", name: "Notebook", quantity: 2, unitPriceCents: 499 },
    { sku: "PN-2", name: "Pen", quantity: 3, unitPriceCents: 199 }
  ],
  { state: "CA" }
);

console.log(receipt);
```

### 2.3 Less maintainable form

```ts
type StateCode = "CA" | "NY" | "TX" | "OTHER";

type CartItem = {
  sku: string;
  name: string;
  quantity: number;
  unitPriceCents: number;
};

type ShippingAddress = {
  state: StateCode;
};

type ReceiptLine = {
  sku: string;
  description: string;
  amountCents: number;
};

type Receipt = {
  orderId: string;
  lines: ReceiptLine[];
  subtotalCents: number;
  taxCents: number;
  totalCents: number;
};

class CheckoutService {
  checkout(
    orderId: string,
    items: CartItem[],
    address: ShippingAddress
  ): Receipt {
    const subtotalCents = items.reduce(
      (total, item) => total + item.quantity * item.unitPriceCents,
      0
    );

    const taxRates: Record<StateCode, number> = {
      CA: 0.0825,
      NY: 0.08,
      TX: 0.0625,
      OTHER: 0
    };

    const taxCents = Math.round(subtotalCents * taxRates[address.state]);

    const lines = items.map((item) => ({
      sku: item.sku,
      description: `${item.quantity} x ${item.name}`,
      amountCents: item.quantity * item.unitPriceCents
    }));

    return {
      orderId,
      lines,
      subtotalCents,
      taxCents,
      totalCents: subtotalCents + taxCents
    };
  }
}

const checkout = new CheckoutService();

const receipt = checkout.checkout(
  "order-1001",
  [
    { sku: "BK-1", name: "Notebook", quantity: 2, unitPriceCents: 499 },
    { sku: "PN-2", name: "Pen", quantity: 3, unitPriceCents: 199 }
  ],
  { state: "CA" }
);

console.log(receipt);
```

### 2.4 Why this difference matters

In the good form, pricing, tax calculation, and receipt creation are separate modules with separate reasons to change. A tax rule change is localized to `TaxCalculator`, a receipt layout change is localized to `ReceiptFormatter`, and a pricing rule change is localized to `PriceCalculator`.

In the less maintainable form, `CheckoutService` changes for several unrelated reasons. Each edit requires rereading and retesting a broader checkout module, increasing the chance that a tax change accidentally breaks receipt construction or subtotal logic.

### 2.5 Structural references

```text
Good: PriceCalculator.subtotal, TaxCalculator.taxFor, ReceiptFormatter.createReceipt
Less maintainable: CheckoutService.checkout > pricing, tax, and receipt statements
```

The relevant structural difference is that the good form separates unrelated reasons to change into distinct functions owned by focused modules. The less maintainable form concentrates pricing, taxation, and receipt formatting inside one checkout function.

## 3. Boundaries and distinctions

Divergent Change does not apply just because a module has several methods. It applies when the same module must be edited for unrelated kinds of changes, such as tax policy, display format, and pricing rules.

The less maintainable form can be acceptable for a short-lived script, a prototype, or a tiny module where the responsibilities are not yet stable and the cost of separation would be higher than the benefit.

Divergent Change differs from Shotgun Surgery: Divergent Change means one module changes for many unrelated reasons, while Shotgun Surgery means one conceptual change requires edits across many modules. `Extract Class` is a common refactoring for Divergent Change because it moves separate responsibilities into more cohesive modules.
