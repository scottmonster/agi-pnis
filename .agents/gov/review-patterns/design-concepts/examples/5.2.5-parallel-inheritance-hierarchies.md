# Parallel Inheritance Hierarchies

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.5
- **Aliases:** None
- **Definition:** Adding a subclass in one hierarchy requires a matching subclass in another. The duplicated variation structure makes extension brittle.
- **Why it matters:** It makes the code harder to understand and maintain because one conceptual variation is represented in multiple places. Readers must know that the hierarchies must stay synchronized, and adding a new variant requires coordinated edits that are easy to miss.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An e-commerce app creates carrier-specific shipment labels and tracking URLs for packages. FedEx and UPS behave differently, but each carrier should be added through one extension point.

### 2.2 Good form

```ts
type Shipment = {
  id: string;
  destinationPostalCode: string;
  weightKg: number;
};

type ShipmentSummary = {
  label: string;
  trackingUrl: string;
};

abstract class Carrier {
  abstract readonly code: string;
  abstract createLabel(shipment: Shipment): string;
  abstract trackingUrl(shipment: Shipment): string;
}

class FedExCarrier extends Carrier {
  readonly code = "fedex";

  createLabel(shipment: Shipment): string {
    return `FEDEX LABEL ${shipment.id} TO ${shipment.destinationPostalCode}`;
  }

  trackingUrl(shipment: Shipment): string {
    return `https://fedex.example/track/${shipment.id}`;
  }
}

class UpsCarrier extends Carrier {
  readonly code = "ups";

  createLabel(shipment: Shipment): string {
    return `UPS LABEL ${shipment.id} ${shipment.weightKg}KG`;
  }

  trackingUrl(shipment: Shipment): string {
    return `https://ups.example/track/${shipment.id}`;
  }
}

const carriers: Record<string, Carrier> = {
  fedex: new FedExCarrier(),
  ups: new UpsCarrier()
};

function createShipmentSummary(carrierCode: string, shipment: Shipment): ShipmentSummary {
  const carrier = carriers[carrierCode];

  if (!carrier) {
    throw new Error(`Unsupported carrier: ${carrierCode}`);
  }

  return {
    label: carrier.createLabel(shipment),
    trackingUrl: carrier.trackingUrl(shipment)
  };
}

const summary = createShipmentSummary("fedex", {
  id: "S-1001",
  destinationPostalCode: "94105",
  weightKg: 2.4
});

console.log(summary);
```

### 2.3 Less maintainable form

```ts
type Shipment = {
  id: string;
  destinationPostalCode: string;
  weightKg: number;
};

type ShipmentSummary = {
  label: string;
  trackingUrl: string;
};

abstract class Carrier {
  abstract readonly code: string;
  abstract trackingUrl(shipment: Shipment): string;
}

class FedExCarrier extends Carrier {
  readonly code = "fedex";

  trackingUrl(shipment: Shipment): string {
    return `https://fedex.example/track/${shipment.id}`;
  }
}

class UpsCarrier extends Carrier {
  readonly code = "ups";

  trackingUrl(shipment: Shipment): string {
    return `https://ups.example/track/${shipment.id}`;
  }
}

abstract class LabelBuilder {
  abstract readonly carrierCode: string;
  abstract createLabel(shipment: Shipment): string;
}

class FedExLabelBuilder extends LabelBuilder {
  readonly carrierCode = "fedex";

  createLabel(shipment: Shipment): string {
    return `FEDEX LABEL ${shipment.id} TO ${shipment.destinationPostalCode}`;
  }
}

class UpsLabelBuilder extends LabelBuilder {
  readonly carrierCode = "ups";

  createLabel(shipment: Shipment): string {
    return `UPS LABEL ${shipment.id} ${shipment.weightKg}KG`;
  }
}

const carriers: Record<string, Carrier> = {
  fedex: new FedExCarrier(),
  ups: new UpsCarrier()
};

const labelBuilders: LabelBuilder[] = [
  new FedExLabelBuilder(),
  new UpsLabelBuilder()
];

function findLabelBuilderFor(carrier: Carrier): LabelBuilder {
  const builder = labelBuilders.find(candidate => candidate.carrierCode === carrier.code);

  if (!builder) {
    throw new Error(`No label builder for carrier: ${carrier.code}`);
  }

  return builder;
}

function createShipmentSummary(carrierCode: string, shipment: Shipment): ShipmentSummary {
  const carrier = carriers[carrierCode];

  if (!carrier) {
    throw new Error(`Unsupported carrier: ${carrierCode}`);
  }

  const labelBuilder = findLabelBuilderFor(carrier);

  return {
    label: labelBuilder.createLabel(shipment),
    trackingUrl: carrier.trackingUrl(shipment)
  };
}

const summary = createShipmentSummary("fedex", {
  id: "S-1001",
  destinationPostalCode: "94105",
  weightKg: 2.4
});

console.log(summary);
```

### 2.4 Why this difference matters

In the good form, the carrier variation is represented once: each `Carrier` implementation owns both label creation and tracking URL behavior. Adding a new carrier means adding one new carrier implementation and registering it.

In the less maintainable form, the same carrier variation is duplicated across two hierarchies: `Carrier` and `LabelBuilder`. Adding `DhlCarrier` also requires `DhlLabelBuilder`, plus a correct mapping between them. If one side is forgotten or mismatched, the system compiles but fails at runtime for that carrier.

### 2.5 Structural references

```text
Good: Carrier.createLabelBuilder > paired carrier label builder
Less maintainable: FedExCarrier/FedExLabelBuilder and UpsCarrier/UpsLabelBuilder > parallel subclasses
```

The relevant structural difference is the number of synchronized variation points. The good form has one target for carrier-specific behavior, while the less maintainable form has two parallel targets that must evolve in lockstep.

## 3. Boundaries and distinctions

Parallel Inheritance Hierarchies does not apply just because a codebase has multiple inheritance trees. It applies when subclasses correspond one-to-one across trees and adding a subclass in one tree predictably forces a matching subclass in another.

The less maintainable form can be acceptable when the two hierarchies are genuinely independent, owned by different systems, generated from external schemas, or intentionally separated by a stable plugin boundary. In those cases, an explicit mapping layer may be the safest design, but the coupling should be visible and tested.

This smell is different from ordinary duplication. The problem is not only repeated code, but repeated variation structure. It is also different from a deliberate separation of independent dimensions, where one hierarchy can change without requiring matching changes in the other.
