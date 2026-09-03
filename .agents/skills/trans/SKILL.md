---
name: trans
description: "Use when the user asks to export the conversation or its last messages as clean Markdown."
disable-model-invocation: true
---

# Trans

Export the requested portion of the user-visible conversation as Markdown.

- Exclude the current user message that triggered this skill from the export and from any requested message count. If the user gives a message count, include the last that many earlier messages. Otherwise, include the entire available conversation preceding the triggering message. A count of zero produces an empty response.
- Count individual user and assistant messages, in chronological order. Exclude system, developer, tool, and commentary-only messages.
- Preserve each message's content. Only remove leading and trailing blank lines from an individual message.
- Do not add an introduction, explanation, code fence, metadata, or closing text.
- If earlier requested messages are unavailable in the current conversation context, export every available message rather than inventing content.

Use this exact structure, with `---` between consecutive exported messages:

```markdown
## User

<user message>

---

## Assistant

<assistant message>
```
