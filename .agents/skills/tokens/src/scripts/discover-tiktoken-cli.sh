#!/usr/bin/env bash

find_tiktoken_cli() {
  local candidate npm_prefix

  candidate="$(command -v tiktoken-cli 2>/dev/null || true)"
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  candidate="$(which tiktoken-cli 2>/dev/null || true)"
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  npm_prefix="$(npm prefix -g 2>/dev/null || true)"
  if [[ -n "$npm_prefix" ]]; then
    candidate="$(find "$npm_prefix" -path '*/bin/tiktoken-cli' -type f -print -quit 2>/dev/null || true)"
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  fi

  return 1
}
