# Skills CLI grouped install selection

## Purpose

Use this reference when publishing a repository for interactive installation with `npx skills@latest add <source>` and deciding whether the skill picker should show named sections.

This records behavior verified in `skills@1.5.22`. Recheck the installed CLI source after upgrading because grouping is CLI behavior, not part of the base `SKILL.md` format.

## What creates sections

The CLI discovers valid skills independently. Each discovered `SKILL.md` needs string `name` and `description` frontmatter. Its directory and frontmatter tags do not create picker sections.

A discovered skill is assigned to a named section only when its directory is listed in one of these Claude plugin manifests:

- `.claude-plugin/plugin.json`: creates one group from its `name` and `skills` fields.
- `.claude-plugin/marketplace.json`: creates a group for each entry in `plugins[]` that has a `name` and `skills` fields. Use this when the repository needs multiple named groups.

The picker title is derived from the plugin `name`; it title-cases hyphen-separated names. For example, `team-engineering-skills` appears as `Team Engineering Skills`.

## One primary section with Other

Use `.claude-plugin/plugin.json` when one selected subset should be presented as the primary collection:

```json
{
  "name": "team-engineering-skills",
  "skills": [
    "./skills/review-code",
    "./skills/release-check"
  ]
}
```

Every valid discovered skill whose directory is not in that list is automatically assigned to `Other`. `Other` is a CLI-generated fallback, not a configurable group or manifest field.

Use this pattern only when the listed subset is genuinely the collection users should normally select together. Leaving a skill out controls picker placement, not whether it is discoverable or installable.

## Multiple named sections

Use `.claude-plugin/marketplace.json` when several distinct collections need explicit names. Each plugin entry can name and list its own skills. The CLI associates a listed path with that entry's `name`; unlisted discovered skills remain `Other`.

Do not use category directories, tags, or descriptions as a substitute for this manifest. The CLI does not group by them.

## No plugin manifest

If the repository has neither manifest, or neither manifest assigns any discovered skill:

- Skills in standard discovery locations are still found, including `skills/`, `.agents/skills/`, and `.claude/skills/`.
- The interactive selector is a single flat alphabetical list.
- No `Other` section appears.

This is the right setup when all skills are peers and a primary collection would imply a distinction that the repository does not intend.

## Pre-publish check

Before publishing or changing grouping, run:

```sh
npx skills@latest add <owner>/<repository> --list
npx skills@latest add <owner>/<repository>
```

Confirm that every intended skill is discovered, each manifest path points to the skill directory rather than the `SKILL.md` file, group names communicate the intended collection, and intentionally secondary skills appear under `Other`.

## Scope boundary

These manifests affect the `skills` CLI's discovery additions and interactive presentation. They do not change how coding agents interpret a skill after installation. A repository can expose ordinary Agent Skills without either manifest.
