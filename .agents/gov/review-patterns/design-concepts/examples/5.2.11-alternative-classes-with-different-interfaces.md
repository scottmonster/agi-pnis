# Alternative Classes with Different Interfaces

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.11
- **Aliases:** None
- **Definition:** Classes that perform the same role expose different method names or shapes. Callers cannot treat the shared concept uniformly.
- **Why it matters:** When equivalent classes have different interfaces, callers must know provider-specific details, add conditional logic, and repeat adaptation code. This makes the shared role harder to recognize and makes new alternatives riskier to add.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

An order service asks different carriers for a shipping quote. Each carrier can produce the same kind of result: price and estimated delivery time for a package.

### 2.2 Good form

```ts
type Carrier = "ups" | "fedex";

interface ShippingQuoteRequest {
  destinationPostalCode: string;
  weightKg: number;
}

interface ShippingQuote {
  carrier: Carrier;
  totalCents: number;
  etaDays: number;
}

interface ShippingQuoteProvider {
  getQuote(request: ShippingQuoteRequest): ShippingQuote;
}

class UpsQuoteProvider implements ShippingQuoteProvider {
  getQuote(request: ShippingQuoteRequest): ShippingQuote {
    return {
      carrier: "ups",
      totalCents: 700 + Math.ceil(request.weightKg * 120),
      etaDays: 2,
    };
  }
}

class FedExQuoteProvider implements ShippingQuoteProvider {
  getQuote(request: ShippingQuoteRequest): ShippingQuote {
    return {
      carrier: "fedex",
      totalCents: 900 + Math.ceil(request.weightKg * 100),
      etaDays: 3,
    };
  }
}

const quoteProviders: Record<Carrier, ShippingQuoteProvider> = {
  ups: new UpsQuoteProvider(),
  fedex: new FedExQuoteProvider(),
};

function quoteShipping(
  carrier: Carrier,
  request: ShippingQuoteRequest,
): ShippingQuote {
  return quoteProviders[carrier].getQuote(request);
}

const quote = quoteShipping("ups", {
  destinationPostalCode: "10001",
  weightKg: 4.2,
});

console.log(`${quote.carrier}: $${quote.totalCents / 100}, ${quote.etaDays} days`);
```

### 2.3 Less maintainable form

```ts
type Carrier = "ups" | "fedex";

interface ShippingQuoteRequest {
  destinationPostalCode: string;
  weightKg: number;
}

interface ShippingQuote {
  carrier: Carrier;
  totalCents: number;
  etaDays: number;
}

class UpsRates {
  calculateRate(
    postalCode: string,
    weightKg: number,
  ): { amountInCents: number; days: number } {
    return {
      amountInCents: 700 + Math.ceil(weightKg * 120),
      days: 2,
    };
  }
}

class FedExClient {
  createShipmentQuote(input: {
    destinationZip: string;
    packageWeightKg: number;
  }): { priceCents: number; deliveryDays: number } {
    return {
      priceCents: 900 + Math.ceil(input.packageWeightKg * 100),
      deliveryDays: 3,
    };
  }
}

const upsRates = new UpsRates();
const fedExClient = new FedExClient();

function quoteShipping(
  carrier: Carrier,
  request: ShippingQuoteRequest,
): ShippingQuote {
  if (carrier === "ups") {
    const result = upsRates.calculateRate(
      request.destinationPostalCode,
      request.weightKg,
    );

    return {
      carrier: "ups",
      totalCents: result.amountInCents,
      etaDays: result.days,
    };
  }

  const result = fedExClient.createShipmentQuote({
    destinationZip: request.destinationPostalCode,
    packageWeightKg: request.weightKg,
  });

  return {
    carrier: "fedex",
    totalCents: result.priceCents,
    etaDays: result.deliveryDays,
  };
}

const quote = quoteShipping("ups", {
  destinationPostalCode: "10001",
  weightKg: 4.2,
});

console.log(`${quote.carrier}: $${quote.totalCents / 100}, ${quote.etaDays} days`);
```

### 2.4 Why this difference matters

In the good form, each carrier class exposes the same `getQuote(request)` operation and returns the same `ShippingQuote` shape. The caller only depends on the shared role, so adding another carrier means adding another implementation and registering it.

In the less maintainable form, the caller must know that UPS uses `calculateRate(postalCode, weightKg)` while FedEx uses `createShipmentQuote({ destinationZip, packageWeightKg })`. The shared concept is still present, but it is hidden behind incompatible method names, parameter shapes, and result shapes. Every caller that needs a quote may need similar conditional adaptation logic.

### 2.5 Structural references

```text
Good: ShippingQuoteProvider.quote > common provider interface
Less maintainable: quoteShipment > UpsClient.ratePackage and FedExClient.createRateQuote
```

The structural difference is that the good form routes the caller through one stable target method for the shared role. The less maintainable form routes the caller directly to several provider-specific methods, forcing the caller to translate between incompatible interfaces.

## 3. Boundaries and distinctions

This smell does not apply merely because two classes have different names or different internal implementations. It applies when the classes play the same role for callers but require different method names, argument shapes, or return shapes.

The less maintainable form can be appropriate at a system boundary, such as a thin adapter around third-party SDKs where each external API genuinely has a different interface. In that case, the inconsistency should usually be isolated behind local adapters so application code can still use a uniform interface.

This is different from duplication: the main problem is not repeated code, but incompatible access to the same concept. It is also different from a legitimate strategy pattern implementation, where alternatives intentionally share a common interface and callers can switch between them uniformly.
