# Data Clump

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.1.5
- **Aliases:** None
- **Definition:** The same group of values repeatedly appears together in parameters, fields, or locals. The recurring group likely names a missing concept.
- **Why it matters:** Repeated value groups make code harder to read because callers and maintainers must rediscover that the values belong together. Changes to the group, such as adding a region or validation rule, must be repeated across many signatures and call sites.
- **Related concepts:** Introduce Parameter Object

## 2. Example

### 2.1 Scenario

A checkout service quotes shipping and delivery time for an order. The origin postal code, destination postal code, and destination country always travel together because they describe one shipping route.

### 2.2 Good form

```ts
type DeliveryRoute = {
  originPostalCode: string;
  destinationPostalCode: string;
  destinationCountry: string;
};

type ShippingQuote = {
  shippingCost: number;
  transitDays: number;
};

function canDeliver(route: DeliveryRoute): boolean {
  return route.destinationCountry === "US" || route.destinationCountry === "CA";
}

function estimateTransitDays(route: DeliveryRoute): number {
  if (route.originPostalCode === route.destinationPostalCode) {
    return 1;
  }

  return route.destinationCountry === "US" ? 3 : 5;
}

function calculateShippingCost(route: DeliveryRoute, packageWeightKg: number): number {
  const internationalSurcharge = route.destinationCountry === "US" ? 0 : 12;
  return 6 + packageWeightKg * 1.5 + internationalSurcharge;
}

function quoteShipment(route: DeliveryRoute, packageWeightKg: number): ShippingQuote {
  if (!canDeliver(route)) {
    throw new Error(`Cannot deliver to ${route.destinationCountry}`);
  }

  return {
    shippingCost: calculateShippingCost(route, packageWeightKg),
    transitDays: estimateTransitDays(route),
  };
}

const quote = quoteShipment(
  {
    originPostalCode: "94105",
    destinationPostalCode: "10001",
    destinationCountry: "US",
  },
  2.4,
);

console.log(quote);
```

### 2.3 Less maintainable form

```ts
type ShippingQuote = {
  shippingCost: number;
  transitDays: number;
};

function canDeliver(destinationCountry: string): boolean {
  return destinationCountry === "US" || destinationCountry === "CA";
}

function estimateTransitDays(
  originPostalCode: string,
  destinationPostalCode: string,
  destinationCountry: string,
): number {
  if (originPostalCode === destinationPostalCode) {
    return 1;
  }

  return destinationCountry === "US" ? 3 : 5;
}

function calculateShippingCost(
  originPostalCode: string,
  destinationPostalCode: string,
  destinationCountry: string,
  packageWeightKg: number,
): number {
  void originPostalCode;
  void destinationPostalCode;

  const internationalSurcharge = destinationCountry === "US" ? 0 : 12;
  return 6 + packageWeightKg * 1.5 + internationalSurcharge;
}

function quoteShipment(
  originPostalCode: string,
  destinationPostalCode: string,
  destinationCountry: string,
  packageWeightKg: number,
): ShippingQuote {
  if (!canDeliver(destinationCountry)) {
    throw new Error(`Cannot deliver to ${destinationCountry}`);
  }

  return {
    shippingCost: calculateShippingCost(
      originPostalCode,
      destinationPostalCode,
      destinationCountry,
      packageWeightKg,
    ),
    transitDays: estimateTransitDays(
      originPostalCode,
      destinationPostalCode,
      destinationCountry,
    ),
  };
}

const quote = quoteShipment("94105", "10001", "US", 2.4);

console.log(quote);
```

### 2.4 Why this difference matters

In the good form, the repeated values are named as a `DeliveryRoute`, so the code exposes the missing concept directly. Function signatures show which operations need a route, call sites pass one coherent value, and any future route-related change has one obvious place to land. In the less maintainable form, the same three values are repeatedly threaded through functions, making their relationship implicit and increasing the chance of argument ordering mistakes or inconsistent changes.

### 2.5 Structural references

```text
Good: checkout-service > shipping > shippingQuote.ts > quoteShipment > route: DeliveryRoute
Less maintainable: checkout-service > shipping > shippingQuote.ts > quoteShipment > originPostalCode, originCountry, destinationPostalCode, destinationCountry
```

The relevant structural difference is that the good form has one parameter representing the route concept, while the less maintainable form repeats the same route fields as separate parameters.

## 3. Boundaries and distinctions

Data Clump does not apply to values that merely appear together once or are coincidentally adjacent without a stable shared meaning. A small group of primitives can be acceptable when the function is local, short-lived, and the values are not repeated elsewhere.

The less maintainable form may be reasonable at a narrow boundary, such as parsing an HTTP request or reading raw database columns, where separate scalar values are still being decoded. After that boundary, repeatedly passing the same group is a signal to introduce a named object.

Data Clump differs from a long parameter list because the issue is not just the number of parameters. The smell is the repeated cluster of related values across multiple places. `Introduce Parameter Object` is a common refactoring response: it names the recurring group and gives related validation or behavior a natural home.
