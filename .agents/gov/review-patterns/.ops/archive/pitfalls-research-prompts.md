#### Assistant said:

Yes. That list can anchor the agent toward the categories you happened to think of, which can reduce discovery of unexpected classes of issues.

I would remove it and instead define the **kind of thing to find**, not the areas in which to find it.

A better replacement would be:

> Research across the full TypeScript language, type system, compiler behavior, standard development practices, and ecosystem conventions. Do not limit the search to predefined technical categories. Discover categories from the evidence as the research progresses, and include any materially relevant class of pitfalls, gotchas, footguns, anti-patterns, correctness hazards, or preferred idioms that fits the research objective.

You can make the anti-anchoring requirement even stronger:

> Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.

That is much better for the kind of exhaustive research you are trying to do.

-----
#### User said:

Give me the full prompt with:
Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.

-----
#### Assistant said:

:::writing{variant="document" id="58315" title="TypeScript Pitfalls and Preferred Idioms Research Prompt"}
Research as comprehensively as practical for TypeScript-specific **pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms**, especially cases where experienced TypeScript developers recommend **"do this instead of that."**

The goal is to identify as many distinct, materially useful TypeScript practices as possible, not just the most popular or obvious examples.

Research across the full TypeScript language, type system, compiler behavior, standard development practices, and ecosystem conventions.

**Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.**

Actively look for unexpected or less obvious classes of issues that may not fit common TypeScript best-practice lists.

For every finding, provide exactly:

```text
Name:
Category:
Impact:
Consensus:
Description:
Why:
Source URL:
```

Use the fields as follows:

- **Name** - concise name for the pattern, pitfall, or recommendation.
- **Category** - a technical category derived from the findings during research. Do not force findings into a predefined category set.
- **Impact** - High, Medium, or Low based on how materially the issue can affect correctness, reliability, maintainability, type safety, or development outcomes.
- **Consensus** - High, Medium, or Low based on how broadly the recommendation is supported by authoritative sources and experienced TypeScript practitioners.
- **Description** - explain the issue or recommendation, including the problematic approach and preferred alternative where applicable.
- **Why** - explain why the preferred approach matters and what problems it prevents or improves.
- **Source URL** - provide the strongest relevant source supporting the finding.

Organize the final results into:

1. **High Impact**
2. **Medium Impact**
3. **Low Impact**

Within each impact level, order findings from highest to lowest consensus.

Research broadly across authoritative and high-quality sources. Prefer primary and authoritative sources when they adequately support a finding, while also using high-quality practitioner sources where they provide material guidance not covered by primary documentation.

Potential source types include:

- official TypeScript documentation
- TypeScript handbook and release documentation
- TypeScript compiler and repository documentation
- guidance from TypeScript maintainers and contributors
- established engineering documentation
- respected TypeScript experts and practitioners
- technically rigorous articles and discussions

Do not treat popularity, repetition, or search ranking alone as evidence of correctness or consensus.

Evaluate **Impact** and **Consensus** independently. A finding may have high impact but low consensus, or low impact but high consensus.

Include disputed practices when they are materially relevant, but assign an appropriate Consensus rating and accurately describe the disagreement rather than presenting one side as settled guidance.

Avoid duplicate findings that describe the same underlying issue. Merge substantially equivalent recommendations while preserving genuinely different cases, conditions, or failure modes.

Focus on TypeScript-specific guidance or practices whose consequences materially change when TypeScript is involved. Do not fill the results with generic programming advice unless TypeScript introduces a distinct consideration.

Do not stop after finding a conventional "top TypeScript best practices" list. Use iterative discovery to identify additional terminology, failure modes, recommendations, and sources from the findings themselves.

Continue researching until further searching is producing primarily duplicates, minor stylistic preferences, weakly supported claims, or findings with little practical significance.
:::

-----
#### User said:

Now give me that prompt but adapted for vanilla js

-----
#### Assistant said:

:::writing{variant="document" id="58316" title="Vanilla JavaScript Pitfalls and Preferred Idioms Research Prompt"}
Research as comprehensively as practical for vanilla JavaScript-specific **pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms**, especially cases where experienced JavaScript developers recommend **"do this instead of that."**

The goal is to identify as many distinct, materially useful JavaScript practices as possible, not just the most popular or obvious examples.

Research across the full JavaScript language, runtime behavior, built-in APIs, standard development practices, and ecosystem conventions that materially affect vanilla JavaScript.

**Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.**

Actively look for unexpected or less obvious classes of issues that may not fit common JavaScript best-practice lists.

For every finding, provide exactly:

```text
Name:
Category:
Impact:
Consensus:
Description:
Why:
Source URL:
```

Use the fields as follows:

- **Name** - concise name for the pattern, pitfall, or recommendation.
- **Category** - a technical category derived from the findings during research. Do not force findings into a predefined category set.
- **Impact** - High, Medium, or Low based on how materially the issue can affect correctness, reliability, maintainability, security, performance, or development outcomes.
- **Consensus** - High, Medium, or Low based on how broadly the recommendation is supported by authoritative sources and experienced JavaScript practitioners.
- **Description** - explain the issue or recommendation, including the problematic approach and preferred alternative where applicable.
- **Why** - explain why the preferred approach matters and what problems it prevents or improves.
- **Source URL** - provide the strongest relevant source supporting the finding.

Organize the final results into:

1. **High Impact**
2. **Medium Impact**
3. **Low Impact**

Within each impact level, order findings from highest to lowest consensus.

Research broadly across authoritative and high-quality sources. Prefer primary and authoritative sources when they adequately support a finding, while also using high-quality practitioner sources where they provide material guidance not covered by primary documentation.

Potential source types include:

- ECMAScript specifications and proposals
- MDN Web Docs
- TC39 documentation and discussions
- browser and runtime documentation
- guidance from JavaScript engine, runtime, and standards contributors
- established engineering documentation
- respected JavaScript experts and practitioners
- technically rigorous articles and discussions

Do not treat popularity, repetition, or search ranking alone as evidence of correctness or consensus.

Evaluate **Impact** and **Consensus** independently. A finding may have high impact but low consensus, or low impact but high consensus.

Include disputed practices when they are materially relevant, but assign an appropriate Consensus rating and accurately describe the disagreement rather than presenting one side as settled guidance.

Avoid duplicate findings that describe the same underlying issue. Merge substantially equivalent recommendations while preserving genuinely different cases, conditions, or failure modes.

Focus on guidance specific to **vanilla JavaScript**, including the language itself and standard platform APIs. Do not fill the results with framework-specific, library-specific, build-tool-specific, or TypeScript-specific advice unless it exposes a JavaScript behavior that remains materially relevant without those tools.

Do not fill the results with generic programming advice unless JavaScript introduces a distinct consideration.

Do not stop after finding a conventional "top JavaScript best practices" list. Use iterative discovery to identify additional terminology, failure modes, recommendations, and sources from the findings themselves.

Continue researching until further searching is producing primarily duplicates, minor stylistic preferences, weakly supported claims, or findings with little practical significance.
:::

-----
#### User said:

Give me that prompt but adapted for python

-----
#### Assistant said:

:::writing{variant="document" id="58317" title="Python Pitfalls and Preferred Idioms Research Prompt"}
Research as comprehensively as practical for Python-specific **pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms**, especially cases where experienced Python developers recommend **"do this instead of that."**

The goal is to identify as many distinct, materially useful Python practices as possible, not just the most popular or obvious examples.

Research across the full Python language, runtime behavior, standard library, packaging and environment behavior where materially relevant, standard development practices, and ecosystem conventions that broadly affect Python development.

**Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.**

Actively look for unexpected or less obvious classes of issues that may not fit common Python best-practice lists.

For every finding, provide exactly:

```text
Name:
Category:
Impact:
Consensus:
Description:
Why:
Source URL:
```

Use the fields as follows:

- **Name** - concise name for the pattern, pitfall, or recommendation.
- **Category** - a technical category derived from the findings during research. Do not force findings into a predefined category set.
- **Impact** - High, Medium, or Low based on how materially the issue can affect correctness, reliability, maintainability, security, performance, or development outcomes.
- **Consensus** - High, Medium, or Low based on how broadly the recommendation is supported by authoritative sources and experienced Python practitioners.
- **Description** - explain the issue or recommendation, including the problematic approach and preferred alternative where applicable.
- **Why** - explain why the preferred approach matters and what problems it prevents or improves.
- **Source URL** - provide the strongest relevant source supporting the finding.

Organize the final results into:

1. **High Impact**
2. **Medium Impact**
3. **Low Impact**

Within each impact level, order findings from highest to lowest consensus.

Research broadly across authoritative and high-quality sources. Prefer primary and authoritative sources when they adequately support a finding, while also using high-quality practitioner sources where they provide material guidance not covered by primary documentation.

Potential source types include:

- official Python documentation
- Python language and standard library documentation
- Python Enhancement Proposals (PEPs)
- Python developer and core contributor documentation
- guidance from Python core developers and maintainers
- established engineering documentation
- respected Python experts and practitioners
- technically rigorous articles and discussions

Do not treat popularity, repetition, or search ranking alone as evidence of correctness or consensus.

Evaluate **Impact** and **Consensus** independently. A finding may have high impact but low consensus, or low impact but high consensus.

Include disputed practices when they are materially relevant, but assign an appropriate Consensus rating and accurately describe the disagreement rather than presenting one side as settled guidance.

Avoid duplicate findings that describe the same underlying issue. Merge substantially equivalent recommendations while preserving genuinely different cases, conditions, or failure modes.

Focus on guidance specific to **Python**, including the language itself, runtime behavior, standard library, and broadly applicable Python development practices. Do not fill the results with framework-specific or library-specific advice unless it exposes an underlying Python behavior or practice that remains materially relevant outside that framework or library.

Do not fill the results with generic programming advice unless Python introduces a distinct consideration.

Do not stop after finding a conventional "top Python best practices" list. Use iterative discovery to identify additional terminology, failure modes, recommendations, and sources from the findings themselves.

Continue researching until further searching is producing primarily duplicates, minor stylistic preferences, weakly supported claims, or findings with little practical significance.
:::

-----
#### User said:

Give me that prompt but adapted for bash

-----
#### Assistant said:

:::writing{variant="document" id="58318" title="Bash Pitfalls and Preferred Idioms Research Prompt"}
Research as comprehensively as practical for Bash-specific **pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms**, especially cases where experienced shell developers recommend **"do this instead of that."**

The goal is to identify as many distinct, materially useful Bash practices as possible, not just the most popular or obvious examples.

Research across the full Bash language, shell expansion and evaluation behavior, builtins, process and pipeline semantics, interaction with Unix/POSIX utilities, scripting practices, and environment behavior that materially affect Bash programs.

**Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.**

Actively look for unexpected or less obvious classes of issues that may not fit common Bash best-practice lists.

For every finding, provide exactly:

```text
Name:
Category:
Impact:
Consensus:
Description:
Why:
Source URL:
```

Use the fields as follows:

- **Name** - concise name for the pattern, pitfall, or recommendation.
- **Category** - a technical category derived from the findings during research. Do not force findings into a predefined category set.
- **Impact** - High, Medium, or Low based on how materially the issue can affect correctness, reliability, maintainability, security, portability, data integrity, or development outcomes.
- **Consensus** - High, Medium, or Low based on how broadly the recommendation is supported by authoritative sources and experienced Bash and shell practitioners.
- **Description** - explain the issue or recommendation, including the problematic approach and preferred alternative where applicable.
- **Why** - explain why the preferred approach matters and what problems it prevents or improves.
- **Source URL** - provide the strongest relevant source supporting the finding.

Organize the final results into:

1. **High Impact**
2. **Medium Impact**
3. **Low Impact**

Within each impact level, order findings from highest to lowest consensus.

Research broadly across authoritative and high-quality sources. Prefer primary and authoritative sources when they adequately support a finding, while also using high-quality practitioner sources where they provide material guidance not covered by primary documentation.

Potential source types include:

- GNU Bash documentation and manual
- POSIX shell specifications where relevant to Bash behavior or portability
- Bash source, release notes, and maintainer documentation
- ShellCheck documentation and rationale
- guidance from Bash, shell, and Unix experts
- established engineering documentation
- technically rigorous articles and discussions

Do not treat popularity, repetition, lint warnings, or search ranking alone as evidence of correctness or consensus. Investigate the underlying technical reason for each recommendation.

Evaluate **Impact** and **Consensus** independently. A finding may have high impact but low consensus, or low impact but high consensus.

Include disputed practices when they are materially relevant, but assign an appropriate Consensus rating and accurately describe the disagreement rather than presenting one side as settled guidance.

Avoid duplicate findings that describe the same underlying issue. Merge substantially equivalent recommendations while preserving genuinely different cases, conditions, or failure modes.

Focus on guidance specific to **Bash**, including language semantics, expansion behavior, quoting, command execution, pipelines, subshells, processes, exit status handling, filesystem interaction, and broadly applicable shell scripting practices. Include POSIX portability concerns when they materially affect how Bash code should be written, but distinguish portability recommendations from Bash-specific correctness recommendations.

Do not fill the results with generic programming or Unix advice unless Bash introduces a distinct consideration.

Do not stop after finding a conventional "Bash best practices" or "strict mode" list. Treat commonly repeated shell advice as a starting point to investigate, not as automatically correct guidance.

Use iterative discovery to identify additional terminology, failure modes, recommendations, and sources from the findings themselves.

Continue researching until further searching is producing primarily duplicates, minor stylistic preferences, weakly supported claims, or findings with little practical significance.
:::

-----
#### User said:

Give me that prompt but adapted for go

-----
#### Assistant said:

:::writing{variant="document" id="58319" title="Go Pitfalls and Preferred Idioms Research Prompt"}
Research as comprehensively as practical for Go-specific **pitfalls, gotchas, footguns, anti-patterns, correctness hazards, and preferred idioms**, especially cases where experienced Go developers recommend **"do this instead of that."**

The goal is to identify as many distinct, materially useful Go practices as possible, not just the most popular or obvious examples.

Research across the full Go language, type system, runtime behavior, standard library, concurrency model, memory behavior where relevant, tooling, module/package behavior, standard development practices, and ecosystem conventions that broadly affect Go development.

**Do not use a predetermined taxonomy as the search space. Derive categories from the findings after discovery rather than using categories to constrain discovery.**

Actively look for unexpected or less obvious classes of issues that may not fit common Go best-practice lists.

For every finding, provide exactly:

```text
Name:
Category:
Impact:
Consensus:
Description:
Why:
Source URL:
```

Use the fields as follows:

- **Name** - concise name for the pattern, pitfall, or recommendation.
- **Category** - a technical category derived from the findings during research. Do not force findings into a predefined category set.
- **Impact** - High, Medium, or Low based on how materially the issue can affect correctness, reliability, maintainability, security, performance, resource usage, concurrency safety, or development outcomes.
- **Consensus** - High, Medium, or Low based on how broadly the recommendation is supported by authoritative sources and experienced Go practitioners.
- **Description** - explain the issue or recommendation, including the problematic approach and preferred alternative where applicable.
- **Why** - explain why the preferred approach matters and what problems it prevents or improves.
- **Source URL** - provide the strongest relevant source supporting the finding.

Organize the final results into:

1. **High Impact**
2. **Medium Impact**
3. **Low Impact**

Within each impact level, order findings from highest to lowest consensus.

Research broadly across authoritative and high-quality sources. Prefer primary and authoritative sources when they adequately support a finding, while also using high-quality practitioner sources where they provide material guidance not covered by primary documentation.

Potential source types include:

- official Go documentation
- the Go specification
- Effective Go
- Go blog and official Go team guidance
- Go release notes and proposals
- standard library documentation
- Go tooling documentation
- guidance from Go maintainers and contributors
- established engineering documentation
- respected Go experts and practitioners
- technically rigorous articles and discussions

Do not treat popularity, repetition, lint warnings, or search ranking alone as evidence of correctness or consensus. Investigate the underlying technical reason for each recommendation.

Evaluate **Impact** and **Consensus** independently. A finding may have high impact but low consensus, or low impact but high consensus.

Include disputed practices when they are materially relevant, but assign an appropriate Consensus rating and accurately describe the disagreement rather than presenting one side as settled guidance.

Avoid duplicate findings that describe the same underlying issue. Merge substantially equivalent recommendations while preserving genuinely different cases, conditions, or failure modes.

Focus on guidance specific to **Go**, including language semantics, interfaces, generics, error handling, concurrency, goroutines, channels, synchronization, context propagation, resource management, memory allocation, slices, maps, pointers, packages, modules, APIs, testing, and tooling when those topics emerge from the research.

Do not treat those examples as a predetermined taxonomy or checklist. They are illustrative only. Discovery should remain open-ended and evidence-driven.

Do not fill the results with generic programming advice unless Go introduces a distinct consideration.

Do not stop after finding a conventional "Go best practices" or "Effective Go" list. Treat commonly repeated guidance as a starting point to investigate, not as automatically correct or complete.

Use iterative discovery to identify additional terminology, failure modes, recommendations, and sources from the findings themselves.

Continue researching until further searching is producing primarily duplicates, minor stylistic preferences, weakly supported claims, or findings with little practical significance.
:::

-----
#### User said:

Now I need a prompt telling it to write a single rule to enforce each thing that it found

-----
#### Assistant said:

:::writing{variant="document" id="58320" title="Convert Research Findings Into Enforceable Rules"}
Using the research findings, write **one single enforceable rule for each finding**.

The goal is to convert every identified pitfall, gotcha, footgun, anti-pattern, correctness hazard, or preferred idiom into a concise rule suitable for an AI coding agent.

For each finding:

- Produce exactly **one rule**.
- Preserve the finding's technical intent, conditions, and exceptions.
- State the preferred behavior directly.
- Include prohibited behavior when needed for clarity.
- Make the rule specific, actionable, and reviewable.
- Prefer objective requirements over vague advice.
- Do not add rationale, examples, or implementation guidance unless necessary for correctness.
- Do not make the rule stricter than the evidence supports.
- Do not combine multiple findings or split one finding into multiple rules.
- Do not invent requirements unsupported by the finding.
- Avoid vague wording such as "use best practices," "be careful," or "write idiomatic code."

Use normative language consistently:

- `MUST` for required behavior.
- `MUST NOT` for prohibited behavior.
- `SHOULD` / `SHOULD NOT` for strong preferences with legitimate exceptions.
- `MAY` only when an explicitly permitted alternative matters.

Choose the strength of the rule from the finding's **Impact**, **Consensus**, evidence, and exceptions. Do not automatically turn every finding into `MUST` or `MUST NOT`.

For every finding, output exactly:

```text
Name:
Rule:
```

`Name` must preserve the original finding name for traceability.

`Rule` must contain the single resulting rule.

Process **every finding**, including low-impact, low-consensus, conditional, and stylistic findings. Use weaker normative language where strict requirements are not justified.

Avoid duplicate rules, but do not broaden a rule beyond what its original finding supports.
:::
