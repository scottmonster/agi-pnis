On Linux, Codex CLI session transcripts are stored under:

```sh
~/.codex/sessions/
```

The individual transcripts are JSONL files, typically named something like:

```sh
~/.codex/sessions/**/rollout-<session-id>.jsonl
```

Codex also uses:

```sh
~/.codex/session_index.jsonl
~/.codex/state_5.sqlite
```

for session metadata/indexing. Official Codex docs specifically reference session files under `~/.codex/sessions/`. ([OpenAI Developers][1])

Archived transcripts may also appear under:

```sh
~/.codex/archived_sessions/
```

depending on version/state. ([GitHub][2])

To inspect them:

```sh
find ~/.codex/sessions -type f -name '*.jsonl'
```

[1]: https://developers.openai.com/codex/cli/features?utm_source=chatgpt.com "Codex CLI features"
[2]: https://github.com/openai/codex/issues/27131?utm_source=chatgpt.com "Codex self-ingests local session JSONL logs during token- ..."



