#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$root/src/scripts/count-tokens.sh"

update_output="$(bash "$root/src/update")"
[[ "$update_output" == *"Updated $root/SKILL.md"* ]]
[[ -s "$root/src/model-to-encoding.tsv" ]]
rg -q '<!-- model-encodings:start -->' "$root/SKILL.md"
rg -q '| gpt-5 ' "$root/SKILL.md"

output="$(printf 'Hello, tokens!\n' | bash "$script" --model gpt-5)"
[[ "$output" == *"running model: gpt-5"* ]]
[[ "$output" == *"counter model: gpt-5"* ]]
[[ "$output" == *"encoding: o200k_base"* ]]
[[ "$output" == *"4  <stdin>"* ]]

fallback_output="$(printf 'Hello, tokens!\n' | bash "$script" --model gpt-5.6)"
[[ "$fallback_output" == *"running model: gpt-5.6"* ]]
[[ "$fallback_output" == *"counter model: gpt-5"* ]]
[[ "$fallback_output" == *"encoding: o200k_base"* ]]

if bash "$script" >/dev/null 2>&1; then
  echo "Missing model unexpectedly succeeded." >&2
  exit 1
fi

if bash "$script" --model not-a-model >/dev/null 2>&1; then
  echo "Unknown model unexpectedly succeeded." >&2
  exit 1
fi
