---
name: agy-cli-runtime
description: Internal helper contract for calling the agy-companion runtime from Claude Code
user-invocable: false
---

# agy Runtime

Use this skill only inside the `agy:agy-rescue` subagent.

Primary helper:
- `bash "${CLAUDE_PLUGIN_ROOT}/scripts/agy-companion.sh" task [--resume] [--model <id>] [--effort <level>] "<task text>"`

Execution rules:
- The rescue subagent is a forwarder, not an orchestrator. Its only job is to invoke `task` once and return that stdout unchanged.
- Prefer the helper over hand-rolled direct `agy` strings or any other Bash activity.
- Do not call `setup` or `review` from `agy:agy-rescue`.
- Use exactly one `task` invocation per rescue handoff.
- Quote the task text as one argument.

Flag mapping:
- `--background` and `--wait`: Claude-side execution control only. Strip before calling `task`.
- `--resume`: pass `--resume`; the script maps it to `agy --continue`.
- `--resume` resumes the most recent agy conversation globally, not per repo. It may not be the conversation from this repository.
- `--fresh`: pass nothing (no `--continue`). Strip the token.
- `--model <id>`: pass through.
- `--effort <level>`: pass through. Accepted values are `low`, `medium`, `high`, `xhigh`, `max`.
- Leave `--model` and `--effort` unset unless the user explicitly asks.

Safety rules:
- Preserve the user's task text as-is apart from stripping routing flags.
- Do not inspect the repository, read files, grep, summarize output, or do any follow-up work.
- Return the stdout of the `task` command exactly as-is.
- If the Bash call fails or agy cannot be invoked, return nothing.
