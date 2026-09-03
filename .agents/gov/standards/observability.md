# Observability Decision

## 1. Decision

Produce the smallest set of safe, actionable signals needed to understand important behavior, diagnose failures, and operate the system. Add or retain telemetry only when its benefit justifies its complexity, cost, and exposure risk.

This standard applies the Engineering Principles Framework. Observability supports error handling and verification; it does not replace either.

## 2. Select the smallest useful signal

Add telemetry to answer a current diagnostic, operational, security, audit, or service-level question. Do not instrument every operation solely because it exists.

Use the signal that best represents the needed evidence:

- **Logs** record discrete events and their diagnostic context.
- **Metrics** show numerical behavior and trends over time.
- **Traces** show an operation's path through meaningful components, services, or asynchronous work.

Use more than one signal only when each provides distinct useful evidence.

## 3. Make evidence useful

Record meaningful outcomes, failures, latency, state transitions, and boundary interactions when they need to be understood or operated. Use structured, machine-readable fields for information that must be searched, filtered, aggregated, correlated, or processed automatically.

Include the operation, relevant non-sensitive identifiers, outcome, and cause or boundary when they materially aid diagnosis. Correlate related activity with a request, trace, job, workflow, or other operation identifier when the behavior crosses concurrent, asynchronous, or distributed boundaries.

Severity communicates an event's significance and normal visibility, not its code location. Use a consistent project-specific severity mapping; do not raise severity merely to make a message more visible.

## 4. Preserve safety and signal quality

Do not record secrets, credentials, sensitive personal data, confidential payloads, or information whose exposure is not justified by an established need. Redact, truncate, hash, or record metadata instead of content when that preserves the needed evidence.

Control volume, cardinality, retention, performance impact, and cost. Use aggregation, sampling, rate limiting, or state-transition events when repeated telemetry would otherwise obscure meaningful signals. Keep detailed diagnostic output disabled or bounded during routine production operation unless a present need justifies it.

Follow the Error Handling Decision for error context, error translation, and recording unexpected terminal failures. Do not log the same propagated failure at every layer.

## 5. Make signals operable

Give important signals a clear owner, stable name or schema, and intended operational use. Create an alert only when a defined owner can investigate or act on the condition.

Do not use logs as a substitute for metrics or traces when another signal represents the required evidence more directly.

## 6. Verify meaningful observability

Test observability behavior when it is part of a contract, security control, incident safeguard, service objective, or operational requirement. A useful test establishes the required event, field, correlation, metric, trace, alert condition, or redaction behavior without coupling to incidental implementation details.

## 7. Guiding principle

> Produce enough safe evidence to understand, diagnose, and operate meaningful behavior. Do not create telemetry noise, cost, or exposure without a present need.
