# Build and Maintain the JavaScript Pitfalls Catalog Family

Run this workflow independently for JavaScript only. Apply the shared [language pitfalls workflow](pitfalls.md) in full.

```text
Historical input: ../sources/pitfalls-javascript/javascript.md
Catalog: ../../pitfalls/javascript/javascript-pitfalls-catalog.md
Rules: ../../pitfalls/javascript/javascript-pitfalls-rules.md
Examples: ../../pitfalls/javascript/examples/
Sources: ../sources/pitfalls-javascript.md
```

Research vanilla JavaScript: ECMAScript semantics, standard built-ins, browser and runtime behavior, and standard platform APIs with broadly applicable language consequences. Prefer the ECMAScript specification, MDN, TC39 materials, and official browser or runtime documentation. Separate core-language behavior from host-specific behavior, and state browser, runtime, and version boundaries where they matter.

Do not add framework-, library-, build-tool-, or TypeScript-specific advice unless it exposes a JavaScript behavior that remains materially relevant without those tools. Use `# JavaScript Pitfalls Catalog` and `# JavaScript Pitfalls Rules` as the derived-file titles.
