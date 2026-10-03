# Singleton

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.5
- **Aliases:** None
- **Definition:** Restrict a type to one instance and provide access to it. It makes shared global state easy to reach but often hides dependencies and complicates change.
- **Why it matters:** Singleton makes it clear that a shared object is intended to be process-wide and reused, which can reduce duplicate setup and make access predictable. It can also reduce maintainability when callers silently depend on global state instead of receiving dependencies explicitly.
- **Related concepts:** Global Data, Service Locator

## 2. Example

### 2.1 Scenario

A checkout service reads payment configuration from an environment-like object. Multiple functions need the same validated configuration while handling a payment request.

### 2.2 Good form

```ts
type Env = Record<string, string | undefined>;

type Settings = {
  paymentUrl: string;
  timeoutMs: number;
};

class AppConfig {
  private static instance: AppConfig | undefined;

  readonly settings: Settings;

  private constructor(env: Env) {
    const paymentUrl = env.PAYMENT_URL;
    const timeoutMs = Number(env.PAYMENT_TIMEOUT_MS ?? "3000");

    if (!paymentUrl) {
      throw new Error("PAYMENT_URL is required");
    }

    this.settings = { paymentUrl, timeoutMs };
  }

  static getInstance(env: Env): AppConfig {
    if (!AppConfig.instance) {
      AppConfig.instance = new AppConfig(env);
    }

    return AppConfig.instance;
  }
}

function createPaymentClient(env: Env): { charge(cents: number): string } {
  const config = AppConfig.getInstance(env);

  return {
    charge(cents: number): string {
      return `POST ${config.settings.paymentUrl}/charges ${cents} timeout=${config.settings.timeoutMs}`;
    },
  };
}

function renderPaymentStatus(env: Env): string {
  const config = AppConfig.getInstance(env);
  return `Payment service: ${config.settings.paymentUrl}`;
}

const env: Env = {
  PAYMENT_URL: "https://payments.example.test",
  PAYMENT_TIMEOUT_MS: "5000",
};

const client = createPaymentClient(env);

console.log(client.charge(2500));
console.log(renderPaymentStatus(env));
```

### 2.3 Less maintainable form

```ts
type Env = Record<string, string | undefined>;

type Settings = {
  paymentUrl: string;
  timeoutMs: number;
};

class AppConfig {
  readonly settings: Settings;

  constructor(env: Env) {
    const paymentUrl = env.PAYMENT_URL;
    const timeoutMs = Number(env.PAYMENT_TIMEOUT_MS ?? "3000");

    if (!paymentUrl) {
      throw new Error("PAYMENT_URL is required");
    }

    this.settings = { paymentUrl, timeoutMs };
  }
}

function createPaymentClient(env: Env): { charge(cents: number): string } {
  const config = new AppConfig(env);

  return {
    charge(cents: number): string {
      return `POST ${config.settings.paymentUrl}/charges ${cents} timeout=${config.settings.timeoutMs}`;
    },
  };
}

function renderPaymentStatus(env: Env): string {
  const config = new AppConfig(env);
  return `Payment service: ${config.settings.paymentUrl}`;
}

const env: Env = {
  PAYMENT_URL: "https://payments.example.test",
  PAYMENT_TIMEOUT_MS: "5000",
};

const client = createPaymentClient(env);

console.log(client.charge(2500));
console.log(renderPaymentStatus(env));
```

### 2.4 Why this difference matters

In the good form, `AppConfig` enforces its own single-instance rule with a private constructor and a static `getInstance` access point. A reader can see that all callers share the same validated configuration object.

In the less maintainable form, every caller can construct `AppConfig` independently. That preserves the visible behavior in this small example, but it spreads the decision about instance lifetime across the codebase. If configuration loading later becomes expensive, stateful, cached, or dependent on initialization order, each call site must be audited and changed.

### 2.5 Structural references

```text
Good: checkout-service > configuration > appConfig.ts > getInstance > AppConfig.instance
Less maintainable: checkout-service > configuration > appConfig.ts > createPaymentClient > new AppConfig
```

The relevant structural difference is where instance ownership lives. The good form centralizes ownership inside the configuration file through one access function and one stored target instance. The less maintainable form places construction at each consuming function, so the type is not restricted to one instance.

## 3. Boundaries and distinctions

Singleton applies when the design intentionally requires exactly one instance of a type, such as a process-wide configuration object or a shared runtime registry. It does not apply merely because an object is commonly reused, expensive to create, or passed to many functions. In those cases, dependency injection or explicit module-level composition may communicate dependencies more clearly.

The less maintainable form can be appropriate when separate instances are useful, such as per-request configuration, test-specific setup, tenant-specific settings, or independent clients with different options.

Singleton differs from Global Data because Singleton is a construction and access-control pattern for one object, while Global Data is any globally reachable mutable state. A Singleton may contain global data, but it is not the same concept. Singleton also differs from Service Locator: a Service Locator provides access to many services by lookup, while a Singleton restricts one type to one instance.
