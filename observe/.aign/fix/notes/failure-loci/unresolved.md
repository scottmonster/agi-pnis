# Unresolved Prevention Locus

## 1. Example failures

- **Insufficient retained evidence:** A regression is detected, but the relevant logs were not retained and the failure cannot be reproduced. Preserve the evidence gap and seek further evidence before assigning a preventive change.
- **Competing explanations:** A failure follows both an instruction change and a tool upgrade, but the available evidence cannot distinguish their effects. Record both hypotheses and avoid a premature corrective-action claim.
- **Unavailable execution context:** A prior agent run caused an incorrect change, but its runtime context and tool results are unavailable. Retain the uncertainty and investigate only when new evidence becomes available.
