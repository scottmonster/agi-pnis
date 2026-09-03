# Security and Privacy Decision

## 1. Decision

Protect trust boundaries, access, secrets, and sensitive data through deliberate security and privacy controls.

## 2. Trust boundaries and authorization

Identify where untrusted input, users, services, and environments cross into trusted behavior. Authenticate and authorize before granting access or performing sensitive actions. Use the least privilege needed.

## 3. Secrets and sensitive data

Do not hard-code secrets or expose them through source control, errors, logs, telemetry, or diagnostics. Collect, retain, disclose, and access sensitive data only as needed for an established purpose.

## 4. Boundary validation and safe failure

Validate untrusted input at boundaries. Reject malformed, unauthorized, or unsafe requests before they affect protected behavior. Do not expose sensitive internal details or grant access when a security check cannot be completed.

## 5. Dependencies and security updates

Use maintained dependencies from trusted sources. Promptly assess known security issues affecting used dependencies, platforms, and configurations.

## 6. Verification and exceptions

Test meaningful security behavior, especially authorization, trust boundaries, sensitive-data handling, and safe failure. An allowed exception should state its scope, risk, compensating control if any, owner, and reconsideration condition.

## 7. Residual guidance

> For security and privacy concerns not explicitly addressed here, follow applicable established guidance unless an applicable authority explicitly allows otherwise.
