# Error Handling Decision

## 1. Decision

Make failure behavior explicit, safe, and observable without adding error-handling machinery that does not support a present caller, contract, constraint, or operational need.

This standard applies the Engineering Principles Framework: add or retain error-handling structure when its benefit justifies its complexity and maintenance cost.

## 2. Failure ownership and contracts

- Handle a failure at the lowest layer that can take a meaningful, correct action. Otherwise preserve useful context and let it propagate.
- Treat an error as part of a public contract when a caller can recover, choose a response, or needs to distinguish outcomes. Translate provider and framework failures at module or external boundaries; do not casually leak them across those boundaries.
- Validate untrusted input at boundaries. Reject invalid or unauthorized requests early with an actionable, safe error.
- Add error types, result wrappers, exception hierarchies, or centralized handling only when they provide a stable caller contract or reduce demonstrated ambiguity. Use the language or framework's ordinary mechanism otherwise.

## 3. Recovery, retries, and fallbacks

- Do not silently swallow failures. Suppress, degrade, or use a fallback only when that behavior is intentional, safe, observable, and has a defined owner.
- Retry only transient failures when the operation is safe to retry. Define idempotency, attempt limits, backoff, timeout, and cancellation behavior.
- Do not add generic retry, fallback, or error-routing infrastructure solely for possible future use.

## 4. Diagnostics and safety

- Preserve useful diagnostic context: the operation, relevant identifiers, cause, and boundary.
- Exclude secrets and sensitive data from errors, logs, and telemetry.
- Record an unexpected terminal failure once at an appropriate operational boundary. Avoid duplicate logs at every propagation layer.

## 5. Verification

Test meaningful failure behavior at the relevant boundary, following the Testing Strategy Decision. Strong candidates include rejected input, authorization, contract translation, retries, timeouts, partial failure, and irreversible operations.

Do not test incidental exception plumbing. A test should establish the caller-visible behavior, state outcome, retry limit, or operational signal that matters.

## 6. Guiding principle

> Make expected failures actionable, unexpected failures diagnosable, and recovery behavior deliberate. Do not hide failures or build generalized error machinery without a present need.
