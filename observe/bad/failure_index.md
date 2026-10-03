# Failure Index

**Status: Draft for discussion; non-authoritative.**

This is the short companion to `large_list.md`. Both documents use the same sections and family headings in the same order. This index states the broad failure family; the catalogue keeps the detailed patterns, evidence labels, and supporting context.

## 1. Agent-level preventable failures

### Intent, specification, and scope failures

Misunderstanding the request, omitting material requirements, adding unrequested behavior, or expanding the work beyond its justified scope.

### Repository and context-grounding failures

Acting without adequately locating, checking, or applying the repository-specific facts, conventions, dependencies, and context needed for the work.

### Speculative architecture and needless abstraction

Adding layers, configuration, extensibility, distribution, or optimization that the present problem does not justify.

### Reimplementing existing capabilities and dependency mistakes

Rebuilding an available platform capability or introducing a dependency where a simpler existing option would suffice.

### Structural bloat and maintainability failures

Producing code that is needlessly long, coupled, fragmented, duplicated, obscure, or difficult to change safely.

### Functional correctness and robustness failures

Producing code that is incomplete, incorrect, brittle, or unable to handle required inputs, states, and failures.

### Performance and resource inefficiency

Adding avoidable time, memory, I/O, network, token, or operational cost without a demonstrated need.

## 2. Tool-level preventable failures

### Dependency, package, build, and environment failures

Depending on unavailable, incompatible, fabricated, insecure, or poorly controlled packages, build settings, or execution environments.

## 3. Shared agent-and-tool preventable failures

### Testing and verification failures

Failing to create, run, interpret, or protect checks that materially establish whether the requested result works.

### Security and privacy failures

Introducing vulnerabilities, exposing secrets or sensitive data, or crossing a required safety or permission boundary.

### Change hygiene and integration failures

Making changes that are unnecessarily broad, incomplete across affected artifacts, difficult to review, or unsafe to merge and recover.

### Documentation, comments, configuration, and operability failures

Leaving misleading documentation, unsafe configuration, weak diagnostics, or operational gaps that prevent reliable use and review.

### Coding-agent workflow and interaction failures

Using tools, feedback, time, or autonomy poorly during the work, including failure to clarify, recover, verify, or communicate material limitations.

### Central meta-failures

General patterns of acting, abstracting, optimizing, configuring, distributing, or depending before the present evidence justifies it.

## 4. Task, authority, external, or unresolved conditions

Some episodes are driven by an underspecified task, unavailable authority, external outage, or insufficient evidence to identify a credible preventive action. These are recorded in the index so they are not misrepresented as detailed coding patterns.

## 5. Outcome and evaluation signals

Noncompletion, incorrect output, build or runtime failure, regression, inconsistency, nondeterminism, and failed or misleading validation describe what was observed. They are signals for analysis, not detailed failure-pattern families in the catalogue.

## 6. Use

Read the index for the broad family, then read the matching catalogue section for the concrete patterns and evidence. The grouping aids review and discussion; it does not establish root cause, fault, severity, or a required remedy.
