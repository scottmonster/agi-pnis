# Tool-Level Prevention Locus

`tool_level` — Repair or constrain tool behavior; add guardrails, validation, feedback, or observability.

## 1. Example failures

- **Silent configuration loss:** A deployment tool accepts a configuration file but drops an unsupported setting without reporting it. Repair parsing and add post-deployment configuration validation.
- **False-success test result:** A test runner exits successfully after failing to load part of the test suite. Repair exit-status handling and expose suite-discovery diagnostics.
- **Wrong-target action:** A command tool resolves an ambiguous environment name to production instead of the selected staging environment. Constrain target resolution and require an explicit target confirmation.
