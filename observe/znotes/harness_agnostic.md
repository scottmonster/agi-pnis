- The system is intended to remain harness-agnostic: it must work across applicable runtimes rather than assume one agent platform, telemetry setup, tool stack, storage product, or capture mechanism.

- Requirements should only mandate information that can reasonably be expected across those harnesses. Information that may be absent, restricted, unsafe, or inapplicable is handled “when available.”

- The design distinguishes minimum qualifying evidence from helpful investigation detail. A record can establish a violation without knowing its root cause, responsible actor, corrective action, traces, logs, or complete execution context.

- The protocol should retain available, material evidence and explicitly preserve meaningful evidence gaps or limitations, rather than treating missing data as a reason the record is invalid.

- Portability matters: durable references such as repository paths, revisions, hashes, artifact IDs, and concise excerpts are preferred over links that only work in the originating harness.

- Harness-specific requirements may be added later, but only where that harness can guarantee the relevant data. Until then, fields such as provider/model settings, reasoning configuration, telemetry, and detailed context remain optional and availability-aware.