---
name: reword
description: Generate one or more meaning-preserving rewordings of supplied text, files, directories, conversations, transcripts, structured content, or mixed material. Use when the user wants complete alternative wording without changing meaning.
disable-model-invocation: true
---

# Reword

Generate the requested number of complete alternative representations of all supplied material.

1. Treat every supplied source as material to reword unless the user explicitly excludes it. Read files and directories completely before writing.
2. Preserve the meaning, not the wording. Maintain intent, scope, conditions, qualifications, relationships, distinctions, implications, perspective, voice, modality, level of obligation, certainty or uncertainty, communicative function, and other material meaning without adding, removing, broadening, narrowing, reinterpreting, or inferring content.
3. Re-express each version using substantially different vocabulary, phrasing, syntax, sentence construction, and, where meaning and format permit, organization. Minor synonym substitution or small edits to the original wording are insufficient.
4. Prefer suitable alternative expressions over wording already used in the source or another version. Repeat words, phrases, constructions, or ordering only when alternatives would reduce naturalness or precision, change meaning, or replace necessary terminology or literals. Do not manufacture variation for its own sake.
5. Create each version as an independent re-expression of the underlying meaning. Do not derive later versions by incrementally editing the source or another version. Versions must differ materially from both the source and one another.
6. Preserve the input's format and representation when meaningful or functional, including headings, lists, tables, blockquotes, frontmatter, fields, labels, speaker structure, code fences, emphasis, quotation, capitalization, and comparable structure. Keep reworded content associated with the same structural unit unless the user requests otherwise or reorganization preserves meaning, correspondence, and usability.
7. Reword natural-language expression, not fixed or machine-significant content. Preserve syntax, delimiters, identifiers, placeholders, paths, URLs, commands, code, configuration keys, schema fields, citations, defined terms, cross-references, section references, and other literals when changing them could alter identity, function, reference, validity, or usability.
8. Preserve references and referents so pronouns, labels, links, cross-references, and relative references such as `above`, `below`, `the following`, or `option 2` continue to identify the same thing.
9. Honor user-specified invariants. Treat any wording, terminology, sections, structure, formatting, or literals the user requires unchanged as fixed while varying the remaining material as much as meaning permits.
10. Adapt the form and degree of rewording to the material. Short material may require substantial lexical and syntactic change; longer or multi-source material may also be reorganized when doing so preserves all material relationships, correspondence, meaning, and functional structure.
11. Keep each version complete. Do not summarize, comment on, explain, evaluate, or otherwise replace re-expression with analysis.
12. Return the versions in the response. Do not write an output file unless the user requests one.
13. do not number each variation
14. place the results in a code block
