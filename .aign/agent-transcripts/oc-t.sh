#!/usr/bin/env bash
# Print the human-readable user and assistant messages from an OpenCode session.
#
# This reads the local SQLite store directly. `opencode export` can emit a
# truncated JSON document for sessions with large tool output.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'Usage: %s SESSION_ID\n' "${0##*/}" >&2
  exit 64
fi

session_id=$1
if [[ ! $session_id =~ ^[A-Za-z0-9_-]+$ ]]; then
  printf 'Error: invalid session ID: %s\n' "$session_id" >&2
  exit 64
fi

for command in jq sqlite3; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Error: required command not found: %s\n' "$command" >&2
    exit 69
  fi
done

database=${OPENCODE_DB:-"${XDG_DATA_HOME:-$HOME/.local/share}/opencode/opencode.db"}
if [[ ! -r $database ]]; then
  printf 'Error: OpenCode database is not readable: %s\n' "$database" >&2
  exit 66
fi

sqlite3 -readonly -json "$database" "
  SELECT
    json_extract(message.data, '\$.role') AS role,
    json_extract(part.data, '\$.text') AS text
  FROM message
  JOIN part ON part.message_id = message.id
  WHERE message.session_id = '$session_id'
    AND json_extract(message.data, '\$.role') IN ('user', 'assistant')
    AND json_extract(part.data, '\$.type') = 'text'
  ORDER BY message.time_created, part.time_created, part.id;
" | jq -r '
  .[]
  | "## \(.role | ascii_upcase)\n\n\(.text)"
'
