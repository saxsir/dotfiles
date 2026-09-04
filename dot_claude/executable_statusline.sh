#!/bin/bash

# Check jq availability
if ! command -v jq > /dev/null 2>&1; then
  printf "statusline: jq not found"
  exit 0
fi

# Read JSON input from stdin
input=$(cat)

# Extract all values from JSON in a single jq call for performance
eval "$(echo "${input}" | jq -r '
  "model_name=\(.model.display_name // "unknown" | @sh)",
  "current_dir=\(.workspace.current_dir // "" | @sh)",
  "remaining_pct=\(.context_window.remaining_percentage // -1 | floor)",
  "rate_5h=\(.rate_limits.five_hour.used_percentage // -1 | floor)",
  "rate_5h_reset=\(.rate_limits.five_hour.resets_at // -1)",
  "rate_7d=\(.rate_limits.seven_day.used_percentage // -1 | floor)",
  "rate_7d_reset=\(.rate_limits.seven_day.resets_at // -1)",
  "effort=\(.effort.level // "" | @sh)",
  "output_style=\(.output_style.name // "" | @sh)",
  "cache_warm=\(.prompt_cache.warm // false)",
  "cache_ttl=\(.prompt_cache.ttl // "" | @sh)",
  "cache_expires=\(.prompt_cache.expires_at // -1)",
  "cache_observed=\(.prompt_cache.caching_observed // false)"
')"

format_reset() {
  date -d "@$1" +"$2" 2>/dev/null || date -r "$1" +"$2" 2>/dev/null
}

dir_name=$(basename "${current_dir}")

# ===== Git Cache Mechanism =====
CACHE_TTL=5
cache_hash=$(printf '%s' "${current_dir}" | md5sum 2>/dev/null | cut -d' ' -f1)
if [ -z "${cache_hash}" ]; then
  cache_hash=$(printf '%s' "${current_dir}" | md5 -q 2>/dev/null)
fi
cache_file="/tmp/.claude-statusline-cache-${cache_hash}"

cache_is_stale() {
  [ ! -f "${cache_file}" ] && return 0
  local cache_mtime now
  cache_mtime=$(stat -c %Y "${cache_file}" 2>/dev/null || stat -f %m "${cache_file}" 2>/dev/null || echo 0)
  now=$(date +%s)
  [ $(( now - cache_mtime )) -gt "${CACHE_TTL}" ]
}

if cache_is_stale; then
  if git --no-optional-locks -C "${current_dir}" rev-parse --git-dir > /dev/null 2>&1; then
    _branch=$(git --no-optional-locks -C "${current_dir}" symbolic-ref --short HEAD 2>/dev/null || echo "detached")
    _staged=$(git --no-optional-locks -C "${current_dir}" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    _modified=$(git --no-optional-locks -C "${current_dir}" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    _raw_url=$(git --no-optional-locks -C "${current_dir}" remote get-url origin 2>/dev/null)
    _remote=$(echo "${_raw_url}" | sed -E 's|git@github\.com:|https://github.com/|; s|\.git$||')
    printf 'git_branch=%s\ngit_staged=%s\ngit_modified=%s\ngit_remote=%s\n' \
      "${_branch}" "${_staged}" "${_modified}" "${_remote}" > "${cache_file}"
  else
    printf 'git_branch=\ngit_staged=\ngit_modified=\ngit_remote=\n' > "${cache_file}"
  fi
fi

# shellcheck source=/dev/null
source "${cache_file}" 2>/dev/null

# ===== Color Definitions =====
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
WHITE_BOLD='\033[1;37m'
DIM='\033[2m'
RESET='\033[0m'

# ===== Context Window: Color + Progress Bar =====
ctx_color=""
bar=""
if [ "${remaining_pct}" -ge 0 ] 2>/dev/null; then
  if [ "${remaining_pct}" -ge 70 ]; then
    ctx_color="${GREEN}"
  elif [ "${remaining_pct}" -ge 30 ]; then
    ctx_color="${YELLOW}"
  else
    ctx_color="${RED}"
  fi
  filled=$(( remaining_pct / 10 ))
  empty=$(( 10 - filled ))
  bar=""
  for (( i=0; i<filled; i++ )); do bar+="█"; done
  for (( i=0; i<empty; i++ )); do bar+="░"; done
fi

# ===== Rate Limits =====
limits=""
if [ "${rate_5h}" -ge 0 ] 2>/dev/null; then
  limits="5h: ${rate_5h}%"
  if [ "${rate_5h_reset}" -gt 0 ] 2>/dev/null; then
    reset_str=$(format_reset "${rate_5h_reset}" "%H:%M")
    [ -n "${reset_str}" ] && limits="${limits} (${reset_str})"
  fi
fi
if [ "${rate_7d}" -ge 0 ] 2>/dev/null; then
  limits="${limits:+${limits} | }7d: ${rate_7d}%"
  if [ "${rate_7d_reset}" -gt 0 ] 2>/dev/null; then
    reset_str=$(format_reset "${rate_7d_reset}" "%m/%d %H:%M")
    [ -n "${reset_str}" ] && limits="${limits} (${reset_str})"
  fi
fi

# ===== Render Line 1 =====
# Arrow
printf "\033[1;31m➜\033[0m "

# Repo name with OSC 8 hyperlink (clickable in supported terminals)
if [ -n "${git_remote}" ]; then
  printf '\033]8;;%s\a' "${git_remote}"
  printf '\033[36m%s\033[0m' "${dir_name}"
  printf '\033]8;;\a'
else
  printf '\033[36m%s\033[0m' "${dir_name}"
fi

# Git branch + staged/modified counts
if [ -n "${git_branch}" ]; then
  printf ' \033[1;37mgit:(%s)\033[0m' "${git_branch}"
  [ "${git_staged:-0}" -gt 0 ] && printf ' \033[32m+%s\033[0m' "${git_staged}"
  [ "${git_modified:-0}" -gt 0 ] && printf ' \033[33m~%s\033[0m' "${git_modified}"
fi

# Rate limits
if [ -n "${limits}" ]; then
  printf ' \033[2m[%s]\033[0m' "${limits}"
fi

printf '\n'

# ===== Render Line 2 =====
printf '  '

# Context progress bar with color
if [ -n "${ctx_color}" ]; then
  printf '%b[%s]%b %b%d%%%b' "${ctx_color}" "${bar}" "${RESET}" "${ctx_color}" "${remaining_pct}" "${RESET}"
fi

# Model name
if [ -n "${model_name}" ] && [ "${model_name}" != "unknown" ]; then
  printf ' %b%s%b' "${DIM}" "${model_name}" "${RESET}"
fi

# Effort level
if [ -n "${effort}" ]; then
  printf ' %b%s%b' "${DIM}" "${effort}" "${RESET}"
fi

# Output style (default は表示しない)
if [ -n "${output_style}" ] && [ "${output_style}" != "default" ]; then
  printf ' %b%s%b' "${DIM}" "style:${output_style}" "${RESET}"
fi

# Prompt cache status
if [ "${cache_observed}" = "true" ]; then
  now=$(date +%s)
  if [ "${cache_warm}" = "true" ]; then
    if [ "${cache_expires}" -le 0 ] 2>/dev/null; then
      cache_str="cache:warm"
    else
      cache_mins=$(( (cache_expires - now) / 60 ))
      cache_str="cache:${cache_mins}m"
      [ -n "${cache_ttl}" ] && cache_str="${cache_str}(${cache_ttl})"
    fi
    printf ' %b%s%b' "${GREEN}" "${cache_str}" "${RESET}"
  else
    cache_str="cache:cold"
    [ -n "${cache_ttl}" ] && cache_str="${cache_str}(${cache_ttl})"
    printf ' %b%s%b' "${RED}" "${cache_str}" "${RESET}"
  fi
fi
