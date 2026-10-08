# Replace Exception with Precheck

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.2.8
- **Aliases:** replace exception with test
- **Definition:** Test a predictable condition before the operation rather than using an exception as ordinary branching. It clarifies expected flow; it does not apply to truly exceptional failures.
- **Why it matters:** It makes expected branches visible in the main control flow, reduces noisy try/catch blocks, and keeps exceptions reserved for failures the program does not normally expect to handle as routine decisions.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout service reserves inventory for a requested SKU. If the SKU is unknown, the service should return a normal "unknown-sku" result rather than treating that expected condition as an exceptional failure.

### 2.2 Good form

```ts
type ReservationResult =
  | { ok: true; remaining: number }
  | { ok: false; reason: "unknown-sku" | "out-of-stock" };

function reserveItem(
  stockBySku: Map<string, number>,
  sku: string,
  quantity: number
): ReservationResult {
  if (!stockBySku.has(sku)) {
    return { ok: false, reason: "unknown-sku" };
  }

  const currentStock = stockBySku.get(sku)!;

  if (currentStock < quantity) {
    return { ok: false, reason: "out-of-stock" };
  }

  const remaining = currentStock - quantity;
  stockBySku.set(sku, remaining);

  return { ok: true, remaining };
}

const stockBySku = new Map<string, number>([
  ["SKU-123", 5],
  ["SKU-456", 0]
]);

console.log(reserveItem(stockBySku, "SKU-999", 1));
console.log(reserveItem(stockBySku, "SKU-123", 2));
```

### 2.3 Less maintainable form

```ts
type ReservationResult =
  | { ok: true; remaining: number }
  | { ok: false; reason: "unknown-sku" | "out-of-stock" };

class MissingSkuError extends Error {
  constructor(readonly sku: string) {
    super(`Unknown SKU: ${sku}`);
    this.name = "MissingSkuError";
  }
}

function getStockOrThrow(stockBySku: Map<string, number>, sku: string): number {
  const currentStock = stockBySku.get(sku);

  if (currentStock === undefined) {
    throw new MissingSkuError(sku);
  }

  return currentStock;
}

function reserveItem(
  stockBySku: Map<string, number>,
  sku: string,
  quantity: number
): ReservationResult {
  try {
    const currentStock = getStockOrThrow(stockBySku, sku);

    if (currentStock < quantity) {
      return { ok: false, reason: "out-of-stock" };
    }

    const remaining = currentStock - quantity;
    stockBySku.set(sku, remaining);

    return { ok: true, remaining };
  } catch (error) {
    if (error instanceof MissingSkuError) {
      return { ok: false, reason: "unknown-sku" };
    }

    throw error;
  }
}

const stockBySku = new Map<string, number>([
  ["SKU-123", 5],
  ["SKU-456", 0]
]);

console.log(reserveItem(stockBySku, "SKU-999", 1));
console.log(reserveItem(stockBySku, "SKU-123", 2));
```

### 2.4 Why this difference matters

The good form names the predictable condition, `!stockBySku.has(sku)`, at the point where the decision is made. A reader can see that "unknown SKU" is an ordinary outcome of the reservation process.

The less maintainable form hides that same expected branch behind `throw` and `catch`. To understand the normal behavior, a reader must inspect `getStockOrThrow`, identify the thrown error type, and then connect it to the catch block. This makes routine control flow look like failure handling and makes future changes riskier, because new exception paths may accidentally be mixed with expected business outcomes.

### 2.5 Structural references

```text
Good: checkout-service > inventory > src/reservations.ts > reserveItem > stockBySku.has(sku) precheck
Less maintainable: checkout-service > inventory > src/reservations.ts > reserveItem > catch (error) branch for MissingSkuError
```

The relevant structural difference is that the good form keeps the expected "unknown SKU" branch inside the direct reservation flow, while the less maintainable form splits that branch across a throwing helper and an exception handler.

## 3. Boundaries and distinctions

Replace Exception with Precheck applies when the condition is predictable, cheap to test, and part of normal business flow, such as a missing key, empty collection, absent optional value, or invalid user choice.

The less maintainable form may be appropriate when the failure is truly exceptional, such as corrupted data, a violated invariant, an unavailable external service, or an API that can fail for reasons the caller cannot reliably test beforehand. It may also be necessary when the operation is inherently race-prone: even after a precheck, the operation can still fail because shared state changed, so exception handling may still be required as a safety net.

This refactoring is not a rule against exceptions. It is a rule against using exceptions as ordinary branching for expected cases. It also differs from a generic guard clause: a guard clause is any early check, while Replace Exception with Precheck specifically replaces a predictable exception path with an explicit test before the operation.
