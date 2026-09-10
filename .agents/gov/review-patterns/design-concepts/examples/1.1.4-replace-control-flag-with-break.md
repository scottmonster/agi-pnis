# Replace Control Flag with Break

## 1. Concept

- **Classification:** refactoring
- **Catalog identifier:** 1.1.4
- **Aliases:** remove control flag
- **Definition:** Replace a variable used only to stop a loop with the loop's termination control. It exposes loop exit intent instead of making later conditions depend on hidden state.
- **Why it matters:** It makes the loop's stopping condition explicit at the point where the decision is made, reducing hidden state and making later changes less likely to accidentally keep scanning after the desired result is found.
- **Related concepts:** None

## 2. Example

### 2.1 Scenario

A shipping service scans a package's tracking events and returns the first event that requires the package to be held for manual review.

### 2.2 Good form

```ts
type TrackingEvent = {
  code: string;
  description: string;
};

function requiresManualReview(event: TrackingEvent): boolean {
  return event.code === "DAMAGED" || event.code === "ADDRESS_UNKNOWN";
}

function findFirstHoldEvent(events: TrackingEvent[]): TrackingEvent | undefined {
  let firstHoldEvent: TrackingEvent | undefined;

  for (const event of events) {
    if (requiresManualReview(event)) {
      firstHoldEvent = event;
      break;
    }
  }

  return firstHoldEvent;
}

const events: TrackingEvent[] = [
  { code: "PICKED_UP", description: "Package picked up by carrier" },
  { code: "ADDRESS_UNKNOWN", description: "Destination address could not be verified" },
  { code: "DAMAGED", description: "Package was damaged in transit" }
];

console.log(findFirstHoldEvent(events));
```

### 2.3 Less maintainable form

```ts
type TrackingEvent = {
  code: string;
  description: string;
};

function requiresManualReview(event: TrackingEvent): boolean {
  return event.code === "DAMAGED" || event.code === "ADDRESS_UNKNOWN";
}

function findFirstHoldEvent(events: TrackingEvent[]): TrackingEvent | undefined {
  let firstHoldEvent: TrackingEvent | undefined;
  let shouldContinue = true;

  for (const event of events) {
    if (shouldContinue && requiresManualReview(event)) {
      firstHoldEvent = event;
      shouldContinue = false;
    }
  }

  return firstHoldEvent;
}

const events: TrackingEvent[] = [
  { code: "PICKED_UP", description: "Package picked up by carrier" },
  { code: "ADDRESS_UNKNOWN", description: "Destination address could not be verified" },
  { code: "DAMAGED", description: "Package was damaged in transit" }
];

console.log(findFirstHoldEvent(events));
```

### 2.4 Why this difference matters

In the good form, the loop exits exactly where the first hold event is found. The `break` statement states the intent directly: after the first matching event, scanning is done.

In the less maintainable form, the loop still iterates over the remaining events, and a separate `shouldContinue` flag prevents later matches from changing the result. That flag is only there to simulate loop termination, so readers must track extra state to understand why later iterations do nothing.

### 2.5 Structural references

```text
Good: findFirstOverdueInvoice > break statement
Less maintainable: findFirstOverdueInvoice > found flag variable
```

The relevant structural difference is that the good form places termination control in the loop body with `break`, while the less maintainable form stores termination state in a separate local variable that later conditions must check.

## 3. Boundaries and distinctions

This refactoring applies when a variable's only purpose is to stop loop processing. It does not apply when the variable represents meaningful domain state, such as `hasValidationError`, `isAuthorized`, or `needsRetry`, and that state is used after the loop.

The less maintainable form can be appropriate when the language or context does not allow `break`, or when a flag must be shared across multiple scopes that cannot be exited directly. In ordinary TypeScript loops, `break` is usually clearer for single-loop termination.

This concept is not the same as replacing a loop with `return`. A direct `return` is appropriate when finding the item should exit the whole function, while `break` is appropriate when the function still needs to run logic after the loop. It is also different from simplifying boolean expressions: the focus here is removing a variable that exists only to control loop continuation.
