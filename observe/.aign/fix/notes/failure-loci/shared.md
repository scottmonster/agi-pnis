# Shared Agent-and-Tool Prevention Locus

`shared_agent_and_tool` — Combine tool-enforced checks with agent guidance, interface improvements, and verification loops.

## 1. Example failures

- **Destructive migration without preview:** The agent runs a migration without first inspecting its impact, and the migration tool provides no required dry-run or confirmation. Add an agent preview checkpoint and a tool-enforced preview gate.
- **Ambiguous bulk edit:** The agent selects the wrong files from an ambiguous tool result, and the tool offers no scoped diff or confirmation. Improve agent selection rules and add tool-side target review.
- **Misread successful command:** The agent treats a zero exit code as proof of success even though the tool's output reports skipped work. Improve agent result interpretation and make skipped work a distinct tool status.
