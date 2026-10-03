---
name: glossary
description: Maintain a compact glossary when the user explicitly defines, redefines, renames, removes, stores, or looks up terminology.
---

# Glossary

Keep definitions in `glossary.md` in this skill directory.
Use `AGENTS.md` only as a compact index of canonical glossary terms.

## When to use

Use this skill when the user explicitly defines, redefines, renames, removes, or asks to store a term, or asks for a defined project term.
Do not infer or store a definition from ordinary use of a word or phrase.

## Format

Write one entry per line:

```md
- term (alias, another alias) - definition
```

Omit the parenthetical when there are no aliases.
Use the user's intended canonical spelling, capitalization, and wording.

## Maintain entries

- Maintain entries only in `glossary.md` in this skill directory.
- If `glossary.md` does not exist and the user explicitly defines a term or asks to store one, create it before adding the entry.
- Add one canonical entry for each term. Normalize only whitespace and non-meaningful case when checking for duplicates.
- Resolve an alias to its canonical entry. Do not create separate entries for aliases.
- Update an existing entry when the user redefines it. An explicit redefinition replaces the prior definition.
- If a statement may conflict with an existing definition but does not clearly redefine it, identify the conflict and ask before changing the entry.
- On rename, preserve aliases unless the user removes them.
- On removal, delete the entry and aliases that belong only to it.

## Synchronize the index

After an add, rename, or removal, create or update the single `**Defined in Glossary:**` line in `AGENTS.md` with the canonical terms only, sorted alphabetically.
Do not put definitions or aliases in `AGENTS.md`.
If no terms remain, remove the `**Defined in Glossary:**` line.

## Lookup

For a lookup, match canonical terms and aliases case-insensitively unless capitalization changes meaning.
When a defined phrase overlaps a word, use the phrase definition.
Do not modify either file for a lookup unless the user also asks to change the glossary.
