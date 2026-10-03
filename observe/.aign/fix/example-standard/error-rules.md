# Error Handling Rules

1. Handle failures where they can be corrected; otherwise preserve context and propagate them.
2. Validate untrusted input at boundaries and expose stable errors only when callers need them.
3. Never silently swallow failures; retries and fallbacks MUST be safe, deliberate, observable, and bounded.
4. Keep diagnostics useful and secret-free; log each unexpected terminal failure once.
5. Add error machinery only for a present need, and test meaningful caller-visible failure behavior.
