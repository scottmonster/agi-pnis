# Mediator

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.16
- **Aliases:** None
- **Definition:** Route many-object collaboration through one coordinating object. It reduces peer-to-peer coupling, but the mediator can become a Large Class.
- **Why it matters:** Mediator makes collaboration easier to read and change by centralizing interaction rules that would otherwise be scattered across many objects. Instead of each object knowing which peers to update, each object reports events to one coordinator.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout screen lets a customer choose a shipping method and a payment method. The order summary must update when either choice changes.

### 2.2 Good form

```ts
type ShippingMethod = "standard" | "express";
type PaymentMethod = "card" | "gift-card";

interface CheckoutMediator {
  shippingChanged(method: ShippingMethod): void;
  paymentChanged(method: PaymentMethod): void;
}

class ShippingSelector {
  constructor(private readonly mediator: CheckoutMediator) {}

  select(method: ShippingMethod): void {
    console.log(`Shipping selected: ${method}`);
    this.mediator.shippingChanged(method);
  }
}

class PaymentSelector {
  constructor(private readonly mediator: CheckoutMediator) {}

  select(method: PaymentMethod): void {
    console.log(`Payment selected: ${method}`);
    this.mediator.paymentChanged(method);
  }
}

class SummaryPanel {
  show(total: number): void {
    console.log(`Order total: $${total}`);
  }
}

class CheckoutCoordinator implements CheckoutMediator {
  private shipping: ShippingMethod = "standard";
  private payment: PaymentMethod = "card";

  constructor(private readonly summary: SummaryPanel) {}

  shippingChanged(method: ShippingMethod): void {
    this.shipping = method;
    this.refreshSummary();
  }

  paymentChanged(method: PaymentMethod): void {
    this.payment = method;
    this.refreshSummary();
  }

  private refreshSummary(): void {
    const baseTotal = 50;
    const shippingCost = this.shipping === "express" ? 15 : 5;
    const discount = this.payment === "gift-card" ? 10 : 0;

    this.summary.show(baseTotal + shippingCost - discount);
  }
}

const summary = new SummaryPanel();
const coordinator = new CheckoutCoordinator(summary);
const shippingSelector = new ShippingSelector(coordinator);
const paymentSelector = new PaymentSelector(coordinator);

shippingSelector.select("express");
paymentSelector.select("gift-card");
```

### 2.3 Less maintainable form

```ts
type ShippingMethod = "standard" | "express";
type PaymentMethod = "card" | "gift-card";

class SummaryPanel {
  show(total: number): void {
    console.log(`Order total: $${total}`);
  }
}

class PaymentSelector {
  private payment: PaymentMethod = "card";
  private shippingSelector?: ShippingSelector;
  private summary?: SummaryPanel;

  connect(shippingSelector: ShippingSelector, summary: SummaryPanel): void {
    this.shippingSelector = shippingSelector;
    this.summary = summary;
  }

  select(method: PaymentMethod): void {
    this.payment = method;
    console.log(`Payment selected: ${method}`);
    this.refreshSummary();
  }

  currentPayment(): PaymentMethod {
    return this.payment;
  }

  refreshSummary(): void {
    if (!this.shippingSelector || !this.summary) {
      return;
    }

    const baseTotal = 50;
    const shippingCost = this.shippingSelector.currentShipping() === "express" ? 15 : 5;
    const discount = this.payment === "gift-card" ? 10 : 0;

    this.summary.show(baseTotal + shippingCost - discount);
  }
}

class ShippingSelector {
  private shipping: ShippingMethod = "standard";
  private paymentSelector?: PaymentSelector;
  private summary?: SummaryPanel;

  connect(paymentSelector: PaymentSelector, summary: SummaryPanel): void {
    this.paymentSelector = paymentSelector;
    this.summary = summary;
  }

  select(method: ShippingMethod): void {
    this.shipping = method;
    console.log(`Shipping selected: ${method}`);
    this.refreshSummary();
  }

  currentShipping(): ShippingMethod {
    return this.shipping;
  }

  refreshSummary(): void {
    if (!this.paymentSelector || !this.summary) {
      return;
    }

    const baseTotal = 50;
    const shippingCost = this.shipping === "express" ? 15 : 5;
    const discount = this.paymentSelector.currentPayment() === "gift-card" ? 10 : 0;

    this.summary.show(baseTotal + shippingCost - discount);
  }
}

const summary = new SummaryPanel();
const shippingSelector = new ShippingSelector();
const paymentSelector = new PaymentSelector();

shippingSelector.connect(paymentSelector, summary);
paymentSelector.connect(shippingSelector, summary);

shippingSelector.select("express");
paymentSelector.select("gift-card");
```

### 2.4 Why this difference matters

In the good form, `ShippingSelector` and `PaymentSelector` do not know about each other or about how totals are calculated. They only notify the `CheckoutMediator`, and the `CheckoutCoordinator` owns the collaboration rule: when checkout state changes, recompute the summary.

In the less maintainable form, each selector knows about the other selector and the summary. The same total calculation is duplicated in multiple peers, so adding a new checkout component, such as a coupon selector, would require changing several objects and keeping their interaction logic consistent.

### 2.5 Structural references

```text
Good: shop-app > checkout > checkoutCoordinator.ts > CheckoutCoordinator.shippingChanged > updateSummary
Less maintainable: shop-app > checkout > shippingSelector.ts > ShippingSelector.refreshSummary > paymentPanel and summaryPanel fields
```

The good structure places many-object coordination in a dedicated mediator target. The less maintainable structure places coordination inside peer objects, so collaboration paths spread across the participating components.

## 3. Boundaries and distinctions

Mediator applies when several objects must coordinate behavior and direct references between them are making changes difficult. It is most useful when the interaction rules are more complex than the individual objects themselves.

It may not apply when there are only one or two simple interactions, when direct calls are clearer, or when the coordination is already naturally owned by one domain object. The less maintainable form can be acceptable for small, stable code where introducing a mediator would add indirection without reducing meaningful coupling.

Mediator should also be kept focused. If every unrelated workflow is routed through one coordinator, the mediator can become a Large Class that is hard to understand and risky to change. In that case, split it by workflow or feature boundary.
