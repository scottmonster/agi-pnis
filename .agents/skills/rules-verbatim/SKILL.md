---
name: rules-verbatim
description: Use to output all of the user supplied rules.
disable-model-invocation: true
---

# Reword

Do not read any files or retrieve any additional context.

Output only the user-provided and project-provided rules, instructions, and guidance that are already present in your current context.

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

Output **ALL** instruction blocks defined by the **USER**

Before output stop and ask... Are these _actually_ all of the rules or did I miss any?