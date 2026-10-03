#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
INPUT_FILE="${1:-$SCRIPT_DIR/tool_log.log}"
OUTPUT_FILE="/home/scott/Documents/tmp/md/agent-transcripts/reads_range_searches.log"

command -v jq >/dev/null 2>&1 || {
  printf 'Error: jq is required.\n' >&2
  exit 2
}

[[ -r "$INPUT_FILE" ]] || {
  printf 'Error: tool log not found or unreadable: %s\n' "$INPUT_FILE" >&2
  exit 2
}

TEMP_FILE="$(mktemp "${OUTPUT_FILE}.XXXXXX")"
trap 'rm -f "$TEMP_FILE"' EXIT

jq -c '
  def decode_json_string:
    ("\"" + . + "\"") | fromjson;

  def shell_category($command):
    if $command | test("(^|[[:space:];|&])(sed[[:space:]]+-n|head|tail|nl[[:space:]]|awk)([[:space:];|&]|$)") then
      "read_range"
    elif $command | test("(^|[[:space:];|&])(rg|grep|ag|ack|find|fd|locate)([[:space:];|&]|$)") then
      "search"
    elif $command | test("(^|[[:space:];|&])(cat|less|more|jq|stat|file|wc|ls)([[:space:];|&]|$)|\\bgit[[:space:]]+(show|diff|status)\\b") then
      "read"
    else
      empty
    end;

  def referenced_files($command):
    [
      $command
      | scan("(?:/?[A-Za-z0-9_@%+=:,.-]+/)*[A-Za-z0-9_@%+=:,.-]+\\.(?:md|mdx|txt|json|jsonl|ya?ml|toml|ini|cfg|conf|sh|bash|zsh|py|js|jsx|ts|tsx|css|html|xml|csv|tsv|sql|pdf|docx)")
    ] | unique;

  def shell_commands:
    if .tool == "exec_command" then
      (.arguments | fromjson? | .cmd? // empty)
    elif .tool == "exec" then
      .arguments
      | scan("(?s)tools\\.exec_command\\(\\s*\\{.*?(?:\\\"cmd\\\"|cmd)\\s*:\\s*\\\"((?:\\\\.|[^\\\"])*)\\\"")
      | .[0]
      | decode_json_string
    else
      empty
    end;

  def direct_tool_record:
    if .tool == "web__run" and (.arguments | test("search_query|image_query|\\\"find\\\"")) then
      {tool: .tool, arguments: .arguments, files: [], category: "search"}
    elif .tool == "read_mcp_resource" or .tool == "view_image" then
      {tool: .tool, arguments: .arguments, files: [], category: "read"}
    else
      empty
    end;

  select(.record == "call")
  | . as $call
  | [
      (
        $call
        | shell_commands
        | . as $command
        | shell_category($command) as $category
        | select($category != null)
        | {
            tool: "exec_command",
            command: $command,
            files: referenced_files($command),
            category: $category
          }
      ),
      ($call | direct_tool_record)
    ]
  | .[]
' "$INPUT_FILE" >"$TEMP_FILE"

mv "$TEMP_FILE" "$OUTPUT_FILE"
trap - EXIT

printf 'Wrote %s read, range-read, or search commands to %s\n' \
  "$(wc -l < "$OUTPUT_FILE")" \
  "$OUTPUT_FILE"
