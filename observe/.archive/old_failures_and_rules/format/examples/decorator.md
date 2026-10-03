# Decorator

## 1. Concept

- **Classification:** pattern
- **Catalog identifier:** 4.2.9
- **Aliases:** None
- **Definition:** Wrap an object to add behavior while preserving its interface. It localizes optional responsibilities, though stacked decorators can obscure behavior.
- **Why it matters:** Decorator keeps optional behavior near the code that adds it, instead of spreading conditionals through the core object. This makes the base behavior easier to read, allows responsibilities to be combined independently, and reduces the need to edit stable code when adding optional features.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A notification service sends account security emails. Some deployments need delivery logging and retry behavior, while others only need the base email sender.

### 2.2 Good form

```ts
interface Notifier {
  send(to: string, message: string): Promise<void>;
}

class EmailNotifier implements Notifier {
  async send(to: string, message: string): Promise<void> {
    console.log(`Sending email to ${to}: ${message}`);
  }
}

abstract class NotifierDecorator implements Notifier {
  protected constructor(private readonly wrapped: Notifier) {}

  send(to: string, message: string): Promise<void> {
    return this.wrapped.send(to, message);
  }
}

class LoggingNotifier extends NotifierDecorator {
  async send(to: string, message: string): Promise<void> {
    console.log(`Notification requested for ${to}`);
    await super.send(to, message);
    console.log(`Notification sent for ${to}`);
  }
}

class RetryingNotifier extends NotifierDecorator {
  constructor(
    wrapped: Notifier,
    private readonly maxAttempts: number
  ) {
    super(wrapped);
  }

  async send(to: string, message: string): Promise<void> {
    let lastError: unknown;

    for (let attempt = 1; attempt <= this.maxAttempts; attempt += 1) {
      try {
        await super.send(to, message);
        return;
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError;
  }
}

function buildNotifier(): Notifier {
  const emailNotifier = new EmailNotifier();
  const retryingNotifier = new RetryingNotifier(emailNotifier, 3);
  return new LoggingNotifier(retryingNotifier);
}

async function sendSecurityAlert(): Promise<void> {
  const notifier = buildNotifier();
  await notifier.send("alex@example.com", "A new sign-in was detected.");
}

void sendSecurityAlert();
```

### 2.3 Less maintainable form

```ts
interface Notifier {
  send(to: string, message: string): Promise<void>;
}

type EmailNotifierOptions = {
  enableLogging: boolean;
  enableRetry: boolean;
  maxAttempts: number;
};

class EmailNotifier implements Notifier {
  constructor(private readonly options: EmailNotifierOptions) {}

  async send(to: string, message: string): Promise<void> {
    if (this.options.enableLogging) {
      console.log(`Notification requested for ${to}`);
    }

    let lastError: unknown;
    const attempts = this.options.enableRetry ? this.options.maxAttempts : 1;

    for (let attempt = 1; attempt <= attempts; attempt += 1) {
      try {
        console.log(`Sending email to ${to}: ${message}`);

        if (this.options.enableLogging) {
          console.log(`Notification sent for ${to}`);
        }

        return;
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError;
  }
}

function buildNotifier(): Notifier {
  return new EmailNotifier({
    enableLogging: true,
    enableRetry: true,
    maxAttempts: 3
  });
}

async function sendSecurityAlert(): Promise<void> {
  const notifier = buildNotifier();
  await notifier.send("alex@example.com", "A new sign-in was detected.");
}

void sendSecurityAlert();
```

### 2.4 Why this difference matters

The good form keeps the `Notifier` interface stable while moving optional responsibilities into separate wrappers. `EmailNotifier` only knows how to send an email, `RetryingNotifier` only knows how to retry another notifier, and `LoggingNotifier` only knows how to log calls to another notifier. New optional behavior can be added by creating another `Notifier` wrapper without editing the existing sender.

The less maintainable form preserves the same intended behavior, but it embeds optional responsibilities inside `EmailNotifier`. Each new behavior adds more options, branches, and ordering concerns to the base sender. Over time, the reader must understand every optional path before trusting the core email behavior.

### 2.5 Structural references

```text
Good: notification-service > notifications > notifier.ts > buildNotifier > new LoggingNotifier(retryingNotifier)
Less maintainable: notification-service > notifications > notifier.ts > buildNotifier > optionConfiguredNotifier conditional behavior
```

The relevant structural difference is where optional behavior is attached. In the good form, `buildNotifier` composes behavior by wrapping one `Notifier` with another. In the less maintainable form, `buildNotifier` passes flags into a single object, forcing that object to contain both core behavior and optional responsibilities.

## 3. Boundaries and distinctions

Decorator applies when several objects share an interface and optional behavior can be added around calls to that interface. It is especially useful when responsibilities need to be combined in different orders or enabled independently.

It may not apply when the behavior is not optional, when there is only one simple implementation, or when the added behavior changes the public interface instead of preserving it. In those cases, a direct implementation or a new abstraction may be clearer.

The less maintainable form can be appropriate for very small, stable code where one or two flags are unlikely to grow and introducing wrappers would add unnecessary indirection.

Decorator differs from inheritance because it adds behavior at object composition time rather than by creating a fixed subclass hierarchy. It also differs from Adapter: an adapter changes one interface into another, while a decorator preserves the same interface and adds behavior around it. Stacked decorators should be used carefully because too many layers can make the final behavior harder to trace.
