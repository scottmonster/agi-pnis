# Build and Maintain the Bash Pitfalls Catalog Family

Run this workflow independently for Bash only. Apply the shared [language pitfalls workflow](pitfalls.md) in full.

```text
Historical input: ../sources/pitfalls-bash/bash.md
Catalog: ../../pitfalls/bash/bash-pitfalls-catalog.md
Rules: ../../pitfalls/bash/bash-pitfalls-rules.md
Examples: ../../pitfalls/bash/examples/
Sources: ../sources/pitfalls-bash.md
```

Research Bash parsing, expansion, evaluation, variables, arrays, builtins, process and pipeline semantics, signals, filesystem operations, shell options, and interactions with Unix and POSIX utilities. Prefer the Bash manual, relevant POSIX specifications, GNU documentation, ShellCheck documentation where it identifies language behavior, and authoritative security guidance. Separate Bash-specific recommendations from portable POSIX-shell advice, and record platform, utility, shell-option, and version limits.

Use `# Bash Pitfalls Catalog` and `# Bash Pitfalls Rules` as the derived-file titles.
