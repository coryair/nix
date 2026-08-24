#!/bin/bash
# Claude Code statusLine script
# Shows: model name, current working directory, git branch, context remaining %

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")

branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi

remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Dim color codes for terminal output
DIM='\033[2m'
RESET='\033[0m'

parts=()
parts+=("${model}")
parts+=("${dir}")
if [ -n "$branch" ]; then
  parts+=("${branch}")
fi
if [ -n "$remaining" ]; then
  parts+=("$(printf '%.0f' "$remaining")% left")
fi

output=""
for p in "${parts[@]}"; do
  if [ -n "$output" ]; then
    output="${output} ${DIM}|${RESET} "
  fi
  output="${output}${p}"
done

printf "${DIM}%s${RESET}" "$output"
