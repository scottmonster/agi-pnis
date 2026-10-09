# Governance Index

This file is the canonical map of active governance material in this directory. Each linked document defines its own scope and authority.

## Standards

1. [`standards/principles.md`](standards/principles.md)
   Purpose: Defines the framework for selecting adequate present solutions and justifying material complexity.
   Relation: Governs the engineering standards. They apply its decision, cost, and verification tests to specific concerns.

2. [`standards/design.md`](standards/design.md)
   Purpose: Defines how to organize a codebase for contained, understandable, and verifiable change by people and AI coding agents.
   Relation: Applies the principles framework to repository structure, module boundaries, code design, dependencies, documentation, and verification.

3. [`standards/testing.md`](standards/testing.md)
   Purpose: Defines when and how to test meaningful behavior without unnecessary test and maintenance cost.
   Relation: Applies the principles framework to verification and supports design, error-handling, and observability changes.

4. [`standards/error-handling.md`](standards/error-handling.md)
   Purpose: Defines ownership, contracts, recovery, diagnostics, and verification for meaningful failures.
   Relation: Applies the principles framework to failure behavior and supplies error-specific guidance for design, testing, and observability.

5. [`standards/observability.md`](standards/observability.md)
   Purpose: Defines how to produce safe, actionable signals for understanding, diagnosing, and operating meaningful behavior.
   Relation: Applies the principles framework to telemetry and complements error handling and testing without replacing either.

6. [`standards/security-and-privacy.md`](standards/security-and-privacy.md)
   Purpose: Defines baseline controls for trust boundaries, authorization, secrets, sensitive data, safe failure, dependencies, and security verification.
   Relation: Constrains engineering decisions unless an applicable authority explicitly allows otherwise.

## Standard operating procedures

1. [`sop/skill-creation.md`](sop/skill-creation.md)
   Purpose: Defines required purpose records, metadata, portable resources, directory layout, and runtime-state locations for skills.
   Relation: Implements the skill-design guidance when creating or modifying repository skills.

## Guides

1. [`guides/guidance-guide.md`](guides/guidance-guide.md)
   Purpose: Defines the role, boundaries, and appropriate use of guidance files.
   Relation: Provides the common model for the other guides.

2. [`guides/agents-md-scope-guide.md`](guides/agents-md-scope-guide.md)
   Purpose: Helps place agent instructions at the narrowest effective scope.
   Relation: Supports the rules guide by distinguishing repository instructions from narrower documentation.

3. [`guides/rules-guide.md`](guides/rules-guide.md)
   Purpose: Helps design scoped, reliable agent rules and identify constraints that need trusted enforcement.
   Relation: Applies the guidance model to persistent instructions and complements the AGENTS.md boundary guide.

4. [`guides/skills-guide.md`](guides/skills-guide.md)
   Purpose: Helps design reusable, focused, safe, testable, and portable agent skills.
   Relation: Guides the design of skills; the skill-creation procedure defines repository-specific requirements.

5. [`guides/deterministic-agents-guide.md`](guides/deterministic-agents-guide.md)
   Purpose: Helps design workflows that use deterministic controls for enforceable boundaries and agent judgment for bounded interpretive work.
   Relation: Complements the rules and skills guides by defining control, judgment, and assurance boundaries.

6. [`guides/agent-recovery-guide.md`](guides/agent-recovery-guide.md)
   Purpose: Helps agents recover safely when work stalls, fails repeatedly, diverges, or leaves the task state uncertain.
   Relation: Uses observability evidence to select, execute, and verify a recovery path.

7. [`guides/observability-guide.md`](guides/observability-guide.md)
   Purpose: Helps make consequential agent work diagnosable through sufficient, safe evidence.
   Relation: Complements the recovery guide by defining the information needed to understand a breakdown.

8. [`guides/research-guide.md`](guides/research-guide.md)
   Purpose: Helps find, evaluate, combine, and communicate evidence in proportion to the research question and stakes.
   Relation: Supports research tasks and preserves uncertainty, provenance, and claim-evidence fit.

9. [`guides/findings-guide.md`](guides/findings-guide.md)
   Purpose: Defines how to distinguish evidenced nonconformances from recommendations when inspecting files.
   Relation: Supports reviews against authoritative requirements and conventions.

10. [`guides/verbosity-guide.md`](guides/verbosity-guide.md)
    Purpose: Helps choose response depth based on the user's and task's explanatory needs.
    Relation: Applies to communication about work governed by this directory without changing the underlying requirements.

11. [`guides/reference.md`](guides/reference.md)
    Purpose: States that reference material is non-authoritative unless an authoritative source adopts it.
    Relation: Clarifies the status of informational material used alongside active governance.

12. [`review-patterns/how-to-review.md`](review-patterns/how-to-review.md)
    Purpose: Explains how to size a code review, use catalogs to identify review areas, selectively load rules and examples, verify findings, and handle failure records, judgement records, and prevention rules.
    Relation: Applies the findings guide and routes qualifying records to the episode skill. Review scope follows the changed behavior, affected scope, and potential impact.

## Review reference material

Load relevant sections for the review at hand. Do not include the entire library in routine context. A pattern match alone does not establish a violation; applicable requirements and evidence determine whether it is a finding.

1. [`review-patterns/`](review-patterns/)
   Purpose: Provides catalogs, concise rules, and examples for AI mistakes, design concepts, language pitfalls, and other review concerns.
   Relation: Supports the review guide. Use catalog headings and entries to identify review areas, matching rules to select checks, and individual examples when needed to assess applicability or exceptions.

2. [`review-patterns/.ops/catalog-family-spec.md`](review-patterns/.ops/catalog-family-spec.md)
   Purpose: Defines the shared structure, identifiers, and consistency requirements for catalogs, rules, and examples.
   Relation: Governs maintenance of review reference material; topic workflows under `.ops/workflows/` provide the corresponding build steps.

3. [`review-patterns/.ops/rule-authoring-guide.md`](review-patterns/.ops/rule-authoring-guide.md)
   Purpose: Helps decide whether a prevention rule is needed and choose its wording, scope, and loading behavior.
   Relation: Supports proposed prevention changes after review. Research sources provide supporting evidence; archived material is historical, not active instruction.

## Deferred work

1. **Dependencies and configuration standard**
   Purpose: Define selection, provenance, updates, validation, and safe use of packages, tools, environments, settings, and secrets.
   Relation: Constrains engineering and operations by preventing dependency, environment, configuration, and supply-chain failures.

2. **Compatibility and migration standard**
   Purpose: Define safe changes to public contracts, schemas, stored data, APIs, and user-visible behavior.
   Relation: Guides engineering, testing, releases, and reliability when existing users or data are affected.

3. **Release and operations standard**
   Purpose: Define build, deployment, rollback, and incident practices for deployable software.
   Relation: Uses testing before release and observability, debugging, and reliability practices after release.
   Condition: Create this when the repository needs to govern deployable software.

4. **Reliability standard**
   Purpose: Define availability, timeouts, capacity, degradation, idempotency, service objectives, and recovery beyond individual error behavior.
   Relation: Complements [error-handling.md](standards/error-handling.md) when those broader concerns have a demonstrated need.

5. **Structural references standard**
   Purpose: Define an exact code-location format for issues, reviews, and agent work.
   Relation: Supports engineering, debugging, and review work.
   Condition: Create this only when precise structural references are a repeated repository-wide need.

6. **Debugging guide**
   Purpose: Define a practical workflow to investigate, isolate, correct, and verify defects.
   Relation: Uses structural references, testing, error handling, and observability evidence.
   Location: Create it under [`guides/`](guides/), not as an engineering standard.

7. **Failure taxonomy and risk register**
   Purpose: Record researched failure families and risks that standards prevent, detect, or help recover from.
   Relation: Keep this as research material or a risk register, not as an engineering standard.
