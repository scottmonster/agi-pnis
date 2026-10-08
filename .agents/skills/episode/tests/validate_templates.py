#!/usr/bin/env python3
"""Validate the episode skill's source documents and routing invariants."""

from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError as error:
    raise SystemExit("PyYAML is required to validate YAML examples.") from error


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
SOURCE_FILES = (
    "episode.md",
    "schema.md",
    "judgement-record.md",
    "failure-record.md",
    "failures.md",
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def yaml_blocks(path: Path) -> list[str]:
    return re.findall(r"```yaml\n(.*?)```", path.read_text(encoding="utf-8"), re.DOTALL)


def validate_yaml() -> None:
    count = 0
    for name in SOURCE_FILES:
        path = SRC / name
        require(path.is_file(), f"missing source file: src/{name}")
        for index, block in enumerate(yaml_blocks(path), start=1):
            count += 1
            try:
                yaml.safe_load(block)
            except yaml.YAMLError as error:
                raise AssertionError(f"{path.name} YAML block {index} is invalid: {error}") from error
    require(count > 0, "source standards have no YAML blocks to validate")


def validate_source_links() -> None:
    for path in SRC.glob("*.md"):
        for target in re.findall(r"\]\(([^)#]+\.md)\)", path.read_text(encoding="utf-8")):
            require((SRC / target).is_file(), f"{path.name} links to missing src/{target}")


def validate_templates() -> None:
    judgement = (SRC / "judgement-record.md").read_text(encoding="utf-8")
    failure = (SRC / "failure-record.md").read_text(encoding="utf-8")
    catalog = (SRC / "failures.md").read_text(encoding="utf-8")
    schema = (SRC / "schema.md").read_text(encoding="utf-8")

    jur_fields = (
        "kind: <only when changed>",
        "trigger: <user | agent>",
        "activity: <user | agent>",
        "statement: <only when changed>",
        "basis: <only material update information>",
        "scope: <only when changed>",
        "rationale: <only when changed>",
        "revisit_triggers: <only when changed>",
    )
    fur_fields = (
        "failure_ids: <only when classification changes>",
        "trigger: <only when changed>",
        "detected_at: <only when changed>",
        "expectation: <only when changed>",
        "observed: <only when changed>",
        "level: <only when changed>",
        "description: <only when changed>",
        "affected_scope: <only when changed>",
        "statement: <only when changed>",
        "status: <only when changed>",
        "causal_status: <only when changed>",
        "evidence: <only when changed>",
        "limitations: <only when changed>",
        "target: <only when changed>",
        "validation: <only when changed or performed>",
    )

    for field in jur_fields:
        require(field in judgement, f"JUR template lacks delta field: {field}")
    for field in fur_fields:
        require(field in failure, f"FUR template lacks delta field: {field}")

    for field in (
        'index: "<next three-digit root index>"',
        'index: "<originating root index>.<next two-digit update index>"',
        "rule: <reusable instruction that prevents the pattern>",
    ):
        require(field in judgement, f"judgement template lacks required field: {field}")

    for field in (
        'index: "<next three-digit root index>"',
        'index: "<originating root index>.<next two-digit update index>"',
        "rule: <reusable instruction that prevents the pattern>",
        "rule: <only when changed or newly established>",
    ):
        require(field in failure, f"failure template lacks required field: {field}")

    require("Use `<index>-<record_type>-<slug>.md` as the filename." in schema, "schema lacks indexed filename rule")
    require("Every new Corrective Action includes `rule`." in schema, "schema lacks required corrective-action rule")

    for row in (
        "| User-triggered | User-activity | Not a violation | Not required |",
        "| User-triggered | Agent-activity | Concern | Required |",
        "| Agent-triggered | Any activity | Violation | Required |",
    ):
        require(row in judgement, f"JUR status matrix lacks required path: {row}")

    require("Record data in `failure.classification_data`" in catalog, "catalog lacks Record data mapping")
    require("Investigation data in named entries in `investigation.findings`" in catalog, "catalog lacks Investigation data mapping")


def validate_record_paths() -> None:
    def jur_status(previous_trigger: str, current_activity: str) -> tuple[str, bool]:
        if previous_trigger == "user" and current_activity == "user":
            return "not_a_violation", False
        if previous_trigger == "user" and current_activity == "agent":
            return "concern", True
        return "violation", True

    expected = {
        ("user", "user"): ("not_a_violation", False),
        ("user", "agent"): ("concern", True),
        ("agent", "user"): ("violation", True),
        ("agent", "agent"): ("violation", True),
    }
    for route, result in expected.items():
        require(jur_status(*route) == result, f"incorrect JUR route: {route}")

    failure = (SRC / "failure-record.md").read_text(encoding="utf-8")
    require("Create an FR for a detected failure" in failure, "FR creation path is missing")
    require("Create an FUR when later material information changes" in failure, "FUR update path is missing")


def validate_existing_failure_indexes() -> None:
    records = ROOT.parents[1] / "records" / "failures"
    if not records.is_dir():
        return

    root_pattern = re.compile(r"^(?P<root>\d{3})-FR-[a-z0-9-]+\.md$")
    update_pattern = re.compile(r"^(?P<root>\d{3})\.(?P<update>\d{2})-FUR-[a-z0-9-]+\.md$")
    roots: set[str] = set()
    updates: set[tuple[str, str]] = set()

    for path in records.glob("*.md"):
        root_match = root_pattern.match(path.name)
        update_match = update_pattern.match(path.name)
        require(root_match or update_match, f"failure record has invalid indexed filename: {path.name}")
        if root_match:
            root = root_match.group("root")
            require(root not in roots, f"duplicate failure root index: {root}")
            roots.add(root)
        else:
            assert update_match is not None
            key = (update_match.group("root"), update_match.group("update"))
            require(key not in updates, f"duplicate failure update index: {'.'.join(key)}")
            updates.add(key)

    root_numbers = sorted(int(root) for root in roots)
    require(root_numbers == list(range(1, len(root_numbers) + 1)), "FR root indexes are not sequential")

    update_numbers: dict[str, list[int]] = {}
    for root, update in updates:
        require(root in roots, f"FUR has no originating FR index: {root}")
        update_numbers.setdefault(root, []).append(int(update))
    for root, numbers in update_numbers.items():
        require(sorted(numbers) == list(range(len(numbers))), f"FUR update indexes are not sequential for FR {root}")


def validate_skill() -> None:
    skill = (ROOT / "SKILL.md").read_text(encoding="utf-8")
    frontmatter = re.match(r"^---\n(.*?)\n---", skill, re.DOTALL)
    require(frontmatter is not None, "SKILL.md lacks YAML frontmatter")
    metadata = yaml.safe_load(frontmatter.group(1))
    require(metadata["name"] == "episode", "SKILL.md name must be episode")
    require(metadata["description"].startswith("Use when"), "SKILL.md description must state when to use the skill")
    require("decision will guide later work" in metadata["description"], "SKILL.md description must state the plain-language decision trigger")
    require("Do not use for ordinary work" in metadata["description"], "SKILL.md description must exclude routine work")
    require(metadata.get("disable-model-invocation") is False, "SKILL.md must allow automatic invocation")
    for text in (
        "src/judgement-record.md",
        "src/failures.md",
        "src/failure-record.md",
        "src/episode.md",
        "src/schema.md",
        ".agents/records/judgements/",
        ".agents/records/failures/",
    ):
        require(text in skill, f"SKILL.md lacks required route or destination: {text}")

    purpose = (ROOT / "purpose.md").read_text(encoding="utf-8")
    require(purpose.startswith("# Purpose\n"), "purpose.md must begin with # Purpose")

    openai = yaml.safe_load((ROOT / "agents" / "openai.yaml").read_text(encoding="utf-8"))
    require(openai["interface"]["display_name"] == "Episode", "openai.yaml display name must be Episode")
    require(openai["interface"]["default_prompt"].startswith("Use $episode"), "openai.yaml default prompt must name $episode")
    require(openai["policy"]["allow_implicit_invocation"] is True, "openai.yaml must allow automatic invocation")

    nested = [path for path in ROOT.rglob("SKILL.md") if path != ROOT / "SKILL.md"]
    require(not nested, f"nested SKILL.md files are not allowed: {nested}")


def main() -> None:
    validate_yaml()
    validate_source_links()
    validate_templates()
    validate_record_paths()
    validate_existing_failure_indexes()
    validate_skill()
    print("episode skill validation passed")


if __name__ == "__main__":
    try:
        main()
    except AssertionError as error:
        print(f"episode skill validation failed: {error}", file=sys.stderr)
        raise SystemExit(1) from error
