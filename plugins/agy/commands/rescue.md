---
description: Delegate investigation, an explicit fix request, or follow-up rescue work to the agy rescue subagent
argument-hint: "[--background|--wait] [--resume|--fresh] [--model <id>] [--effort <low|medium|high|xhigh|max>] [what agy should investigate, solve, or continue]"
allowed-tools: Bash(bash:*), Agent
---

Invoke the `agy:agy-rescue` subagent via the `Agent` tool (`subagent_type: "agy:agy-rescue"`), forwarding the raw user request as the prompt.
`agy:agy-rescue` is a subagent, not a skill. Do not call `Skill(agy:agy-rescue)` or `Skill(agy:rescue)` (that re-enters this command and hangs the session).
The final user-visible response must be agy's output verbatim.

Raw user request:
$ARGUMENTS

Execution mode:

- If the request includes `--background`, run the `agy:agy-rescue` subagent in the background.
- If the request includes `--wait`, run it in the foreground.
- If neither flag is present, default to foreground.
- `--background` and `--wait` are execution flags for Claude Code. Do not treat them as part of the task text.
- `--model` and `--effort` are runtime-selection flags. Preserve them for the forwarded `task` call.
- `--resume` and `--fresh` are routing flags. Leave them in the forwarded request.
- agy has no per-repo thread store, so do not ask whether to continue. If the user says continue, keep going, resume, or dig deeper, add `--resume` unless `--fresh` is present.

Operating rules:

- The subagent is a thin forwarder only. It uses one `Bash` call to invoke `bash "${CLAUDE_PLUGIN_ROOT}/scripts/agy-companion.sh" task ...` and returns stdout as-is.
- Return the agy stdout verbatim. Do not paraphrase, summarize, or add commentary.
- Leave `--effort` and `--model` unset unless the user asks.
- If agy is missing, stop and tell the user to run `/agy:setup`.
- If the user did not supply a request, ask what agy should investigate or fix.
