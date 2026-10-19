---
description: Check whether the local agy CLI is ready
argument-hint: ''
allowed-tools: Bash(bash:*)
---

Run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/agy-companion.sh" setup
```

Output rules:
- Present the setup output to the user as-is.
- If agy is missing, tell the user it must be installed by them. Do not guess or run an install command.
