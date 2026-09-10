# Encapsulate Variable

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 3.1.1
- **Aliases:** encapsulate field, self-encapsulate field
- **Definition:** Route access to mutable data through a named access point. It creates one place to understand, validate, or change its representation.
- **Why it matters:** It makes mutable state easier to read and change because callers use a named operation instead of depending on the variable's storage details. Validation, logging, lazy computation, or representation changes can be added in one place.
- **Related concepts:** Global Data, Mutable Data

## 2. Example

### 2.1 Scenario

A checkout module keeps a configurable receipt currency. The application can switch the currency for a region before formatting receipt totals.

### 2.2 Good form

```ts
type Currency = "USD" | "EUR" | "GBP";

const supportedCurrencies: ReadonlySet<Currency> = new Set(["USD", "EUR", "GBP"]);
let receiptCurrency: Currency = "USD";

function getReceiptCurrency(): Currency {
  return receiptCurrency;
}

function setReceiptCurrency(currency: Currency): void {
  if (!supportedCurrencies.has(currency)) {
    throw new Error(`Unsupported receipt currency: ${currency}`);
  }

  receiptCurrency = currency;
}

function formatReceiptTotal(cents: number): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: getReceiptCurrency(),
  }).format(cents / 100);
}

setReceiptCurrency("EUR");
console.log(formatReceiptTotal(1299));
```

### 2.3 Less maintainable form

```ts
type Currency = "USD" | "EUR" | "GBP";

let receiptCurrency: Currency = "USD";

function formatReceiptTotal(cents: number): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: receiptCurrency,
  }).format(cents / 100);
}

receiptCurrency = "EUR";
console.log(formatReceiptTotal(1299));
```

### 2.4 Why this difference matters

In the good form, all reads and writes go through `getReceiptCurrency` and `setReceiptCurrency`. That makes `receiptCurrency` a private representation detail and gives the module one access point for validation and future changes. For example, the value could later come from configuration, tenant settings, or a request context without changing every formatting call.

In the less maintainable form, code reads and writes the mutable variable directly. Any rule about valid values, side effects after a change, or representation changes must be found and updated at each direct access site.

### 2.5 Structural references

```text
Good: setReceiptCurrency > receiptCurrency assignment
Less maintainable: module scope > direct receiptCurrency assignment
```

The structural difference is that the good form places mutation behind a named function, while the less maintainable form mutates the variable directly from ordinary code.

## 3. Boundaries and distinctions

Encapsulate Variable applies when code has mutable data whose access rules or representation may matter. It is less useful for local variables with a tiny scope, immutable constants, or values that are already safely hidden inside a short function.

Direct access can be appropriate when the data is intentionally simple, immutable, and local, or when a small script has no meaningful maintenance cost. It can also be acceptable inside the accessor implementation itself.

This refactoring is related to **Mutable Data** because it reduces the risk of uncontrolled mutation, but it does not remove mutability. It is related to **Global Data** because global variables often need encapsulation, but the concept is broader: fields, module variables, and shared in-memory state can all be encapsulated even when they are not global.
