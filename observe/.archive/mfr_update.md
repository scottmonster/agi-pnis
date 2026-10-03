**Status: Strictly non-authoritative reference material.**

This document is informational only. It creates no requirements, specifications, decisions, policies, obligations, approvals, interpretations, or binding guidance of any kind. Do not treat any part of it as controlling, implied, or actionable unless an authoritative source explicitly adopts the specific content at issue. In any conflict or ambiguity, authoritative sources control without exception.


I just started using this system, so there is not much accumulated data yet. The broader goal is to preserve meaningful decisions made throughout a repository's history, especially decisions made by agents. I expect to use this across most of my projects.

The immediate purpose is documentation and review, but the longer-term goal is to collect these decision records into a central corpus that I can analyze across projects.

I want the preserved decisions to support several kinds of analysis:

1. Analyze the decisions I make.
2. Analyze the decisions agents make.
3. Measure alignment between them, including where agent judgment consistently matches or diverges from mine.
4. Use the accumulated records as a source for creating explicit guidance about how I want agents to make decisions.

Eventually, this could become a more deliberate workflow. When an agent encounters a decision I have not previously addressed, it could surface the question for me. My answer could then become another durable decision record and potentially new guidance for future agents.

The important point is that I do not want decision records to contain only the final decision. I want enough surrounding information to understand and analyze the decision at multiple levels.

For example, I want to understand:

* what judgment was exercised;
* what decision was made;
* the context in which it was made;
* the reasoning and relevant constraints;
* the scope of the decision;
* whether it was local to a particular implementation detail or reflected a broader project-level principle;
* how it relates to other decisions and established project direction.

That is why I have been trying to preserve things such as judgment, decisions, context, rationale, constraints, and scope. The goal is not merely to create an audit trail. It is to build a structured body of decision-making evidence that can later be reviewed, compared, generalized, conceptualized, and used to improve agent alignment.





Research, as defined in research.md, how to design a durable record of material judgments, meaningful decisions, key resolutions, and important determinations made by humans and AI agents, in support of the stated goal.

The system will be used across many repositories. Its immediate purpose is documentation and review, but its longer-term purpose is to build a central corpus of meaningful human and agent judgment that can be analyzed across projects.

A material judgment is a settled, non-obvious exercise of discretion that governs future work. It may result in a decision, but it can also be an interpretation, bounded assumption, trade-off, conflict resolution, scope boundary, or intentional departure from prior direction.

The system should preserve the judgment itself, its resulting direction where applicable, and enough surrounding evidence to understand how and why the judgment was exercised.

We want the records to support:

1. Reviewing material judgment throughout a repository’s history.
2. Analyzing the judgment exercised by a human project owner.
3. Analyzing the judgment exercised by agents.
4. Comparing human and agent judgment, including recurring agreement, divergence, correction, delegation, and escalation patterns.
5. Deriving explicit future guidance for agents from accumulated judgment evidence.
6. Supporting a workflow where an agent can surface a material unresolved judgment for the project owner, and the answer can become durable guidance.

The records must preserve more than a final decision or outcome. They should retain enough surrounding information to later understand and analyze:

- what required judgment;
- what was decided, interpreted, assumed, traded off, resolved, or intentionally changed;
- the context, objectives, success criteria, and constraints;
- relevant requirements, evidence, observations, assumptions, uncertainty, and alternatives;
- the reasoning and trade-offs;
- the scope, authority, applicability boundary, and intended force of the result;
- how the judgment relates to prior judgments, established project direction, implementation artifacts, and later revisions;
- the respective roles of the human and the agent in identifying, proposing, evaluating, settling, recording, or revisiting the judgment.

We are deliberately uncertain about how much information should be saved, which information should be structured versus narrative, what should remain optional, and what should be captured only for material judgments. Do not assume an existing record template, storage format, workflow, or implementation is correct. Begin from the goals above.

Research relevant established practices and adjacent models, such as architecture decision records, decision logs, judgment and rationale capture, provenance and lineage systems, human-AI collaboration records, auditability, knowledge-management systems, and datasets used to study reasoning or decision-making. Prefer primary sources, well-established standards, and concrete operational examples where available.

Produce a recommendation that includes:

- a definition and qualification threshold for a material judgment record;
- how to distinguish settled material judgments from open questions, observations, recommendations, routine implementation choices, execution logs, and validation results;
- the minimum viable record model;
- optional fields or sections justified by specific review or analysis needs;
- how to preserve human and agent contributions without falsely attributing authority or representing an agent inference as a human judgment;
- how to distinguish a judgment from its resulting decision, implementation, and outcome;
- identity, provenance, versioning, cross-repository aggregation, relationships between records, supersession, and later review;
- what should remain immutable historical evidence versus what can be corrected, appended, or reconsidered later;
- privacy, security, retention, and sensitive-context considerations;
- workflow recommendations for autonomous and collaborative agents, including how agents should surface unresolved material judgments;
- trade-offs between capture burden, completeness, consistency, and later analytical value;
- a proposed schema or template, with a short example;
- a staged adoption plan suitable for a system with very little accumulated data.

Separate findings supported by sources from your own recommendations. State uncertainty clearly. Avoid prescribing complexity that is not justified by the stated goals.

I am trying to build a durable, structured body of evidence about meaningful decisions made throughout my repositories, especially decisions involving agents. My goal is to preserve enough of each decision episode to understand not only what was decided, but what judgment was exercised, who exercised it, the context and constraints that shaped it, its rationale and scope, and how it relates to established project direction.

I want to use these records for documentation and review now, and eventually as a cross-project corpus for analyzing my decisions, agent decisions, and the degree to which agent judgment aligns with or diverges from mine. The accumulated evidence should also support deriving explicit guidance for future agents and, eventually, a workflow in which genuinely unresolved decisions can be surfaced to me and my answers preserved as durable decisions or guidance.

The records should retain enough original context and qualification to support later generalization and conceptual analysis without overstating local decisions as universal rules. In particular, distinctions between source-specific decisions, broader principles, authority, scope, conditions, exceptions, and related project direction need to remain recoverable. The result should be useful as structured decision-making evidence, not merely as an audit trail or collection of final outcomes.

