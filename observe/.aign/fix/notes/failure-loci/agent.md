# Agent-Level Prevention Locus

## 1. Example failures

- **Ignored repository instruction:** The agent changes generated files despite an explicit instruction to edit the source files only. Improve instruction handling or add an agent checkpoint before modifying generated output.
- **Unverified completion claim:** The agent reports the task complete after a narrow unit test passes but does not check the required integration path. Improve the agent's verification routing or completion checklist.
- **Unsupported API assumption:** The agent implements against an imagined dependency API instead of inspecting the installed version. Improve repository grounding and evidence requirements before implementation.
