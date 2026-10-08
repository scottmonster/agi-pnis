# Build and Maintain the Python Pitfalls Catalog Family

Run this workflow independently for Python only. Apply the shared [language pitfalls workflow](pitfalls.md) in full.

```text
Historical input: ../sources/pitfalls-python/python.md
Catalog: ../../pitfalls/python/python-pitfalls-catalog.md
Rules: ../../pitfalls/python/python-pitfalls-rules.md
Examples: ../../pitfalls/python/examples/
Sources: ../sources/pitfalls-python.md
```

Research the Python language, runtime behavior, standard library, packaging and environment behavior where broadly relevant, and established Python development practice. Prefer official Python documentation, Python Enhancement Proposals, release notes, security guidance, and documented core-developer guidance. Record CPython-specific, operating-system-specific, packaging-tool-specific, and version-specific limits rather than presenting them as universal Python facts.

Do not add framework- or library-specific advice unless it establishes a generally relevant Python behavior or practice. Use `# Python Pitfalls Catalog` and `# Python Pitfalls Rules` as the derived-file titles.
