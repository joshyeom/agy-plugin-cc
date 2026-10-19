#!/usr/bin/env bash
# Thin wrapper around the agy CLI: setup | task | review
set -euo pipefail

AGY="${AGY_BIN:-$(command -v agy 2>/dev/null || echo "$HOME/.local/bin/agy")}"
TIMEOUT="900s"

die() { echo "agy-companion: $*" >&2; exit 1; }

cmd_setup() {
  if [[ ! -x "$AGY" ]]; then
    echo "agy: NOT FOUND (looked for $AGY). It must be installed by the user."
    exit 1
  fi
  echo "agy: found at $AGY"
  "$AGY" models 2>&1 | head -20 || true
}

cmd_task() {
  local flags=(--dangerously-skip-permissions) text=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --resume) flags+=(--continue); shift ;;
      --read-only) flags+=(--sandbox); shift ;;
      --fresh|--background|--wait) shift ;;
      --model|--effort) [[ $# -ge 2 ]] || die "$1 needs a value"; flags+=("$1" "$2"); shift 2 ;;
      *) text+=("$1"); shift ;;
    esac
  done
  [[ ${#text[@]} -gt 0 ]] || die "task text is empty"
  "$AGY" ${flags[@]+"${flags[@]}"} --print-timeout "$TIMEOUT" "-p=${text[*]}"
}

cmd_review() {
  local base="" scope="auto" focus=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --base) [[ $# -ge 2 ]] || die "--base needs a value"; base="$2"; shift 2 ;;
      --scope) [[ $# -ge 2 ]] || die "--scope needs a value"; scope="$2"; shift 2 ;;
      --wait|--background) shift ;;
      *) focus+=("$1"); shift ;;
    esac
  done
  case "$scope" in auto|working-tree|branch) ;; *) die "invalid --scope: $scope" ;; esac

  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || die "not inside a git repository"
  cd "$root"

  if [[ "$scope" == auto ]]; then
    if [[ -n "$base" ]]; then scope=branch
    elif [[ -n "$(git status --porcelain --untracked-files=all)" ]]; then scope=working-tree
    else scope=branch; fi
  fi

  diff=""
  diff="$(mktemp "$root/.agy-review-XXXXXX")"
  trap 'rm -f "${diff:-}"' EXIT

  if [[ "$scope" == working-tree ]]; then
    {
      if git rev-parse -q --verify HEAD >/dev/null; then git diff HEAD; else git diff --cached; git diff; fi
      git ls-files --others --exclude-standard -z | while IFS= read -r -d '' f; do
        [[ "$root/$f" == "$diff" ]] && continue
        git diff --no-index -- /dev/null "$f" || true
      done
    } >"$diff" || true
  else
    if [[ -z "$base" ]]; then
      base="$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || { git rev-parse -q --verify main >/dev/null && echo main; } || echo master)"
    fi
    git diff "$base...HEAD" >"$diff" || die "cannot diff against $base"
  fi

  if [[ ! -s "$diff" ]]; then echo "Nothing to review."; exit 0; fi

  local name prompt
  name="$(basename "$diff")"
  prompt="Act as a code reviewer. Read the diff in the file $name in the current directory (scope: $scope). Consult other repository files as needed for context. Report only material correctness, security, or data-loss findings, each with file:line. No style nits. If there are no material findings, say so."
  if [[ ${#focus[@]} -gt 0 ]]; then prompt+=" Reviewer focus: ${focus[*]}"; fi
  prompt+=" Do not modify, create, or delete any file."
  "$AGY" --sandbox --dangerously-skip-permissions --print-timeout "$TIMEOUT" "-p=$prompt"
}

sub="${1:-}"; [[ $# -gt 0 ]] && shift
case "$sub" in
  setup) cmd_setup "$@" ;;
  task) cmd_task "$@" ;;
  review) cmd_review "$@" ;;
  *) die "usage: agy-companion.sh setup|task|review ..." ;;
esac
