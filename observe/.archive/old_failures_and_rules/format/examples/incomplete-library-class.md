# Incomplete Library Class

## 1. Concept

- **Classification:** code smell
- **Catalog identifier:** 5.2.10
- **Aliases:** None
- **Definition:** A library type lacks a needed operation but cannot be modified directly. Workarounds can scatter across callers; an adapter or wrapper can localize them.
- **Why it matters:** When callers repeatedly compensate for a missing library operation, the workaround becomes duplicated, inconsistent, and harder to change. A wrapper gives the missing operation a clear name and keeps the library-specific gap in one place.
- **Related concepts:** Adapter

## 2. Example

### 2.1 Scenario

A billing API receives query strings through the built-in `URLSearchParams` type. The team needs a consistent "required parameter" operation, but `URLSearchParams.get()` only returns `string | null`.

### 2.2 Good form

```ts
type DiscountRequest = {
  customerId: string;
  couponCode?: string;
};

type InvoiceRequest = {
  customerId: string;
  invoiceId: string;
};

class RequiredQueryParameters {
  private readonly params: URLSearchParams;

  constructor(queryString: string) {
    this.params = new URLSearchParams(queryString);
  }

  required(name: string): string {
    const value = this.params.get(name);

    if (value === null || value.trim() === "") {
      throw new Error(`Missing required query parameter: ${name}`);
    }

    return value;
  }

  optional(name: string): string | undefined {
    const value = this.params.get(name);
    return value === null || value.trim() === "" ? undefined : value;
  }
}

function createDiscountRequest(queryString: string): DiscountRequest {
  const query = new RequiredQueryParameters(queryString);

  return {
    customerId: query.required("customerId"),
    couponCode: query.optional("couponCode"),
  };
}

function createInvoiceRequest(queryString: string): InvoiceRequest {
  const query = new RequiredQueryParameters(queryString);

  return {
    customerId: query.required("customerId"),
    invoiceId: query.required("invoiceId"),
  };
}
```

### 2.3 Less maintainable form

```ts
type DiscountRequest = {
  customerId: string;
  couponCode?: string;
};

type InvoiceRequest = {
  customerId: string;
  invoiceId: string;
};

function createDiscountRequest(queryString: string): DiscountRequest {
  const query = new URLSearchParams(queryString);

  const customerId = query.get("customerId");
  if (customerId === null || customerId.trim() === "") {
    throw new Error("Missing required query parameter: customerId");
  }

  const couponCode = query.get("couponCode");

  return {
    customerId,
    couponCode: couponCode === null || couponCode.trim() === "" ? undefined : couponCode,
  };
}

function createInvoiceRequest(queryString: string): InvoiceRequest {
  const query = new URLSearchParams(queryString);

  const customerId = query.get("customerId");
  if (customerId === null || customerId.trim() === "") {
    throw new Error("Missing required query parameter: customerId");
  }

  const invoiceId = query.get("invoiceId");
  if (invoiceId === null || invoiceId.trim() === "") {
    throw new Error("Missing required query parameter: invoiceId");
  }

  return {
    customerId,
    invoiceId,
  };
}
```

### 2.4 Why this difference matters

`URLSearchParams` is a useful library type, but it does not provide the operation this codebase needs: "read this parameter and fail consistently if it is missing or blank." In the good form, `RequiredQueryParameters` adapts the library type once and gives that missing operation a domain-relevant name. Callers read as request construction logic instead of repeated null, blank, and error-message handling.

In the less maintainable form, every caller must remember the same workaround. If the rule changes, such as treating whitespace differently or using a typed validation error, each scattered check must be found and updated.

### 2.5 Structural references

```text
Good: RequiredQueryParameters.required > URLSearchParams wrapper method
Less maintainable: parseInvoiceRequest > repeated params.has and params.get checks
```

The relevant structural difference is that the good form localizes the missing library operation behind one wrapper target, while the less maintainable form embeds the workaround directly inside each caller.

## 3. Boundaries and distinctions

This smell does not apply when the library already provides the needed operation clearly, or when the operation is so specific to one caller that wrapping the library would add indirection without reuse. A small one-off workaround can be acceptable if it is isolated and unlikely to spread.

It is also different from simply disliking a library API. The issue is a concrete missing operation that the codebase repeatedly needs but cannot add to the library class directly.

An Adapter is a common way to address this smell. The smell is the incomplete library surface from the client code's perspective; the adapter or wrapper is the design response that supplies the missing operation locally without modifying the external type. Monkey-patching built-in or third-party prototypes can appear to solve the gap, but it usually makes behavior global, surprising, and harder to reason about.
