# Builder

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.3
- **Aliases:** None
- **Definition:** Construct a complex object step by step through a dedicated builder. It makes optional parts and construction order explicit.
- **Why it matters:** Builder makes complex construction easier to read and change by naming each construction step, separating required setup from optional parts, and avoiding long parameter lists or scattered conditional assembly logic.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A checkout service creates a shipping quote request with required origin, destination, and package weight. Some shipments also add optional insurance, signature confirmation, and a delivery window.

### 2.2 Good form

```ts
type Address = {
  name: string;
  street: string;
  postalCode: string;
  country: string;
};

type DeliveryWindow = {
  startHour: number;
  endHour: number;
};

type ShipmentRequest = {
  origin: Address;
  destination: Address;
  weightKg: number;
  insuranceValueCents?: number;
  signatureRequired: boolean;
  deliveryWindow?: DeliveryWindow;
};

class ShipmentRequestBuilder {
  private request: ShipmentRequest;

  constructor(origin: Address, destination: Address, weightKg: number) {
    this.request = {
      origin,
      destination,
      weightKg,
      signatureRequired: false
    };
  }

  withInsurance(valueCents: number): ShipmentRequestBuilder {
    this.request.insuranceValueCents = valueCents;
    return this;
  }

  requireSignature(): ShipmentRequestBuilder {
    this.request.signatureRequired = true;
    return this;
  }

  withDeliveryWindow(startHour: number, endHour: number): ShipmentRequestBuilder {
    this.request.deliveryWindow = { startHour, endHour };
    return this;
  }

  build(): ShipmentRequest {
    return { ...this.request };
  }
}

function buildShipmentRequest(): ShipmentRequest {
  const warehouse: Address = {
    name: "Main Warehouse",
    street: "100 Supply Road",
    postalCode: "10001",
    country: "US"
  };

  const customer: Address = {
    name: "Ava Chen",
    street: "25 Market Street",
    postalCode: "94105",
    country: "US"
  };

  return new ShipmentRequestBuilder(warehouse, customer, 3.4)
    .withInsurance(50000)
    .requireSignature()
    .withDeliveryWindow(9, 13)
    .build();
}

const request = buildShipmentRequest();
console.log(request);
```

### 2.3 Less maintainable form

```ts
type Address = {
  name: string;
  street: string;
  postalCode: string;
  country: string;
};

type DeliveryWindow = {
  startHour: number;
  endHour: number;
};

type ShipmentRequest = {
  origin: Address;
  destination: Address;
  weightKg: number;
  insuranceValueCents?: number;
  signatureRequired: boolean;
  deliveryWindow?: DeliveryWindow;
};

function createShipmentRequest(
  origin: Address,
  destination: Address,
  weightKg: number,
  insuranceValueCents?: number,
  signatureRequired: boolean = false,
  deliveryWindowStartHour?: number,
  deliveryWindowEndHour?: number
): ShipmentRequest {
  const request: ShipmentRequest = {
    origin,
    destination,
    weightKg,
    signatureRequired
  };

  if (insuranceValueCents !== undefined) {
    request.insuranceValueCents = insuranceValueCents;
  }

  if (
    deliveryWindowStartHour !== undefined &&
    deliveryWindowEndHour !== undefined
  ) {
    request.deliveryWindow = {
      startHour: deliveryWindowStartHour,
      endHour: deliveryWindowEndHour
    };
  }

  return request;
}

function buildShipmentRequest(): ShipmentRequest {
  const warehouse: Address = {
    name: "Main Warehouse",
    street: "100 Supply Road",
    postalCode: "10001",
    country: "US"
  };

  const customer: Address = {
    name: "Ava Chen",
    street: "25 Market Street",
    postalCode: "94105",
    country: "US"
  };

  return createShipmentRequest(
    warehouse,
    customer,
    3.4,
    50000,
    true,
    9,
    13
  );
}

const request = buildShipmentRequest();
console.log(request);
```

### 2.4 Why this difference matters

The good form gives each optional construction step a named method: `withInsurance`, `requireSignature`, and `withDeliveryWindow`. A reader can see which optional parts are present without remembering the position and meaning of several arguments.

The less maintainable form preserves the same behavior, but the call depends on argument order. Values like `50000`, `true`, `9`, and `13` are harder to interpret at the call site, and adding another optional part would make the function signature longer and more fragile.

### 2.5 Structural references

```text
Good: shipping-service > shipments > shipmentRequest.ts > buildShipmentRequest > ShipmentRequestBuilder.build
Less maintainable: shipping-service > shipments > shipmentRequest.ts > buildShipmentRequest > createShipmentRequest argument list
```

The structural difference is that the good form places object construction behind a dedicated builder target, while the less maintainable form places all required and optional construction inputs directly in one factory function call.

## 3. Boundaries and distinctions

Builder is most useful when an object has several required and optional parts, construction involves multiple steps, or valid construction order should be visible. It is often unnecessary for small objects with only a few clear fields, where a direct object literal or simple factory function is easier.

The less maintainable form can be acceptable when construction is stable, has very few parameters, or is used only in a narrow local context. It becomes a problem when optional parameters accumulate, when callers pass many literals, or when construction rules start spreading across call sites.

Builder differs from a plain factory because a factory usually returns the finished object from one call, while a builder exposes a step-by-step construction process before `build()`. Builder also differs from simply using an options object: an options object names fields, but it does not necessarily guide construction order, enforce staged setup, or encapsulate construction rules.
