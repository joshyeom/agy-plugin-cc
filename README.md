# agy plugin for Claude Code

Use agy from inside Claude Code to review code or delegate tasks.

## What You Get

- `/agy:review` for an agy review of your working tree or branch
- `/agy:rescue` to delegate a task to agy, also available as the `agy:agy-rescue` subagent
- `/agy:setup` to check that the `agy` CLI is found

## Requirements

- The `agy` CLI installed and on your `PATH`. Verify with `agy --help`.
- bash
- git (for `/agy:review`)

## Install

Add the marketplace in Claude Code:

```bash
/plugin marketplace add joshyeom/agy-plugin-cc
```

Install the plugin:

```bash
/plugin install agy@agy-plugin-cc
```

Reload plugins:

```bash
/reload-plugins
```

Or from the shell:

```bash
claude plugin marketplace add joshyeom/agy-plugin-cc
claude plugin install agy@agy-plugin-cc
```

Then run `/agy:setup` to confirm agy is found.

## Usage

### `/agy:rescue`

```bash
/agy:rescue [--background|--wait] [--resume|--fresh] [--model <id>] [--effort low|medium|high|xhigh|max] <task>
```

Delegates a task to agy.

### `/agy:review`

```bash
/agy:review [--wait|--background] [--base <ref>] [--scope auto|working-tree|branch] [focus]
```

Runs an agy review of your changes. Optional `focus` text steers what agy looks at.

### `/agy:setup`

Checks that `agy` is available and prints its path.

## Notes

- `--resume` uses agy `--continue`, which picks the most recent agy conversation globally, not per repo.
- Unlike the codex plugin, there is no background job tracking, no status/result/cancel commands, and no Stop hook.
- `/agy:review` writes a temporary diff file named `.agy-review-*` in the repo root and removes it on exit.
