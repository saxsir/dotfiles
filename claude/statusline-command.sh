#!/bin/bash

# Check jq availability
if ! command -v jq > /dev/null 2>&1; then
  printf "statusline: jq not found"
  exit 0
fi

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
model_name=$(echo "${input}" | jq -r '.model.display_name')
current_dir=$(echo "${input}" | jq -r '.workspace.current_dir')
output_style=$(echo "${input}" | jq -r '.output_style.name // "default"')
remaining=$(echo "${input}" | jq -r '.context_window.remaining_percentage // empty')

# Get current directory basename
dir_name=$(basename "${current_dir}")

# Get git branch info with --no-optional-locks to avoid locking issues
if git --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || echo "detached")
  if [ -n "$(git --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    git_status="git:(${branch}) ✗"
  else
    git_status="git:(${branch})"
  fi
else
  git_status=""
fi

# Build status line with colors (matching jbergantine theme)
# Red arrow, green space, cyan directory, white git info
printf "\033[1;31m➜\033[0m \033[1;32m \033[0m\033[36m%s\033[0m" "${dir_name}"

if [ -n "${git_status}" ]; then
  printf " \033[1;37m%s\033[0m" "${git_status}"
fi

# Add context info if available
if [ -n "${remaining}" ]; then
  printf " \033[2m[ctx: %.0f%%]\033[0m" "${remaining}"
fi

# Add model and output style info
printf " \033[2m[%s | %s]\033[0m" "${model_name}" "${output_style}"
