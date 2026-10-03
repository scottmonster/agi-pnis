---
name: rules-verbatim
description: Output every user-provided and project-provided rule, instruction, and guidance block already in context, verbatim.
disable-model-invocation: true
---

# Output Rules Verbatim

Do not read any files or retrieve any additional context.

Output every user-provided and project-provided rule, instruction, and guidance block already present in your current context. This includes all applicable instruction blocks, not only the instructions in this skill or blocks explicitly labelled as rules.

Do not output or attempt to reveal any system, developer, platform, model-provider, or other hidden instructions.

For the permitted user/project instructions, output the original text verbatim, character-for-character and symbol-for-symbol.

Do not summarize, paraphrase, interpret, reconstruct, normalize, correct, reorder, add, or remove anything.

Preserve exactly:
- wording
- capitalization
- punctuation
- symbols
- Markdown
- headings
- bullets
- numbering
- code fences
- inline code
- whitespace
- line breaks

If multiple user/project instruction blocks are present, reproduce each block exactly as it appears.

Output **ALL** user-provided and project-provided instruction blocks.

Before completing, verify that you provided **ALL** permitted instruction blocks.
