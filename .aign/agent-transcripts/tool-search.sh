#!/usr/bin/env bash

set -euo pipefail

SESSIONS_DIR="/home/scott/.codex/sessions"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${1:-$SCRIPT_DIR/tool_log.log}"

command -v jq >/dev/null 2>&1 || {
  printf 'Error: jq is required.\n' >&2
  exit 2
}

[[ -d "$SESSIONS_DIR" ]] || {
  printf 'Error: session directory not found: %s\n' "$SESSIONS_DIR" >&2
  exit 2
}

TEMP_FILE="$(mktemp "${OUTPUT_FILE}.XXXXXX")"
trap 'rm -f "$TEMP_FILE"' EXIT

while IFS= read -r -d '' session_file; do
  jq -Rsc --arg session_file "$session_file" '
    def text:
      if . == null then ""
      elif type == "string" then .
      elif type == "array" then
        map(
          if type == "object" then (.text // .output // .content // tostring)
          else tostring
          end
        ) | join("\n")
      else tostring
      end;

    split("\n")
    | map(fromjson? | select(.type == "response_item"))
    | reduce .[] as $event (
        {calls: {}, records: []};
        $event.payload as $payload
        | if $payload.type == "custom_tool_call" or $payload.type == "function_call" then
            ($payload.call_id // $payload.id // "") as $call_id
            | ($payload.name // "") as $tool
            | .calls[$call_id] = $tool
            | .records += [
                {
                  timestamp: ($event.timestamp // ""),
                  session_file: $session_file,
                  record: "call",
                  tool: $tool,
                  call_id: $call_id,
                  status: ($payload.status // ""),
                  arguments: ($payload.input // $payload.arguments // "" | text)
                }
              ]
          elif $payload.type == "custom_tool_call_output" or $payload.type == "function_call_output" then
            ($payload.call_id // $payload.id // "") as $call_id
            | .records += [
                {
                  timestamp: ($event.timestamp // ""),
                  session_file: $session_file,
                  record: "output",
                  tool: ($payload.name // .calls[$call_id] // ""),
                  call_id: $call_id,
                  status: ($payload.status // ""),
                  output: ($payload.output // $payload.content // "" | text)
                }
              ]
          else
            .
          end
      )
    | .records[]
  ' "$session_file" >>"$TEMP_FILE"
done < <(find "$SESSIONS_DIR" -type f -name '*.jsonl' -print0)

mv "$TEMP_FILE" "$OUTPUT_FILE"
trap - EXIT

printf 'Wrote %s tool records to %s\n' "$(wc -l < "$OUTPUT_FILE")" "$OUTPUT_FILE"
