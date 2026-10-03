#!/usr/bin/env bash

set -u

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SESSIONS_DIR="$CODEX_HOME/sessions"
ARCHIVED_DIR="$CODEX_HOME/archived_sessions"
SESSION_INDEX="$CODEX_HOME/session_index.jsonl"
STATE_DB="$CODEX_HOME/state_5.sqlite"
declare -A SESSION_NAME_CACHE=()
SESSION_NAME_CACHE_LOADED=0
SESSION_NAME=""
MAX_DISPLAY_NAME_LENGTH=120

ROLE="both"
CASE_SENSITIVE=0
CONVERSATION_SELECTOR="first"
MATCH_SELECTOR="all"
# Percentage of the terminal width used for each displayed match line.
OUTPUT_WIDTH_PERCENT=80
# Absolute maximum width for each displayed match line.
HARD_STOP=160
# Default maximum number of displayed matches per transcript. Set to 0 for no limit.
MAX_MATCHES_PER_FILE=3
CONTEXT_CHARS=""
SINCE_SECONDS=""
BETWEEN_NEAR=""
BETWEEN_FAR=""
SEARCH_ACTIVE=1
SEARCH_ARCHIVED=1
MODE="search"

if [[ -t 1 ]]; then
  COLOR_TIMESTAMP=$'\033[33m'
  COLOR_TEXT=$'\033[34m'
  COLOR_MATCH=$'\033[1;92m'
  COLOR_USER=$'\033[1;95m'
  COLOR_ASSISTANT=$'\033[1;96m'
  COLOR_LABEL=$'\033[37m'
  COLOR_NAME=$'\033[1;97m'
  COLOR_RESET=$'\033[0m'
else
  COLOR_TIMESTAMP=""
  COLOR_TEXT=""
  COLOR_MATCH=""
  COLOR_USER=""
  COLOR_ASSISTANT=""
  COLOR_LABEL=""
  COLOR_NAME=""
  COLOR_RESET=""
fi

usage() {
  cat <<'EOF'
Usage:
  codex-search.sh [options] "phrase"
  codex-search.sh "session ID or exact session name"
  codex-search.sh --list

Conversation selection, searched newest -> oldest:
  --conversation first|last|all|N   Default: first

Match selection inside each conversation, searched newest -> oldest:
  --match all|first|last|N          Default: all
                                    N means Nth newest match.
                                    Output is displayed oldest -> newest.

Message role:
  --role both|user|assistant         Default: both
  --user                             Same as --role user
  --assistant                        Same as --role assistant

Time filters, based on transcript file modification time:
  --since DURATION                   Search now back through DURATION
  --between NEAR FAR                Search conversations aged NEAR..FAR

Durations:
  30m  2h  4d  1w
  Also: 30min, 2hours, 4days, 1week

Other:
  -l, --list                         List session IDs and names
  --case-sensitive                   Default matching is case-insensitive
  --context N                        Characters on each side; overrides width-based context
  --max-matches N                    Matches displayed per conversation; default 3 (0 is unlimited)
  --active-only                      Search ~/.codex/sessions only
  --archived-only                    Search ~/.codex/archived_sessions only
  -h, --help

Examples:
  codex-search.sh "permission rule"

  codex-search.sh --list

  codex-search.sh "Discuss research framework strictness"

  codex-search.sh \
    --conversation all \
    "permission rule"

  codex-search.sh \
    --conversation 3 \
    --match 2 \
    "permission rule"

  codex-search.sh \
    --role user \
    --since 3d \
    "ralph loop"

  codex-search.sh \
    --between 1w 4w \
    "some phrase"

  codex-search.sh \
    --between 2h 10h \
    --assistant \
    "some phrase"
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 2
}

need_arg() {
  (($# >= 2)) || die "$1 requires a value"
}

parse_duration() {
  local raw="${1,,}"
  local n unit

  if [[ "$raw" =~ ^([0-9]+)(m|min|mins|minute|minutes)$ ]]; then
    n="${BASH_REMATCH[1]}"
    unit=60
  elif [[ "$raw" =~ ^([0-9]+)(h|hr|hrs|hour|hours)$ ]]; then
    n="${BASH_REMATCH[1]}"
    unit=3600
  elif [[ "$raw" =~ ^([0-9]+)(d|day|days)$ ]]; then
    n="${BASH_REMATCH[1]}"
    unit=86400
  elif [[ "$raw" =~ ^([0-9]+)(w|wk|wks|week|weeks)$ ]]; then
    n="${BASH_REMATCH[1]}"
    unit=604800
  else
    die "invalid duration '$1' (examples: 30m, 2h, 4d, 1w)"
  fi

  printf '%s\n' "$((n * unit))"
}

valid_selector() {
  [[ "$1" == "first" ||
     "$1" == "last" ||
     "$1" == "all" ||
     "$1" =~ ^[1-9][0-9]*$ ]]
}

PHRASE=""

while (($#)); do
  case "$1" in
    --conversation)
      need_arg "$@"
      CONVERSATION_SELECTOR="$2"
      valid_selector "$CONVERSATION_SELECTOR" ||
        die "invalid --conversation selector '$2'"
      shift 2
      ;;

    --match)
      need_arg "$@"
      MATCH_SELECTOR="$2"
      valid_selector "$MATCH_SELECTOR" ||
        die "invalid --match selector '$2'"
      shift 2
      ;;

    --role)
      need_arg "$@"
      ROLE="$2"
      [[ "$ROLE" == "both" ||
         "$ROLE" == "user" ||
         "$ROLE" == "assistant" ]] ||
        die "invalid role '$ROLE'"
      shift 2
      ;;

    --user)
      ROLE="user"
      shift
      ;;

    --assistant)
      ROLE="assistant"
      shift
      ;;

    --case-sensitive)
      CASE_SENSITIVE=1
      shift
      ;;

    --context)
      need_arg "$@"
      [[ "$2" =~ ^[0-9]+$ ]] ||
        die "--context must be a non-negative integer"
      CONTEXT_CHARS="$2"
      shift 2
      ;;

    --max-matches)
      need_arg "$@"
      [[ "$2" =~ ^[0-9]+$ ]] ||
        die "--max-matches must be a non-negative integer"
      MAX_MATCHES_PER_FILE="$2"
      shift 2
      ;;

    --since)
      need_arg "$@"
      SINCE_SECONDS="$(parse_duration "$2")"
      shift 2
      ;;

    --between)
      (($# >= 3)) ||
        die "--between requires NEAR and FAR durations"

      BETWEEN_NEAR="$(parse_duration "$2")"
      BETWEEN_FAR="$(parse_duration "$3")"

      ((BETWEEN_NEAR <= BETWEEN_FAR)) ||
        die "--between NEAR must be <= FAR"

      shift 3
      ;;

    --active-only)
      SEARCH_ACTIVE=1
      SEARCH_ARCHIVED=0
      shift
      ;;

    --archived-only)
      SEARCH_ACTIVE=0
      SEARCH_ARCHIVED=1
      shift
      ;;

    -l|--list)
      MODE="list"
      shift
      ;;

    -h|--help)
      usage
      exit 0
      ;;

    --)
      shift
      (($#)) || die "missing phrase"
      PHRASE="$*"
      break
      ;;

    -*)
      die "unknown option '$1'"
      ;;

    *)
      [[ -z "$PHRASE" ]] ||
        die "phrase must be supplied as one quoted argument"

      PHRASE="$1"
      shift

      (($# == 0)) ||
        die "phrase must be supplied as one quoted argument"
      ;;
  esac
done

if [[ "$MODE" == "list" ]]; then
  [[ -z "$PHRASE" ]] || die "--list does not accept a phrase"
else
  [[ -n "$PHRASE" ]] || die "missing phrase"
fi

command -v jq >/dev/null 2>&1 ||
  die "jq is required"

if [[ "$MODE" == "search" && -z "$CONTEXT_CHARS" ]]; then
  if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    TERMINAL_COLUMNS="$(tput cols 2>/dev/null || true)"
  else
    TERMINAL_COLUMNS=""
  fi

  if [[ "$TERMINAL_COLUMNS" =~ ^[1-9][0-9]*$ ]]; then
    OUTPUT_WIDTH="$((TERMINAL_COLUMNS * OUTPUT_WIDTH_PERCENT / 100))"
  else
    OUTPUT_WIDTH="$HARD_STOP"
  fi

  ((OUTPUT_WIDTH > HARD_STOP)) && OUTPUT_WIDTH="$HARD_STOP"
  ((OUTPUT_WIDTH < 1)) && OUTPUT_WIDTH=1

  CONTEXT_CHARS="$(((OUTPUT_WIDTH - ${#PHRASE} - 6) / 2))"
  ((CONTEXT_CHARS < 0)) && CONTEXT_CHARS=0
fi

if [[ -n "$SINCE_SECONDS" && -n "$BETWEEN_NEAR" ]]; then
  die "use either --since or --between, not both"
fi

SEARCH_DIRS=()

if ((SEARCH_ACTIVE)) && [[ -d "$SESSIONS_DIR" ]]; then
  SEARCH_DIRS+=("$SESSIONS_DIR")
fi

if ((SEARCH_ARCHIVED)) && [[ -d "$ARCHIVED_DIR" ]]; then
  SEARCH_DIRS+=("$ARCHIVED_DIR")
fi

((${#SEARCH_DIRS[@]})) ||
  die "no Codex session directories found under $CODEX_HOME"

NOW="$(date +%s)"

in_time_range() {
  local mtime_int="$1"
  local age=$((NOW - mtime_int))

  ((age < 0)) && age=0

  if [[ -n "$SINCE_SECONDS" ]]; then
    ((age <= SINCE_SECONDS)) || return 1
  elif [[ -n "$BETWEEN_NEAR" ]]; then
    ((age >= BETWEEN_NEAR && age <= BETWEEN_FAR)) ||
      return 1
  fi

  return 0
}

session_id_for_file() {
  local file="$1"
  local id

  id="$(
    head -n 1 "$file" 2>/dev/null |
      jq -Rr '
        fromjson?
        | select(.type == "session_meta")
        | .payload.id // .payload.session_id // empty
      ' 2>/dev/null
  )"

  if [[ -z "$id" &&
        "$(basename "$file")" =~ ([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}) ]]; then
    id="${BASH_REMATCH[1]}"
  fi

  printf '%s\n' "${id:-unknown}"
}

load_session_name_cache() {
  local id
  local name

  ((SESSION_NAME_CACHE_LOADED == 0)) ||
    return

  SESSION_NAME_CACHE_LOADED=1

  if [[ -r "$SESSION_INDEX" ]]; then
    while IFS= read -r -d '' id && IFS= read -r -d '' name; do
      [[ -n "$id" ]] &&
        SESSION_NAME_CACHE["$id"]="$name"
    done < <(
      jq -Rrj '
        fromjson?
        | select(.id != null and .thread_name != null)
        | .id, .thread_name
        | . + "\u0000"
      ' "$SESSION_INDEX" 2>/dev/null
    )
  fi

  if [[ -r "$STATE_DB" ]] &&
     command -v sqlite3 >/dev/null 2>&1; then
    while IFS= read -r -d '' id && IFS= read -r -d '' name; do
      [[ -n "$id" &&
            -z "${SESSION_NAME_CACHE[$id]+present}" ]] &&
        SESSION_NAME_CACHE["$id"]="$name"
    done < <(
      sqlite3 -readonly -json "$STATE_DB" \
        'SELECT id, title FROM threads WHERE title IS NOT NULL;' \
        2>/dev/null |
        jq -rj '
          .[]
          | select(.id != null and .title != null)
          | (.id + "\u0000"), (.title + "\u0000")
        ' 2>/dev/null
    )
  fi
}

set_vscode_name_for_id() {
  local id="$1"
  local name=""

  load_session_name_cache

  if [[ "$id" != "unknown" &&
        -n "${SESSION_NAME_CACHE[$id]+present}" ]]; then
    name="${SESSION_NAME_CACHE[$id]}"
  fi

  SESSION_NAME="${name:-(unnamed)}"
}

vscode_name_for_id() {
  set_vscode_name_for_id "$1"
  printf '%s\n' "$SESSION_NAME"
}

session_name_for_display() {
  local name="$1"
  local truncated=0

  if ((${#name} > MAX_DISPLAY_NAME_LENGTH - 3)); then
    name="${name:0:$((MAX_DISPLAY_NAME_LENGTH - 3))}"
    truncated=1
  fi

  name="${name//$'\r'/ }"
  name="${name//$'\n'/ }"
  name="${name//$'\t'/ }"

  while [[ "$name" == ' '* ]]; do
    name="${name# }"
  done

  while [[ "$name" == *' ' ]]; do
    name="${name% }"
  done

  ((truncated)) && name="${name}..."

  printf '%s\n' "${name:-(unnamed)}"
}

MATCHES=()

scan_file() {
  local file="$1"

  mapfile -t MATCHES < <(
    jq -Rrc \
      --arg phrase "$PHRASE" \
      --arg role "$ROLE" \
      --argjson ci "$((1 - CASE_SENSITIVE))" \
      --argjson ctx "$CONTEXT_CHARS" '

      def msg:
        fromjson?
        | select(.type == "event_msg")
        | . as $root
        | .payload as $p
        | if $p.type == "user_message" then
            {
              timestamp: ($root.timestamp // ""),
              role: "user",
              text: (
                ($p.message // "")
                | gsub("[\\r\\n\\t]+"; " ")
                | gsub("  +"; " ")
              )
            }
          elif $p.type == "agent_message" then
            {
              timestamp: ($root.timestamp // ""),
              role: "assistant",
              text: (
                ($p.message // "")
                | gsub("[\\r\\n\\t]+"; " ")
                | gsub("  +"; " ")
              )
            }
          else
            empty
          end;

      def wanted_role:
        $role == "both" or .role == $role;

      def fold($s):
        if $ci == 1
        then ($s | ascii_downcase)
        else $s
        end;

      def max2($a; $b):
        if $a > $b then $a else $b end;

      def min2($a; $b):
        if $a < $b then $a else $b end;

      msg
      | select(wanted_role)
      | . as $m

      | fold($m.text) as $hay
      | fold($phrase) as $needle

      | ($hay | indices($needle)[]) as $pos
      | ($phrase | length) as $n

      | max2(0; $pos - $ctx) as $lo
      | min2(
          ($m.text | length);
          $pos + $n + $ctx
        ) as $hi

      | ($m.text[$lo:$pos]) as $before
      | ($m.text[$pos:($pos + $n)]) as $hit
      | ($m.text[($pos + $n):$hi]) as $after

      | {
          timestamp: $m.timestamp,
          role: $m.role,
          message_id: input_line_number,
          before: (
            (
              if $ctx > 0 and $lo > 0
              then "..."
              else ""
              end
            )
            + $before
          ),
          hit: $hit,
          after: (
            $after
            + (
              if $ctx > 0 and $hi < ($m.text | length)
              then "..."
              else ""
              end
            )
          )
        }
    ' "$file" 2>/dev/null
  )

  ((${#MATCHES[@]} > 0))
}

format_timestamp() {
  local timestamp="$1"

  [[ -n "$timestamp" ]] || {
    printf 'unknown-time\n'
    return
  }

  date -d "$timestamp" '+%Y-%m-%d %H:%M:%S' 2>/dev/null ||
    printf '%s\n' "$timestamp"
}

print_match_group() {
  local entry="${GROUP_ENTRIES[0]}"
  local timestamp
  local role
  local role_color
  local index=0
  local before
  local hit
  local after

  timestamp="$(jq -r '.timestamp' <<<"$entry")"
  role="$(jq -r '.role' <<<"$entry")"

  if [[ "$role" == "user" ]]; then
    role_color="$COLOR_USER"
  else
    role_color="$COLOR_ASSISTANT"
  fi

  printf '\n%s%s%s  %s[%s]%s  %d %s\n' \
    "$COLOR_TIMESTAMP" \
    "$(format_timestamp "$timestamp")" \
    "$COLOR_RESET" \
    "$role_color" \
    "$role" \
    "$COLOR_RESET" \
    "${#GROUP_ENTRIES[@]}" \
    "$([[ ${#GROUP_ENTRIES[@]} == 1 ]] && printf 'match' || printf 'matches')"

  for entry in "${GROUP_ENTRIES[@]}"; do
    ((index++))
    before="$(jq -r '.before' <<<"$entry")"
    hit="$(jq -r '.hit' <<<"$entry")"
    after="$(jq -r '.after' <<<"$entry")"

    printf '  %d │ %s%s%s%s%s%s\n' \
      "$index" \
      "$COLOR_TEXT" \
      "$before" \
      "$COLOR_MATCH" \
      "$hit" \
      "$COLOR_TEXT" \
      "$after$COLOR_RESET"
  done
}

selected_match_indexes() {
  local count="$1"
  local selector="$MATCH_SELECTOR"
  local limit="$MAX_MATCHES_PER_FILE"
  local i
  local start=0

  if [[ "$selector" == "all" && "$limit" != 0 && "$count" -gt "$limit" ]]; then
    start=$((count - limit))
  fi

  case "$selector" in
    all)
      for ((i = start; i < count; i++)); do
        printf '%s\n' "$i"
      done
      ;;

    first)
      # First searched = newest.
      printf '%s\n' "$((count - 1))"
      ;;

    last)
      # Last searched = oldest.
      printf '0\n'
      ;;

    *)
      # Nth newest.
      if ((selector <= count)); then
        printf '%s\n' "$((count - selector))"
      fi
      ;;
  esac
}

print_conversation() {
  local file="$1"
  local id
  local name
  local modified
  local idx
  local entry
  local message_id
  local current_message_id=""
  local shown=0
  local -a GROUP_ENTRIES=()

  id="$(session_id_for_file "$file")"
  set_vscode_name_for_id "$id"
  name="$(session_name_for_display "$SESSION_NAME")"

  modified="$(
    date -d "@$(stat -c %Y "$file")" \
      '+%Y-%m-%d %H:%M:%S' \
      2>/dev/null ||
      stat -c %y "$file"
  )"

  printf '%s%s%s\n' "$COLOR_NAME" "$name" "$COLOR_RESET"
  printf '%sSession:%s  %s\n' "$COLOR_LABEL" "$COLOR_RESET" "$id"
  printf '%sFile:%s     %s\n' "$COLOR_LABEL" "$COLOR_RESET" "$file"
  printf '%sModified:%s %s\n' "$COLOR_LABEL" "$COLOR_RESET" "$modified"
  if [[ "$MATCH_SELECTOR" == "all" &&
        "$MAX_MATCHES_PER_FILE" != 0 &&
        "${#MATCHES[@]}" -gt "$MAX_MATCHES_PER_FILE" ]]; then
    printf '%sMatches:%s  %d shown of %d\n' \
      "$COLOR_LABEL" "$COLOR_RESET" "$MAX_MATCHES_PER_FILE" "${#MATCHES[@]}"
  else
    printf '%sMatches:%s  %d\n' "$COLOR_LABEL" "$COLOR_RESET" "${#MATCHES[@]}"
  fi
  printf '%s\n' '────────────────────────────────────────────────────────────'

  while IFS= read -r idx; do
    [[ -n "$idx" ]] || continue

    entry="${MATCHES[$idx]}"
    message_id="$(jq -r '.message_id' <<<"$entry")"

    if [[ -n "$current_message_id" &&
          "$message_id" != "$current_message_id" ]]; then
      print_match_group
      GROUP_ENTRIES=()
    fi

    current_message_id="$message_id"
    GROUP_ENTRIES+=("$entry")
    ((shown++))
  done < <(
    selected_match_indexes "${#MATCHES[@]}"
  )

  if ((shown == 0)); then
    printf '\n  Requested match does not exist in this conversation.\n'
  else
    print_match_group
  fi
}

session_records() {
  find "${SEARCH_DIRS[@]}" \
    -type f \
    -name '*.jsonl' \
    -printf '%T@\t%p\0' \
    2>/dev/null |
    sort -z -t $'\t' -k1,1nr
}

print_transcript() {
  local file="$1"
  local id
  local name
  local modified
  local entry
  local timestamp
  local role
  local role_color
  local message
  local message_count=0

  id="$(session_id_for_file "$file")"
  set_vscode_name_for_id "$id"
  name="$(session_name_for_display "$SESSION_NAME")"
  modified="$(
    date -d "@$(stat -c %Y "$file")" \
      '+%Y-%m-%d %H:%M:%S' \
      2>/dev/null ||
      stat -c %y "$file"
  )"

  printf '%s%s%s\n' "$COLOR_NAME" "$name" "$COLOR_RESET"
  printf '%sSession:%s  %s\n' "$COLOR_LABEL" "$COLOR_RESET" "$id"
  printf '%sFile:%s     %s\n' "$COLOR_LABEL" "$COLOR_RESET" "$file"
  printf '%sModified:%s %s\n' "$COLOR_LABEL" "$COLOR_RESET" "$modified"
  printf '%s\n' '────────────────────────────────────────────────────────────'

  while IFS= read -r entry; do
    timestamp="$(jq -r '.timestamp' <<<"$entry")"
    role="$(jq -r '.role' <<<"$entry")"
    message="$(jq -r '.message' <<<"$entry")"

    if [[ "$role" == "user" ]]; then
      role_color="$COLOR_USER"
    else
      role_color="$COLOR_ASSISTANT"
    fi

    printf '\n%s%s%s  %s[%s]%s\n' \
      "$COLOR_TIMESTAMP" \
      "$(format_timestamp "$timestamp")" \
      "$COLOR_RESET" \
      "$role_color" \
      "$role" \
      "$COLOR_RESET"
    printf '%s\n' "$message"
    ((message_count++))
  done < <(
    jq -Rrc '
      fromjson?
      | select(.type == "event_msg")
      | . as $root
      | .payload as $p
      | if $p.type == "user_message" then
          {
            timestamp: ($root.timestamp // ""),
            role: "user",
            message: ($p.message // "")
          }
        elif $p.type == "agent_message" then
          {
            timestamp: ($root.timestamp // ""),
            role: "assistant",
            message: ($p.message // "")
          }
        else
          empty
        end
    ' "$file" 2>/dev/null
  )

  if ((message_count == 0)); then
    printf '\nNo user or assistant messages found in this transcript.\n'
  fi
}

print_session_list() {
  local record
  local mtime
  local mtime_int
  local file
  local id
  local name

  while IFS= read -r -d '' record; do
    mtime="${record%%$'\t'*}"
    file="${record#*$'\t'}"
    mtime_int="${mtime%%.*}"

    in_time_range "$mtime_int" ||
      continue

    id="$(session_id_for_file "$file")"
    set_vscode_name_for_id "$id"
    name="$(session_name_for_display "$SESSION_NAME")"
    printf '%s\t%s\n' "$id" "$name"
  done < <(session_records)
}

print_exact_transcript() {
  local target="$1"
  local record
  local mtime
  local mtime_int
  local file
  local id
  local name
  local display_name
  local name_matches=0

  while IFS= read -r -d '' record; do
    mtime="${record%%$'\t'*}"
    file="${record#*$'\t'}"
    mtime_int="${mtime%%.*}"

    in_time_range "$mtime_int" ||
      continue

    id="$(session_id_for_file "$file")"
    if [[ "$id" == "$target" ]]; then
      print_transcript "$file"
      return 0
    fi

    set_vscode_name_for_id "$id"
    name="$SESSION_NAME"
    display_name="$(session_name_for_display "$name")"
    if [[ "$name" == "$target" || "$display_name" == "$target" ]]; then
      if ((name_matches > 0)); then
        printf '\n%s\n\n' \
          '------------------------------------------------------------'
      fi
      print_transcript "$file"
      ((name_matches++))
    fi
  done < <(session_records)

  ((name_matches > 0)) && return 0
  return 1
}

if [[ "$MODE" == "list" ]]; then
  print_session_list
  exit 0
fi

if print_exact_transcript "$PHRASE"; then
  exit 0
fi

matching_conversations=0
found_any=0

last_file=""
LAST_MATCHES=()

# GNU find/sort:
# Search transcripts by most recently modified first.
while IFS= read -r -d '' record; do

  mtime="${record%%$'\t'*}"
  file="${record#*$'\t'}"
  mtime_int="${mtime%%.*}"

  in_time_range "$mtime_int" ||
    continue

  scan_file "$file" ||
    continue

  found_any=1
  ((matching_conversations++))

  case "$CONVERSATION_SELECTOR" in

    first)
      print_conversation "$file"
      exit 0
      ;;

    all)
      if ((matching_conversations > 1)); then
        printf '\n%s\n\n' \
          '------------------------------------------------------------'
      fi

      print_conversation "$file"
      ;;

    last)
      last_file="$file"
      LAST_MATCHES=("${MATCHES[@]}")
      ;;

    *)
      if ((matching_conversations == CONVERSATION_SELECTOR)); then
        print_conversation "$file"
        exit 0
      fi
      ;;
  esac

done < <(session_records)

if [[ "$CONVERSATION_SELECTOR" == "last" &&
      -n "$last_file" ]]; then

  MATCHES=("${LAST_MATCHES[@]}")
  print_conversation "$last_file"
  exit 0
fi

if ((found_any == 0)); then
  printf 'Phrase not found: %s\n' "$PHRASE"
  exit 1
fi

if [[ "$CONVERSATION_SELECTOR" =~ ^[1-9][0-9]*$ ]] &&
   ((matching_conversations < CONVERSATION_SELECTOR)); then

  printf \
    'Only %d matching conversation(s) found; conversation %s does not exist.\n' \
    "$matching_conversations" \
    "$CONVERSATION_SELECTOR"

  exit 1
fi
