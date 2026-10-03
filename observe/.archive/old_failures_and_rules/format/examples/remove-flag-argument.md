# Remove Flag Argument

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 2.2.4
- **Aliases:** replace parameter with explicit methods
- **Definition:** Replace a boolean or mode parameter that selects different operations with distinct named operations. Call sites reveal the chosen behavior.
- **Why it matters:** It makes the caller's intent explicit, reduces the need to remember what `true` or `false` means, and localizes behavior changes behind named operations.
- **Related concepts:** Flag Argument

## 2. Example

### 2.1 Scenario

A checkout service quotes shipping labels for standard and expedited delivery. Both options use the same shipment data, but the caller must choose which delivery behavior is intended.

### 2.2 Good form

```ts
type Shipment = {
  weightKg: number;
  destinationZone: "local" | "regional" | "national";
};

type LabelQuote = {
  serviceLevel: "standard" | "expedited";
  priceCents: number;
  estimatedDays: number;
};

function zoneSurchargeCents(destinationZone: Shipment["destinationZone"]): number {
  switch (destinationZone) {
    case "local":
      return 0;
    case "regional":
      return 400;
    case "national":
      return 900;
  }
}

function basePriceCents(shipment: Shipment): number {
  return 500 + shipment.weightKg * 120 + zoneSurchargeCents(shipment.destinationZone);
}

function createQuote(
  shipment: Shipment,
  serviceLevel: LabelQuote["serviceLevel"],
  priceMultiplier: number,
  estimatedDays: number
): LabelQuote {
  return {
    serviceLevel,
    priceCents: Math.round(basePriceCents(shipment) * priceMultiplier),
    estimatedDays
  };
}

function quoteStandardLabel(shipment: Shipment): LabelQuote {
  return createQuote(shipment, "standard", 1, 5);
}

function quoteExpeditedLabel(shipment: Shipment): LabelQuote {
  return createQuote(shipment, "expedited", 1.75, 2);
}

const shipment: Shipment = {
  weightKg: 3,
  destinationZone: "national"
};

const standardQuote = quoteStandardLabel(shipment);
const expeditedQuote = quoteExpeditedLabel(shipment);

console.log(standardQuote, expeditedQuote);
```

### 2.3 Less maintainable form

```ts
type Shipment = {
  weightKg: number;
  destinationZone: "local" | "regional" | "national";
};

type LabelQuote = {
  serviceLevel: "standard" | "expedited";
  priceCents: number;
  estimatedDays: number;
};

function zoneSurchargeCents(destinationZone: Shipment["destinationZone"]): number {
  switch (destinationZone) {
    case "local":
      return 0;
    case "regional":
      return 400;
    case "national":
      return 900;
  }
}

function basePriceCents(shipment: Shipment): number {
  return 500 + shipment.weightKg * 120 + zoneSurchargeCents(shipment.destinationZone);
}

function quoteLabel(shipment: Shipment, expedited: boolean): LabelQuote {
  if (expedited) {
    return {
      serviceLevel: "expedited",
      priceCents: Math.round(basePriceCents(shipment) * 1.75),
      estimatedDays: 2
    };
  }

  return {
    serviceLevel: "standard",
    priceCents: basePriceCents(shipment),
    estimatedDays: 5
  };
}

const shipment: Shipment = {
  weightKg: 3,
  destinationZone: "national"
};

const standardQuote = quoteLabel(shipment, false);
const expeditedQuote = quoteLabel(shipment, true);

console.log(standardQuote, expeditedQuote);
```

### 2.4 Why this difference matters

In the good form, the operation is named at the call site: `quoteStandardLabel(shipment)` and `quoteExpeditedLabel(shipment)`. A reader does not need to inspect the function signature or implementation to decode what `true` or `false` means.

The distinct functions also give each behavior its own place to evolve. If expedited labels later need a delivery promise, surcharge rule, or audit event, that change can be made through the expedited operation without making every caller reason about a shared flag-controlled branch.

### 2.5 Structural references

```text
Good: checkout-service > shipping > label-pricing.ts > quoteExpeditedLabel > named operation
Less maintainable: checkout-service > shipping > label-pricing.ts > quoteLabel > boolean flag parameter
```

The relevant structural difference is that the good form exposes separate functions for separate operations, while the less maintainable form exposes one function whose behavior is selected by a boolean parameter.

## 3. Boundaries and distinctions

Remove Flag Argument applies when a parameter chooses between different operations, such as standard versus expedited shipping. It does not apply to every boolean parameter. A boolean can be appropriate when it is ordinary domain data, such as `isGiftWrapped`, `isVerified`, or a persisted checkbox value.

The less maintainable form can be acceptable for a private helper hidden behind explicit public methods, especially when the helper only removes duplication and callers never pass the flag directly. It can also be acceptable for simple data transfer where no behavior is selected.

This refactoring addresses the smell called Flag Argument. The smell is the boolean or mode parameter that hides intent at the call site. The refactoring is to replace that selector with explicit named operations. The same idea can apply to string or enum mode parameters when each mode represents a different operation rather than just data.
