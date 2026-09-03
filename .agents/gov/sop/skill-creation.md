# Skill Creation

## Purpose Record

Every skill `MUST` include a `purpose.md` file with a `# Purpose` heading.

The file is a detailed, plain-language record that helps someone recreate the skill in the future.
It is not a binding contract, a change-control mechanism, or a specification for maintenance.

Keep the record simple, but include enough context to explain:

- what the skill is for;
- why it was created or the problem it addresses;
- who uses or benefits from it;
- the result it should provide; and
- material context or boundaries that would matter when recreating it.

Use the structure that makes the purpose clearest. A fixed template is not required.
Keep current procedures, tools, and implementation details in `SKILL.md` and supporting files unless they are needed to explain the purpose.

Create `purpose.md` from the direct request, goal, and design context.
If the available context is incomplete, state the uncertainty rather than inventing a reason for the skill.
Update the record when it no longer accurately explains the skill.

## Authoring

### Scope

Apply this when creating or modifying a skill.

When creating a skill, authors `MUST` write `purpose.md` from the direct request, goal, and material design context.
Write it before or alongside `SKILL.md`.

When recreating a skill, use its `purpose.md` to understand the original role and context.
When the skill changes enough that the record is no longer accurate, update `purpose.md` to match.

### Metadata and Invocation

- Default new skills to `disable-model-invocation: true` unless requirements explicitly state otherwise or implicit model invocation is inherently required.
- Include `agents/openai.yaml` in every skill.
- When `SKILL.md` contains `disable-model-invocation: true`, set `policy.allow_implicit_invocation: false` in `agents/openai.yaml`.
- Make `agents/openai.yaml` the closest supported OpenAI equivalent of the behavior and metadata in `SKILL.md` frontmatter.
- Keep frontmatter under approximately 100 tokens when practical. Put operational detail in the body.
- Frontmatter field `description` should not be a description but rather an instruction on when to use the skill. A `Use when...`, `Use for...`, etc. statement

### Portability and Resources

- Make skills portable across supported agents and runtimes.
- Use skill-root-relative paths for bundled files such as `scripts/foo.py` and `src/bar.md`.
- Do not rely on agent-specific invocation syntax, filesystem locations, frontmatter fields, tool names, or permission semantics unless explicitly required.
- Prefer Agent Skills standard behavior and the closest runtime-specific equivalent where needed.
- Do not make portable skill behavior depend on tool permissions unless that compatibility requirement is explicitly declared.

## Directory Layout

```text
.agents/skills/skill-name/
├── agents/
│   └── openai.yaml
├── purpose.md
├── ref/                         (optional, when reference material is needed)
│   └── ...non-skill-owned reference material...
├── tests/                       (optional, when tests are needed)
│   └── ...tests...
└── SKILL.md
```

`ref/` and `tests/` are optional.
Do not create them unless the skill needs the material they hold.
When reference material or tests are needed, use these directories rather than placing that content elsewhere in the skill.

### Directory Roles

- `SKILL.md`: Canonical skill entry point and primary instructions.
- `agents/`: Runtime-specific metadata and configuration.
- `purpose.md`: Detailed, plain-language record used to help recreate the skill in the future. It is not a binding contract.
- `ref/`: Optional. Use when non-skill-owned reference material is needed for development, documentation, validation, or maintenance. This may include upstream documentation, example files, reference implementations, external schemas, specifications, or other source material. Content under `ref/` should not be required as part of the skill's runtime implementation.
- `tests/`: Optional. Use when tests are needed for skill behavior, implementation, schemas, executable helpers, or related components.

### Runtime State

Skills that need to store runtime state must use one of these directories:

1. Use `.agents/state/<skill-name>` as the primary state directory.
2. If the primary directory is not writable, use `.state/<skill-name>` instead.

Do not use the secondary directory when the primary directory is writable.
