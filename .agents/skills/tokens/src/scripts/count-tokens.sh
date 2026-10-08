#!/usr/bin/env bash
set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$skill_dir/src/scripts/discover-tiktoken-cli.sh"

usage() {
  printf '%s\n' 'Usage: count-tokens.sh --model MODEL [PATH ...]'
  printf '%s\n' ''
  printf '%s\n' 'Count file paths recursively, multiple paths, or stdin when no paths are given.'
  printf '%s\n' 'Specify the model selected by the calling skill.'
}

requested_model=""
while (($#)); do
  case "$1" in
    -m|--model)
      (($# >= 2)) || { echo "Missing model name." >&2; exit 2; }
      requested_model="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

if [[ -z "$requested_model" ]]; then
  echo "A model is required." >&2
  usage >&2
  exit 2
fi

model_map="$skill_dir/src/model-to-encoding.tsv"
if [[ ! -f "$model_map" ]]; then
  echo "No model map is available. Run: bash $skill_dir/src/update" >&2
  exit 1
fi

counter_model="$requested_model"
encoding="$(awk -F '\t' -v model="$counter_model" '$1 == model { print $2; exit }' "$model_map")"
if [[ -z "$encoding" ]]; then
  if [[ "$requested_model" =~ ^(gpt-[0-9]+|o[0-9]+)([.-].*)?$ ]]; then
    counter_model="${BASH_REMATCH[1]}"
    encoding="$(awk -F '\t' -v model="$counter_model" '$1 == model { print $2; exit }' "$model_map")"
  fi
  if [[ -z "$encoding" ]]; then
    echo "Unsupported model: $requested_model" >&2
    echo "Run /tokens update to refresh the local model map." >&2
    exit 2
  fi
fi

cli="$(find_tiktoken_cli || true)"
if [[ -z "$cli" ]]; then
  echo "Unable to find tiktoken-cli with command -v, which, or npm prefix -g." >&2
  exit 127
fi

printf 'running model: %s\ncounter model: %s\nencoding: %s\n' "$requested_model" "$counter_model" "$encoding"
"$cli" --model "$counter_model" "$@"
